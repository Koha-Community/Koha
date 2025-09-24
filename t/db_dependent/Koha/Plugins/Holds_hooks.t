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
use Test::More tests => 7;
use Test::MockModule;
use Test::Warn;

use File::Basename;

use C4::Reserves qw( AddReserve );

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
    $test_plugin->mock( 'before_send_messages',   undef );

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    warnings_like {
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item_1->biblionumber
            }
        );
    }
    [
        qr/after_hold_create is deprecated and will be removed soon/,
        qr/after_hold_create called with parameter Koha::Hold/
    ],
        'AddReserve calls the after_hold_create hook, deprecation warning found';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};

subtest 'after_hold_action (placed) hook tests' => sub {

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
    $test_plugin->mock( 'after_hold_create',      undef );

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    warnings_like {
        AddReserve(
            {
                branchcode     => $patron->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item_1->biblionumber
            }
        );
    }
    [
        qr/after_hold_create is deprecated and will be removed soon/,
        qr/after_hold_action called with action: place, ref: Koha::Hold/,
    ],
        'AddReserve calls the after_hold_action hook';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};

subtest 'Koha::Hold tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # Reduce noise
    t::lib::Mocks::mock_preference( 'HoldFeeMode', 'not_always' );
    t::lib::Mocks::mock_preference( 'HoldsLog',    0 );

    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron->id, found => undef,
            }
        }
    );

    warning_like {
        $hold->fill;
    }
    qr/after_hold_action called with action: fill, ref: Koha::Old::Hold/,
        '->fill calls the after_hold_action hook';

    $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron->id, found => undef,
            }
        }
    );

    warning_like {
        $hold->suspend_hold;
    }
    qr/after_hold_action called with action: suspend, ref: Koha::Hold/,
        '->suspend_hold calls the after_hold_action hook';

    warning_like {
        $hold->resume;
    }
    qr/after_hold_action called with action: resume, ref: Koha::Hold/,
        '->resume calls the after_hold_action hook';

    warning_like {
        $hold->set_transfer;
    }
    qr/after_hold_action called with action: transfer, ref: Koha::Hold/,
        '->set_transfer calls the after_hold_action hook';

    warning_like {
        $hold->set_processing;
    }
    qr/after_hold_action called with action: processing, ref: Koha::Hold/,
        '->set_processing calls the after_hold_action hook';

    warning_like {
        $hold->set_waiting;
    }
    qr/after_hold_action called with action: waiting, ref: Koha::Hold/,
        '->set_waiting calls the after_hold_action hook';

    warning_like {
        $hold->cancel;
    }
    qr/after_hold_action called with action: cancel, ref: Koha::Old::Hold/,
        '->cancel calls the after_hold_action hook';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
