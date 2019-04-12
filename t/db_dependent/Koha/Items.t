#!/usr/bin/perl

# Copyright 2016 Koha Development team
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
use Test::Exception;

use C4::Circulation;
use C4::Context;
use Koha::Item;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh     = C4::Context->dbh;

my $builder     = t::lib::TestBuilder->new;
my $library     = $builder->build( { source => 'Branch' } );
my $nb_of_items = Koha::Items->search->count;
my $biblio      = $builder->build_sample_biblio();
my $new_item_1   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});
my $new_item_2   = $builder->build_sample_item({
    biblionumber => $biblio->biblionumber,
    homebranch       => $library->{branchcode},
    holdingbranch    => $library->{branchcode},
});


t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

like( $new_item_1->itemnumber, qr|^\d+$|, 'Adding a new item should have set the itemnumber' );
is( Koha::Items->search->count, $nb_of_items + 2, 'The 2 items should have been added' );

my $retrieved_item_1 = Koha::Items->find( $new_item_1->itemnumber );
is( $retrieved_item_1->barcode, $new_item_1->barcode, 'Find a item by id should return the correct item' );

subtest 'get_transfer' => sub {
    plan tests => 3;

    my $transfer = $new_item_1->get_transfer();
    is( $transfer, undef, 'Koha::Item->get_transfer should return undef if the item is not in transit' );

    my $library_to = $builder->build( { source => 'Branch' } );

    C4::Circulation::transferbook( $library_to->{branchcode}, $new_item_1->barcode );

    $transfer = $new_item_1->get_transfer();
    is( ref($transfer), 'Koha::Item::Transfer', 'Koha::Item->get_transfer should return a Koha::Item::Transfers object' );

    is( $transfer->itemnumber, $new_item_1->itemnumber, 'Koha::Item->get_transfer should return a valid Koha::Item::Transfers object' );
};

subtest 'holds' => sub {
    plan tests => 5;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    $nb_of_items++;
    is($item->holds->count, 0, "Nothing returned if no holds");
    my $hold1 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'T' }});
    my $hold2 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});
    my $hold3 = $builder->build({ source => 'Reserve', value => { itemnumber=>$item->itemnumber, found => 'W' }});

    is($item->holds()->count,3,"Three holds found");
    is($item->holds({found => 'W'})->count,2,"Two waiting holds found");
    is_deeply($item->holds({found => 'T'})->next->unblessed,$hold1,"Found transit holds matches the hold");
    is($item->holds({found => undef})->count, 0,"Nothing returned if no matching holds");
};

