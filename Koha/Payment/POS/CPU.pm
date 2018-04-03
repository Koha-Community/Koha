package Koha::Payment::POS::CPU;

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use base qw(Koha::Payment::POS);

use C4::Context;

use Data::Dumper qw(Dumper);
use Digest::SHA qw(sha256_hex);
use Encode;
use HTTP::Request;
use IO::Socket::SSL;
use JSON;
use LWP::UserAgent;
use YAML::XS;

use Koha::Patron;
use Koha::Patrons;
use Koha::Items;
use Koha::Logger;
use Koha::PaymentsTransaction;
use Koha::PaymentsTransactions;
use Koha::Exception::NoSystemPreference;

sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';
    bless $self, $class;
    return $self;
};

=head2 add_custom_parameters

  &add_custom_parameters($payment, $query);

Adds custom parameters from $query into $payment.

Returns modified $payment where custom parameters from $query have been added.

=cut

sub add_custom_parameters {
    my ($class, $payment, $query) = @_;

    $payment->{'Office'} = $query->param("office");

    return $payment;
};

=head2 complete_payment

  &complete_payment($args);

Completes the payment in REST API.

=cut

sub complete_payment {
    my ($class, $args) = @_;

    my $transaction = Koha::PaymentsTransactions->find($args->{Id});
    return if not $transaction or $transaction->is_self_payment == 1;
    $transaction->CompletePayment($class->_get_response_string($args->{Status})->{status});
};

=head2 get_custom_parameters

  &get_custom_parameters($payment);

Gets custom parameters in order to display custom parameters in paycollect.tt.
This subroutine is given a prepared $payment in paycollect.pl.

=cut

sub get_custom_parameters {
    my ($class, $args) = @_;

    return { Office => $args->{'Office'} };
};

=head2 get_prepared_products

  &get_prepared_products($products, $branch);

Converts C<$products> from Koha::PaymentsTransaction->GetProducts() into a format
that matches CPU documentation, and converts Koha accounttypes from accountlines
into product codes recognized by CPU payment server.

=cut

sub get_prepared_products {
    my ($class, $products, $branch) = @_;
    return $class->_account_types_to_itemnumbers(
                       $class->_convert_to_cpu_products($products),
                       $branch
                    );
}

=head2 get_transaction_id

  &get_transaction_id($query);

Returns the transaction id (payment id) from C<$query>.

Returns transaction id if it is found in C<$query>.

=cut

sub get_transaction_id {
    my ($class, $query) = @_;

    return $query->param("Id");
};

=head2 is_valid_hash

  &is_valid_hash($query);

Validates C<$query> by calculating its checksum.

Returns true if valid checksum.

=cut

sub is_valid_hash {
    my ($class, $query) = @_;

    if (ref($query) eq "CGI") {
        return $query->param("Hash") eq $class->_calculate_response_hash({ $query->Vars() });
    } else {
        return $query->{'Hash'} eq $class->_calculate_response_hash($query);
    }
};

=head2 is_valid_return_address

  &is_valid_return_address($query);

Checks the C<$query> to determine whether given
parameter values are not tampered with.

Return true if the parameters are valid.

=cut

sub is_valid_return_address {
    my ($class, $query) = @_;

    return if not $class->is_return_address($query);

    return $query->param("Hash") eq _calculate_response_hash($query->param("Hash"));
};

=head2 prepare_payment

  &prepare_payment($payment, $input);

Converts C<$payment> HASH from paycollect.pl into a format
accepted by your POS provider.

Pass the CGI-object C<$query> if you want to use custom input
values.

=cut

sub prepare_payment {
    my ($class, $payment, $input) = @_;
    return $class->_get_payment($payment, $input);
};

=head2 send_payment

  &send_payment($payment);

Sends the payment using custom interface's implementation.

=cut

