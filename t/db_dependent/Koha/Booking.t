#!/usr/bin/perl

# Copyright 2024 Koha Development team
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
use utf8;

use Test::More tests => 7;
use Test::NoWarnings;

use Test::Warn;

use Test::Exception;

use Koha::DateUtils qw( dt_from_string );
use Koha::Notice::Template;
use Koha::Notice::Templates;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Relation accessor tests' => sub {
    plan tests => 6;

    subtest 'biblio relation tests' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio = $builder->build_sample_biblio;
        my $booking =
            $builder->build_object( { class => 'Koha::Bookings', value => { biblio_id => $biblio->biblionumber } } );

        my $THE_biblio = $booking->biblio;
        is( ref($THE_biblio),          'Koha::Biblio',        "Koha::Booking->biblio returns a Koha::Biblio object" );
        is( $THE_biblio->biblionumber, $biblio->biblionumber, "Koha::Booking->biblio returns the links biblio object" );

        $THE_biblio->delete;
        $booking = Koha::Bookings->find( $booking->booking_id );
        is( $booking, undef, "The booking is deleted when the biblio it's attached to is deleted" );

        $schema->storage->txn_rollback;
    };

    subtest 'patron relation tests' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $patron = $builder->build_object( { class => "Koha::Patrons" } );
        my $booking =
            $builder->build_object( { class => 'Koha::Bookings', value => { patron_id => $patron->borrowernumber } } );

        my $THE_patron = $booking->patron;
        is( ref($THE_patron), 'Koha::Patron', "Koha::Booking->patron returns a Koha::Patron object" );
        is(
            $THE_patron->borrowernumber, $patron->borrowernumber,
            "Koha::Booking->patron returns the links patron object"
        );

        $THE_patron->delete;
        $booking = Koha::Bookings->find( $booking->booking_id );
        is( $booking, undef, "The booking is deleted when the patron it's attached to is deleted" );

        $schema->storage->txn_rollback;
    };

    subtest 'pickup_library relation tests' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $pickup_library = $builder->build_object( { class => "Koha::Libraries" } );
        my $booking =
            $builder->build_object(
            { class => 'Koha::Bookings', value => { pickup_library_id => $pickup_library->branchcode } } );

        my $THE_pickup_library = $booking->pickup_library;
        is( ref($THE_pickup_library), 'Koha::Library', "Koha::Booking->pickup_library returns a Koha::Library object" );
        is(
            $THE_pickup_library->branchcode, $pickup_library->branchcode,
            "Koha::Booking->pickup_library returns the linked pickup library object"
        );

        $THE_pickup_library->delete;
        $booking = Koha::Bookings->find( $booking->booking_id );
        is( $booking, undef, "The booking is deleted when the pickup_library it's attached to is deleted" );

        $schema->storage->txn_rollback;
    };

    subtest 'item relation tests' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $item = $builder->build_sample_item( { bookable => 1 } );
        my $booking =
            $builder->build_object( { class => 'Koha::Bookings', value => { item_id => $item->itemnumber } } );

        my $THE_item = $booking->item;
        is( ref($THE_item), 'Koha::Item', "Koha::Booking->item returns a Koha::Item object" );
        is(
            $THE_item->itemnumber, $item->itemnumber,
            "Koha::Booking->item returns the links item object"
        );

        $THE_item->delete;
        $booking = Koha::Bookings->find( $booking->booking_id );
        is( $booking, undef, "The booking is deleted when the item it's attached to is deleted" );

        $schema->storage->txn_rollback;
    };

    subtest 'checkout relation tests' => sub {
        plan tests => 4;
        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => "Koha::Patrons" } );
        my $item    = $builder->build_sample_item( { bookable => 1 } );
        my $booking = $builder->build_object(
            {
                class => 'Koha::Bookings',
                value => {
                    patron_id => $patron->borrowernumber,
                    item_id   => $item->itemnumber,
                    status    => 'completed'
                }
            }
        );

        my $checkout = $booking->checkout;
        is( $checkout, undef, "Koha::Booking->checkout returns undef when no checkout exists" );

        my $issue = $builder->build_object(
            {
                class => 'Koha::Checkouts',
                value => {
                    borrowernumber => $patron->borrowernumber,
                    itemnumber     => $item->itemnumber,
                    booking_id     => $booking->booking_id
                }
            }
        );

        $checkout = $booking->checkout;
        is( ref($checkout),        'Koha::Checkout',     "Koha::Booking->checkout returns a Koha::Checkout object" );
        is( $checkout->issue_id,   $issue->issue_id,     "Koha::Booking->checkout returns the linked checkout" );
        is( $checkout->booking_id, $booking->booking_id, "The checkout is properly linked to the booking" );

        $schema->storage->txn_rollback;
    };

    subtest 'old_checkout relation tests' => sub {
        plan tests => 4;
        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => "Koha::Patrons" } );
        my $item    = $builder->build_sample_item( { bookable => 1 } );
        my $booking = $builder->build_object(
            {
                class => 'Koha::Bookings',
                value => {
                    patron_id => $patron->borrowernumber,
                    item_id   => $item->itemnumber,
                    status    => 'completed'
                }
            }
        );

        my $old_checkout = $booking->old_checkout;
        is( $old_checkout, undef, "Koha::Booking->old_checkout returns undef when no old_checkout exists" );

        my $old_issue = $builder->build_object(
            {
                class => 'Koha::Old::Checkouts',
                value => {
                    borrowernumber => $patron->borrowernumber,
                    itemnumber     => $item->itemnumber,
                    booking_id     => $booking->booking_id
                }
            }
        );

        $old_checkout = $booking->old_checkout;
        is(
            ref($old_checkout), 'Koha::Old::Checkout',
            "Koha::Booking->old_checkout returns a Koha::Old::Checkout object"
        );
        is(
            $old_checkout->issue_id, $old_issue->issue_id,
            "Koha::Booking->old_checkout returns the linked old_checkout"
        );
        is( $old_checkout->booking_id, $booking->booking_id, "The old_checkout is properly linked to the booking" );

        $schema->storage->txn_rollback;
    };
};

