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

use Test::NoWarnings;
use Test::More tests => 3;

use Koha::Bookings;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'filter_by_active' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $biblio    = $builder->build_sample_biblio;
    my $start_ago = dt_from_string->subtract( days => 5 );
    my $end_ago   = dt_from_string->subtract( days => 1 );
    my $start_day = dt_from_string->add( days => 1 );
    my $end_day   = dt_from_string->add( days => 5 );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value =>
                { biblio_id => $biblio->biblionumber, start_date => $start_ago, end_date => $end_day, status => 'new' }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 1, 'Active new booking is open' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value =>
                { biblio_id => $biblio->biblionumber, start_date => $start_ago, end_date => $end_ago, status => 'new' }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 2, 'Uncollected past-window new booking is still open' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id => $biblio->biblionumber, start_date => $start_ago, end_date => $end_day, status => 'issued'
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 3, 'Issued booking is open' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id => $biblio->biblionumber, start_date => $start_day, end_date => $end_day,
                status    => 'cancelled'
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 3, 'Cancelled booking is not open' );

    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id => $biblio->biblionumber, start_date => $start_ago, end_date => $end_ago,
                status    => 'completed'
            }
        }
    );
    is( $biblio->bookings->filter_by_active->count, 3, 'Completed booking is not open' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_overlapping' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $day    = sub { dt_from_string->add( days => shift )->truncate( to => 'day' ) };

    # Existing booking: today+10 to today+20
    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                item_id    => $item->itemnumber,
                start_date => $day->(10),
                end_date   => $day->(20),
                status     => 'new',
            }
        }
    );

    my $overlapping = sub {
        my ( $start, $end, $lead, $trail ) = @_;
        return $biblio->bookings->filter_by_overlapping(
            {
                start_date => $day->($start),
                end_date   => $day->($end),
                lead_days  => $lead,
                trail_days => $trail,
            }
        )->count;
    };

    is( $overlapping->( 12, 15 ), 1, 'Period inside the booking overlaps' );
    is( $overlapping->( 5,  25 ), 1, 'Period containing the booking overlaps' );
    is( $overlapping->( 21, 25 ), 0, 'Period after the booking does not overlap without lead/trail' );

    # lead=3, trail=2: effective period today+7 to today+22
    is( $overlapping->( 21, 25, 3, 2 ), 1, 'Period starting inside the trail period overlaps' );
    is( $overlapping->( 23, 25, 3, 2 ), 1, 'Period whose lead period reaches the booking overlaps' );
    is( $overlapping->( 26, 30, 3, 2 ), 0, 'Period starting after the effective period does not overlap' );

    # Cancelled booking: today+30 to today+35
    $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                item_id    => $item->itemnumber,
                start_date => $day->(30),
                end_date   => $day->(35),
                status     => 'cancelled',
            }
        }
    );
    is( $overlapping->( 31, 33 ), 1, 'Status is not considered by filter_by_overlapping alone' );
    is(
        $biblio->bookings->filter_by_active->filter_by_overlapping(
            { start_date => $day->(31), end_date => $day->(33) }
        )->count,
        0,
        'Cancelled booking is excluded when chained with filter_by_active'
    );

    $schema->storage->txn_rollback;
};
