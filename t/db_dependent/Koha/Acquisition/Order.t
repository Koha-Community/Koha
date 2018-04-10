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

use Test::More tests => 2;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

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
