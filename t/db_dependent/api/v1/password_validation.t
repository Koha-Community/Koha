#!/usr/bin/perl

#
# This file is part of Koha
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

use Test::More tests => 7;
use Test::Mojo;
use Test::Warn;
use Mojo::JWT;
use Crypt::OpenSSL::RSA;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::AuthUtils;
use C4::Auth;
use Data::Dumper;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';

subtest 'password validation - success' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => $userid,
        "password" => "test",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->content_is('');
    $resp->status_is(204);

    $schema->storage->txn_rollback;
};

subtest 'password validation - account lock out' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 1 );

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => { "username" => $userid, "password" => "bad"} );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    my $resp = $t->request_ok($tx);
    $resp->json_is('/error' => 'Validation failed');
    $resp->status_is(400);

    my $tx2 = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => { "username" => $userid, "password" => "test"} );
    $tx2->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx2->req->env( { REMOTE_ADDR => $remote_address } );
    my $resp2 = $t->request_ok($tx2);
    $resp2->json_is('/error' => 'Validation failed');
    $resp2->status_is(400);

    $schema->storage->txn_rollback;
};


subtest 'password validation - bad username' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => '1234567890abcdefghijklmnopqrstuvwxyz@koha-community.org',
        "password" => "test",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->json_is('/error' => 'Validation failed');
    $resp->status_is(400);

    $schema->storage->txn_rollback;
};

subtest 'password validation - bad password' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => $userid,
        "password" => "bad",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->json_is('/error' => 'Validation failed');
    $resp->status_is(400);

    $schema->storage->txn_rollback;
};

subtest 'password validation - syntax error in payload' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => $userid,
        "password2" => "test",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->json_is('' => {"errors" => [{"message" => "Properties not allowed: password2.","path" => "\/body"}],"status" => 400} );
    $resp->status_is(400);

    $schema->storage->txn_rollback;
};

subtest 'password validation - unauthorized user' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 0 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => $userid,
        "password" => "test",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->json_is('/error' => 'Authorization failure. Missing required permission(s).');
    $resp->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'password validation - unauthenticated user' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 0 } );
    my $patron = Koha::Patrons->find($borrowernumber);
    my $userid = $patron->userid;

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $json = {
        "username" => $userid,
        "password" => "test",
    };

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/password/validation", json => $json );
    #$tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $resp = $t->request_ok($tx);
    $resp->json_is('/error' => 'Authentication failure.');
    $resp->status_is(401);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 1 : 0;

    my $password = Koha::AuthUtils::hash_password('test');
    my $user = $builder->build(
        {   source => 'Borrower',
            value  => { flags => $flags, password => $password }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       $remote_address );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $user->{borrowernumber}, $session->id );
}
