#!/usr/bin/env perl

# Copyright 2026 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 23;
use Test::Exception;
use Test::MockModule;
use Test::NoWarnings;
use Test::Warn;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Reserves    qw( AddReserve );
use Koha::Account;
use Koha::Checkins;
use Koha::Database;
use Koha::Old::Holds;
use Koha::Recall;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'item() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;

    my $THE_item = $checkin->item;
    is( ref($THE_item),        'Koha::Item',      'item() returns a Koha::Item' );
    is( $THE_item->itemnumber, $item->itemnumber, 'Correct item returned' );

    $item->delete;
    $checkin = Koha::Checkins->find( $checkin->checkin_id );
    is( $checkin, undef, 'Checkin deleted when item is deleted (CASCADE)' );

    $schema->storage->txn_rollback;
};

subtest 'user() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;

    my $THE_user = $checkin->user;
    is( ref($THE_user),            'Koha::Patron',        'user() returns a Koha::Patron' );
    is( $THE_user->borrowernumber, $user->borrowernumber, 'Correct user returned' );

    $user->delete;
    $checkin->discard_changes;
    is( $checkin->user, undef, 'user() returns undef after user deleted (SET NULL)' );

    $schema->storage->txn_rollback;
};

subtest 'library() tests' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;

    my $THE_library = $checkin->library;
    is( ref($THE_library),        'Koha::Library',      'library() returns a Koha::Library' );
    is( $THE_library->branchcode, $library->branchcode, 'Correct library returned' );

    $library->delete;
    $checkin = Koha::Checkins->find( $checkin->checkin_id );
    is( $checkin, undef, 'Checkin deleted when library is deleted (CASCADE)' );

    $schema->storage->txn_rollback;
};

subtest 'desk() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $desk    = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->branchcode } } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            desk_id    => $desk->desk_id,
        }
    )->store;

    my $THE_desk = $checkin->desk;
    is( ref($THE_desk),     'Koha::Desk',   'desk() returns a Koha::Desk' );
    is( $THE_desk->desk_id, $desk->desk_id, 'Correct desk returned' );

    # desk_id SET NULL on delete
    $desk->delete;
    $checkin->discard_changes;
    is( $checkin->desk, undef, 'desk() returns undef after desk deleted (SET NULL)' );

    $schema->storage->txn_rollback;
};

subtest 'checkout() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    my $issue = AddIssue( $patron, $item->barcode );
    AddReturn( $item->barcode, $library->branchcode );

    my $old_checkout = Koha::Old::Checkouts->find( $issue->issue_id );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $library->branchcode,
            checkout_id => $old_checkout->issue_id,
        }
    )->store;

    my $THE_checkout = $checkin->checkout;
    is( ref($THE_checkout),      'Koha::Old::Checkout',   'checkout() returns a Koha::Old::Checkout' );
    is( $THE_checkout->issue_id, $old_checkout->issue_id, 'Correct checkout returned' );

    # No checkout
    my $checkin2 = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;
    $checkin2->discard_changes;
    is( $checkin2->checkout, undef, 'checkout() returns undef when checkout_id is NULL' );

    $schema->storage->txn_rollback;
};

subtest 'transfer() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => { itemnumber => $item->itemnumber },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $library->branchcode,
            transfer_id => $transfer->branchtransfer_id,
        }
    )->store;

    my $THE_transfer = $checkin->transfer;
    is( ref($THE_transfer),               'Koha::Item::Transfer',       'transfer() returns a Koha::Item::Transfer' );
    is( $THE_transfer->branchtransfer_id, $transfer->branchtransfer_id, 'Correct transfer returned' );

    $schema->storage->txn_rollback;
};

subtest 'hold() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber   => $item->biblionumber,
                borrowernumber => $patron->borrowernumber,
            },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            hold_id    => $hold->reserve_id,
        }
    )->store;

    my $THE_hold = $checkin->hold;
    is( ref($THE_hold),        'Koha::Hold',      'hold() returns a Koha::Hold' );
    is( $THE_hold->reserve_id, $hold->reserve_id, 'Correct hold returned' );

    $schema->storage->txn_rollback;
};

subtest 'recall() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    my $recall = $builder->build_object(
        {
            class => 'Koha::Recalls',
            value => {
                biblio_id => $item->biblionumber,
                patron_id => $patron->borrowernumber,
            },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            recall_id  => $recall->id,
        }
    )->store;

    my $THE_recall = $checkin->recall;
    is( ref($THE_recall), 'Koha::Recall', 'recall() returns a Koha::Recall' );
    is( $THE_recall->id,  $recall->id,    'Correct recall returned' );

    $schema->storage->txn_rollback;
};

