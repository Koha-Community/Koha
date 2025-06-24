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
use Test::More tests => 9;

use File::Basename;

use C4::Context;

use Koha::FrameworkPlugin;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
    use_ok('Koha::Plugin::TestValuebuilder');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'get_valuebuilders_installed() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # Test 1: No valuebuilders when no plugins have get_valuebuilder method
    # Only enable the regular Test plugin (which doesn't have get_valuebuilder)
    my $regular_plugin = Koha::Plugin::Test->new->enable;
    my @valuebuilders  = $plugins->get_valuebuilders_installed();
    is( scalar @valuebuilders, 0, 'No valuebuilders when enabled plugin lacks get_valuebuilder method' );

    # Test 2: Enable the TestValuebuilder plugin which provides a valuebuilder
    my $valuebuilder_plugin = Koha::Plugin::TestValuebuilder->new->enable;
    @valuebuilders = $plugins->get_valuebuilders_installed();
    is( scalar @valuebuilders, 1, 'One valuebuilder found when TestValuebuilder plugin is enabled' );

    # Test 3: Check the structure of returned valuebuilder
    my $valuebuilder = $valuebuilders[0];
    is( ref($valuebuilder),    'HASH',                        'Valuebuilder is returned as hashref' );
    is( $valuebuilder->{name}, 'test_plugin_valuebuilder.pl', 'Valuebuilder name matches TestValuebuilder plugin' );
    isa_ok( $valuebuilder->{plugin}, 'Koha::Plugin::TestValuebuilder', 'Valuebuilder plugin is correct object type' );

    # Test 4: Disable the valuebuilder plugin and verify it's not found
    $valuebuilder_plugin->disable;
    @valuebuilders = $plugins->get_valuebuilders_installed();
    is( scalar @valuebuilders, 0, 'No valuebuilders when TestValuebuilder plugin is disabled' );

    Koha::Plugins->RemovePlugins( { destructive => 1 } );
    $schema->storage->txn_rollback;
};

subtest 'FrameworkPlugin valuebuilder integration tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # Enable the TestValuebuilder plugin
    my $valuebuilder_plugin    = Koha::Plugin::TestValuebuilder->new->enable;
    my $test_valuebuilder_name = $valuebuilder_plugin->get_valuebuilder();

    # Test 1: FrameworkPlugin can find plugin-based valuebuilder
    my $framework_plugin = Koha::FrameworkPlugin->new( { name => $test_valuebuilder_name } );
    ok( $framework_plugin, 'FrameworkPlugin object created successfully' );
    is( $framework_plugin->name, $test_valuebuilder_name, 'FrameworkPlugin has correct name' );

    # Test 2: FrameworkPlugin can load plugin-based valuebuilder
    my $build_result = $framework_plugin->build( { id => 'test_field_001' } );
    ok( $build_result, 'FrameworkPlugin build method succeeds with plugin valuebuilder' );

    # Test 3: FrameworkPlugin generates javascript from plugin
    my $javascript = $framework_plugin->javascript;
    ok( $javascript, 'FrameworkPlugin generates javascript' );
    like(
        $javascript, qr/test_focus_test_field_001/,
        'Generated javascript contains expected field-specific function'
    );

    # Test 4: FrameworkPlugin can launch plugin-based valuebuilder (would need CGI mock for full test)
    ok( $framework_plugin->{launcher}, 'FrameworkPlugin has launcher method loaded from plugin' );

    Koha::Plugins->RemovePlugins( { destructive => 1 } );
    $schema->storage->txn_rollback;
};

subtest 'Plugin Base valuebuilder methods tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # Test 1: get_valuebuilders() with plugin that doesn't have get_valuebuilder method
    my $regular_plugin = Koha::Plugin::Test->new->enable;
    my $valuebuilders  = $regular_plugin->get_valuebuilders();
    is( ref($valuebuilders),    'ARRAY', 'get_valuebuilders returns array reference' );
    is( scalar @$valuebuilders, 0, 'get_valuebuilders returns empty array when plugin lacks get_valuebuilder method' );

    # Test 2: get_valuebuilders() with plugin that has get_valuebuilder method
    my $valuebuilder_plugin = Koha::Plugin::TestValuebuilder->new->enable;
    $valuebuilders = $valuebuilder_plugin->get_valuebuilders();
    is( scalar @$valuebuilders, 1, 'get_valuebuilders returns one item when plugin has get_valuebuilder method' );
    is( $valuebuilders->[0],    'test_plugin_valuebuilder.pl', 'get_valuebuilders returns correct valuebuilder name' );

    # Test 3: get_valuebuilder_url() method
    my $url            = $valuebuilder_plugin->get_valuebuilder_url();
    my $expected_class = ref($valuebuilder_plugin);
    like(
        $url, qr|/cgi-bin/koha/plugins/run\.pl\?class=$expected_class&method=launcher|,
        'get_valuebuilder_url returns correct URL format'
    );

    # Test 4: get_valuebuilder() method directly
    my $valuebuilder_name = $valuebuilder_plugin->get_valuebuilder();
    is( $valuebuilder_name, 'test_plugin_valuebuilder.pl', 'get_valuebuilder returns expected name' );

    Koha::Plugins->RemovePlugins( { destructive => 1 } );
    $schema->storage->txn_rollback;
};

subtest 'Real FrameworkPlugin integration with valuebuilder plugins' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # Enable our test valuebuilder plugin
    my $valuebuilder_plugin = Koha::Plugin::TestValuebuilder->new->enable;
    ok( $valuebuilder_plugin->is_enabled, 'TestValuebuilder plugin is enabled' );

    # Test 1: Verify the plugin provides a valuebuilder
    my $valuebuilder_name = $valuebuilder_plugin->get_valuebuilder();
    is(
        $valuebuilder_name, 'test_plugin_valuebuilder.pl',
        'TestValuebuilder plugin returns correct valuebuilder name'
    );

    # Test 2: Verify get_valuebuilders_installed finds our plugin
    my @valuebuilders = $plugins->get_valuebuilders_installed();
    is( scalar @valuebuilders,     1,                  'get_valuebuilders_installed finds one valuebuilder' );
    is( $valuebuilders[0]->{name}, $valuebuilder_name, 'Found valuebuilder has correct name' );
    isa_ok(
        $valuebuilders[0]->{plugin}, 'Koha::Plugin::TestValuebuilder',
        'Found valuebuilder has correct plugin type'
    );

    # Test 3: FrameworkPlugin can load our plugin-based valuebuilder
    my $framework_plugin = Koha::FrameworkPlugin->new( { name => $valuebuilder_name } );
    ok( $framework_plugin, 'FrameworkPlugin created successfully with plugin valuebuilder name' );
    is( $framework_plugin->name, $valuebuilder_name, 'FrameworkPlugin has correct name' );
    ok( !$framework_plugin->errstr, 'FrameworkPlugin has no errors' );

    # Test 4: FrameworkPlugin can build JavaScript from our plugin
    my $build_result = $framework_plugin->build( { id => 'test_field_123' } );
    ok( $build_result, 'FrameworkPlugin build succeeds with real plugin valuebuilder' );

    my $javascript = $framework_plugin->javascript;
    ok( $javascript, 'FrameworkPlugin generates JavaScript from plugin' );
    like( $javascript, qr/test_focus_test_field_123/, 'Generated JavaScript contains expected function for field ID' );
    like(
        $javascript, qr/test_click_test_field_123/,
        'Generated JavaScript contains expected click function for field ID'
    );

    Koha::Plugins->RemovePlugins( { destructive => 1 } );
    $schema->storage->txn_rollback;
};