sub send_payment {
    my ($class, $payment) = @_;

    my $logger = Koha::Logger->get({ category => 'Koha.Payment.POS.CPU.send_payment'});

    my $content = $payment; # content will be JSON string, payment will be HASH
    my $response = eval {
        $content = JSON->new->canonical(1)->encode($payment);

        my $transaction = Koha::PaymentsTransactions->find($payment->{Id});
        return { error => "Error: No transaction found with id ".$payment->{Id}, status => 0 }
            if not $transaction;
        return { error => "Error: Transaction ".$payment->{Id}." is not a POS payment", status => 0 }
            if $transaction->is_self_payment != 0;

        my $server_config = $class->_get_server_config();
        my $ua = LWP::UserAgent->new;

        if ($server_config->{'ssl_cert'}) {
            $ua->ssl_opts(
                SSL_use_cert    => 1,
                SSL_cert_file   => $server_config->{'ssl_cert'},
                SSL_key_file    => $server_config->{'ssl_key'},
                SSL_ca_file     => $server_config->{'ssl_ca_file'},
                verify_hostname => 1,
            );
        }

        $ua->timeout(500);

        my $req = HTTP::Request->new(POST => $server_config->{'url'});
        $req->header('content-type' => 'application/json');

        $req->content($content);
        $transaction->set({ status => "pending" })->store();
        $logger->info("Sent payment: ".Dumper($payment));
        my $request = $ua->request($req);

        $transaction = Koha::PaymentsTransactions->find($payment->{Id});
        my $payment_already_paid = 1 if $transaction->status eq "paid"; # Already paid via REST API!
        return { status => 1 } if $payment_already_paid;

        if ($request->{_rc} != 200) {
            $logger->error('Payment '.$payment->{Id}.' did not return HTTP200 from server, but '.$request->{_rc});
            $transaction->set({ status => "cancelled", description => $request->{_content} })->store();
            return { error => $request->{_content}, status => 0 };
        }

        my $response = JSON->new->utf8->canonical(1)->decode($request->{_content});

        if ($response->{Hash} ne $class->_calculate_response_hash($response)) {
            $logger->error('Payment '.$payment->{Id}.' responded with invalid hash '.$response->{Hash});
            $transaction->set({ status => "cancelled", description => "Invalid hash" })->store();
            return { error => "Invalid hash", status => 0 };
        }

        my $response_str = $class->_get_response_int($response->{Status});
        if (defined $response_str->{description}) {
            $logger->error('Payment '.$payment->{Id}.' returned an error: '.$response_str->{description});
            $transaction->set({ status => "cancelled", description => $response_str->{description} })->store();
            return { error => $response_str->{description}, status => 0 };
        }

        return $response_str;
    };

    if ($@ || $response->{'error'}) {
        my $error = $@ || $response->{'error'};

        my $transaction = Koha::PaymentsTransactions->find($payment->{Id});
        $logger->error("No transaction found with id ".$payment->{Id}) if not $transaction;
        return JSON->new->utf8->canonical(1)->encode({ error => "Error: Transaction not found " .$payment->{Id}, status => 0 }) if not $transaction;
        return JSON->new->utf8->canonical(1)->encode({ status => 1 }) if $transaction->status eq "paid"; # Already paid via REST API!

        $logger->fatal("Payment ".$payment->{Id}." died with an error: $error");
        $transaction->set({ status => "cancelled", description => $error })->store();
        return JSON->new->utf8->canonical(1)->encode({ error => "Error: " . $error, status => 0 });
    }

    return JSON->new->utf8->canonical(1)->encode($response);
};

=head2 _account_types_to_itemnumbers

  &_account_types_to_itemnumbers($products, $branch);

Maps Koha-itemtypes (accountlines.accounttype) to CPU itemnumbers.

This is defined in system preference "POSIntegration" for POS integration.

Products is an array of Product (HASH) that are in the format of CPU-document.
Additionally, a product can have _itemnumber to define product code by item's home branch.

Returns an ARRAY of products (HASH).

=cut

sub _account_types_to_itemnumbers {
    my ($class, $products, $branch) = @_;

    my ($pref, $config);

    $pref = C4::Context->preference("POSIntegration");
    Koha::Exception::NoSystemPreference->throw(
            error => "YAML configuration in system preference "
                    ."'POSIntegration' is not defined! Cannot assign item numbers for accounttypes.",
            syspref => "POSIntegration"
            ) unless $pref;

    $config = YAML::XS::Load(
                            Encode::encode(
                                'UTF-8',
                                $pref,
                                Encode::FB_CROAK
                            ));
    $branch = "Default" unless ($config->{$branch});

    my $modified_products;

    for my $product (@$products){
        my $mapped_product = $product;
        # If accounttype is mapped to an item number
        if ($config->{$branch}->{$product->{Code}}) {
            $mapped_product->{Code} = $config->{$branch}->{$product->{Code}};
        } else {
            # Else, try to use accounttype "Default"
            Koha::Exception::NoSystemPreference->throw( error => "Could not assign item number to accounttype '".$product->{Code}."'. Configure system preference 'POSIntegration' with parameters 'Default'.", syspref => "POSIntegration" ) unless $config->{$branch}->{'Default'};

            $mapped_product->{Code} = $config->{$branch}->{'Default'};
        }

        push @$modified_products, $mapped_product;
    }

    return $modified_products;
};

