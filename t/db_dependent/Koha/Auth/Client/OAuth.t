#!/usr/bin/env perl

# Copyright 2025 Koha Development Team
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

use Test::More tests => 6;
use Test::MockModule;
use Test::NoWarnings;

use JSON         qw(encode_json);
use MIME::Base64 qw(encode_base64url);

use Koha::Auth::Client::OAuth;
use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_get_data_and_patron() with id_token tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;

    # Create test patron
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { email => 'test@example.com' }
        }
    );

    # Create provider with email matchpoint
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                matchpoint => 'email',
                mapping    => encode_json(
                    {
                        email     => 'mail',
                        firstname => 'given_name',
                        surname   => 'family_name'
                    }
                )
            }
        }
    );

    # Create JWT token with user data
    my $claims = {
        mail        => 'test@example.com',
        given_name  => 'John',
        family_name => 'Doe'
    };

    my $id_token = 'header.' . encode_base64url( encode_json($claims) ) . '.signature';

    my $data   = { id_token => $id_token };
    my $config = {};

    # Test the method
    my ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    # Verify results
    is( $mapped_data->{email},     'test@example.com', 'Email mapped correctly' );
    is( $mapped_data->{firstname}, 'John',             'First name mapped correctly' );
    is( $mapped_data->{surname},   'Doe',              'Surname mapped correctly' );
    is( $found_patron->id,         $patron->id,        'Patron found by email matchpoint' );

    $schema->storage->txn_rollback;
};

subtest '_get_data_and_patron() with userinfo_url tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;

    # Create test patron
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { email => 'userinfo@example.com' }
        }
    );

    # Create provider with email matchpoint
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                matchpoint => 'email',
                mapping    => encode_json(
                    {
                        email     => 'email',
                        firstname => 'first_name'
                    }
                )
            }
        }
    );

    # Mock UserAgent for userinfo endpoint
    my $ua_mock      = Test::MockModule->new('Mojo::UserAgent');
    my $tx_mock      = Test::MockModule->new('Mojo::Transaction::HTTP');
    my $res_mock     = Test::MockModule->new('Mojo::Message::Response');
    my $headers_mock = Test::MockModule->new('Mojo::Headers');

    $headers_mock->mock( 'content_type', sub { 'application/json' } );
    $res_mock->mock( 'code', sub { '200' } );
    $res_mock->mock(
        'json',
        sub {
            return {
                email      => 'userinfo@example.com',
                first_name => 'Jane'
            };
        }
    );
    $res_mock->mock(
        'headers',
        sub {
            my $headers = {};
            bless $headers, 'Mojo::Headers';
            return $headers;
        }
    );

    $tx_mock->mock(
        'res',
        sub {
            my $res = {};
            bless $res, 'Mojo::Message::Response';
            return $res;
        }
    );

    $ua_mock->mock(
        'get',
        sub {
            my $tx = {};
            bless $tx, 'Mojo::Transaction::HTTP';
            return $tx;
        }
    );

    my $data   = { access_token => 'test_token' };
    my $config = { userinfo_url => 'https://provider.com/userinfo' };

    # Test the method
    my ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    # Verify results
    is( $mapped_data->{email},     'userinfo@example.com', 'Email mapped from userinfo' );
    is( $mapped_data->{firstname}, 'Jane',                 'First name mapped from userinfo' );
    is( $found_patron->id,         $patron->id,            'Patron found by email from userinfo' );

    # Test with both id_token and userinfo (patron should be found from id_token first)
    my $id_token_claims = { email => 'token@example.com' };
    my $id_token        = 'header.' . encode_base64url( encode_json($id_token_claims) ) . '.signature';

    my $token_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { email => 'token@example.com' }
        }
    );

    $data->{id_token} = $id_token;

    ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    is( $found_patron->id,     $token_patron->id,      'Patron found from id_token takes precedence' );
    is( $mapped_data->{email}, 'userinfo@example.com', 'But userinfo data still merged' );

    $schema->storage->txn_rollback;
};

subtest '_get_data_and_patron() no patron found tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;

    # Create provider
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                matchpoint => 'email',
                mapping    => encode_json( { email => 'mail' } )
            }
        }
    );

    # Create token for non-existent user
    my $claims   = { mail => 'nonexistent@example.com' };
    my $id_token = 'header.' . encode_base64url( encode_json($claims) ) . '.signature';

    my $data   = { id_token => $id_token };
    my $config = {};

    # Test the method
    my ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    # Verify results
    is( $mapped_data->{email}, 'nonexistent@example.com', 'Email mapped correctly' );
    is( $found_patron,         undef,                     'No patron found for non-existent email' );

    $schema->storage->txn_rollback;
};

