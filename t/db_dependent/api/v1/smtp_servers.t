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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 5;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::SMTP::Servers;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    Koha::SMTP::Servers->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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
    # No SMTP servers, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/config/smtp_servers")
      ->status_is(200)->json_is( [] );

    my $smtp_server =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );

    # One smtp server created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/config/smtp_servers")
      ->status_is(200)->json_is( [ $smtp_server->to_api ] );

    my $another_smtp_server =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );

    # Two SMTP servers created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/config/smtp_servers")
      ->status_is(200)
      ->json_is( [ $smtp_server->to_api, $another_smtp_server->to_api, ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/config/smtp_servers")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $smtp_server =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    $t->get_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/" . $smtp_server->id )
      ->status_is(200)->json_is( $smtp_server->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/config/smtp_servers/"
          . $smtp_server->id )->status_is(403);

    my $smtp_server_to_delete =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );
    my $non_existent_id = $smtp_server_to_delete->id;
    $smtp_server_to_delete->delete;

    $t->get_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$non_existent_id")
      ->status_is(404)->json_is( '/error' => 'SMTP server not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    Koha::SMTP::Servers->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $smtp_server =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );
    my $smtp_server_data = $smtp_server->to_api;
    delete $smtp_server_data->{smtp_server_id};
    $smtp_server->delete;

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/config/smtp_servers" => json =>
          $smtp_server_data )->status_is(403);

    # Authorized attempt to write invalid data
    my $smtp_server_with_invalid_field = {
        name => 'Some other server',
        blah => 'blah'
    };

    $t->post_ok( "//$userid:$password@/api/v1/config/smtp_servers" => json =>
          $smtp_server_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $smtp_server_id =
      $t->post_ok( "//$userid:$password@/api/v1/config/smtp_servers" => json =>
          $smtp_server_data )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/config\/smtp_servers\/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/name' => $smtp_server_data->{name} )
      ->json_is( '/state'       => $smtp_server_data->{state} )
      ->json_is( '/postal_code' => $smtp_server_data->{postal_code} )
      ->json_is( '/country'     => $smtp_server_data->{country} )
      ->tx->res->json->{smtp_server_id};

    # Authorized attempt to create with null id
    $smtp_server_data->{smtp_server_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/config/smtp_servers" => json =>
          $smtp_server_data )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $smtp_server_data->{smtp_server_id} = $smtp_server_id;
    $t->post_ok( "//$userid:$password@/api/v1/config/smtp_servers" => json =>
          $smtp_server_data )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/smtp_server_id"
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
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $smtp_server_id =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/config/smtp_servers/$smtp_server_id"
          => json => { name => 'New unauthorized name change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $smtp_server_with_missing_field = {
        host     => 'localhost',
        ssl_mode => 'disabled'
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id" =>
          json => $smtp_server_with_missing_field )->status_is(400)
      ->json_is( "/errors" =>
          [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $smtp_server_with_updated_field = { name => "Some name", };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id" =>
          json => $smtp_server_with_updated_field )->status_is(200)
      ->json_is( '/name' => 'Some name' );

    # Authorized attempt to write invalid data
    my $smtp_server_with_invalid_field = {
        blah => "Blah",
        name => 'Some name'
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id" =>
          json => $smtp_server_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    my $smtp_server_to_delete =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } );
    my $non_existent_id = $smtp_server_to_delete->id;
    $smtp_server_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$non_existent_id" =>
          json => $smtp_server_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $smtp_server_with_updated_field->{smtp_server_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id" =>
          json => $smtp_server_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $smtp_server_id =
      $builder->build_object( { class => 'Koha::SMTP::Servers' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/config/smtp_servers/$smtp_server_id"
    )->status_is(403);

    $t->delete_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok(
        "//$userid:$password@/api/v1/config/smtp_servers/$smtp_server_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
