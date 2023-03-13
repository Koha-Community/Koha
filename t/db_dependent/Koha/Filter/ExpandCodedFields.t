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

use t::lib::TestBuilder;

use C4::Biblio qw( GetMarcSubfieldStructure );

use Koha::Database;

use Koha::AuthorisedValueCategory;
use Koha::Caches;

use Koha::RecordProcessor;

my $schema  = Koha::Database->schema();
my $builder = t::lib::TestBuilder->new();

subtest 'ExpandCodedFields tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin();

    # Add libraries
    my $homebranch    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $holdingbranch = $builder->build_object( { class => 'Koha::Libraries' } );

    diag("Homebranch: " . $homebranch->branchcode . " : " . $homebranch->branchname);
    # Add itemtypes
    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes' } );

    # Add a biblio
    my $biblio = $builder->build_sample_biblio;
    my $record = $biblio->metadata->record;

    # Suppress the record to test that suppression is never expanded
    $record->field('942')->update( n => 1 );

    # Add an AV ended field to test for AV expansion
    $record->append_fields(
        MARC::Field->new( '590', '', '', a => 'CODE' ),
    );

    Koha::AuthorisedValueCategory->new({ category_name => 'TEST' })->store;
    Koha::AuthorisedValue->new(
        {
            category         => 'TEST',
            authorised_value => 'CODE',
            lib              => 'Description should show',
            lib_opac         => 'Description should show OPAC'
        }
    )->store;
    my $mss = Koha::MarcSubfieldStructures->find({tagfield => "590", tagsubfield => "a", frameworkcode => $biblio->frameworkcode });
    $mss->update({ authorised_value => "TEST" });

    my $cache = Koha::Caches->get_instance;
    $cache->clear_from_cache("MarcCodedFields-");
    # Clear GetAuthorisedValueDesc-generated cache
    $cache->clear_from_cache("libraries:name");
    $cache->clear_from_cache("itemtype:description:en");
    $cache->clear_from_cache("cn_sources:description");
    $cache->clear_from_cache("AV_descriptions:LOST");

    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber);
    $record = $biblio->metadata->record;

    # Embed an item to test for branchcode and itemtype expansions
    $record->append_fields(
        MARC::Field->new(
            '952', '', '',
            a => $homebranch->branchcode,
            b => $holdingbranch->branchcode,
            y => $itemtype->itemtype
        ),
    );


    is( $record->field('590')->subfield('a'), 'CODE', 'Record prior to filtering contains AV Code' );
    is( $record->field('942')->subfield('n'), 1, 'Record suppression is numeric prior to filtering' );
    is( $record->field('952')->subfield('a'), $homebranch->branchcode, 'Record prior to filtering contains homebranch branchcode' );
    is( $record->field('952')->subfield('b'), $holdingbranch->branchcode, 'Record prior to filtering contains holdingbranch branchcode' );
    is( $record->field('952')->subfield('y'), $itemtype->itemtype, 'Record prior to filtering contains itemtype code' );

    my $processor = Koha::RecordProcessor->new(
        {
            schema  => 'MARC',
            filters => ['ExpandCodedFields'],
        }
    );
    is( ref($processor), 'Koha::RecordProcessor', 'Created record processor with ExpandCodedFields filter' );

    my $result = $processor->process( $record );
    is( ref($result), 'MARC::Record', 'It returns a reference to a MARC::Record object' );
    is( $result->field('590')->subfield('a'), 'Description should show OPAC', 'Returned record contains AV OPAC description (interface defaults to opac)' );
    is( $record->field('590')->subfield('a'), 'Description should show OPAC', 'Original record now contains AV OPAC description (interface defaults to opac)' );
    is( $record->field('942')->subfield('n'), 1, 'Record suppression is still numeric after filtering' );
    is( $record->field('952')->subfield('a'), $homebranch->branchname, 'Record now contains homebranch branchname' );
    is( $record->field('952')->subfield('b'), $holdingbranch->branchname, 'Record now contains holdingbranch branchname' );
    is( $record->field('952')->subfield('y'), $itemtype->description, 'Record now contains itemtype description' );

    # reset record for next test
    $record = $biblio->metadata->record;
    is( $record->field('590')->subfield('a'), 'CODE', 'Record reset contains AV Code' );

    # set interface
    $processor->options({ interface => 'intranet' });
    $result = $processor->process( $record );
    is( $record->field('590')->subfield('a'), 'Description should show', 'Original record now contains AV description (interface set to intranet)' );
    is( $record->field('942')->subfield('n'), 1, 'Item suppression field remains numeric after filtering' );

    $schema->storage->txn_rollback();
};
