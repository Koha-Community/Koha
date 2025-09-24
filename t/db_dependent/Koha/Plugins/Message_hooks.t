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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;

use File::Basename;

use C4::Letters qw( SendQueuedMessages );

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'after_hold_create() hook tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_userenv(
        {
            patron     => $patron,
            branchcode => $patron->branchcode
        }
    );

    # Avoid testing useless warnings
    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'after_item_action',      undef );
    $test_plugin->mock( 'after_biblio_action',    undef );
    $test_plugin->mock( 'item_barcode_transform', undef );
    $test_plugin->mock( 'after_hold_action',      undef );

    warnings_like { SendQueuedMessages(); }
    [qr/before_send_messages called/],
        'Plugin hook before_send_messages triggered when SendQueuedMessages is called';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
