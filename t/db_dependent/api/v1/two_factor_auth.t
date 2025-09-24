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

use Test::More tests => 3;
use Test::NoWarnings;
use Test::Mojo;
use Test::MockModule;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

my $mocked_koha_email = Test::MockModule->new('Koha::Email');
$mocked_koha_email->mock(
    'send_or_die',
    sub {
        return 1;
    }
);

subtest 'registration and verification' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'enabled' );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 20,    # Staff access and Patron info
            }
        }
    );

    # Not authenticated yet - 401
    my $session = C4::Auth::get_session('');
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration/verification" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(401);

    # Authenticated - can register
    $session->param( 'number', $patron->borrowernumber );
    $session->param( 'id',     $patron->userid );
    $session->flush;

    $patron->auth_method('password');
    $patron->secret(undef);
    $patron->store;

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    {
        # Ignore the following warning
        # Use of uninitialized value $aMask[1383] in bitwise xor (^) at /usr/local/share/perl/5.36.0/GD/Barcode/QRcode.pm line 217.
        # We do not want to expect it (using Test::Warn): it is a bug from GD::Barcode
        local $SIG{__WARN__} = sub { };
        my $dup_err;
        local *STDERR;
        open STDERR, ">>", \$dup_err;

        $t->request_ok($tx)->status_is(201);

        close STDERR;
    }
    my $secret32 = $t->tx->res->json->{secret32};

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration/verification" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(400);    # Missing parameter

    my $auth     = Koha::Auth::TwoFactorAuth->new( { patron => $patron, secret32 => $secret32 } );
    my $pin_code = $auth->code;
    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration/verification" => form =>
            { secret32 => $secret32, pin_code => $pin_code } );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(204);

    $patron = $patron->get_from_storage;
    is( $patron->auth_method, 'two-factor' );
    isnt( $patron->secret, undef );

    $patron->auth_method('password');
    $patron->secret(undef);
    $patron->store;

    # Setting up 2FA - can register
    $session->param( 'waiting-for-2FA-setup', 1 );
    $session->flush;
    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    {
        # Ignore the following warning
        # Use of uninitialized value $aMask[1383] in bitwise xor (^) at /usr/local/share/perl/5.36.0/GD/Barcode/QRcode.pm line 217.
        # We do not want to expect it (using Test::Warn): it is a bug from GD::Barcode
        local $SIG{__WARN__} = sub { };
        my $dup_err;
        local *STDERR;
        open STDERR, ">>", \$dup_err;

        $t->request_ok($tx)->status_is(201);

        close STDERR;
    }
    $secret32 = $t->tx->res->json->{secret32};

    $auth     = Koha::Auth::TwoFactorAuth->new( { patron => $patron, secret32 => $secret32 } );
    $pin_code = $auth->code;
    $tx       = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration/verification" => form =>
            { secret32 => $secret32, pin_code => $pin_code } );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(204);

    $patron = $patron->get_from_storage;
    is( $patron->auth_method, 'two-factor' );
    isnt( $patron->secret, undef );

    # 2FA already enabled - cannot register again
    $patron->auth_method('two-factor');
    $patron->encode_secret("nv4v65dpobpxgzldojsxiii");
    $patron->store;

    $session->param( 'waiting-for-2FA-setup', undef );
    $session->flush;

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(401);

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/two-factor/registration/verification" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(401);

    $schema->storage->txn_rollback;
};

subtest 'send_otp_token' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'enabled' );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 20,    # Staff access and Patron info
            }
        }
    );

    my $session = C4::Auth::get_session('');
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/otp/token_delivery" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    # Session is still anonymous, no borrowernumber yet: Unauthorized
    $t->request_ok($tx)->status_is(401);

    # Patron is partially authenticated (credentials correct)
    $session->param( 'number',          $patron->borrowernumber );
    $session->param( 'id',              $patron->userid );
    $session->param( 'waiting-for-2FA', 1 );
    $session->flush;

    $patron->library->set(
        {
            branchemail      => 'from@example.org',
            branchreturnpath => undef,
            branchreplyto    => undef,
        }
    )->store;
    $patron->auth_method('two-factor');
    $patron->encode_secret("nv4v65dpobpxgzldojsxiii");
    $patron->email(undef);
    $patron->store;

    $tx = $t->ua->build_tx( POST => "/api/v1/auth/otp/token_delivery" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    # Invalid email
    $t->request_ok($tx)->status_is(400)->json_is( { error => 'email_not_sent' } );

    $patron->email('to@example.org')->store;
    $tx = $t->ua->build_tx( POST => "/api/v1/auth/otp/token_delivery" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    # Everything is ok, the email will be sent
    $t->request_ok($tx)->status_is(200);

    # Change flags: not enough authorization anymore
    $patron->flags(16)->store;
    $tx = $t->ua->build_tx( POST => "/api/v1/auth/otp/token_delivery" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);
    $patron->flags(20)->store;

    # Patron is fully authenticated, cannot request a token again
    $session->param( 'waiting-for-2FA', 0 );
    $session->flush;
    $tx = $t->ua->build_tx( POST => "/api/v1/auth/otp/token_delivery" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(401);

    $schema->storage->txn_rollback;
};

1;