subtest 'store() tests' => sub {
    plan tests => 16;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );
    my $biblio  = $builder->build_sample_biblio();
    my $item_1  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0 = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0   = $start_0->clone()->add( days => 6 );

    my $deleted_item = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    $deleted_item->delete;

    my $wrong_item = $builder->build_sample_item();

    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $deleted_item->itemnumber,
            pickup_library_id => $deleted_item->homebranch,
            start_date        => $start_0,
            end_date          => $end_0
        }
    );

    throws_ok { $booking->store() } 'Koha::Exceptions::Object::FKConstraint',
        'Throws exception if passed a deleted item';

    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $wrong_item->itemnumber,
            pickup_library_id => $wrong_item->homebranch,
            start_date        => $start_0,
            end_date          => $end_0
        }
    );

    throws_ok { $booking->store() } 'Koha::Exceptions::Object::FKConstraint',
        "Throws exception if item passed doesn't match biblio passed";

    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_0,
            end_date          => $end_0
        }
    );

    # FIXME: Should this be allowed if an item is passed specifically?
    throws_ok { $booking->store() } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when there are no items marked bookable for this biblio';

    $item_1->bookable(1)->store();
    $booking->store();
    ok( $booking->in_storage, 'First booking on item 1 stored OK' );

    # Bookings
    # ✓ Item 1    |----|
    # ✗ Item 1      |----|

    my $start_1 = dt_from_string->truncate( to => 'day' );
    my $end_1   = $start_1->clone()->add( days => 6 );
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    );
    throws_ok { $booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when passed booking start_date falls inside another booking for the item passed';

    # Bookings
    # ✓ Item 1    |----|
    # ✗ Item 1  |----|
    $start_1 = dt_from_string->subtract( days => 4 )->truncate( to => 'day' );
    $end_1   = $start_1->clone()->add( days => 6 );
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    );
    throws_ok { $booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when passed booking end_date falls inside another booking for the item passed';

    # Bookings
    # ✓ Item 1    |----|
    # ✗ Item 1  |--------|
    $start_1 = dt_from_string->subtract( days => 4 )->truncate( to => 'day' );
    $end_1   = $start_1->clone()->add( days => 10 );
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    );
    throws_ok { $booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when passed booking dates would envelope another booking for the item passed';

    # Bookings
    # ✓ Item 1    |----|
    # ✗ Item 1     |--|
    $start_1 = dt_from_string->truncate( to => 'day' );
    $end_1   = $start_1->clone()->add( days => 4 );
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    );
    throws_ok { $booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when passed booking dates would fall wholly inside another booking for the item passed';

    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $item_3 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 0 } );

    # Bookings
    # ✓ Item 1    |----|
    # ✓ Item 2     |--|
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_2->itemnumber,
            pickup_library_id => $item_2->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    )->store();
    ok(
        $booking->in_storage,
        'First booking on item 2 stored OK, even though it would overlap with a booking on item 1'
    );

    # Bookings
    # ✓ Item 1    |----|
    # ✓ Item 2     |--|
    # ✘ Any        |--|
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_2->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    );
    throws_ok { $booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when passed booking dates would fall wholly inside all existing bookings when no item specified';

    # Bookings
    # ✓ Item 1    |----|
    # ✓ Item 2     |--|
    # ✓ Any             |--|
    $start_1 = dt_from_string->add( days => 5 )->truncate( to => 'day' );
    $end_1   = $start_1->clone()->add( days => 4 );
    $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_2->homebranch,
            start_date        => $start_1,
            end_date          => $end_1
        }
    )->store();
    ok( $booking->in_storage, 'Booking stored OK when item not specified and the booking slot is available' );
    ok( $booking->item_id,    'An item was assigned to the booking' );

    subtest '_assign_item_for_booking() tests' => sub {
        plan tests => 5;

        # Bookings
        # ✓ Item 1    |----|
        # ✓ Item 2     |--|
        # ✓ Any (X)         |--|
        my $valid_items   = [ $item_1->itemnumber, $item_2->itemnumber ];
        my $assigned_item = $booking->item_id;
        is(
            ( scalar grep { $_ == $assigned_item } @$valid_items ), 1,
            'The item assigned was one of the valid, bookable items'
        );

        my $second_booking = Koha::Booking->new(
            {
                patron_id         => $patron->borrowernumber,
                biblio_id         => $biblio->biblionumber,
                pickup_library_id => $item_2->homebranch,
                start_date        => $start_1,
                end_date          => $end_1
            }
        )->store();
        isnt( $second_booking->item_id, $assigned_item, "The subsequent booking picks the only other available item" );

        # Cancel both bookings so we can check that cancelled bookings are allowed in the auto-assign
        $booking->status('cancelled')->store();
        $second_booking->status('cancelled')->store();
        is( $booking->status,        'cancelled', "Booking is cancelled" );
        is( $second_booking->status, 'cancelled', "Second booking is cancelled" );

        # Test optimal selection - with no future bookings, both items have equal availability
        # The algorithm should consistently select the same item (deterministic)
        my %seen_items;
        foreach my $i ( 1 .. 10 ) {
            my $new_booking = Koha::Booking->new(
                {
                    patron_id         => $patron->borrowernumber,
                    biblio_id         => $biblio->biblionumber,
                    pickup_library_id => $item_1->homebranch,
                    start_date        => $start_1,
                    end_date          => $end_1
                }
            );
            $new_booking->store();
            $seen_items{ $new_booking->item_id }++;
            $new_booking->delete();
        }
        ok(
            scalar( keys %seen_items ) == 1,
            'Optimal selection is deterministic - same item selected when items have equal future availability, and cancelled bookings are ignored'
        );
    };

    subtest 'confirmation notice trigger' => sub {
        plan tests => 3;

        # FIXME: This is a bandaid solution to prevent test failures when running
        # the Koha_Main_My8 job because notices are not added at upgrade time.
        my $template = Koha::Notice::Templates->search(
            {
                module                 => 'bookings',
                code                   => 'BOOKING_CONFIRMATION',
                message_transport_type => 'email',
            }
        )->single;

        if ( !$template ) {
            my $default_content = Koha::Notice::Template->new(
                {
                    module                 => 'bookings',
                    code                   => 'BOOKING_CONFIRMATION',
                    lang                   => 'default',
                    message_transport_type => 'email',
                }
            )->get_default();

            Koha::Notice::Template->new(
                {
                    module                 => 'bookings',
                    code                   => 'BOOKING_CONFIRMATION',
                    name                   => 'BOOKING_CONFIRMATION Test Notice',
                    title                  => 'BOOKING_CONFIRMATION Test Notice',
                    content                => $default_content || 'Dummy content for BOOKING_CONFIRMATION.',
                    branchcode             => undef,
                    message_transport_type => 'email',
                }
            )->store;
        }

        my $original_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CONFIRMATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;

        # Reuse previous booking to produce a clash
        throws_ok {
            Koha::Booking->new( $booking->unblessed )->store
        }
        'Koha::Exceptions::Object::DuplicateID',
            'Exception is thrown correctly';

        my $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CONFIRMATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count,
            'Koha::Booking->store should not have enqueued a BOOKING_CONFIRMATION email if booking creation fails'
        );

        $start_1 = dt_from_string->add( months => 1 )->truncate( to => 'day' );
        $end_1   = $start_1->clone()->add( days => 1 );

        $booking = Koha::Booking->new(
            {
                patron_id         => $patron->borrowernumber,
                biblio_id         => $biblio->biblionumber,
                pickup_library_id => $item_2->homebranch,
                start_date        => $start_1->datetime(q{ }),
                end_date          => $end_1->datetime(q{ }),
            }
        )->store;

        $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CONFIRMATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count + 1,
            'Koha::Booking->store should have enqueued a BOOKING_CONFIRMATION email for a new booking'
        );
    };

    subtest 'modification/cancellation notice triggers' => sub {
        plan tests => 5;

        # FIXME: This is a bandaid solution to prevent test failures when running
        # the Koha_Main_My8 job because notices are not added at upgrade time.
        for my $notice_type (qw(BOOKING_MODIFICATION BOOKING_CANCELLATION)) {
            my $template = Koha::Notice::Templates->search(
                {
                    module                 => 'bookings',
                    code                   => $notice_type,
                    message_transport_type => 'email',
                }
            )->single;

            if ( !$template ) {
                my $default_content = Koha::Notice::Template->new(
                    {
                        module                 => 'bookings',
                        code                   => $notice_type,
                        lang                   => 'default',
                        message_transport_type => 'email',
                    }
                )->get_default();

                Koha::Notice::Template->new(
                    {
                        module                 => 'bookings',
                        code                   => $notice_type,
                        name                   => "$notice_type Test Notice",
                        title                  => "$notice_type Test Notice",
                        content                => $default_content || "Dummy content for $notice_type.",
                        branchcode             => undef,
                        message_transport_type => 'email',
                    }
                )->store;
            }
        }

        my $original_modification_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        my $original_cancellation_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CANCELLATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;

        $start_1 = dt_from_string->add( months => 1 )->truncate( to => 'day' );
        $end_1   = $start_1->clone()->add( days => 1 );

        # Use datetime formatting so that we don't get DateTime objects
        $booking = Koha::Booking->new(
            {
                patron_id         => $patron->borrowernumber,
                biblio_id         => $biblio->biblionumber,
                pickup_library_id => $item_2->homebranch,
                start_date        => $start_1->datetime(q{ }),
                end_date          => $end_1->datetime(q{ }),
            }
        )->store;

        my $post_modification_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_modification_notices_count,
            $original_modification_notices_count,
            'Koha::Booking->store should not have enqueued a BOOKING_MODIFICATION email for a new booking'
        );

        my $item_4 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );

        $booking->update(
            {
                item_id => $item_4->itemnumber,
            }
        );

        $post_modification_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_modification_notices_count,
            $original_modification_notices_count,
            'Koha::Booking->store should not have enqueued a BOOKING_MODIFICATION email for a booking with modified item_id'
        );

        $booking->update(
            {
                start_date => $start_1->clone()->add( days => 1 )->datetime(q{ }),
            }
        );

        # start_date, end_date and pickup_library_id should behave identical
        $post_modification_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_modification_notices_count,
            $original_modification_notices_count + 1,
            'Koha::Booking->store should have enqueued a BOOKING_MODIFICATION email for a booking with modified start_date'
        );

        $booking->update(
            {
                end_date => $end_1->clone()->add( days => 1 )->datetime(q{ }),
            }
        );

        $booking->update(
            {
                status => 'completed',
            }
        );

        my $post_cancellation_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CANCELLATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_cancellation_notices_count,
            $original_cancellation_notices_count,
            'Koha::Booking->store should NOT have enqueued a BOOKING_CANCELLATION email for a booking status change that is not a "cancellation"'
        );

        $booking->update(
            {
                status => 'cancelled',
            }
        );

        $post_cancellation_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CANCELLATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_cancellation_notices_count,
            $original_cancellation_notices_count + 1,
            'Koha::Booking->store should have enqueued a BOOKING_CANCELLATION email for a booking status change that is a "cancellation"'
        );
    };

    subtest 'status change exception' => sub {
        plan tests => 2;

        $booking->discard_changes;
        my $status = $booking->status;
        throws_ok { $booking->update( { status => 'blah' } ) } 'Koha::Exceptions::Object::BadValue',
            'Throws exception when passed booking status would fail enum constraint';

        # Status unchanged
        $booking->discard_changes;
        is( $booking->status, $status, 'Booking status is unchanged' );
    };

    $schema->storage->txn_rollback;
};

