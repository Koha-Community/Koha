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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 5;

use Test::MockModule;
use Test::MockObject;
use Test::NoWarnings;
use Test::Exception;

use JSON         qw(encode_json);
use MIME::Base64 qw{ encode_base64url };

use Koha::Auth::Client;
use Koha::Auth::Client::OAuth;
use Koha::Patrons;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'get_user() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client::OAuth->new;
    my $provider =
        $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { matchpoint => 'email' } } );
    my $domain = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => {
                identity_provider_id => $provider->id, domain => '', update_on_auth => 0, allow_opac => 1,
                allow_staff          => 0
            }
        }
    );
    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { email => 'patron@test.com' } } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );
    my $mapping = {
        email     => 'electronic_mail',
        firstname => 'given_name',
        surname   => 'family_name'
    };
    $provider->set_mapping($mapping)->store;

    my $id_token = 'header.' . encode_base64url(
        encode_json(
            {
                electronic_mail => 'patron@test.com',
                given_name      => 'test name'
            }
        )
    ) . '.footer';

    my $data = { id_token => $id_token };

    my ( $resolved_patron, $mapped_data, $resolved_domain ) =
        $client->get_user( { provider => $provider->code, data => $data, interface => 'opac' } );
    is_deeply(
        $resolved_patron->to_api( { user => $patron } ), $patron->to_api( { user => $patron } ),
        'Patron correctly retrieved'
    );
    is( $mapped_data->{firstname},            'test name',                                   'Data mapped correctly' );
    is( $mapped_data->{surname},              undef,                                         'No surname mapped' );
    is( $domain->identity_provider_domain_id, $resolved_domain->identity_provider_domain_id, 'Is the same domain' );

    $schema->storage->txn_rollback;
};

subtest 'get_valid_domain_config() tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client->new;
    my $provider =
        $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { matchpoint => 'email' } } );
    my $domain1 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => { identity_provider_id => $provider->id, domain => '', allow_opac => 0, allow_staff => 0 }
        }
    );
    my $domain2 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value =>
                { identity_provider_id => $provider->id, domain => '*library.com', allow_opac => 1, allow_staff => 0 }
        }
    );
    my $domain3 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value =>
                { identity_provider_id => $provider->id, domain => '*.library.com', allow_opac => 1, allow_staff => 0 }
        }
    );
    my $domain4 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => {
                identity_provider_id => $provider->id, domain => 'student.library.com', allow_opac => 1,
                allow_staff          => 0
            }
        }
    );
    my $domain5 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => {
                identity_provider_id => $provider->id, domain => 'staff.library.com', allow_opac => 1, allow_staff => 1
            }
        }
    );

    my $retrieved_domain;

    # Test @gmail.com
    $retrieved_domain =
        $client->get_valid_domain_config( { provider => $provider, email => 'user@gmail.com', interface => 'opac' } );
    is( $retrieved_domain, undef, 'gmail user cannot enter opac' );
    $retrieved_domain =
        $client->get_valid_domain_config( { provider => $provider, email => 'user@gmail.com', interface => 'staff' } );
    is( $retrieved_domain, undef, 'gmail user cannot enter staff' );

    # Test @otherlibrary.com
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@otherlibrary.com', interface => 'opac' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain2->identity_provider_domain_id,
        'otherlibaray user can enter opac with domain2'
    );
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@otherlibrary.com', interface => 'staff' } );
    is( $retrieved_domain, undef, 'otherlibrary user cannot enter staff' );

    # Test @provider.library.com
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@provider.library.com', interface => 'opac' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain3->identity_provider_domain_id,
        'provider.library user can enter opac with domain3'
    );
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@provider.library.com', interface => 'staff' } );
    is( $retrieved_domain, undef, 'provider.library user cannot enter staff' );

    # Test @student.library.com
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@student.library.com', interface => 'opac' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain4->identity_provider_domain_id,
        'student.library user can enter opac with domain4'
    );
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@student.library.com', interface => 'staff' } );
    is( $retrieved_domain, undef, 'student.library user cannot enter staff' );

    # Test @staff.library.com
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@staff.library.com', interface => 'opac' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain5->identity_provider_domain_id,
        'staff.library user can enter opac with domain5'
    );
    $retrieved_domain = $client->get_valid_domain_config(
        { provider => $provider, email => 'user@staff.library.com', interface => 'staff' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain5->identity_provider_domain_id,
        'staff.library user can enter staff with domain5'
    );

    $schema->storage->txn_rollback;
};

subtest 'has_valid_domain_config() tests' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my $client = Koha::Auth::Client->new;
    my $provider =
        $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { matchpoint => 'email' } } );
    my $domain1 = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => { identity_provider_id => $provider->id, domain => '', allow_opac => 1, allow_staff => 0 }
        }
    );

    # Test @gmail.com
    my $retrieved_domain =
        $client->has_valid_domain_config( { provider => $provider, email => 'user@gmail.com', interface => 'opac' } );
    is(
        $retrieved_domain->identity_provider_domain_id, $domain1->identity_provider_domain_id,
        'gmail user can enter opac with domain1'
    );
    throws_ok {
        $client->has_valid_domain_config( { provider => $provider, email => 'user@gmail.com', interface => 'staff' } )
    }
    'Koha::Exceptions::Auth::NoValidDomain',
        'gmail user cannot enter staff';

    $schema->storage->txn_rollback;
};

subtest '_traverse_hash() tests' => sub {
    plan tests => 3;

    my $client = Koha::Auth::Client->new;

    my $hash = {
        a  => { hash  => { with => 'complicated structure' } },
        an => { array => [ { inside => 'a hash' }, { inside => 'second element' } ] }
    };

    my $first_result = $client->_traverse_hash(
        {
            base => $hash,
            keys => 'a.hash.with'
        }
    );
    is( $first_result, 'complicated structure', 'get the value within a hash structure' );

    my $second_result = $client->_traverse_hash(
        {
            base => $hash,
            keys => 'an.array.0.inside'
        }
    );
    is( $second_result, 'a hash', 'get the value of the first element of an array within a hash structure' );

    my $third_result = $client->_traverse_hash(
        {
            base => $hash,
            keys => 'an.array.1.inside'
        }
    );
    is( $third_result, 'second element', 'get the value of the second element of an array within a hash structure' );
};
