#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017 Koha-Suomi Oy
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

use Modern::Perl;
use Mojolicious::Lite;
use JSON;
use Data::Dumper;

use C4::Context;

my $mode = 'online_payments';

# This Mojolicious Lite server is designed to implement CPU online payment
# and Ceepos POS test server. Its main function is to automatically respond
# with success message to the payments provided in CPU-format given to /maksu.html
#
# Most basic validations are included:
# - check required parameters
# - validate SHA2 hash of payment
# - make sure given product code(s) exist in demo products
#
# Workflow:
# 1. User posts a JSON-message to /maksu.html. The payment should follow
#    the definitions provided in CPU documentation (version 2.1).
# 2. Test server makes basic validations described in the list above. If
#    validations fail, return appropriate error to the user.
# 3. If the payment request is okay, connect to "NotificationAddress" and
#    POST a JSON-message telling the REST API that the payment was paid.
# 4. For formal reasons, return "PaymentAddress" that would be used to
#    redirect the Borrower to CPU online shop. However, we will not actually
#    use this address for the sake of automation - we don't want to implement
#    the online shop itself. Simply returning a success message is enough.

# Initialize demo products
my $products;
$products->{'demo_001'} = { Price => '1000', Description => 'Myöhästymismaksu', Taxcode => '24' };
$products->{'demo_002'} = { Price => '1000', Description => 'Vuokra', Taxcode => '24' };
$products->{'demo_003'} = { Price => '1000', Description => 'Työsuorite', Taxcode => '24' };
$products->{'demo_004'} = { Price => '0', Description => 'Lasku', Taxcode => '24' };

# Return codes defined by CPU
# 1 = Payment completed
# 0 = Payment was cancelled or payment creation failed
# 2 = Pending
# 97 = Duplicate payment id
# 98 = Server error
# 99 = Invalid payment request

post '/maksu.html' => sub {
  my $c = shift;

  my $json = $c->req->json;

  if (exists $json->{Office}) {
    $mode = 'pos';
  }

  $c->app->log->debug(Dumper($json)."\n\n");

  # Check that the request is matching the Payment API
  if (not exists $json->{'Id'} or not $json->{'Id'}) {
    $c->render(text => "Connection accepted only with Payment API.");
    $c->app->log->debug(Dumper($json)."\n\n");
    warn("ERROR: Parameter Id is missing.\n");
    return;
  }

  my $error_98 = { Id => $json->{'Id'}, Status => 98, Reference => undef, Hash => ''};
  $error_98->{'Hash'} = CalculateResponseHash($error_98);

  my $error_99 = { Id => $json->{'Id'}, Status => 99, Reference => undef, Hash => ''};
  $error_99->{'Hash'} = CalculateResponseHash($error_99);

  # Check that the required fields are given
  if (not $json->{'ApiVersion'}
      or not $json->{'Source'}
      or not $json->{'Mode'}
      or not $json->{'Products'}
      or ($mode eq 'online_payments' && not $json->{'ReturnAddress'})
      or not $json->{'NotificationAddress'}
      or not $json->{'Hash'}) {
        $c->render(json => $error_99);
        $c->app->log->debug(Dumper($json)."\n\n");
        warn("ERROR: Invalid payment request. Returning error 99.\n");
        return;
  }

  # Check that each Product has required fields and that their
  # product code is found.
  foreach my $product (@{ $json->{'Products'} }){
    if (not $product->{'Code'}
        or not exists $products->{$product->{'Code'}}) {
        $c->render(json => $error_99);
        $c->app->log->debug(Dumper($json)."\n\n");
        warn("ERROR: Product code is not given, or it does not exist in demo products.\n\nReturning error 99.\n");
        return;
    }
  }

  # Make sure that the payment Hash is correct
  if ($json->{'Hash'} ne CalculatePaymentHash($json)) {
    $c->render(json => $error_99);
    $c->app->log->debug(Dumper($json)."\n\n");
    warn("ERROR: Invalid hash. Given hash was " . $json->{'Hash'}
         . " and the calculated hash was "
         . CalculatePaymentHash($json)
         . ".\n\nReturning error 99.\n"
         );
    return;
  }

  if ($mode eq 'pos') {
    sleep(5);
  }

  # To skip the online store and keep test environment fully automatically,
  # do not forward the user into an actual online shop. Instead, simply skip
  # this phase and forward the user directly to ReturnAddress.
  my $success = { Id              => '' . $json->{'Id'},
                  Status          => 1,
                  Reference       => '' . $json->{'Id'},
                  PaymentAddress  => $json->{'ReturnAddress'},
                  Hash            => ''
                };
  delete $success->{PaymentAddress} if $mode eq 'pos';
  $success->{'Hash'} = CalculateResponseHash($success);
  $success->{'Status'} = int($success->{'Status'});

  $c->render(json => $success);
  $mode = 'online_payments';
  # Fork and return; Return the JSON success response, and create a new process
  # for sending the success report to notification address
  fork and return;
  # If we get this far, everything seems to be okay with the request.
  # For formal reasons, let's return a PaymentAddress, and to complete
  # the payment send a POST request to NotificationAddress.
  SendNotification($c);

  exit;
};