subtest '_select_optimal_item() tests' => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $biblio = $builder->build_sample_biblio;

    # Create 3 items with different future booking scenarios
    my $item1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $item2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $item3 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );

    # Current booking period
    my $start_date = dt_from_string->truncate( to => 'day' );
    my $end_date   = $start_date->clone->add( days => 5 );

    # Test 1: With no items, should return undef
    my $test_booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item1->homebranch,
            start_date        => $start_date,
            end_date          => $end_date
        }
    );

    my $empty_items  = Koha::Items->search( { itemnumber => -1 } );         # Empty resultset
    my $optimal_item = $test_booking->_select_optimal_item($empty_items);
    is( $optimal_item, undef, 'Returns undef when no items available' );

    # Test 2: With one item, should return that item
    my $single_items = Koha::Items->search( { itemnumber => $item1->itemnumber } );
    $optimal_item = $test_booking->_select_optimal_item($single_items);
    is( $optimal_item->itemnumber, $item1->itemnumber, 'Returns the single available item' );

    # Setup future bookings with different availability windows:
    # Item1: Next booking in 5 days (short future availability)
    # Item2: Next booking in 15 days (medium future availability)
    # Item3: No future bookings (longest future availability - 365 days)

    my $item1_future_start = $end_date->clone->add( days => 6 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item1->itemnumber,
            pickup_library_id => $item1->homebranch,
            start_date        => $item1_future_start,
            end_date          => $item1_future_start->clone->add( days => 3 )
        }
    )->store;

    my $item2_future_start = $end_date->clone->add( days => 16 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item2->itemnumber,
            pickup_library_id => $item2->homebranch,
            start_date        => $item2_future_start,
            end_date          => $item2_future_start->clone->add( days => 3 )
        }
    )->store;

    # Item3 has no future bookings

    # Test 3: Should select item3 (no future bookings = 365 days)
    my $all_items = Koha::Items->search(
        { itemnumber => [ $item1->itemnumber, $item2->itemnumber, $item3->itemnumber ] },
        { order_by   => { -asc => 'itemnumber' } }
    );
    $optimal_item = $test_booking->_select_optimal_item($all_items);
    is( $optimal_item->itemnumber, $item3->itemnumber, 'Selects item with longest future availability (no bookings)' );

    # Test 4: If item3 is removed, should select item2 (15 days > 5 days)
    my $two_items = Koha::Items->search(
        { itemnumber => [ $item1->itemnumber, $item2->itemnumber ] },
        { order_by   => { -asc => 'itemnumber' } }
    );
    $optimal_item = $test_booking->_select_optimal_item($two_items);
    is(
        $optimal_item->itemnumber, $item2->itemnumber,
        'Selects item with longest future availability (15 days vs 5 days)'
    );

    # Test 5: Test with equal future availability - should return first item
    my $item4 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $item5 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );

    # Both items have booking starting 10 days after current booking ends
    my $equal_future_start = $end_date->clone->add( days => 11 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item4->itemnumber,
            pickup_library_id => $item4->homebranch,
            start_date        => $equal_future_start,
            end_date          => $equal_future_start->clone->add( days => 3 )
        }
    )->store;

    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item5->itemnumber,
            pickup_library_id => $item5->homebranch,
            start_date        => $equal_future_start,
            end_date          => $equal_future_start->clone->add( days => 3 )
        }
    )->store;

    my $equal_items = Koha::Items->search(
        { itemnumber => [ $item4->itemnumber, $item5->itemnumber ] },
        { order_by   => { -asc => 'itemnumber' } }
    );
    $optimal_item = $test_booking->_select_optimal_item($equal_items);
    ok(
        $optimal_item->itemnumber == $item4->itemnumber || $optimal_item->itemnumber == $item5->itemnumber,
        'Returns an item when future availability is equal'
    );

    # Test 6: Cancelled future bookings should not affect optimal selection
    my $item6            = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $cancelled_future = $end_date->clone->add( days => 6 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item6->itemnumber,
            pickup_library_id => $item6->homebranch,
            start_date        => $cancelled_future,
            end_date          => $cancelled_future->clone->add( days => 3 ),
            status            => 'cancelled'
        }
    )->store;

    # Item6 should have 365 days availability since cancelled booking is ignored
    my $with_cancelled = Koha::Items->search(
        { itemnumber => [ $item1->itemnumber, $item6->itemnumber ] },
        { order_by   => { -asc => 'itemnumber' } }
    );
    $optimal_item = $test_booking->_select_optimal_item($with_cancelled);
    is(
        $optimal_item->itemnumber, $item6->itemnumber,
        'Selects item with cancelled future booking over item with active future booking'
    );

    # Test 7: Verify iterator is reset after selection
    $all_items->reset;
    $optimal_item = $test_booking->_select_optimal_item($all_items);
    my $count = $all_items->count;
    is( $count, 3, 'Iterator is properly reset after optimal selection' );

    $schema->storage->txn_rollback;
};

