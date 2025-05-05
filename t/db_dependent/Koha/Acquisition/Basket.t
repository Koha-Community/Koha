#!/usr/bin/perl

# Copyright 2018 Koha Development team
#
# This file is part of Koha
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

use Test::NoWarnings;
use Test::More tests => 15;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Acquisition qw( NewBasket ModBasket ModBasketHeader );
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

use_ok('Koha::Acquisition::Basket');
use_ok('Koha::Acquisition::Baskets');

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'create_items + effective_create_items tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { create_items => undef }
        }
    );
    my $created_basketno = C4::Acquisition::NewBasket(
        $basket->booksellerid,   $basket->authorisedby,
        $basket->basketname,     $basket->note,
        $basket->booksellernote, $basket->contractnumber,
        $basket->deliveryplace,  $basket->billingplace,
        $basket->is_standing,    $basket->create_items
    );
    my $created_basket = Koha::Acquisition::Baskets->find($created_basketno);
    is(
        $created_basket->basketno, $created_basketno,
        "Basket created by NewBasket matches db basket"
    );
    is( $basket->create_items, undef, "Create items value can be null" );

    t::lib::Mocks::mock_preference( 'AcqCreateItem', 'cataloguing' );
    is(
        $basket->effective_create_items,
        "cataloguing",
        "We use AcqCreateItem if basket create items is not set"
    );
    C4::Acquisition::ModBasketHeader(
        $basket->basketno,       $basket->basketname,
        $basket->note,           $basket->booksellernote,
        $basket->contractnumber, $basket->booksellerid,
        $basket->deliveryplace,  $basket->billingplace,
        $basket->is_standing,    "ordering"
    );
    my $retrieved_basket = Koha::Acquisition::Baskets->find( $basket->basketno );
    $basket->create_items("ordering");
    is( $retrieved_basket->create_items, "ordering", "Should be able to set with ModBasketHeader" );
    is( $basket->create_items,           "ordering", "Should be able to set with object methods" );
    is_deeply(
        $retrieved_basket->unblessed,
        $basket->unblessed, "Correct basket found and updated"
    );
    is(
        $retrieved_basket->effective_create_items,
        "ordering", "We use basket create items if it is set"
    );

    $schema->storage->txn_rollback;
};

subtest 'basket_group' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    my $b = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { basketgroupid => undef },     # not linked to a basketgroupid
        }
    );

    my $basket = Koha::Acquisition::Baskets->find( $b->basketno );
    is(
        $basket->basket_group, undef,
        '->basket_group should return undef if not linked to a basket group'
    );

    $b = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',

            # Will be linked to a basket group by TestBuilder
        }
    );

    $basket = Koha::Acquisition::Baskets->find( $b->basketno );
    is(
        ref( $basket->basket_group ), 'Koha::Acquisition::BasketGroup',
        '->basket_group should return a Koha::Acquisition::BasketGroup object if linked to a basket group'
    );

    $schema->storage->txn_rollback;
};

subtest 'creator() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { authorisedby => undef }
        }
    );

    is( $basket->creator, undef, 'Undef is handled as expected' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $basket->authorisedby( $patron->borrowernumber )->store->discard_changes;

    my $creator = $basket->creator;
    is( ref($creator),            'Koha::Patron',          'Return type is correct' );
    is( $creator->borrowernumber, $patron->borrowernumber, 'Returned object is the right one' );

    # Delete the patron
    $patron->delete;

    is( $basket->creator, undef, 'Undef is handled as expected' );

    $schema->storage->txn_rollback;
};

subtest 'to_api() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { closedate => undef }
        }
    );

    my $closed = $basket->to_api->{closed};
    ok( defined $closed, 'closed is defined' );
    ok( !$closed,        'closedate is undef, closed evaluates to false' );

    $basket->closedate(dt_from_string)->store->discard_changes;
    $closed = $basket->to_api->{closed};
    ok( defined $closed, 'closed is defined' );
    ok( $closed,         'closedate is defined, closed evaluates to true' );

    $basket->booksellerid( $vendor->id )->store->discard_changes;
    my $basket_json = $basket->to_api( { embed => { bookseller => {} } } );
    ok( exists $basket_json->{bookseller} );
    is_deeply( $basket_json->{bookseller}, $vendor->to_api );

    $schema->storage->txn_rollback;
};

subtest 'estimated_delivery_date' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;
    my $bookseller = $builder->build_object(
        {
            class => 'Koha::Acquisition::Booksellers',
            value => {
                deliverytime => undef,    # Does not have a delivery time defined
            }
        }
    );

    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => undef,             # Still open
            }
        }
    );

    my $now = dt_from_string;
    is(
        $basket->estimated_delivery_date,
        undef, 'return undef if closedate and deliverytime are not defined'
    );

    $basket->closedate( $now->clone->subtract( days => 1 ) )->store;    #Closing the basket
    is(
        $basket->estimated_delivery_date,
        undef, 'return undef if deliverytime is not defined'
    );

    $basket->closedate(undef)->store;                                   #Reopening
    $bookseller->deliverytime(2)->store;                                # 2 delivery days
    is(
        $basket->estimated_delivery_date,
        undef, 'return undef if closedate is not defined (basket still open)'
    );

    $bookseller->deliverytime(2)->store;                                # 2 delivery days
    $basket->closedate( $now->clone->subtract( days => 1 ) )->store;    #Closing the basket
    is(
        $basket->get_from_storage->estimated_delivery_date,
        $now->clone->add( days => 1 )->truncate( to => 'day' ),
        'Estimated delivery date should be tomorrow if basket closed on yesterday and delivery takes 2 days'
    );

    $schema->storage->txn_rollback;
};

