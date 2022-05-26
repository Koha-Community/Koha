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

    plan tests => 10;

    $schema->storage->txn_begin();

    # Add a biblio
    my $biblio = $builder->build_sample_biblio;
    my $record = $biblio->metadata->record;
    $record->field('942')->update( n => 1 );
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

    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber);
    $record = $biblio->metadata->record;

    is( $record->field('590')->subfield('a'), 'CODE', 'Record prior to filtering contains AV Code' );
    is( $record->field('942')->subfield('n'), 1, 'Record suppression is numeric prior to filtering' );

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
