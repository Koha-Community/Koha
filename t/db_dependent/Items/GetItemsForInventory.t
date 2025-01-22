#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (c) 2015   Mark Tompsett
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
use Test::More tests => 8;
use t::lib::TestBuilder;

use List::MoreUtils qw( any none );

use C4::Biblio      qw(AddBiblio);
use C4::Reserves    qw( AddReserve );
use C4::ClassSource qw( GetClassSort );
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Database;
use MARC::Record;

BEGIN {
    use_ok('C4::Context');
    use_ok( 'C4::Items', qw( GetItemsForInventory ) );
    use_ok('C4::Biblio');
    use_ok('C4::Koha');
}

can_ok( 'C4::Items', 'GetItemsForInventory' );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Skip items with waiting holds' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes', value => { rentalcharge => 0 } } );
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons',   value => { branchcode   => $library->id } } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons',   value => { branchcode   => $library->id } } );

    my $title_1 = 'Title 1, ';
    my $title_2 = 'Title 2, bizzarre one so doesn\'t already exist';

    my $biblio_1 = $builder->build_sample_biblio( { itemtype => $itemtype->itemtype, title => $title_1 } );
    my $biblio_2 = $builder->build_sample_biblio( { itemtype => $itemtype->itemtype, title => $title_2 } );

    my ( $items_1, $first_items_count ) = GetItemsForInventory();
    is( scalar @{$items_1}, $first_items_count, 'Results and count match' );

    # Add two items, so we don't depend on existing data
    my $item_1 = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                biblionumber     => $biblio_1->biblionumber,
                biblioitemnumber => $biblio_1->biblioitem->biblioitemnumber,
                homebranch       => $library->id,
                holdingbranch    => $library->id,
                itype            => $itemtype->itemtype,
                reserves         => undef
            }
        }
    );

    my $item_2 = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                biblionumber     => $biblio_2->biblionumber,
                biblioitemnumber => $biblio_2->biblioitem->biblioitemnumber,
                homebranch       => $library->id,
                holdingbranch    => $library->id,
                itype            => $itemtype->itemtype,
                reserves         => undef
            }
        }
    );

    my ( $items_2, $second_items_count ) = GetItemsForInventory();
    is( scalar @{$items_2},     $second_items_count, 'Results and count match' );
    is( $first_items_count + 2, $second_items_count, 'Two items added, count makes sense' );

    my $real_itemtype_count = Koha::Items->search( { itype => $itemtype->itemtype } )->count;
    my $itype_str           = "'" . $itemtype->itemtype . "'";    # manipulate string for db query
    my ( $items_3, $itemtype_count ) = GetItemsForInventory( { itemtypes => [$itype_str] } );
    is( $itemtype_count, $real_itemtype_count, 'Itemtype filter gets correct number of inventory items' );

    # Add 2 waiting holds
    C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $item_1->biblionumber,
            priority       => 1,
            itemnumber     => $item_1->itemnumber,
            found          => 'W'
        }
    );
    C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $item_2->biblionumber,
            priority       => 1,
            itemnumber     => $item_2->itemnumber,
        }
    );
    C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $item_2->biblionumber,
            priority       => 2,
            itemnumber     => $item_2->itemnumber,
        }
    );

    my ( $new_items, $new_items_count ) = GetItemsForInventory( { ignore_waiting_holds => 1 } );
    is( $new_items_count, $first_items_count + 1, 'Item on hold skipped, count makes sense' );
    ok(
        ( any { $_->{title} eq $title_2 } @{$new_items} ),
        'Item on hold skipped, the other one we added is present'
    );
    ok(
        ( none { $_->{title} eq $title_1 } @{$new_items} ),
        'Item on hold skipped, no one matches'
    );
    is( scalar(@$new_items), $new_items_count, 'total and number of items is the same' );

    $schema->storage->txn_rollback;
};

subtest 'Use cn_sort rather than callnumber to determine correct location' => sub {
    $schema->storage->txn_begin;
    plan tests => 1;

    my $builder = t::lib::TestBuilder->new;

    my $class_rule = $builder->build(
        {
            source => 'ClassSortRule',
            value  => { sort_routine => "LCC" }
        }
    );
    my $class_source = $builder->build(
        {
            source => 'ClassSource',
            value  => {
                class_sort_rule => $class_rule->{class_sort_rule},
            }
        }
    );

    #Find if we have any items in our test range before we start
    my ( undef, $pre_item_count ) = GetItemsForInventory(
        {
            maxlocation  => 'GT100',
            minlocation  => 'GT90',
            class_source => $class_source->{cn_source},
        }
    );

    my $item_1 = $builder->build(
        {    # Cannot call build_sample_item or cn_sort will be replaced by Koha::Item->store
            source => 'Item',
            value  => {
                itemcallnumber => 'GT95',
                cn_sort        => GetClassSort( $class_source->{cn_source}, undef, 'GT95' ),
            }
        }
    );

    my ( undef, $item_count ) = GetItemsForInventory(
        {
            maxlocation  => 'GT100',
            minlocation  => 'GT90',
            class_source => $class_source->{cn_source},
        }
    );
    is( $item_count, $pre_item_count + 1, "We should return GT95 as between GT90 and GT100" );
    $schema->storage->txn_rollback;

};
