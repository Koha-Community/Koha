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

use Test::More tests => 4;
use t::lib::TestBuilder;

use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Batch;
use File::Slurp;
use Encode;

use C4::Biblio;
use C4::Context;
use Koha::Database;
use Koha::Exporter::Record;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

my $biblio_1_title = 'Silence in the library';
my $biblio_2_title = 'The art of computer programming ກ ຂ ຄ ງ ຈ ຊ ຍ é';
my $biblio_1 = MARC::Record->new();
$biblio_1->leader('00266nam a22001097a 4500');
$biblio_1->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
    MARC::Field->new('245', ' ', ' ', a => $biblio_1_title),
);
my ($biblionumber_1, $biblioitemnumber_1) = AddBiblio($biblio_1, '');
my $biblio_2 = MARC::Record->new();
$biblio_2->leader('00266nam a22001097a 4500');
$biblio_2->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Knuth, Donald Ervin'),
    MARC::Field->new('245', ' ', ' ', a => $biblio_2_title),
);
my ($biblionumber_2, $biblioitemnumber_2) = AddBiblio($biblio_2, '');

my $builder = t::lib::TestBuilder->new;
my $item_1_1 = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblionumber_1,
        more_subfields_xml => '',
    }
});
my $item_1_2 = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblionumber_1,
        more_subfields_xml => '',
    }
});
my $item_2_1 = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblionumber_2,
        more_subfields_xml => '',
    }
});

subtest 'export csv' => sub {
    plan tests => 2;
    my $csv_content = q{Title=245$a|Barcode=952$p};
    $dbh->do(q|INSERT INTO export_format(profile, description, content, csv_separator, field_separator, subfield_separator, encoding, type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)|, {}, "TEST_PROFILE_Records.t", "my useless desc", $csv_content, '|', ';', ',', 'utf8', 'marc');
    my $csv_profile_id = $dbh->last_insert_id( undef, undef, 'export_format', undef );
    my $generated_csv_file = '/tmp/test_export_1.csv';

    # Get all item infos
    Koha::Exporter::Record::export(
        {
            record_type => 'bibs',
            record_ids => [ $biblionumber_1, $biblionumber_2 ],
            format => 'csv',
            csv_profile_id => $csv_profile_id,
            output_filepath => $generated_csv_file,
        }
    );
    my $expected_csv = <<EOF;
Title|Barcode
"$biblio_1_title"|$item_1_1->{barcode},$item_1_2->{barcode}
"$biblio_2_title"|$item_2_1->{barcode}
EOF
    my $generated_csv_content = read_file( $generated_csv_file );
    is( $generated_csv_content, $expected_csv, "Export CSV: All item's infos should have been retrieved" );

    $generated_csv_file = '/tmp/test_export.csv';
    # Get only 1 item info
    Koha::Exporter::Record::export(
        {
            record_type => 'bibs',
            record_ids => [ $biblionumber_1, $biblionumber_2 ],
            itemnumbers => [ $item_1_1->{itemnumber}, $item_2_1->{itemnumber} ],
            format => 'csv',
            csv_profile_id => $csv_profile_id,
            output_filepath => $generated_csv_file,
        }
    );
    $expected_csv = <<EOF;
Title|Barcode
"$biblio_1_title"|$item_1_1->{barcode}
"$biblio_2_title"|$item_2_1->{barcode}
EOF
    $generated_csv_content = read_file( $generated_csv_file );
    is( $generated_csv_content, $expected_csv, "Export CSV: Only 1 item info should have been retrieved" );
};

subtest 'export xml' => sub {
    plan tests => 2;
    my $generated_xml_file = '/tmp/test_export.xml';
    Koha::Exporter::Record::export(
        {
            record_type => 'bibs',
            record_ids => [ $biblionumber_1, $biblionumber_2 ],
            format => 'xml',
            output_filepath => $generated_xml_file,
        }
    );
    my $generated_xml_content = read_file( $generated_xml_file );
    $MARC::File::XML::_load_args{BinaryEncoding} = 'utf-8';
    open my $fh, '<', $generated_xml_file;
    my $records = MARC::Batch->new( 'XML', $fh );
    my @records;
    # The following statement produces
    # Use of uninitialized value in concatenation (.) or string at /usr/share/perl5/MARC/File/XML.pm line 398, <$fh> chunk 5.
    # Why?
    while ( my $record = $records->next ) {
        push @records, $record;
    }
    is( scalar( @records ), 2, 'Export XML: 2 records should have been exported' );
    my $second_record = $records[1];
    my $title = $second_record->subfield(245, 'a');
    $title = Encode::encode('UTF-8', $title);
    is( $title, $biblio_2_title, 'Export XML: The title is correctly encoded' );
};

subtest 'export iso2709' => sub {
    plan tests => 2;
    my $generated_mrc_file = '/tmp/test_export.mrc';
    # Get all item infos
    Koha::Exporter::Record::export(
        {
            record_type => 'bibs',
            record_ids => [ $biblionumber_1, $biblionumber_2 ],
            format => 'iso2709',
            output_filepath => $generated_mrc_file,
        }
    );
    my $records = MARC::File::USMARC->in( $generated_mrc_file );
    my @records;
    while ( my $record = $records->next ) {
        push @records, $record;
    }
    is( scalar( @records ), 2, 'Export ISO2709: 2 records should have been exported' );
    my $second_record = $records[1];
    my $title = $second_record->subfield(245, 'a');
    $title = Encode::encode('UTF-8', $title);
    is( $title, $biblio_2_title, 'Export ISO2709: The title is correctly encoded' );
};

subtest 'export without record_type' => sub {
    plan tests => 1;

    my $rv = Koha::Exporter::Record::export({
            record_ids => [ $biblionumber_1, $biblionumber_2 ],
            format => 'iso2709',
            output_filepath => 'does_not_matter_here',
    });
    is( $rv, undef, 'export returns undef' );
    #Depending on your logger config, you might have a warn in your logs
};

$schema->storage->txn_rollback;

1;
