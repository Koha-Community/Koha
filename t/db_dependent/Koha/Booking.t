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

use Test::More tests => 1;

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

        my $item = $builder->build_object( { class => "Koha::Items" } );
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
