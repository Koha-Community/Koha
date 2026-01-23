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
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $t = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**27 }    # recalls flag == 27
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/recalls' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( [] );

    my $recall_1 = $builder->build_object( { class => 'Koha::Recalls', value => { patron_id => $patron->id } } );
    my $recall_2 = $builder->build_object( { class => 'Koha::Recalls', value => { patron_id => $patron->id } } );

    # Add another patron
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $recall_3 = $builder->build_object( { class => 'Koha::Recalls', value => { patron_id => $patron_2->id } } );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron->id . '/recalls?_order_by=+me.recall_id' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => [ $recall_1->to_api, $recall_2->to_api ], 'Recalls retrieved' );

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->id . '/recalls?_order_by=+me.recall_id' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => [ $recall_3->to_api ], 'Recalls retrieved' );

    $recall_3->delete;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $patron_2->id . '/recalls?_order_by=+me.recall_id' )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( [] );

    my $non_existent_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $non_existent_patron_id = $non_existent_patron->id;

    # get rid of the patron
    $non_existent_patron->delete;

    $t->get_ok( "//$userid:$password@/api/v1/patrons/" . $non_existent_patron_id . '/recalls' )
        ->status_is(404)
        ->json_is( '/error' => 'Patron not found' );

    $schema->storage->txn_rollback;
};