subtest '_assign_item_for_booking() with itemtype_id tests' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $itemtype1 = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $itemtype2 = $builder->build_object( { class => 'Koha::ItemTypes' } );

    my $biblio = $builder->build_sample_biblio;

    # Create items of different types
    my $item1_type1 =
        $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype1->itemtype } );
    my $item2_type1 =
        $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype1->itemtype } );
    my $item3_type2 =
        $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype2->itemtype } );

    my $start_date = dt_from_string->truncate( to => 'day' );
    my $end_date   = $start_date->clone->add( days => 5 );

    # Test 1: Booking without item_id or itemtype_id should select any available item
    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $start_date,
            end_date          => $end_date
        }
    )->store;

    ok( $booking->item_id, 'Booking assigned an item when no item_id or itemtype_id specified' );
    my $assigned_item = $booking->item;
    ok(
               $assigned_item->itemnumber == $item1_type1->itemnumber
            || $assigned_item->itemnumber == $item2_type1->itemnumber
            || $assigned_item->itemnumber == $item3_type2->itemnumber,
        'Assigned item is one of the available items'
    );

    # Test 2: Booking with itemtype_id should only select items of that type
    my $booking_type1 = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $start_date->clone->add( days => 10 ),
            end_date          => $start_date->clone->add( days => 15 )
        }
    );

    # Set transient itemtype filter (simulating API call)
    $booking_type1->set_itemtype_filter( $itemtype1->itemtype );
    $booking_type1->store;

    ok( $booking_type1->item_id, 'Booking with itemtype_id assigned an item' );
    is(
        $booking_type1->item->itype, $itemtype1->itemtype,
        'Assigned item matches the specified itemtype'
    );

    # Test 3: Should select optimal item from filtered itemtype
    # Create future bookings to test optimal selection within itemtype
    my $future_start = $end_date->clone->add( days => 20 );

    # Item1 of type1 has a booking soon after (less future availability)
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item1_type1->itemnumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $future_start->clone->add( days => 6 ),
            end_date          => $future_start->clone->add( days => 10 )
        }
    )->store;

    # Item2 of type1 has no future bookings (more future availability)
    # Item3 is type2, should not be considered

    my $optimal_booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $future_start,
            end_date          => $future_start->clone->add( days => 3 )
        }
    );
    $optimal_booking->set_itemtype_filter( $itemtype1->itemtype );
    $optimal_booking->store;

    is(
        $optimal_booking->item->itemnumber, $item2_type1->itemnumber,
        'Optimal selection works within filtered itemtype (selects item with no future bookings)'
    );

    # Test 6: Exception when no items of specified type are available
    # Book both type1 items for an overlapping period
    my $conflict_start =
        dt_from_string->add( days => 200 )->truncate( to => 'day' );    # Use far future to avoid conflicts
    my $conflict_end = $conflict_start->clone->add( days => 5 );

    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item1_type1->itemnumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $conflict_start,
            end_date          => $conflict_end
        }
    )->store;

    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item2_type1->itemnumber,
            pickup_library_id => $item2_type1->homebranch,
            start_date        => $conflict_start,
            end_date          => $conflict_end
        }
    )->store;

    my $failing_booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item1_type1->homebranch,
            start_date        => $conflict_start->clone->add( days => 2 ),
            end_date          => $conflict_end->clone->add( days => 2 )
        }
    );
    $failing_booking->set_itemtype_filter( $itemtype1->itemtype );

    throws_ok { $failing_booking->store } 'Koha::Exceptions::Booking::Clash',
        'Throws exception when no items of specified itemtype are available';

    $schema->storage->txn_rollback;
};

