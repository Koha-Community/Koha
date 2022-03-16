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

use Koha::ERM::Agreements;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::ERM::Agreements->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28}
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
    # No agreements, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")->status_is(200)
      ->json_is( [] );

    my $agreement =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );

    # One agreement created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")->status_is(200)
      ->json_is( [ $agreement->to_api ] );

    my $another_agreement = $builder->build_object(
        {
            class => 'Koha::ERM::Agreements',
            value => { vendor_id => $agreement->vendor_id }
        }
    );
    my $agreement_with_another_vendor_id =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );

    # Two agreements created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements")->status_is(200)
      ->json_is(
        [
            $agreement->to_api,
            $another_agreement->to_api,
            $agreement_with_another_vendor_id->to_api
        ]
      );

    # Filtering works, two agreements sharing vendor_id
    $t->get_ok( "//$userid:$password@/api/v1/erm/agreements?vendor_id="
          . $agreement->vendor_id )->status_is(200)
      ->json_is( [ $agreement->to_api, $another_agreement->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/erm/agreements?blah=blah")
      ->status_is(400)
      ->json_is(
        [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/agreements")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $agreement =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );
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

    $t->get_ok( "//$userid:$password@/api/v1/erm/agreements/"
          . $agreement->agreement_id )->status_is(200)
      ->json_is( $agreement->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/agreements/"
          . $agreement->agreement_id )->status_is(403);

    my $agreement_to_delete =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );
    my $non_existent_id = $agreement_to_delete->id;
    $agreement_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/erm/agreements/$non_existent_id")
      ->status_is(404)->json_is( '/error' => 'Agreement not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 22;

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

    my $agreement = {
        vendor_id => undef,
        name             => "Agreement name",
        description      => "Agreement description",
        status           => "active",
        closure_reason   => "",
        is_perpetual     => 1,
        renewal_priority => "",
        license_info     => "Agreement license_info",
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/erm/agreements" => json =>
          $agreement )->status_is(403);

    # Authorized attempt to write invalid data
    my $agreement_with_invalid_field = {
        blah             => "Agreement Blah",
        name             => "Agreement name",
        description      => "Agreement description",
        status           => "active",
        closure_reason   => "",
        is_perpetual     => 1,
        renewal_priority => "",
        license_info     => "Agreement license_info",
    };

    $t->post_ok( "//$userid:$password@/api/v1/erm/agreements" => json =>
          $agreement_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $agreement_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/erm/agreements" => json => $agreement )
      ->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^/api/v1/erm/agreements/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/vendor_id' => $agreement->{vendor_id} )
      ->json_is( '/name'             => $agreement->{name} )
      ->json_is( '/description'      => $agreement->{description} )
      ->json_is( '/status'           => $agreement->{status} )
      ->json_is( '/closure_reason'   => $agreement->{closure_reason} )
      ->json_is( '/is_perpetual'     => $agreement->{is_perpetual} )
      ->json_is( '/renewal_priority' => $agreement->{renewal_priority} )
      ->json_is( '/license_info'     => $agreement->{license_info} )
      ->tx->res->json->{agreement_id};

    # Authorized attempt to create with null id
    $agreement->{agreement_id} = undef;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/agreements" => json => $agreement )
      ->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $agreement->{agreement_id} = $agreement_id;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/agreements" => json => $agreement )
      ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/agreement_id"
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

    my $agreement_id =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } )->agreement_id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/erm/agreements/$agreement_id" =>
          json => { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $agreement_with_missing_field = {
        description      => 'New description',
        status           => 'active',
        closure_reason   => undef,
        is_perpetual     => 1,
        renewal_priority => undef,
        license_info     => 'New license_info',
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/agreements/$agreement_id" => json =>
          $agreement_with_missing_field )->status_is(400)
      ->json_is( "/errors" =>
          [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $agreement_with_updated_field = {
        vendor_id        => undef,
        name             => 'New name',
        description      => 'New description',
        status           => 'closed',
        closure_reason   => undef,
        is_perpetual     => 1,
        renewal_priority => undef,
        license_info     => 'New license_info',
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/agreements/$agreement_id" => json =>
          $agreement_with_updated_field )->status_is(200)
      ->json_is( '/name' => 'New name' );

    # Authorized attempt to write invalid data
    my $agreement_with_invalid_field = {
        blah             => "Agreement Blah",
        name             => "Agreement name",
        description      => "Agreement description",
        status           => "closed",
        closure_reason   => undef,
        is_perpetual     => 1,
        renewal_priority => undef,
        license_info     => "Agreement license_info",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/agreements/$agreement_id" => json =>
          $agreement_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    my $agreement_to_delete =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );
    my $non_existent_id = $agreement_to_delete->id;
    $agreement_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/erm/agreements/$non_existent_id" =>
          json => $agreement_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $agreement_with_updated_field->{agreement_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/agreements/$agreement_id" => json =>
          $agreement_with_updated_field )->status_is(404);

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

    my $agreement_id =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/erm/agreements/$agreement_id")
      ->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/erm/agreements/$agreement_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/erm/agreements/$agreement_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};

