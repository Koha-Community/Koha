#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;
use Try::Tiny;

use Koha::Club::Hold;
use Koha::Club::Hold::PatronHolds;
use Koha::Holds;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Scalar::Util    qw(blessed);

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'add' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $club    = $builder->build_object( { class => 'Koha::Clubs' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $item1   = $builder->build_sample_item( { library => $library->branchcode } );
    my $item2   = $builder->build_sample_item( { library => $library->branchcode } );

    throws_ok {
        Koha::Club::Hold::add( { club_id => $club->id } );
    }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown when biblio_id is passed';

    like( "$@", qr/The biblio_id parameter is mandatory/ );

    throws_ok {
        Koha::Club::Hold::add( { biblio_id => $item1->biblionumber } );
    }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown when club_id is passed';

    like( "$@", qr/The club_id parameter is mandatory/ );

    throws_ok {
        Koha::Club::Hold::add(
            {
                club_id           => $club->id,
                biblio_id         => $item1->biblionumber,
                pickup_library_id => $library->branchcode
            }
        );
    }
    'Koha::Exceptions::ClubHold::NoPatrons',
        'Exception thrown when no patron is enrolled in club';

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );
    my $e = $builder->build_object(
        {
            class => 'Koha::Club::Enrollments',
            value => {
                club_id        => $club->id,
                borrowernumber => $patron->borrowernumber,
                date_canceled  => undef
            }
        }
    );

    my $club_hold = Koha::Club::Hold::add(
        {
            club_id           => $club->id,
            biblio_id         => $item1->biblionumber,
            pickup_library_id => $library->branchcode
        }
    );

    is( blessed($club_hold), 'Koha::Club::Hold', 'add returns a Koha::Club::Hold' );

    $e->date_canceled(dt_from_string)->store;

    throws_ok {
        Koha::Club::Hold::add(
            {
                club_id           => $club->id,
                biblio_id         => $item2->biblionumber,
                pickup_library_id => $library->branchcode
            }
        );
    }
    'Koha::Exceptions::ClubHold::NoPatrons',
        'Exception thrown when no patron is enrolled in club';

    my $patron_holds = Koha::Club::Hold::PatronHolds->search( { club_hold_id => $club_hold->id } );

    ok( $patron_holds->count, "There must be at least one patron_hold" );

    my $patron_hold = $patron_holds->next;

    my $hold = Koha::Holds->find( $patron_hold->hold_id );

    is( $patron_hold->patron_id, $hold->borrowernumber, 'Patron must be the same' );

    $schema->storage->txn_rollback;
    }
