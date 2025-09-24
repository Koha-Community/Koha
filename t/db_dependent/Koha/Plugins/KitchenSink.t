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
use Archive::Extract;
use File::Temp qw/tempdir/;
use FindBin    qw($Bin);
use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 2;
use Test::Warn;

use t::lib::Mocks;

use C4::Context;
use Koha::Database;
use Koha::Plugins;
use Koha::Plugins::Datas;
use Koha::Plugins::Handler;
use Koha::Plugins::Methods;

my $schema = Koha::Database->new->schema;

subtest 'Fun with KitchenSink, Handler->delete' => sub {
    plan tests => 7;

    create_mytable();    # IMPORTANT: before transaction start (prevent implicit commit)
    $schema->storage->txn_begin;
    t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    my $module_name = 'Koha::Plugin::Com::ByWaterSolutions::KitchenSink';
    my $pm_path     = 'Koha/Plugin/Com/ByWaterSolutions/KitchenSink.pm';
    Koha::Plugins->RemovePlugins( { plugin_class => $module_name, destructive => 1 } );    # just to be safe
    Koha::Plugins->new->InstallPlugins;                                                    # install without KitchenSink
    my ( $count_d, $count_m ) = ( Koha::Plugins::Datas->count, Koha::Plugins::Methods->count );

    # Install KitchenSink, mock install and uninstall
    my $plugins_dir = tempdir( CLEANUP => 1 );
    t::lib::Mocks::mock_config( 'pluginsdir', $plugins_dir );
    push @INC, $plugins_dir;
    my $ae = Archive::Extract->new( archive => "$Bin/KitchenSinkPlugin.kpz", type => 'zip' );
    $ae->extract( to => $plugins_dir ) or warn "ERROR: " . $ae->error;
    my $mock = Test::MockModule->new($module_name);
    $mock->mock( install   => 1 );
    $mock->mock( uninstall => 1 );
    warning_is { Koha::Plugins->new->InstallPlugins; } undef, 'No warnings from InstallPlugins';
    ok( Koha::Plugins::Datas->count > $count_d,   'More records in plugin_data' );
    ok( Koha::Plugins::Methods->count > $count_m, 'More records in plugin_methods' );
    ok( -f "$plugins_dir/$pm_path",               "KitchenSink module found" );

    # Delete via Handler->delete, uninstall has been mocked to prevent implicit commit (DROP TABLE)
    Koha::Plugins::Handler->delete( { class => $module_name } );

    # Final checks
    ok( !-f "$plugins_dir/$pm_path", "Module file no longer found" );
    is( Koha::Plugins::Datas->count,   $count_d, 'Original count in plugin_data' );
    is( Koha::Plugins::Methods->count, $count_m, 'Original count in plugin_methods' );

    $schema->storage->txn_rollback;
    drop_mytable();    # Created before txn, remove after rollback
};

sub create_mytable {

    # This create mimics what KitchenSink would do.
    # The columns are not relevant here.
    C4::Context->dbh->do("CREATE TABLE IF NOT EXISTS mytable ( test int )");
}

sub drop_mytable {
    C4::Context->dbh->do("DROP TABLE mytable");
}