sub SendNotification {
  my $c = shift;

  my $json = $c->req->json;
  if (exists $json->{Office}) {
    $mode = 'pos';
  }

  my $success = { Id              => '' . $json->{'Id'},
                  Status          => 1,
                  Reference       => '' . $json->{'Id'},
                  Hash            => ''
                };
  $success->{'Hash'} = CalculateResponseHash($success);
  $success->{'Status'} = 1;

  if ($mode ne 'pos') {
    sleep(1);
  }
  my $ua = Mojo::UserAgent->new;
  my $tx = $ua->post($json->{'NotificationAddress'}
                        => json => $success);

  if ($tx->res->code != 200) {
    $c->app->log->debug(Dumper($json)."\n\n");
    $c->app->log->debug("ERROR: Server did not respond with HTTP 200. The given response code was "
         . $tx->res->code . " (" . $tx->res->error->{message}. ")\n"
         . $tx->res->content->asset->{content} ."\nStatus report was:\n"
         . JSON->new->utf8->canonical(1)->encode($success)."\n"
         );
  }
};

sub CalculatePaymentHash {
    my $invoice = shift;
    my $data;

    warn "Mode: $mode\n";

    if ($mode eq 'pos') {
        return _calc_pos_hash($invoice);
    }

    $data .= (defined $invoice->{ApiVersion}) ? "&" . $invoice->{ApiVersion} : "&"
        if exists $invoice->{ApiVersion};
    $data .= (defined $invoice->{Source}) ? "&" . $invoice->{Source} : "&"
        if exists $invoice->{Source};
    $data .= (defined $invoice->{Id}) ? "&" . $invoice->{Id} : "&"
        if exists $invoice->{Id};
    $data .= (defined $invoice->{Mode}) ? "&" . $invoice->{Mode} : "&"
        if exists $invoice->{Mode};
    $data .= (defined $invoice->{Office}) ? "&" . $invoice->{Office} : "&"
        if exists $invoice->{Office};
    $data .= (defined $invoice->{Action}) ? "&" . $invoice->{Action} : "&"
        if exists $invoice->{Action};
    $data .= (defined $invoice->{Description}) ? "&" . $invoice->{Description} : "&"
        if exists $invoice->{Description};
    foreach my $product (@{ $invoice->{Products} }) {
        $data .= (defined $product->{Code}) ? "&" . $product->{Code} : "&"
        if exists $product->{Code};
        $data .= (defined $product->{Amount}) ? "&" . $product->{Amount} : "&"
        if exists $product->{Amount};
        $data .= (defined $product->{Price}) ? "&" . $product->{Price} : "&"
        if exists $product->{Price};
        $data .= (defined $product->{Description}) ? "&" . $product->{Description} : "&"
        if exists $product->{Description};
        $data .= (defined $product->{Taxcode}) ? "&" . $product->{Taxcode} : "&"
        if exists $product->{Taxcode};
    }
    $data .= (defined $invoice->{Email} and $invoice->{Email} ne "") ? "&" . $invoice->{Email} : "&"
        if exists $invoice->{Email};
        $data .= (defined $invoice->{FirstName}) ? "&" . $invoice->{FirstName} : "&"
        if exists $invoice->{FirstName};
        $data .= (defined $invoice->{LastName}) ? "&" . $invoice->{LastName} : "&"
        if exists $invoice->{LastName};
        $data .= (defined $invoice->{ReturnAddress}) ? "&" . $invoice->{ReturnAddress} : "&"
        if exists $invoice->{ReturnAddress};
        $data .= (defined $invoice->{NotificationAddress}) ? "&" . $invoice->{NotificationAddress} : "&"
        if exists $invoice->{NotificationAddress};

    $data =~ s/^&//g; # Remove first &
    $data .= "&" . C4::Context->config($mode)->{'CPU'}->{'secretKey'};
    $data = Encode::encode_utf8($data);
    return Digest::SHA::sha256_hex($data);
}

sub CalculateResponseHash {
    my $resp = shift;
    my $data = "";

    my $mode = 'online_payments';

    $data .= $resp->{Source} if defined $resp->{Source};
    $data .= "&" . $resp->{Id} if defined $resp->{Id};
    $data .= "&" . $resp->{Status} if defined $resp->{Status};
    $data .= "&" if exists $resp->{Reference};
    $data .= $resp->{Reference} if defined $resp->{Reference};
    $data .= "&" . $resp->{PaymentAddress} if defined $resp->{PaymentAddress};
    $data .= "&" . C4::Context->config($mode)->{'CPU'}->{'secretKey'};

    $data =~ s/^&//g;

    $data = Digest::SHA::sha256_hex($data);
    return $data;
}

# POS integration has a different way of calculating security hash
# CPU said they will unify these moment sometime in the future. Until then,
# use this alternative method:
sub _calc_pos_hash {
    my ($payment) = @_;
    my $data;

    foreach my $param (sort keys $payment){
        next if $param eq "Hash";
        my $value = $payment->{$param};

        if (ref($payment->{$param}) eq 'ARRAY') {
            my $product_hash = $value;
            $value = "";
            foreach my $product (values $product_hash){
                foreach my $product_data (sort keys $product){
                    $value .= $product->{$product_data} . "&";
                }
            }
            $value =~ s/&$//g
        }
        $data .= $value . "&";
    }

    $data .= C4::Context->config('pos')->{'CPU'}->{'secretKey'};
    $data = Encode::encode_utf8($data);
    return Digest::SHA::sha256_hex($data);
};

app->start;
