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

use Archive::Extract;
use CGI;
use Cwd qw(abs_path);
use File::Basename;
use File::Spec;
use File::Temp qw( tempdir tempfile );
use FindBin qw($Bin);
use Module::Load::Conditional qw(can_load);
use Test::MockModule;
use Test::More tests => 61;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::Plugins::Methods;

use t::lib::Mocks;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugins::Base');
    use_ok('Koha::Plugin::Test');
    use_ok('Koha::Plugin::TestItemBarcodeTransform');
}

my $schema = Koha::Database->new->schema;

subtest 'call() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;
    # Temporarily remove any installed plugins data
    Koha::Plugins::Methods->delete;
    $schema->resultset('PluginData')->delete();

    t::lib::Mocks::mock_config('enable_plugins', 1);
    my $plugins = Koha::Plugins->new({ enable_plugins => 1 });

    my @plugins;

    warning_is { @plugins = $plugins->InstallPlugins; } undef;

    foreach my $plugin (@plugins) {
        $plugin->enable();
    }

    my @responses = Koha::Plugins->call('check_password', { password => 'foo' });

    my $expected = [ { error => 1, msg => 'PIN should be four digits' } ];
    is_deeply(\@responses, $expected, 'call() should return all responses from plugins');

    # Make sure parameters are correctly passed to the plugin method
    @responses = Koha::Plugins->call('check_password', { password => '1234' });

    $expected = [ { error => 0 } ];
    is_deeply(\@responses, $expected, 'call() should return all responses from plugins');

    t::lib::Mocks::mock_config('enable_plugins', 0);
    @responses = Koha::Plugins->call('check_password', { password => '1234' });
    is_deeply(\@responses, [], 'call() should return an empty array if plugins are disabled');

    $schema->storage->txn_rollback;
};

subtest 'more call() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;
    # Temporarily remove any installed plugins data
    Koha::Plugins::Methods->delete;

    t::lib::Mocks::mock_config('enable_plugins', 1);
    my $plugins = Koha::Plugins->new({ enable_plugins => 1 });
    my @plugins;

    warning_is { @plugins = $plugins->InstallPlugins; } undef;

    foreach my $plugin (@plugins) {
        $plugin->enable();
    }

    # Barcode is multiplied by 2 by Koha::Plugin::Test, and again by 4 by Koha::Plugin::TestItemBarcodeTransform
    # showing that call has passed the same ref to multiple plugins to operate on
    my $bc = 1;
    warnings_are
        { Koha::Plugins->call('item_barcode_transform', \$bc); }
        [ qq{Plugin error (Test Plugin): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 1'\n},
          qq{Plugin error (Test Plugin for item_barcode_transform): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 2'\n} ];
    is( $bc, 8, "Got expected response" );

    my $cn = 'abcd';
    warnings_are
        { Koha::Plugins->call('item_barcode_transform', \$bc); }
        [ qq{Plugin error (Test Plugin): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 8'\n},
          qq{Plugin error (Test Plugin for item_barcode_transform): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 16'\n} ];
    is( $cn, 'abcd', "Got expected response" );

    t::lib::Mocks::mock_config('enable_plugins', 0);
    $bc = 1;
    Koha::Plugins->call('item_barcode_transform', \$bc);
    is( $bc, 1, "call should return the original arguments if plugins are disabled" );

    $schema->storage->txn_rollback;
};

subtest 'GetPlugins() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;
    # Temporarily remove any installed plugins data
    Koha::Plugins::Methods->delete;

    my $plugins = Koha::Plugins->new({ enable_plugins => 1 });

    warning_is { $plugins->InstallPlugins; } undef;

    my @plugins = $plugins->GetPlugins({ method => 'report', all => 1 });

    my @names = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names), 1, "Koha::Plugins::GetPlugins functions correctly" );

    @plugins = $plugins->GetPlugins({ metadata => { my_example_tag  => 'find_me' }, all => 1 });
    @names = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar @names, 2, "Only two plugins found via a metadata tag" );

    $schema->storage->txn_rollback;
};

subtest 'Version upgrade tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );

    # make sure there's no version on the DB
    $schema->resultset('PluginData')
        ->search( { plugin_class => $plugin->{class}, plugin_key => '__INSTALLED_VERSION__' } )
        ->delete;

    $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );
    my $version = $plugin->retrieve_data('__INSTALLED_VERSION__');

    is( $version, $plugin->get_metadata->{version}, 'Version has been populated correctly' );

    $schema->storage->txn_rollback;
};

