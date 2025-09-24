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
use Test::More tests => 7;

use Test::MockModule;
use Test::Exception;

use JSON qw(encode_json);

use Koha::Auth::Identity::Providers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'domains() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers' } );
    my $domains  = $provider->domains;

    is( ref($domains),   'Koha::Auth::Identity::Provider::Domains', 'Type is correct' );
    is( $domains->count, 0,                                         'No domains defined' );

    $builder->build_object(
        { class => 'Koha::Auth::Identity::Provider::Domains', value => { identity_provider_id => $provider->id } } );
    $builder->build_object(
        { class => 'Koha::Auth::Identity::Provider::Domains', value => { identity_provider_id => $provider->id } } );

    is( $provider->domains->count, 2, 'The provider has 2 domains defined' );

    $schema->storage->txn_rollback;
};

subtest 'get_config() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { config => '{' } } );

    throws_ok { $provider->get_config() }
    'Koha::Exceptions::Object::BadValue', 'Expected exception thrown on bad JSON';

    my $config = { some => 'value', and => 'another' };
    $provider->config( encode_json($config) )->store;

    is_deeply( $provider->get_config, $config, 'Config correctly retrieved' );

    $schema->storage->txn_rollback;
};

subtest 'set_config() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    subtest 'OIDC protocol tests' => sub {

        plan tests => 4;

        my $provider =
            $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { protocol => 'OIDC' } } );
        $provider = $provider->upgrade_class;

        my $config = {
            key    => 'key',
            secret => 'secret',
        };

        throws_ok { $provider->set_config($config) }
        'Koha::Exceptions::MissingParameter', 'Exception thrown on missing parameter';

        is( $@->parameter, 'well_known_url', 'Message is correct' );

        $config->{well_known_url} = 'https://koha-community.org/auth';

        my $return = $provider->set_config($config);
        is( ref($return), 'Koha::Auth::Identity::Provider::OIDC', 'Return type is correct' );

        is_deeply( $provider->get_config, $config, 'Configuration stored correctly' );
    };

    subtest 'OAuth protocol tests' => sub {

        plan tests => 4;

        my $provider =
            $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { protocol => 'OAuth' } } );
        $provider = $provider->upgrade_class;

        my $config = {
            key       => 'key',
            secret    => 'secret',
            token_url => 'https://koha-community.org/auth/token',
        };

        throws_ok { $provider->set_config($config) }
        'Koha::Exceptions::MissingParameter', 'Exception thrown on missing parameter';

        is( $@->parameter, 'authorize_url', 'Message is correct' );

        $config->{authorize_url} = 'https://koha-community.org/auth/authorize';

        my $return = $provider->set_config($config);
        is( ref($return), 'Koha::Auth::Identity::Provider::OAuth', 'Return type is correct' );

        is_deeply( $provider->get_config, $config, 'Configuration stored correctly' );
    };

    subtest 'Unsupported protocol tests' => sub {

        plan tests => 2;

        my $provider =
            $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { protocol => 'CAS' } } );

        throws_ok { $provider->set_config() }
        'Koha::Exception', 'Exception thrown on unsupported protocol';

        like( "$@", qr/This method needs to be subclassed/, 'Message is correct' );
    };

    $schema->storage->txn_rollback;
};

subtest 'get_mapping() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { config => '{' } } );

    throws_ok { $provider->get_mapping() }
    'Koha::Exceptions::Object::BadValue', 'Expected exception thrown on bad JSON';

    my $mapping = { some => 'value', and => 'another' };
    $provider->mapping( encode_json($mapping) )->store;

    is_deeply( $provider->get_mapping, $mapping, 'Mapping correctly retrieved' );

    $schema->storage->txn_rollback;
};

subtest 'set_mapping() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $provider = $builder->build_object( { class => 'Koha::Auth::Identity::Providers' } );

    my $mapping = { some => 'value', and => 'another' };
    $provider->set_mapping($mapping)->store;

    is_deeply( $provider->get_mapping, $mapping, 'Mapping correctly retrieved' );

    $schema->storage->txn_rollback;
};

subtest 'upgrade_class() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $mapping   = Koha::Auth::Identity::Provider::protocol_to_class_mapping;
    my @protocols = keys %{$mapping};

    foreach my $protocol (@protocols) {

        my $provider = $builder->build_object(
            {
                class => 'Koha::Auth::Identity::Providers',
                value => { protocol => $protocol },
            }
        );

        is( ref($provider), 'Koha::Auth::Identity::Provider', "Base class used for $protocol" );

        # upgrade
        $provider = $provider->upgrade_class;
        is(
            ref($provider), $mapping->{$protocol},
            "Class upgraded to " . $mapping->{$protocol} . "for protocol $protocol"
        );
    }

    my $provider = Koha::Auth::Identity::Provider->new( { protocol => 'Invalid' } );
    throws_ok { $provider->upgrade }
    'Koha::Exception',
        'Exception throw on invalid protocol';

    $schema->storage->txn_rollback;
};
