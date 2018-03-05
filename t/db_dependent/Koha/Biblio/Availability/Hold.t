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
use Test::More tests => 6;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;
use Benchmark;

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Biblio::Availability::Hold;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'Biblio with zero available items in OPAC' => \&t_no_available_items_opac;
sub t_no_available_items_opac {
    plan tests => 6;

    my $item1 = build_a_test_item();
    my $biblio = Koha::Biblios->find($item1->biblionumber);
    my $item2 = build_a_test_item();
    $item2->biblionumber($biblio->biblionumber)->store;
    $item2->biblioitemnumber($item1->biblioitemnumber)->store;
    $item2->itype($item1->itype)->store;

    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item2->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 0,
        reservesallowed => 0,
        opacitemholds => 'Y',
    })->store;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $branch2 = Koha::Libraries->find($builder->build({ source => 'Branch' })->{branchcode});
    C4::Circulation::CreateBranchTransferLimit(
        $branch2->branchcode,
        $item1->holdingbranch,
        $item1->effective_itemtype
    );

    my $availability = Koha::Biblio::Availability::Hold->new({
        biblio => $biblio,
        to_branch => $branch2->branchcode
    })->in_opac;
    my $expecting = 'Koha::Exceptions::Biblio::NoAvailableItems';

    ok(!Koha::Item::Availability::Hold->new({
            item => $item1, to_branch => $branch2->branchcode,
        })->in_opac->available,
       'When I look at the first item of two in this biblio, it is not available.');
    ok(!Koha::Item::Availability::Hold->new({
            item => $item2,
        })->in_opac->available,
       'When I look at the second item of two in this biblio, it is not available.');
    ok(!$availability->available, 'Then, the biblio is not available.');
    is($availability->unavailable, 1, 'Then, there are two reasons for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'The first reason says there are no'
       .' available items in this biblio.');
    is(@{$availability->item_unavailabilities}, 2, 'There seems to be two items that are unavailable.');
};

subtest 'Biblio with zero available items in intranet' => \&t_no_available_items_intranet;
sub t_no_available_items_intranet {
    plan tests => 2;

    my $item1 = build_a_test_item();
    my $biblio = Koha::Biblios->find($item1->biblionumber);
    my $item2 = build_a_test_item();
    $item2->biblionumber($biblio->biblionumber)->store;
    $item2->biblioitemnumber($item1->biblioitemnumber)->store;

    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item2->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 0,
        reservesallowed => 0,
        opacitemholds => 'Y',
    })->store;
    $item1->withdrawn('1')->store;

    subtest 'While AllowHoldPolicyOverride is disabled' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference('AllowHoldPolicyOverride', 0);
        my $availability = Koha::Biblio::Availability::Hold->new({
            biblio => $biblio, patron => $patron})->in_intranet;
        my $i1_avail = Koha::Item::Availability::Hold->new({
            item => $item1, patron => $patron })->in_intranet;
        my $i2_avail = Koha::Item::Availability::Hold->new({
            item => $item2, patron => $patron })->in_intranet;
        ok(!$i1_avail->available, 'When I look at the first item of two in this'
           .' biblio, it is not available.');
        ok(!$i2_avail->available, 'When I look at the second item of two in this'
           .' biblio, it is not available.');
        ok(!$availability->available, 'Then, the biblio is not available.');
    };

    subtest 'Given AllowHoldPolicyOverride is enabled' => sub {
        plan tests => 5;

        t::lib::Mocks::mock_preference('AllowHoldPolicyOverride', 1);
        my $availability = Koha::Biblio::Availability::Hold->new({
            biblio => $biblio, patron => $patron})->in_intranet;
        my $i1_avail = Koha::Item::Availability::Hold->new({
            item => $item1, patron => $patron })->in_intranet;
        my $i2_avail = Koha::Item::Availability::Hold->new({
            item => $item2, patron => $patron })->in_intranet;
        ok($i1_avail->available, 'When I look at the first item of two in this'
           .' biblio, it is available.');
        is($i1_avail->confirm, 1, 'Then the first item availability seems to have'
           .' one reason to ask for confirmation.');
        ok($i2_avail->available, 'When I look at the second item of two in this'
           .' biblio, it is available.');
        is($i2_avail->confirm, 1, 'Then the second item availability seems to'
           .' have one reason to ask for confirmation.');
        ok($availability->available, 'Then, the biblio is available.');
    };

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

    my $availability = Koha::Biblio::Availability::Hold->new({biblio => $biblio, patron => $patron})->in_opac;
    my $item_availabilities = $availability->item_availabilities;
    ok(!Koha::Item::Availability::Hold->new({ item => $item1, patron => $patron })->in_opac->available,
       'When I look at the first item of two in this biblio, it is not available.');
    ok(Koha::Item::Availability::Hold->new({ item => $item2, patron => $patron })->in_opac->available,
       'When I look at the second item of two in this biblio, it seems to be available.');
    ok($availability->available, 'Then, the biblio is available.');
    is(@{$item_availabilities}, 1, 'There seems to be one available item in this biblio.');
    is($item_availabilities->[0]->item->itemnumber, $item2->itemnumber, 'Then the only available item'
       .'is the second item of this biblio.');
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

    my $availability = Koha::Biblio::Availability::Hold->new({biblio => $biblio, patron => $patron})->in_opac;
    my $item_availabilities = $availability->item_availabilities;
    ok(Koha::Item::Availability::Hold->new({ item => $item1, patron => $patron })->in_opac->available,
       'When I look at the first item of two in this biblio, it seems to be available.');
    ok(Koha::Item::Availability::Hold->new({ item => $item2, patron => $patron })->in_opac->available,
       'When I look at the second item of two in this biblio, it seems to be available.');
    ok($availability->available, 'Then, the biblio is available.');
    is(@{$item_availabilities}, 2, 'There seems to be two available items in this biblio.');
};

subtest 'Biblio with one item that and item-level holds forbidden' => \&t_itemlevelholdforbidden;
sub t_itemlevelholdforbidden {
    plan tests => 3;

    my $item = build_a_test_item();
    my $biblio = Koha::Biblios->find($item->biblionumber);

    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 10,
        reservesallowed => 10,
        opacitemholds => 'N',
    })->store;

    my $availability = Koha::Biblio::Availability::Hold->new({biblio => $biblio, patron => $patron})->in_opac;
    my $item_availabilities = $availability->item_availabilities;
    ok(!Koha::Item::Availability::Hold->new({ item => $item, patron => $patron })->in_opac->available,
       'When I look at the item in this biblio, it is not to be available.');
    ok($availability->available, 'But then, the biblio is available.');
    is(@{$item_availabilities}, 1, 'There seems to be one available item in this biblio.');
};

subtest 'Performance test' => \&t_performance_test;
sub t_performance_test {
    plan tests => 2;

    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);

    # add some items to biblio
    my $bib_iterations = 10;
    my $count = 10;
    for my $i (1..($count-1)) { # one already built earlier
        my $t_item = build_a_test_item($biblio, $biblioitem);
        $t_item->itype($item->itype)->store;
        $t_item->homebranch($item->homebranch)->store;
    }

    my @items = $biblio->items;
    is(@items, $count, "We will get availability for $count items.");
    my $res1 = timethis($bib_iterations, sub {
        Koha::Biblio::Availability::Hold->new({ biblio => $biblio, patron => $patron })->in_opac;
    });
    ok($res1, "Calculated search availability $bib_iterations times.");
};

$schema->storage->txn_rollback;

1;
