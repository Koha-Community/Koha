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

use Mojo::JSON qw(encode_json);

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::StockRotationRotas;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::StockRotationRotas->search->delete;

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
    # No rotas, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/rotas")->status_is(200)->json_is( [] );

    my $active_rota = $builder->build_object( { class => 'Koha::StockRotationRotas', value => { active => 1 } } );

    # One rota created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/rotas")->status_is(200)->json_is( [ $active_rota->to_api ] );

    my $another_active_rota =
        $builder->build_object( { class => 'Koha::StockRotationRotas', value => { active => 1 } } );
    my $inactive_rota = $builder->build_object( { class => 'Koha::StockRotationRotas', value => { active => 0 } } );

    # Three rotas created, all should both be returned
    $t->get_ok("//$userid:$password@/api/v1/rotas")->status_is(200)->json_is(
        [
            $active_rota->to_api, $another_active_rota->to_api,
            $inactive_rota->to_api
        ]
    );

    # Filtering works, two rotas are active
    my $api_filter = encode_json( { 'me.active' => Mojo::JSON->true } );
    $t->get_ok("//$userid:$password@/api/v1/rotas?q=$api_filter")
        ->status_is(200)
        ->json_is( [ $active_rota->to_api, $another_active_rota->to_api ] );

    $api_filter = encode_json( { 'me.title' => $active_rota->title } );
    $t->get_ok("//$userid:$password@/api/v1/rotas?q=$api_filter")->status_is(200)->json_is( [ $active_rota->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok( "//$userid:$password@/api/v1/rotas?title=" . $active_rota->title )
        ->status_is(400)
        ->json_is( [ { path => '/query/title', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/rotas")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $rota      = $builder->build_object( { class => 'Koha::StockRotationRotas' } );
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

    $t->get_ok( "//$userid:$password@/api/v1/rotas/" . $rota->rota_id )->status_is(200)->json_is( $rota->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/rotas/" . $rota->rota_id )->status_is(403);

    my $rota_to_delete  = $builder->build_object( { class => 'Koha::StockRotationRotas' } );
    my $non_existent_id = $rota_to_delete->id;
    $rota_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/rotas/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Rota not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**24 }    # stockrotation flag = 24
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

    my $rota = {
        title       => "Rota Title",
        description => "Rota Description",
        active      => Mojo::JSON->true,
        cyclical    => Mojo::JSON->true
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/rotas" => json => $rota )->status_is(403);

    # Authorized attempt to write invalid data
    my $rota_with_invalid_field = {
        blah        => "Rota Blah",
        description => "Rota Description",
        active      => Mojo::JSON->true,
        cyclical    => Mojo::JSON->true
    };

    $t->post_ok( "//$userid:$password@/api/v1/rotas" => json => $rota_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
    );

    # Authorized attempt to write
    my $rota_id =
        $t->post_ok( "//$userid:$password@/api/v1/rotas" => json => $rota )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/rotas/\d*|,
        'REST3.4.1'
        )
        ->json_is( '/title'       => $rota->{title} )
        ->json_is( '/description' => $rota->{description} )
        ->json_is( '/active'      => $rota->{active} )
        ->json_is( '/cyclical'    => $rota->{cyclical} )
        ->tx->res->json->{rota_id};

    # Authorized attempt to create with null id
    $rota->{rota_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/rotas" => json => $rota )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $rota->{rota_id} = $rota_id;
    $t->post_ok( "//$userid:$password@/api/v1/rotas" => json => $rota )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/rota_id"
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
            value => { flags => 2**24 }    # stockrotation flag = 24
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

    my $rota_id = $builder->build_object( { class => 'Koha::StockRotationRotas' } )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/rotas/$rota_id" => json => { title => 'New unauthorized title change' } )
        ->status_is(403);

    # Attempt partial update on a PUT
    my $rota_with_missing_field = {
        title       => 'New title',
        description => 'New description',
        cyclical    => Mojo::JSON->false
    };

    $t->put_ok( "//$userid:$password@/api/v1/rotas/$rota_id" => json => $rota_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/active" } ] );

    # Full object update on PUT
    my $rota_with_updated_field = {
        title       => "London",
        description => "Rota Description",
        active      => Mojo::JSON->true,
        cyclical    => Mojo::JSON->false
    };

    $t->put_ok( "//$userid:$password@/api/v1/rotas/$rota_id" => json => $rota_with_updated_field )
        ->status_is(200)
        ->json_is( '/title' => 'London' );

    # Authorized attempt to write invalid data
    my $rota_with_invalid_field = {
        blah        => "Rota Blah",
        description => "Rota Description",
        active      => Mojo::JSON->true,
        cyclical    => Mojo::JSON->false
    };

    $t->put_ok( "//$userid:$password@/api/v1/rotas/$rota_id" => json => $rota_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    my $rota_to_delete  = $builder->build_object( { class => 'Koha::StockRotationRotas' } );
    my $non_existent_id = $rota_to_delete->id;
    $rota_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/rotas/$non_existent_id" => json => $rota_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $rota_with_updated_field->{rota_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/rotas/$rota_id" => json => $rota_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**24 }    # stockrotation flag = 24
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

    my $rota_id = $builder->build_object( { class => 'Koha::StockRotationRotas' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/rotas/$rota_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/rotas/$rota_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/rotas/$rota_id")->status_is(404);

    $schema->storage->txn_rollback;
};
