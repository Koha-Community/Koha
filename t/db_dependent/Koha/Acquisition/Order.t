#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Test::More tests => 12;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Circulation qw( AddIssue AddReturn );

use Koha::Biblios;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Items;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'basket() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets'
        }
    );
    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { basketno => $basket->basketno }
        }
    );

    my $retrieved_basket = $order->basket;
    is( ref($retrieved_basket), 'Koha::Acquisition::Basket',
        'Type is correct for ->basket' );
    is_deeply( $retrieved_basket->unblessed,
        $basket->unblessed, "Correct basket found and updated" );

    $schema->storage->txn_rollback;
};

subtest 'biblio() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { biblionumber => undef }
        }
    );

    is( $order->biblio, undef, 'If no linked biblio, undef is returned' );

    # Add and link a biblio to the order
    my $biblio = $builder->build_sample_biblio();
    $order->set({ biblionumber => $biblio->biblionumber })->store->discard_changes;

    my $THE_biblio = $order->biblio;
    is( ref($THE_biblio), 'Koha::Biblio', 'Returns a Koha::Biblio object' );
    is( $THE_biblio->biblionumber, $biblio->biblionumber, 'It is not cheating about the object' );

    $order->biblio->delete;
    $order = Koha::Acquisition::Orders->find($order->ordernumber);
    ok( $order, 'The order is not deleted if the biblio is deleted' );
    is( $order->biblio, undef, 'order.biblio is correctly set to NULL when the biblio is deleted' );

    $schema->storage->txn_rollback;
};

subtest 'store' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;
    my $o = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders'
        }
    );

    subtest 'entrydate' => sub {
        plan tests => 2;

        my $order;

        t::lib::Mocks::mock_preference( 'TimeFormat', '12hr' );
        $order = Koha::Acquisition::Order->new(
            {
                basketno     => $o->basketno,
                biblionumber => $o->biblionumber,
                budget_id    => $o->budget_id,
                quantity     => 1,
            }
        )->store;
        $order->discard_changes;
        like( $order->entrydate, qr|^\d{4}-\d{2}-\d{2}$| );

        t::lib::Mocks::mock_preference( 'TimeFormat', '24hr' );
        $order = Koha::Acquisition::Order->new(
            {
                basketno     => $o->basketno,
                biblionumber => $o->biblionumber,
                budget_id    => $o->budget_id,
                quantity     => 1,
            }
        )->store;
        $order->discard_changes;
        like( $order->entrydate, qr|^\d{4}-\d{2}-\d{2}$| );
    };
    $schema->storage->txn_rollback;
};

subtest 'fund' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;
    my $o = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
        }
    );

    my $order = Koha::Acquisition::Orders->find( $o->ordernumber );
    is( ref( $order->fund ),
        'Koha::Acquisition::Fund',
        '->fund should return a Koha::Acquisition::Fund object' );
    $schema->storage->txn_rollback;
};

subtest 'invoice' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    my $o = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { cancellationreason => 'XXXXXXXX', invoiceid => undef }, # not received yet
        }
    );

    my $order = Koha::Acquisition::Orders->find( $o->ordernumber );
    is( $order->invoice, undef,
        '->invoice should return undef if no invoice defined yet');

    my $invoice = $builder->build_object(
        {
            class => 'Koha::Acquisition::Invoices',
        },
    );

    $o->invoiceid( $invoice->invoiceid )->store;
    $order = Koha::Acquisition::Orders->find( $o->ordernumber );
    is( ref( $order->invoice ), 'Koha::Acquisition::Invoice',
        '->invoice should return a Koha::Acquisition::Invoice object if an invoice is defined');

    $schema->storage->txn_rollback;
};

subtest 'subscription' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    my $o = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { subscriptionid => undef }, # not linked to a subscription
        }
    );

    my $order = Koha::Acquisition::Orders->find( $o->ordernumber );
    is( $order->subscription, undef,
        '->subscription should return undef if not created from a subscription');

    $o = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            # Will be linked to a subscription by TestBuilder
        }
    );

    $order = Koha::Acquisition::Orders->find( $o->ordernumber );
    is( ref( $order->subscription ), 'Koha::Subscription',
        '->subscription should return a Koha::Subscription object if created from a subscription');

    $schema->storage->txn_rollback;
};

