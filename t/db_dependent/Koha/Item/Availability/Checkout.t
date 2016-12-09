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
use Test::More tests => 10;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use C4::Biblio;
use C4::Circulation;
use C4::Reserves;

use Koha::Biblioitems;
use Koha::Checkouts;
use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Exceptions;
use Koha::Exceptions::Hold;
use Koha::Exceptions::Checkout;
use Koha::Exceptions::Item;
use Koha::Exceptions::ItemType;
use Koha::Exceptions::Patron;

use_ok('Koha::Item::Availability::Checkout');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

set_default_circulation_rules();
set_default_system_preferences();

my $builder = t::lib::TestBuilder->new;
my $library = $builder->build({ source => 'Branch' });

subtest 'Checkout lost item' => sub {
    plan tests => 12;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    $item->itemlost(1)->store;
    t::lib::Mocks::mock_preference('IssueLostItem', 'confirm');
    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    ok($item->itemlost, 'When I look at the item, I cannot see it because it'
       .' is lost.');
    is(C4::Context->preference('IssueLostItem'), 'confirm', 'Lost items can be'
       .' issued but require confirmation.');
    ok($availability->available, 'When I check item checkout availability,'
       .' I can see it is available.');
    is($availability->confirm, 1, 'However, there is one thing that needs'
       .' a confirmation.');
    my $expected = 'Koha::Exceptions::Item::Lost';
    is(ref($availability->confirmations->{$expected}), $expected, 'Then I am'
       .' told that lost item status needs to be confirmed.');
    t::lib::Mocks::mock_preference('IssueLostItem', 'nothing');
    is(C4::Context->preference('IssueLostItem'), 'nothing', 'Then I changed'
       .' the settings. Lost items can now be issued without confirmation.');
    ok($availability->in_intranet->available, 'When I again check item'
       .' availability for checkout, it seems to be available.');
    ok(!$availability->confirm, 'Then availability does not need confirmation.');
    t::lib::Mocks::mock_preference('IssueLostItem', 'alert');
    is(C4::Context->preference('IssueLostItem'), 'alert', 'Then I changed'
       .' the settings. Lost items can now be issued, but shows an additional note.');
    ok($availability->in_intranet->available, 'When I again check item'
       .' availability for checkout, it seems to be available.');
    is($availability->note, 1, 'Then availability has one additional note.');
    is(ref($availability->notes->{$expected}), $expected, 'Then I am told that'
       .' in an additional note that the item is lost.');
    $item->itemlost(0)->store;
};

subtest 'Checkout held item' => sub {
    plan tests => 6;

    my $patron = build_a_test_patron();
    my $patron2 = build_a_test_patron();
    my $item = build_a_test_item();
    my $biblio = C4::Biblio::GetBiblio($item->biblionumber);
    my $priority= C4::Reserves::CalculatePriority($item->biblionumber);
    my $reserve_id = add_biblio_level_hold($item, $patron2, $item->homebranch);

    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Item::Held';
    ok($reserve_id, 'There seems to be a hold on this item.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then it is available.');
    is($availability->confirm, 1, 'Then there is one thing to be confirmed.');
    ok($availability->confirmations->{$expected}, $expected);
    C4::Reserves::CancelReserve({ reserve_id => $reserve_id });
    ok($availability->in_intranet->available, 'Given I have cancelled the hold,'
       .' then the item is still available.');
    ok(!$availability->confirm, 'Then there is no need to make confirmations.');
};

subtest 'Checkout a checked out item (checked out for someone else)' => sub {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $patron2 = build_a_test_patron();
    my $item = build_a_test_item();
    my $checkout = issue_item($item, $patron2);

    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Item::CheckedOut';
    ok($checkout, 'This item seems to be checked out.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then it is available.');
    is($availability->confirm, 1, 'Then there is one thing to be confirmed.');
    ok($availability->confirmations->{$expected}, $expected);
};

subtest 'Checkout a checked out item (checked out for me)' => sub {
    plan tests => 10;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $checkout = issue_item($item, $patron);

    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Checkout::Renew';
    ok($checkout, 'This item seems to be checked out.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then it is available.');
    is($availability->confirm, 1, 'Then there is one thing to be confirmed.');
    ok($availability->confirmations->{$expected}, $expected);
    C4::Circulation::AddRenewal($patron->borrowernumber, $item->itemnumber);
    my ($renewcount, $renewsallowed, $renewsleft) =
    C4::Circulation::GetRenewCount($patron->borrowernumber, $item->itemnumber);
    is($renewcount, 1, 'Given I have now renewed this item once.');
    is($renewsallowed, 1, 'The maximum allowed amount of renewals is 1.');
    is($renewsleft, 0, 'This means I have zero renews left.');
    $expected = 'Koha::Exceptions::Checkout::NoMoreRenewals';
    ok(!$availability->in_intranet->available, 'When I check item availability again'
       .' for checkout, then it is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    ok($availability->unavailabilities->{$expected}, $expected);
};

subtest 'Checkout fee' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('RentalFeesCheckoutConfirmation', 1);
    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $itemtype = Koha::ItemTypes->find($item->effective_itemtype);
    $itemtype->rentalcharge('5')->store;
    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Checkout::Fee';
    is($itemtype->rentalcharge, 5, 'Item has a rental fee.');
    ok(C4::Context->preference('RentalFeesCheckoutConfirmation'),
       'Checkouts with rental fees must be confirmed.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then it is available.');
    is($availability->confirm, 1, 'Then there is one thing to be confirmed.');
    my $ret = $availability->confirmations->{$expected};
    is(ref($ret), $expected, "The thing to be confirmed is $expected.");
    is($ret->amount, '5.00', 'The exception defines a correct amount of 5 for rental charge.');
    t::lib::Mocks::mock_preference('RentalFeesCheckoutConfirmation', 0);
    ok(!C4::Context->preference('RentalFeesCheckoutConfirmation'),
       'Then I changed settings so that rental fees are no longer required to be confirmed.');
    ok(!$availability->in_intranet->confirm, 'Then there is nothing to be confirmed.');
};

