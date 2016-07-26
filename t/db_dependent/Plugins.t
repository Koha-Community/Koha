#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 24;
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

is( Koha::Plugins::Handler->run({ class => "Koha::Plugin::Test", method => 'report', enable_plugins => 1 }), "Koha::Plugin::Test::report", 'Test run plugin report method' );

my $metadata = $plugin->get_metadata();
is( $metadata->{'name'}, 'Test Plugin', 'Test $plugin->get_metadata()' );

is( $plugin->get_qualified_table_name('mytable'), 'koha_plugin_test_mytable', 'Test $plugin->get_qualified_table_name()' );
is( $plugin->get_plugin_http_path(), '/plugin/Koha/Plugin/Test', 'Test $plugin->get_plugin_http_path()' );

# testing GetPlugins
my @plugins = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins({
    method => 'report'
});
my @names = map { $_->get_metadata()->{'name'} } @plugins;
is( scalar grep( /^Test Plugin$/, @names), 1, "Koha::Plugins::GetPlugins functions correctly" );
@plugins =  Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins({
    metadata => { my_example_tag  => 'find_me' },
});
@names = map { $_->get_metadata()->{'name'} } @plugins;
is( scalar grep( /^Test Plugin$/, @names), 1, "GetPlugins also found Test Plugin via a metadata tag" );
# Test two metadata conditions; one does not exist for Test.pm
# Since it is a required key, we should not find the same results
my @plugins2 = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins({
    metadata => { my_example_tag  => 'find_me', not_there => '1' },
});
isnt( scalar @plugins2, scalar @plugins, 'GetPlugins with two metadata conditions' );

SKIP: {
    my $plugins_dir = C4::Context->config("pluginsdir");
    skip "plugindir not set", 4 unless defined $plugins_dir;
    skip "plugindir not writable", 4 unless -w $plugins_dir;
    # no need to skip further tests if KitchenSink would already exist

    my $ae = Archive::Extract->new( archive => "$Bin/KitchenSinkPlugin.kpz", type => 'zip' );
    unless ( $ae->extract( to => $plugins_dir ) ) {
        warn "ERROR: " . $ae->error;
    }
    use_ok('Koha::Plugin::Com::ByWaterSolutions::KitchenSink');
    $plugin = Koha::Plugin::Com::ByWaterSolutions::KitchenSink->new({ enable_plugins => 1});
    my $table = $plugin->get_qualified_table_name( 'mytable' );

    ok( -f $plugins_dir . "/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm", "KitchenSink plugin installed successfully" );
    Koha::Plugins::Handler->delete({ class => "Koha::Plugin::Com::ByWaterSolutions::KitchenSink", enable_plugins => 1 });
    my $sth = C4::Context->dbh->table_info( undef, undef, $table, 'TABLE' );
    my $info = $sth->fetchall_arrayref;
    is( @$info, 0, "Table $table does no longer exist" );
    ok( !( -f $plugins_dir . "/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm" ), "Koha::Plugins::Handler::delete works correctly." );
}