subtest 'duplicate_to | add_item' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item;
    my $order_no_sub = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value =>
              {
                  biblionumber => $item->biblionumber,
                  subscriptionid => undef, # not linked to a subscription
              }
        }
    );
    $order_no_sub->basket->create_items(undef)->store; # use syspref
    $order_no_sub->add_item( $item->itemnumber );

    $item = $builder->build_sample_item;
    my $order_from_sub = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value =>
              {
                  biblionumber => $item->biblionumber,
                  # Will be linked to a subscription by TestBuilder
              }
        }
    );
    $order_from_sub->basket->create_items(undef)->store; # use syspref
    $order_from_sub->add_item( $item->itemnumber );

    my $basket_to = $builder->build_object(
         { class => 'Koha::Acquisition::Baskets' });

    subtest 'Create item on receiving' => sub {
        plan tests => 2;

        t::lib::Mocks::mock_preference('AcqCreateItem', 'receiving');

        my $duplicated_order = $order_no_sub->duplicate_to($basket_to);
        is( $duplicated_order->items->count, 0,
            'Items should not be copied if the original order did not create items on ordering'
        );

        $duplicated_order = $order_from_sub->duplicate_to($basket_to);
        is( $duplicated_order->items->count, 0,
            'Items should not be copied if the original order is created from a subscription'
        );
    };

    subtest 'Create item on ordering' => sub {
        plan tests => 2;

        t::lib::Mocks::mock_preference('AcqCreateItem', 'ordering');

        my $duplicated_order = $order_no_sub->duplicate_to($basket_to);
        is( $duplicated_order->items->count, 1,
            'Items should be copied if items are created on ordering'
        );

        $duplicated_order = $order_from_sub->duplicate_to($basket_to);
        is( $duplicated_order->items->count, 0,
            'Items should never be copied if the original order is created from a subscription'
        );
    };

    subtest 'Regression tests' => sub {
        plan tests => 1;

        my $duplicated_order = $order_no_sub->duplicate_to($basket_to);
        is($duplicated_order->invoiceid, undef, "invoiceid should be set to null for a new duplicated order");
    };

    $schema->storage->txn_rollback;
};

subtest 'current_item_level_holds() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_3 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    C4::Reserves::AddReserve(
        {
            branchcode       => $patron->branchcode,
            borrowernumber   => $patron->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            reservation_date => dt_from_string->add( days => -2 ),
            itemnumber       => $item_1->itemnumber,
        }
    );
    C4::Reserves::AddReserve(
        {
            branchcode       => $patron->branchcode,
            borrowernumber   => $patron->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            reservation_date => dt_from_string->add( days => -2 ),
            itemnumber       => $item_2->itemnumber,
        }
    );
    # Add a hold in the future
    C4::Reserves::AddReserve(
        {
            branchcode       => $patron->branchcode,
            borrowernumber   => $patron->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            reservation_date => dt_from_string->add( days => 2 ),
            itemnumber       => $item_3->itemnumber,
        }
    );

    # Add an order with no biblionumber
    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                biblionumber => undef
            }
        }
    );

    my $holds = $order->current_item_level_holds;

    is( ref($holds), 'Koha::Holds', 'Koha::Holds iterator returned if no linked biblio' );
    is( $holds->count, 0, 'Count is 0 if no linked biblio' );

    $order->set({ biblionumber => $biblio->biblionumber })->store->discard_changes;

    $holds = $order->current_item_level_holds;

    is( ref($holds), 'Koha::Holds', 'Koha::Holds iterator returned if no linked items' );
    is( $holds->count, 0, 'Count is 0 if no linked items' );

    $order->add_item( $item_2->itemnumber );
    $order->add_item( $item_3->itemnumber );

    $holds = $order->current_item_level_holds;
    is( $holds->count, 1, 'Only current (not future) holds are returned');

    $schema->storage->txn_rollback;
};

subtest 'claim*' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;
    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
        }
    );

    my $now = dt_from_string;
    is( $order->claims->count, 0, 'No claim yet, ->claims should return an empty set');
    is( $order->claims_count, 0, 'No claim yet, ->claims_count should return 0');
    is( $order->claimed_date, undef, 'No claim yet, ->claimed_date should return undef');

    my $claim_1 = $order->claim;
    my $claim_2 = $order->claim;

    $claim_1->claimed_on($now->clone->subtract(days => 1))->store;
    $claim_2->claimed_on($now)->store;

    is( $order->claims->count, 2, '->claims should return the correct number of claims');
    is( $order->claims_count, 2, '->claims_count should return the correct number of claims');
    is( dt_from_string($order->claimed_date), $now, '->claimed_date should return the date of the last claim');

    $schema->storage->txn_rollback;
};

