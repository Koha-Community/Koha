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

use CGI;
use Cwd qw(abs_path);
use File::Basename;
use File::Spec;
use File::Temp                qw( tempdir tempfile );
use FindBin                   qw($Bin);
use List::MoreUtils           qw(none);
use Module::Load::Conditional qw(can_load);
use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 20;
use Test::Warn;
use Test::Exception;

use C4::Context;
use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::Plugins::Datas;
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

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'call() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    my $plugins = Koha::Plugins->new( { enable_plugins => 1 } );

    my @plugins;

    warning_is { @plugins = $plugins->InstallPlugins; } undef;

    foreach my $plugin (@plugins) {
        $plugin->enable();
    }

    my @responses = Koha::Plugins->call( 'check_password', { password => 'foo' } );

    my $expected = [ { error => 1, msg => 'PIN should be four digits' } ];
    is_deeply( \@responses, $expected, 'call() should return all responses from plugins' );

    # Make sure parameters are correctly passed to the plugin method
    @responses = Koha::Plugins->call( 'check_password', { password => '1234' } );

    $expected = [ { error => 0 } ];
    is_deeply( \@responses, $expected, 'call() should return all responses from plugins' );

    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    @responses = Koha::Plugins->call( 'check_password', { password => '1234' } );
    is_deeply( \@responses, [], 'call() should return an empty array if plugins are disabled' );

    $schema->storage->txn_rollback;
};

subtest 'more call() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    my $plugins = Koha::Plugins->new( { enable_plugins => 1 } );
    my @plugins;

    warning_is { @plugins = $plugins->InstallPlugins; } undef;

    foreach my $plugin (@plugins) {
        $plugin->enable();
    }

    # Barcode is multiplied by 2 by Koha::Plugin::Test, and again by 4 by Koha::Plugin::TestItemBarcodeTransform
    # showing that call has passed the same ref to multiple plugins to operate on
    my $bc = 1;
    warnings_are { Koha::Plugins->call( 'item_barcode_transform', \$bc ); }
    [
        qq{Plugin error (Test Plugin): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 1'\n},
        qq{Plugin error (Test Plugin for item_barcode_transform): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 2'\n}
    ];
    is( $bc, 8, "Got expected response" );

    my $cn = 'abcd';
    warnings_are { Koha::Plugins->call( 'item_barcode_transform', \$bc ); }
    [
        qq{Plugin error (Test Plugin): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 8'\n},
        qq{Plugin error (Test Plugin for item_barcode_transform): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: 16'\n}
    ];
    is( $cn, 'abcd', "Got expected response" );

    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    $bc = 1;
    Koha::Plugins->call( 'item_barcode_transform', \$bc );
    is( $bc, 1, "call should return the original arguments if plugins are disabled" );

    $schema->storage->txn_rollback;
};

subtest 'feature_enabled tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    my $enabled = Koha::Plugins->feature_enabled('check_password');
    ok( !$enabled, "check_password not available when plugins are disabled" );

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    my $plugins = Koha::Plugins->new( { enable_plugins => 1 } );

    my @plugins;
    warning_is { @plugins = $plugins->InstallPlugins; } undef;

    $enabled = Koha::Plugins->feature_enabled('check_password');
    ok( !$enabled, "check_password not available when plugins are installed but not enabled" );

    foreach my $plugin (@plugins) {
        $plugin->enable();
    }

    $enabled = Koha::Plugins->feature_enabled('check_password');
    ok( $enabled, "check_password is available when at least one enabled plugin supports it" );

    $schema->storage->txn_rollback;
};

subtest 'GetPlugins() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data (FIXME not done)
    Koha::Plugins->RemovePlugins;

    my $plugins = Koha::Plugins->new( { enable_plugins => 1 } );

    warning_is { $plugins->InstallPlugins; } undef;

    my @plugins = $plugins->GetPlugins( { method => 'report', all => 1 } );

    my @names = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names ), 1, "Koha::Plugins::GetPlugins functions correctly" );

    @plugins = $plugins->GetPlugins( { metadata => { my_example_tag => 'find_me' }, all => 1 } );
    @names   = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar @names, 2, "Only two plugins found via a metadata tag" );

    $schema->storage->txn_rollback;
};