subtest 'restriction() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $restriction = $builder->build_object(
        {
            class => 'Koha::Patron::Restrictions',
            value => { borrowernumber => $user->borrowernumber },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id        => $item->itemnumber,
            user_id        => $user->borrowernumber,
            library_id     => $library->branchcode,
            restriction_id => $restriction->borrower_debarment_id,
        }
    )->store;

    my $THE_restriction = $checkin->restriction;
    is( ref($THE_restriction), 'Koha::Patron::Restriction', 'restriction() returns a Koha::Patron::Restriction' );
    is(
        $THE_restriction->borrower_debarment_id,
        $restriction->borrower_debarment_id,
        'Correct restriction returned'
    );

    $schema->storage->txn_rollback;
};

subtest 'claim() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $item    = $builder->build_sample_item;
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );

    my $claim = $builder->build_object(
        {
            class => 'Koha::Checkouts::ReturnClaims',
            value => { itemnumber => $item->itemnumber },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            claim_id   => $claim->id,
        }
    )->store;

    my $THE_claim = $checkin->claim;
    is( ref($THE_claim), 'Koha::Checkouts::ReturnClaim', 'claim() returns a Koha::Checkouts::ReturnClaim' );
    is( $THE_claim->id,  $claim->id,                     'Correct claim returned' );

    $schema->storage->txn_rollback;
};

subtest 'AddReturn creates a Koha::Checkin' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $user->borrowernumber } );

    my $issue = AddIssue( $patron, $item->barcode );

    my ( $doreturn, $messages, $old_issue, $borrower, $checkin ) = AddReturn( $item->barcode, $library->branchcode );

    ok( $doreturn, 'AddReturn succeeded' );
    is( ref($checkin),         'Koha::Checkin',       'Fifth return value is a Koha::Checkin' );
    is( $checkin->item_id,     $item->itemnumber,     'item_id set correctly' );
    is( $checkin->user_id,     $user->borrowernumber, 'user_id set from userenv' );
    is( $checkin->library_id,  $library->branchcode,  'library_id set correctly' );
    is( $checkin->checkout_id, $issue->issue_id,      'checkout_id links to old_issues' );
    is( $checkin->exempt_fine, 0,                     'exempt_fine defaults to false' );
    is( $checkin->local_use,   0,                     'local_use defaults to false' );
    ok( $checkin->checkin_id, 'checkin_id is set (persisted)' );

    $schema->storage->txn_rollback;
};

subtest 'AddReturn sets local_use for non-issued items' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $user->borrowernumber } );
    t::lib::Mocks::mock_preference( 'RecordLocalUseOnReturn', 1 );

    # Item is not checked out — should be recorded as local use
    my ( $doreturn, $messages, $issue, $borrower, $checkin ) = AddReturn( $item->barcode, $library->branchcode );

    is( ref($checkin),         'Koha::Checkin', 'Checkin created for non-issued item' );
    is( $checkin->local_use,   1,               'local_use set to true' );
    is( $checkin->checkout_id, undef,           'checkout_id is undef (not checked out)' );

    $schema->storage->txn_rollback;
};

subtest 'debits() and credits() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            library_id => $library->branchcode,
            local_use  => 0,
        }
    )->store;

    # No accountlines yet
    is( $checkin->debits->count,  0, 'No debits linked initially' );
    is( $checkin->credits->count, 0, 'No credits linked initially' );

    # Add debits
    my $account = Koha::Account->new( { patron_id => $patron->borrowernumber } );
    my $debit1  = $account->add_debit(
        {
            amount    => 5.00,
            type      => 'OVERDUE',
            item_id   => $item->itemnumber,
            interface => 'commandline',
        }
    );
    $debit1->checkin_id( $checkin->id )->store;

    my $debit2 = $account->add_debit(
        {
            amount    => 10.00,
            type      => 'LOST',
            item_id   => $item->itemnumber,
            interface => 'commandline',
        }
    );
    $debit2->checkin_id( $checkin->id )->store;

    # Add a credit
    my $credit = $account->add_credit(
        {
            amount    => 5.00,
            type      => 'LOST_FOUND',
            interface => 'commandline',
        }
    );
    $credit->checkin_id( $checkin->id )->store;

    # Test accessors
    my $debits = $checkin->debits;
    is( ref($debits),   'Koha::Account::Debits', 'debits() returns Koha::Account::Debits' );
    is( $debits->count, 2,                       'Two debits linked' );

    my $credits = $checkin->credits;
    is( ref($credits),   'Koha::Account::Credits', 'credits() returns Koha::Account::Credits' );
    is( $credits->count, 1,                        'One credit linked' );

    # Verify the right lines are in each set
    is( $debits->total_outstanding, 15.00, 'Debits total is correct' );

    $schema->storage->txn_rollback;
};