subtest 'filter_by_late' => sub {
    plan tests => 17;

    $schema->storage->txn_begin;
    my $now        = dt_from_string;
    my $bookseller = $builder->build_object(
        {
            class => 'Koha::Acquisition::Booksellers',
            value => { deliverytime => 2 }
        }
    );
    my $basket_1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => undef,
            }
        }
    );
    my $order_1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_1->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => undef,
                orderstatus             => 'ordered',
            }
        }
    );
    my $basket_2 = $builder->build_object(    # expected tomorrow
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => $now->clone->subtract( days => 1 ),
            }
        }
    );
    my $order_2 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_2->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => undef,
                orderstatus             => 'ordered',
            }
        }
    );
    my $basket_3 = $builder->build_object(    # expected yesterday (1 day)
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => $now->clone->subtract( days => 3 ),
            }
        }
    );
    my $order_3 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_3->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => undef,
                orderstatus             => 'ordered',
            }
        }
    );
    my $basket_4 = $builder->build_object(    # expected 3 days ago
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => $now->clone->subtract( days => 5 ),
            }
        }
    );
    my $order_4 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_4->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => undef,
                orderstatus             => 'ordered',
            }
        }
    );
    my $order_42 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_4->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => undef,
                orderstatus             => 'complete',
            }
        }
    );

    my $orders = Koha::Acquisition::Orders->search(
        {
            ordernumber => {
                -in => [
                    $order_1->ordernumber, $order_2->ordernumber,
                    $order_3->ordernumber, $order_4->ordernumber,
                ]
            }
        }
    );

    my $late_orders = $orders->filter_by_lates;
    is( $late_orders->count, 3 );

    $late_orders = $orders->filter_by_lates( { delay => 0 } );
    is( $late_orders->count, 3 );

    $late_orders = $orders->filter_by_lates( { delay => 1 } );
    is( $late_orders->count, 3 );

    $late_orders = $orders->filter_by_lates( { delay => 3 } );
    is( $late_orders->count, 2 );

    $late_orders = $orders->filter_by_lates( { delay => 4 } );
    is( $late_orders->count, 1 );

    $late_orders = $orders->filter_by_lates( { delay => 5 } );
    is( $late_orders->count, 1 );

    $late_orders = $orders->filter_by_lates( { delay => 6 } );
    is( $late_orders->count, 0 );

    $late_orders = $orders->filter_by_lates(
        { estimated_from => $now->clone->subtract( days => 6 ) } );
    is( $late_orders->count,             2 );
    is( $late_orders->next->ordernumber, $order_3->ordernumber );

    $late_orders = $orders->filter_by_lates(
        { estimated_from => $now->clone->subtract( days => 5 ) } );
    is( $late_orders->count,             2 );
    is( $late_orders->next->ordernumber, $order_3->ordernumber );

    $late_orders = $orders->filter_by_lates(
        { estimated_from => $now->clone->subtract( days => 4 ) } );
    is( $late_orders->count,             2 );
    is( $late_orders->next->ordernumber, $order_3->ordernumber );

    $late_orders = $orders->filter_by_lates(
        { estimated_from => $now->clone->subtract( days => 3 ) } );
    is( $late_orders->count, 2 );

    $late_orders = $orders->filter_by_lates(
        { estimated_from => $now->clone->subtract( days => 1 ) } );
    is( $late_orders->count, 1 );

    $late_orders = $orders->filter_by_lates(
        {
            estimated_from => $now->clone->subtract( days => 4 ),
            estimated_to   => $now->clone->subtract( days => 3 )
        }
    );
    is( $late_orders->count, 1 );

    my $basket_5 = $builder->build_object(    # closed today
        {
            class => 'Koha::Acquisition::Baskets',
            value => {
                booksellerid => $bookseller->id,
                closedate    => $now,
            }
        }
    );
    my $order_5 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno                => $basket_4->basketno,
                datereceived            => undef,
                datecancellationprinted => undef,
                estimated_delivery_date => $now->clone->subtract( days => 2 ),
            }
        }
    );
    $late_orders = $orders->filter_by_lates(
        {
            estimated_from => $now->clone->subtract( days => 3 ),
            estimated_to   => $now->clone->subtract( days => 2 )
        }
    );
    is( $late_orders->count, 1 );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_current & filter_by_cancelled' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    my $now        = dt_from_string;
    my $order_1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                datecancellationprinted => undef,
            }
        }
    );
    my $order_2 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                datecancellationprinted => undef,
            }
        }
    );
    my $order_3 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                datecancellationprinted => dt_from_string,
            }
        }
    );

    my $orders = Koha::Acquisition::Orders->search(
        {
            ordernumber => {
                -in => [
                    $order_1->ordernumber, $order_2->ordernumber,
                    $order_3->ordernumber,
                ]
            }
        }
    );

    is( $orders->filter_by_current->count, 2);
    is( $orders->filter_by_cancelled->count, 1);


    $schema->storage->txn_rollback;
};

