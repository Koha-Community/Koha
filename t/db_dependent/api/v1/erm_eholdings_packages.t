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

use Koha::ERM::EHoldings::Packages;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    Koha::ERM::EHoldings::Packages->search->delete;

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
    # No EHoldings package, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/packages")
      ->status_is(200)->json_is( [] );

    my $ehpackage = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Packages',
            value => { external_id => undef }
        }
    );

    # One EHoldings package created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/packages")
      ->status_is(200)->json_is( [ $ehpackage->to_api ] );

    my $another_ehpackage = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Packages',
            value => {
                package_type => $ehpackage->package_type,
                external_id  => undef
            }
        }
    );
    my $ehpackage_with_another_package_type = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Packages',
            value => { external_id => undef }
        }
    );

    # Two EHoldings packages created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/packages")
      ->status_is(200)->json_is(
        [
            $ehpackage->to_api,
            $another_ehpackage->to_api,
            $ehpackage_with_another_package_type->to_api
        ]
      );

    # Filtering works, two EHoldings packages sharing package_type
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages?package_type="
          . $ehpackage->package_type )->status_is(200)
      ->json_is( [ $ehpackage->to_api, $another_ehpackage->to_api ] );

    # Attempt to search by name like 'ko'
    $ehpackage->delete;
    $another_ehpackage->delete;
    $ehpackage_with_another_package_type->delete;
    $t->get_ok(
qq~//$userid:$password@/api/v1/erm/eholdings/local/packages?q=[{"me.name":{"like":"%ko%"}}]~
    )->status_is(200)->json_is( [] );

    my $ehpackage_to_search = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Packages',
            value => {
                name        => 'koha',
                external_id => undef
            }
        }
    );

    # Search works, searching for name like 'ko'
    $t->get_ok(
qq~//$userid:$password@/api/v1/erm/eholdings/local/packages?q=[{"me.name":{"like":"%ko%"}}]~
    )->status_is(200)->json_is( [ $ehpackage_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages?blah=blah")
      ->status_is(400)
      ->json_is(
        [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/packages")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $ehpackage =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } );
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

    # This EHoldings package exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/erm/eholdings/local/packages/"
          . $ehpackage->package_id )->status_is(200)
      ->json_is( $ehpackage->to_api );

    # Return one EHoldings package with embed
    $t->get_ok( "//$userid:$password@/api/v1/erm/eholdings/local/packages/"
          . $ehpackage->package_id =>
          { 'x-koha-embed' => 'resources,resources.package' } )->status_is(200)
      ->json_is( { %{ $ehpackage->to_api }, resources => [] } );

    # Unauthorized access
    $t->get_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/packages/"
          . $ehpackage->package_id )->status_is(403);

    # Attempt to get non-existent EHoldings package
    my $ehpackage_to_delete =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } );
    my $non_existent_id = $ehpackage_to_delete->package_id;
    $ehpackage_to_delete->delete;

    $t->get_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/packages/$non_existent_id"
    )->status_is(404)->json_is( '/error' => 'Package not found' );

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

    my $ehpackage = {
        name         => "Package name",
        package_type => "Package type",
        content_type => "Content type",
        notes        => "Notes"
    };

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/packages" =>
          json => $ehpackage )->status_is(403);

    # Authorized attempt to write invalid data
    my $ehpackage_with_invalid_field = {
        blah => "EHolding Package Blah",
        name => "Package name",
    };

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages" => json =>
          $ehpackage_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $ehpackage_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages" => json =>
          $ehpackage )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^/api/v1/erm/eholdings/local/packages/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/name' => $ehpackage->{name} )
      ->json_is( '/print_identifier' => $ehpackage->{print_identifier} )
      ->json_is( '/notes'            => $ehpackage->{notes} )
      ->json_is( '/publisher_name'   => $ehpackage->{publisher_name} )
      ->tx->res->json->{package_id};

    # Authorized attempt to create with null id
    $ehpackage->{package_id} = undef;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages" => json =>
          $ehpackage )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $ehpackage->{package_id} = $ehpackage_id;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages" => json =>
          $ehpackage )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/package_id"
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

    my $ehpackage_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } )
      ->package_id;

    # Unauthorized attempt to update
    $t->put_ok(
"//$unauth_userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
          => json => { name => 'New unauthorized name change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $ehpackage_with_missing_field = { package_type => "Package type", };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
          => json => $ehpackage_with_missing_field )->status_is(400)
      ->json_is( "/errors" =>
          [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $ehpackage_with_updated_field = {
        name         => "Package name",
        package_type => "Package type",
        content_type => "Content type",
        notes        => "Notes"
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
          => json => $ehpackage_with_updated_field )->status_is(200)
      ->json_is( '/name' => 'Package name' );

    # Authorized attempt to write invalid data
    my $ehpackage_with_invalid_field = {
        blah => "EHolding Package Blah",
        name => "Package name",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
          => json => $ehpackage_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Attempt to update non-existent EHolding package
    my $ehpackage_to_delete =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } );
    my $non_existent_id = $ehpackage_to_delete->package_id;
    $ehpackage_to_delete->delete;

    $t->put_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/packages/$non_existent_id"
          => json => $ehpackage_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $ehpackage_with_updated_field->{package_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
          => json => $ehpackage_with_updated_field )->status_is(404);

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

    my $ehpackage_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } )
      ->package_id;

    # Unauthorized attempt to delete
    $t->delete_ok(
"//$unauth_userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
    )->status_is(403);

    # Delete existing EHolding package
    $t->delete_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
    )->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    # Attempt to delete non-existent EHolding package
    $t->delete_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/packages/$ehpackage_id"
    )->status_is(404);

    $schema->storage->txn_rollback;
};