subtest 'Integration test: Full optimal selection workflow' => sub {
    plan tests => 5;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $biblio   = $builder->build_sample_biblio;

    # Create 3 items of the same type with different future booking patterns
    my $item_A = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype->itemtype } );
    my $item_B = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype->itemtype } );
    my $item_C = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype->itemtype } );

    # Current booking window
    my $start = dt_from_string->truncate( to => 'day' );
    my $end   = $start->clone->add( days => 7 );

    # Setup: Item A has booking in 5 days (short availability)
    #        Item B has booking in 20 days (long availability)
    #        Item C has booking in 10 days (medium availability)
    my $future_A = $end->clone->add( days => 6 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_A->itemnumber,
            pickup_library_id => $item_A->homebranch,
            start_date        => $future_A,
            end_date          => $future_A->clone->add( days => 3 )
        }
    )->store;

    my $future_B = $end->clone->add( days => 21 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_B->itemnumber,
            pickup_library_id => $item_B->homebranch,
            start_date        => $future_B,
            end_date          => $future_B->clone->add( days => 3 )
        }
    )->store;

    my $future_C = $end->clone->add( days => 11 );
    Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_C->itemnumber,
            pickup_library_id => $item_C->homebranch,
            start_date        => $future_C,
            end_date          => $future_C->clone->add( days => 3 )
        }
    )->store;

    # Test 1: First "any item" booking should select Item B (longest availability: 20 days)
    my $booking1 = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_A->homebranch,
            start_date        => $start,
            end_date          => $end
        }
    );
    $booking1->set_itemtype_filter( $itemtype->itemtype );
    $booking1->store;

    is(
        $booking1->item_id, $item_B->itemnumber,
        'First booking selects item B (longest future availability: 20 days)'
    );

    # Test 2: Second booking should select Item C (medium availability: 10 days)
    #         Item B is now booked, Item A still has shortest (5 days)
    my $booking2 = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_A->homebranch,
            start_date        => $start,
            end_date          => $end
        }
    );
    $booking2->set_itemtype_filter( $itemtype->itemtype );
    $booking2->store;

    is( $booking2->item_id, $item_C->itemnumber, 'Second booking selects item C (next longest: 10 days)' );

    # Test 3: Third booking should select Item A (only one left, 5 days availability)
    my $booking3 = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_A->homebranch,
            start_date        => $start,
            end_date          => $end
        }
    );
    $booking3->set_itemtype_filter( $itemtype->itemtype );
    $booking3->store;

    is( $booking3->item_id, $item_A->itemnumber, 'Third booking selects item A (only remaining item)' );

    # Test 4: Fourth booking should fail (all items booked for this period)
    my $booking4 = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $item_A->homebranch,
            start_date        => $start,
            end_date          => $end
        }
    );
    $booking4->set_itemtype_filter( $itemtype->itemtype );

    throws_ok { $booking4->store } 'Koha::Exceptions::Booking::Clash',
        'Fourth booking fails when all items are already booked';

    # Test 5: Verify the algorithm preserved items optimally
    # Item A (shortest availability) was selected last, preserving it for bookings that specifically need it
    # This demonstrates that the optimal selection algorithm works as intended:
    # - Longest availability items are consumed first
    # - Shortest availability items are preserved for when they're the only option
    # - This maximizes overall system booking capacity

    my @booking_order  = ( $booking1->item_id,  $booking2->item_id,  $booking3->item_id );
    my @expected_order = ( $item_B->itemnumber, $item_C->itemnumber, $item_A->itemnumber );

    is_deeply(
        \@booking_order, \@expected_order,
        'Items were selected in optimal order: longest availability first (B->C->A)'
    );

    $schema->storage->txn_rollback;
};