subtest 'Overdues block' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference('OverduesBlockCirc', 'block');
    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $itemtype = Koha::ItemTypes->find($item->effective_itemtype);
    issue_item($item, $patron);
    my $issue = Koha::Checkouts->find({ borrowernumber => $patron->borrowernumber });
    $issue->date_due('2000-01-01 23:59:00')->store;
    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $accountline = Koha::Account::Lines->find({ borrowernumber => $patron->borrowernumber });
    my $expected = 'Koha::Exceptions::Patron::DebarredOverdue';
    ok(!$availability->available, 'When I check item availability for checkout,'
       .' then the item is not available.');
    is($availability->unavailable, 1, 'There is one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expected}), $expected,
       "Then the reason for unavailability is $expected.");
};

subtest 'Maximum checkouts reached' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('AllowTooManyOverride', 0);

    my $patron = build_a_test_patron();
    my $item1 = build_a_test_item();
    my $item2 = build_a_test_item();
    issue_item($item2, $patron);
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => '*',
        categorycode => '*',
        maxissueqty => 1,
    })->store;
    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item1,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Checkout::MaximumCheckoutsReached';
    is(C4::Context->preference("AllowTooManyOverride"), 0,
       'AllowTooManyOverride system preference is disabled.');
    ok(!$availability->available, 'When I check item availability for checkout,'
       .' then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expected}), $expected,
        "Then the reason for unavailability is $expected.");

    t::lib::Mocks::mock_preference('AllowTooManyOverride', 1);
    $availability = Koha::Item::Availability::Checkout->new({
        item => $item1,
        patron => $patron
    })->in_intranet;
    is(C4::Context->preference("AllowTooManyOverride"), 1,
       'AllowTooManyOverride system preference is now enabled.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then the item is available.');
    is($availability->confirm, 1, 'Then there is one reason to be confirmed.');
    is(ref($availability->confirmations->{$expected}), $expected,
        "Then the reason for confirmation is $expected.");
};

subtest 'AllowNotForLoanOverride' => sub {
    plan tests => 9;

    t::lib::Mocks::mock_preference('AllowNotForLoanOverride', 0);

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    $item->notforloan('1')->store;

    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Item::NotForLoan';
    is($item->notforloan, 1, 'Item is not for loan.');
    is(C4::Context->preference("AllowNotForLoanOverride"), 0,
       'AllowNotForLoanOverride system preference is disabled.');
    ok(!$availability->available, 'When I check item availability for checkout,'
       .' then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    is(ref($availability->unavailabilities->{$expected}), $expected,
        "Then the reason for unavailability is $expected.");
    t::lib::Mocks::mock_preference('AllowNotForLoanOverride', 1);
    $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    is(C4::Context->preference("AllowNotForLoanOverride"), 1,
       'AllowNotForLoanOverride system preference is now enabled.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then the item is available.');
    is($availability->confirm, 1, 'Then there is one reason to be confirmed.');
    is(ref($availability->confirmations->{$expected}), $expected,
        "Then the reason for confirmation is $expected.");
};

subtest 'High holds' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('decreaseLoanHighHolds', 1);
    t::lib::Mocks::mock_preference('decreaseLoanHighHoldsDuration', 3);
    t::lib::Mocks::mock_preference('decreaseLoanHighHoldsValue', 1);
    t::lib::Mocks::mock_preference('decreaseLoanHighHoldsControl', 'static');

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $rule = Koha::IssuingRules->get_effective_issuing_rule;
    my $threedays = output_pref({
        dt => dt_from_string()->add_duration(
        DateTime::Duration->new(days => 3))->set_hour(23)->set_minute(59)->truncate(to => 'minute'),
        dateformat => 'iso',
    }).":00";
    $rule->issuelength('14')->store;
    add_biblio_level_hold($item, $patron, $patron->branchcode);

    my $availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet;
    my $expected = 'Koha::Exceptions::Item::HighHolds';
    ok($availability->available, 'When I check item availability for checkout,'
       .' then the item is available.');
    my $hh = $availability->confirmations->{$expected};
    is(ref($hh), $expected, "Then a reason to be confirmed is $expected.");
    is($hh->num_holds, 1, 'The reason tells me there is one hold.');
    is($hh->duration, 3, 'The reason tells me the duration.');
    is($hh->returndate, $threedays, 'The reason tells me the returndate is in 3 days.');
    ok($availability = Koha::Item::Availability::Checkout->new({
        item => $item,
        patron => $patron
    })->in_intranet({ override_high_holds => 1 }),
       'Given a parameter override_high_holds, we can get the status as'
       .' an additional note instead of requiring a confirmation.');
    ok($availability->available, 'When I check item availability for checkout,'
       .' then the item is available.');
    $hh = $availability->notes->{$expected};
    is(ref($hh), $expected, "Then an additional note is $expected.");
};

$schema->storage->txn_rollback;

1;
