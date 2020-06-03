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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'filter_by_active() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

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
            value => { orderstatus => 'new' }
        }
    );
    my $order_4 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'ordered' }
        }
    );
    my $order_5 = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'partial' }
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
            ]
        },
        {
            order_by => 'ordernumber'
        }
    );

    my $rs = $this_orders_rs->filter_by_active;

    is( $rs->count, 3, 'Only new, ordered and partial orders are returned' );
    is( $rs->next->ordernumber, $order_3->ordernumber , 'Expected order in resultset' );
    is( $rs->next->ordernumber, $order_4->ordernumber , 'Expected order in resultset' );
    is( $rs->next->ordernumber, $order_5->ordernumber , 'Expected order in resultset' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_id_including_transfers() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $order_1 = $builder->build_object({ class => 'Koha::Acquisition::Orders' });
    my $order_2 = $builder->build_object({ class => 'Koha::Acquisition::Orders' });
    my $order_3 = $builder->build_object({ class => 'Koha::Acquisition::Orders' });

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
    my $count = $orders_rs->count;

    throws_ok
        { $orders_rs->filter_by_id_including_transfers() }
        'Koha::Exceptions::MissingParameter',
        'Exception thrown correctly';

    $orders_rs = $orders_rs->filter_by_id_including_transfers({ ordernumber => $order_1->ordernumber });

    is( $orders_rs->count, 2, 'The two referenced orders are returned' );
    is( $orders_rs->next->ordernumber, $order_2->ordernumber, 'The right order is returned' );
    is( $orders_rs->next->ordernumber, $order_1->ordernumber, 'The right order is returned' );

    $orders_rs = $orders_rs->filter_by_id_including_transfers({ ordernumber => $order_2->ordernumber });

    is( $orders_rs->count, 1, 'Only one order related to the specified ordernumber' );
    is( $orders_rs->next->ordernumber, $order_2->ordernumber, 'The right order is returned' );

    $schema->storage->txn_rollback;
};