subtest 'is_latest() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item;
    my $other   = $builder->build_sample_item;

    my $build_checkin = sub {
        return Koha::Checkin->new( { item_id => $_[0]->itemnumber, library_id => $library->branchcode } )->store;
    };

    my $checkin = $build_checkin->($item);
    ok( $checkin->is_latest, 'The only checkin of the item is the latest' );

    $build_checkin->($other);
    ok( $checkin->is_latest, 'A checkin of another item does not matter' );

    my $new_checkin = $build_checkin->($item);
    ok( !$checkin->is_latest,    'Not the latest after the item is checked in again' );
    ok( $new_checkin->is_latest, 'The new checkin is the latest' );

    $schema->storage->txn_rollback;
};

subtest 'pending_actions(), action_tokens() and check_action_token() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $other   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item;

    my $checkin = Koha::Checkin->new( { item_id => $item->itemnumber, library_id => $library->branchcode } )->store;

    is_deeply( $checkin->pending_actions,                    [], 'No pending actions' );
    is_deeply( $checkin->action_tokens( { user => $user } ), {}, 'No action tokens' );

    $checkin->add_message( { message => 'needs_transfer', type => 'info' } );
    is_deeply( $checkin->pending_actions, ['transfer_confirmation'], 'A transfer can be requested' );

    my $hold     = $builder->build_object( { class => 'Koha::Holds' } );
    my $transfer = $builder->build_object( { class => 'Koha::Item::Transfers' } );
    my $recall   = $builder->build_object( { class => 'Koha::Recalls' } );
    $checkin->set( { hold_id => $hold->id, transfer_id => $transfer->id, recall_id => $recall->id } )->store;

    my @all_actions =
        qw( hold_confirmation hold_cancellation transfer_confirmation transfer_cancellation recall_confirmation );
    is_deeply( $checkin->pending_actions, \@all_actions, 'All the actions are pending' );

    throws_ok { $checkin->action_tokens }
    'Koha::Exceptions::MissingParameter',
        'action_tokens requires a user';

    my $tokens = $checkin->action_tokens( { user => $user } );
    is_deeply( [ sort keys %{$tokens} ], [ sort @all_actions ], 'A token for each pending action' );

    ok(
        $checkin->check_action_token(
            { action => 'hold_confirmation', user => $user, token => $tokens->{hold_confirmation} }
        ),
        'Valid token'
    );
    ok(
        !$checkin->check_action_token(
            { action => 'hold_confirmation', user => $user, token => $tokens->{hold_cancellation} }
        ),
        'Token for another action is not valid'
    );
    ok(
        !$checkin->check_action_token(
            { action => 'hold_confirmation', user => $other, token => $tokens->{hold_confirmation} }
        ),
        'Token for another user is not valid'
    );
    ok(
        !$checkin->check_action_token( { action => 'hold_confirmation', user => $user } ),
        'Missing token is not valid'
    );
    ok(
        !$checkin->check_action_token( { action => 'hold_confirmation', user => $user, token => 'invalid' } ),
        'Garbage token is not valid'
    );

    my $other_checkin =
        Koha::Checkin->new( { item_id => $item->itemnumber, library_id => $library->branchcode } )->store;
    ok(
        !$other_checkin->check_action_token(
            { action => 'hold_confirmation', user => $user, token => $tokens->{hold_confirmation} }
        ),
        'Token for another checkin is not valid'
    );

    my $jwt_mock = Test::MockModule->new('Mojo::JWT');
    $jwt_mock->mock( 'now', sub { time + Koha::Checkin::ACTION_TOKEN_EXPIRY_SECONDS + 60 } );
    ok(
        !$checkin->check_action_token(
            { action => 'hold_confirmation', user => $user, token => $tokens->{hold_confirmation} }
        ),
        'Expired token is not valid'
    );
    $jwt_mock->unmock('now');
    ok(
        $checkin->check_action_token(
            { action => 'hold_confirmation', user => $user, token => $tokens->{hold_confirmation} }
        ),
        'Token valid again once time is restored'
    );

    $schema->storage->txn_rollback;
};

