#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 35;
use CGI;
use File::Basename;
use File::Temp qw( tempdir tempfile );
use FindBin qw($Bin);
use Archive::Extract;
use Module::Load::Conditional qw(can_load);
use Test::MockModule;

use C4::Context;
use Koha::UploadedFile;

use t::lib::Mocks;

BEGIN {
    push( @INC, dirname(__FILE__) . '/../lib' );

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

ok( can_load( modules => { "Koha::Plugin::Test" => undef } ), 'Test can_load' );

my $plugin = Koha::Plugin::Test->new({ enable_plugins => 1, cgi => CGI->new });

isa_ok( $plugin, "Koha::Plugin::Test", 'Test plugin class' );
isa_ok( $plugin, "Koha::Plugins::Base", 'Test plugin parent class' );

ok( $plugin->can('report'), 'Test plugin can report' );
ok( $plugin->can('tool'), 'Test plugin can tool' );
ok( $plugin->can('to_marc'), 'Test plugin can to_marc' );
ok( $plugin->can('opac_online_payment'), 'Test plugin can opac_online_payment' );
ok( $plugin->can('opac_online_payment_begin'), 'Test plugin can opac_online_payment_begin' );
ok( $plugin->can('opac_online_payment_end'), 'Test plugin can opac_online_payment_end' );
ok( $plugin->can('opac_head'), 'Test plugin can opac_head' );
ok( $plugin->can('opac_js'), 'Test plugin can opac_js' );
ok( $plugin->can('configure'), 'Test plugin can configure' );
ok( $plugin->can('install'), 'Test plugin can install' );
ok( $plugin->can('uninstall'), 'Test plugin can install' );

is( Koha::Plugins::Handler->run({ class => "Koha::Plugin::Test", method => 'report', enable_plugins => 1 }), "Koha::Plugin::Test::report", 'Test run plugin report method' );

my $metadata = $plugin->get_metadata();
is( $metadata->{'name'}, 'Test Plugin', 'Test $plugin->get_metadata()' );

is( $plugin->get_qualified_table_name('mytable'), 'koha_plugin_test_mytable', 'Test $plugin->get_qualified_table_name()' );
is( $plugin->get_plugin_http_path(), '/plugin/Koha/Plugin/Test', 'Test $plugin->get_plugin_http_path()' );

# test absolute path change in get_template with Koha::Plugin::Test
# using the mock set before
# we also add tmpdir as an approved template dir
t::lib::Mocks::mock_config( 'pluginsdir', [ Koha::UploadedFile->temporary_directory ] );
my ( $fh, $fn ) = tempfile( SUFFIX => '.tt', UNLINK => 1 );
print $fh 'I am [% filename %]';
close $fh;
my $classname = ref($plugin);
like( $plugin->test_template($fn), qr/^I am $fn/, 'Template works' );

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
    Koha::Plugins::Handler->delete({ class => "Koha::Plugin::Com::ByWaterSolutions::KitchenSink", enable_plugins => 1 });
    my $sth = C4::Context->dbh->table_info( undef, undef, $table, 'TABLE' );
    my $info = $sth->fetchall_arrayref;
    is( @$info, 0, "Table $table does no longer exist" );
    ok( !( -f $full_pm_path ), "Koha::Plugins::Handler::delete works correctly." );
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