subtest 'biblio' => sub {
    plan tests => 2;

    my $biblio = $retrieved_item_1->biblio;
    is( ref( $biblio ), 'Koha::Biblio', 'Koha::Item->biblio should return a Koha::Biblio' );
    is( $biblio->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblio should return the correct biblio' );
};

subtest 'biblioitem' => sub {
    plan tests => 2;

    my $biblioitem = $retrieved_item_1->biblioitem;
    is( ref( $biblioitem ), 'Koha::Biblioitem', 'Koha::Item->biblioitem should return a Koha::Biblioitem' );
    is( $biblioitem->biblionumber, $retrieved_item_1->biblionumber, 'Koha::Item->biblioitem should return the correct biblioitem' );
};

subtest 'checkout' => sub {
    plan tests => 5;
    my $item = Koha::Items->find( $new_item_1->itemnumber );
    # No checkout yet
    my $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no current checkout on this item' );

    # Add a checkout
    my $patron = $builder->build({ source => 'Borrower' });
    C4::Circulation::AddIssue( $patron, $item->barcode );
    $checkout = $retrieved_item_1->checkout;
    is( ref( $checkout ), 'Koha::Checkout', 'Koha::Item->checkout should return a Koha::Checkout' );
    is( $checkout->itemnumber, $item->itemnumber, 'Koha::Item->checkout should return the correct checkout' );
    is( $checkout->borrowernumber, $patron->{borrowernumber}, 'Koha::Item->checkout should return the correct checkout' );

    # Do the return
    C4::Circulation::AddReturn( $item->barcode );

    # There is no more checkout on this item, making sure it will not return old checkouts
    $checkout = $item->checkout;
    is( $checkout, undef, 'Koha::Item->checkout should return undef if there is no *current* checkout on this item' );
};

subtest 'can_be_transferred' => sub {
    plan tests => 5;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $biblio   = $builder->build_sample_biblio();
    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item  = $builder->build_sample_item({
        biblionumber     => $biblio->biblionumber,
        homebranch       => $library1->branchcode,
        holdingbranch    => $library1->branchcode,
    });
    $nb_of_items++;

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($item->can_be_transferred({ to => $library2 }),
       'Item can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 1, 'Given we have added a transfer limit,');
    is($item->can_be_transferred({ to => $library2 }), 0,
       'Item can no longer be transferred between libraries.');
    is($item->can_be_transferred({ to => $library2, from => $library1 }), 0,
       'We get the same result also if we pass the from-library parameter.');
};

$retrieved_item_1->delete;
is( Koha::Items->search->count, $nb_of_items + 1, 'Delete should have deleted the item' );

$schema->storage->txn_rollback;

subtest 'pickup_locations' => sub {
    plan tests => 33;

    $schema->storage->txn_begin;

    # Cleanup database
    Koha::Holds->search->delete;
    Koha::Patrons->search->delete;
    Koha::Items->search->delete;
    Koha::Libraries->search->delete;
    $dbh->do('DELETE FROM issues');
    $dbh->do('DELETE FROM issuingrules');
    $dbh->do(
        q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
        VALUES (?, ?, ?, ?)},
        {},
        '*', '*', '*', 25
    );
    $dbh->do('DELETE FROM branch_item_rules');
    $dbh->do('DELETE FROM default_branch_circ_rules');
    $dbh->do('DELETE FROM default_branch_item_rules');
    $dbh->do('DELETE FROM default_circ_rules');

    my $root1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );
    my $root2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );

    my $library1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0 } } );
    my $library4 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );

    my $group1_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library1->branchcode } } );
    my $group1_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library2->branchcode } } );

    my $group2_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library3->branchcode } } );
    my $group2_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library4->branchcode } } );

    my $biblioitem  = $builder->build( { source => 'Biblioitem' } );

    my $item1  = Koha::Item->new({
        biblionumber     => $biblioitem->{biblionumber},
        biblioitemnumber => $biblioitem->{biblioitemnumber},
        homebranch       => $library1->branchcode,
        holdingbranch    => $library2->branchcode,
        itype            => 'test',
        barcode          => "item1barcode",
    })->store;

    my $item3  = Koha::Item->new({
        biblionumber     => $biblioitem->{biblionumber},
        biblioitemnumber => $biblioitem->{biblioitemnumber},
        homebranch       => $library3->branchcode,
        holdingbranch    => $library4->branchcode,
        itype            => 'test',
        barcode          => "item3barcode",
    })->store;

    my $patron1 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library1->branchcode } } );
    my $patron4 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library4->branchcode } } );

    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');

    #Case 1: holdallowed any, hold_fulfillment_policy any
    $dbh->do(
        q{INSERT INTO default_circ_rules (holdallowed, hold_fulfillment_policy, returnbranch)
        VALUES (?,?,?)},
        {},
        2, 'any', 'any'
    );

    my @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    my @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    my @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    my @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == scalar(@pl_1_4) && scalar(@pl_1_1) == scalar(@pl_3_1) && scalar(@pl_1_1) == scalar(@pl_3_4), 'All combinations of patron/item renders the same number of locations');

    #Case 2: holdallowed homebranch, hold_fulfillment_policy any, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'any'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 3, 'Pickup location for patron 1 and item 1 renders all libraries that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations');

    #Case 3: holdallowed holdgroup, hold_fulfillment_policy any
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'any'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 3, 'Pickup location for patron 1 and item 1 renders all libraries that are pickup_locations');
    ok(scalar(@pl_3_4) == 3, 'Pickup location for patron 4 and item 3 renders all libraries that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0, 'Any other combination renders no locations');

    #Case 4: holdallowed any, hold_fulfillment_policy holdgroup
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'holdgroup'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2 && scalar(@pl_1_4) == 2, 'Pickup locations for item 1 renders all libraries in items\'s holdgroup that are pickup_locations');
    ok(scalar(@pl_3_1) == 1 && scalar(@pl_3_4) == 1, 'Pickup locations for item 3 renders all libraries in items\'s holdgroup that are pickup_locations');

    #Case 5: holdallowed homebranch, hold_fulfillment_policy holdgroup, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdgroup'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2, 'Pickup location for patron 1 and item 1 renders all libraries in holdgroup that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations');

    #Case 6: holdallowed holdgroup, hold_fulfillment_policy holdgroup
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'holdgroup'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 2, 'Pickup location for patron 1 and item 1 renders all libraries that are pickup_locations');
    ok(scalar(@pl_3_4) == 1, 'Pickup location for patron 4 and item 3 renders all libraries that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0, 'Any other combination renders no locations');

    #Case 7: holdallowed any, hold_fulfillment_policy homebranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'homebranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_1_4) == 1 && $pl_1_1[0]->{branchcode} eq $library1->branchcode && $pl_1_4[0]->{branchcode} eq $library1->id, 'Pickup locations for item 1 renders item\'s homelibrary');
    ok(scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations, because library3 is not pickup_location');

    #Case 8: holdallowed homebranch, hold_fulfillment_policy homebranch, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'homebranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && $pl_1_1[0]->{branchcode} eq $library1->branchcode, 'Pickup location for patron 1 and item 1 renders item\'s homebranch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations');

    #Case 9: holdallowed holdgroup, hold_fulfillment_policy homebranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'homebranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1, 'Pickup location for patron 1 and item 1 renders item\'s homebranch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations');

    #Case 10: holdallowed any, hold_fulfillment_policy holdingbranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        2, 'holdingbranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && scalar(@pl_1_4) == 1 && $pl_1_1[0]->{branchcode} eq $library2->branchcode && $pl_1_4[0]->{branchcode} eq $library2->branchcode, 'Pickup locations for item 1 renders item\'s holding branch');
    ok(scalar(@pl_3_1) == 1 && scalar(@pl_3_4) == 1 && $pl_3_1[0]->{branchcode} eq $library4->branchcode && $pl_3_4[0]->{branchcode} eq $library4->branchcode, 'Pickup locations for item 3 renders item\'s holding branch');


    #Case 11: holdallowed homebranch, hold_fulfillment_policy holdingbranch, HomeOrHoldingBranch 'homebranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdingbranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && $pl_1_1[0]->{branchcode} eq $library2->branchcode, 'Pickup location for patron 1 and item 1 renders item\'s holding branch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_3_4) == 0, 'Any other combination renders no locations');

    #Case 12: holdallowed holdgroup, hold_fulfillment_policy holdingbranch
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        3, 'holdingbranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_1_1) == 1 && $pl_1_1[0]->{branchcode} eq $library2->branchcode, 'Pickup location for patron 1 and item 1 renders item\'s holding branch');
    ok(scalar(@pl_3_4) == 1 && $pl_3_4[0]->{branchcode} eq $library4->branchcode, 'Pickup location for patron 4 and item 3 renders item\'s holding branch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0, 'Any other combination renders no locations');

    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'holdingbranch');

    #Case 13: holdallowed homebranch, hold_fulfillment_policy any, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'any'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_3_4) == 3, 'Pickup location for patron 4 and item 3 renders all libraries that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_1_1) == 0, 'Any other combination renders no locations');

    #Case 14: holdallowed homebranch, hold_fulfillment_policy holdgroup, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdgroup'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_3_4) == 1, 'Pickup location for patron 4 and item 3 renders all libraries in holdgroup that are pickup_locations');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_1_1) == 0, 'Any other combination renders no locations');

    #Case 15: holdallowed homebranch, hold_fulfillment_policy homebranch, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'homebranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    #ok(scalar(@pl_3_4) == 1 && $pl_3_4[0]->{branchcode} eq $library4->branchcode, 'Pickup location for patron 4 and item 3 renders item\'s holding branch');
    ok(scalar(@pl_3_4) == 0 && scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_1_1) == 0, 'Any combination of patron/item renders no locations');

    #Case 16: holdallowed homebranch, hold_fulfillment_policy holdingbranch, HomeOrHoldingBranch 'holdingbranch'
    $dbh->do(
        q{UPDATE default_circ_rules set holdallowed = ?, hold_fulfillment_policy = ?},
        {},
        1, 'holdingbranch'
    );

    @pl_1_1 = $item1->pickup_locations( { patron => $patron1 } );
    @pl_1_4 = $item1->pickup_locations( { patron => $patron4 } );
    @pl_3_1 = $item3->pickup_locations( { patron => $patron1 } );
    @pl_3_4 = $item3->pickup_locations( { patron => $patron4 } );

    ok(scalar(@pl_3_4) == 1 && $pl_3_4[0]->{branchcode} eq $library4->branchcode, 'Pickup location for patron 1 and item 1 renders item\'s holding branch');
    ok(scalar(@pl_1_4) == 0 && scalar(@pl_3_1) == 0 && scalar(@pl_1_1) == 0, 'Any other combination renders no locations');

    $schema->storage->txn_rollback;
};
