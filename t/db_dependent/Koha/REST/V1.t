#!/usr/bin/perl

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
use Test::More tests => 3;
use Test::Mojo;
use Test::MockModule;
use Test::Warn;

use Carp qw( carp );
use File::Basename;
use t::lib::Mocks;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );
}

use Koha::Database;
use Koha::Plugins;

my $logger = Test::MockModule->new('Koha::Logger');
$logger->mock(
    'error',
    sub {
        shift;
        carp @_;
    }
);

my $schema = Koha::Database->new->schema;

subtest 'Type definition tests' => sub {

    plan tests => 4;

    # initialize Koha::REST::V1 after mocking
    my $remote_address = '127.0.0.1';
    my $t;

    $t = Test::Mojo->new('Koha::REST::V1');
    my $types = $t->app->types;

    is(
        $types->type('json'),
        'application/json; charset=utf8',
        'application/json gets charset added'
    );
    is( $types->type('marcxml'), 'application/marcxml+xml',  'application/marcxml+xml is defined' );
    is( $types->type('mij'),     'application/marc-in-json', 'application/marc-in-json is defined' );
    is( $types->type('marc'),    'application/marc',         'application/marc is defined' );
};

subtest '_route_wants_raw_payload' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    Koha::Plugins::Methods->search->delete;
    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;
    $_->enable for $plugins->GetPlugins( { all => 1 } );

    my $t;
    warning_like { $t = Test::Mojo->new('Koha::REST::V1'); }
    [
        qr{Could not load REST API spec bundle: /paths/~0001contrib~0001badass},
        qr{bother_wrong/put/parameters/0: /oneOf/1 Properties not allowed:},
        qr{Plugin Koha::Plugin::BadAPIRoute route injection failed: The resulting spec is invalid. Skipping Bad API Route Plugin},
    ],
        'Bad plugins raise warning';

    # Attributes and ordering are exactly the kind of thing the default XML<->JSON
    # conversion cannot round-trip; parse_xml() never reads node attributes at all.
    my $xml =
          '<NCIPMessage version="1.0">'
        . '<Request type="RequestItem" priority="high">'
        . '<InitiationHeader><FromAgencyId>AgencyA</FromAgencyId><ToAgencyId>AgencyB</ToAgencyId></InitiationHeader>'
        . '<BibliographicId scheme="ISBN">9780140449136</BibliographicId>'
        . '</Request>'
        . '</NCIPMessage>';

    $t->post_ok(
        '/api/v1/contrib/testplugin/public/patrons/echo_raw',
        { 'Content-Type' => 'application/xml' },
        $xml
        )
        ->status_is(200)
        ->content_is( $xml, 'x-koha-raw-payload leaves the request/response body byte-for-byte untouched' );

    $t->post_ok(
        '/api/v1/contrib/testplugin/public/patrons/echo_converted',
        { 'Content-Type' => 'application/xml' },
        $xml
    )->status_is(200)->json_is(
        '/received' => {
            NCIPMessage => {
                Request => {
                    InitiationHeader => { FromAgencyId => 'AgencyA', ToAgencyId => 'AgencyB' },
                    BibliographicId  => '9780140449136',
                }
            }
        },
        'Without the flag, the default conversion silently drops all XML attributes (version/type/priority/scheme)'
    );

    $schema->storage->txn_rollback;
};
