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
# Koha is distributed in the hope t1hat it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 10;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Item::Availability::Search;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'Given item is in a good state for availability' => \&t_ok_availability;
sub t_ok_availability {
    plan tests => 3;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;

    ok($availability->available, 'When I request availability, then the item is available.');
    ok(!$availability->confirm, 'Then nothing needs to be confirmed.');
    ok(!$availability->unavailable, 'Then there are no reasons to be unavailable.');
}

subtest 'Given item is damaged' => sub {
    plan tests => 2;

    subtest 'Given AllowHoldsOnDamagedItems is disabled' => \&t_damaged_item_allow_disabled;
    subtest 'Given AllowHoldsOnDamagedItems is enabled' => \&t_damaged_item_allow_enabled;
    sub t_damaged_item_allow_disabled {
        plan tests => 4;

        t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 0);

        my $patron = build_a_test_patron();
        my $item = build_a_test_item()->set({damaged=>1})->store;
        my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
        my $expecting = 'Koha::Exceptions::Item::Damaged';

        is($item->damaged, 1, 'When I look at the item, I see that it is damaged.');
        ok(!$availability->available, 'When I request availability, then the item is not available.');
        is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
        is(ref($availability->unavailabilities->{$expecting}), $expecting,
            'Then there is an unavailability status indicating damaged item.');
    };
    sub t_damaged_item_allow_enabled {
        plan tests => 4;

        t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 1);

        my $patron = build_a_test_patron();
        my $item = build_a_test_item()->set({damaged=>1})->store;
        my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;

        is($item->damaged, 1, 'When I look at the item, I see that it is damaged.');
        ok($availability->available, 'When I request availability, then the item is available.');
        ok(!$availability->unavailable, 'Then there are no statuses for unavailability.');
        ok(!$availability->confirm, 'Then there is no reason to have availability confirmed.');
    };
};

subtest 'Given item is lost' => \&t_lost;
sub t_lost {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({itemlost=>1})->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::Lost';

    is($item->itemlost, 1, 'When I try to look at the item, I find out that it is lost.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating lost item.');
};

subtest 'Given item is not for loan' => \&t_notforloan;
sub t_notforloan {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({notforloan=>1})->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::NotForLoan';

    is($item->notforloan, 1, 'When I look at the item, I see that it is not for loan.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating the item is not for loan.');
};

subtest 'Given item type is not for loan' => sub {

    subtest 'Given item-level_itypes is on (item-itemtype)' => \&t_itemlevel_itemtype_notforloan_item_level_itypes_on;
    subtest 'Given item-level_itypes is off (biblioitem-itemtype)' => \&t_itemlevel_itemtype_notforloan_item_level_itypes_off;
    sub t_itemlevel_itemtype_notforloan_item_level_itypes_on {
        plan tests => 5;

        t::lib::Mocks::mock_preference('item-level_itypes', 1);

        my $patron = build_a_test_patron();
        my $item = build_a_test_item();
        my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
        my $itemtype = Koha::ItemTypes->find($item->itype);
        $itemtype->set({notforloan=>1})->store;
        my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
        my $expecting = 'Koha::Exceptions::ItemType::NotForLoan';

        is(Koha::ItemTypes->find($biblioitem->itemtype)->notforloan, 0, 'Biblioitem itemtype is for loan.');
        is(Koha::ItemTypes->find($item->itype)->notforloan, 1, 'Item itemtype is not for loan.');
        ok(!$availability->available, 'When I request availability, then the item is not available.');
        is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
        is(ref($availability->unavailabilities->{$expecting}), $expecting,
            "Then there is an unavailability status indicating the itemtype is not forloan.");
    };
    sub t_itemlevel_itemtype_notforloan_item_level_itypes_off {
        plan tests => 5;

        t::lib::Mocks::mock_preference('item-level_itypes', 0);

        my $patron = build_a_test_patron();
        my $item = build_a_test_item();
        my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
        my $itemtype = Koha::ItemTypes->find($biblioitem->itemtype);
        $itemtype->set({notforloan=>1})->store;
        my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
        my $expecting = 'Koha::Exceptions::ItemType::NotForLoan';

        is(Koha::ItemTypes->find($biblioitem->itemtype)->notforloan, 1, 'Biblioitem itemtype is not for loan.');
        is(Koha::ItemTypes->find($item->itype)->notforloan, 0, 'Item itemtype is for loan.');
        ok(!$availability->available, 'When I request availability, then the item is not available.');
        is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
        is(ref($availability->unavailabilities->{$expecting}), $expecting,
            "Then there is an unavailability status indicating the itemtype is not forloan.");
    };
};

subtest 'Given item is ordered' => \&t_ordered;
sub t_ordered {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({notforloan=>-1})->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::NotForLoan';

    ok(!$availability->available, 'When I request availability, then the item is not available.');
    ok($availability->unavailable, 'Then there is one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then the unavailability status is indicating not for loan status.');
    is($availability->unavailabilities->{$expecting}->code, 'Ordered', 'Not for loan code says the item is ordered.')
};

subtest 'Given item is restricted' => \&t_restricted;
sub t_restricted {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({restricted=>1})->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::Restricted';

    is($item->restricted, 1, 'When I look at the item, I see that it is restricted.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating restricted item.');
};

subtest 'Given item has no barcode' => \&t_unknown_barcode;
sub t_unknown_barcode {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({barcode=>undef})->store;
    my $expecting = 'Koha::Exceptions::Item::UnknownBarcode';
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;

    is($item->barcode, undef, 'When I look at the item, we see that it has undefined barcode.');
    ok($availability->unavailable, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
       'Then there is an unavailability status indicating unknown barcode.');
};

subtest 'Given item is withdrawn' => \&t_withdrawn;
sub t_withdrawn {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item()->set({restricted=>1})->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::Restricted';

    is($item->restricted, 1, 'When I look at the item, I see that it is restricted.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating restricted item.');
};

subtest 'Held' => \&t_held;
sub t_held {
    plan tests => 8;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $reserve_id = add_item_level_hold($item, $patron, $item->homebranch);
    my $hold = Koha::Holds->find({ borrowernumber => $patron->borrowernumber });
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => $item->homebranch,
        itemtype     => $item->effective_itemtype,
        categorycode => $patron->categorycode,
        holds_per_record => 9001,
        reservesallowed => 9001,
        opacitemholds => 'Y',
    })->store;
    my $availability = Koha::Item::Availability::Search->new({item => $item})->in_opac;
    my $expecting = 'Koha::Exceptions::Item::Held';

    is($rule->reservesallowed, 9001, 'As I look at circulation rules, I can see that many reserves are allowed.');
    ok($reserve_id, 'I have placed a hold on an item.');
    is($hold->itemnumber, $item->itemnumber, 'The item I have hold for is the same item I will check availability for.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there is one additional note.');
    is($availability->unavailable, 1, 'Then there is only one unavailability reason.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an additional note indicating that I have already held this.');
};

$schema->storage->txn_rollback;

1;