subtest 'is_enabled() tests' => sub {

    plan tests => 3;
    $schema->storage->txn_begin;

    # Make sure there's no previous installs or leftovers on DB
    Koha::Plugins::Methods->delete;
    $schema->resultset('PluginData')->delete;

    my $plugin = Koha::Plugin::Test->new({ enable_plugins => 1, cgi => CGI->new });
    ok( $plugin->is_enabled, 'Plugins enabled by default' );

    # disable
    $plugin->disable;
    ok( !$plugin->is_enabled, 'Calling ->disable disables the plugin' );

    # enable
    $plugin->enable;
    ok( $plugin->is_enabled, 'Calling ->enable enabled the plugin' );

    $schema->storage->txn_rollback;
};

$schema->storage->txn_begin;
Koha::Plugins::Methods->delete;

warning_is { Koha::Plugins->new( { enable_plugins => 1 } )->InstallPlugins(); } undef;

ok( Koha::Plugins::Methods->search( { plugin_class => 'Koha::Plugin::Test' } )->count, 'Test plugin methods added to database' );
is( Koha::Plugins::Methods->search({ plugin_class => 'Koha::Plugin::Test', plugin_method => '_private_sub' })->count, 0, 'Private methods are skipped' );

my $mock_plugin = Test::MockModule->new( 'Koha::Plugin::Test' );
$mock_plugin->mock( 'test_template', sub {
    my ( $self, $file ) = @_;
    my $template = $self->get_template({ file => $file });
    $template->param( filename => $file );
    return $template->output;
});

ok( can_load( modules => { "Koha::Plugin::Test" => undef } ), 'Test can_load' );

my $plugin = Koha::Plugin::Test->new({ enable_plugins => 1, cgi => CGI->new });

isa_ok( $plugin, "Koha::Plugin::Test", 'Test plugin class' );
isa_ok( $plugin, "Koha::Plugins::Base", 'Test plugin parent class' );

ok( $plugin->can('report'), 'Test plugin can report' );
ok( $plugin->can('tool'), 'Test plugin can tool' );
ok( $plugin->can('to_marc'), 'Test plugin can to_marc' );
ok( $plugin->can('intranet_catalog_biblio_enhancements'), 'Test plugin can intranet_catalog_biblio_enhancements');
ok( $plugin->can('intranet_catalog_biblio_enhancements_toolbar_button'), 'Test plugin can intranet_catalog_biblio_enhancements_toolbar_button' );
ok( $plugin->can('opac_online_payment'), 'Test plugin can opac_online_payment' );
ok( $plugin->can('after_hold_create'), 'Test plugin can after_hold_create' );
ok( $plugin->can('opac_online_payment_begin'), 'Test plugin can opac_online_payment_begin' );
ok( $plugin->can('opac_online_payment_end'), 'Test plugin can opac_online_payment_end' );
ok( $plugin->can('opac_head'), 'Test plugin can opac_head' );
ok( $plugin->can('opac_js'), 'Test plugin can opac_js' );
ok( $plugin->can('intranet_head'), 'Test plugin can intranet_head' );
ok( $plugin->can('intranet_js'), 'Test plugin can intranet_js' );
ok( $plugin->can('item_barcode_transform'), 'Test plugin can barcode_transform' );
ok( $plugin->can('configure'), 'Test plugin can configure' );
ok( $plugin->can('install'), 'Test plugin can install' );
ok( $plugin->can('upgrade'), 'Test plugin can upgrade' );
ok( $plugin->can('uninstall'), 'Test plugin can install' );

is( Koha::Plugins::Handler->run({ class => "Koha::Plugin::Test", method => 'report', enable_plugins => 1 }), "Koha::Plugin::Test::report", 'Test run plugin report method' );

