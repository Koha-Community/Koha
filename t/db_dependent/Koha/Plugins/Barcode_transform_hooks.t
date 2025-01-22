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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;

use File::Basename;

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

subtest 'patron_barcode_transform() and item_barcode_transform() hook tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Avoid testing useless warnings
    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'after_item_action',   undef );
    $test_plugin->mock( 'after_biblio_action', undef );

    my $plugins = Koha::Plugins->new;

    warning_is { $plugins->InstallPlugins; } undef;

    C4::Context->dbh->do("DELETE FROM plugin_methods WHERE plugin_class LIKE '%TestBarcodes%'");

    my $plugin = Koha::Plugin::Test->new->enable;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { cardnumber => undef } } );

    t::lib::Mocks::mock_preference( 'autoMemberNum', 1 );
    warnings_like { $patron->store(); }
    [
        qr/patron_barcode_transform called with parameter: /,
        qr/patron_barcode_transform called with parameter: /
    ],
        'Koha::Patron::store calls the patron_barcode_transform hook twice when autoMemberNum is enabled and cardnumber is undefined';

    $patron->cardnumber('TEST');
    warning_like { $patron->store(); }
    qr/patron_barcode_transform called with parameter: TEST/,
        'Koha::Patron::store calls the patron_barcode_transform hook once when autoMemberNum is enabled and cardnumber is set';

    t::lib::Mocks::mock_preference( 'autoMemberNum', 0 );
    $patron->cardnumber(undef);
    warning_like { $patron->store(); }
    qr/patron_barcode_transform called with parameter: /,
        'Koha::Patron::store calls the patron_barcode_transform hook once when autoMemberNum is disabled and cardnumber is undefined';

    t::lib::Mocks::mock_userenv(
        {
            patron     => $patron,
            branchcode => $patron->branchcode
        }
    );

    my $item;
    warning_like { $item = $builder->build_sample_item(); }
    qr/Plugin error \(Test Plugin\): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: /,
        'Koha::Item->store calls the item_barcode_transform hook';

    $item->barcode('THISISATEST');

    warning_like { $item->store(); }
    qr/Plugin error \(Test Plugin\): Exception 'Koha::Exception' thrown 'item_barcode_transform called with parameter: THISISATEST'/,
        'Koha::Item->store calls the item_barcode_transform hook';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
