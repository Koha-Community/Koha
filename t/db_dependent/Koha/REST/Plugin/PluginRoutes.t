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

use Test::More tests => 1;
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

subtest 'Bad plugins tests' => sub {

    plan tests => 3;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    t::lib::Mocks::mock_preference( 'UseKohaPlugins', 1 );

    # initialize Koha::REST::V1 after mocking
    my $remote_address = '127.0.0.1';
    my $t;

    warning_is
        { $t = Test::Mojo->new('Koha::REST::V1'); }
        'The resulting spec is invalid. Skipping Bad API Route Plugin',
        'Bad plugins raise warning';

    my $routes = get_defined_routes($t);
    ok( !exists $routes->{'/contrib/badass/patrons/(:patron_id)/bother_wrong'}, 'Route doesn\'t exist' );
    ok( exists $routes->{'/contrib/testplugin/patrons/(:patron_id)/bother'}, 'Route exists' );

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
