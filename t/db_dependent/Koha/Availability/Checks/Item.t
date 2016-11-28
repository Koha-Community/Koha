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
use Test::More tests => 14;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use C4::Members;

use Koha::Account::Lines;
use Koha::Biblioitems;
use Koha::Database;
use Koha::DateUtils;
use Koha::Items;
use Koha::Item::Transfers;

use Koha::Availability::Checks::Item;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'checked_out' => \&t_checked_out;
sub t_checked_out {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    issue_item($item, $patron);
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::CheckedOut';

    is(Koha::Checkouts->search({ itemnumber => $item->itemnumber })->count, 1,
       'I found out that item is checked out.');
    is(ref($itemcalc->checked_out), $expecting, "When I check item availability"
       ." calculation for checked_out, then exception $expecting is given.");
};

subtest 'damaged' => \&t_damaged;
sub t_damaged {
    plan tests => 2;

    t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 0);

    my $item = build_a_test_item()->set({damaged=>1})->store;
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Damaged';

    is($item->damaged, 1, 'When I look at the item, I see that it is damaged.');
    is(ref($itemcalc->damaged), $expecting, "When I check item availability"
       ." calculation for damaged, then exception $expecting is given.");
};


subtest 'from_another_branch, item from same branch than me'
=> \&t_from_another_library_same_branch;
sub t_from_another_library_same_branch {
    plan tests => 3;

    t::lib::Mocks::mock_preference('IndependentBranches', 1);
    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');

    my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode,
                             'Midway Public Library', undef, '', '');

    my $item = build_a_test_item();
    $item->homebranch($branchcode)->store;

    my $itemcalc = Koha::Availability::Checks::Item->new($item);

    is(C4::Context->userenv->{branch}, $item->homebranch,
       'Patron is from same branch as me.');
    ok(C4::Context->preference('IndependentBranches'),
       'IndependentBranches system preference is on.');
    ok(!$itemcalc->from_another_library, 'When I check if item is'
       .' from same branch as me, then no exception is given.');
}

subtest 'from_another_library, item from different branch than me'
=> \&t_from_another_library;
sub t_from_another_library {
    plan tests => 3;

    t::lib::Mocks::mock_preference('IndependentBranches', 1);
    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');

    my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
    my $branchcode2 = $builder->build({ source => 'Branch' })->{'branchcode'};

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode,
                             'Midway Public Library', undef, '', '');

    my $item = build_a_test_item();
    $item->homebranch($branchcode2)->store;

    my $itemcalc= Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::FromAnotherLibrary';

    isnt(C4::Context->userenv->{branch}, $item->homebranch, 'Item is not from'
         .' same branch as me.');
    ok(C4::Context->preference('IndependentBranches'), 'IndependentBranches'
       .' system preference is on.');
    is(ref($itemcalc->from_another_library), $expecting, 'When I check if item is'
       ." from same branch as me, then $expecting is given.");
}

subtest 'held' => \&t_held;
sub t_held {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    add_item_level_hold($item, $patron, $patron->branchcode);
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Held';

    is(Koha::Holds->search({biblionumber => $item->biblionumber})->count, 1,
       'I found out that item is held.');
    is(ref($itemcalc->held), $expecting, "When I check item availability "
       ."calculation for held, then exception $expecting is given.");
};

subtest 'held_by_patron' => \&t_held_by_patron;
sub t_held_by_patron {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    add_item_level_hold($item, $patron, $patron->branchcode);
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::AlreadyHeldForThisPatron';

    is(Koha::Holds->search({biblionumber => $item->biblionumber})->count, 1,
       'I found out that item is held.');
    is(ref($itemcalc->held_by_patron($patron)), $expecting, "When I check item "
       ."availability calculation for held, then exception $expecting is given.");
};

subtest 'lost' => \&t_lost;
sub t_lost {
    plan tests => 2;

    my $item = build_a_test_item()->set({itemlost=>1})->store;
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Lost';

    is($item->itemlost, 1, 'When I look at the item, I see that it is lost.');
    is(ref($itemcalc->lost), $expecting, "When I check availability calculation"
       ." for item lost, then exception $expecting is given.");
};

