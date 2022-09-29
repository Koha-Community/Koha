#!/usr/bin/perl

# This file is part of Koha.
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

use Test::More tests => 27;
use t::lib::Dates;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::DateUtils qw( dt_from_string );

BEGIN {
    require_ok('Koha::Recall');
    require_ok('Koha::Recalls');
}

# Start transaction

my $database = Koha::Database->new();
my $schema = $database->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

# Setup test variables

my $item1 = $builder->build_sample_item();
my $biblio1 = $item1->biblio;
my $branch1 = $item1->holdingbranch;
my $itemtype1 = $item1->effective_itemtype;

my $item2 = $builder->build_sample_item();
my $biblio2 = $item2->biblio;
my $branch2 = $item2->holdingbranch;
my $itemtype2 = $item2->effective_itemtype;

my $category1 = $builder->build({ source => 'Category' })->{ categorycode };
my $patron1 = $builder->build_object({ class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch1 } });
my $patron2 = $builder->build_object({ class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch1 } });
t::lib::Mocks::mock_userenv({ patron => $patron1 });
my $old_recalls_count = Koha::Recalls->search({ completed => 1 })->count;

Koha::CirculationRules->set_rule({
    branchcode => undef,
    categorycode => undef,
    itemtype => undef,
    rule_name => 'recalls_allowed',
    rule_value => '10',
});

my $overdue_date = dt_from_string->subtract( days => 4 );
C4::Circulation::AddIssue( $patron2, $item1->barcode, $overdue_date );

my $recall1 = Koha::Recall->new({
    patron_id => $patron1->borrowernumber,
    created_date => dt_from_string,
    biblio_id => $biblio1->biblionumber,
    pickup_library_id => $branch1,
    status => 'requested',
    item_id => $item1->itemnumber,
    expiration_date => undef,
    item_level => 1
})->store;

is( $recall1->biblio->title, $biblio1->title, "Recall biblio relationship correctly linked" );
is( $recall1->item->homebranch, $item1->homebranch, "Recall item relationship correctly linked" );
is( $recall1->patron->categorycode, $category1, "Recall patron relationship correctly linked" );
is( $recall1->library->branchname, Koha::Libraries->find( $branch1 )->branchname, "Recall library relationship correctly linked" );
is( $recall1->checkout->itemnumber, $item1->itemnumber, "Recall checkout relationship correctly linked" );
ok( $recall1->requested, "Recall has been requested" );

is( $recall1->should_be_overdue, 1, "Correctly calculated that recall should be marked overdue" );
$recall1->set_overdue({ interface => 'COMMANDLINE' });
ok( $recall1->overdue, "Recall is overdue" );

$recall1->set_cancelled;
ok( $recall1->cancelled, "Recall is cancelled" );

my $recall2 = Koha::Recall->new({
    patron_id => $patron1->borrowernumber,
    created_date => dt_from_string,
    biblio_id => $biblio1->biblionumber,
    pickup_library_id => $branch1,
    item_id => $item1->itemnumber,
    expiration_date => undef,
    item_level => 1
})->store;

Koha::CirculationRules->set_rule({
    branchcode => undef,
    categorycode => undef,
    itemtype => undef,
    rule_name => 'recall_shelf_time',
    rule_value => undef,
});

t::lib::Mocks::mock_preference( 'RecallsMaxPickUpDelay', 7 );
my $expected_expirationdate = dt_from_string->add({ days => 7 });
my $expirationdate = $recall2->calc_expirationdate;
is( t::lib::Dates::compare( $expirationdate, $expected_expirationdate ), 0, "Expiration date calculated based on system preference as no circulation rules are set" );

Koha::CirculationRules->set_rule({
    branchcode => undef,
    categorycode => undef,
    itemtype => undef,
    rule_name => 'recall_shelf_time',
    rule_value => '3',
});
$expected_expirationdate = dt_from_string->add({ days => 3 });
$expirationdate = $recall2->calc_expirationdate;
is( t::lib::Dates::compare( $expirationdate, $expected_expirationdate ), 0, "Expiration date calculated based on circulation rules" );

$recall2->set_waiting({ expirationdate => $expirationdate });
is( $recall2->waiting, 1, "Recall is waiting" );

my $notice = C4::Message->find_last_message( $patron1->unblessed, 'PICKUP_RECALLED_ITEM', 'email' );
ok( defined $notice, "Patron was notified to pick up waiting recall" );

$recall2->set_expired({ interface => 'COMMANDLINE' });
is( $recall2->expired, 1, "Recall has expired" );

my $old_recalls_count_now = Koha::Recalls->search({ completed => 1 })->count;
is( $old_recalls_count_now, $old_recalls_count + 2, "Recalls have been flagged as old when cancelled or expired" );

my $recall3 = Koha::Recall->new({
    patron_id => $patron1->borrowernumber,
    created_date => dt_from_string,
    biblio_id => $biblio1->biblionumber,
    pickup_library_id => $branch1,
    item_id => $item1->itemnumber,
    expiration_date => undef,
    item_level => 1
})->store;

# test that recall gets T status
$recall3->start_transfer;
ok( $recall3->in_transit, "Recall is in transit" );

$recall3->revert_transfer;
ok( $recall3->requested, "Recall transfer has been cancelled and the status reverted" );
is( $recall3->item_id, $item1->itemnumber, "Item persists for item-level recall" );

# for testing purposes, pretend the item gets checked out
$recall3->set_fulfilled;
ok( $recall3->fulfilled, "Recall has been fulfilled" );

C4::Circulation::AddIssue( $patron2, $item1->barcode );
my $recall4 = Koha::Recall->new({
    patron_id => $patron1->borrowernumber,
    created_date => dt_from_string,
    biblio_id => $biblio1->biblionumber,
    pickup_library_id => $branch1,
    item_id => undef,
    expiration_date => undef,
    item_level => 0
})->store;

ok( !defined $recall4->item, "No relevant item returned for a biblio-level recall" );
is( $recall4->checkout->itemnumber, $item1->itemnumber, "Return most relevant checkout for a biblio-level recall");

$recall4->set_waiting({ item => $item1, expirationdate => $expirationdate });
is( $recall4->item_id, $item1->itemnumber, "Item has been allocated to biblio-level recall" );

$recall4->revert_waiting;
ok( !defined $recall4->item_id, "Itemnumber has been removed from biblio-level recall when reverting waiting status" );

$recall4->start_transfer({ item => $item1 });
is( $recall4->item_id, $item1->itemnumber, "Itemnumber saved to recall when item is transferred" );
$recall4->revert_transfer;
ok( !defined $recall4->item_id, "Itemnumber has been removed from biblio-level recall when reverting transfer status" );

$schema->storage->txn_rollback();
