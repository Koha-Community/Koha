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

use Test::More tests => 2;

use Koha::Bookings;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'filter_by_future' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => dt_from_string->subtract( days => 1 )->truncate( to => 'day' ),
                end_date   => undef
            }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => dt_from_string->add( days => 1 )->truncate( to => 'day' ),
                end_date   => undef
            }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => dt_from_string->add( days => 2 )->truncate( to => 'day' ),
                end_date   => undef
            }
        }
    );

    is( $biblio->bookings->filter_by_future->count, 2, 'There should have 2 bookings starting after now' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => dt_from_string->truncate( to => 'day' ),
                end_date   => undef
            }
        }
    );

    is( $biblio->bookings->filter_by_future->count, 2, 'Current day is not considered future' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_active' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $biblio     = $builder->build_sample_biblio;
    my $start_ago  = dt_from_string->subtract( hours => 1 );
    my $start_hour = dt_from_string->add( hours => 1 );
    my $start_day  = dt_from_string->add( days  => 1 );
    my $end_ago    = dt_from_string->subtract( minutes => 1 );
    my $end_hour   = dt_from_string->add( hours => 1 );
    my $end_day    = dt_from_string->add( days  => 1 );
    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => $start_ago,
                end_date   => $end_hour
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 1, 'Booking started in past, ending in future is counted' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => $start_ago,
                end_date   => $end_ago
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 1, 'Booking started in past, ended now is not counted' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => $start_hour,
                end_date   => $end_hour
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 2, 'Booking starting soon, ending soon is still counted' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => $start_day,
                end_date   => $end_day
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 3, 'Booking starting tomorrow, ending tomorrow is counted' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                start_date => $start_day,
                end_date   => $end_ago
            }
        }
    );
    is(
        $biblio->bookings->filter_by_active->count, 3,
        'EDGE CASE: Booking starting in future, already ended is not counted - should be impossible, but good check'
    );

    $schema->storage->txn_rollback;
};