subtest 'notforloan' => \&t_notforloan;
sub t_notforloan {
    plan tests => 2;

    subtest 'Given item is notforloan > 0' => sub {
        plan tests => 2;

        my $item = build_a_test_item()->set({notforloan=>1})->store;
        my $itemcalc = Koha::Availability::Checks::Item->new($item);
        my $expecting = 'Koha::Exceptions::Item::NotForLoan';

        is($item->notforloan, 1, 'When I look at the item, I see that it is not'
           .' for loan.');
        is(ref($itemcalc->notforloan), $expecting,
            "When I look availability calculation for at item notforloan, then "
            ." exception $expecting is given.");
    };

    subtest 'Given item type is notforloan > 0' => sub {
        subtest 'Given item-level_itypes is on (item-itemtype)'
        => \&t_itemlevel_itemtype_notforloan_item_level_itypes_on;
        subtest 'Given item-level_itypes is off (biblioitem-itemtype)'
        => \&t_itemlevel_itemtype_notforloan_item_level_itypes_off;
        sub t_itemlevel_itemtype_notforloan_item_level_itypes_on {
            plan tests => 3;

            t::lib::Mocks::mock_preference('item-level_itypes', 1);

            my $item = build_a_test_item();
            my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
            my $itemtype = Koha::ItemTypes->find($item->itype);
            $itemtype->set({notforloan=>1})->store;
            my $itemcalc = Koha::Availability::Checks::Item->new($item);
            my $expecting = 'Koha::Exceptions::ItemType::NotForLoan';

            is(Koha::ItemTypes->find($biblioitem->itemtype)->notforloan, 0,
               'Biblioitem itemtype is for loan.');
            is(Koha::ItemTypes->find($item->itype)->notforloan, 1,
               'Item itemtype is not for loan.');
            is(ref($itemcalc->notforloan), $expecting, "When I look at "
               ."availability calculation for item notforloan, then "
               ."exception $expecting is given.");
        };
        sub t_itemlevel_itemtype_notforloan_item_level_itypes_off {
            plan tests => 3;

            t::lib::Mocks::mock_preference('item-level_itypes', 0);

            my $item = build_a_test_item();
            my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
            my $itemtype = Koha::ItemTypes->find($biblioitem->itemtype);
            $itemtype->set({notforloan=>1})->store;
            my $itemcalc = Koha::Availability::Checks::Item->new($item);
            my $expecting = 'Koha::Exceptions::ItemType::NotForLoan';

            is(Koha::ItemTypes->find($biblioitem->itemtype)->notforloan, 1,
               'Biblioitem itemtype is not for loan.');
            is(Koha::ItemTypes->find($item->itype)->notforloan, 0,
               'Item itemtype is for loan.');
            is(ref($itemcalc->notforloan), $expecting, "When I look at "
               ."availability calculation for item notforloan, then "
               ."exception $expecting is given.");
        };
    };
};

subtest 'onloan' => \&t_onloan;
sub t_onloan {
    plan tests => 2;

    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    issue_item($item, $patron);
    $item = Koha::Items->find($item->itemnumber);
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::CheckedOut';
    ok($item->onloan, 'When I look at the item, I see that it is '
       .'on loan.');
    is(ref($itemcalc->onloan), $expecting, "When I check availability "
       ."calculation for item onloan, then exception $expecting is given.");
};

subtest 'restricted' => \&t_restricted;
sub t_restricted {
    plan tests => 2;

    my $item = build_a_test_item()->set({restricted=>1})->store;
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Restricted';

    is($item->restricted, 1, 'When I look at the item, I see that it is '
       .'restricted.');
    is(ref($itemcalc->restricted), $expecting, "When I check availability "
       ."calculation for item restricted, then exception $expecting is given.");
};

