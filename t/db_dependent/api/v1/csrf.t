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
use Test::More tests => 5;
use Test::Mojo;

use Koha::Database;
use Koha::Session;
use Koha::Token;

use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
my $t      = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'GET with CGISESSID but no CSRF token is allowed' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $tx = $t->ua->build_tx( GET => '/api/v1/patrons' );
    $tx->req->cookies( { name => 'CGISESSID', value => 'fake_session' } );
    $t->request_ok($tx);
    isnt( $t->tx->res->code, 403, 'GET not blocked by CSRF check' );

    $schema->storage->txn_rollback;
};

subtest 'POST without CGISESSID is not blocked by CSRF' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $tx = $t->ua->build_tx( POST => '/api/v1/patrons' );
    $tx->req->headers->content_type('application/json');
    $tx->req->body('{}');
    $t->request_ok($tx);
    isnt( $t->tx->res->code, 403, 'POST without cookie not blocked by CSRF' );

    $schema->storage->txn_rollback;
};

subtest 'POST with CGISESSID but missing/invalid CSRF token returns 403' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # No token
    my $tx = $t->ua->build_tx( POST => '/api/v1/patrons' );
    $tx->req->cookies( { name => 'CGISESSID', value => 'some_session' } );
    $tx->req->headers->content_type('application/json');
    $tx->req->body('{}');
    $t->request_ok($tx)->status_is(403)->json_is( '/error', 'Wrong CSRF token' );

    # Invalid token
    $tx = $t->ua->build_tx( POST => '/api/v1/patrons' );
    $tx->req->cookies( { name => 'CGISESSID', value => 'some_session' } );
    $tx->req->headers->header( 'CSRF-TOKEN', 'invalid' );
    $tx->req->headers->content_type('application/json');
    $tx->req->body('{}');
    $t->request_ok($tx)->status_is(403)->json_is( '/error', 'Wrong CSRF token' );

    $schema->storage->txn_rollback;
};

subtest 'POST with CGISESSID and valid CSRF token passes CSRF check' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $session    = Koha::Session->get_session( {} );
    my $session_id = $session->id;
    my $csrf_token = Koha::Token->new->generate_csrf( { session_id => $session_id } );

    my $tx = $t->ua->build_tx( POST => '/api/v1/patrons' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->headers->header( 'CSRF-TOKEN', $csrf_token );
    $tx->req->headers->content_type('application/json');
    $tx->req->body('{}');
    $t->request_ok($tx);

    # Should NOT be 403 - it passes CSRF and hits auth (401) or validation (400)
    isnt( $t->tx->res->code, 403, 'Valid CSRF token passes the check' );

    $schema->storage->txn_rollback;
};
