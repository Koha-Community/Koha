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

use utf8;
use Modern::Perl;

use Test::More tests => 1;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::RecordProcessor;

my $schema  = Koha::Database->schema();
my $builder = t::lib::TestBuilder->new();

subtest 'Index880InZebra tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin();

    # Add a biblio
    my $biblio = $builder->build_sample_biblio({ title => 'Pastoral epistles' });
    my $record = $biblio->metadata->record;

    # Add an 880 alternate
    $record->append_fields(
        MARC::Field->new( '880', '', '', 6 => '245-01', a => '教牧書信' ),
    );

    my @fields_245 = $record->field('245');
    is( @fields_245, 1, 'One title (245) field present before filtering');
    is( $fields_245[0]->subfield('a'), 'Pastoral epistles', 'First 245 contains english title before filtering');

    my @fields_880 = $record->field('880');
    is( @fields_880, 1, 'One alternate graphic represnetation (880) field present before filtering');
    is( $fields_880[0]->subfield('a'), '教牧書信', 'Alternate graphic represnations contains chinese characters prior to filtering' );

    my $processor = Koha::RecordProcessor->new(
        {
            schema  => 'MARC',
            filters => ['Index880InZebra'],
        }
    );
    is( ref($processor), 'Koha::RecordProcessor', 'Created record processor with Index880InZebra filter' );

    my $result = $processor->process( $record );
    is( ref($result), 'MARC::Record', 'It returns a reference to a MARC::Record object' );

    @fields_245 = $result->field('245');
    is( @fields_245, 2, 'Two title (245) fields present after filtering');
    is( $fields_245[0]->subfield('a'), 'Pastoral epistles', 'First 245 contains english title after filtering');
    is( $fields_245[1]->subfield('a'), '教牧書信', 'Second 245 contains chinese title from 880 after filtering' );

    @fields_880 = $result->field('880');
    is( @fields_880, 0, 'No alternate graphic represnetation (880) fields present after filtering');

    $schema->storage->txn_rollback();
};
