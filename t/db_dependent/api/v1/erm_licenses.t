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

use Koha::ERM::Licenses;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    Koha::ERM::Licenses->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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
    # No licenses, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/licenses")->status_is(200)
      ->json_is( [] );

    my $license =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } );

    # One license created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/licenses")->status_is(200)
      ->json_is( [ $license->to_api ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/licenses")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $license =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    $t->get_ok( "//$userid:$password@/api/v1/erm/licenses/"
          . $license->license_id )->status_is(200)
      ->json_is( $license->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/licenses/"
          . $license->license_id )->status_is(403);

    my $license_to_delete =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } );
    my $non_existent_id = $license_to_delete->id;
    $license_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/erm/licenses/$non_existent_id")
      ->status_is(404)->json_is( '/error' => 'License not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    my $license = {
        name             => "License name",
        description      => "License description",
        type             => 'local',
        status           => "active",
        started_on       => undef,
        ended_on         => undef,
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/erm/licenses" => json =>
          $license )->status_is(403);

    # Authorized attempt to write invalid data
    my $license_with_invalid_field = {
        blah             => "License Blah",
        name             => "License name",
        description      => "License description",
        type             => 'local',
        status           => "active",
        started_on       => undef,
        ended_on         => undef,
    };

    $t->post_ok( "//$userid:$password@/api/v1/erm/licenses" => json =>
          $license_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $license_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/erm/licenses" => json => $license )
      ->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^/api/v1/erm/licenses/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/name'             => $license->{name} )
      ->json_is( '/description'     => $license->{description} )
      ->json_is( '/type'            => $license->{type} )
      ->json_is( '/status'          => $license->{status} )
      ->tx->res->json->{license_id};

    # Authorized attempt to create with null id
    $license->{license_id} = undef;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/licenses" => json => $license )
      ->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $license->{license_id} = $license_id;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/licenses" => json => $license )
      ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/license_id"
            }
        ]
      );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    my $license_id =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } )->license_id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/erm/licenses/$license_id" =>
          json => { name => 'New unauthorized name change' } )->status_is(403);

    # Full object update on PUT
    my $license_with_updated_field = {
        name             => 'New name',
        description      => 'New description',
        type             => 'national',
        status           => 'expired',
        started_on       => undef,
        ended_on         => undef,
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/licenses/$license_id" => json =>
          $license_with_updated_field )->status_is(200)
      ->json_is( '/name' => 'New name' );

    # Authorized attempt to write invalid data
    my $license_with_invalid_field = {
        blah             => "License Blah",
        name             => "License name",
        description      => "License description",
        type             => 'national',
        status           => 'expired',
        started_on       => undef,
        ended_on         => undef,
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/licenses/$license_id" => json =>
          $license_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    my $license_to_delete =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } );
    my $non_existent_id = $license_to_delete->id;
    $license_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/erm/licenses/$non_existent_id" =>
          json => $license_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $license_with_updated_field->{license_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/licenses/$license_id" => json =>
          $license_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    my $license_id =
      $builder->build_object( { class => 'Koha::ERM::Licenses' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/erm/licenses/$license_id")
      ->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/erm/licenses/$license_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/erm/licenses/$license_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};

