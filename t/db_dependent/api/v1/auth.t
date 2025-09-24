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
use Test::More tests => 4;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth qw( get_session );
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');
my $tx;

subtest 'under() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session();

    # disable the /public namespace
    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 0 );
    $tx = $t->ua->build_tx( POST => "/api/v1/public/patrons/$borrowernumber/password" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403)
        ->json_is( '/error', 'Configuration prevents the usage of this endpoint by unprivileged users' );

    # enable the /public namespace
    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    $tx = $t->ua->build_tx( GET => "/api/v1/public/patrons/$borrowernumber/password" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(404);

    # 401 (no authentication)
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(401)->json_is( '/error', 'Authentication failure.' );

    # 403 (no permission)
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403)->json_is( '/error', 'Authorization failure. Missing required permission(s).' );

    # 401 (session expired)
    t::lib::Mocks::mock_preference( 'timeout', '1' );
    ( $borrowernumber, $session_id ) = create_user_and_session();
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    sleep(2);
    $t->request_ok($tx)->status_is(401)->json_is( '/error', 'Session has been expired.' );

    # 503 (under maintenance & pending update)
    t::lib::Mocks::mock_preference( 'Version', 1 );
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(503)->json_is( '/error', 'System is under maintenance.' );

    # 503 (under maintenance & database not installed)
    t::lib::Mocks::mock_preference( 'Version', undef );
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(503)->json_is( '/error', 'System is under maintenance.' );

    # 503 (public while maintenance syspref activated)
    t::lib::Mocks::mock_preference( 'OPACMaintenance', 1 );
    t::lib::Mocks::mock_preference( 'RESTPublicAPI',   1 );
    $tx = $t->ua->build_tx( GET => "/api/v1/public/libraries" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(503)->json_is( '/error', 'Under maintenance' );
    t::lib::Mocks::mock_preference( 'OPACMaintenance', 0 );
    t::lib::Mocks::mock_preference( 'RESTPublicAPI',   0 );

    $schema->storage->txn_rollback;
};

subtest 'CORS support' => sub {

    plan tests => 6;

    t::lib::Mocks::mock_preference( 'AccessControlAllowOrigin', '' );
    $t->get_ok("/api/v1/patrons")->header_is( 'Access-control-allow-origin', undef, 'Header not returned' );

    # FIXME: newer Test::Mojo has header_exists_not

    t::lib::Mocks::mock_preference( 'AccessControlAllowOrigin', undef );
    $t->get_ok("/api/v1/patrons")->header_is( 'Access-control-allow-origin', undef, 'Header not returned' );

    # FIXME: newer Test::Mojo has header_exists_not

    t::lib::Mocks::mock_preference( 'AccessControlAllowOrigin', '*' );
    $t->get_ok("/api/v1/patrons")->header_is( 'Access-control-allow-origin', '*', 'Header set' );
};

subtest 'spec retrieval tests' => sub {

    plan tests => 4;

    $t->get_ok("/api/v1/")->status_is(200);

    $t->get_ok("/api/v1/.html")->status_is(200);
};

sub create_user_and_session {
    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => { flags => 0 }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $user->{borrowernumber}, $session->id );
}

1;
