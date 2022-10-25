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

use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ERM::EHoldings::Resources;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::ERM::EHoldings::Resources->search->delete;

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
    # No resources, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/resources")
      ->status_is(200)->json_is( [] );

    my $resource =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Resources' } );

    # One resource created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/resources")
      ->status_is(200)->json_is( [ $resource->to_api ] );

    my $another_resource = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Resources',
            value => { vendor_id => $resource->vendor_id }
        }
    );
    my $resource_with_another_vendor_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Resources' } );

    # Two resources created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/resources")
      ->status_is(200)->json_is(
        [
            $resource->to_api,
            $another_resource->to_api,
            $resource_with_another_vendor_id->to_api
        ]
      );

    # Filtering works, two resources sharing vendor_id
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/resources?vendor_id="
          . $resource->vendor_id )->status_is(200)
      ->json_is( [ $resource->to_api, $another_resource->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/resources?blah=blah")
      ->status_is(400)
      ->json_is(
        [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/resources")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $resource =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Resources' } );
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

    # This resource exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/erm/eholdings/local/resources/"
          . $resource->resource_id )->status_is(200)
      ->json_is( $resource->to_api );

    # Unauthorized access
    $t->get_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/resources/"
          . $resource->resource_id )->status_is(403);

    # Attempt to get non-existent resource
    my $resource_to_delete =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Resources' } );
    my $non_existent_id = $resource_to_delete->resource_id;
    $resource_to_delete->delete;

    $t->get_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/resources/$non_existent_id"
    )->status_is(404)->json_is( '/error' => 'eHolding resource not found' );

    $schema->storage->txn_rollback;
};
