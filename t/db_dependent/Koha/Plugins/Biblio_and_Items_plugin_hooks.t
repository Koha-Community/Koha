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

use Test::More tests => 5;
use Test::Warn;

use File::Basename;

use C4::Biblio qw(AddBiblio ModBiblio);
use C4::Items;

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

subtest 'after_biblio_action() and after_item_action() hooks tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'item_barcode_transform', undef );

    my $biblio_id;

    warning_like { ( $biblio_id, undef ) = C4::Biblio::AddBiblio( MARC::Record->new(), '' ); }
            qr/after_biblio_action called with action: create, ref: Koha::Biblio/,
            'AddBiblio calls the hook with action=create';

    warning_like { C4::Biblio::ModBiblio( MARC::Record->new(), $biblio_id, '' ); }
            qr/after_biblio_action called with action: modify, ref: Koha::Biblio/,
            'ModBiblio calls the hook with action=modify';

    my $item;
    warning_like { $item = $builder->build_sample_item({ biblionumber => $biblio_id }); }
            qr/after_item_action called with action: create, ref: Koha::Item item_id defined: yes itemnumber defined: yes/,
            'AddItem calls the hook with action=create';

    warning_like { $item->location('shelves')->store; }
            qr/after_item_action called with action: modify, ref: Koha::Item item_id defined: yes itemnumber defined: yes/,
            'ModItem calls the hook with action=modify';

    my $itemnumber = $item->id;
    warning_like { $item->delete; }
            qr/after_item_action called with action: delete, id: $itemnumber/,
            'DelItem calls the hook with action=delete, item_id passed';

    warning_like { C4::Biblio::DelBiblio( $biblio_id ); }
            qr/after_biblio_action called with action: delete, id: $biblio_id/,
            'DelBiblio calls the hook with action=delete biblio_id passed';

    $schema->storage->txn_rollback;
    Koha::Plugins::Methods->delete;
};

subtest 'before_biblio_action() hooks tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $subfield_contents = 'Arte club';

    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'after_biblio_action', undef );

    # Defaults to avoid noise
    my $options = {
        disable_autolink  => 1,
        skip_holds_queue  => 1,
        skip_record_index => 1,
    };

    # Add a record
    my ( $biblio_id, undef ) = C4::Biblio::AddBiblio( MARC::Record->new(), '' );

    my $record = Koha::Biblios->find($biblio_id)->metadata->record;

    my @fields_990 = $record->field('990');

    is( scalar @fields_990, 1, 'One field added' );
    is( $fields_990[0]->subfield('a'), $subfield_contents );

    # Simulate editing the record
    ModBiblio( $record, $biblio_id, '', $options );

    $record = Koha::Biblios->find($biblio_id)->record;

    @fields_990 = $record->field('990');
    # This is to highlight that is the plugin responsibility to choose what to do on the record
    is( scalar @fields_990, 2, 'Two saves, two fields' );

    foreach my $index (qw(0 1)) {
        is( $fields_990[$index]->subfield('a'), $subfield_contents );
    }

    $schema->storage->txn_rollback;
    Koha::Plugins::Methods->delete;
};
