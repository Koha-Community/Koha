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

use Koha::Database;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $t = Test::Mojo->new('Koha::REST::V1');
my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

subtest '/oauth/token tests' => sub {
    plan tests => 27;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value  => {
            flags => 0 # no permissions
        },
    });

    # Missing parameter grant_type
    $t->post_ok('/api/v1/oauth/token')
        ->status_is(400);

    # Wrong grant type
    $t->post_ok('/api/v1/oauth/token', form => { grant_type => 'password' })
        ->status_is(400)
        ->json_is({error => 'Unimplemented grant type'});

    t::lib::Mocks::mock_preference('RESTOAuth2ClientCredentials', 1);

    # No client_id/client_secret
    $t->post_ok('/api/v1/oauth/token', form => { grant_type => 'client_credentials' })
        ->status_is(403)
        ->json_is({error => 'unauthorized_client'});

    my $api_key = Koha::ApiKey->new({ patron_id => $patron->id, description => 'blah' })->store;

    my $formData = {
        grant_type    => 'client_credentials',
        client_id     => $api_key->client_id,
        client_secret => $api_key->secret
    };
    $t->post_ok('/api/v1/oauth/token', form => $formData)
        ->status_is(200)
        ->json_is('/expires_in' => 3600)
        ->json_is('/token_type' => 'Bearer')
        ->json_has('/access_token');

    my $access_token = $t->tx->res->json->{access_token};

    # Without access token, it returns 401
    $t->get_ok('/api/v1/patrons')->status_is(401);

    # With access token, but without permissions, it returns 403
    my $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
    $tx->req->headers->authorization("Bearer $access_token");
    $t->request_ok($tx)->status_is(403);

    # With access token and permissions, it returns 200
    $patron->flags(2**4)->store;
    $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
    $tx->req->headers->authorization("Bearer $access_token");
    $t->request_ok($tx)->status_is(200);

    # expire token
    my $token = Koha::OAuthAccessTokens->find($access_token);
    $token->expires( time - 1 )->store;
    $tx = $t->ua->build_tx( GET => '/api/v1/patrons' );
    $tx->req->headers->authorization("Bearer $access_token");
    $t->request_ok($tx)
      ->status_is(401);

    # revoke key
    $api_key->active(0)->store;
    $t->post_ok('/api/v1/oauth/token', form => $formData)
        ->status_is(403)
        ->json_is({ error => 'unauthorized_client' });

    # disable client credentials grant
    t::lib::Mocks::mock_preference('RESTOAuth2ClientCredentials', 0);

    # enable API key
    $api_key->active(1)->store;
    # Wrong grant type
    $t->post_ok('/api/v1/oauth/token', form => $formData )
        ->status_is(400)
        ->json_is({ error => 'Unimplemented grant type' });

    $schema->storage->txn_rollback;
};
