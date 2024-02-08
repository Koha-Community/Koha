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

use Test::More tests => 2;

use Test::Exception;

use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Relation accessor tests' => sub {
    plan tests => 3;

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
    plan tests => 13;
    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => "Koha::Patrons" } );
    my $biblio  = $builder->build_sample_biblio();
    my $item_1  = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $start_0 = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0   = $start_0->clone()->add( days => 6 );

    my $deleted_item = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    $deleted_item->delete;

    my $wrong_item = $builder->build_sample_item();

    my $booking = Koha::Booking->new(
        {
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $deleted_item->itemnumber,
            start_date => $start_0,
            end_date   => $end_0
        }
    );

    throws_ok { $booking->store() } 'Koha::Exceptions::Object::FKConstraint',
        'Throws exception if passed a deleted item';

    $booking = Koha::Booking->new(
        {
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $wrong_item->itemnumber,
            start_date => $start_0,
            end_date   => $end_0
        }
    );

    throws_ok { $booking->store() } 'Koha::Exceptions::Object::FKConstraint',
        "Throws exception if item passed doesn't match biblio passed";

    $booking = Koha::Booking->new(
        {
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_1->itemnumber,
            start_date => $start_0,
            end_date   => $end_0
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_1->itemnumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_1->itemnumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_1->itemnumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_1->itemnumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            item_id    => $item_2->itemnumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            start_date => $start_1,
            end_date   => $end_1
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
            patron_id  => $patron->borrowernumber,
            biblio_id  => $biblio->biblionumber,
            start_date => $start_1,
            end_date   => $end_1
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

    $schema->storage->txn_rollback;
};
