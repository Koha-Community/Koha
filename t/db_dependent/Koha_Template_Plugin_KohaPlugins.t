#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 10;
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
    push( @INC, dirname(__FILE__) );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugins::Base');
    use_ok('Koha::Plugin::Test');
}

my $mock_plugin = Test::MockModule->new( 'Koha::Plugin::Test' );
$mock_plugin->mock( 'test_template', sub {
    my ( $self, $file ) = @_;
    my $template = $self->get_template({ file => $file });
    $template->param( filename => $file );
    return $template->output;
});

use_ok( 'Koha::Template::Plugin::KohaPlugins', 'Can use Koha::Template::Plugin::KohaPlugins' );

ok( my $plugin = Koha::Template::Plugin::KohaPlugins->new(), 'Able to instantiate template plugin' );

t::lib::Mocks::mock_preference('UseKohaPlugins',1);
t::lib::Mocks::mock_config('enable_plugins',1);
ok( index( $plugin->get_plugins_opac_js, 'Koha::Plugin::Test::opac_js' ) != -1, 'Test plugin opac_js return value is part of code returned by get_plugins_opac_js' );
ok( index( $plugin->get_plugins_opac_head, 'Koha::Plugin::Test::opac_head' ) != -1, 'Test plugin opac_head return value is part of code returned by get_plugins_opac_head' );

t::lib::Mocks::mock_preference('UseKohaPlugins',0);
t::lib::Mocks::mock_config('enable_plugins',0);
is( $plugin->get_plugins_opac_js, q{}, 'Test plugin opac_js return value is empty' );
is( $plugin->get_plugins_opac_head, q{}, 'Test plugin opac_head return value is empty' );
