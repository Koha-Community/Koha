package Koha::Acquisition::Order;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp qw( croak );

use Koha::Acquisition::Baskets;
use Koha::Acquisition::Funds;
use Koha::Acquisition::Invoices;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Items;
use Koha::Subscriptions;

use base qw(Koha::Object);

=head1 NAME

Koha::Acquisition::Order Object class

=head1 API

=head2 Class methods

=head3 new

Overloaded I<new> method for backwards compatibility.

=cut

sub new {
    my ( $self, $params ) = @_;

    my $schema  = Koha::Database->new->schema;
    my @columns = $schema->source('Aqorder')->columns;

    my $values =
      { map { exists $params->{$_} ? ( $_ => $params->{$_} ) : () } @columns };
    return $self->SUPER::new($values);
}

=head3 store

Overloaded I<store> method for backwards compatibility.

=cut

sub store {
    my ($self) = @_;

    my $schema  = Koha::Database->new->schema;
    # Override quantity for standing orders
    $self->quantity(1) if ( $self->basketno && $schema->resultset('Aqbasket')->find( $self->basketno )->is_standing );

    # if these parameters are missing, we can't continue
    for my $key (qw( basketno quantity biblionumber budget_id )) {
        croak "Cannot insert order: Mandatory parameter $key is missing"
          unless $self->$key;
    }

    if (not defined $self->{created_by}) {
        my $userenv = C4::Context->userenv;
        if ($userenv) {
            $self->created_by($userenv->{number});
        }
    }

    $self->quantityreceived(0) unless $self->quantityreceived;
    $self->entrydate(dt_from_string) unless $self->entrydate;

    $self->ordernumber(undef) unless $self->ordernumber;
    $self = $self->SUPER::store( $self );

    unless ( $self->parent_ordernumber ) {
        $self->set( { parent_ordernumber => $self->ordernumber } );
        $self = $self->SUPER::store( $self );
    }

    return $self;
}

=head3 add_item

  $order->add_item( $itemnumber );

Link an item to this order.

=cut

sub add_item {
    my ( $self, $itemnumber )  = @_;

    my $schema = Koha::Database->new->schema;
    my $rs = $schema->resultset('AqordersItem');
    $rs->create({ ordernumber => $self->ordernumber, itemnumber => $itemnumber });
}

=head3 basket

    my $basket = Koha::Acquisition::Orders->find( $id )->basket;

Returns the basket associated to the order.

=cut

sub basket {
    my ( $self )  = @_;
    my $basket_rs = $self->_result->basketno;
    return Koha::Acquisition::Basket->_new_from_dbic( $basket_rs );
}

=head3 fund

    my $fund = $order->fund

Returns the fund (aqbudgets) associated to the order.

=cut

sub fund {
    my ( $self )  = @_;
    my $fund_rs = $self->_result->budget;
    return Koha::Acquisition::Fund->_new_from_dbic( $fund_rs );
}

=head3 invoice

    my $invoice = $order->invoice

Returns the invoice associated to the order.

=cut

sub invoice {
    my ( $self )  = @_;
    my $invoice_rs = $self->_result->invoiceid;
    return unless $invoice_rs;
    return Koha::Acquisition::Invoice->_new_from_dbic( $invoice_rs );
}

=head3 subscription

    my $subscription = $order->subscription

Returns the subscription associated to the order.

=cut

sub subscription {
    my ( $self )  = @_;
    my $subscription_rs = $self->_result->subscriptionid;
    return unless $subscription_rs;
    return Koha::Subscription->_new_from_dbic( $subscription_rs );
}

=head3 items

    my $items = $order->items

Returns the items associated to the order.

=cut

sub items {
    my ( $self )  = @_;
    # aqorders_items is not a join table
    # There is no FK on items (may have been deleted)
    my $items_rs = $self->_result->aqorders_items;
    my @itemnumbers = $items_rs->get_column( 'itemnumber' )->all;
    return Koha::Items->search({ itemnumber => \@itemnumbers });
}

=head3 biblio

    my $biblio = $order->biblio

Returns the bibliographic record associated to the order

=cut

sub biblio {
    my ( $self ) = @_;
    my $biblio_rs= $self->_result->biblionumber;
    return Koha::Biblio->_new_from_dbic( $biblio_rs );
}

=head3 duplicate_to

    my $duplicated_order = $order->duplicate_to($basket, [$default_values]);

Duplicate an existing order and attach it to a basket. $default_values can be specified as a hashref
that contain default values for the different order's attributes.
Items will be duplicated as well but barcodes will be set to null.

=cut

sub duplicate_to {
    my ( $self, $basket, $default_values ) = @_;
    my $new_order;
    $default_values //= {};
    Koha::Database->schema->txn_do(
        sub {
            my $order_info = $self->unblessed;
            undef $order_info->{ordernumber};
            for my $field (
                qw(
                ordernumber
                received_on
                datereceived
                datecancellationprinted
                cancellationreason
                purchaseordernumber
                claims_count
                claimed_date
                parent_ordernumber
                )
              )
            {
                undef $order_info->{$field};
            }
            $order_info->{placed_on}        = dt_from_string;
            $order_info->{entrydate}        = dt_from_string;
            $order_info->{orderstatus}      = 'new';
            $order_info->{quantityreceived} = 0;
            while ( my ( $field, $value ) = each %$default_values ) {
                $order_info->{$field} = $value;
            }

            my $userenv = C4::Context->userenv;
            $order_info->{created_by} = $userenv->{number};
            $order_info->{basketno} = $basket->basketno;

            $new_order = Koha::Acquisition::Order->new($order_info)->store;

            if ( ! $self->subscriptionid && $self->basket->effective_create_items eq 'ordering') { # Do copy items if not a subscription order AND if items are created on ordering
                my $items = $self->items;
                while ( my ($item) = $items->next ) {
                    my $item_info = $item->unblessed;
                    undef $item_info->{itemnumber};
                    undef $item_info->{barcode};
                    my $new_item = Koha::Item->new($item_info)->store;
                    $new_order->add_item( $new_item->itemnumber );
                }
            }
        }
    );
    return $new_order;
}


=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqorder';
}

1;