subtest 'InstallPlugins() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    # Temporarily remove any installed plugins data
    Koha::Plugins::Methods->delete;
    $schema->resultset('PluginData')->delete;

    # Tests for the exclude parameter
    # Test the returned plugins of the InstallPlugins subroutine
    my $excluded_plugins  = [ "Koha::Plugin::Test", "Koha::Plugin::MarcFieldValues" ];
    my $plugins           = Koha::Plugins->new( { enable_plugins => 1 } );
    my @installed_plugins = $plugins->InstallPlugins( { exclude => $excluded_plugins } );

    foreach my $excluded_plugin ( @{$excluded_plugins} ) {
        ok(
            none { $_ eq $excluded_plugin } ( map { $_->{class} } @installed_plugins ),
            "Excluded plugin not returned ($excluded_plugin)"
        );
    }

    # Test the plugins in the database
    my @plugins = $plugins->GetPlugins( { all => 1, error => 1 } );
    foreach my $excluded_plugin ( @{$excluded_plugins} ) {
        ok(
            none { $_ eq $excluded_plugin } ( map { $_->{class} } @plugins ),
            "Excluded plugin not installed ($excluded_plugin)"
        );
    }

    # Remove installed plugins data
    Koha::Plugins::Methods->delete;
    $schema->resultset('PluginData')->delete;

    # Tests for the include parameter
    # Test the returned plugins of the InstallPlugins subroutine
    @installed_plugins =
        $plugins->InstallPlugins( { include => [ "Koha::Plugin::Test", "Koha::Plugin::MarcFieldValues" ] } );

    my $result = 1;
    foreach my $plugin_class ( map { $_->{class} } @installed_plugins ) {
        $result = 0 unless ( "$plugin_class" =~ ":Test\$" || "$plugin_class" =~ ":MarcFieldValues\$" );
    }
    ok( $result, "Only included plugins are returned" );

    # Test the plugins in the database
    @plugins = $plugins->GetPlugins( { all => 1, error => 1 } );

    $result = 1;
    foreach my $plugin_class ( map { $_->{class} } @plugins ) {
        $result = 0 unless ( "$plugin_class" =~ ":Test\$" || "$plugin_class" =~ ":MarcFieldValues\$" );
    }
    ok( $result, "Only included plugins are installed" );

    # Tests when both include and exclude parameter are used simultaneously
    throws_ok {
        $plugins->InstallPlugins( { exclude => ["Koha::Plugin::Test"], include => ["Koha::Plugin::Test"] } );
    }
    'Koha::Exceptions::BadParameter';

    # Tests when the plugin to be installled is not found
    throws_ok {
        $plugins->InstallPlugins( { include => ["Koha::Plugin::NotfoundPlugin"] } );
    }
    'Koha::Exceptions::BadParameter';

    $schema->storage->txn_rollback;
};

subtest 'Version upgrade tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );

    # make sure there's no version on the DB
    Koha::Plugins::Datas->search( { plugin_class => $plugin->{class}, plugin_key => '__INSTALLED_VERSION__' } )->delete;

    $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );
    my $version = $plugin->retrieve_data('__INSTALLED_VERSION__');

    is( $version, $plugin->get_metadata->{version}, 'Version has been populated correctly' );

    $schema->storage->txn_rollback;
};

