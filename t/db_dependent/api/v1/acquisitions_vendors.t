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

use Koha::Acquisition::Booksellers;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() and delete() tests | authorized user' => sub {

    plan tests => 40;

    $schema->storage->txn_begin;

    $schema->resultset('Aqbasket')->search->delete;
    Koha::Acquisition::Booksellers->search->delete;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 11 } ## 11 => acquisitions
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    ## Authorized user tests
    # No vendors, so empty array should be returned
    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" )
      ->status_is(200)
      ->json_is( [] );

    my $vendor_name = 'Ruben libros';
    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers', value => { name => $vendor_name } });

    # One vendor created, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" )
      ->status_is(200)
      ->json_like( '/0/name' => qr/$vendor_name/ );

    my $other_vendor_name = 'Amerindia';
    my $other_vendor
        = $builder->build_object({ class => 'Koha::Acquisition::Booksellers', value => { name => $other_vendor_name } });

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" )
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ )
      ->json_like( '/1/name' => qr/Amerindia/ );

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors?name=$vendor_name" )
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ );

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors?name=$other_vendor_name" )
      ->status_is(200)
      ->json_like( '/0/name' => qr/Amerindia/ );


    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors?accountnumber=" . $vendor->accountnumber )
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ );

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors?accountnumber=" . $other_vendor->accountnumber )
      ->status_is(200)
      ->json_like( '/0/name' => qr/Amerindia/ );

    my @aliases = ( { alias => 'alias 1' }, { alias => 'alias 2' } );
    $vendor->aliases( \@aliases );
    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" =>
        { 'x-koha-embed' => 'aliases' } )
      ->status_is(200)
      ->json_has('/0/aliases', 'aliases are embeded')
      ->json_is('/0/aliases/0/alias' => 'alias 1', 'alias 1 is embeded')
      ->json_is('/0/aliases/1/alias' => 'alias 2', 'alias 2 is embeded');

    $t->delete_ok( "//$userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" )
      ->status_is(200)
      ->json_like( '/0/name' => qr/$other_vendor_name/ )
      ->json_hasnt( '/1', 'Only one vendor' );

    $t->delete_ok( "//$userid:$password@/api/v1/acquisitions/vendors/" . $other_vendor->id )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors" )
      ->status_is(200)
      ->json_is( [] );

    $schema->storage->txn_rollback;
};

subtest 'get() test' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' });
    my $nonexistent_vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' });
    my $non_existent_id = $nonexistent_vendor->id;
    $nonexistent_vendor->delete;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 11 } ## 11 => acquisitions
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(200)
      ->json_is( $vendor->to_api );

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors/" . $non_existent_id )
      ->status_is(404)
      ->json_is( '/error' => 'Vendor not found' );

    # remove permissions
    $patron->set({ flags => 0 })->store;

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(403)
      ->json_is( '/error', 'Authorization failure. Missing required permission(s).' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 11 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 0 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $vendor = { name => 'Ruben libros' };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/acquisitions/vendors" => json => $vendor )
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $vendor_with_invalid_field = {
        name     => 'Amerindia',
        address5 => 'An address'
    };

    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors" => json => $vendor_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {   message => "Properties not allowed: address5.",
                path    => "/body"
            }
          ]
        );

    # Authorized attempt to write
    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors" => json => $vendor )
      ->status_is( 201, 'SWAGGER3 .2.1' )
      ->header_like( Location => qr|^\/api\/v1\/acquisitions\/vendors/\d*|, 'SWAGGER3.4.1')
      ->json_is( '/name' => $vendor->{name} )
      ->json_is( '/address1' => $vendor->{address1} );

    # read the response vendor id for later use
    my $vendor_id = $t->tx->res->json('/id');

    # Authorized attempt to create with null id
    $vendor->{id} = undef;
    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors" => json => $vendor )
      ->status_is(400)
      ->json_has('/errors');

    # Authorized attempt to create with existing id
    $vendor->{id} = $vendor_id;
    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors" => json => $vendor )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {   message => "Read-only.",
                path    => "/body/id"
            }
        ]
    );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 11 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 0 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' } );

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/acquisitions/vendors/"
          . $vendor->id => json =>
          { city_name => 'New unauthorized name change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $vendor_without_mandatory_field = { address1 => 'New address' };

    $t->put_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/"
          . $vendor->id => json => $vendor_without_mandatory_field )
      ->status_is(400)
      ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $vendor_with_updated_field = { name => "London books", };

    $t->put_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/"
          . $vendor->id => json => $vendor_with_updated_field )
      ->status_is(200)
      ->json_is( '/name' => 'London books' );

    # Authorized attempt to write invalid data
    my $vendor_with_invalid_field = {
        blah     => "Blah",
        address1 => "Address 1",
        address2 => "Address 2",
        address3 => "Address 3"
    };

    $t->put_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/"
          . $vendor->id => json => $vendor_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {   message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
      );

    my $nonexistent_vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' } );
    my $non_existent_id = $nonexistent_vendor->id;
    $nonexistent_vendor->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/"
          . $non_existent_id => json => $vendor_with_updated_field )
      ->status_is(404);

    $schema->storage->txn_rollback;

    # Wrong method (POST)
    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/"
          . $vendor->id => json => $vendor_with_updated_field )
      ->status_is(404);
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 11 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 0 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' } );

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(403);

    $t->delete_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok( "//$auth_userid:$password@/api/v1/acquisitions/vendors/" . $vendor->id )
      ->status_is(404);

    $schema->storage->txn_rollback;
};
