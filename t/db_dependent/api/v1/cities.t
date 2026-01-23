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
use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Cities;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::Cities->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    ## Authorized user tests
    # No cities, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)->json_is( [] );

    my $city = $builder->build_object( { class => 'Koha::Cities' } );

    # One city created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)->json_is( [ $city->to_api ] );

    my $another_city =
        $builder->build_object( { class => 'Koha::Cities', value => { city_country => $city->city_country } } );
    my $city_with_another_country = $builder->build_object( { class => 'Koha::Cities' } );

    # Two cities created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)->json_is(
        [
            $city->to_api,
            $another_city->to_api,
            $city_with_another_country->to_api
        ]
    );

    # Filtering works, two cities sharing city_country
    $t->get_ok( "//$userid:$password@/api/v1/cities?country=" . $city->city_country )->status_is(200)->json_is(
        [
            $city->to_api,
            $another_city->to_api
        ]
    );

    $t->get_ok( "//$userid:$password@/api/v1/cities?name=" . $city->city_name )
        ->status_is(200)
        ->json_is( [ $city->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/cities?city_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/city_blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/cities")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $city      = $builder->build_object( { class => 'Koha::Cities' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/cities/" . $city->cityid )->status_is(200)->json_is( $city->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/cities/" . $city->cityid )->status_is(403);

    my $city_to_delete  = $builder->build_object( { class => 'Koha::Cities' } );
    my $non_existent_id = $city_to_delete->id;
    $city_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/cities/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'City not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters flag = 2
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

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $city = {
        name        => "City Name",
        state       => "City State",
        postal_code => "City Zipcode",
        country     => "City Country"
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/cities" => json => $city )->status_is(403);

    # Authorized attempt to write invalid data
    my $city_with_invalid_field = {
        blah        => "City Blah",
        state       => "City State",
        postal_code => "City Zipcode",
        country     => "City Country"
    };

    $t->post_ok( "//$userid:$password@/api/v1/cities" => json => $city_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
    );

    # Authorized attempt to write
    my $city_id =
        $t->post_ok( "//$userid:$password@/api/v1/cities" => json => $city )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/cities/\d*|,
        'REST3.4.1'
        )
        ->json_is( '/name'        => $city->{name} )
        ->json_is( '/state'       => $city->{state} )
        ->json_is( '/postal_code' => $city->{postal_code} )
        ->json_is( '/country'     => $city->{country} )
        ->tx->res->json->{city_id};

    # Authorized attempt to create with null id
    $city->{city_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/cities" => json => $city )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $city->{city_id} = $city_id;
    $t->post_ok( "//$userid:$password@/api/v1/cities" => json => $city )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/city_id"
            }
        ]
    );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters flag = 2
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

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $city_id = $builder->build_object( { class => 'Koha::Cities' } )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/cities/$city_id" => json => { name => 'New unauthorized name change' } )
        ->status_is(403);

    # Attempt partial update on a PUT
    my $city_with_missing_field = {
        name    => 'New name',
        state   => 'New state',
        country => 'New country'
    };

    $t->put_ok( "//$userid:$password@/api/v1/cities/$city_id" => json => $city_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/postal_code" } ] );

    # Full object update on PUT
    my $city_with_updated_field = {
        name        => "London",
        state       => "City State",
        postal_code => "City Zipcode",
        country     => "City Country"
    };

    $t->put_ok( "//$userid:$password@/api/v1/cities/$city_id" => json => $city_with_updated_field )
        ->status_is(200)
        ->json_is( '/name' => 'London' );

    # Authorized attempt to write invalid data
    my $city_with_invalid_field = {
        blah        => "City Blah",
        state       => "City State",
        postal_code => "City Zipcode",
        country     => "City Country"
    };

    $t->put_ok( "//$userid:$password@/api/v1/cities/$city_id" => json => $city_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    my $city_to_delete  = $builder->build_object( { class => 'Koha::Cities' } );
    my $non_existent_id = $city_to_delete->id;
    $city_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/cities/$non_existent_id" => json => $city_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $city_with_updated_field->{city_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/cities/$city_id" => json => $city_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters flag = 2
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

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $city_id = $builder->build_object( { class => 'Koha::Cities' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/cities/$city_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/cities/$city_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/cities/$city_id")->status_is(404);

    $schema->storage->txn_rollback;
};
