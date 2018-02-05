#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use Test::More tests => 8;

use C4::Circulation;
use Koha::Item;
use Koha::Items;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder     = t::lib::TestBuilder->new;
my $biblioitem  = $builder->build( { source => 'Biblioitem' } );
my $library     = $builder->build( { source => 'Branch' } );
my $nb_of_items = Koha::Items->search->count;
my $new_item_1  = Koha::Item->new(
    {   biblionumber     => $biblioitem->{biblionumber},
        biblioitemnumber => $biblioitem->{biblioitemnumber},
        homebranch       => $library->{branchcode},
        holdingbranch    => $library->{branchcode},
        barcode          => "a_barcode_for_t",
        itype            => 'BK',
    }
)->store;
my $new_item_2 = Koha::Item->new(
    {   biblionumber     => $biblioitem->{biblionumber},
        biblioitemnumber => $biblioitem->{biblioitemnumber},
        homebranch       => $library->{branchcode},
        holdingbranch    => $library->{branchcode},
        barcode          => "another_bc_for_t",
        itype            => 'BK',
    }
)->store;

C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, 'Midway Public Library', '', '', '');

like( $new_item_1->itemnumber, qr|^\d+$|, 'Adding a new item should have set the itemnumber' );
is( Koha::Items->search->count, $nb_of_items + 2, 'The 2 items should have been added' );

my $retrieved_item_1 = Koha::Items->find( $new_item_1->itemnumber );
is( $retrieved_item_1->barcode, $new_item_1->barcode, 'Find a item by id should return the correct item' );

subtest 'get_transfer' => sub {
    plan tests => 3;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    C4::Circulation::transferbook( $library_to->{branchcode}, $new_item_1->barcode );

    $transfer = $new_item_1->get_transfer();
    is( ref($transfer), 'Koha::Item::Transfer', 'Koha::Item->get_transfer should return a Koha::Item::Transfers object' );

    is( $transfer->itemnumber, $new_item_1->itemnumber, 'Koha::Item->get_transfer should return a valid Koha::Item::Transfers object' );
};

subtest 'biblio' => sub {
    plan tests => 2;

    my $biblio = $retrieved_item_1->biblio;
    is( ref( $biblio ), 'Koha::Biblio', 'Koha::Item->biblio should return a Koha::Biblio' );
    is( $biblio->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblio should return the correct biblio' );
};

subtest 'biblioitem' => sub {
    plan tests => 2;

    my $biblioitem = $retrieved_item_1->biblioitem;
    is( ref( $biblioitem ), 'Koha::Biblioitem', 'Koha::Item->biblioitem should return a Koha::Biblioitem' );
    is( $biblioitem->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblioitem should return the correct biblioitem' );
};

subtest 'checkout' => sub {
    plan tests => 5;
    my $item = Koha::Items->find( $new_item_1->itemnumber );
    # No checkout yet
    my $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no current checkout on this item' );

    # Add a checkout
    my $patron = $builder->build({ source => 'Borrower' });
    C4::Circulation::AddIssue( $patron, $item->barcode );
    $checkout = $retrieved_item_1->checkout;
    is( ref( $checkout ), 'Koha::Checkout', 'Koha::Item->checkout should return a Koha::Checkout' );
    is( $checkout->itemnumber, $item->itemnumber, 'Koha::Item->checkout should return the correct checkout' );
    is( $checkout->borrowernumber, $patron->{borrowernumber}, 'Koha::Item->checkout should return the correct checkout' );

    # Do the return
    C4::Circulation::AddReturn( $item->barcode );

    # There is no more checkout on this item, making sure it will not return old checkouts
    $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no *current* checkout on this item' );
};

$retrieved_item_1->delete;
is( Koha::Items->search->count, $nb_of_items + 1, 'Delete should have deleted the item' );

$schema->storage->txn_rollback;

