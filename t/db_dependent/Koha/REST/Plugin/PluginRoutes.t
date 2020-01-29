#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use File::Basename;
use t::lib::Mocks;

use JSON::Validator::OpenAPI::Mojolicious;

# Dummy app for testing the plugin
use Mojolicious::Lite;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../../lib';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );
}

use Koha::Database;
use Koha::Plugins;

my $schema = Koha::Database->new->schema;

subtest 'Bad plugins tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    t::lib::Mocks::mock_preference( 'UseKohaPlugins', 1 );

    # remove any existing plugins that might interfere
    Koha::Plugins::Methods->search->delete;
    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my @plugins = $plugins->GetPlugins( { all => 1 } );
    foreach my $plugin (@plugins) {
        $plugin->enable;
    }

    # initialize Koha::REST::V1 after mocking
    my $t;
    warning_is
        { $t = Test::Mojo->new('Koha::REST::V1'); }
        'The resulting spec is invalid. Skipping Bad API Route Plugin',
        'Bad plugins raise warning';

    my $routes = get_defined_routes($t);
    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok( !exists $routes->{'/contrib/badass/patrons/(:patron_id)/bother_wrong'} && !exists $routes->{'/contrib/badass/patrons/<:patron_id>/bother_wrong'}, 'Route doesn\'t exist' );
    ok( exists $routes->{'/contrib/testplugin/patrons/(:patron_id>)/bother'} || exists $routes->{'/contrib/testplugin/patrons/<:patron_id>/bother'}, 'Route exists' );

    $schema->storage->txn_rollback;
};

subtest 'Disabled plugins tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    t::lib::Mocks::mock_preference( 'UseKohaPlugins', 1 );

    my $good_plugin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my @plugins = $plugins->GetPlugins( { all => 1 } );
    foreach my $plugin (@plugins) {
        $plugin->disable;
        $good_plugin = $plugin
            if $plugin->{metadata}->{description} eq 'Test plugin';
    }

    # initialize Koha::REST::V1 after mocking
    my $t = Test::Mojo->new('Koha::REST::V1');

    my $routes = get_defined_routes($t);
    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok( !exists $routes->{'/contrib/testplugin/patrons/(:patron_id)/bother'} && !exists $routes->{'/contrib/testplugin/patrons/<:patron_id>/bother'},
        'Plugin disabled, route not defined' );

    $good_plugin->enable;

    $t      = Test::Mojo->new('Koha::REST::V1');
    $routes = get_defined_routes($t);

    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok( exists $routes->{'/contrib/testplugin/patrons/(:patron_id)/bother'} || exists $routes->{'/contrib/testplugin/patrons/<:patron_id>/bother'},
        'Plugin enabled, route defined' );

    $schema->storage->txn_rollback;
};

sub get_defined_routes {
    my ($t) = @_;
    my $routes = {};
    traverse_routes( $_, 0, $routes ) for @{ $t->app->routes->children };

    return $routes;
}

sub traverse_routes {
    my ( $route, $depth, $routes ) = @_;

    # Pattern
    my $path = $route->pattern->unparsed || '/';

    # Methods
    my $via = $route->via;
    my $verb = !$via ? '*' : uc join ',', @$via;
    $routes->{$path}->{$verb} = 1;

    $depth++;
    traverse_routes( $_, $depth, $routes ) for @{ $route->children };
    $depth--;
}