subtest 'is_enabled() tests' => sub {

    plan tests => 3;
    $schema->storage->txn_begin;

    # Make sure there's no previous installs or leftovers on DB
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    my $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );
    ok( $plugin->is_enabled, 'Plugins enabled by default' );

    # disable
    $plugin->disable;
    ok( !$plugin->is_enabled, 'Calling ->disable disables the plugin' );

    # enable
    $plugin->enable;
    ok( $plugin->is_enabled, 'Calling ->enable enabled the plugin' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Plugin::Test' => sub {
    $schema->storage->txn_begin;
    Koha::Plugins->RemovePlugins( { destructive => 1 } );

    warning_is { Koha::Plugins->new( { enable_plugins => 1 } )->InstallPlugins(); } undef;

    ok(
        Koha::Plugins::Methods->search( { plugin_class => 'Koha::Plugin::Test' } )->count,
        'Test plugin methods added to database'
    );
    is( Koha::Plugins::Methods->search( { plugin_class => 'Koha::Plugin::Test', plugin_method => '_private_sub' } )
            ->count, 0, 'Private methods are skipped' );

    my $mock_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $mock_plugin->mock(
        'test_template',
        sub {
            my ( $self, $file ) = @_;
            my $template = $self->get_template( { file => $file } );
            $template->param( filename => $file );
            return $template->output;
        }
    );

    ok( can_load( modules => { "Koha::Plugin::Test" => undef } ), 'Test can_load' );

    my $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );

    isa_ok( $plugin, "Koha::Plugin::Test",  'Test plugin class' );
    isa_ok( $plugin, "Koha::Plugins::Base", 'Test plugin parent class' );

    ok( $plugin->can('report'),                               'Test plugin can report' );
    ok( $plugin->can('tool'),                                 'Test plugin can tool' );
    ok( $plugin->can('to_marc'),                              'Test plugin can to_marc' );
    ok( $plugin->can('intranet_catalog_biblio_enhancements'), 'Test plugin can intranet_catalog_biblio_enhancements' );
    ok(
        $plugin->can('intranet_catalog_biblio_enhancements_toolbar_button'),
        'Test plugin can intranet_catalog_biblio_enhancements_toolbar_button'
    );
    ok( $plugin->can('opac_online_payment'),       'Test plugin can opac_online_payment' );
    ok( $plugin->can('after_hold_create'),         'Test plugin can after_hold_create' );
    ok( $plugin->can('before_send_messages'),      'Test plugin can before_send_messages' );
    ok( $plugin->can('opac_online_payment_begin'), 'Test plugin can opac_online_payment_begin' );
    ok( $plugin->can('opac_online_payment_end'),   'Test plugin can opac_online_payment_end' );
    ok( $plugin->can('opac_head'),                 'Test plugin can opac_head' );
    ok( $plugin->can('opac_js'),                   'Test plugin can opac_js' );
    ok( $plugin->can('intranet_head'),             'Test plugin can intranet_head' );
    ok( $plugin->can('intranet_js'),               'Test plugin can intranet_js' );
    ok( $plugin->can('item_barcode_transform'),    'Test plugin can barcode_transform' );
    ok( $plugin->can('configure'),                 'Test plugin can configure' );
    ok( $plugin->can('install'),                   'Test plugin can install' );
    ok( $plugin->can('upgrade'),                   'Test plugin can upgrade' );
    ok( $plugin->can('uninstall'),                 'Test plugin can install' );

    is(
        Koha::Plugins::Handler->run( { class => "Koha::Plugin::Test", method => 'report', enable_plugins => 1 } ),
        "Koha::Plugin::Test::report", 'Test run plugin report method'
    );

    my $metadata = $plugin->get_metadata();
    is( $metadata->{'name'}, 'Test Plugin', 'Test $plugin->get_metadata()' );

    is(
        $plugin->get_qualified_table_name('mytable'), 'koha_plugin_test_mytable',
        'Test $plugin->get_qualified_table_name()'
    );
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
    my @plugins = Koha::Plugins->new( { enable_plugins => 1 } )->GetPlugins( { method => 'report' } );

    my @names = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names ), 1, "Koha::Plugins::GetPlugins functions correctly" );
    @plugins = Koha::Plugins->new( { enable_plugins => 1 } )->GetPlugins(
        {
            metadata => { my_example_tag => 'find_me' },
        }
    );

    @names = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names ), 1, "GetPlugins also found Test Plugin via a metadata tag" );

    $result = $plugin->disable;
    is( ref($result), 'Koha::Plugin::Test' );

    @plugins = Koha::Plugins->new( { enable_plugins => 1 } )->GetPlugins();
    @names   = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names ), 0, "GetPlugins does not found disabled Test Plugin" );

    @plugins = Koha::Plugins->new( { enable_plugins => 1 } )->GetPlugins( { all => 1 } );
    @names   = map { $_->get_metadata()->{'name'} } @plugins;
    is( scalar grep( /^Test Plugin$/, @names ), 1, "With all param, GetPlugins found disabled Test Plugin" );

    $schema->storage->txn_rollback;
};

