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

use Test::More tests => 13;
use Test::NoWarnings;

use C4::Circulation qw( AddIssue AddReturn );
use Koha::Checkins;
use Koha::Database;

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
