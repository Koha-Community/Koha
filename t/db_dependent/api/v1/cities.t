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

use Data::Printer colored => 1;

use C4::Auth;
use Koha::Cities;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    Koha::Cities->search->delete;
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 0 } );

    ## Authorized user tests
    # No cities, so empty array should be returned
    my $tx = $t->ua->build_tx( GET => '/api/v1/cities' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [] );

    my $city_country = 'France';
    my $city         = $builder->build(
        { source => 'City', value => { city_country => $city_country } } );

    # One city created, should get returned
    $tx = $t->ua->build_tx( GET => '/api/v1/cities' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [$city] );

    my $another_city = $builder->build(
        { source => 'City', value => { city_country => $city_country } } );
    my $city_with_another_country = $builder->build( { source => 'City' } );

    # Two cities created, they should both be returned
    $tx = $t->ua->build_tx( GET => '/api/v1/cities' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)
      ->json_is( [ $city, $another_city, $city_with_another_country ] );

    # Filtering works, two cities sharing city_country
    $tx =
      $t->ua->build_tx( GET => "/api/v1/cities?city_country=" . $city_country );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [ $city, $another_city ] );

    $tx = $t->ua->build_tx(
        GET => "/api/v1/cities?city_name=" . $city->{city_name} );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [$city] );

    $tx = $t->ua->build_tx( GET => '/api/v1/cities?city_blah=blah' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    warning_like {
        $t->request_ok($tx)->status_is(500)
          ->json_like( '/error' => qr/Unknown column/ );
    }
    qr/Unknown column/, 'Wrong parameters raise warnings';

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $city = $builder->build( { source => 'City' } );
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 0 } );

    my $tx = $t->ua->build_tx( GET => "/api/v1/cities/" . $city->{cityid} );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is($city);

    my $non_existent_id = $city->{cityid} + 1;
    $tx = $t->ua->build_tx( GET => "/api/v1/cities/" . $non_existent_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404)
      ->json_is( '/error' => 'City not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );
    my $city = {
        city_name    => "City Name",
        city_state   => "City State",
        city_zipcode => "City Zipcode",
        city_country => "City Country"
    };

    # Unauthorized attempt to write
    my $tx = $t->ua->build_tx( POST => "/api/v1/cities/" => json => $city );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);

    # Authorized attempt to write
    $tx = $t->ua->build_tx( POST => "/api/v1/cities/" => json => $city );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)
      ->json_is( '/city_name'    => $city->{city_name} )
      ->json_is( '/city_state'   => $city->{city_state} )
      ->json_is( '/city_zipcode' => $city->{city_zipcode} )
      ->json_is( '/city_country' => $city->{city_country} );

    my $city_with_invalid_field = {
        city_blah    => "City Blah",
        city_state   => "City State",
        city_zipcode => "City Zipcode",
        city_country => "City Country"
    };

    # Authorized attempt to write invalid data
    $tx = $t->ua->build_tx(
        POST => "/api/v1/cities/" => json => $city_with_invalid_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(500);

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $city_id = $builder->build( { source => 'City' } )->{cityid};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx( PUT => "/api/v1/cities/$city_id" => json =>
          { city_name => 'New unauthorized name change' } );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/cities/$city_id" => json => { city_name => 'New name' }
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( '/city_name' => 'New name' );

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/cities/$city_id" => json => { city_blah => 'New blah' }
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(500)
      ->json_is( '/error' => "No method city_blah for Koha::City" );

    my $non_existent_id = $city_id + 1;
    $tx = $t->ua->build_tx( PUT => "/api/v1/cities/$non_existent_id" => json =>
          { city_name => 'New name' } );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $city_id = $builder->build( { source => 'City' } )->{cityid};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx( DELETE => "/api/v1/cities/$city_id" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);

    $tx = $t->ua->build_tx( DELETE => "/api/v1/cities/$city_id" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->content_is('');

    $tx = $t->ua->build_tx( DELETE => "/api/v1/cities/$city_id" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags
            }
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
        $dbh->do( "
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,3,'parameters_remaining_permissions')", undef,
            $user->{borrowernumber} );
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
