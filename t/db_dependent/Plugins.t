#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 21;
use File::Basename;
use FindBin qw($Bin);
use Archive::Extract;
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
ok( $plugin->can('to_marc'), 'Test plugin can to_marc' );
ok( $plugin->can('configure'), 'Test plugin can configure' );
ok( $plugin->can('install'), 'Test plugin can install' );
ok( $plugin->can('uninstall'), 'Test plugin can install' );

ok( Koha::Plugins::Handler->run({ class => "Koha::Plugin::Test", method => 'report', enable_plugins => 1 }) eq "Koha::Plugin::Test::report", 'Test run plugin report method' );

my $metadata = $plugin->get_metadata();
ok( $metadata->{'name'} eq 'Test Plugin', 'Test $plugin->get_metadata()' );

ok( $plugin->get_qualified_table_name('mytable') eq 'koha_plugin_test_mytable', 'Test $plugin->get_qualified_table_name()' );
ok( $plugin->get_plugin_http_path() eq '/plugin/Koha/Plugin/Test', 'Test $plugin->get_plugin_http_path()' );

my @plugins = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins( 'report' );
ok( $plugins[0]->get_metadata()->{'name'} eq 'Test Plugin', "Koha::Plugins::GetPlugins functions correctly" );

SKIP: {
    my $plugins_dir = C4::Context->config("pluginsdir");
    skip "plugindir not set", 3 unless defined $plugins_dir;
    skip "plugindir not writable", 3 unless -w $plugins_dir;
    skip "KitchenSink plugin already installed", 3 if (-f "$plugins_dir/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm");

    my $ae = Archive::Extract->new( archive => "$Bin/KitchenSinkPlugin.kpz", type => 'zip' );
    unless ( $ae->extract( to => $plugins_dir ) ) {
        warn "ERROR: " . $ae->error;
    }
    use_ok('Koha::Plugin::Com::ByWaterSolutions::KitchenSink');
    $plugin = Koha::Plugin::Com::ByWaterSolutions::KitchenSink->new({ enable_plugins => 1});

    ok( -f $plugins_dir . "/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm", "KitchenSink plugin installed successfully" );
    Koha::Plugins::Handler->delete({ class => "Koha::Plugin::Com::ByWaterSolutions::KitchenSink" });
    ok( !( -f $plugins_dir . "/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm" ), "Koha::Plugins::Handler::delete works correctly." );
}