=head2 _calculate_payment_hash

  &_calculate_payment_hash($payment);

Calculates a SHA256 checksum out of C<$payment>.

=cut

sub _calculate_payment_hash {
    my ($class, $payment) = @_;
    my $data;

    foreach my $param (sort keys %$payment){
        next if $param eq "Hash";
        my $value = $payment->{$param};

        if (ref($payment->{$param}) eq 'ARRAY') {
            my $product_hash = $value;
            $value = "";
            foreach my $product (values @$product_hash){
                foreach my $product_data (sort keys %$product){
                    $value .= $product->{$product_data} . "&";
                }
            }
            $value =~ s/&$//g
        }
        $data .= $value . "&";
    }

    $data .= $class->_get_server_config()->{'secretKey'};
    $data = Encode::encode_utf8($data);
    return Digest::SHA::sha256_hex($data);
};

=head2 _calculate_response_hash

  &_calculate_response_hash($payment);

Calculates a SHA256 checksum out of CPU C<$response>.

=cut

sub _calculate_response_hash {
    my ($class, $resp) = @_;
    my $data = "";

    my $transaction = Koha::PaymentsTransactions->find($resp->{Id});
    return if not $transaction;

    $data .= $resp->{Source} if defined $resp->{Source};
    $data .= "&" . $resp->{Id} if defined $resp->{Id};
    $data .= "&" . $resp->{Status} if defined $resp->{Status};
    $data .= "&" if exists $resp->{Reference};
    $data .= $resp->{Reference} if defined $resp->{Reference};
    $data .= "&" . $resp->{PaymentAddress} if defined $resp->{PaymentAddress};
    $data .= "&" . $class->_get_server_config()->{'secretKey'};

    $data =~ s/^&//g;

    $data = Digest::SHA::sha256_hex($data);
    return $data;
};

=head2 _convert_to_cpu_products

  &_convert_to_cpu_products($products);

Converts Koha::PaymentsTransaction->GetProducts() products into a format defined
in the CPU documentation.

See also Koha::PaymentsTransaction->GetProducts().

=cut

sub _convert_to_cpu_products {
    my ($class, $products) = @_;
    my $CPU_products;

    foreach my $product (@$products){
        my $tmp;

        $tmp->{Price} = $product->{price};
        $tmp->{Description} = $product->{description};
        $tmp->{Code} = $product->{accounttype};

        push @$CPU_products, $tmp;
    }

    return $CPU_products;
};

=head2 _get_payment

  &_get_payment($unprepared_payment, $query);

Creates a payment that has a format matching CPU's documentation.

=cut

sub _get_payment {
    my ($class, $unprepared_payment, $query) = @_;

    my $transaction = $unprepared_payment->{'transaction'};

    my $borrower = Koha::Patrons->cast($transaction->borrowernumber);

    my $payment;
    $payment->{ApiVersion}  = "2.0";
    $payment->{Source}      = $class->_get_server_config()->{'source'};
    $payment->{Id}          = $transaction->transaction_id;
    $payment->{Mode}        = C4::Context->config('pos')->{'CPU'}->{'mode'};
    if (C4::Context->config('pos')->{'CPU'}->{'receiptDescription'} eq 'borrower') {
        $payment->{Description} = $borrower->surname . ", " .  $borrower->firstname . " (".$borrower->cardnumber.")";
    } else {
        $payment->{Description} = "#" . $transaction->transaction_id;
    }
    $payment->{Products}    = $class->get_prepared_products($transaction->GetProducts(), C4::Context::mybranch());
    my $notificationAddress = C4::Context->config('pos')->{'CPU'}->{'notificationAddress'};
    my $transactionNumber = $transaction->transaction_id;
    $notificationAddress =~ s/{invoicenumber}/$transactionNumber/g;
    $payment->{NotificationAddress} = $notificationAddress;

    # Custom parameters
    $payment->{Office} = $query->param("Office");
    # / Custom parameters

    $payment = $class->_validate_cpu_hash($payment);
    $payment->{Hash}        = $class->_calculate_payment_hash($payment);
    $payment = $class->_validate_cpu_hash($payment);
    $payment->{"send_payment"} = "POST";

    return $payment;
}

