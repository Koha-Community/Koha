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
use Test::More tests => 5;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Item::Availability::Hold;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'Given there are no hold rules blocking a hold from me' => \&t_hold_rules_nothing_blocking;
sub t_hold_rules_nothing_blocking {
    plan tests => 7;

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => $patron->branchcode,
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        opacitemholds => 'Y',
    })->store;

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;

    is($rule->reservesallowed, 1, 'As I look at hold rules, I match a rule says reservesallowed is 1.');
    is($rule->holds_per_record, 1, 'This rule also says holds_per_record is 1.');
    is($rule->opacitemholds, 'Y', 'This rule also says OPAC item holds are allowed.');
    ok($availability->available, 'When they request availability, then the item is available.');
    ok(!$availability->unavailable, 'Then there are no reasons for unavailability.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional availability notes.');
};

subtest 'Given zero holds are allowed' => sub {
    plan tests => 4;

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => '*',
        categorycode => '*',
        holds_per_record => 0,
        reservesallowed => 0,
        opacitemholds => 'Y',
    })->store;

    sub t_zero_holds_allowed {
        my ($item, $patron, $rule) = @_;

        my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
        my $expecting = 'Koha::Exceptions::Hold::ZeroHoldsAllowed';

        is($rule->reservesallowed, 0, 'As I study this rule, it says zero reserves are allowed.');
        ok(!$availability->available, 'When I request availability, then the item is not available.');
        ok(!$availability->confirm, 'Then there are nothing to be confirmed.');
        ok(!$availability->note, 'Then there are no additional notes.');
        is($availability->unavailable, 1, 'Then there is only one reason for unavailability.');
        is(ref($availability->unavailabilities->{$expecting}), $expecting,
            'Then there is an unavailability status indicating that holds are not allowed at all.');
    }
    subtest '...on any item type or in any library' => sub {
        plan tests => 6;
        \&t_zero_holds_allowed($item, $patron, $rule);
    };
    subtest '...in item home library' => sub {
        plan tests => 2;

        subtest '...while ReservesControlBranch = ItemHomeLibrary' => sub {
            plan tests => 7;

            t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
            $rule->branchcode($item->homebranch)->store;
            is($rule->branchcode, $item->homebranch, 'There is a hold rule matching item homebranch.');
            t_zero_holds_allowed($item, $patron, $rule);
            $rule->branchcode('*')->store;
            set_default_system_preferences();
        };
        subtest '...while ReservesControlBranch = PatronLibrary' => sub {
            plan tests => 7;

            t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
            $rule->branchcode($item->homebranch)->store;

            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;

            is($rule->branchcode, $item->homebranch, 'There is a hold rule matching item homebranch.');
            is($rule->reservesallowed, 0, 'As I study this rule, it says zero reserves are allowed.');
            is(C4::Context->preference('ReservesControlBranch'), 'PatronLibrary', 'However, system preference '
               .'ReserveControlBranch says we should use PatronLibrary for matching hold rules.');
            ok($availability->available, 'When I availability, then the item is available.');
            ok(!$availability->confirm, 'Then there are nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
            ok(!$availability->unavailable, 'Then there are no reasons for unavailability.');

            $rule->branchcode('*')->store;
        };
    };
    subtest '...in patron library' => sub {
        plan tests => 2;

        subtest '...while ReservesControlBranch = ItemHomeLibrary' => sub {
            plan tests => 7;

            t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
            $rule->branchcode($patron->branchcode)->store;

            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;

            is($rule->branchcode, $patron->branchcode, 'There is a hold rule matching patron branchcode.');
            is($rule->reservesallowed, 0, 'As I study this rule, it says zero reserves are allowed.');
            is(C4::Context->preference('ReservesControlBranch'), 'ItemHomeLibrary', 'However, system preference '
               .'ReserveControlBranch says we should use ItemHomeLibrary for matching hold rules.');
            ok($availability->available, 'When I availability, then the item is available.');
            ok(!$availability->confirm, 'Then there are nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
            ok(!$availability->unavailable, 'Then there are no reasons for unavailability.');

            $rule->branchcode('*')->store;
        };
        subtest '...while ReservesControlBranch = PatronLibrary' => sub {
            plan tests => 6;

            t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
            $rule->branchcode($patron->branchcode)->store;

            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
            my $expecting = 'Koha::Exceptions::Hold::ZeroHoldsAllowed';

            is($rule->branchcode, $patron->branchcode, 'There is a hold rule matching patron branchcode.');
            is($rule->reservesallowed, 0, 'As I study this rule, it says zero reserves are allowed.');
            ok(!$availability->available, 'When I request availability, then the item is not available.');
            ok(!$availability->confirm,  'Then there are nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
            is($availability->unavailable, 1, 'Then there is one reason for unavailability.');

            $rule->branchcode('*')->store;
        };
    };

    subtest '...on effective item type' => sub {
        plan tests => 7;
        $rule->itemtype($item->effective_itemtype)->store;
        is($rule->itemtype, $item->effective_itemtype, 'There is a hold rule matching effective itemtype.');
        t_zero_holds_allowed($item, $patron, $rule);
        $rule->itemtype('*')->store;
    };
};

subtest 'Given OPAC item holds are not allowed' => \&t_opac_item_hold_not_allowed;
sub t_opac_item_hold_not_allowed {
    plan tests => 6;

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => '*',
        categorycode => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        opacitemholds => 'N',
    })->store;

    is($rule->opacitemholds, 'N', 'As I look at issuing rules, I find out that OPAC item holds are not allowed.');

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::ItemLevelHoldNotAllowed';

    ok(!$availability->available, 'When I request availability, then the item is not available.');
    ok(!$availability->confirm, 'Then there are nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional notes.');
    is($availability->unavailable, 1, 'Then there is only one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating that item level holds are not allowed.');
};

