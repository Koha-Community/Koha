package Koha::Acquisition::Basket;

# Copyright 2017 Aleisha Amohia <aleisha@catalyst.net.nz>
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::BasketGroups;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use Koha::Exceptions::Acquisition::Basket;
use Koha::Patrons;
use C4::Log qw( logaction );

use base qw( Koha::Object Koha::Object::Mixin::AdditionalFields );

=head1 NAME

Koha::Acquisition::Basket - Koha Basket Object class

=head1 API

=head2 Class methods

=cut

=head3 bookseller

Returns the vendor

=cut

sub bookseller {
    my ($self) = @_;
    my $bookseller_rs = $self->_result->booksellerid;
    return Koha::Acquisition::Bookseller->_new_from_dbic($bookseller_rs);
}

=head3 vendor

    my $vendor = $basket->vendor;

Returns the related I<Koha::Acquisition::Bookseller> object.

=cut

sub vendor {
    my ($self) = @_;
    my $vendor_rs = $self->_result->vendor;
    return Koha::Acquisition::Bookseller->_new_from_dbic($vendor_rs);
}

=head3 creator

    my $creator = $basket->creator;

Returns the I<Koha::Patron> for the basket creator.

=cut

sub creator {
    my ($self) = @_;
    my $borrowernumber = $self->authorisedby;    # FIXME missing FK here
    return unless $borrowernumber;
    return Koha::Patrons->find($borrowernumber);
}

=head3 basket_group

Returns the basket group associated to this basket

=cut

sub basket_group {
    my ($self) = @_;

    my $basket_group_rs = $self->_result->basket_group;
    return unless $basket_group_rs;
    return Koha::Acquisition::BasketGroup->_new_from_dbic($basket_group_rs);
}

=head3 orders

    my $orders = $basket->orders;

Returns a Koha::Acquisition::Orders resultset, with the orders linked
to this basket.

=cut

sub orders {
    my ($self) = @_;

    my $orders_rs = $self->_result->orders;
    return Koha::Acquisition::Orders->_new_from_dbic($orders_rs);
}

=head3 edi_order

  my $edi_order = $basket->edi_order;

Returns the most recently attached EDI order object if one exists for the basket.

NOTE: This currently returns a bare DBIx::Class result or undefined. This is consistent with the rest of EDI;
However it would be beneficial to convert these to full fledge Koha::Objects in the future.

=cut

sub edi_order {
    my ($self) = @_;

    my $order_rs = $self->_result->edifact_messages(
        {
            message_type => 'ORDERS',
            deleted      => 0
        },
        { order_by => { '-desc' => 'transfer_date' }, rows => 1 }
    );
    return $order_rs->single;
}

=head3 effective_create_items

Returns C<create_items> for this basket, falling back to C<AcqCreateItem> if unset.

=cut

sub effective_create_items {
    my ($self) = @_;

    return $self->create_items || C4::Context->preference('AcqCreateItem');
}

=head3 estimated_delivery_date

my $estimated_delivery_date = $basket->estimated_delivery_date;

Return the estimated delivery date for this basket.

It is calculated adding the delivery time of the vendor to the close date of this basket.

Return implicit undef if the basket is not closed, or the vendor does not have a delivery time.

=cut

sub estimated_delivery_date {
    my ($self) = @_;
    return unless $self->closedate and $self->bookseller->deliverytime;
    return dt_from_string( $self->closedate )->add( days => $self->bookseller->deliverytime );
}

=head3 late_since_days

my $number_of_days_late = $basket->late_since_days;

Return the number of days the basket is late.

Return implicit undef if the basket is not closed.

=cut

sub late_since_days {
    my ($self) = @_;
    return unless $self->closedate;
    return dt_from_string->delta_days( dt_from_string( $self->closedate ) )->delta_days();
}

=head3 authorizer

my $authorizer = $basket->authorizer;

Returns the patron who authorized/created this basket.

=cut

sub authorizer {
    my ($self) = @_;

    # FIXME We should use a DBIC rs, but the FK is missing
    return unless $self->authorisedby;
    return scalar Koha::Patrons->find( $self->authorisedby );
}

=head3 is_closed

    if ( $basket->is_closed ) { ... }

Returns a boolean value representing if the basket is closed.

=cut

sub is_closed {
    my ($self) = @_;

    return ( $self->closedate ) ? 1 : 0;
}

=head3 close

    $basket->close;

Close the basket and mark all open orders as ordered.

A I<Koha::Exceptions::Acquisition::Basket::AlreadyClosed> exception is thrown
if the basket is already closed.

=cut

sub close {
    my ($self) = @_;

    Koha::Exceptions::Acquisition::Basket::AlreadyClosed->throw
        if $self->is_closed;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $open_orders = $self->orders->search( { orderstatus => { not_in => [ 'complete', 'cancelled' ] } } );

            # Mark open orders as ordered
            $open_orders->update( { orderstatus => 'ordered' }, { no_triggers => 1 } );

            # set as closed
            $self->set( { closedate => \'NOW()' } )->store;
        }
    );

    # Log the closure
    if ( C4::Context->preference("AcquisitionLog") ) {
        logaction(
            'ACQUISITIONS',
            'CLOSE_BASKET',
            $self->id
        );
    }

    return $self;
}

=head3 to_api

    my $json = $basket->to_api;

Overloaded method that returns a JSON representation of the Koha::Acquisition::Basket object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json_basket = $self->SUPER::to_api($params);
    return unless $json_basket;

    $json_basket->{closed} =
        ( $self->closedate )
        ? Mojo::JSON->true
        : Mojo::JSON->false;

    return $json_basket;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Acquisition::Basket object
on the API.

=cut

sub to_api_mapping {
    return {
        basketno                => 'basket_id',
        basketname              => 'name',
        booksellernote          => 'vendor_note',
        contractnumber          => 'contract_id',
        creationdate            => 'creation_date',
        closedate               => 'close_date',
        booksellerid            => 'vendor_id',
        authorisedby            => 'creator_id',
        booksellerinvoicenumber => undef,
        basketgroupid           => 'basket_group_id',
        deliveryplace           => 'delivery_library_id',
        billingplace            => 'billing_library_id',
        branch                  => 'library_id',
        is_standing             => 'standing'
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqbasket';
}

=head1 AUTHOR

Aleisha Amohia <aleisha@catalyst.net.nz>
Catalyst IT

=cut

1;