subtest 'store() skips clash detection on terminal status transition' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $biblio            = $builder->build_sample_biblio();
    my $bookable_item     = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
    my $non_bookable_item = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 0 } );

    my $start = dt_from_string()->truncate( to => 'day' );
    my $end   = $start->clone->add( days => 7 );

    # Create booking first, before any checkouts exist so
    # store() succeeds without interference from Bug 41886.
    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $bookable_item->itemnumber,
            pickup_library_id => $bookable_item->homebranch,
            start_date        => $start,
            end_date          => $end,
        }
    )->store();
    ok( $booking->in_storage, 'Booking on bookable item stored OK' );

    # Now check out the non-bookable sibling item. This
    # checkout inflates the unavailable count in
    # Biblio::check_booking (see Bug 41886) and causes a
    # false clash when there is only one bookable item.
    C4::Circulation::AddIssue( $patron, $non_bookable_item->barcode );

    # Without the fix, transitioning to 'completed' runs clash
    # detection which sees the non-bookable checkout and throws
    # Koha::Exceptions::Booking::Clash → 500 error.
    lives_ok { $booking->status('completed')->store() }
    'Transition to completed skips clash detection';

    # Cancellation from completed is also a terminal transition
    lives_ok { $booking->status('cancelled')->store() }
    'Transition to cancelled skips clash detection';

    $schema->storage->txn_rollback;
};