subtest 'cancel() tests' => sub {

    plan tests => 54;

    $schema->storage->txn_begin;

    my $reason = 'Some reason';

    # Scenario:
    # * order with one item attached
    # * the item is on loan
    # * delete_biblio is passed
    # => order is not cancelled
    # => item in order is not removed
    # => biblio in order is not removed
    # => message about not being able to delete

    my $item      = $builder->build_sample_item;
    my $biblio_id = $item->biblionumber;
    my $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $item->biblionumber,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item->id );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $item->homebranch, flags => 1 }
        }
    );
    t::lib::Mocks::mock_userenv({ patron => $patron });

    # Add a checkout so deleting the item fails because od 'book_on_loan'
    C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

    my $result = $order->cancel({ reason => $reason });
    # refresh the order object
    $order->discard_changes;

    is( $result, $order, 'self is returned' );
    is( $order->orderstatus, 'cancelled', 'Order is not marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is not undef' );
    is( $order->cancellationreason, $reason, 'cancellationreason is set' );
    is( ref(Koha::Items->find($item->id)), 'Koha::Item', 'The item is present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is present' );
    my @messages = @{ $order->object_messages };
    is( $messages[0]->message, 'error_delitem', 'An error message is attached to the order' );

    # Scenario:
    # * order with one item attached
    # * the item is no longer on loan
    # * delete_biblio not passed
    # => order is cancelled
    # => item in order is removed
    # => biblio remains untouched

    C4::Circulation::AddReturn( $item->barcode );

    $order = Koha::Acquisition::Orders->find($order->ordernumber);
    $order->cancel({ reason => $reason })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is set' );
    is( $order->cancellationreason, $reason, 'cancellationreason is undef' );
    is( Koha::Items->find($item->id), undef, 'The item is no longer present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is present' );
    @messages = @{ $order->object_messages };
    is( scalar @messages, 0, 'No messages' );

    # Scenario:
    # * order with one item attached
    # * biblio has another item
    # => order is cancelled
    # => item in order is removed
    # => the extra item remains untouched
    # => biblio remains untouched

    my $item_1 = $builder->build_sample_item;
    $biblio_id = $item_1->biblionumber;
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio_id });
    $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $biblio_id,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item_1->id );

    $order->cancel({ reason => $reason, delete_biblio => 1 })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is set' );
    is( $order->cancellationreason, $reason, 'cancellationreason is undef' );
    is( Koha::Items->find($item_1->id), undef, 'The item is no longer present' );
    is( ref(Koha::Items->find($item_2->id)), 'Koha::Item', 'The item is still present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is still present' );
    @messages = @{ $order->object_messages };
    is( $messages[0]->message, 'error_delbiblio_items', 'Cannot delete biblio and it gets notified' );

    # Scenario:
    # * order with one item attached
    # * there's another order pointing to the biblio
    # => order is cancelled
    # => item in order is removed
    # => biblio remains untouched
    # => biblio delete error notified

    $item      = $builder->build_sample_item;
    $biblio_id = $item->biblionumber;
    $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $biblio_id,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item->id );

    # Add another order
    $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $biblio_id,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );

    $order->cancel({ reason => $reason, delete_biblio => 1 })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is set' );
    is( $order->cancellationreason, $reason, 'cancellationreason is undef' );
    is( Koha::Items->find($item->id), undef, 'The item is no longer present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is still present' );
    @messages = @{ $order->object_messages };
    is( $messages[0]->message, 'error_delbiblio_active_orders', 'Cannot delete biblio and it gets notified' );

    # Scenario:
    # * order with one item attached
    # * there's a subscription on the biblio
    # => order is cancelled
    # => item in order is removed
    # => biblio remains untouched
    # => biblio delete error notified

    $item      = $builder->build_sample_item;
    $biblio_id = $item->biblionumber;
    $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $biblio_id,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item->id );

    # Add a subscription
    $builder->build_object(
        {
            class => 'Koha::Subscriptions',
            value => {
                biblionumber => $biblio_id,
            }
        }
    );

    $order->cancel({ reason => $reason, delete_biblio => 1 })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is set' );
    is( $order->cancellationreason, $reason, 'cancellationreason is undef' );
    is( Koha::Items->find($item->id), undef, 'The item is no longer present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is still present' );
    @messages = @{ $order->object_messages };
    is( $messages[0]->message, 'error_delbiblio_subscriptions', 'Cannot delete biblio and it gets notified' );

    # Scenario:
    # * order with one item attached
    # * delete_biblio is passed
    # => order is cancelled
    # => item in order is removed
    # => biblio in order is removed

    $item      = $builder->build_sample_item;
    $biblio_id = $item->biblionumber;
    $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $item->biblionumber,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item->id );

    $order->cancel({ reason => $reason, delete_biblio => 1 })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is not marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is not undef' );
    is( $order->cancellationreason, $reason, 'cancellationreason is set' );
    is( Koha::Items->find($item->id), undef, 'The item is not present' );
    is( Koha::Biblios->find($biblio_id), undef, 'The biblio is not present' );
    @messages = @{ $order->object_messages };
    is( scalar @messages, 0, 'No errors' );

    # Scenario:
    # * order with two items attached
    # * one of the items is on loan
    # => order is cancelled
    # => item on loan is kept
    # => the other item is removed
    # => biblio remains untouched
    # => biblio delete error notified
    # => item delete error notified

    $item_1    = $builder->build_sample_item;
    $item_2    = $builder->build_sample_item({ biblionumber => $item_1->biblionumber });
    my $item_3 = $builder->build_sample_item({ biblionumber => $item_1->biblionumber });
    $biblio_id = $item_1->biblionumber;
    $order     = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus             => 'new',
                biblionumber            => $biblio_id,
                datecancellationprinted => undef,
                cancellationreason      => undef,
            }
        }
    );
    $order->add_item( $item_1->id );
    $order->add_item( $item_2->id );
    $order->add_item( $item_3->id );

    # Add a checkout so deleting the item fails because od 'book_on_loan'
    C4::Circulation::AddIssue( $patron->unblessed, $item_2->barcode );
    C4::Reserves::AddReserve(
        {
            branchcode     => $item_3->holdingbranch,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_id,
            itemnumber     => $item_3->id,
            found          => 'W',
        }
    );

    $order->cancel({ reason => $reason, delete_biblio => 1 })
          ->discard_changes;

    is( $order->orderstatus, 'cancelled', 'Order is marked as cancelled' );
    isnt( $order->datecancellationprinted, undef, 'datecancellationprinted is set' );
    is( $order->cancellationreason, $reason, 'cancellationreason is undef' );
    is( Koha::Items->find($item_1->id), undef, 'The item is no longer present' );
    is( ref(Koha::Items->find($item_2->id)), 'Koha::Item', 'The on loan item is still present' );
    is( ref(Koha::Biblios->find($biblio_id)), 'Koha::Biblio', 'The biblio is still present' );
    @messages = @{ $order->object_messages };
    is( $messages[0]->message, 'error_delitem', 'Cannot delete on loan item' );
    is( $messages[0]->payload->{item}->id, $item_2->id, 'Cannot delete on loan item' );
    is( $messages[0]->payload->{reason}, 'book_on_loan', 'Item on loan notified' );
    is( $messages[1]->message, 'error_delitem', 'Cannot delete reserved and found item' );
    is( $messages[1]->payload->{item}->id, $item_3->id, 'Cannot delete reserved and found item' );
    is( $messages[1]->payload->{reason}, 'book_reserved', 'Item reserved notified' );
    is( $messages[2]->message, 'error_delbiblio_items', 'Cannot delete on loan item' );
    is( $messages[2]->payload->{biblio}->id, $biblio_id, 'The right biblio is attached' );

    # Call ->store with biblionumber NULL (as ->cancel does)
    $item_1 = $builder->build_sample_item;
    $biblio_id = $item_1->biblionumber;
    $order= $builder->build_object({
        class => 'Koha::Acquisition::Orders',
        value => {
            orderstatus             => 'new',
            biblionumber            => $biblio_id,
            datecancellationprinted => undef,
            cancellationreason      => undef,
        }
    });
    my $columns = {
        biblionumber            => undef,
        cancellationreason      => $reason,
        datecancellationprinted => \'NOW()',
        orderstatus             => 'cancelled',
    };
    lives_ok { $order->set($columns)->store; } 'No croak on missing biblionumber when cancelling an order';
    throws_ok { $order->orderstatus('new')->store; } qr/Cannot insert order: Mandatory parameter biblionumber is missing/, 'Expected croak';

    $schema->storage->txn_rollback;
};
