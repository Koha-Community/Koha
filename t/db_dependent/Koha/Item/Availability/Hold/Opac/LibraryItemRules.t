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

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Item::Availability::Hold;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'Given my library does not allow holds in branch item rules' => \&t_holdnotallowed_patronlibrary;
sub t_holdnotallowed_patronlibrary {
    plan tests => 7;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $patron->branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
       .' rule that says holds are not allowed from my library.');

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::NotAllowedByLibrary';

    is(C4::Context->preference('CircControl'), 'PatronLibrary', 'Koha is configured to use patron\'s library for checkout rules.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional notes.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
       .' note indicating library does not allow item to be held.');
};

subtest 'Given item\'s home library does not allow holds in branch item rules' => \&t_holdnotallowed_itemhomelibrary;
sub t_holdnotallowed_itemhomelibrary {
    plan tests => 7;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $item->homebranch, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
       .' rule that says item\'s library forbids holds.');

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::NotAllowedByLibrary';

    is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'Koha is configured to use item\'s library for checkout rules.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional notes.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
       .' note indicating library does not allow item to be held.');
};

subtest 'Given my library allows holds only from my library' => \&t_holdallowed_only_from_patronlibrary;
sub t_holdallowed_only_from_patronlibrary {
    plan tests => 8;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $patron->branchcode, $item->effective_itemtype, 1, 'homebranch'), 'There is a branch item'
       .' rule that says holds are allowed only from my library.');

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::NotAllowedFromOtherLibraries';

    is(C4::Context->preference('CircControl'), 'PatronLibrary', 'Koha is configured to use patron\'s library for checkout rules.');
    ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional notes.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
       .' status indicating library does not allow item to be held from other libraries.');
};

subtest 'Given item\'s library allows holds only its library' => \&t_holdallowed_only_from_itemhomelibrary;
sub t_holdallowed_only_from_itemhomelibrary {
    plan tests => 8;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $item->homebranch, $item->effective_itemtype, 1, 'homebranch'), 'There is a branch item'
       .' rule that says holds are allowed only in item home branch.');

    my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
    my $expecting = 'Koha::Exceptions::Hold::NotAllowedFromOtherLibraries';

    is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'Koha is configured to use item\'s library for checkout rules.');
    ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
    ok(!$availability->available, 'When I request availability, then the item is not available.');
    is($availability->unavailable, 1, 'Then there is one reason for unavailability.');
    ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
    ok(!$availability->note, 'Then there are no additional notes.');
    is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
       .' status indicating library does not allow item to be held from other libraries.');
};

subtest 'Given my library allows holds from any other libraries' => \&t_holdallowed_from_any_library_patronlibrary;
sub t_holdallowed_from_any_library_patronlibrary {
    plan tests => 3;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $patron->branchcode, $item->effective_itemtype, 2, 'homebranch'), 'There is a branch item'
       .' rule that says holds are allowed from any library.');

       subtest 'Given IndependentBranches is on and canreservefromotherbranches is off' => sub {
            plan tests => 9;

            t::lib::Mocks::mock_preference('canreservefromotherbranches', 0);
            t::lib::Mocks::mock_preference('IndependentBranches', 1);

            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
            my $expecting = 'Koha::Exceptions::Hold::NotAllowedFromOtherLibraries';

            is(C4::Context->preference('CircControl'), 'PatronLibrary', 'Koha is configured to use patron\'s library for checkout rules.');
            is(C4::Context->preference('canreservefromotherbranches'), 0, 'People cannot reserve from other libraries.');
            is(C4::Context->preference('IndependentBranches'), 1, 'Libraries are independent.');
            ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
            ok(!$availability->available, 'When I request availability, then the item is not available.');
            is($availability->unavailable, 1, 'Then there are no reasons for unavailability.');
            ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
            is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
               .' status indicating library does not allow item to be held from other libraries.');
       };

       subtest 'Given IndependentBranches is off and canreservefromotherbranches is on' => sub {
            plan tests => 8;

            t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
            t::lib::Mocks::mock_preference('IndependentBranches', 0);
            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;

            is(C4::Context->preference('CircControl'), 'PatronLibrary', 'Koha is configured to use patron\'s library for checkout rules.');
            is(C4::Context->preference('canreservefromotherbranches'), 1, 'People can reserve from other libraries.');
            is(C4::Context->preference('IndependentBranches'), 0, 'Libraries are not independent.');
            ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
            ok($availability->available, 'When I request availability, then the item is available.');
            ok(!$availability->unavailable, 'Then there are no reasons for unavailability.');
            ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
       };
};

subtest 'Given item\'s library allows holds from any other libraries' => \&t_holdallowed_from_any_library_itemhomelibrary;
sub t_holdallowed_from_any_library_itemhomelibrary {
    plan tests => 3;

    set_default_circulation_rules();
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    ok($dbh->do(q{
        INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
        VALUES (?, ?, ?, ?)
    }, {}, $item->homebranch, $item->effective_itemtype, 2, 'homebranch'), 'There is a branch item'
       .' rule in item\'s homebranch that says holds are allowed from any library.');

       subtest 'Given IndependentBranches is on and canreservefromotherbranches is off' => sub {
            plan tests => 9;

            t::lib::Mocks::mock_preference('canreservefromotherbranches', 0);
            t::lib::Mocks::mock_preference('IndependentBranches', 1);

            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;
            my $expecting = 'Koha::Exceptions::Hold::NotAllowedFromOtherLibraries';

            is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'Koha is configured to use item\'s library for checkout rules.');
            is(C4::Context->preference('canreservefromotherbranches'), 0, 'People cannot reserve from other libraries.');
            is(C4::Context->preference('IndependentBranches'), 1, 'Libraries are independent.');
            ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
            ok(!$availability->available, 'When I request availability, then the item is not available.');
            is($availability->unavailable, 1, 'Then there are no reasons for unavailability.');
            ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
            is(ref($availability->unavailabilities->{$expecting}), $expecting, 'Then there is an unavailability'
               .' status indicating library does not allow item to be held from other libraries.');
       };

       subtest 'Given IndependentBranches is off and canreservefromotherbranches is on' => sub {
            plan tests => 8;

            t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
            t::lib::Mocks::mock_preference('IndependentBranches', 0);
            my $availability = Koha::Item::Availability::Hold->new({item => $item, patron => $patron})->in_opac;

            is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'Koha is configured to use item\'s library for checkout rules.');
            is(C4::Context->preference('canreservefromotherbranches'), 1, 'People can reserve from other libraries.');
            is(C4::Context->preference('IndependentBranches'), 0, 'Libraries are not independent.');
            ok($item->homebranch ne $patron->branchcode, 'I am from different library than the item.');
            ok($availability->available, 'When I request availability, then the item is available.');
            ok(!$availability->unavailable, 'Then there are no reasons for unavailability.');
            ok(!$availability->confirm, 'Then there is nothing to be confirmed.');
            ok(!$availability->note, 'Then there are no additional notes.');
       };
};
