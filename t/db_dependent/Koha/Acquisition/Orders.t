#!/usr/bin/perl

# Copyright 2020 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'filter_by_active() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $basket_1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { is_standing => 1 }
        }
    );

    my $basket_2 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { is_standing => 0 }
        }
    );

    my $order_1 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'cancelled' }
        }
    );
    my $order_2 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'completed' }
        }
    );
    my $order_3 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno         => $basket_1->basketno,
                orderstatus      => 'new',
                quantity         => 1,
                quantityreceived => 0,
            }
        }
    );
    my $order_4 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'ordered', quantity => 1, quantityreceived => 0 }
        }
    );
    my $order_5 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'partial', quantity => 2, quantityreceived => 1 }
        }
    );
    my $order_6 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                basketno         => $basket_2->basketno,
                orderstatus      => 'new',
                quantity         => 1,
                quantityreceived => 0,
            }
        }
    );

    my $this_orders_rs = Koha::Acquisition::Orders->search(
        {
            ordernumber => [
                $order_1->ordernumber,
                $order_2->ordernumber,
                $order_3->ordernumber,
                $order_4->ordernumber,
                $order_5->ordernumber,
                $order_6->ordernumber,
            ]
        },
        { order_by => 'ordernumber' }
    );

    my $rs = $this_orders_rs->filter_by_active;

    is( $rs->count,             3, 'Only new (basket is standing), ordered and partial orders are returned' );
    is( $rs->next->ordernumber, $order_3->ordernumber, 'Expected order in resultset' );
    is( $rs->next->ordernumber, $order_4->ordernumber, 'Expected order in resultset' );
    is( $rs->next->ordernumber, $order_5->ordernumber, 'Expected order in resultset' );

    # If we change quantities on order_5 (partial), we should no longer see it
    $order_5->quantityreceived(2)->store;
    is( $this_orders_rs->filter_by_active->count, 2, 'Dropped one order as expected' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_id_including_transfers() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $order_1 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $order_2 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $order_3 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );

    $builder->build(
        {
            source => 'AqordersTransfer',
            value  => {
                ordernumber_from => $order_1->ordernumber,
                ordernumber_to   => $order_2->ordernumber
            }
        }
    );

    my $orders_rs = Koha::Acquisition::Orders->search;
    my $count     = $orders_rs->count;

    throws_ok { $orders_rs->filter_by_id_including_transfers() }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown correctly';

    $orders_rs = $orders_rs->filter_by_id_including_transfers( { ordernumber => $order_1->ordernumber } );

    is_deeply(
        [ sort { $a <=> $b } $orders_rs->get_column('ordernumber') ],
        [ $order_1->ordernumber, $order_2->ordernumber ], 'The 2 orders are returned'
    );

    $orders_rs = $orders_rs->filter_by_id_including_transfers( { ordernumber => $order_2->ordernumber } );

    is( $orders_rs->count,             1,                     'Only one order related to the specified ordernumber' );
    is( $orders_rs->next->ordernumber, $order_2->ordernumber, 'The right order is returned' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_obsolete and cancel' => sub {
    plan tests => 11;
    $schema->storage->txn_begin;

    my $order_1 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $order_2 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );
    my $order_3 = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );

    # First make order 1 obsolete by removing biblio, and order 3 by status problem.
    my $date = Koha::DateUtils::dt_from_string->subtract( days => 7 );
    $order_1->orderstatus('ordered')
        ->quantity(2)
        ->quantityreceived(0)
        ->datecancellationprinted(undef)
        ->entrydate($date)
        ->store;
    Koha::Biblios->find( $order_1->biblionumber )->delete;
    $order_1->discard_changes;
    $order_2->orderstatus('ordered')->quantity(3)->quantityreceived(0)->datecancellationprinted(undef)->store;
    $order_3->orderstatus('cancelled')->datecancellationprinted(undef)->store;

    my $limit = { ordernumber => { '>=', $order_1->ordernumber } };
    my $rs    = Koha::Acquisition::Orders->filter_by_obsolete->search($limit);
    is( $rs->count, 2, 'Two obsolete' );
    is( $rs->search( { ordernumber => $order_1->ordernumber } )->count, 1, 'Including order_1' );
    is( $rs->search( { ordernumber => $order_2->ordernumber } )->count, 0, 'Excluding order_2' );

    # Test param age
    $rs = Koha::Acquisition::Orders->filter_by_obsolete( { age => 6 } )->search($limit);
    is( $rs->count, 1, 'Age 6: Including order_1' );
    $rs = Koha::Acquisition::Orders->filter_by_obsolete( { age => 7 } )->search($limit);
    is( $rs->count, 0, 'Age 7: Excluding order_1' );

    # Make order 2 obsolete too
    Koha::Biblios->find( $order_2->biblionumber )->delete;
    $order_2->discard_changes;

    # Use the plural cancel method
    $rs = Koha::Acquisition::Orders->filter_by_obsolete->search($limit);
    is( $rs->count, 3, 'Three obsolete' );
    my @results = $rs->cancel;
    is( $results[0],                            2,           'Two should be cancelled, one was cancelled already' );
    is( @{ $results[1] },                       0,           'No messages' );
    is( $order_1->discard_changes->orderstatus, 'cancelled', 'Check orderstatus of order_1' );
    isnt( $order_2->discard_changes->datecancellationprinted, undef, 'Cancellation date of order_2 filled' );
    is( $order_3->discard_changes->datecancellationprinted, undef, 'order_3 was skipped, so date not touched' );

    $schema->storage->txn_rollback;
};
