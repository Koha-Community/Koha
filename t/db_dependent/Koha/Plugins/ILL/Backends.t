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
use File::Basename;
use Test::More tests => 4;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::BackendClass');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'get_backend_plugin(), new_ill_backend() and load_backend() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::ILL::Request->new->get_backend_plugin('BackendClass');

    is(
        ref($plugin), 'Koha::Plugin::BackendClass',
        'Returns our Test Plugin which implements the Test Plugin backend'
    );
    my $backend = $plugin->new_ill_backend();
    is( ref($backend), 'Koha::Plugin::ILL::TestClass', 'Returns the right object class' );

    my $request = Koha::ILL::Request->new->load_backend('BackendClass');
    ok( $request->{_plugin}, 'Instantiated plugin stored for later use' );
    is( ref( $request->{_plugin} ), 'Koha::Plugin::BackendClass', 'Class is correct' );

    ok( $request->{_my_backend}, 'Instantiated backend stored for later use' );
    is( ref( $request->{_my_backend} ), 'Koha::Plugin::ILL::TestClass', 'Returns the right object class' );

    Koha::Plugins::Methods->delete;
    $schema->storage->txn_rollback;
};
