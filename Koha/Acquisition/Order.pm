package Koha::Acquisition::Order;

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

use Carp qw( croak );

use C4::Biblio qw( DelBiblio );
use C4::Acquisition;

use Koha::Acquisition::Baskets;
use Koha::Acquisition::Funds;
use Koha::Acquisition::Invoices;
use Koha::Acquisition::Order::Claims;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions::Object;
use Koha::Biblios;
use Koha::Holds;
use Koha::Items;
use Koha::Number::Price;
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
        next if $key eq 'biblionumber' && ($self->orderstatus // q{}) eq 'cancelled'; # cancelled order might have biblionumber NULL
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

=head3 cancel

    $order->cancel(
        {
            [
                reason        => $reason,
                delete_biblio => $delete_biblio
            ]
        }
    );

This method marks an order as cancelled, optionally using the I<reason> parameter.
As the order is cancelled, the (eventual) items linked to it are removed.
If I<delete_biblio> is passed, it will try to remove the linked biblio.

If either the items or biblio removal fails, an error message is added to the object
so the caller can take appropriate actions.

=cut

sub cancel {
    my ($self, $params) = @_;

    my $delete_biblio = $params->{delete_biblio};
    my $reason        = $params->{reason};

    # Delete the related items
    my $items = $self->items;
    while ( my $item = $items->next ) {
        my $deleted = $item->safe_delete;
        unless ( $deleted ) {
            $self->add_message(
                {
                    message => 'error_delitem',
                    payload => { item => $item, reason => @{$deleted->messages}[0]->message }
                }
            );
        }
    }

    my $biblio = $self->biblio;
    if ( $biblio and $delete_biblio ) {

        if (
            $biblio->active_orders->search(
                { ordernumber => { '!=' => $self->ordernumber } }
            )->count == 0
            and $biblio->subscriptions->count == 0
            and $biblio->items->count == 0
            )
        {

            my $error = DelBiblio( $biblio->id );
            $self->add_message(
                {
                    message => 'error_delbiblio',
                    payload => { biblio => $biblio, reason => $error }
                }
            ) if $error;
            $self->biblionumber(undef) unless $error; # constraint cleared biblionumber in db already
        }
        else {

            my $message;

            if ( $biblio->active_orders->search(
                { ordernumber => { '!=' => $self->ordernumber } }
            )->count > 0 ) {
                $message = 'error_delbiblio_active_orders';
            }
            elsif ( $biblio->subscriptions->count > 0 ) {
                $message = 'error_delbiblio_subscriptions';
            }
            else { # $biblio->items->count > 0
                $message = 'error_delbiblio_items';
            }

            $self->add_message(
                {
                    message => $message,
                    payload => { biblio => $biblio }
                }
            );
        }
    }

    # Update order status
    $self->set(
        {
            cancellationreason      => $reason,
            datecancellationprinted => \'NOW()',
            orderstatus             => 'cancelled',
        }
    )->store;

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

    my $basket = $order->basket;

Returns the I<Koha::Acquisition::Basket> object for the basket associated
to the order.

=cut

sub basket {
    my ( $self )  = @_;
    my $basket_rs = $self->_result->basket;
    return Koha::Acquisition::Basket->_new_from_dbic( $basket_rs );
}

=head3 fund

    my $fund = $order->fund;

Returns the I<Koha::Acquisition::Fund> object for the fund (aqbudgets)
associated to the order.

=cut

sub fund {
    my ( $self )  = @_;
    my $fund_rs = $self->_result->fund;
    return Koha::Acquisition::Fund->_new_from_dbic( $fund_rs );
}

=head3 invoice

    my $invoice = $order->invoice;

Returns the I<Koha::Acquisition::Invoice> object for the invoice associated
to the order.

It returns B<undef> if no linked invoice is found.

=cut

sub invoice {
    my ( $self )  = @_;
    my $invoice_rs = $self->_result->invoice;
    return unless $invoice_rs;
    return Koha::Acquisition::Invoice->_new_from_dbic( $invoice_rs );
}

=head3 subscription

    my $subscription = $order->subscription

Returns the I<Koha::Subscription> object for the subscription associated
to the order.

It returns B<undef> if no linked subscription is found.

=cut

sub subscription {
    my ( $self )  = @_;
    my $subscription_rs = $self->_result->subscription;
    return unless $subscription_rs;
    return Koha::Subscription->_new_from_dbic( $subscription_rs );
}

=head3 current_item_level_holds

    my $holds = $order->current_item_level_holds;

Returns the current item-level holds associated to the order. It returns a I<Koha::Holds>
resultset.

=cut

sub current_item_level_holds {
    my ($self) = @_;

    my $items_rs     = $self->_result->aqorders_items;
    my @item_numbers = $items_rs->get_column('itemnumber')->all;
    my $biblio       = $self->biblio;

    unless ( $biblio and @item_numbers ) {
        return Koha::Holds->new->empty;
    }

    return $biblio->current_holds->search(
        {
            itemnumber => {
                -in => \@item_numbers
            }
        }
    );
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
    my $biblio_rs= $self->_result->biblio;
    return unless $biblio_rs;
    return Koha::Biblio->_new_from_dbic( $biblio_rs );
}

=head3 claims

    my $claims = $order->claims

Return the claims history for this order

=cut

sub claims {
    my ( $self ) = @_;
    my $claims_rs = $self->_result->aqorders_claims;
    return Koha::Acquisition::Order::Claims->_new_from_dbic( $claims_rs );
}

=head3 claim

    my $claim = $order->claim

Do claim for this order

=cut

sub claim {
    my ( $self ) = @_;
    my $claim_rs = $self->_result->create_related('aqorders_claims', {});
    return Koha::Acquisition::Order::Claim->_new_from_dbic($claim_rs);
}

=head3 claims_count

my $nb_of_claims = $order->claims_count;

This is the equivalent of $order->claims->count. Keeping it for retrocompatibilty.

=cut

sub claims_count {
    my ( $self ) = @_;
    return $self->claims->count;
}

=head3 claimed_date

my $last_claim_date = $order->claimed_date;

This is the equivalent of $order->claims->last->claimed_on. Keeping it for retrocompatibilty.

=cut

sub claimed_date {
    my ( $self ) = @_;
    my $last_claim = $self->claims->last;
    return unless $last_claim;
    return $last_claim->claimed_on;
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
                invoiceid
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

=head3 populate_with_prices_for_ordering

Sets calculated values for an order - all values are stored with full precision
regardless of rounding preference except for tax value which is calculated on
rounded values if requested

    $order->populate_with_prices_for_ordering()

The values set are:
    rrp_tax_included
    rrp_tax_excluded
    ecost_tax_included
    ecost_tax_excluded
    tax_value_on_ordering

=cut

sub populate_with_prices_for_ordering {
    my ($self) = @_;

    my $bookseller = $self->basket->bookseller;
    return unless $bookseller;

    my $discount = $self->discount || 0;
    $discount /= 100 if $discount > 1;

    if ( $bookseller->listincgst ) {
        # The user entered the prices tax included
        $self->unitprice($self->unitprice + 0);
        $self->unitprice_tax_included($self->unitprice);
        $self->rrp_tax_included($self->rrp);

        # price tax excluded = price tax included / ( 1 + tax rate )
        $self->unitprice_tax_excluded( $self->unitprice_tax_included / ( 1 + $self->tax_rate_on_ordering ) );
        $self->rrp_tax_excluded( $self->rrp_tax_included / ( 1 + $self->tax_rate_on_ordering ) );

        # ecost tax included = rrp tax included  ( 1 - discount )
        $self->ecost_tax_included($self->rrp_tax_included * ( 1 - $discount ));

        # ecost tax excluded = rrp tax excluded * ( 1 - discount )
        $self->ecost_tax_excluded($self->rrp_tax_excluded * ( 1 - $discount ));

        # tax value = quantity * ecost tax excluded * tax rate
        # we should use the unitprice if included
        my $cost_tax_included = $self->unitprice_tax_included == 0 ? $self->ecost_tax_included : $self->unitprice_tax_included;
        my $cost_tax_excluded = $self->unitprice_tax_excluded == 0 ? $self->ecost_tax_excluded : $self->unitprice_tax_excluded;
        $self->tax_value_on_ordering( ( C4::Acquisition::get_rounded_price($cost_tax_included) - C4::Acquisition::get_rounded_price($cost_tax_excluded) ) * $self->quantity );
    } else {
        # The user entered the prices tax excluded
        $self->unitprice_tax_excluded($self->unitprice);
        $self->rrp_tax_excluded($self->rrp);

        # price tax included = price tax excluded * ( 1 - tax rate )
        $self->unitprice_tax_included($self->unitprice_tax_excluded * ( 1 + $self->tax_rate_on_ordering ));
        $self->rrp_tax_included($self->rrp_tax_excluded * ( 1 + $self->tax_rate_on_ordering ));

        # ecost tax excluded = rrp tax excluded * ( 1 - discount )
        $self->ecost_tax_excluded($self->rrp_tax_excluded * ( 1 - $discount ));

        # ecost tax included = rrp tax excluded * ( 1 + tax rate ) * ( 1 - discount ) = ecost tax excluded * ( 1 + tax rate )
        $self->ecost_tax_included($self->ecost_tax_excluded * ( 1 + $self->tax_rate_on_ordering ));

        # tax value = quantity * ecost tax included * tax rate
        # we should use the unitprice if included
        my $cost_tax_excluded = $self->unitprice_tax_excluded == 0 ? $self->ecost_tax_excluded : $self->unitprice_tax_excluded;
        $self->tax_value_on_ordering($self->quantity * C4::Acquisition::get_rounded_price($cost_tax_excluded) * $self->tax_rate_on_ordering);
    }
}

=head3 populate_with_prices_for_receiving

Sets calculated values for an order - all values are stored with full precision
regardless of rounding preference except for tax value which is calculated on
rounded values if requested

    $order->populate_with_prices_for_receiving()

The values set are:
    unitprice_tax_included
    unitprice_tax_excluded
    tax_value_on_receiving

Note: When receiving, if the rounded value of the unitprice matches the rounded
value of the ecost then then ecost (full precision) is used.

=cut

sub populate_with_prices_for_receiving {
    my ($self) = @_;

    my $bookseller = $self->basket->bookseller;
    return unless $bookseller;

    my $discount = $self->discount || 0;
    $discount /= 100 if $discount > 1;

    if ($bookseller->invoiceincgst) {
        # Trick for unitprice. If the unit price rounded value is the same as the ecost rounded value
        # we need to keep the exact ecost value
        if ( Koha::Number::Price->new( $self->unitprice )->round == Koha::Number::Price->new( $self->ecost_tax_included )->round ) {
            $self->unitprice($self->ecost_tax_included);
        }

        # The user entered the unit price tax included
        $self->unitprice_tax_included($self->unitprice);

        # unit price tax excluded = unit price tax included / ( 1 + tax rate )
        $self->unitprice_tax_excluded($self->unitprice_tax_included / ( 1 + $self->tax_rate_on_receiving ));
    } else {
        # Trick for unitprice. If the unit price rounded value is the same as the ecost rounded value
        # we need to keep the exact ecost value
        if ( Koha::Number::Price->new($self->unitprice)->round == Koha::Number::Price->new($self->ecost_tax_excluded)->round ) {
            $self->unitprice($self->ecost_tax_excluded);
        }

        # The user entered the unit price tax excluded
        $self->unitprice_tax_excluded($self->unitprice);


        # unit price tax included = unit price tax included * ( 1 + tax rate )
        $self->unitprice_tax_included($self->unitprice_tax_excluded * ( 1 + $self->tax_rate_on_receiving ));
    }

    # tax value = quantity * unit price tax excluded * tax rate
    $self->tax_value_on_receiving($self->quantity * C4::Acquisition::get_rounded_price($self->unitprice_tax_excluded) * $self->tax_rate_on_receiving);
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Acquisition::Order object
on the API.

=cut

sub to_api_mapping {
    return {
        basketno                      => 'basket_id',
        biblionumber                  => 'biblio_id',
        budget_id                     => 'fund_id',
        budgetdate                    => undef,                    # unused
        cancellationreason            => 'cancellation_reason',
        claimed_date                  => 'last_claim_date',
        datecancellationprinted       => 'cancellation_date',
        datereceived                  => 'date_received',
        discount                      => 'discount_rate',
        entrydate                     => 'entry_date',
        freight                       => 'shipping_cost',
        invoiceid                     => 'invoice_id',
        line_item_id                  => undef,                    # EDIFACT related
        listprice                     => 'list_price',
        order_internalnote            => 'internal_note',
        order_vendornote              => 'vendor_note',
        ordernumber                   => 'order_id',
        orderstatus                   => 'status',
        parent_ordernumber            => 'parent_order_id',
        purchaseordernumber           => undef,                    # obsolete
        quantityreceived              => 'quantity_received',
        replacementprice              => 'replacement_price',
        sort1                         => 'statistics_1',
        sort1_authcat                 => 'statistics_1_authcat',
        sort2                         => 'statistics_2',
        sort2_authcat                 => 'statistics_2_authcat',
        subscriptionid                => 'subscription_id',
        suppliers_reference_number    => undef,                    # EDIFACT related
        suppliers_reference_qualifier => undef,                    # EDIFACT related
        suppliers_report              => undef,                    # EDIFACT related
        tax_rate_bak                  => undef,                    # unused
        tax_value_bak                 => undef,                    # unused
        uncertainprice                => 'uncertain_price',
        unitprice                     => 'unit_price',
        unitprice_tax_excluded        => 'unit_price_tax_excluded',
        unitprice_tax_included        => 'unit_price_tax_included',
        invoice_unitprice             => 'invoice_unit_price',
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqorder';
}

1;