subtest 'confirm_hold() tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user            = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron          = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item            = $builder->build_sample_item( { library => $checkin_library->branchcode } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $user->borrowernumber } );

    # Create a hold at the same library (no transfer needed)
    my $reserve_id = AddReserve(
        {
            branchcode     => $checkin_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    my $desk =
        $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $checkin_library->branchcode } } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            desk_id    => $desk->id,
            hold_id    => $reserve_id,
        }
    )->store;

    # Test confirm_hold at same library (no transfer)
    $checkin->confirm_hold;
    $checkin->discard_changes;

    my $hold = Koha::Holds->find($reserve_id);
    is( $hold->found,          'W',       'Hold set to waiting after confirm_hold' );
    is( $hold->desk_id,        $desk->id, 'Hold set to waiting at the checkin desk' );
    is( $checkin->transfer_id, undef,     'No transfer created when same library' );

    $schema->storage->txn_rollback;

    # Test confirm_hold with different pickup library (transfer needed)
    $schema->storage->txn_begin;

    $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    $user            = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron          = $builder->build_object( { class => 'Koha::Patrons' } );
    $item            = $builder->build_sample_item( { library => $checkin_library->branchcode } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $user->borrowernumber } );

    $reserve_id = AddReserve(
        {
            branchcode     => $pickup_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            hold_id    => $reserve_id,
        }
    )->store;

    $checkin->confirm_hold;
    $checkin->discard_changes;

    $hold = Koha::Holds->find($reserve_id);
    is( $hold->found, 'T', 'Hold set to in-transit when pickup differs' );
    ok( $checkin->transfer_id, 'Transfer ID set on checkin' );

    my $transfer = $checkin->transfer;
    is( $transfer->tobranch, $pickup_library->branchcode, 'Transfer destination is pickup library' );
    ok( $transfer->datesent, 'Transfer set in transit (datesent populated)' );

    # Test confirm_hold with no hold (throws)
    my $checkin_no_hold = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
        }
    )->store;

    throws_ok { $checkin_no_hold->confirm_hold }
    'Koha::Exceptions::MissingParameter',
        'confirm_hold throws MissingParameter when no hold';

    # Test confirm_hold when the item was checked out again in the meantime
    my $other_item = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    $reserve_id = AddReserve(
        {
            branchcode     => $pickup_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $other_item->biblionumber,
            itemnumber     => $other_item->itemnumber,
            priority       => 1,
        }
    );

    $checkin = Koha::Checkin->new(
        {
            item_id    => $other_item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            hold_id    => $reserve_id,
        }
    )->store;

    $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $other_item->itemnumber, branchcode => $checkin_library->branchcode }
        }
    );

    throws_ok { $checkin->confirm_hold }
    'Koha::Exceptions::Checkin::ItemCheckedOut',
        'confirm_hold throws ItemCheckedOut when the item is on loan';

    $checkin->discard_changes;
    $hold = Koha::Holds->find($reserve_id);
    is( $hold->found,              undef, 'Hold left pending' );
    is( $checkin->transfer_id,     undef, 'No transfer created' );
    is( $other_item->get_transfer, undef, 'Item has no transfer' );

    # Test confirm_hold when ModReserveAffect cannot find the hold
    my $no_loan_item = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    $reserve_id = AddReserve(
        {
            branchcode     => $checkin_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $no_loan_item->biblionumber,
            itemnumber     => $no_loan_item->itemnumber,
            priority       => 1,
        }
    );

    $checkin = Koha::Checkin->new(
        {
            item_id    => $no_loan_item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            hold_id    => $reserve_id,
        }
    )->store;

    my $checkin_mock = Test::MockModule->new('Koha::Checkin');
    $checkin_mock->mock( 'ModReserveAffect', sub { return; } );

    throws_ok { $checkin->confirm_hold }
    'Koha::Exceptions::Checkin::HoldNotFound',
        'confirm_hold throws HoldNotFound when ModReserveAffect does not find the hold';

    $checkin_mock->mock( 'ModReserveAffect', sub { return 0; } );

    throws_ok { $checkin->confirm_hold }
    'Koha::Exceptions::Checkin::ItemCheckedOut',
        'confirm_hold throws ItemCheckedOut when ModReserveAffect returns 0';

    $checkin_mock->unmock('ModReserveAffect');

    # Test confirm_hold when the hold was deleted in the meantime
    Koha::Holds->find($reserve_id)->delete;

    throws_ok { $checkin->confirm_hold }
    'Koha::Exceptions::Checkin::HoldNotFound',
        'confirm_hold throws HoldNotFound when the hold no longer exists';
    is( Koha::Holds->search( { itemnumber => $no_loan_item->itemnumber } )->count, 0, 'No hold set aside' );

    # Changes are rolled back if the transfer cannot be sent
    my $atomic_item = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    $reserve_id = AddReserve(
        {
            branchcode     => $pickup_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $atomic_item->biblionumber,
            itemnumber     => $atomic_item->itemnumber,
            priority       => 1,
        }
    );

    $checkin = Koha::Checkin->new(
        {
            item_id    => $atomic_item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            hold_id    => $reserve_id,
        }
    )->store;

    my $transfer_mock = Test::MockModule->new('Koha::Item::Transfer');
    $transfer_mock->mock( 'transit', sub { die "Transit failed\n" } );

    throws_ok { $checkin->confirm_hold } qr/Transit failed/, 'confirm_hold dies when the transfer cannot be sent';

    $transfer_mock->unmock('transit');

    $hold = Koha::Holds->find($reserve_id);
    is( $hold->found,                                      undef, 'Hold not set in transit nor waiting' );
    is( $hold->priority,                                   1,     'Hold priority unchanged' );
    is( Koha::Checkins->find( $checkin->id )->transfer_id, undef, 'No transfer linked to the checkin' );
    is( $atomic_item->get_transfer,                        undef, 'No transfer created for the item' );

    $schema->storage->txn_rollback;
};

