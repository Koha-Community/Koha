#!/usr/bin/perl

# Copyright 2023 Koha Development team
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
use File::Basename;
use File::Path qw(make_path remove_tree);
use Test::MockModule;

use Test::More tests => 4;

use Koha::ILL::Backends;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'installed_backends() tests' => sub {

    # dir backend    = An ILL backend installed through backend_directory in koha-conf.xml
    # plugin backend = An ILL backend installed through a plugin

    plan tests => 2;

    $schema->storage->txn_begin;

    # Install a plugin_backend
    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;
    is_deeply(
        Koha::ILL::Backends->installed_backends, ['Test Plugin'],
        'Only one backend installed, happens to be a plugin'
    );

    # Install a dir backend
    my $dir_backend = '/tmp/ill_backend_test/Old_Backend';
    my $ill_config  = Test::MockModule->new('Koha::ILL::Request::Config');
    $ill_config->mock(
        'backend_dir',
        sub {
            return '/tmp/ill_backend_test';
        }
    );
    make_path($dir_backend);
    my $installed_backends = Koha::ILL::Backends->installed_backends;
    is_deeply(
        $installed_backends, [ 'Old_Backend', 'Test Plugin' ],
        'Two backends are installed, one plugin and one directory backend'
    );

    #cleanup
    remove_tree($dir_backend);
    Koha::Plugins::Methods->delete;
    $schema->storage->txn_rollback;
};
