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

use JSON qw(encode_json);

use Koha::Database;
use Koha::Auth::Identity::Providers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
t::lib::Mocks::mock_preference( 'SessionStorage',     'tmp' );
t::lib::Mocks::mock_preference( 'OPACBaseURL',        'https://opac.example.org' );
t::lib::Mocks::mock_preference( 'staffClientBaseURL', 'https://staff.example.org' );

subtest 'login - initial request without CGISESSID cookie (IdP-initiated)' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Create a real identity provider
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                protocol => 'OIDC',
                config   => encode_json(
                    {
                        key            => 'test_client_id',
                        secret         => 'test_client_secret',
                        authorize_url  => 'https://idp.example.org/authorize',
                        token_url      => 'https://idp.example.org/token',
                        well_known_url => 'https://idp.example.org/.well-known/openid-configuration',
                    }
                ),
                mapping    => '{}',
                matchpoint => 'email',
            }
        }
    );

    # Create a domain allowing OPAC access
    $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => {
                identity_provider_id => $provider->identity_provider_id,
                domain               => undef,
                allow_opac           => 1,
                allow_staff          => 0,
            }
        }
    );

    # Need a fresh Test::Mojo so the app picks up the new provider
    my $t = Test::Mojo->new('Koha::REST::V1');

    # Hit the login endpoint without a CGISESSID cookie (IdP-initiated flow)
    my $tx = $t->ua->build_tx( GET => '/api/v1/public/oauth/login/' . $provider->code . '/opac' );
    $t->request_ok($tx)->status_is( 302, 'Redirects (not 500)' );

    # Should redirect to the IdP's authorize URL
    my $location = $t->tx->res->headers->location;
    like( $location, qr{https://idp\.example\.org/authorize}, 'Redirects to IdP authorize URL' );

    # Should have set a CGISESSID cookie
    my @cookies = @{ $t->tx->res->cookies };
    my ($session_cookie) = grep { $_->name eq 'CGISESSID' } @cookies;
    ok( $session_cookie, 'CGISESSID cookie was set for the new session' );

    $schema->storage->txn_rollback;
};

subtest 'login - callback without CGISESSID cookie' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                protocol => 'OIDC',
                config   => encode_json(
                    {
                        key           => 'test_client_id',
                        secret        => 'test_client_secret',
                        authorize_url => 'https://idp.example.org/authorize',
                        token_url     => 'https://idp.example.org/token',
                    }
                ),
                mapping    => '{}',
                matchpoint => 'email',
            }
        }
    );

    my $t = Test::Mojo->new('Koha::REST::V1');

    # Hit the callback endpoint without a CGISESSID cookie
    my $tx = $t->ua->build_tx(
        GET => '/api/v1/public/oauth/login/' . $provider->code . '/opac?code=fake_code&state=fake_state' );
    $t->request_ok($tx)->status_is( 302, 'Redirects (not 500)' );

    # Should redirect with wrong_csrf_token error
    my $location = $t->tx->res->headers->location;
    like( $location, qr{auth_error=wrong_csrf_token}, 'Redirects with wrong_csrf_token error' );

    $schema->storage->txn_rollback;
};

subtest 'login - initial request WITH CGISESSID cookie (normal flow)' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                protocol => 'OIDC',
                config   => encode_json(
                    {
                        key           => 'test_client_id',
                        secret        => 'test_client_secret',
                        authorize_url => 'https://idp.example.org/authorize',
                        token_url     => 'https://idp.example.org/token',
                    }
                ),
                mapping    => '{}',
                matchpoint => 'email',
            }
        }
    );

    my $t = Test::Mojo->new('Koha::REST::V1');

    # Create a session first
    my $session    = Koha::Session->get_session( {} );
    my $session_id = $session->id;

    # Hit the login endpoint WITH a CGISESSID cookie (normal SP-initiated flow)
    my $tx = $t->ua->build_tx( GET => '/api/v1/public/oauth/login/' . $provider->code . '/opac' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $t->request_ok($tx)->status_is( 302, 'Redirects to IdP' );

    my $location = $t->tx->res->headers->location;
    like( $location, qr{https://idp\.example\.org/authorize}, 'Redirects to IdP authorize URL' );

    $schema->storage->txn_rollback;
};