subtest 'cancel_hold() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $user->borrowernumber } );

    # Test cancel without reason (no letter attempted)
    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            hold_id    => $reserve_id,
        }
    )->store;

    $checkin->cancel_hold;
    $checkin->discard_changes;

    is( $checkin->hold_id, undef, 'hold_id cleared after cancel_hold (no reason)' );
    my $old_hold = Koha::Old::Holds->find($reserve_id);
    ok( $old_hold, 'Hold moved to old_reserves (no reason)' );
    is( $old_hold->cancellation_reason, undef, 'No cancellation reason stored' );

    # Test cancel with reason (letter warning expected)
    my $reserve_id2 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    my $checkin2 = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
            hold_id    => $reserve_id2,
        }
    )->store;

    warning_like { $checkin2->cancel_hold( { reason => 'PATRON_REQUEST' } ) }
    qr/HOLD_CANCELLATION/,
        'Warning about missing letter template when cancelling with reason';

    $checkin2->discard_changes;
    is( $checkin2->hold_id, undef, 'hold_id cleared after cancel_hold (with reason)' );
    my $old_hold2 = Koha::Old::Holds->find($reserve_id2);
    ok( $old_hold2, 'Hold moved to old_reserves (with reason)' );
    is( $old_hold2->cancellation_reason, 'PATRON_REQUEST', 'Cancellation reason stored' );

    # Test cancel_hold with no hold (throws)
    my $checkin_no_hold = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;

    throws_ok { $checkin_no_hold->cancel_hold }
    'Koha::Exceptions::MissingParameter',
        'cancel_hold throws MissingParameter when no hold';

    # Cancellation fee (ExpireReservesMaxPickUpDelayCharge) is charged unless forgiven
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 5 );

    my $fee_patron            = $builder->build_object( { class => 'Koha::Patrons' } );
    my $new_checkin_with_hold = sub {
        my $hold_id = AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $fee_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => $item->itemnumber,
                priority       => 1,
            }
        );
        return Koha::Checkin->new(
            {
                item_id    => $item->itemnumber,
                user_id    => $user->borrowernumber,
                library_id => $library->branchcode,
                hold_id    => $hold_id,
            }
        )->store;
    };

    $new_checkin_with_hold->()->cancel_hold( { forgive_hold_fees => 1 } );
    is( $fee_patron->account->balance, 0, 'No cancellation fee charged when forgive_hold_fees is passed' );

    $new_checkin_with_hold->()->cancel_hold;
    is( $fee_patron->account->balance + 0, 5, 'Cancellation fee charged when forgive_hold_fees is not passed' );

    $schema->storage->txn_rollback;
};

