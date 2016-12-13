#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2016
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
use Test::More tests => 4;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;
use Benchmark;

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Availability::Search;
use Koha::Biblio::Availability::Search;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'Biblio with zero available items' => \&t_no_available_items;
sub t_no_available_items {
    plan tests => 6;

    my $item1 = build_a_test_item();
    my $biblio = Koha::Biblios->find($item1->biblionumber);
    my $item2 = build_a_test_item();
    $item2->biblionumber($biblio->biblionumber)->store;
    $item2->biblioitemnumber($item1->biblioitemnumber)->store;
    $item1->withdrawn('1')->store;
    $item2->notforloan('1')->store;
    my $patron = build_a_test_patron();

    my $availability = Koha::Biblio::Availability::Search->new({
        biblio => $biblio,
    })->in_opac;
    my $expecting = 'Koha::Exceptions::Biblio::NoAvailableItems';

    ok(!Koha::Item::Availability::Search->new({
            item => $item1,
        })->in_opac->available,
       'When I look at the first item of two in this biblio, it is not available.');
    ok(!Koha::Item::Availability::Search->new({
            item => $item2
        })->in_opac->available,
       'When I look at the second item of two in this biblio, it is not available.');
    ok(!$availability->available, 'Then, the biblio is not available.');
    is($availability->unavailable, 1, 'Then, there is exactly one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'The reason says there are no'
       .' available items in this biblio.');
    is(@{$availability->item_unavailabilities}, 2, 'There seems to be two items that are unavailable.');
};

subtest 'Biblio with one available items out of two' => \&t_one_out_of_two_items_available;
sub t_one_out_of_two_items_available {
    plan tests => 5;

    my $item1 = build_a_test_item();
    my $biblio = Koha::Biblios->find($item1->biblionumber);
    my $item2 = build_a_test_item();
    $item2->biblionumber($biblio->biblionumber)->store;
    $item2->biblioitemnumber($item1->biblioitemnumber)->store;

    my $patron = build_a_test_patron();
    $item1->withdrawn('1')->store;

    my $availability = Koha::Biblio::Availability::Search->new({biblio => $biblio})->in_opac;
    my $item_availabilities = $availability->item_availabilities;
    ok(!Koha::Item::Availability::Search->new({ item => $item1,})->in_opac->available,
       'When I look at the first item of two in this biblio, it is not available.');
    ok(Koha::Item::Availability::Search->new({ item => $item2,})->in_opac->available,
       'When I look at the second item of two in this biblio, it seems to be available.');
    ok($availability->available, 'Then, the biblio is available.');
    is(@{$item_availabilities}, 1, 'There seems to be one available item in this biblio.');
    is($item_availabilities->[0]->item->itemnumber, $item2->itemnumber, 'Then the only available item'
       .' is the second item of this biblio.');
};

subtest 'Biblio with two items out of two available' => \&t_all_items_available;
sub t_all_items_available {
    plan tests => 4;

    my $item1 = build_a_test_item();
    my $biblio = Koha::Biblios->find($item1->biblionumber);
    my $item2 = build_a_test_item();
    $item2->biblionumber($biblio->biblionumber)->store;
    $item2->biblioitemnumber($item1->biblioitemnumber)->store;

    my $patron = build_a_test_patron();

    my $availability = Koha::Biblio::Availability::Search->new({biblio => $biblio})->in_opac;
    my $item_availabilities = $availability->item_availabilities;
    ok(Koha::Item::Availability::Search->new({ item => $item1,})->in_opac->available,
       'When I look at the first item of two in this biblio, it seems to be available.');
    ok(Koha::Item::Availability::Search->new({ item => $item2,})->in_opac->available,
       'When I look at the second item of two in this biblio, it seems to be available.');
    ok($availability->available, 'Then, the biblio is available.');
    is(@{$item_availabilities}, 2, 'There seems to be two available items in this biblio.');
};

subtest 'Prove that lower MaxSearchResultsItemsPerRecordStatusCheck boosts performance' => \&t_performance_proof;
sub t_performance_proof {
    plan tests => 6;

    my $item = build_a_test_item();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);

    # add some items to biblio
    my $count1 = 20;
    my $count2 = 200;
    for my $i (1..($count2-1)) { # one already built earlier
        build_a_test_item($biblio, $biblioitem);
    }

    my $availability_iterations = 10;
    my @items = $biblio->items;
    is(@items, $count2, "We will get availability for $count2 items.");
    t::lib::Mocks::mock_preference('MaxSearchResultsItemsPerRecordStatusCheck',
                                    $count1);
    is(C4::Context->preference('MaxSearchResultsItemsPerRecordStatusCheck'),
       $count1, "First test will be done with"
       ." MaxSearchResultsItemsPerRecordStatusCheck = $count1");
    my $res1 = timethis($availability_iterations, sub {
        Koha::Availability::Search->new->biblio({ biblio => $biblio })->in_opac(
            {
                MaxSearchResultsItemsPerRecordStatusCheck => 1
            }
        );
    });
    ok($res1, "Calculated search availability $availability_iterations times.");
    t::lib::Mocks::mock_preference('MaxSearchResultsItemsPerRecordStatusCheck',
                                    $count2);
    is(C4::Context->preference('MaxSearchResultsItemsPerRecordStatusCheck'),
       $count2, "Second test will be done with"
       ." MaxSearchResultsItemsPerRecordStatusCheck = $count2");
    my $res2 = timethis($availability_iterations, sub {
        Koha::Availability::Search->new->biblio({ biblio => $biblio })->in_opac(
            {
                MaxSearchResultsItemsPerRecordStatusCheck => 1
            }
        );
    });
    ok($res2, "Calculated search availability $availability_iterations times.");
    ok($res1->cpu_a < $res2->cpu_a, 'First test was faster than second.');
};

$schema->storage->txn_rollback;

1;
