#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 5;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Acquisition::Booksellers;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() and delete() tests | authorized user' => sub {

    plan tests => 35;

    $schema->storage->txn_begin;

    $schema->resultset('Aqbasket')->search->delete;
    Koha::Acquisition::Booksellers->search->delete;
    my ( $borrowernumber, $session_id )
        = create_user_and_session( { authorized => 1 } );

    ## Authorized user tests
    # No vendors, so empty array should be returned
    my $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( [] );

    my $vendor_name = 'Ruben libros';
    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers', value => { name => $vendor_name } });

    # One vendor created, should get returned
    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/$vendor_name/ );

    my $other_vendor_name = 'Amerindia';
    my $other_vendor
        = $builder->build_object({ class => 'Koha::Acquisition::Booksellers', value => { name => $other_vendor_name } });

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ )
      ->json_like( '/1/name' => qr/Amerindia/ );

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors?name=' . $vendor_name );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ );

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors?name=' . $other_vendor_name );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/Amerindia/ );

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors?accountnumber=' . $vendor->accountnumber );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/Ruben/ );

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors?accountnumber=' . $other_vendor->accountnumber );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/Amerindia/ );

    $tx = $t->ua->build_tx( DELETE => '/api/v1/acquisitions/vendors/' . $vendor->id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->content_is(q{""});

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_like( '/0/name' => qr/$other_vendor_name/ )
      ->json_hasnt( '/1', 'Only one vendor' );

    $tx = $t->ua->build_tx( DELETE => '/api/v1/acquisitions/vendors/' . $other_vendor->id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->content_is(q{""});

    $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/vendors' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( [] );

    $schema->storage->txn_rollback;
};

subtest 'get() test' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $vendor = $builder->build_object({ class => 'Koha::Acquisition::Booksellers' });
    my ( $borrowernumber, $session_id )
        = create_user_and_session( { authorized => 1 } );

    my $tx = $t->ua->build_tx( GET => "/api/v1/acquisitions/vendors/" . $vendor->id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( Koha::REST::V1::Acquisitions::Vendors::_to_api( $vendor->TO_JSON ) );

    my $non_existent_id = $vendor->id + 1;
    $tx = $t->ua->build_tx( GET => "/api/v1/acquisitions/vendors/" . $non_existent_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404)
      ->json_is( '/error' => 'Vendor not found' );

    my ( $unauthorized_borrowernumber, $unauthorized_session_id )
        = create_user_and_session( { authorized => 0 } );
    $tx = $t->ua->build_tx( GET => "/api/v1/acquisitions/vendors/" . $vendor->id );
    $tx->req->cookies( { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is( '/error', 'Authorization failure. Missing required permission(s).' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id )
        = create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id )
        = create_user_and_session( { authorized => 1 } );
    my $vendor = { name => 'Ruben libros' };

    # Unauthorized attempt to write
    my $tx = $t->ua->build_tx( POST => "/api/v1/acquisitions/vendors" => json => $vendor );
    $tx->req->cookies( { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $vendor_with_invalid_field = {
        name     => 'Amerindia',
        address5 => 'An address'
    };

    $tx = $t->ua->build_tx(
        POST => "/api/v1/acquisitions/vendors" => json => $vendor_with_invalid_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {   message => "Properties not allowed: address5.",
                path    => "/body"
            }
          ]
        );

    # Authorized attempt to write
    $tx = $t->ua->build_tx( POST => "/api/v1/acquisitions/vendors" => json => $vendor );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    my $vendor_id = $t->request_ok($tx)
                      ->status_is(200)
                      ->json_is( '/name' => $vendor->{name} )
                      ->json_is( '/address1' => $vendor->{address1} )->tx->res->json('/id')
        ;    # read the response vendor id for later use

    # Authorized attempt to create with null id
    $vendor->{id} = undef;
    $tx = $t->ua->build_tx( POST => "/api/v1/acquisitions/vendors" => json => $vendor );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_has('/errors');

    # Authorized attempt to create with existing id
    $vendor->{id} = $vendor_id;
    $tx = $t->ua->build_tx( POST => "/api/v1/acquisitions/vendors" => json => $vendor );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
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

    my ( $unauthorized_borrowernumber, $unauthorized_session_id )
        = create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id )
        = create_user_and_session( { authorized => 1 } );

    my $vendor_id = $builder->build( { source => 'Aqbookseller' } )->{id};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx( PUT => "/api/v1/acquisitions/vendors/$vendor_id" => json =>
            { city_name => 'New unauthorized name change' } );
    $tx->req->cookies( { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    # Attempt partial update on a PUT
    my $vendor_without_mandatory_field = { address1 => 'New address' };

    $tx = $t->ua->build_tx( PUT => "/api/v1/acquisitions/vendors/$vendor_id" => json =>
            $vendor_without_mandatory_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $vendor_with_updated_field = { name => "London books", };

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/acquisitions/vendors/$vendor_id" => json => $vendor_with_updated_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( '/name' => 'London books' );

    # Authorized attempt to write invalid data
    my $vendor_with_invalid_field = {
        blah     => "Blah",
        address1 => "Address 1",
        address2 => "Address 2",
        address3 => "Address 3"
    };

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/acquisitions/vendors/$vendor_id" => json => $vendor_with_invalid_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {   message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
      );

    my $non_existent_id = $vendor_id + 1;
    $tx = $t->ua->build_tx( PUT => "/api/v1/acquisitions/vendors/$non_existent_id" => json =>
            $vendor_with_updated_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404);

    $schema->storage->txn_rollback;

    # Wrong method (POST)
    $vendor_with_updated_field->{id} = 2;

    $tx = $t->ua->build_tx(
        POST => "/api/v1/acquisitions/vendors/$vendor_id" => json => $vendor_with_updated_field );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404);
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id )
        = create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id )
        = create_user_and_session( { authorized => 1 } );

    my $vendor_id = $builder->build( { source => 'Aqbookseller' } )->{id};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx( DELETE => "/api/v1/acquisitions/vendors/$vendor_id" );
    $tx->req->cookies( { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx( DELETE => "/api/v1/acquisitions/vendors/$vendor_id" );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->content_is(q{""});

    $tx = $t->ua->build_tx( DELETE => "/api/v1/acquisitions/vendors/$vendor_id" );
    $tx->req->cookies( { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args = shift;
    my $flags = ( $args->{authorized} ) ? 2052 : 0;

    # my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh = C4::Context->dbh;

    my $user = $builder->build(
        {   source => 'Borrower',
            value  => { flags => $flags }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    if ( $args->{authorized} ) {
        $dbh->do(
            q{
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,11,'vendors_manage')},
            undef, $user->{borrowernumber}
        );
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
