#!/usr/bin/perl

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

use Mojolicious::Lite;

use Koha::Database;
use Koha::Session;
use Koha::Token;

use t::lib::Mocks;

app->log->level('error');

plugin 'Koha::REST::Plugin::CSRF';

# Dummy routes for testing
get '/test' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

post '/test' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

put '/test' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

del '/test' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

patch '/test' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

use Test::NoWarnings;
use Test::More tests => 8;
use Test::Mojo;

my $schema = Koha::Database->new->schema;
my $t      = Test::Mojo->new;

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'GET requests bypass CSRF check' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    $t->get_ok('/test')->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'HEAD requests bypass CSRF check' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $tx = $t->ua->build_tx( HEAD => '/test' );
    $t->request_ok($tx);

    $schema->storage->txn_rollback;
};

subtest 'POST without CGISESSID cookie bypasses CSRF check' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    $t->post_ok('/test')->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'POST with CGISESSID but no CSRF-TOKEN returns 403' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $tx = $t->ua->build_tx( POST => '/test' );
    $tx->req->cookies( { name => 'CGISESSID', value => 'a_session_id' } );
    $t->request_ok($tx)->status_is(403)->json_is( '/error', 'Wrong CSRF token' );

    $schema->storage->txn_rollback;
};

subtest 'POST with CGISESSID and invalid CSRF-TOKEN returns 403' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $tx = $t->ua->build_tx( POST => '/test' );
    $tx->req->cookies( { name => 'CGISESSID', value => 'a_session_id' } );
    $tx->req->headers->header( 'CSRF-TOKEN', 'bogus_token' );
    $t->request_ok($tx)->status_is(403)->json_is( '/error', 'Wrong CSRF token' );

    $schema->storage->txn_rollback;
};

subtest 'POST with CGISESSID and valid CSRF-TOKEN succeeds' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $session    = Koha::Session->get_session( {} );
    my $session_id = $session->id;
    my $csrf_token = Koha::Token->new->generate_csrf( { session_id => $session_id } );

    my $tx = $t->ua->build_tx( POST => '/test' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->headers->header( 'CSRF-TOKEN', $csrf_token );
    $t->request_ok($tx)->status_is(200)->json_is( '/ok', 1 );

    $schema->storage->txn_rollback;
};

subtest 'PUT and DELETE with valid CSRF-TOKEN succeed' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $session    = Koha::Session->get_session( {} );
    my $session_id = $session->id;
    my $csrf_token = Koha::Token->new->generate_csrf( { session_id => $session_id } );

    my $tx = $t->ua->build_tx( PUT => '/test' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->headers->header( 'CSRF-TOKEN', $csrf_token );
    $t->request_ok($tx)->status_is(200)->json_is( '/ok', 1 );

    $tx = $t->ua->build_tx( DELETE => '/test' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->headers->header( 'CSRF-TOKEN', $csrf_token );
    $t->request_ok($tx)->status_is(200)->json_is( '/ok', 1 );

    $schema->storage->txn_rollback;
};