subtest 'Given I have too many holds in my library' => \&t_too_many_holds_patron_library;
sub t_too_many_holds_patron_library {
    plan tests => 8;

    t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $item2 = build_a_test_item();
    $item->homebranch($item2->homebranch)->store;
    $item->itype($item2->itype)->store;
    my $reserve_id = add_item_level_hold($item2, $patron, $item2->homebranch);
    my $hold = Koha::Holds->find({ borrowernumber => $patron->borrowernumber });
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => $patron->branchcode,
        itemtype     => $item->effective_itemtype,
        categorycode => $patron->categorycode,
        holds_per_record => 3,
        reservesallowed => 1,
        opacitemholds => 'Y',
    })->store;
    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsReached';

    is(C4::Context->preference('ReservesControlBranch'), 'PatronLibrary', 'We will be checking my library\'s rules for holdability.');
    is($rule->reservesallowed, 1, 'As I look at circulation rules, I can see that only one reserve is allowed.');
    is($hold->reserve_id, $reserve_id, 'I have placed one hold already.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating that maximum holds have been reached.');

    my $ex = $availability->unavailabilities->{$expecting};
    is($ex->max_holds_allowed, 1, 'Then, from the status, I can see the maximum holds allowed.');
    is($ex->current_hold_count, 1, 'Then, from the status, I can see my current hold count.');
};

subtest 'Given I have too many holds in item\'s library' => \&t_too_many_holds_item_home_library ;
sub t_too_many_holds_item_home_library {
    plan tests => 8;

    t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $item2 = build_a_test_item();
    $item->homebranch($item2->homebranch)->store;
    $item->itype($item2->itype)->store;
    my $reserve_id = add_item_level_hold($item2, $patron, $item2->homebranch);
    my $hold = Koha::Holds->find({ borrowernumber => $patron->borrowernumber });
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => $item2->homebranch,
        itemtype     => $item2->effective_itemtype,
        categorycode => $patron->categorycode,
        holds_per_record => 3,
        reservesallowed => 1,
        opacitemholds => 'Y',
    })->store;
    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsReached';

    is(C4::Context->preference('ReservesControlBranch'), 'ItemHomeLibrary', 'We will be checking item\'s home library rules for holdability.');
    is($rule->reservesallowed, 1, 'As I look at circulation rules, I can see that only one reserve is allowed.');
    is($hold->reserve_id, $reserve_id, 'I have placed one hold already.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is only one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting,
        'Then there is an unavailability status indicating that maximum holds have been reached.');

    my $ex = $availability->unavailabilities->{$expecting};
    is($ex->max_holds_allowed, 1, 'Then, from the status, I can see the maximum holds allowed.');
    is($ex->current_hold_count, 1, 'Then, from the status, I can see my current hold count.');
};

$schema->storage->txn_rollback;

1;
