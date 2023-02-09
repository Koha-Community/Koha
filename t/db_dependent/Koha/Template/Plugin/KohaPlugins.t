#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 18;
use Test::Warn;
use CGI;
use File::Basename;
use File::Spec;
use File::Temp qw( tempdir tempfile );
use FindBin qw($Bin);
use Archive::Extract;
use Module::Load::Conditional qw(can_load);
use Test::MockModule;

use C4::Context;
use t::lib::Mocks;

BEGIN {
    push( @INC, dirname(__FILE__) . '/../../../../lib/plugins' );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugins::Base');
    use_ok('Koha::Plugin::Test');
}

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Enable all plugins
my $plugins = Koha::Plugins->new;
$plugins->InstallPlugins;
my @plugins = $plugins->GetPlugins({ all => 1, class => 'Koha::Plugin::Test' });
map { $_->enable; } @plugins;

my $mock_plugin = Test::MockModule->new( 'Koha::Plugin::Test' );
$mock_plugin->mock( 'test_template', sub {
    my ( $self, $file ) = @_;
    my $template = $self->get_template({ file => $file });
    $template->param( filename => $file );
    return $template->output;
});

use_ok( 'Koha::Template::Plugin::KohaPlugins', 'Can use Koha::Template::Plugin::KohaPlugins' );

ok( my $plugin = Koha::Template::Plugin::KohaPlugins->new(), 'Able to instantiate template plugin' );

ok( index( $plugin->get_plugins_opac_js, 'Koha::Plugin::Test::opac_js' ) != -1, 'Test plugin opac_js return value is part of code returned by get_plugins_opac_js' );
ok( index( $plugin->get_plugins_opac_head, 'Koha::Plugin::Test::opac_head' ) != -1, 'Test plugin opac_head return value is part of code returned by get_plugins_opac_head' );
ok( index( $plugin->get_plugins_intranet_js, 'Koha::Plugin::Test::intranet_js' ) != -1, 'Test plugin intranet_js return value is part of code returned by get_plugins_intranet_js' );
ok( index( $plugin->get_plugins_intranet_head, 'Koha::Plugin::Test::intranet_head' ) != -1, 'Test plugin intranet_head return value is part of code returned by get_plugins_intranet_head' );

sub boom {
    my ( $self, $file ) = @_;
    die "Something wrong is happening in this hook";
}
$mock_plugin->mock( 'opac_head',     \&boom );
$mock_plugin->mock( 'opac_js',       \&boom );
$mock_plugin->mock( 'intranet_head', \&boom );
$mock_plugin->mock( 'intranet_js',   \&boom );
warning_like { $plugin->get_plugins_opac_head } qr{Error calling 'opac_head' on the Koha::Plugin::Testplugin \(Something wrong is happening in this hook};
warning_like { $plugin->get_plugins_opac_js } qr{Error calling 'opac_js' on the Koha::Plugin::Testplugin \(Something wrong is happening in this hook};
warning_like { $plugin->get_plugins_intranet_head } qr{Error calling 'intranet_head' on the Koha::Plugin::Testplugin \(Something wrong is happening in this hook};
warning_like { $plugin->get_plugins_intranet_js } qr{Error calling 'intranet_js' on the Koha::Plugin::Testplugin \(Something wrong is happening in this hook};

t::lib::Mocks::mock_config('enable_plugins',0);
is( $plugin->get_plugins_opac_js, q{}, 'Test plugin opac_js return value is empty' );
is( $plugin->get_plugins_opac_head, q{}, 'Test plugin opac_head return value is empty' );
is( $plugin->get_plugins_intranet_js, q{}, 'Test plugin intranet_js return value is empty' );
is( $plugin->get_plugins_intranet_head, q{}, 'Test plugin intranet_head return value is empty' );

$schema->storage->txn_rollback;
