#!/usr/bin/perl

# Copyright 2022 Theke Solutions
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;
use Test::Warn;
use Mojo::JWT;
use Crypt::OpenSSL::RSA;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use C4::Auth;
use Koha::Auth::Identity::Providers;
use Koha::Auth::Identity::Provider::Domains;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';

# use t::lib::IdP::ExternalIdP;

# my $idp_port = t::lib::IdP::ExternalIdP->start;

my $oauth_provider_data = {
    code        => 'oauth_test',
    description => 'OAuth provider',
    protocol    => 'OAuth',
    mapping     => {
        email     => 'users.0.email',
        firstname => 'users.0.custom_name',
        surname   => 'users.0.custom_surname',
        userid    => 'users.0.id'
    },
    matchpoint => 'email',
    config     => {
        authorize_url => "/idp/test/authorization_endpoint",
        token_url     => "/idp/test/token_endpoint/without_id_token",
        userinfo_url  => "/idp/test/userinfo_endpoint",
        key           => "client_id",
        secret        => "client_secret"
    }
};

my $oidc_with_email_provider_data = {
    code        => 'oidc_email',
    description => 'OIDC with email provider',
    protocol    => 'OIDC',
    mapping     => {
        email     => 'email',
        firstname => 'given_name',
        surname   => 'family_name',
        userid    => 'sub'
    },
    matchpoint => 'email',
    config     => {
        authorize_url  => "/idp/test/authorization_endpoint",
        well_known_url => "/idp/test/with_email/.well_known",
        key            => "client_id",
        secret         => "client_secret"
    }
};

my $oidc_without_email_provider_data = {
    code        => 'oidc_no_email',
    description => 'OIDC without email provider',
    protocol    => 'OIDC',
    mapping     => {
        email     => 'users.0.email',
        firstname => 'given_name',
        surname   => 'family_name',
        userid    => 'sub'
    },
    matchpoint => 'email',
    config     => {
        authorize_url  => "/idp/test/authorization_endpoint",
        well_known_url => "/idp/test/without_email/.well_known",
        key            => "client_id",
        secret         => "client_secret"
    }
};

my $domain_not_matching = {
    domain              => 'gmail.com',
    auto_register       => 0,
    update_on_auth      => 0,
    default_library_id  => undef,
    default_category_id => undef,
    allow_opac          => 1,
    allow_staff         => 0
};

my $domain_no_register = {
    domain              => 'some.library.com',
    auto_register       => 0,
    update_on_auth      => 0,
    default_library_id  => undef,
    default_category_id => undef,
    allow_opac          => 1,
    allow_staff         => 0
};

my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
my $category = $builder->build_object( { class => 'Koha::Patron::Categories' } );

my $domain_register = {
    domain              => 'some.library.com',
    auto_register       => 1,
    update_on_auth      => 0,
    default_library_id  => $library->branchcode,
    default_category_id => $category->categorycode,
    allow_opac          => 1,
    allow_staff         => 1
};

my $domain_register_update = {
    domain              => 'some.library.com',
    auto_register       => 1,
    update_on_auth      => 1,
    default_library_id  => $library->branchcode,
    default_category_id => $category->categorycode,
    allow_opac          => 1,
    allow_staff         => 0
};

