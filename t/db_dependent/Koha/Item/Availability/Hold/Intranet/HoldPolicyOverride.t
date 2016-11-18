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
use Test::More tests => 9;
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

t::lib::Mocks::mock_preference('AllowHoldPolicyOverride', 1);
t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 0);

# Create test item and patron, and add some reasons that will be need confirmation
my $item = build_a_test_item();
$item->set({
    barcode => '',
    damaged => 1,
    itemlost => 1,
    notforloan => 1,
    restricted => 1,
    withdrawn => 1,
})->store; # 6 reasons
my $patron = build_a_test_patron();
Koha::Account::Line->new({
    borrowernumber => $patron->borrowernumber,
    amountoutstanding => 999999999,
    accounttype => 'F',
})->store; # 1 reason

Koha::IssuingRules->search->delete;
my $rule = Koha::IssuingRule->new({
    branchcode   => $item->homebranch,
    itemtype     => $item->effective_itemtype,
    categorycode => '*',
    holds_per_record => 0,
    reservesallowed => 0,
})->store; # 1 reason
my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_intranet;
ok($availability->can('in_intranet'), 'Attempt to check availability in intranet'
   .' while considering AllowHoldPolicyOverride system preference.');
is(C4::Context->preference('AllowHoldPolicyOverride'), 1, 'Given librarians are '
   .'allowed to override hold policy restrictions.');
ok($availability->available, 'When librarian checks item availability for '
   .'patron, they see that the status is available.');
ok(!$availability->unavailable, 'There are no reasons for unavailability.');
is($availability->confirm, 8, 'There are 8 things to be confirmed.');

t::lib::Mocks::mock_preference('AllowHoldPolicyOverride', 0);
$availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_intranet;
is(C4::Context->preference('AllowHoldPolicyOverride'), 0, 'Changed setting - '
   .' librarians are no long allowed to override hold policy restrictions.');
ok(!$availability->available, 'When librarian checks item availability for '
   .'patron, they see that the it is NOT available.');
ok(!$availability->confirm, 'There are no to be confirmed.');
is($availability->unavailable, 8, 'There are 8 reasons for unavailability.');

$schema->storage->txn_rollback;

1;
