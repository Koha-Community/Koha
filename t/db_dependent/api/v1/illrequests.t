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

use Test::More tests => 1;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Illrequests;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 1 } );

    ## Authorized user tests
    # No requests, so empty array should be returned
    my $tx = $t->ua->build_tx( GET => '/api/v1/illrequests' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [] );

#    my $city_country = 'France';
#    my $city         = $builder->build(
#        { source => 'City', value => { city_country => $city_country } } );
#
#    # One city created, should get returned
#    $tx = $t->ua->build_tx( GET => '/api/v1/cities' );
#    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#    $tx->req->env( { REMOTE_ADDR => $remote_address } );
#    $t->request_ok($tx)->status_is(200)->json_is( [$city] );
#
#    my $another_city = $builder->build(
#        { source => 'City', value => { city_country => $city_country } } );
#    my $city_with_another_country = $builder->build( { source => 'City' } );
#
#    # Two cities created, they should both be returned
#    $tx = $t->ua->build_tx( GET => '/api/v1/cities' );
#    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#    $tx->req->env( { REMOTE_ADDR => $remote_address } );
#    $t->request_ok($tx)->status_is(200)
#      ->json_is( [ $city, $another_city, $city_with_another_country ] );
#
#    # Filtering works, two cities sharing city_country
#    $tx =
#      $t->ua->build_tx( GET => "/api/v1/cities?city_country=" . $city_country );
#    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#    $tx->req->env( { REMOTE_ADDR => $remote_address } );
#    my $result =
#      $t->request_ok($tx)->status_is(200)->json_is( [ $city, $another_city ] );
#
#    $tx = $t->ua->build_tx(
#        GET => "/api/v1/cities?city_name=" . $city->{city_name} );
#    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#    $tx->req->env( { REMOTE_ADDR => $remote_address } );
#    $t->request_ok($tx)->status_is(200)->json_is( [$city] );

    # Warn on unsupported query parameter
    $tx = $t->ua->build_tx( GET => '/api/v1/illrequests?request_blah=blah' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(400)->json_is(
        [{ path => '/query/request_blah', message => 'Malformed query string'}]
    );

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
