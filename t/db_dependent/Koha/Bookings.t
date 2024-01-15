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

use Test::More tests => 1;

use Koha::Bookings;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

subtest 'filter_by_future' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio  = $builder->build_sample_biblio;
    my $start_0 = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0   = dt_from_string->add( days => 4 )->truncate( to => 'day' );
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
