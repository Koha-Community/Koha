#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 15;
use File::Basename;

use Module::Load::Conditional qw(can_load);

use C4::Context;

BEGIN {
    push( @INC, dirname(__FILE__) . '/..' );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugins::Base');
    use_ok('Koha::Plugin::Test');
}

ok( can_load( modules => { "Koha::Plugin::Test" => undef } ), 'Test can_load' );

my $plugin = Koha::Plugin::Test->new({ enable_plugins => 1});

isa_ok( $plugin, "Koha::Plugin::Test", 'Test plugin class' );
isa_ok( $plugin, "Koha::Plugins::Base", 'Test plugin parent class' );

ok( $plugin->can('report'), 'Test plugin can report' );
ok( $plugin->can('tool'), 'Test plugin can tool' );
ok( $plugin->can('configure'), 'Test plugin can configure' );
ok( $plugin->can('install'), 'Test plugin can install' );
ok( $plugin->can('uninstall'), 'Test plugin can install' );

my $metadata = $plugin->get_metadata();
ok( $metadata->{'name'} eq 'Test Plugin', 'Test $plugin->get_metadata()' );

ok( $plugin->get_qualified_table_name('mytable') eq 'koha_plugin_test_mytable', 'Test $plugin->get_qualified_table_name()' );
ok( $plugin->get_plugin_http_path() eq '/plugin/Koha/Plugin/Test', 'Test $plugin->get_plugin_http_path()' );