=head2 _get_response_int

  &_get_response_int($code);

Converts a response from CPU into a HASH containing "status" and "description".
Status is the same code as CPU returned, and description is additional description
for possible errors.

=cut

sub _get_response_int {
    my ($class, $code) = @_;

    my $status;
    $status->{status} = 0;
    $status->{status} = 1 if $code == 1;
    $status->{status} = 2 if $code == 2;
    $status->{description} = "ERROR 97: Duplicate id" if $code == 97;
    $status->{description} = "ERROR 98: System error" if $code == 98;
    $status->{description} = "ERROR 99: Invalid invoice" if $code == 99;

    return $status;
}

=head2 _get_response_string

  &_get_response_string($code);

Converts a response from CPU into a HASH containing "status" and "description".
Status is a string representation of payment status that matches the definitions of
C<payments_transactions.status>.

Uses _get_response_int for the description-parameter. See also _get_response_int.

=cut

sub _get_response_string {
    my ($class, $code) = @_;

    my $response = $class->_get_response_int($code);
    my $status;
    $status->{status} = 'cancelled';
    $status->{status} = 'paid' if $response->{'status'} == 1;
    $status->{status} = 'pending' if $response->{'status'} == 2;
    $status->{description} = $response->{description} if $response->{description};

    return $status;
};

=head2 _validate_cpu_hash

  &_validate_cpu_hash($payment);

Makes some basic validations on C<$payment>. CPU has some requirements, such as:
A payment may not contain
- &-character
- ('-character bug was in online payments)
- (empty description was in online payments)

Trims both ends of a value, and sets Amount and Price parameter values as int.

=cut

sub _validate_cpu_hash {
    my ($class, $invoice) = @_;

    # CPU does not like a semicolon. Go through the fields and make sure
    # none of the fields contain ';' character (from CPU documentation)
    # Also it seems that fields should be trim()med or they could cause problems
    # in SHA2 hash calculation at payment server
    foreach my $field (keys %$invoice){
        $invoice->{$field} =~ s/;//g if defined $invoice->{$field}; # Remove semicolon
        $invoice->{$field} =~ s/^\s+|\s+$//g if defined $invoice->{$field}; # Trim both ends
        my $tmp_field = $invoice->{$field};
        $tmp_field = substr($invoice->{$field}, 0, 99) if (ref($invoice->{$field}) ne "ARRAY") and ($field ne "ReturnAddress") and ($field ne "NotificationAddress");
        $tmp_field =~ s/^\s+|\s+$//g if defined $tmp_field; # Trim again, because after substr there can be again whitelines around left & right
        $invoice->{$field} = $tmp_field;
    }

    $invoice->{Mode} = int($invoice->{Mode});
    foreach my $product (@{ $invoice->{Products} }){
        foreach my $product_field (keys %$product){
            $product->{$product_field} =~ s/;//g if defined $invoice->{$product_field}; # Remove semicolon
            $product->{$product_field} =~ s/'//g if defined $invoice->{$product_field}; # Remove '
            $product->{$product_field} =~ s/^\s+|\s+$//g if defined $invoice->{$product_field}; # Trim both ends
            $product->{$product_field} = substr($product->{$product_field}, 0, 99);
            $product->{$product_field} =~ s/^\s+|\s+$//g if defined $invoice->{$product_field}; # Trim again
        }
        $product->{Description} = "-" if $product->{'Description'} eq "";
        $product->{Amount} = int($product->{Amount}) if $product->{Amount};
        $product->{Price} = int($product->{Price}) if $product->{Price};
    }

    return $invoice;
};

sub _get_server_config {
    my ($self) = @_;

    my $branchcode = $self->{'branch'};
    $branchcode ||= C4::Context::mybranch();
    my $config = C4::Context->config('pos')->{'CPU'};

    if (exists $config->{'branchcode'}->{$branchcode}) {
        $config = $config->{'branchcode'}->{$branchcode};
    }

    return $config;
}

1;
