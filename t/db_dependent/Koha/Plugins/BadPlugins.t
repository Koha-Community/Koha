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

use File::Basename;
use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 5;
use Test::Warn;
use Test::Exception;

use Koha::Database;

use t::lib::Mocks;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins_bad';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugins::Base');
}

my $schema = Koha::Database->new->schema;

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'Koha::Plugin::BadMetadata' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data (FIXME not done)
    Koha::Plugins->RemovePlugins;

    my $plugins = Koha::Plugins->new( { enable_plugins => 1 } );

    warnings_are { $plugins->InstallPlugins; }
    [
        'Plugin Bad Metadata has invalid date_authored metadata',
        'Plugin Bad Metadata has invalid date_updated metadata'
    ];

    my @plugins = $plugins->GetPlugins( { metadata => { name => 'Bad Metadata' }, all => 1 } );
    is( scalar @plugins, 1 );

    is( $plugins[0]->get_metadata()->{'date_authored'}, undef );
    is( $plugins[0]->get_metadata()->{'date_updated'},  undef );

    $schema->storage->txn_rollback;
};
