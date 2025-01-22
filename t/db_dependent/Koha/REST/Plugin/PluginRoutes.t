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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Mojo;
use Test::Warn;
use Test::MockModule;

use File::Basename;
use t::lib::Mocks;

# Dummy app for testing the plugin
use Mojolicious::Lite;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );
}

use Koha::Database;
use Koha::Plugins;
use t::lib::TestBuilder;

my $logger = Test::MockModule->new('Koha::Logger');
$logger->mock(
    'error',
    sub {
        shift;
        warn @_;
    }
);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'NotifyPasswordChange', undef );

subtest 'Bad plugins tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

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
    warning_like { $t = Test::Mojo->new('Koha::REST::V1'); }
    [
        qr{Could not load REST API spec bundle: /paths/~0001contrib~0001badass},
        qr{bother_wrong/put/parameters/0: /oneOf/1 Properties not allowed:},
        qr{Plugin Koha::Plugin::BadAPIRoute route injection failed: The resulting spec is invalid. Skipping Bad API Route Plugin},
    ],
        'Bad plugins raise warning';

    my $routes = get_defined_routes($t);

    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok( !exists $routes->{'/contrib/badass/patrons/bother_wrong'}, 'Route doesn\'t exist' );
    ok( exists $routes->{'/contrib/testplugin/patrons/bother'},    'Route exists' );

    $schema->storage->txn_rollback;
};

subtest 'Disabled plugins tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

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
    ok(
        !exists $routes->{'/contrib/testplugin/patrons/bother'},
        'Plugin disabled, route not defined'
    );

    $good_plugin->enable;

    $t      = Test::Mojo->new('Koha::REST::V1');
    $routes = get_defined_routes($t);

    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok(
        exists $routes->{'/contrib/testplugin/patrons/bother'},
        'Plugin enabled, route defined'
    );

    $schema->storage->txn_rollback;
};

subtest 'Permissions and access to plugin routes tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    # enable BASIC auth
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    # Silence warnings from unrelated plugins feature
    my $plugin_mock = Test::MockModule->new('Koha::Plugin::Test');
    $plugin_mock->mock( 'patron_barcode_transform', undef );

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
    warning_like { $t = Test::Mojo->new('Koha::REST::V1'); }
    [
        qr{Could not load REST API spec bundle: /paths/~0001contrib~0001badass},
        qr{bother_wrong/put/parameters/0: /oneOf/1 Properties not allowed:},
        qr{Plugin Koha::Plugin::BadAPIRoute route injection failed: The resulting spec is invalid. Skipping Bad API Route Plugin},
    ],
        'Bad plugins raise warning';

    my $routes = get_defined_routes($t);
    ok( exists $routes->{'/contrib/testplugin/patrons/bother'},        'Route exists' );
    ok( exists $routes->{'/contrib/testplugin/public/patrons/bother'}, 'Route exists' );

    C4::Context->set_preference( 'RESTPublicAnonymousRequests', 0 );

    $t->get_ok('/api/v1/contrib/testplugin/public/patrons/bother')
        ->status_is( 200, 'Plugin routes not affected by RESTPublicAnonymousRequests' )
        ->json_is( { bothered => Mojo::JSON->true } );

    C4::Context->set_preference( 'RESTPublicAnonymousRequests', 1 );

    $t->get_ok('/api/v1/contrib/testplugin/public/patrons/bother')
        ->status_is( 200, 'Plugin routes not affected by RESTPublicAnonymousRequests' )
        ->json_is( { bothered => Mojo::JSON->true } );

    $t->get_ok('/api/v1/contrib/testplugin/patrons/bother')
        ->status_is( 401, 'Plugin routes honour permissions, anonymous access denied' );

    # Create a patron with permissions, but the wrong ones: 3 => parameters
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    $t->get_ok("//$userid:$password@/api/v1/contrib/testplugin/patrons/bother")
        ->status_is( 403, 'Plugin routes honour permissions, wrong permissions, access denied' );

    # Set the patron permissions to the right ones: 4 => borrowers
    $librarian->set( { flags => 2**4 } )->store->discard_changes;

    $t->get_ok("//$userid:$password@/api/v1/contrib/testplugin/patrons/bother")
        ->status_is( 200, 'Plugin routes honour permissions, right permissions, access granted' )
        ->json_is( { bothered => Mojo::JSON->true } );

    $schema->storage->txn_rollback;
};

subtest 'needs_install use case tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # enable plugins
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    my $good_plugin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    # mock Version before initializing the API class
    t::lib::Mocks::mock_preference( 'Version', undef );

    # initialize Koha::REST::V1 after mocking

    my $t      = Test::Mojo->new('Koha::REST::V1');
    my $routes = get_defined_routes($t);

    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok(
        !exists $routes->{'/contrib/testplugin/patrons/bother'},
        'Plugin enabled, route not defined as C4::Context->needs_install is true'
    );

    t::lib::Mocks::mock_preference( 'Version', '3.0.0' );

    Koha::Plugins->RemovePlugins( { destructive => 1 } );    # FIXME destructive seems not to be needed here
    $plugins->InstallPlugins;

    # re-initialize Koha::REST::V1 after mocking
    $t      = Test::Mojo->new('Koha::REST::V1');
    $routes = get_defined_routes($t);

    # Support placeholders () and <>  (latter style used starting with Mojolicious::Plugin::OpenAPI@1.28)
    # TODO: remove () if minimum version is bumped to at least 1.28.
    ok(
        exists $routes->{'/contrib/testplugin/patrons/bother'},
        'Plugin enabled, route defined as C4::Context->needs_install is false'
    );

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
    my $methods = $route->methods // [];
    my $verb    = !$methods ? '*' : uc join ',', @$methods;
    $routes->{$path}->{$verb} = 1;

    $depth++;
    traverse_routes( $_, $depth, $routes ) for @{ $route->children };
    $depth--;
}
