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
use Test::More tests => 2;

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
