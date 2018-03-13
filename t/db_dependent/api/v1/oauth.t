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

use t::lib::Mocks;
use t::lib::TestBuilder;

my $t = Test::Mojo->new('Koha::REST::V1');
my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

subtest '/oauth/token tests' => sub {
    plan tests => 19;

    $schema->storage->txn_begin;

    my $patron = $builder->build({
        source => 'Borrower',
        value  => {
            surname => 'Test OAuth',
            flags => 0,
        },
    });

    # Missing parameter grant_type
    $t->post_ok('/api/v1/oauth/token')
        ->status_is(400);

    # Wrong grant type
    $t->post_ok('/api/v1/oauth/token', form => { grant_type => 'password' })
        ->status_is(400)
        ->json_is({error => 'Unimplemented grant type'});

    # No client_id/client_secret
    $t->post_ok('/api/v1/oauth/token', form => { grant_type => 'client_credentials' })
        ->status_is(403)
        ->json_is({error => 'unauthorized_client'});

    my ($client_id, $client_secret) = ('client1', 'secr3t');
    t::lib::Mocks::mock_config('api_client', {
        'client_id' => $client_id,
        'client_secret' => $client_secret,
        patron_id => $patron->{borrowernumber},
    });

    my $formData = {
        grant_type => 'client_credentials',
        client_id => $client_id,
        client_secret => $client_secret,
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
    $builder->build({
        source => 'UserPermission',
        value  => {
            borrowernumber => $patron->{borrowernumber},
            module_bit => 4, # borrowers
            code => 'edit_borrowers',
        },
    });
    $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
    $tx->req->headers->authorization("Bearer $access_token");
    $t->request_ok($tx)->status_is(200);

    $schema->storage->txn_rollback;
};