my $metadata = $plugin->get_metadata();
is( $metadata->{'name'}, 'Test Plugin', 'Test $plugin->get_metadata()' );

is( $plugin->get_qualified_table_name('mytable'), 'koha_plugin_test_mytable', 'Test $plugin->get_qualified_table_name()' );
is( $plugin->get_plugin_http_path(), '/plugin/Koha/Plugin/Test', 'Test $plugin->get_plugin_http_path()' );

# test absolute path change in get_template with Koha::Plugin::Test
# using the mock set before
# we also add tmpdir as an approved template dir
t::lib::Mocks::mock_config( 'pluginsdir', [ C4::Context->temporary_directory ] );
my ( $fh, $fn ) = tempfile( SUFFIX => '.tt', UNLINK => 1, DIR => C4::Context->temporary_directory );
print $fh 'I am [% filename %]';
close $fh;
my $classname = ref($plugin);
like( $plugin->test_template($fn), qr/^I am $fn/, 'Template works' );

my $result = $plugin->enable;
is( ref($result), 'Koha::Plugin::Test' );

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

$result = $plugin->disable;
is( ref($result), 'Koha::Plugin::Test' );

@plugins = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins();
@names = map { $_->get_metadata()->{'name'} } @plugins;
is( scalar grep( /^Test Plugin$/, @names), 0, "GetPlugins does not found disabled Test Plugin" );

@plugins = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins({ all => 1 });
@names = map { $_->get_metadata()->{'name'} } @plugins;
is( scalar grep( /^Test Plugin$/, @names), 1, "With all param, GetPlugins found disabled Test Plugin" );

for my $pass ( 1 .. 2 ) {
    my $plugins_dir;
    my $module_name = 'Koha::Plugin::Com::ByWaterSolutions::KitchenSink';
    my $pm_path = 'Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm';
    if ( $pass == 1 ) {
        my $plugins_dir1 = tempdir( CLEANUP => 1 );
        t::lib::Mocks::mock_config('pluginsdir', $plugins_dir1);
        $plugins_dir = $plugins_dir1;
        push @INC, $plugins_dir1;
    } else {
        my $plugins_dir1 = tempdir( CLEANUP => 1 );
        my $plugins_dir2 = tempdir( CLEANUP => 1 );
        t::lib::Mocks::mock_config('pluginsdir', [ $plugins_dir2, $plugins_dir1 ]);
        $plugins_dir = $plugins_dir2;
        pop @INC;
        push @INC, $plugins_dir2;
        push @INC, $plugins_dir1;
    }
    my $full_pm_path = $plugins_dir . '/' . $pm_path;

    my $ae = Archive::Extract->new( archive => "$Bin/KitchenSinkPlugin.kpz", type => 'zip' );
    unless ( $ae->extract( to => $plugins_dir ) ) {
        warn "ERROR: " . $ae->error;
    }
    use_ok('Koha::Plugin::Com::ByWaterSolutions::KitchenSink');
    $plugin = Koha::Plugin::Com::ByWaterSolutions::KitchenSink->new({ enable_plugins => 1});
    my $table = $plugin->get_qualified_table_name( 'mytable' );

    ok( -f $plugins_dir . "/Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm", "KitchenSink plugin installed successfully" );
    $INC{$pm_path} = $full_pm_path; # FIXME I do not really know why, but if this is moved before the $plugin constructor, it will fail with Can't locate object method "new" via package "Koha::Plugin::Com::ByWaterSolutions::KitchenSink"
    warning_is { Koha::Plugins->new( { enable_plugins => 1 } )->InstallPlugins(); } undef;
    ok( -f $full_pm_path, "Koha::Plugins::Handler::delete works correctly (pass $pass)" );
    Koha::Plugins::Handler->delete({ class => "Koha::Plugin::Com::ByWaterSolutions::KitchenSink", enable_plugins => 1 });
    my $sth = C4::Context->dbh->table_info( undef, undef, $table, 'TABLE' );
    my $info = $sth->fetchall_arrayref;
    is( @$info, 0, "Table $table does no longer exist" );
    ok( !( -f $full_pm_path ), "Koha::Plugins::Handler::delete works correctly (pass $pass)" );
}

