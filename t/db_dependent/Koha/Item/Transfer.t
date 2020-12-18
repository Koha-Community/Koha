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

use Koha::Database;

use t::lib::TestBuilder;

use Test::More tests => 2;
use Test::Exception;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'item relation tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $item     = $builder->build_sample_item();
    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item->itemnumber,
            }
        }
    );

    my $transfer_item = $transfer->item;
    is( ref( $transfer_item ), 'Koha::Item', 'Koha::Item::Transfer->item should return a Koha::Item' );
    is( $transfer_item->itemnumber, $item->itemnumber, 'Koha::Item::Transfer->item should return the correct item' );

    $schema->storage->txn_rollback;
};

subtest 'transit tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            datelastseen  => undef
        }
    );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $item->itemnumber,
                frombranch => $library2->branchcode,
                tobranch   => $library1->branchcode,
                reason     => 'Manual'
            }
        }
    );
    is( ref($transfer), 'Koha::Item::Transfer', 'Mock transfer added' );

    # Item checked out should result in failure
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber => $item->itemnumber
            }
        }
    );
    is( ref($checkout), 'Koha::Checkout', 'Mock checkout added' );

    throws_ok { $transfer->transit() }
    'Koha::Exceptions::Item::Transfer::Out',
      'Exception thrown if item is checked out';

    $checkout->delete;

    # CartToShelf test
    $item->set({ location => 'CART', permanent_location => 'TEST' })->store();
    is ( $item->location, 'CART', 'Item location set to CART');
    $transfer->discard_changes;
    $transfer->transit();
    $item->discard_changes;
    is ( $item->location, 'TEST', 'Item location correctly restored to match permanent location');

    # Transit state set
    ok( $transfer->datesent, 'Transit set the datesent for the transfer' );

    # Last seen
    ok ( $item->datelastseen, 'Transit set item datelastseen date');

    $schema->storage->txn_rollback;
};
