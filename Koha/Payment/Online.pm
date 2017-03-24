package Koha::Payment::Online;

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

=NAME Koha::Payment::Online

=SYNOPSIS

This is an interface definition for Koha::Payment::Online::* -subclasses.
This documentation explains how to subclass different online payment interfaces.

Feature works per branch. This allows online payments to be enabled or disabled
per branch, or also use different interfaces in different branches.
The branch is Patron's home branch.

=USAGE

    # Define your interface in OnlinePayments system preference.
    # E.g. system preference: OnlinePayments
    #
    # CPL:
    #   OnlinePaymentsInterface: Test

    if ($transaction) {
        # Creates a Koha::Payment::Online::Test object
        $payment = Koha::Payment::Online->new({ branch => "CPL" });
        $payment->send_payment($transaction);
    }

=DESCRIPTION

Koha::Payment::Online is a class holds an interface definition for different
types of online payment interfaces. By calling Koha::Payment::Online->new,
this class will attempt to instantiate a Koha::Payment::Online::*interface*
object according to the value set in 'OnlinePayments'-system preference under
branch in OnlinePaymentsInterface parameter. The instantiated object can then
be used to send online payments with the custom implementation of *interface*.

This class holds an implemented subroutine to check whether online payments
has been enabled in 'OnlinePayments' system preference. You can of course
override the subroutine implemented in this class and add your own implementation
into your own Koha::Payment::Online::interface.

Use the value Test in OnlinePayments preference at OnlinePaymentsInterface parameter
and this class will attempt to create a Koha::Payment::Online::Test object.
Test class is required to implement the subroutines defined in this class.
See _validate_interface_implementation() for the required subroutines.

=cut

sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';

    my $branch = $self->{branch};
    $branch = C4::Context::mybranch() if not $branch;
    my $interface = $class->is_online_payment_enabled($branch);

    Koha::Exception::NoSystemPreference->throw(error => "Koha::Payment::Online->new():>"
        . "Online payment is disabled in OnlinePayments system preference.",
        syspref => "OnlinePayments")
    if not $interface;

    $class = $class."::$interface";
    bless $self, $class;

    Module::Load::load($class);

    Koha::Exception::UnknownObject->throw(error => "Koha::Payment::Online->new():>"
        . "Online payment interface not found.") if not $self->isa("$class");

    Koha::Exception::BadParameter->throw(error => "Koha::Payment::Online->new():>"
        . "Online payment interface not properly implemented.")
    if not $self->_validate_interface_implementation();

    return $self;
};

sub _validate_interface_implementation {
    my ($class) = @_;

    # Required subroutines
    return  $class->can("complete_payment") &&
            $class->can("get_transaction_id") &&
            $class->can("is_return_address") &&
            $class->can("is_valid_hash") &&
            $class->can("send_payment") &&
            $class->can("set_payment_status_in_return_address");
}

=head1 FUNCTIONS

=cut

=head2 is_online_payment_enabled

  &is_online_payment_enabled( $branch );

Checks if the online payment feature is enabled in $branch.
Override by implementing this subroutine in your own interface.

Returns the interface name if online payment is enabled in
C<$branch>.

=cut

sub is_online_payment_enabled {
    my ($class, $branch) = @_;

    $branch = C4::Context::mybranch() if not $branch;
    my $pref = C4::Context->preference("OnlinePayments");

    if ($pref) {
        my $conf = eval {
            my $config = YAML::XS::Load(
                                Encode::encode(
                                    'UTF-8',
                                    $pref,
                                    Encode::FB_CROAK
                                ));
            return if $config->{$branch}->{'OnlinePaymentsInterface'} and $config->{$branch}->{'OnlinePaymentsInterface'} eq "disabled";
            return $config->{$branch}->{'OnlinePaymentsInterface'} if $config->{$branch}->{'OnlinePaymentsInterface'};
            return $config->{'Default'}->{'OnlinePaymentsInterface'} if $config->{'Default'}->{'OnlinePaymentsInterface'};
        };
        return $conf;
    }
};

=head2 complete_payment

  &complete_payment();

Completes the payment.

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
    $classname =~ s/^Koha::Payment::Online:://g;
    return $classname;
}

=head2 get_prepared_products

  &get_prepared_products();

Uses an ARRAY of products (format defined in
Koha::PaymentsTransactions->GetProducts()) and prepares them
into the format accepted by your online payments provider.

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

=head2 is_return_address

  &is_return_address($query);

Checks the C<$query> to determine whether Patron has
returned into the return address from online store.

Return true if yes.

IMPLEMENTATION REQUIRED!

=cut

sub is_return_address {
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

=head2 send_payment

  &send_payment($transaction);

Sends the payment using custom interface's implementation.

IMPLEMENTATION REQUIRED!

=cut

sub send_payment {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

=head2 set_payment_status_in_return_address

  &set_payment_status_in_return_address($query);

Sets the payment status accordingly by query parameters after
returning back to Koha from the online store.

Return HASH of response parameters.

IMPLEMENTATION REQUIRED!

=cut

sub set_payment_status_in_return_address {
    Koha::Exception::NotImplemented->throw(error => (caller(0))[3]."> Subroutine must be implemented in your custom interface.")
};

1;
