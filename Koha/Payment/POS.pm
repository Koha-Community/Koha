package Koha::Payment::POS;

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

use Modern::Perl;

use C4::Context;

use Koha::Exception::BadParameter;
use Koha::Exception::NoSystemPreference;
use Koha::Exception::NotImplemented;
use Koha::Exception::UnknownObject;

use Encode;
use Module::Load;
use YAML::XS;
use Data::Dumper;

=head

=NAME Koha::Payment::POS

=SYNOPSIS

This is an interface definition for Koha::Payment::POS::* -subclasses.
This documentation explains how to subclass different POS payment interfaces.

=USAGE

    # Define your interface in pos_interface system preference.
    # E.g. "Test"

    if ($transaction) {
        # Creates a Koha::Payment::POS::Test object
        $payment = Koha::Payment::POS->new({ branch => "CPL" });
        $payment->send_payment($transaction);
    }

=DESCRIPTION

Koha::Payment::POS is a class holds an interface definition for different
types of POS interfaces. By calling Koha::Payment::POS->new, this class will
attempt to instantiate a Koha::Payment::POS::*interface*
object according to the value set in 'POSIntegration'-system preference at
POSInterface-parameter. The instantiated object can then be used to send
payments to pos with the custom implementation of *interface*.

This class holds an implemented subroutine to check whether POS has been enabled
in 'POSIntegration' system preference. You can of course override the subroutine
implemented in this class and add your own implementation into your own
Koha::Payment::POS::*interface*.

Use POSIntegration value Test and this class will attempt to create
a Koha::Payment::POS::Test object. Test class is required to implement the
subroutines defined in this class. See _validate_interface_implementation() for
the required subroutines.

=cut

sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';

    my $branch = $self->{branch};
    $branch = C4::Context::mybranch() if not $branch;
    my $interface = $class->is_pos_integration_enabled($branch);

    Koha::Exception::NoSystemPreference->throw(error => "Koha::Payment::POS->new():>"
        . "POS integration is disabled in POSIntegration system preference.", syspref => "POSIntegration" )
    if not $interface;

    $class = $class."::$interface";
    bless $self, $class;

    Module::Load::load($class);

    Koha::Exception::UnknownObject->throw(error => "Koha::Payment::POS->new():>"
        . "POS integration interface not found.") if not $self->isa("$class");

    Koha::Exception::BadParameter->throw(error => "Koha::Payment::POS->new():>"
        . "POS integration interface not properly implemented.")
    if not $self->_validate_interface_implementation();

    return $self;
};

sub _validate_interface_implementation {
    my ($class) = @_;

    return  $class->can("complete_payment") &&
            $class->can("get_transaction_id") &&
            $class->can("is_valid_hash") &&
            $class->can("prepare_payment") &&
            $class->can("send_payment");
}

=head1 FUNCTIONS

=cut

=head2 is_pos_integration_enabled

  &is_pos_integration_enabled( $branch );

Checks if the POS integration feature is enabled in C<$branch>.
Override by implementing this subroutine in your own interface.

Returns itemnumber configuration if POS integration is enabled
in C<$branch>.

=cut

sub is_pos_integration_enabled {
    my ($class, $branch) = @_;

    $branch = C4::Context::mybranch() if not $branch;
    my $pref = C4::Context->preference("POSIntegration");

    if ($pref) {
        my $conf = eval {
            my $config = YAML::XS::Load(
                                Encode::encode(
                                    'UTF-8',
                                    $pref,
                                    Encode::FB_CROAK
                                ));
            return if $config->{$branch}->{'POSInterface'} and $config->{$branch}->{'POSInterface'} eq "disabled";
            return $config->{$branch}->{'POSInterface'} if $config->{$branch}->{'POSInterface'};
            return $config->{'Default'}->{'POSInterface'} if $config->{'Default'}->{'POSInterface'};
        };
        return $conf;
    }
};

=head2 complete_payment

  &complete_payment();

Completes the payment. Use of Koha::PaymentsTransaction->CompletePayment()
recommended.

IMPLEMENTATION REQUIRED!

=cut

sub complete_payment {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

=head2 get_interface

  &get_interface();

Returns name of the loaded interface.

=cut

sub get_interface {
    my ($class) = @_;
    my $classname = ref($class);
    $classname =~ s/^Koha::Payment::POS:://g;
    return $classname;
}

=head2 get_prepared_products

  &get_prepared_products();

Uses an ARRAY of products (format defined in
Koha::PaymentsTransactions->GetProducts()) and prepares them
into the format accepted by your POS provider.

Also converts Koha account types (from accountlines) into product
codes accepted by your provider.

Returns an ARRAY of products which is in acceptable format for your
provider.

Optional implementation.

=cut

sub get_prepared_products {};

=head2 get_transaction_id

  &get_transaction_id($query);

Returns the transaction id (payment id) from C<$query>.

Returns transaction id if it is found in C<$query>.

IMPLEMENTATION REQUIRED!

=cut

sub get_transaction_id {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

=head2 is_valid_hash

  &is_valid_hash($query);

Checks the C<$query> to determine whether given
parameter values are not tampered with.

Return true if the parameters are valid.

IMPLEMENTATION REQUIRED!

=cut

sub is_valid_hash {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

=head2 prepare_payment

  &prepare_payment($payment, $query);

Converts C<$payment> HASH from paycollect.pl into a format
accepted by your POS provider (HASH). In other words, this
subroutine must return perfectly defined HASH that will
be sent to your provider!

Pass the CGI-object C<$query> if you want to use custom input
values.

Returns a HASH that will be sent to your POS provider.

IMPLEMENTATION REQUIRED!

=cut

sub prepare_payment {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

=head2 send_payment

  &send_payment($transaction);

Sends the payment using custom interface's implementation.

IMPLEMENTATION REQUIRED!

=cut

sub send_payment {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

1;
