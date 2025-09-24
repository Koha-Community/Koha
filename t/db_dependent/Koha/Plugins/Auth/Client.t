#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Exception;

use File::Basename;
use JSON         qw(encode_json);
use MIME::Base64 qw{ encode_base64url };

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
    use_ok('Koha::Auth::Client');
    use_ok('Koha::Auth::Client::OAuth');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'auth_client_get_user hook tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # Test Plugin manipulates mapped_data
    my $plugin = Koha::Plugin::Test->new->enable;

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
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { email => 'patron@test.com' } } );
    my $mapping = {
        email      => 'electronic_mail',
        firstname  => 'given_name',
        surname    => 'family_name',
        cardnumber => 'cardnumber',
    };
    $provider->set_mapping($mapping)->store;

    my $id_token = 'header.' . encode_base64url(
        encode_json(
            {
                electronic_mail => 'patron@test.com',
                given_name      => 'test name',
                cardnumber      => 'kit:12345',
            }
        )
    ) . '.footer';

    my $data = { id_token => $id_token };

    my ( $resolved_patron, $mapped_data, $resolved_domain ) =
        $client->get_user( { provider => $provider->code, data => $data, interface => 'opac' } );
    is( $mapped_data->{cardnumber}, '12345', 'Plugin manipulated mapped_data successfully' );
    isnt( $resolved_patron->borrowernumber, $patron->borrowernumber, 'Plugin changed the resolved patron' );
    isnt( $resolved_domain->domain,         $domain->domain,         'Plugin changed the resolved domain' );

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
