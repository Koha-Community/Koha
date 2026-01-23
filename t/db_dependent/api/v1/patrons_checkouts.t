#!/usr/bin/env perl

# This file is part of Koha.
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
use Test::MockModule;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'Patron checkouts list() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/checkouts' )->status_is(200)->json_is( [] );

    my $date_due = dt_from_string->add( weeks => 2 );
    my $item1    = $builder->build_sample_item;
    my $item2    = $builder->build_sample_item;

    my $issue1 = C4::Circulation::AddIssue( $patron, $item1->barcode, $date_due );
    my $issue2 = C4::Circulation::AddIssue( $patron, $item2->barcode, $date_due );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/checkouts' )
        ->status_is(200)
        ->json_is( '/0/item_id' => $item1->itemnumber )
        ->json_is( '/1/item_id' => $item2->itemnumber );

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;
    $non_existent_patron->delete;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $non_existent_patron_id . '/checkouts' )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $unauthorized_password = 'thePassword456';

    $unauthorized_patron->set_password( { password => $unauthorized_password, skip_validation => 1 } );
    my $unauthorized_userid = $unauthorized_patron->userid;

    $t->get_ok( "//$unauthorized_userid:$unauthorized_password@/api/v1/patrons/" . $patron->id . '/checkouts' )
        ->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );
    }
