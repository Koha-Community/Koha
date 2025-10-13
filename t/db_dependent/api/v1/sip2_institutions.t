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

use Koha::SIP2::Institutions;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    Koha::SIP2::Institutions->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
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
    # No institutions, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions")->status_is(200)->json_is( [] );

    my $institution = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );

    # One institution created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions")->status_is(200)->json_is( [ $institution->to_api ] );

    my $another_institution = $builder->build_object(
        {
            class => 'Koha::SIP2::Institutions',
            value => { implementation => 'ILS' }
        }
    );

    # Two institutions created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions")->status_is(200)->json_is(
        [
            $institution->to_api,
            $another_institution->to_api,
        ]
    );

    # Filtering works, single institution with queried implementation
    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions?implementation=ILS")->status_is(200)
        ->json_is( [ $another_institution->to_api ] );

    # Attempt to search by name like 'ko'
    $institution->delete;
    $another_institution->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/institutions?q=[{"me.name":{"like":"%ko%"}}]~)->status_is(200)
        ->json_is( [] );

    my $institution_to_search = $builder->build_object(
        {
            class => 'Koha::SIP2::Institutions',
            value => {
                name => 'koha',
            }
        }
    );

    # Search works, searching for name like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/sip2/institutions?q=[{"me.name":{"like":"%ko%"}}]~)->status_is(200)
        ->json_is( [ $institution_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions?blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/sip2/institutions")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $institution = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );
    my $librarian   = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
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

    # This institution exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/sip2/institutions/" . $institution->sip_institution_id )->status_is(200)
        ->json_is( $institution->to_api );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/sip2/institutions/" . $institution->sip_institution_id )
        ->status_is(403);

    # Attempt to get non-existent institution
    my $institution_to_delete = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );
    my $non_existent_id       = $institution_to_delete->sip_institution_id;
    $institution_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/sip2/institutions/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'Institution not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
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

    my $institution = {
        name           => "Institution name",
        implementation => "ILS",
        retries        => 5,
        timeout        => 100,
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/sip2/institutions" => json => $institution )->status_is(403);

    # Authorized attempt to write invalid data
    my $institution_with_invalid_field = {
        blah           => "Institution Blah",
        name           => "Institution name",
        implementation => "ILS",
        retries        => 5,
        timeout        => 100,
    };

    $t->post_ok( "//$userid:$password@/api/v1/sip2/institutions" => json => $institution_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $sip_institution_id =
        $t->post_ok( "//$userid:$password@/api/v1/sip2/institutions" => json => $institution )
        ->status_is( 201, 'REST3.2.1' )->header_like(
        Location => qr|^/api/v1/sip2/institutions/\d*|,
        'REST3.4.1'
    )->json_is( '/name' => $institution->{name} )->json_is( '/implementation' => $institution->{implementation} )
        ->json_is( '/retries' => $institution->{retries} )->json_is( '/timeout' => $institution->{timeout} )
        ->tx->res->json->{sip_institution_id};

    # Authorized attempt to create with null id
    $institution->{sip_institution_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/sip2/institutions" => json => $institution )->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $institution->{sip_institution_id} = $sip_institution_id;

    $t->post_ok( "//$userid:$password@/api/v1/sip2/institutions" => json => $institution )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/sip_institution_id"
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
            value => { flags => 2**31 }
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

    my $sip_institution_id = $builder->build_object( { class => 'Koha::SIP2::Institutions' } )->sip_institution_id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/sip2/institutions/$sip_institution_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $institution_with_missing_field = {
        implementation => "ILS",
        retries        => 5,
        timeout        => 100,
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id" => json => $institution_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $institution_with_updated_field = {
        name           => "New institution name",
        implementation => "ILS",
        retries        => 5,
        timeout        => 100,
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id" => json => $institution_with_updated_field )
        ->status_is(200)->json_is( '/name' => 'New institution name' );

    # Authorized attempt to write invalid data
    my $institution_with_invalid_field = {
        blah           => "Institution Blah",
        name           => "Institution name",
        implementation => "ILS",
        retries        => 5,
        timeout        => 100,
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id" => json => $institution_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Attempt to update non-existent institution
    my $institution_to_delete = $builder->build_object( { class => 'Koha::SIP2::Institutions' } );
    my $non_existent_id       = $institution_to_delete->id;
    $institution_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/sip2/institutions/$non_existent_id" => json => $institution_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $institution_with_updated_field->{sip_institution_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id" => json => $institution_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**31 }
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

    my $sip_institution_id = $builder->build_object( { class => 'Koha::SIP2::Institutions' } )->sip_institution_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/sip2/institutions/$sip_institution_id")->status_is(403);

    # Delete existing institution
    $t->delete_ok("//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id")->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent institution
    $t->delete_ok("//$userid:$password@/api/v1/sip2/institutions/$sip_institution_id")->status_is(404);

    $schema->storage->txn_rollback;
};
