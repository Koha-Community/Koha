#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 7;
use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'overdue_fines' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
        }
    );

    my $overdueline = Koha::Account::Line->new(
        {
            issue_id          => $checkout->id,
            borrowernumber    => $checkout->borrowernumber,
            itemnumber        => $checkout->itemnumber,
            branchcode        => $checkout->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'OVERDUE',
            status            => 'UNRETURNED',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $accountline = Koha::Account::Line->new(
        {
            issue_id          => $checkout->id,
            borrowernumber    => $checkout->borrowernumber,
            itemnumber        => $checkout->itemnumber,
            branchcode        => $checkout->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'LOST',
            status            => '',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store();

    my $overdue_fines = $checkout->overdue_fines;
    is(
        ref($overdue_fines), 'Koha::Account::Lines',
        'Koha::Checkout->overdue_fines should return a Koha::Account::Lines'
    );
    is( $overdue_fines->count, 1, "Koha::Checkout->overdue_fines returns only overdue fines" );

    my $overdue = $overdue_fines->next;
    is(
        ref($overdue), 'Koha::Account::Line',
        'next returns a Koha::Account::Line'
    );

    is(
        $overdueline->id,
        $overdue->id,
        'Koha::Checkout->overdue_fines should return the correct overdue_fines'
    );

    $schema->storage->txn_rollback;
};

subtest 'library() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { branchcode => $library->branchcode }
        }
    );

    is( ref( $checkout->library ),      'Koha::Library',      'Object type is correct' );
    is( $checkout->library->branchcode, $library->branchcode, 'Right library linked' );

    $schema->storage->txn_rollback;
};

subtest 'renewals() tests' => sub {

    plan tests => 2;
    $schema->storage->txn_begin;

    my $checkout = $builder->build_object( { class => 'Koha::Checkouts' } );
    my $renewal1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => undef }
        }
    );
    $renewal1->checkout_id( $checkout->issue_id )->store();
    my $renewal2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => undef }
        }
    );
    $renewal2->checkout_id( $checkout->issue_id )->store();

    is( ref( $checkout->renewals ), 'Koha::Checkouts::Renewals', 'Object set type is correct' );
    is( $checkout->renewals->count, 2,                           "Count of renewals is correct" );

    $schema->storage->txn_rollback;
};

subtest 'public_read_list() tests' => sub {

    $schema->storage->txn_begin;

    my @all_attrs = Koha::Checkouts->columns();
    my $public_attrs =
        { map { $_ => 1 } @{ Koha::Checkout->public_read_list() } };
    my $mapping = Koha::Checkout->to_api_mapping;

    plan tests => scalar @all_attrs * 2;

    # Create a sample checkout
    my $checkout = $builder->build_object( { class => 'Koha::Checkouts' } );

    my $unprivileged_representation = $checkout->to_api( { public => 1 } );
    my $privileged_representation   = $checkout->to_api;

    foreach my $attr (@all_attrs) {
        my $mapped = exists $mapping->{$attr} ? $mapping->{$attr} : $attr;
        if ( defined($mapped) ) {
            ok(
                exists $privileged_representation->{$mapped},
                "Attribute '$attr' is present when privileged"
            );
            if ( exists $public_attrs->{$attr} ) {
                ok(
                    exists $unprivileged_representation->{$mapped},
                    "Attribute '$attr' is present when public"
                );
            } else {
                ok(
                    !exists $unprivileged_representation->{$mapped},
                    "Attribute '$attr' is not present when public"
                );
            }
        } else {
            ok(
                !exists $privileged_representation->{$attr},
                "Unmapped attribute '$attr' is not present when privileged"
            );
            ok(
                !exists $unprivileged_representation->{$attr},
                "Unmapped attribute '$attr' is not present when public"
            );
        }
    }

    $schema->storage->txn_rollback;
};