subtest 'output and output_html tests' => sub {

    plan tests => 6;

    # Trick stdout to be able to test
    local *STDOUT;
    my $stdout;
    open STDOUT, '>', \$stdout;

    my $plugin = Koha::Plugin::Test->new({ enable_plugins => 1, cgi => CGI->new });
    $plugin->test_output;

    like($stdout, qr/Cache-control: no-cache/, 'force_no_caching sets Cache-control as desired');
    like($stdout, qr{Content-Type: application/json; charset=UTF-8}, 'Correct content-type');
    like($stdout, qr{¡Hola output!}, 'Correct data');

    # reset the stdout buffer
    $stdout = '';
    close STDOUT;
    open STDOUT, '>', \$stdout;

    $plugin->test_output_html;

    like($stdout, qr/Cache-control: no-cache/, 'force_no_caching sets Cache-control as desired');
    like($stdout, qr{Content-Type: text/html; charset=UTF-8}, 'Correct content-type');
    like($stdout, qr{¡Hola output_html!}, 'Correct data');
};

subtest 'Test _version_compare' => sub {

    plan tests => 12;

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    is( Koha::Plugins::Base::_version_compare( '1.1.1',    '2.2.2' ), -1, "1.1.1 is less then 2.2.2" );
    is( Koha::Plugins::Base::_version_compare( '2.2.2',    '1.1.1' ),  1, "1.1.1 is greater then 2.2.2" );
    is( Koha::Plugins::Base::_version_compare( '1.1.1',    '1.1.1' ),  0, "1.1.1 is equal to 1.1.1" );
    is( Koha::Plugins::Base::_version_compare( '1.01.001', '1.1.1' ),  0, "1.01.001 is equal to 1.1.1" );
    is( Koha::Plugins::Base::_version_compare( '1',        '1.0.0' ),  0, "1 is equal to 1.0.0" );
    is( Koha::Plugins::Base::_version_compare( '1.0',      '1.0.0' ),  0, "1.0 is equal to 1.0.0" );

    # OO tests
    my $plugin = Koha::Plugin::Test->new;
    is( $plugin->_version_compare( '1.1.1',    '2.2.2' ), -1, "1.1.1 is less then 2.2.2" );
    is( $plugin->_version_compare( '2.2.2',    '1.1.1' ),  1, "1.1.1 is greater then 2.2.2" );
    is( $plugin->_version_compare( '1.1.1',    '1.1.1' ),  0, "1.1.1 is equal to 1.1.1" );
    is( $plugin->_version_compare( '1.01.001', '1.1.1' ),  0, "1.01.001 is equal to 1.1.1" );
    is( $plugin->_version_compare( '1',        '1.0.0' ),  0, "1 is equal to 1.0.0" );
    is( $plugin->_version_compare( '1.0',      '1.0.0' ),  0, "1.0 is equal to 1.0.0" );
};

subtest 'bundle_path() tests' => sub {

    plan tests => 1;

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    my @current_dir = File::Spec->splitdir(abs_path(__FILE__));
    # remote Plugins.t
    pop @current_dir;
    # remove /Plugins
    pop @current_dir;
    # remove /Koha
    pop @current_dir;
    # remove db_dependent
    pop @current_dir;

    my $plugin = Koha::Plugin::Test->new;

    is( $plugin->bundle_path, File::Spec->catdir(@current_dir) . '/lib/plugins/Koha/Plugin/Test' );

};

subtest 'new() tests' => sub {

    plan tests => 2;

    t::lib::Mocks::mock_config( 'pluginsdir', [ C4::Context->temporary_directory ] );
    t::lib::Mocks::mock_config( 'enable_plugins', 0 );

    my $result = Koha::Plugins->new();
    is( $result, undef, 'calling new() on disabled plugins returns undef' );

    $result = Koha::Plugins->new({ enable_plugins => 1 });
    is( ref($result), 'Koha::Plugins', 'calling new with enable_plugins makes it override the config' );
};

Koha::Plugins::Methods->delete;
