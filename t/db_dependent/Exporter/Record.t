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

use Test::More tests => 6;
use Test::Warn;
use t::lib::TestBuilder;

use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Batch;
use File::Slurp;
use Encode;

use C4::Biblio qw( AddBiblio );
use C4::Context;
use Koha::Database;
use Koha::Biblio;
use Koha::Biblioitem;
use Koha::Exporter::Record;
use Koha::Biblio::Metadatas;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

my $biblio_1_title = 'Silence in the library';
my $biblio_2_title = 'The art of computer programming ກ ຂ ຄ ງ ຈ ຊ ຍ é';
my $biblio_1 = $builder->build_sample_biblio(
    {
        title => $biblio_1_title,
        author => 'Moffat, Steven',
    }
);
my $biblionumber_1 = $biblio_1->biblionumber;
my $biblio_2 = $builder->build_sample_biblio(
    {
        title => $biblio_2_title,
        author => 'Knuth, Donald Ervin',
    }
);
my $biblionumber_2 = $biblio_2->biblionumber;

my $marcflavour = C4::Context->preference('marcflavour');
my ($title_field_tag, $item_field_tag, $barcode_subfield_code, $homebranch_subfield_code);
if ($marcflavour eq 'UNIMARC') {
    $title_field_tag = '200';
    $item_field_tag = '995';
    $barcode_subfield_code = 'f';
    $homebranch_subfield_code = 'b';
} else {
    $title_field_tag = '245';
    $item_field_tag = '952';
    $barcode_subfield_code = 'p';
    $homebranch_subfield_code = 'a';
}

my $bad_biblio = Koha::Biblio->new()->store();
Koha::Biblio::Metadata->new( { biblionumber => $bad_biblio->id, format => 'marcxml', metadata => 'something wrong', schema => $marcflavour } )->store();
my $bad_biblionumber = $bad_biblio->id;

my $item_1_1 = $builder->build_sample_item(
    {
        biblionumber => $biblionumber_1,
    }
)->unblessed;
my $item_1_2 = $builder->build_sample_item(
    {
        biblionumber => $biblionumber_1,
    }
)->unblessed;
my $item_2_1 = $builder->build_sample_item(
    {
        biblionumber => $biblionumber_2,
    }
)->unblessed;
my $bad_item = $builder->build({ # Cannot call build_sample_item, we want inconsistent data on purpose
    source => 'Item',
    value => {
        biblionumber => $bad_biblionumber,
    }
});

subtest 'export csv' => sub {
    plan tests => 3;
    my $csv_content = "Title=$title_field_tag\$a|Barcode=$item_field_tag\$$barcode_subfield_code";
    $dbh->do(q|INSERT INTO export_format(profile, description, content, csv_separator, field_separator, subfield_separator, encoding, type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)|, {}, "TEST_PROFILE_Records.t", "my useless desc", $csv_content, '|', ';', ',', 'utf8', 'marc');
    my $csv_profile_id = $dbh->last_insert_id( undef, undef, 'export_format', undef );
    my $generated_csv_file = '/tmp/test_export_1.csv';

    # Get all item infos
    warning_like {
        Koha::Exporter::Record::export(
            {   record_type     => 'bibs',
                record_ids      => [ $biblionumber_1, $bad_biblionumber, $biblionumber_2 ],
                format          => 'csv',
                csv_profile_id  => $csv_profile_id,
                output_filepath => $generated_csv_file,
            }
        );
    }
    qr|.*Start tag expected.*|, "Export csv with wrong marcxml should raise a warning";
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
    plan tests => 3;
    my $generated_xml_file = '/tmp/test_export.xml';
    warning_like {
        Koha::Exporter::Record::export(
            {   record_type     => 'bibs',
                record_ids      => [ $biblionumber_1, $bad_biblionumber, $biblionumber_2 ],
                format          => 'xml',
                output_filepath => $generated_xml_file,
            }
        );
    }
    qr|.*Start tag expected.*|, "Export xml with wrong marcxml should raise a warning";

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
    my $title = $second_record->subfield($title_field_tag, 'a');
    $title = Encode::encode('UTF-8', $title);
    is( $title, $biblio_2_title, 'Export XML: The title is correctly encoded' );
};