subtest 'booking() tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $booking  = $builder->build_object( { class => 'Koha::Bookings' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { booking_id => $booking->booking_id }
        }
    );

    my $linked_booking = $checkout->booking;
    is( ref($linked_booking),        'Koha::Booking',      'booking() returns a Koha::Booking object' );
    is( $linked_booking->booking_id, $booking->booking_id, 'booking() returns the correct booking' );

    my $checkout_no_booking = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { booking_id => undef }
        }
    );

    my $no_booking = $checkout_no_booking->booking;
    is( $no_booking,      undef, 'booking() returns undef when no booking_id is set' );
    is( ref($no_booking), '',    'booking() returns empty ref when no booking_id is set' );

    $schema->storage->txn_rollback;
};

subtest 'mark_returned' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;
    my $library = $builder->build_object(
        {
            class => 'Koha::Libraries',
        }
    );
    my $borrower = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );
    my $other_borrower = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );
    my $item     = $builder->build_sample_item( { onloan => '2024-01-01' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber      => $item->itemnumber,
                checkin_library => $library->branchcode,
                borrowernumber  => $borrower->borrowernumber,
            }
        }
    );
    my $other_checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { checkin_library => $library->branchcode, borrowernumber => $other_borrower->borrowernumber }
        }
    );

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', 1 );

    # One fine on the checkout being returned, one on a checkout that is left alone
    my $fine = Koha::Account::Line->new(
        {
            issue_id          => $checkout->issue_id,
            borrowernumber    => $borrower->borrowernumber,
            itemnumber        => $item->itemnumber,
            branchcode        => $library->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'OVERDUE',
            status            => 'UNRETURNED',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store;
    my $other_fine = Koha::Account::Line->new(
        {
            issue_id          => $other_checkout->issue_id,
            borrowernumber    => $other_borrower->borrowernumber,
            itemnumber        => $other_checkout->itemnumber,
            branchcode        => $library->branchcode,
            date              => \'NOW()',
            debit_type_code   => 'OVERDUE',
            status            => 'UNRETURNED',
            interface         => 'cli',
            amount            => '1',
            amountoutstanding => '1',
        }
    )->store;

    # Borrowernumber assertion
    is(
        $checkout->mark_returned( { borrowernumber => $other_borrower->borrowernumber } ), undef,
        'returns void when borrowernumber does not match the checkout'
    );
    ok( Koha::Checkouts->find( $checkout->issue_id ), 'the checkout is untouched on a borrowernumber mismatch' );

    $checkout->mark_returned( { borrowernumber => $borrower->borrowernumber } );

    # Archived checkout
    is( Koha::Checkouts->find( $checkout->issue_id ), undef, 'the issues row is deleted' );
    my $old_checkout = Koha::Old::Checkouts->find( $checkout->issue_id );
    ok( $old_checkout->returndate, 'returndate is set on the archived checkout' );
    is(
        $old_checkout->checkin_library, undef,
        'checkin_library is taken from the parameter, overwriting the value already on the checkout'
    );

    # Item loan status
    $item->discard_changes;
    is( $item->onloan, undef, 'items.onloan is cleared' );

    # Last returned
    is(
        $item->last_returned_by->borrowernumber, $borrower->borrowernumber,
        'items.last_returned_by records the patron who had it'
    );

    # Accountlines
    $fine->discard_changes;
    is( $fine->old_issue_id, $old_checkout->issue_id, 'the accountline is reattached to the archived checkout' );

    $other_fine->discard_changes;
    is( $other_fine->issue_id, $other_checkout->issue_id, "another checkout's accountline still points at it" );

    # Privacy
    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->borrowernumber );

    my $private_checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { borrowernumber => $borrower->borrowernumber }
        }
    );
    $private_checkout->mark_returned( { privacy => 2 } );
    is(
        Koha::Old::Checkouts->find( $private_checkout->issue_id )->borrowernumber,
        $anonymous_patron->borrowernumber,
        'privacy 2 anonymises the archived checkout'
    );

    my $normal_checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { borrowernumber => $borrower->borrowernumber }
        }
    );
    $normal_checkout->mark_returned( { privacy => 1 } );
    is(
        Koha::Old::Checkouts->find( $normal_checkout->issue_id )->borrowernumber,
        $borrower->borrowernumber,
        'a lower privacy leaves the archived borrower intact'
    );

    $schema->storage->txn_rollback;
};
