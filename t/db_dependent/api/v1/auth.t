#!/usr/bin/env perl

# Copyright 2016 Koha-Suomi
#
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

use Test::More tests => 4;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use C4::Context;
use Koha::Auth::PermissionManager;
use Koha::AuthUtils;
use Koha::Database;
use Koha::DateUtils;

use DateTime::Format::HTTP;
use Digest::SHA qw( hmac_sha256_hex );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');
my $tx;

subtest 'under() tests' => sub {
    plan tests => 21;

    $schema->storage->txn_begin;

    my ($borrowernumber, $session_id) = create_user_and_session();

    # 401 (no authentication)
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', 'Authentication failure.');

    # 401 (authenticating as database user)
    my $db_session = C4::Auth::get_session('');
    $db_session->param( 'number', 0);
    $db_session->param( 'id',     C4::Context->config('user'));
    $db_session->param('ip', '127.0.0.1');
    $db_session->param('lasttime', time());
    $db_session->flush;
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
     $tx->req->cookies(
        { name => 'CGISESSID', value => $db_session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', 'Please do not use the API as the database '
                .'administrative user. This could cause problems!');

    # 401 (anonymous session)
    my $anon_session = C4::Auth::get_session('');
    $anon_session->param( 'sessiontype', 'anon');
    $anon_session->param('ip', '127.0.0.1');
    $anon_session->param('lasttime', time());
    $anon_session->flush;
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
     $tx->req->cookies(
        { name => 'CGISESSID', value => $anon_session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', 'Unknown authenticated user. Perhaps you have '
                .'an anonymous session?');


    # 403 (no permission)
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error', 'Authorization failure. Missing required permission(s).');

    # 401 (session expired)
    my $session = C4::Auth::get_session($session_id);
    $session->delete;
    $session->flush;
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', 'Session has been expired.');

    # 503 (under maintenance & pending update)
    my $ver = C4::Context->preference('Version');
    t::lib::Mocks::mock_preference('Version', 1);
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(503)
      ->json_is('/error', 'System is under maintenance.');

    # 503 (under maintenance & database not installed)
    t::lib::Mocks::mock_preference('Version', undef);
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(503)
      ->json_is('/error', 'System is under maintenance.');

    t::lib::Mocks::mock_preference('Version', $ver);

    $schema->storage->txn_rollback;
};

subtest 'Authorization header tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ($borrowernumber, $session_id) = create_user_and_session();
    my $apikey = $builder->build(
        {
            source => 'ApiKey',
            value  => {
                borrowernumber => $borrowernumber,
                active => 1,
            }
        }
    );
    Koha::Auth::PermissionManager->grantAllSubpermissions(
        $borrowernumber, 'borrowers'
    );
    my $kohadate = DateTime::Format::HTTP->format_datetime();
    my $signature = hmac_sha256_hex("GET $borrowernumber $kohadate", $apikey->{api_key});

    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $tx->req->headers->header('X-Koha-Date' => $kohadate);
    $tx->req->headers->header('Authorization' => "Koha $borrowernumber:$signature");
    $t->request_ok($tx)
      ->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'get() test (get_api_session)' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $password = "2anxious? if someone finds out";

    t::lib::Mocks::mock_preference('TrackLastPatronActivity', 1);

    my ($nobody, $sessionid) = create_user_and_session();
    my $b = Koha::Patrons->find($nobody);
    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            email => 'testinen@example.com',
            cardnumber => '1A01',
            firstname => 'Juhani',
            surname => 'Seplae',
            branchcode   => $branchcode,
            categorycode => $categorycode,
            lost     => 0,
            password => Koha::AuthUtils::hash_password($password),
        }
    });

    my $borrowernumber = $borrower->{borrowernumber};
    my $patron = Koha::Patrons->find($borrowernumber);
    Koha::Auth::PermissionManager->grantPermissions($patron, {
        'auth' => 'get_session'
    });

    my $key = $builder->build({
        source => 'ApiKey',
        value  => {
            borrowernumber => $borrowernumber,
            active => 1,
        }
    });
    my $kohadate = DateTime::Format::HTTP->format_datetime();
    my $sig = hmac_sha256_hex("GET $borrowernumber $kohadate", $key->{api_key});

    my $tx = $t->ua->build_tx( GET => "/api/v1/auth/session", json => {
        sessionid => $sessionid
    });
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $tx->req->headers->header('X-Koha-Date' => $kohadate);
    $tx->req->headers->header('Authorization' => "Koha $borrowernumber:$sig");
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/firstname' => $b->firstname, "Get human firstname")
      ->json_has('/sessionid', "Get human sessionid");

    Koha::Auth::PermissionManager->revokeAllPermissions($patron);
    $tx = $t->ua->build_tx( GET => "/api/v1/auth/session", json => {
        sessionid => $sessionid
    });
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $tx->req->headers->header('X-Koha-Date' => $kohadate);
    $tx->req->headers->header('Authorization' => "Koha $borrowernumber:$sig");
    $t->request_ok($tx)
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'post() test (login & logout)' => sub {
    plan tests => 42;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $password = "2anxious? if someone finds out";

    t::lib::Mocks::mock_preference('TrackLastPatronActivity', 1);

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            lost     => 0,
            password => Koha::AuthUtils::hash_password($password),
        }
    });
    my $patron = Koha::Patrons->find($borrower->{borrowernumber});

    my $auth_by_userid = {
        userid => $borrower->{userid},
        password => $password,
    };
    my $auth_by_cardnumber = {
        cardnumber => $borrower->{cardnumber},
        password => $password,
    };
    my $invalid_login = {
        userid => $borrower->{userid},
        password => "please let me in",
    };
    my $invalid_login2 = {
        cardnumber => $borrower->{cardnumber},
        password => "my password is password, don't tell anyone",
    };

    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $auth_by_userid);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/firstname', $borrower->{firstname})
      ->json_is('/surname', $borrower->{surname})
      ->json_is('/borrowernumber', $borrower->{borrowernumber})
      ->json_is('/email', $borrower->{email})
      ->json_has('/sessionid');

    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $auth_by_cardnumber);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/firstname', $borrower->{firstname})
      ->json_is('/surname', $borrower->{surname})
      ->json_is('/borrowernumber', $borrower->{borrowernumber})
      ->json_is('/email', $borrower->{email})
      ->json_has('/sessionid');
    my $sessionid = $tx->res->json->{sessionid};

    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $invalid_login);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', "Login failed.");

    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $invalid_login2);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', "Login failed.");

    $patron->set({ lost => 1 })->store;
    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $auth_by_userid);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error' =>
            "Patron's card has been marked as 'lost'. Access forbidden.");
    $patron->set({ lost => 0 })->store;

    $tx = $t->ua->build_tx(DELETE => '/api/v1/auth/session' =>
                           json => { sessionid => $sessionid."123" });
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401)
      ->json_is('/error', "Invalid session id.");

    my ($sess_status, $sid) = C4::Auth::check_cookie_auth($sessionid);
    is($sess_status, "ok", "Session is valid before logging out.");
    $tx = $t->ua->build_tx(DELETE => '/api/v1/auth/session' =>
                           json => { sessionid => $sessionid });
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    ($sess_status, $sid) = C4::Auth::check_cookie_auth($sessionid);
    isnt($sess_status, "ok", "Session is not valid after logging out.");

    $tx = $t->ua->build_tx(POST => '/api/v1/auth/session' =>
                           form => $auth_by_cardnumber);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/firstname', $borrower->{firstname})
      ->json_is('/surname', $borrower->{surname})
      ->json_is('/borrowernumber', $borrower->{borrowernumber})
      ->json_is('/email', $borrower->{email})
      ->json_has('/sessionid');
    $sessionid = $tx->res->json->{sessionid};

    subtest 'check patron lastseen' => sub {
        plan tests => 4;

        my $patron_ls = Koha::Patrons->find($borrower->{borrowernumber});
        ok(defined $patron_ls, 'Found patron');
        my $lastseen = dt_from_string($patron_ls->lastseen);
        is(ref($lastseen), 'DateTime', '$lastseen is a DateTime object');
        my $now = dt_from_string();
        my $max_accepted = dt_from_string()->subtract( seconds => 5 );

        is(DateTime->compare($max_accepted, $lastseen), -1,
           'Lastseen greater than now-5 seconds');
        ok(DateTime->compare($lastseen, $now) <= 0,
           'Lastseen less or equal than now');
    };

    ($sess_status, $sid) = C4::Auth::check_cookie_auth($sessionid);
    is($sess_status, "ok", "Session is valid before logging out.");
    $tx = $t->ua->build_tx(DELETE => '/api/v1/auth/session');
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    ($sess_status, $sid) = C4::Auth::check_cookie_auth($sessionid);
    isnt($sess_status, "ok", "Session is not valid after logging out.");

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => 0,
                lost => 0,
            }
        }
    );

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    return ( $user->{borrowernumber}, $session->id );
}

1;
