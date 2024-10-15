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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use utf8;

use Test::More tests => 6;

use Test::Exception;

use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Relation accessor tests' => sub {
    plan tests => 4;

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
};

subtest 'store() tests' => sub {
    plan tests => 15;
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
        plan tests => 1;
        is( $booking->item_id, $item_1->itemnumber, "Item 1 was assigned to the booking" );

        # Bookings
        # ✓ Item 1    |----|
        # ✓ Item 2     |--|
        # ✓ Any (1)         |--|
    };

    subtest 'modification notice trigger' => sub {
        plan tests => 3;

        my $original_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
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

        my $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count,
            'Koha::Booking->store should not have enqueued a BOOKING_MODIFICATION email for a new booking'
        );

        my $item_4 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );

        $booking->update(
            {
                item_id => $item_4->itemnumber,
            }
        );

        $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count,
            'Koha::Booking->store should not have enqueued a BOOKING_MODIFICATION email for a booking with modified item_id'
        );

        $booking->update(
            {
                start_date => $start_1->clone()->add( days => 1 )->datetime(q{ }),
            }
        );

        # start_date, end_date and pickup_library_id should behave identical
        $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_MODIFICATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count + 1,
            'Koha::Booking->store should have enqueued a BOOKING_MODIFICATION email for a booking with modified start_date'
        );

        $booking->update(
            {
                end_date => $end_1->clone()->add( days => 1 )->datetime(q{ }),
            }
        );
    };

    subtest 'confirmation notice trigger' => sub {
        plan tests => 2;

        my $original_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CONFIRMATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;

        # Reuse previous booking to produce a clash
        eval { $booking = Koha::Booking->new( $booking->unblessed )->store };

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

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );
    my $biblio                 = $builder->build_sample_biblio;
    my $item_1                 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0                = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0                  = $start_0->clone->add( days => 6 );
    my $original_notices_count = Koha::Notice::Messages->search(
        {
            letter_code    => 'BOOKING_CANCELLATION',
            borrowernumber => $patron->borrowernumber,
        }
    )->count;

    $item_1->bookable(1)->store;

    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_0,
            end_date          => $end_0
        }
    )->store;

    my $deleted = $booking->delete;
    is(
        ref($deleted), 'Koha::Booking',
        'Koha::Booking->delete should return the Koha::Booking object if the booking has been correctly deleted'
    );
    is(
        Koha::Bookings->search( { booking_id => $booking->booking_id } )->count, 0,
        'Koha::Booking->delete should have deleted the booking'
    );

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio  = $builder->build_sample_biblio;
    my $item_1  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0 = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0   = $start_0->clone->add( days => 6 );

    $item_1->bookable(1)->store;

    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_0,
            end_date          => $end_0,
        }
    )->store;

    my $booking_to_edit = Koha::Bookings->find( $booking->booking_id );
    $booking_to_edit->edit( { status => 'completed' } );

    is(
        $booking_to_edit->unblessed->{status}, 'completed',
        'Koha::Booking->edit should edit booking with passed params'
    );

    $schema->storage->txn_rollback;
};

subtest 'cancel() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron                 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio                 = $builder->build_sample_biblio;
    my $item_1                 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0                = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0                  = $start_0->clone->add( days => 6 );
    my $original_notices_count = Koha::Notice::Messages->search(
        {
            letter_code    => 'BOOKING_CANCELLATION',
            borrowernumber => $patron->borrowernumber,
        }
    )->count;

    $item_1->bookable(1)->store;

    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_0,
            end_date          => $end_0,
        }
    )->store;

    my $booking_to_cancel = Koha::Bookings->find( $booking->booking_id );
    $booking_to_cancel->cancel( { send_letter => 1 } );

    subtest 'notice trigger' => sub {
        plan tests => 1;

        my $post_notices_count = Koha::Notice::Messages->search(
            {
                letter_code    => 'BOOKING_CANCELLATION',
                borrowernumber => $patron->borrowernumber,
            }
        )->count;
        is(
            $post_notices_count,
            $original_notices_count + 1,
            'Koha::Booking->cancel should have enqueued a BOOKING_CANCELLATION email'
        );
    };

    $schema->storage->txn_rollback;
};

subtest 'set_status() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio  = $builder->build_sample_biblio;
    my $item_1  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0 = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0   = $start_0->clone->add( days => 6 );

    $item_1->bookable(1)->store;

    my $booking = Koha::Booking->new(
        {
            patron_id         => $patron->borrowernumber,
            biblio_id         => $biblio->biblionumber,
            item_id           => $item_1->itemnumber,
            pickup_library_id => $item_1->homebranch,
            start_date        => $start_0,
            end_date          => $end_0,
            status            => 'new',
        }
    )->store;

    my $booking_with_old_status = Koha::Bookings->find( $booking->booking_id );
    $booking_with_old_status->set_status('completed');
    is( $booking_with_old_status->unblessed->{status}, 'completed', 'Booking status is now "completed"' );

    $booking_with_old_status->set_status('cancelled');
    is( $booking_with_old_status->unblessed->{status}, 'cancelled', 'Booking status is now "cancelled"' );

    subtest 'unauthorized status' => sub {
        plan tests => 2;

        eval { $booking_with_old_status->set_status('blah'); };

        if ($@) {
            like(
                $@, qr/Invalid status: blah/,
                'An error is raised for unauthorized status'
            );
        } else {
            fail('Expected an error but none was raised');
        }

        # Status unchanged
        is( $booking_with_old_status->unblessed->{status}, 'cancelled', 'Booking status is still "cancelled"' );
    };

    $schema->storage->txn_rollback;
};
