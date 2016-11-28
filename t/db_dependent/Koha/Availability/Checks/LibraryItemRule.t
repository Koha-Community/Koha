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
use Test::More tests => 3;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use Koha::Database;
use Koha::Items;

use Koha::Availability::Checks::LibraryItemRule;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

subtest 'Given CircControl is configured as ItemHomeLibrary' => sub {
    plan tests => 3;

    subtest 'hold_not_allowed_by_library, item home library' => \&t_hold_not_allowed_item_home_library_item;
    sub t_hold_not_allowed_item_home_library_item {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

        my $item = build_a_test_item();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $item->homebranch, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from item home library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item
        });
        my $expecting = 'Koha::Exceptions::Hold::NotAllowedByLibrary';

        is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'CircControl system preference'
           .' is configured as ItemHomeLibrary.');
        is(ref($libitemcalc->hold_not_allowed_by_library), $expecting,
           "When I check if hold is allowed by library item rules, exception $expecting is given.");
    };

    subtest 'hold_not_allowed_by_library, patron library' => \&t_hold_not_allowed_item_home_library_patron;
    sub t_hold_not_allowed_item_home_library_patron  {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $patron->branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from patron library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron,
        });

        is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'CircControl system preference'
           .' is configured as ItemHomeLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };

    subtest 'hold_not_allowed_by_library, logged in library' => \&t_hold_not_allowed_item_home_library_logged_in;
    sub t_hold_not_allowed_item_home_library_logged_in {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

        my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
        C4::Context->_new_userenv('xxx');
        C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');
        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from logged in library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron
        });

        is(C4::Context->preference('CircControl'), 'ItemHomeLibrary', 'CircControl system preference'
           .' is configured as ItemHomeLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };
};

subtest 'Given CircControl is configured as PatronLibrary' => sub {
    plan tests => 3;

    subtest 'hold_not_allowed_by_library, item home library' => \&t_hold_not_allowed_patron_library_item;
    sub t_hold_not_allowed_patron_library_item {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $item->homebranch, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from item home library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron
        });

        is(C4::Context->preference('CircControl'), 'PatronLibrary', 'CircControl system preference'
           .' is configured as PatronLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };

    subtest 'hold_not_allowed_by_library, patron library' => \&t_hold_not_allowed_patron_library_patron;
    sub t_hold_not_allowed_patron_library_patron {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $patron->branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from patron library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron
        });
        my $expecting = 'Koha::Exceptions::Hold::NotAllowedByLibrary';

        is(C4::Context->preference('CircControl'), 'PatronLibrary', 'CircControl system preference'
           .' is configured as PatronLibrary.');
        is(ref($libitemcalc->hold_not_allowed_by_library), $expecting,
           "When I check if hold is allowed by library item rules, exception $expecting is given.");
    };

    subtest 'hold_not_allowed_by_library, logged in library' => \&t_hold_not_allowed_patron_library_logged_in;
    sub t_hold_not_allowed_patron_library_logged_in {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

        my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
        C4::Context->_new_userenv('xxx');
        C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');
        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from logged in library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron
        });

        is(C4::Context->preference('CircControl'), 'PatronLibrary', 'CircControl system preference'
           .' is configured as PatronLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };
};

subtest 'Given CircControl is configured as PickupLibrary' => sub {
    plan tests => 3;

    subtest 'hold_not_allowed_by_library, item home library' => \&t_hold_not_allowed_pickup_library_item;
    sub t_hold_not_allowed_pickup_library_item {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');

        my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
        C4::Context->_new_userenv('xxx');
        C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');
        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $item->homebranch, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from item home library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron
        });

        is(C4::Context->preference('CircControl'), 'PickupLibrary', 'CircControl system preference'
           .' is configured as PickupLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };

    subtest 'hold_not_allowed_by_library, patron library' => \&t_hold_not_allowed_pickup_library_patron;
    sub t_hold_not_allowed_pickup_library_patron  {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');

        my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
        C4::Context->_new_userenv('xxx');
        C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');
        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $patron->branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from patron library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron,
        });

        is(C4::Context->preference('CircControl'), 'PickupLibrary', 'CircControl system preference'
           .' is configured as PickupLibrary.');
        ok(!$libitemcalc->hold_not_allowed_by_library,
           'When I check if hold is allowed by library item rules, then no exception is given.');
    };
    subtest 'hold_not_allowed_by_library for patron library, CircControl = PickupLibrary' => \&t_hold_not_allowed_pickup_library_logged_in;
    sub t_hold_not_allowed_pickup_library_logged_in {
        plan tests => 3;

        set_default_system_preferences();
        set_default_circulation_rules();
        t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');

        my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
        C4::Context->_new_userenv('xxx');
        C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');

        my $item = build_a_test_item();
        my $patron = build_a_test_patron();
        ok($dbh->do(q{
            INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
            VALUES (?, ?, ?, ?)
        }, {}, $branchcode, $item->effective_itemtype, 0, 'homebranch'), 'There is a branch item'
           .' rule that says holds are not allowed from logged in library.');

        my $libitemcalc = Koha::Availability::Checks::LibraryItemRule->new({
            item => $item,
            patron => $patron,
        });
        my $expecting = 'Koha::Exceptions::Hold::NotAllowedByLibrary';

        is(C4::Context->preference('CircControl'), 'PickupLibrary', 'CircControl system preference'
           .' is configured as PickupLibrary.');
        is(ref($libitemcalc->hold_not_allowed_by_library), $expecting,
           "When I check if hold is allowed by library item rules, exception $expecting is given.");
    };
};

$schema->storage->txn_rollback;

1;