subtest 'provider endpoint tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    Koha::Auth::Identity::Provider::Domains->delete;
    Koha::Auth::Identity::Providers->delete;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $tx = $t->ua->build_tx( POST => "/api/v1/auth/identity_providers", json => $oauth_provider_data );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(201);

    my $provider = Koha::Auth::Identity::Providers->search( { code => 'oauth_test' } )->next;
    is( $provider->code, 'oauth_test', 'Provider was created' );

    $tx = $t->ua->build_tx( GET => "/api/v1/auth/identity_providers" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->json_has( '/0/code', 'oauth_test' );

    my %modified_provider_data_hash = %{$oauth_provider_data};
    my $modified_provider_data      = \%modified_provider_data_hash;
    $modified_provider_data->{code} = 'some_code';

    $tx = $t->ua->build_tx(
        PUT  => "/api/v1/auth/identity_providers/" . $provider->identity_provider_id,
        json => $modified_provider_data
    );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(200);

    $tx = $t->ua->build_tx( GET => "/api/v1/auth/identity_providers/" . $provider->identity_provider_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->json_has( '/code', 'some_code' );

    $tx = $t->ua->build_tx( DELETE => "/api/v1/auth/identity_providers/" . $provider->identity_provider_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(204);

    $provider = Koha::Auth::Identity::Providers->search->next;
    is( $provider, undef, 'All providers deleted' );

    $schema->storage->txn_rollback;
};

subtest 'domain endpoint tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    Koha::Auth::Identity::Provider::Domains->delete;
    Koha::Auth::Identity::Providers->delete;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );

    my $t = Test::Mojo->new('Koha::REST::V1');

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers' } );

    my $tx = $t->ua->build_tx(
        POST => "/api/v1/auth/identity_providers/" . $provider->identity_provider_id . "/domains",
        json => $domain_not_matching
    );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(201);

    my $domain = Koha::Auth::Identity::Provider::Domains->search( { domain => 'gmail.com' } )->next;
    is( $domain->domain, 'gmail.com', 'Provider was created' );

    $tx = $t->ua->build_tx( GET => "/api/v1/auth/identity_providers/" . $provider->identity_provider_id . "/domains" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->json_has( '/0/domain', 'gmail.com' );

    my %modified_domain_data_hash = %{$domain_not_matching};
    my $modified_domain_data      = \%modified_domain_data_hash;
    $modified_domain_data->{domain} = 'some.domain.com';

    $tx = $t->ua->build_tx(
              PUT => "/api/v1/auth/identity_providers/"
            . $provider->identity_provider_id
            . "/domains/"
            . $domain->identity_provider_domain_id,
        json => $modified_domain_data
    );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(200);

    $tx =
        $t->ua->build_tx( GET => "/api/v1/auth/identity_providers/"
            . $provider->identity_provider_id
            . "/domains/"
            . $domain->identity_provider_domain_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->json_has( '/domain', 'some.domain.com' );

    $tx =
        $t->ua->build_tx( DELETE => "/api/v1/auth/identity_providers/"
            . $provider->identity_provider_id
            . "/domains/"
            . $domain->identity_provider_domain_id );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    $t->request_ok($tx)->status_is(204);

    $domain = Koha::Auth::Identity::Provider::Domains->search->next;
    is( $domain, undef, 'All domains deleted' );

    $schema->storage->txn_rollback;
};

# subtest 'oauth login tests' => sub {
#   plan tests => 4;

#   $schema->storage->txn_begin;

#   Koha::Auth::Identity::Provider::Domains->delete;
#   Koha::Auth::Identity::Providers->delete;

#   my ( $borrowernumber, $session_id ) = create_user_and_session({ authorized => 1 });

#   my $t = Test::Mojo->new('Koha::REST::V1');

#   # Build provider
#   my $tx = $t->ua->build_tx( POST => "/api/v1/auth/identity_providers", json => $oauth_provider_data );
#   $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#   $tx->req->env( { REMOTE_ADDR => $remote_address } );

#   $t->request_ok($tx);
#   my $provider_id = $t->tx->res->json->{identity_provider_id};

#   # Build domain
#   $tx = $t->ua->build_tx( POST => "/api/v1/auth/identity_providers/$provider_id/domains", json => $domain_not_matching );
#   $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
#   $tx->req->env( { REMOTE_ADDR => $remote_address } );

#   $t->request_ok($tx);

#   t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );

#   # Simulate server restart
#   $t = Test::Mojo->new('Koha::REST::V1');

#   #$t->ua->max_redirects(10);
#   $t->get_ok("/api/v1/public/oauth/login/oauth_test/opac")
#     ->status_is(302);
#   $schema->storage->txn_rollback;
# };

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 1 : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => { flags => $flags }
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