subtest 'export iso2709' => sub {
    plan tests => 3;
    my $generated_mrc_file = '/tmp/test_export.mrc';
    # Get all item infos
    warning_like {
        Koha::Exporter::Record::export(
            {   record_type     => 'bibs',
                record_ids      => [ $biblionumber_1, $bad_biblionumber, $biblionumber_2 ],
                format          => 'iso2709',
                output_filepath => $generated_mrc_file,
            }
        );
    }
    qr|.*Start tag expected.*|, "Export iso2709 with wrong marcxml should raise a warning";

    my $records = MARC::File::USMARC->in( $generated_mrc_file );
    my @records;
    while ( my $record = $records->next ) {
        push @records, $record;
    }
    is( scalar( @records ), 2, 'Export ISO2709: 2 records should have been exported' );
    my $second_record = $records[1];
    my $title = $second_record->subfield($title_field_tag, 'a');
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

subtest '_get_biblio_for_export' => sub {
    plan tests => 4;

    my $biblio = $builder->build_sample_biblio(
        {
            title => 'The 13 Clocks',
            author => 'Thurber, James',
        }
    );
    my $biblionumber = $biblio->biblionumber;
    my $branch_a = $builder->build({source => 'Branch',});
    my $branch_b = $builder->build({source => 'Branch',});
    my $item_branch_a = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch_a->{branchcode},
        }
    );
    my $item_branch_b = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch_b->{branchcode},
        }
    );

    my $record = Koha::Exporter::Record::_get_biblio_for_export(
        {
            biblionumber                   => $biblionumber,
            export_items                   => 1,
            only_export_items_for_branches => undef
        }
    );
    my @items = $record->field($item_field_tag);
    is( scalar @items, 2, "We should retrieve all items if we don't pass specific branches and request items" );

    $record = Koha::Exporter::Record::_get_biblio_for_export(
        {
            biblionumber                   => $biblionumber,
            export_items                   => 1,
            only_export_items_for_branches => [ $branch_b->{branchcode} ]
        }
    );
    @items = $record->field($item_field_tag);
    is( scalar @items, 1, "We should retrieve only item for branch_b item if we request items and pass branch" );
    is(
        $items[0]->subfield($homebranch_subfield_code),
        $branch_b->{branchcode},
        "And the homebranch for that item should be branch_b branchcode"
    );

    $record = Koha::Exporter::Record::_get_biblio_for_export(
        {
            biblionumber                   => $biblionumber,
            export_items                   => 0,
            only_export_items_for_branches => [ $branch_b->{branchcode} ]
        }
    );
    @items = $record->field($item_field_tag);
    is( scalar @items, 0, "We should not have any items if we don't request items and pass a branch");

};

subtest '_get_record_for_export MARC field conditions' => sub {
    plan tests => 11;

    my $biblio = $builder->build_sample_biblio(
        {
            title => 'The 13 Clocks',
            author => 'Thurber, James',
        }
    );
    my $record = $biblio->metadata->record;
    $record->append_fields(
        MARC::Field->new( '080', ' ', ' ', a => '12345' ),
        MARC::Field->new( '035', ' ', ' ', a => '(TEST)123' ),
        MARC::Field->new( '035', ' ', ' ', a => '(TEST)1234' ),
    );
    $biblio->metadata->metadata($record->as_xml)->store;
    my $biblionumber = $biblio->biblionumber;

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['080', 'a', '=', '12345']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"080a=12345\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['080', 'a', '!=', '12345']],
            record_type => 'bibs',
        }
    );
    is( $record, undef, "Record condition \"080a!=12345\" should not match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['080', 'a', '>', '1234']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"080a>1234\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['080', 'a', '<', '123456']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"080a<123456\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['080', 'a', '>', '123456']],
            record_type => 'bibs',
        }
    );
    is( $record, undef, "Record condition \"080a>123456\" should not match" );


    ## Multiple subfields

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '!=', 'TEST(12345)']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"035a!=TEST(12345)\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '=', 'TEST(1234)']],
            record_type => 'bibs',
        }
    );
    is( $record, undef, "Record condition \"035a=TEST(1234)\" should not match" ); # Since matching all subfields required


    ## Multiple conditions

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '!=', 'TEST(12345)'], ['080', 'a', '>', '1234']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"035a!=TEST(12345),080a>1234\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '!=', 'TEST(12345)'], ['080', 'a', '<', '1234']],
            record_type => 'bibs',
        }
    );
    is( $record, undef, "Record condition \"035a!=TEST(12345),080a<1234\" should not match" );


    ## exists/not_exists

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '?']],
            record_type => 'bibs',
        }
    );
    ok( $record, "Record condition \"exists(035a)\" should match" );

    $record = Koha::Exporter::Record::_get_record_for_export(
        {
            record_id => $biblionumber,
            record_conditions => [['035', 'a', '!?']],
            record_type => 'bibs',
            record_type => 'bibs',
        }
    );
    is( $record, undef, "Record condition \"not_exists(035a)\" should not match" );
};

$schema->storage->txn_rollback;