subtest 'late_since_days' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
        }
    );

    my $now = dt_from_string;
    $basket->closedate(undef)->store;    # Basket is open
    is( $basket->late_since_days, undef, 'return undef if basket is still open' );

    $basket->closedate($now)->store;     #Closing the basket today
    is( $basket->late_since_days, 0, 'return 0 if basket has been closed on today' );

    $basket->closedate( $now->clone->subtract( days => 2 ) )->store;
    is( $basket->late_since_days, 2, 'return 2 if basket has been closed 2 days ago' );

    $schema->storage->txn_rollback;
};

subtest 'authorizer' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { authorisedby => undef },
        }
    );

    my $basket_creator = $builder->build_object( { class => 'Koha::Patrons' } );

    is(
        $basket->authorizer, undef,
        'authorisedby is null, ->authorized should return undef'
    );

    $basket->authorisedby( $basket_creator->borrowernumber )->store;

    is(
        ref( $basket->authorizer ),
        'Koha::Patron', '->authorized should return a Koha::Patron object'
    );
    is(
        $basket->authorizer->borrowernumber,
        $basket_creator->borrowernumber,
        '->authorized should return the correct creator'
    );

    $schema->storage->txn_rollback;
};

subtest 'orders' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object( { class => 'Koha::Acquisition::Baskets' } );

    my $orders = $basket->orders;
    is( ref($orders),   'Koha::Acquisition::Orders', 'Type is correct with no attached orders' );
    is( $orders->count, 0,                           'No orders attached, count 0' );

    my @actual_orders;

    for ( 1 .. 3 ) {
        push @actual_orders,
            $builder->build_object( { class => 'Koha::Acquisition::Orders', value => { basketno => $basket->id } } );
    }

    $orders = $basket->orders;
    is( ref($orders),   'Koha::Acquisition::Orders', 'Type is correct with no attached orders' );
    is( $orders->count, 3,                           '3 orders attached, count 3' );

    $schema->storage->txn_rollback;
};

subtest 'edi_order' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object( { class => 'Koha::Acquisition::Baskets' } );

    is(
        $basket->edi_order, undef,
        'edi_order returns undefined if there are no edi_messages of type "ORDER" attached'
    );

    my $order_message_1 = $builder->build(
        {
            source => 'EdifactMessage',
            value  => {
                basketno      => $basket->basketno,
                message_type  => 'ORDERS',
                transfer_date => '2019-07-30',
                deleted       => 0,
            }
        }
    );

    my $edi_message = $basket->edi_order;
    is(
        ref($edi_message), 'Koha::Schema::Result::EdifactMessage',
        'edi_order returns an EdifactMessage if one is attached'
    );

    my $order_message_2 = $builder->build(
        {
            source => 'EdifactMessage',
            value  => {
                basketno     => $basket->basketno,
                message_type => 'ORDERS',
                deleted      => 0
            }
        }
    );

    $edi_message = $basket->edi_order;
    is(
        $edi_message->id, $order_message_2->{id},
        'edi_order returns the most recently associated ORDERS EdifactMessage'
    );

    $schema->storage->txn_rollback;
};

subtest 'is_closed() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $open_basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { closedate => undef }
        }
    );

    my $closed_basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { closedate => \'NOW()' }
        }
    );

    ok( $closed_basket->is_closed, 'Closed basket is tested as closed' );
    ok( !$open_basket->is_closed,  'Open basket is tested as open' );

    $schema->storage->txn_rollback;
};

subtest 'close() tests' => sub {

    plan tests => 4;

    # Turn on acquisitions logging and ensure the logs are empty
    t::lib::Mocks::mock_preference( 'AcquisitionLog', 1 );
    Koha::ActionLogs->delete;

    $schema->storage->txn_begin;

    # Create an open basket
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { closedate => undef }
        }
    );

    for my $status (qw( new ordered partial complete cancelled )) {
        $builder->build_object(
            {
                class => 'Koha::Acquisition::Orders',
                value => {
                    basketno    => $basket->id,
                    orderstatus => $status
                }
            }
        );
    }

    $basket->close;

    ok( $basket->is_closed, 'Basket is closed' );
    my $ordered_orders = $basket->orders->search( { orderstatus => 'ordered' } );
    is( $ordered_orders->count, 3, 'Only open orders have been marked as ordered' );

    throws_ok { $basket->close; }
    'Koha::Exceptions::Acquisition::Basket::AlreadyClosed',
        'Trying to close an already closed basket throws an exception';

    my @close_logs =
        Koha::ActionLogs->search( { module => 'ACQUISITIONS', action => 'CLOSE_BASKET', object => $basket->id } )
        ->as_list;
    is( scalar @close_logs, 1, 'Basket closure is logged' );

    $schema->storage->txn_rollback;
};

subtest 'vendor() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object( { class => 'Koha::Acquisition::Baskets' } );
    my $vendor = $basket->vendor;
    is( ref($vendor), 'Koha::Acquisition::Bookseller', 'Right object type' );
    my $other_vendor = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );

    # change the vendor
    $basket->set( { booksellerid => $other_vendor->id } )->store()->discard_changes();

    is( $basket->vendor->id, $other_vendor->id, 'Method returns the new vendor' );

    $schema->storage->txn_rollback;
};
