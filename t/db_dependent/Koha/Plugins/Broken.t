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
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use File::Basename;
use Test::NoWarnings;
use Test::More tests => 3;
use Test::Warn;

use t::lib::Mocks;

use Koha::Database;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/bad_plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

my $plugins = Koha::Plugins->new;

warnings_are { $plugins->InstallPlugins; }
[
    "Calling 'install' died for plugin Koha::Plugin::BrokenInstall",
    "Calling 'upgrade' died for plugin Koha::Plugin::BrokenUpgrade"
];

$schema->storage->txn_begin;