subtest '_get_data_and_patron() userinfo_url with extra Content-Type params (bug 43375)' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;

    # Create test patron
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { email => 'graph@example.com' }
        }
    );

    # Create provider with email matchpoint
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                matchpoint => 'email',
                mapping    => encode_json(
                    {
                        email     => 'mail',
                        firstname => 'givenName',
                        surname   => 'surname',
                    }
                )
            }
        }
    );

    # Mock UserAgent - simulate Microsoft Graph API response
    # Content-Type: application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8
    my $ua_mock      = Test::MockModule->new('Mojo::UserAgent');
    my $tx_mock      = Test::MockModule->new('Mojo::Transaction::HTTP');
    my $res_mock     = Test::MockModule->new('Mojo::Message::Response');
    my $headers_mock = Test::MockModule->new('Mojo::Headers');

    $headers_mock->mock(
        'content_type',
        sub {
            'application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8';
        }
    );
    $res_mock->mock( 'code', sub { '200' } );
    $res_mock->mock(
        'json',
        sub {
            return {
                mail      => 'graph@example.com',
                givenName => 'Azure',
                surname   => 'User',
            };
        }
    );
    $res_mock->mock(
        'headers',
        sub {
            my $headers = {};
            bless $headers, 'Mojo::Headers';
            return $headers;
        }
    );

    $tx_mock->mock(
        'res',
        sub {
            my $res = {};
            bless $res, 'Mojo::Message::Response';
            return $res;
        }
    );

    $ua_mock->mock(
        'get',
        sub {
            my $tx = {};
            bless $tx, 'Mojo::Transaction::HTTP';
            return $tx;
        }
    );

    my $data   = { access_token => 'ms_graph_token' };
    my $config = { userinfo_url => 'https://graph.microsoft.com/v1.0/me' };

    my ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    is( $mapped_data->{email}, 'graph@example.com', 'Email mapped from MS Graph response with OData Content-Type' );
    is( $found_patron->id,     $patron->id,         'Patron found despite extra Content-Type parameters' );

    $schema->storage->txn_rollback;
};

subtest '_get_data_and_patron() userinfo_url falls back to form-encoded body (bug 43375)' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;

    # Create test patron
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { email => 'formuser@example.com' }
        }
    );

    # Create provider with email matchpoint
    my $provider = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Providers',
            value => {
                matchpoint => 'email',
                mapping    => encode_json(
                    {
                        email     => 'mail',
                        firstname => 'given_name',
                    }
                )
            }
        }
    );

    # Mock UserAgent - simulate a provider that returns a genuine
    # url-encoded body, so res->json fails to decode (returns undef)
    # and _get_data_and_patron must fall back to Mojo::Parameters
    my $ua_mock      = Test::MockModule->new('Mojo::UserAgent');
    my $tx_mock      = Test::MockModule->new('Mojo::Transaction::HTTP');
    my $res_mock     = Test::MockModule->new('Mojo::Message::Response');
    my $headers_mock = Test::MockModule->new('Mojo::Headers');

    $headers_mock->mock( 'content_type', sub { 'application/x-www-form-urlencoded' } );
    $res_mock->mock( 'code', sub { '200' } );
    $res_mock->mock( 'json', sub { undef } );
    $res_mock->mock( 'body', sub { 'mail=formuser%40example.com&given_name=Form' } );
    $res_mock->mock(
        'headers',
        sub {
            my $headers = {};
            bless $headers, 'Mojo::Headers';
            return $headers;
        }
    );

    $tx_mock->mock(
        'res',
        sub {
            my $res = {};
            bless $res, 'Mojo::Message::Response';
            return $res;
        }
    );

    $ua_mock->mock(
        'get',
        sub {
            my $tx = {};
            bless $tx, 'Mojo::Transaction::HTTP';
            return $tx;
        }
    );

    my $data   = { access_token => 'form_token' };
    my $config = { userinfo_url => 'https://provider.example.com/userinfo' };

    my ( $mapped_data, $found_patron ) = $client->_get_data_and_patron(
        {
            provider => $provider,
            data     => $data,
            config   => $config
        }
    );

    is( $mapped_data->{email}, 'formuser@example.com', 'Email mapped from url-encoded fallback body' );
    is( $found_patron->id,     $patron->id,            'Patron found via form-data fallback parsing' );

    $schema->storage->txn_rollback;
};