subtest 'transfer' => \&t_transfer;
sub t_transfer {
    plan tests => 5;

    my $item = build_a_test_item();
    my $item2 = build_a_test_item();
    my $transfer = Koha::Item::Transfer->new({
        itemnumber => $item->itemnumber,
        datesent => '2000-12-12 12:12:12',
        frombranch => $item->homebranch,
        tobranch => $item2->homebranch,
        comments => 'Very transfer',
    })->store;

    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Transfer';
    ok($transfer, 'Item is in transfer.');
    is(ref($itemcalc->transfer), $expecting, "When I check availability"
       ." calculation for item transfer, then exception $expecting is given.");
    $transfer->datearrived('2001-12-12 12:12:12')->store;
    is(ref($itemcalc->transfer), '', "But after item has arrived, "
       ."no exception is given.");
    $itemcalc = Koha::Availability::Checks::Item->new($item2);
    ok(!Koha::Item::Transfers->find({ itemnumber => $item2->itemnumber}),
       'Another item is not in transfer.');
    ok(!$itemcalc->transfer, "When I check availability calculation for another"
       ." item transfer, then no exception is given.");
};

subtest 'transfer_limit' => \&t_transfer_limit;
sub t_transfer_limit {
    plan tests => 8;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $item = build_a_test_item();
    my $another_branch = Koha::Libraries->find(
            $builder->build({ source => 'Branch' })->{'branchcode'});
    my $third_branch = Koha::Libraries->find(
            $builder->build({ source => 'Branch' })->{'branchcode'});
    my $expecting = 'Koha::Exceptions::Item::CannotBeTransferred';

    is(C4::Circulation::CreateBranchTransferLimit(
        $another_branch->branchcode,
        $item->holdingbranch,
        $item->effective_itemtype
    ), 1, 'There is a branch transfer limit for itemtype from '
       .$item->holdingbranch.' to '.$another_branch->branchcode .'.');
    my $itemcalc = Koha::Availability::Checks::Item->new($item);

    is(ref($itemcalc->transfer_limit($another_branch->branchcode)), $expecting,
       "When I check availability calculation for transfer limit, then $expecting is given.");
    ok(!$itemcalc->transfer_limit($third_branch->branchcode),
       'However, item can be transferred from'
       .' a library to another library when there are no branch transfer limits.');

    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'ccode');
    ok(!$itemcalc->transfer_limit($another_branch->branchcode),
       'When we change limit to ccode, previous'
       .' transfer limit is not in action anymore.');
    is(C4::Circulation::CreateBranchTransferLimit(
        $another_branch->branchcode,
        $item->holdingbranch,
        $item->ccode
    ), 1, 'Then we added a branch transfer limit by ccode.');
    is(ref($itemcalc->transfer_limit($another_branch->branchcode)), $expecting,
       "When I check availability calculation for for transfer limit,"
       ." then $expecting is given.");

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 0);
    is(C4::Context->preference('UseBranchTransferLimits'), 0,
       'Then, we switched UseBranchTransferLimits off.');
    ok(!$itemcalc->transfer_limit($another_branch->branchcode),
       'Then no exception is given anymore.');
}

subtest 'unknown_barcode' => \&t_unknown_barcode;
sub t_unknown_barcode {
    plan tests => 2;

    my $item = build_a_test_item()->set({barcode=>undef})->store;
    my $expecting = 'Koha::Exceptions::Item::UnknownBarcode';
    my $itemcalc = Koha::Availability::Checks::Item->new($item);

    is($item->barcode, undef, 'When I look at the item, we see that it has '
       .'undefined barcode.');
    is(ref($itemcalc->unknown_barcode), $expecting,
       "When I check availability calculation for for unknown barcode, "
       ."then $expecting is given.");
};

subtest 'withdrawn' => \&t_withdrawn;
sub t_withdrawn {
    plan tests => 2;

    my $item = build_a_test_item()->set({withdrawn=>1})->store;
    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    my $expecting = 'Koha::Exceptions::Item::Withdrawn';

    is($item->withdrawn, 1, 'When I look at the item, I see that it is '
       .'withdrawn.');
    is(ref($itemcalc->withdrawn), $expecting, "When I check availability"
       ." calculation for item withdrawn, then exception $expecting is given.");
};

$schema->storage->txn_rollback;

1;
