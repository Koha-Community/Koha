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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use MARC::Record;

use C4::Biblio qw( GetMarcFromKohaField AddBiblio );
use Koha::Biblios;
use Koha::Database;
use Koha::RecordProcessor;

my $schema  = Koha::Database->schema();
my $builder = t::lib::TestBuilder->new();

subtest 'EmbedItemsAvailability tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin();

    my $biblio = Test::MockModule->new('C4::Biblio');
    $biblio->mock(
        'GetMarcFromKohaField',
        sub {
            my ($kohafield) = @_;
            if ( $kohafield eq 'biblio.biblionumber' ) {
                if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
                    return ( '001', '@' );
                } else {
                    return ( '999', 'c' );
                }
            } else {
                my $func_ref = $biblio->original('GetMarcFromKohaField');
                &$func_ref($kohafield);
            }
        }
    );

    # MARC21 tests
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    # Create a dummy record
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( MARC::Record->new(), '' );

    # Add some items with different onloan values
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => '2017-01-01'
        }
    );
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => undef
        }
    );
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => '2017-01-02'
        }
    );

    my $processor = Koha::RecordProcessor->new( { filters => ('EmbedItemsAvailability') } );
    is( ref($processor), 'Koha::RecordProcessor', 'Created record processor' );

    my $biblio_object = Koha::Biblios->find($biblionumber);
    my $record        = $biblio_object->metadata->record;
    ok( !defined $record->field('999')->subfield('x'), q{The record doesn't originally contain 999$x} );

    # Apply filter
    $processor->process($record);
    is( $record->field('999')->subfield('x'), 1, 'There is only one item with undef onloan' );

    $schema->storage->txn_rollback();

    # UNIMARC tests (999 is not created)
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    $schema->storage->txn_begin();

    # Create a dummy record
    ( $biblionumber, $biblioitemnumber ) = AddBiblio( MARC::Record->new(), '' );

    # Add some items with different onloan values
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => '2017-01-01'
        }
    );
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => undef
        }
    );
    $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            onloan       => '2017-01-02'
        }
    );

    $processor = Koha::RecordProcessor->new( { filters => ('EmbedItemsAvailability') } );
    is( ref($processor), 'Koha::RecordProcessor', 'Created record processor' );

    $biblio_object = Koha::Biblios->find($biblionumber);
    $record        = $biblio_object->metadata->record;
    ok( !defined $record->subfield( '999', 'x' ), q{The record doesn't originally contain 999$x} );

    # Apply filter
    $processor->process($record);
    is( $record->subfield( '999', 'x' ), 1, 'There is only one item with undef onloan' );

    $schema->storage->txn_rollback();
};