subtest 'confirm_transfer() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $from_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to_library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item         = $builder->build_sample_item( { library => $from_library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $from_library->branchcode, borrowernumber => $user->borrowernumber } );

    # Create a pending transfer (not yet in transit)
    my $transfer = $item->request_transfer( { to => $to_library, reason => 'Manual' } );
    ok( !$transfer->datesent, 'Transfer not yet in transit' );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $from_library->branchcode,
            transfer_id => $transfer->id,
        }
    )->store;

    # Confirm the transfer
    $checkin->confirm_transfer;

    $transfer->discard_changes;
    ok( $transfer->datesent, 'Transfer set in transit after confirm_transfer' );

    # Calling again on already-sent transfer is a no-op
    my $datesent = $transfer->datesent;
    $checkin->confirm_transfer;
    $transfer->discard_changes;
    is( $transfer->datesent, $datesent, 'confirm_transfer is idempotent on already-sent transfer' );

    # Test confirm_transfer with no transfer (throws)
    my $checkin_no_transfer = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $from_library->branchcode,
        }
    )->store;

    throws_ok { $checkin_no_transfer->confirm_transfer }
    'Koha::Exceptions::MissingParameter',
        'confirm_transfer throws MissingParameter when no transfer';

    # Test that confirm_transfer returns self for chaining
    my $result = $checkin->confirm_transfer;
    is( ref($result), 'Koha::Checkin', 'confirm_transfer returns $self for chaining' );

    # No transfer yet (AutomaticItemReturn disabled): request one to the passed library
    my $item_no_transfer       = $builder->build_sample_item( { library => $from_library->branchcode } );
    my $checkin_needs_transfer = Koha::Checkin->new(
        {
            item_id    => $item_no_transfer->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $from_library->branchcode,
        }
    )->store;

    $checkin_needs_transfer->confirm_transfer( { to_library_id => $to_library->branchcode, reason => 'ReturnToHome' } );

    my $new_transfer = $checkin_needs_transfer->transfer;
    ok( $new_transfer, 'A transfer was requested and linked to the checkin' );
    is( $new_transfer->tobranch, $to_library->branchcode, 'Transfer goes to the passed library' );
    is( $new_transfer->reason,   'ReturnToHome',          'Transfer has the passed reason' );
    ok( $new_transfer->datesent, 'Transfer set in transit' );

    # The reason defaults to Manual
    my $item_manual    = $builder->build_sample_item( { library => $from_library->branchcode } );
    my $checkin_manual = Koha::Checkin->new(
        {
            item_id    => $item_manual->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $from_library->branchcode,
        }
    )->store;
    $checkin_manual->confirm_transfer( { to_library_id => $to_library->branchcode } );
    is( $checkin_manual->transfer->reason, 'Manual', 'Transfer reason defaults to Manual' );

    # Changes are rolled back if the transfer cannot be sent
    my $item_atomic    = $builder->build_sample_item( { library => $from_library->branchcode } );
    my $checkin_atomic = Koha::Checkin->new(
        {
            item_id    => $item_atomic->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $from_library->branchcode,
        }
    )->store;

    my $transfer_mock = Test::MockModule->new('Koha::Item::Transfer');
    $transfer_mock->mock( 'transit', sub { die "Transit failed\n" } );

    throws_ok { $checkin_atomic->confirm_transfer( { to_library_id => $to_library->branchcode } ) }
    qr/Transit failed/, 'confirm_transfer dies when the transfer cannot be sent';

    $transfer_mock->unmock('transit');

    is( Koha::Checkins->find( $checkin_atomic->id )->transfer_id, undef, 'No transfer linked to the checkin' );
    is( $item_atomic->get_transfer,                               undef, 'No transfer created for the item' );

    # A transfer that has already arrived cannot be confirmed
    my $arrived = $item->request_transfer( { to => $to_library, reason => q{Manual}, enqueue => 1 } );
    $arrived->set( { datesent => \q{NOW()}, datearrived => \q{NOW()} } )->store;
    my $checkin_arrived = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $from_library->branchcode,
            transfer_id => $arrived->id,
        }
    )->store;

    throws_ok { $checkin_arrived->confirm_transfer }
    q{Koha::Exceptions::Checkin::TransferFinished},
        q{confirm_transfer throws TransferFinished when the transfer has arrived};

    $schema->storage->txn_rollback;
};

subtest 'cancel_transfer() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $from_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to_library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item         = $builder->build_sample_item( { library => $from_library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $from_library->branchcode, borrowernumber => $user->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 0 );

    # Create a transfer and set it in transit
    my $transfer = $item->request_transfer( { to => $to_library, reason => 'Manual' } );
    $transfer->transit;
    ok( $transfer->datesent, 'Transfer is in transit' );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $from_library->branchcode,
            transfer_id => $transfer->id,
        }
    )->store;

    # Cancel the transfer
    $checkin->cancel_transfer;
    $checkin->discard_changes;

    is( $checkin->transfer_id, undef, 'transfer_id cleared after cancel_transfer' );

    $transfer->discard_changes;
    ok( $transfer->datecancelled, 'Transfer has datecancelled set' );
    is( $transfer->cancellation_reason, 'Manual', 'Cancellation reason is Manual' );

    # Test cancel_transfer with no transfer (throws)
    my $checkin_no_transfer = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $from_library->branchcode,
        }
    )->store;

    throws_ok { $checkin_no_transfer->cancel_transfer }
    'Koha::Exceptions::MissingParameter',
        'cancel_transfer throws MissingParameter when no transfer';

    # A transfer that has already been cancelled cannot be cancelled again
    my $checkin_cancelled = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $from_library->branchcode,
            transfer_id => $transfer->id,
        }
    )->store;

    throws_ok { $checkin_cancelled->cancel_transfer }
    q{Koha::Exceptions::Checkin::TransferFinished},
        q{cancel_transfer throws TransferFinished when the transfer was cancelled};

    $schema->storage->txn_rollback;
};