subtest 'RemovePlugins' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    our $class_basename = 'Koha::Plugin::TestMR::' . time;

    sub reload_plugin {
        my ( $i, $mocks ) = @_;
        Koha::Plugins::Data->new(
            { plugin_class => "$class_basename$i", plugin_key => '__ENABLED__', plugin_value => 1 } )->store;
        Koha::Plugins::Method->new( { plugin_class => "$class_basename$i", plugin_method => "testmr$i" } )->store;

        # no_auto => 1 here prevents loading of a not-existing module
        unless ( $mocks->[$i] ) {
            $mocks->[$i] = Test::MockModule->new( "$class_basename$i", no_auto => 1 );
            $mocks->[$i]->mock( new => 1 );
        }
    }

    # We will (re)create new plugins (without modules)
    # This requires mocking can_load from Module::Load::Conditional
    my $mlc_mock = Test::MockModule->new('Koha::Plugins');
    $mlc_mock->mock( can_load => 1 );
    my $plugin_mocks = [];
    my @enabled_plugins;

    subtest 'Destructive flag' => sub {
        reload_plugin( $_, $plugin_mocks ) for 1 .. 3;
        Koha::Plugins->RemovePlugins( { destructive => 1 } );
        is( Koha::Plugins::Datas->count,   0, 'No data in plugin_data' );
        is( Koha::Plugins::Methods->count, 0, 'No data in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;    # testing if cache cleared
        is( scalar @enabled_plugins, 0, 'No enabled plugins' );

        reload_plugin( $_, $plugin_mocks ) for 1 .. 3;
        Koha::Plugins->RemovePlugins( { plugin_class => "${class_basename}2", destructive => 1 } );
        is( Koha::Plugins::Datas->count,   2, '2 in plugin_data' );
        is( Koha::Plugins::Methods->count, 2, '2 in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 2, '2 enabled plugins' );
        Koha::Plugins->RemovePlugins( { destructive => 1 } );
    };

    subtest 'Disable flag' => sub {
        reload_plugin( $_, $plugin_mocks ) for 1 .. 4;
        Koha::Plugins->RemovePlugins( { disable => 1 } );
        is( Koha::Plugins::Datas->count,   4, '4 in plugin_data' );
        is( Koha::Plugins::Methods->count, 0, 'No data in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 0, '0 enabled plugins' );

        reload_plugin( $_, $plugin_mocks ) for 5 .. 6;
        Koha::Plugins->RemovePlugins( { plugin_class => "${class_basename}5", disable => 1 } );
        is( Koha::Plugins::Datas->count,   6, '6 in plugin_data' );
        is( Koha::Plugins::Methods->count, 1, '1 in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 1, '1 enabled plugins' );
        Koha::Plugins->RemovePlugins( { destructive => 1 } );
    };

    subtest 'No flags' => sub {
        reload_plugin( $_, $plugin_mocks ) for 1 .. 2;
        Koha::Plugins->RemovePlugins;
        is( Koha::Plugins::Datas->count,   2, '2 in plugin_data' );
        is( Koha::Plugins::Methods->count, 0, 'No data in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 2, '2 enabled plugins' );

        reload_plugin( $_, $plugin_mocks ) for 3 .. 4;
        Koha::Plugins->RemovePlugins( { plugin_class => "${class_basename}4" } );
        is( Koha::Plugins::Datas->count,   4, '4 in plugin_data' );
        is( Koha::Plugins::Methods->count, 1, '1 in plugin_methods' );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 2, '2 enabled plugins (from cache)' );

        # clear cache and try again, expect 4 since RemovePlugins did not touch plugin_data here
        Koha::Cache::Memory::Lite->clear_from_cache( Koha::Plugins->ENABLED_PLUGINS_CACHE_KEY );
        @enabled_plugins = Koha::Plugins->get_enabled_plugins;
        is( scalar @enabled_plugins, 4, '4 enabled plugins' );
        Koha::Plugins->RemovePlugins( { destructive => 1 } );
    };

    $schema->storage->txn_rollback;
};

subtest 'verbose and errors flag' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    Koha::Plugins->RemovePlugins( { destructive => 1 } );    # clean start

    our $class_basename = 'Koha::Plugin::TestMR::' . time;
    my $plugin_mocks = [];

    # Recreate TestMR plugins without module and mock on Module::Load::Conditional
    reload_plugin( $_, $plugin_mocks ) for 1 .. 2;
    warnings_like { Koha::Plugins->new->GetPlugins } [], 'Verbose was off';
    warnings_like { Koha::Plugins->new->GetPlugins( { verbose => 1 } ) }
    [ qr/TestMR/, qr/TestMR/ ], 'Verbose was on, two warns';

    my ( $plugins, $failures ) = Koha::Plugins->new->GetPlugins( { errors => 1 } );
    is( @$plugins,               0,                    'No good plugins left' );
    is( @$failures,              2,                    'Two failing plugins' );
    is( $failures->[0]->{error}, 1,                    'Failure hash contains error key' );
    is( $failures->[0]->{name},  "${class_basename}1", 'Failure hash contains name key' );

    $schema->storage->txn_rollback;
};

$schema->storage->txn_begin;    # Matching rollback at very end

subtest 'output and output_html tests' => sub {

    plan tests => 6;

    # Trick stdout to be able to test
    local *STDOUT;
    my $stdout;
    open STDOUT, '>', \$stdout;

    my $plugin = Koha::Plugin::Test->new( { enable_plugins => 1, cgi => CGI->new } );
    $plugin->test_output;

    like( $stdout, qr/Cache-control: no-cache/, 'force_no_caching sets Cache-control as desired' );
    like( $stdout, qr{Content-Type: application/json; charset=UTF-8}, 'Correct content-type' );
    like( $stdout, qr{¡Hola output!},                                 'Correct data' );

    # reset the stdout buffer
    $stdout = '';
    close STDOUT;
    open STDOUT, '>', \$stdout;

    $plugin->test_output_html;

    like( $stdout, qr/Cache-control: no-cache/,                'force_no_caching sets Cache-control as desired' );
    like( $stdout, qr{Content-Type: text/html; charset=UTF-8}, 'Correct content-type' );
    like( $stdout, qr{¡Hola output_html!},                     'Correct data' );
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

    my @current_dir = File::Spec->splitdir( abs_path(__FILE__) );

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

    t::lib::Mocks::mock_config( 'pluginsdir',     [ C4::Context->temporary_directory ] );
    t::lib::Mocks::mock_config( 'enable_plugins', 0 );

    my $result = Koha::Plugins->new();
    is( $result, undef, 'calling new() on disabled plugins returns undef' );

    $result = Koha::Plugins->new( { enable_plugins => 1 } );
    is( ref($result), 'Koha::Plugins', 'calling new with enable_plugins makes it override the config' );
};

$schema->storage->txn_rollback;

#!/usr/bin/perl
