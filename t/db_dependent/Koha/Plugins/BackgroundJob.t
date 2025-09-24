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
use Test::More tests => 2;
use Test::MockModule;

use File::Basename;

use Koha::BackgroundJobs;

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    require Koha::Plugins;
    require Koha::Plugins::Handler;
    require Koha::Plugin::Test;
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $logger  = t::lib::Mocks::Logger->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'background_tasks() hooks tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $bj    = Koha::BackgroundJob->new;
    my $tasks = $bj->type_to_class_mapping;

    ok( !exists $tasks->{foo} );
    ok( !exists $tasks->{bar} );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    $bj    = Koha::BackgroundJob->new;
    $tasks = $bj->type_to_class_mapping;

    is( $tasks->{plugin_test_foo}, 'MyPlugin::Class::Foo' );
    is( $tasks->{plugin_test_bar}, 'MyPlugin::Class::Bar' );

    my $metadata = $plugin->get_metadata;
    delete $metadata->{namespace};

    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'get_metadata', sub { return $metadata; } );

    $plugin = Koha::Plugin::Test->new;

    $bj    = Koha::BackgroundJob->new;
    $tasks = $bj->type_to_class_mapping;
    $logger->warn_is(
        "A plugin includes the 'background_tasks' method, but doesn't provide the required 'namespace' method (Koha::Plugin::Test)"
    );

    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    $bj    = Koha::BackgroundJob->new;
    $tasks = $bj->type_to_class_mapping;

    is_deeply( $tasks, $bj->core_types_to_classes, 'Only core mapping returned when plugins disabled' );

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