subtest 'confirm_recall() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user            = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron          = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item            = $builder->build_sample_item( { library => $checkin_library->branchcode } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $user->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );

    # Test confirm_recall at same library (set to waiting)
    my $recall = Koha::Recall->new(
        {
            patron_id         => $patron->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $item->biblionumber,
            pickup_library_id => $checkin_library->branchcode,
            status            => 'requested',
            item_id           => $item->itemnumber,
            expiration_date   => undef,
            item_level        => 1,
        }
    )->store;

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            recall_id  => $recall->id,
        }
    )->store;

    $checkin->confirm_recall;

    $recall->discard_changes;
    ok( $recall->waiting,         'Recall set to waiting when same library' );
    ok( $recall->expiration_date, 'Expiration date set' );

    $schema->storage->txn_rollback;

    # Test confirm_recall with different pickup library (start transfer)
    $schema->storage->txn_begin;

    $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    $user            = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron          = $builder->build_object( { class => 'Koha::Patrons' } );
    $item            = $builder->build_sample_item( { library => $checkin_library->branchcode } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $user->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );

    $recall = Koha::Recall->new(
        {
            patron_id         => $patron->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $item->biblionumber,
            pickup_library_id => $pickup_library->branchcode,
            status            => 'requested',
            item_id           => $item->itemnumber,
            expiration_date   => undef,
            item_level        => 1,
        }
    )->store;

    $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            recall_id  => $recall->id,
        }
    )->store;

    $checkin->confirm_recall;

    $recall->discard_changes;
    ok( $recall->in_transit, 'Recall set to in_transit when pickup differs' );
    is( $recall->item_id, $item->itemnumber, 'Item assigned to recall' );

    # Idempotent - calling again doesn't fail
    $checkin->confirm_recall;
    $recall->discard_changes;
    ok( $recall->in_transit, 'confirm_recall is idempotent on in-transit recall' );

    # Test confirm_recall with no recall (throws)
    my $checkin_no_recall = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
        }
    )->store;

    throws_ok { $checkin_no_recall->confirm_recall }
    'Koha::Exceptions::MissingParameter',
        'confirm_recall throws MissingParameter when no recall';

    # The transfer cannot be started (the item is already at the pickup library)
    my $at_pickup          = $builder->build_sample_item( { library => $pickup_library->branchcode } );
    my $recall_no_transfer = Koha::Recall->new(
        {
            patron_id         => $patron->borrowernumber,
            created_date      => \q{NOW()},
            biblio_id         => $at_pickup->biblionumber,
            pickup_library_id => $pickup_library->branchcode,
            status            => q{requested},
            item_id           => $at_pickup->itemnumber,
            expiration_date   => undef,
            item_level        => 1,
        }
    )->store;
    my $checkin_no_transfer = Koha::Checkin->new(
        {
            item_id    => $at_pickup->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $checkin_library->branchcode,
            recall_id  => $recall_no_transfer->id,
        }
    )->store;

    throws_ok { $checkin_no_transfer->confirm_recall }
    q{Koha::Exceptions::Checkin::TransferNotStarted},
        q{confirm_recall throws TransferNotStarted when the transfer cannot be started};

    $recall_no_transfer->discard_changes;
    is( $recall_no_transfer->status, q{requested}, q{The recall is left unchanged} );

    $schema->storage->txn_rollback;
};

