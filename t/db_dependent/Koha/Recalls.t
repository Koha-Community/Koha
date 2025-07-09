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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 25;
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
my $schema   = $database->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

# Setup test variables

my $item1     = $builder->build_sample_item();
my $biblio1   = $item1->biblio;
my $branch1   = $item1->holdingbranch;
my $itemtype1 = $item1->effective_itemtype;
my $item2     = $builder->build_sample_item( { biblionumber => $biblio1->biblionumber } );
my $item3     = $builder->build_sample_item( { biblionumber => $biblio1->biblionumber } );
my $biblio2   = $item1->biblio;
my $branch2   = $item1->holdingbranch;
my $itemtype2 = $item1->effective_itemtype;

my $category1 = $builder->build( { source => 'Category' } )->{categorycode};
my $patron1   = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch1 } } );
my $patron2 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch2 } } );
my $patron3 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch1 } } );
my $patron4 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $category1, branchcode => $branch2 } } );
t::lib::Mocks::mock_userenv( { patron => $patron1 } );

Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => undef,
        rules        => {
            'issuelength'              => 7,
            'recall_due_date_interval' => undef,
            'recalls_allowed'          => 10,
        }
    }
);

C4::Circulation::AddIssue( $patron3, $item1->barcode );
C4::Circulation::AddIssue( $patron3, $item2->barcode );
C4::Circulation::AddIssue( $patron4, $item3->barcode );

C4::Members::Messaging::SetMessagingPreference(
    {
        borrowernumber          => $patron3->borrowernumber,
        message_attribute_id    => 13,                         # Recall_Requested
        message_transport_types => [qw( email sms )],
    }
);

my ( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => undef,
        biblio         => $biblio1,
        branchcode     => $branch1,
        item           => $item1,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
ok( !defined $recall, "Can't add a recall without specifying a patron" );

( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron1,
        biblio         => undef,
        branchcode     => $branch1,
        item           => $item1,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
ok( !defined $recall, "Can't add a recall without specifying a biblio" );

( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron1,
        biblio         => undef,
        branchcode     => $branch1,
        item           => $item1,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
ok( !defined $recall, "Can't add a recall without specifying a biblio" );

my $initial_checkout_due_date = Koha::Checkouts->find( $item2->checkout->issue_id )->date_due;
( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron2,
        biblio         => $biblio1,
        branchcode     => undef,
        item           => $item2,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
my $checkout_due_date_after_recall = Koha::Checkouts->find( $item2->checkout->issue_id )->date_due;
is( $recall->pickup_library_id, $branch2, "No pickup branch specified so patron branch used" );
is( $due_interval,              5,        "Recall due date interval defaults to 5 if not specified" );
ok(
    $checkout_due_date_after_recall lt $initial_checkout_due_date,
    "Checkout due date has been moved backwards"
);
$item2                          = Koha::Items->find( $item2->itemnumber );
$checkout_due_date_after_recall = dt_from_string($checkout_due_date_after_recall);
is(
    t::lib::Dates::compare( $checkout_due_date_after_recall->ymd(), $item2->onloan ), 0,
    "items.onloan is updated with adjusted due date"
);

Koha::CirculationRules->set_rule(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => undef,
        rule_name    => 'recall_due_date_interval',
        rule_value   => 3,
    }
);
( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron1,
        biblio         => $biblio1,
        branchcode     => undef,
        item           => $item1,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
is( $due_interval, 3, "Recall due date interval is based on circulation rules" );

( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron1,
        biblio         => $biblio1,
        branchcode     => $branch1,
        item           => undef,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
is( $recall->item_level, 0, "No item provided so recall not flagged as item-level" );

my $checkout_timestamp = dt_from_string( $recall->checkout->date_due );
my $expected_due_date  = dt_from_string->set(
    { hour => $checkout_timestamp->hour, minute => $checkout_timestamp->minute, second => $checkout_timestamp->second }
)->add( days => 3 );
is(
    t::lib::Dates::compare( $recall->checkout->date_due, $expected_due_date ), 0,
    "Checkout due date has correctly been extended by recall_due_date_interval days"
);
is( t::lib::Dates::compare( $due_date, $expected_due_date ), 0, "Due date correctly returned" );

Koha::CirculationRules->set_rule(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => undef,
        rule_name    => 'recall_due_date_interval',
        rule_value   => 10,
    }
);
$initial_checkout_due_date = Koha::Checkouts->find( $item3->checkout->issue_id )->date_due;
my $recall2;
( $recall2, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron2,
        biblio         => $biblio1,
        branchcode     => $branch1,
        item           => $item3,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
$checkout_due_date_after_recall = Koha::Checkouts->find( $item3->checkout->issue_id )->date_due;
is( $due_interval, 10, "Recall due date interval increased above checkout due" );
ok(
    $checkout_due_date_after_recall eq $initial_checkout_due_date,
    "Checkout due date has not been moved forward"
);

my $messages_count = Koha::Notice::Messages->search(
    { borrowernumber => $patron3->borrowernumber, letter_code => 'RETURN_RECALLED_ITEM' } )->count;
is( $messages_count, 6, "RETURN_RECALLED_ITEM notice successfully sent to checkout borrower" );

my $message = Koha::Recalls->move_recall;
is( $message, 'no recall_id provided', "Can't move a recall without specifying which recall" );

$message = Koha::Recalls->move_recall( { recall_id => $recall->recall_id } );
is( $message, 'no action provided', "No clear action to perform on recall" );
$message = Koha::Recalls->move_recall( { recall_id => $recall->recall_id, action => 'whatever' } );
is( $message, 'no action provided', "Legal action not provided to perform on recall" );

$recall->set_waiting( { item => $item1 } );
ok( $recall->waiting, "Recall is waiting" );
Koha::Recalls->move_recall( { recall_id => $recall->recall_id, action => 'revert' } );
$recall = Koha::Recalls->find( $recall->recall_id );
ok( $recall->requested, "Recall reverted to requested with move_recall" );

Koha::Recalls->move_recall( { recall_id => $recall->recall_id, action => 'cancel' } );
$recall = Koha::Recalls->find( $recall->recall_id );
ok( $recall->cancelled, "Recall cancelled with move_recall" );

( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
    {
        patron         => $patron1,
        biblio         => $biblio1,
        branchcode     => $branch1,
        item           => $item2,
        expirationdate => undef,
        interface      => 'COMMANDLINE',
    }
);
$message = Koha::Recalls->move_recall(
    { recall_id => $recall->recall_id, item => $item2, borrowernumber => $patron1->borrowernumber } );
$recall = Koha::Recalls->find( $recall->recall_id );
ok( $recall->fulfilled, "Recall fulfilled with move_recall" );

$schema->storage->txn_rollback();

subtest 'filter_by_current() and filter_by_finished() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $in_transit = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'in_transit' } } );
    my $overdue    = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'overdue' } } );
    my $requested  = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'requested' } } );
    my $waiting    = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'waiting' } } );
    my $cancelled  = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'cancelled' } } );
    my $expired    = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'expired' } } );
    my $fulfilled  = $builder->build_object( { class => 'Koha::Recalls', value => { status => 'fulfilled' } } );

    my $recalls = Koha::Recalls->search(
        {
            recall_id => [
                $in_transit->id,
                $overdue->id,
                $requested->id,
                $waiting->id,
                $cancelled->id,
                $expired->id,
                $fulfilled->id,
            ]
        },
        { order_by => ['recall_id'] }
    );

    is( $recalls->count, 7, 'Resultset count is correct' );

    my $current_recalls = $recalls->filter_by_current;
    is( $current_recalls->count, 4, 'Current recalls count correct' );

    is( $current_recalls->next->status, 'in_transit', 'Resultset correctly includes in_transit recall' );
    is( $current_recalls->next->status, 'overdue',    'Resultset correctly includes overdue recall' );
    is( $current_recalls->next->status, 'requested',  'Resultset correctly includes requested recall' );
    is( $current_recalls->next->status, 'waiting',    'Resultset correctly includes waiting recall' );

    my $finished_recalls = $recalls->filter_by_finished;
    is( $finished_recalls->count, 3, 'Finished recalls count correct' );

    is( $finished_recalls->next->status, 'cancelled', 'Resultset correctly includes cancelled recall' );
    is( $finished_recalls->next->status, 'expired',   'Resultset correctly includes expired recall' );
    is( $finished_recalls->next->status, 'fulfilled', 'Resultset correctly includes fulfilled recall' );

    $schema->storage->txn_rollback;
};