subtest 'replace_wrong_transfer() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $from_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to_library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $wrong_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user          = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item          = $builder->build_sample_item( { library => $from_library->branchcode } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $wrong_library->branchcode, borrowernumber => $user->borrowernumber } );

    my $checkin = Koha::Checkin->new(
        {
            item_id    => $item->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $wrong_library->branchcode,
        }
    )->store;

    # No transfer, nothing to do
    $checkin->replace_wrong_transfer;
    $checkin->discard_changes;
    is( $checkin->transfer_id, undef, 'No transfer_id set when the item has no transfer' );

    my $old_transfer = $item->request_transfer( { to => $to_library, reason => 'Manual' } );
    $old_transfer->transit;

    # The item shows up at the wrong library
    $item->holdingbranch( $wrong_library->branchcode )->store;

    $checkin->replace_wrong_transfer;
    $checkin->discard_changes;

    $old_transfer->discard_changes;
    ok( $old_transfer->datecancelled, 'Original transfer cancelled' );
    is( $old_transfer->cancellation_reason, 'WrongTransfer', 'Original transfer cancelled as WrongTransfer' );

    my $new_transfer = $checkin->transfer;
    isnt( $new_transfer->id, $old_transfer->id, 'A new transfer is linked to the checkin' );
    is( $new_transfer->frombranch, $wrong_library->branchcode, 'New transfer starts at the checkin library' );
    is( $new_transfer->tobranch,   $to_library->branchcode,    'New transfer keeps the original destination' );
    is( $new_transfer->reason,     'Manual',                   'New transfer keeps the original reason' );

    $schema->storage->txn_rollback;
};

subtest 'verify_bundle() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $user    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $user->borrowernumber } );
    t::lib::Mocks::mock_preference( 'BundleLostValue',              2 );
    t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee', 1 );

    my $host       = $builder->build_sample_item( { library => $library->branchcode } );
    my $present    = $builder->build_sample_item( { library => $library->branchcode, itemlost         => 1 } );
    my $missing    = $builder->build_sample_item( { library => $library->branchcode, replacementprice => 10 } );
    my $stranger   = $builder->build_sample_item( { library => $library->branchcode } );
    my $other_host = $builder->build_sample_item( { library => $library->branchcode } );

    $host->add_to_bundle($present);
    $host->add_to_bundle($missing);
    $other_host->add_to_bundle($stranger);

    my $old_checkout = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { itemnumber => $host->itemnumber, borrowernumber => $patron->borrowernumber },
        }
    );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $host->itemnumber,
            user_id     => $user->borrowernumber,
            library_id  => $library->branchcode,
            checkout_id => $old_checkout->issue_id,
        }
    )->store;

    my $result = $checkin->verify_bundle(
        {
            verified_barcodes => [ $present->barcode, $stranger->barcode ],
            patron_id         => $patron->borrowernumber,
        }
    );

    is_deeply( [ map { $_->itemnumber } @{ $result->{verified} } ],   [ $present->itemnumber ],  'Verified items' );
    is_deeply( [ map { $_->itemnumber } @{ $result->{missing} } ],    [ $missing->itemnumber ],  'Missing items' );
    is_deeply( [ map { $_->itemnumber } @{ $result->{unexpected} } ], [ $stranger->itemnumber ], 'Unexpected items' );

    $present->discard_changes;
    is( $present->itemlost, 0, 'Verified item lost status cleared' );
    ok( $present->datelastborrowed, 'Verified item datelastborrowed set on an actual checkin' );

    $missing->discard_changes;
    is( $missing->itemlost, 2, 'Missing item marked lost with BundleLostValue' );

    my $claim = Koha::Checkouts::ReturnClaims->search( { itemnumber => $missing->itemnumber } )->next;
    ok( $claim, 'Return claim recorded for the missing item' );
    is(
        $claim->borrowernumber, $patron->borrowernumber,
        'Return claim is for the patron the bundle was checked out to'
    );
    is( $claim->created_by, $user->borrowernumber, 'Return claim created by the checkin user' );

    my $charge = $patron->account->lines->search( { itemnumber => $missing->itemnumber } )->next;
    ok( $charge, 'Replacement fee charged for the missing item' );
    is( $charge->amount + 0, 10, 'Replacement fee is the item replacement price' );

    $stranger->discard_changes;
    ok( !$stranger->in_bundle, 'Unexpected item removed from its bundle' );

    # Without a checkout (item was not checked out), no claim or charge
    my $loose_host    = $builder->build_sample_item( { library => $library->branchcode } );
    my $loose_missing = $builder->build_sample_item( { library => $library->branchcode } );
    $loose_host->add_to_bundle($loose_missing);
    my $loose_checkin = Koha::Checkin->new(
        {
            item_id    => $loose_host->itemnumber,
            user_id    => $user->borrowernumber,
            library_id => $library->branchcode,
        }
    )->store;
    $loose_checkin->discard_changes;
    $loose_checkin->verify_bundle( { verified_barcodes => [] } );
    is(
        Koha::Checkouts::ReturnClaims->search( { itemnumber => $loose_missing->itemnumber } )->count, 0,
        'No return claim without a checkout'
    );

    $schema->storage->txn_rollback;
};
