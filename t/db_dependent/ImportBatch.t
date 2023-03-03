#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 20;
use utf8;
use File::Basename;
use File::Temp qw/tempfile/;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Import::Records;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('C4::ImportBatch', qw( AddImportBatch GetImportBatch AddBiblioToBatch AddItemsToImportBiblio SetMatchedBiblionumber GetImportBiblios GetItemNumbersFromImportBatch CleanBatch DeleteBatch RecordsFromMarcPlugin BatchCommitRecords ));
}

# Start transaction
my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

# clear
$dbh->do('DELETE FROM import_batches');

my $sample_import_batch1 = {
    matcher_id => 1,
    template_id => 1,
    branchcode => 'QRT',
    overlay_action => 'create_new',
    nomatch_action => 'create_new',
    item_action => 'always_add',
    import_status => 'staged',
    batch_type => 'z3950',
    file_name => 'test.mrc',
    comments => 'test',
    record_type => 'auth',
};

my $sample_import_batch2 = {
    matcher_id => 2,
    template_id => 2,
    branchcode => 'QRZ',
    overlay_action => 'create_new',
    nomatch_action => 'create_new',
    item_action => 'always_add',
    import_status => 'staged',
    batch_type => 'z3950',
    file_name => 'test.mrc',
    comments => 'test',
    record_type => 'auth',
};

my $id_import_batch1 = C4::ImportBatch::AddImportBatch($sample_import_batch1);
my $id_import_batch2 = C4::ImportBatch::AddImportBatch($sample_import_batch2);

like( $id_import_batch1, '/^\d+$/', "AddImportBatch for sample_import_batch1 return an id" );
like( $id_import_batch2, '/^\d+$/', "AddImportBatch for sample_import_batch2 return an id" );

#Test GetImportBatch
my $importbatch2 = C4::ImportBatch::GetImportBatch( $id_import_batch2 );
delete $importbatch2->{upload_timestamp};
delete $importbatch2->{import_batch_id};
delete $importbatch2->{num_records};
delete $importbatch2->{num_items};
delete $importbatch2->{profile_id};
delete $importbatch2->{profile};

is_deeply( $importbatch2, $sample_import_batch2,
    "GetImportBatch returns the right informations about $sample_import_batch2" );

my $importbatch1 = C4::ImportBatch::GetImportBatch( $id_import_batch1 );
delete $importbatch1->{upload_timestamp};
delete $importbatch1->{import_batch_id};
delete $importbatch1->{num_records};
delete $importbatch1->{num_items};
delete $importbatch1->{profile_id};
delete $importbatch1->{profile};

is_deeply( $importbatch1, $sample_import_batch1,
    "GetImportBatch returns the right informations about $sample_import_batch1" );

my $record = MARC::Record->new;
my $original_record = MARC::Record->new;
$record->leader('03174nam a2200445 a 4500');
$original_record->leader('03174nam a2200445 a 4500');
my ($item_tag, $item_subfield) = C4::Biblio::GetMarcFromKohaField( 'items.itemnumber' );
my @fields;
if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
    @fields = (
        MARC::Field->new(
            100, ' ', ' ',
            a => '20220520d        u||y0frey50      ba',
        ),
        MARC::Field->new(
            700, ' ', ' ',
            a => 'Knuth, Donald Ervin',
            f => '1938',
        ),
        MARC::Field->new(
            200, ' ', ' ',
            a => 'The art of computer programming',
            f => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            $item_tag, ' ', ' ',
            e => 'my edition ❤',
            i => 'my item part',
        ),
        MARC::Field->new(
            $item_tag, ' ', ' ',
            e => 'my edition 2',
            i => 'my item part 2',
        ),
    );
} else {
    @fields = (
        MARC::Field->new(
            100, '1', ' ',
            a => 'Knuth, Donald Ervin',
            d => '1938',
        ),
        MARC::Field->new(
            245, '1', '4',
            a => 'The art of computer programming',
            c => 'Donald E. Knuth.',
        ),
        MARC::Field->new(
            650, ' ', '0',
            a => 'Computer programming.',
            9 => '462',
        ),
        MARC::Field->new(
            $item_tag, ' ', ' ',
            e => 'my edition ❤',
            i => 'my item part',
        ),
        MARC::Field->new(
            $item_tag, ' ', ' ',
            e => 'my edition 2',
            i => 'my item part 2',
        ),
    );
}
$record->append_fields(@fields);
$original_record->append_fields(@fields);
my $import_record_id = AddBiblioToBatch( $id_import_batch1, 0, $record, 'utf8', 0 );
AddItemsToImportBiblio( $id_import_batch1, $import_record_id, $record, 0 );

my $import_record = Koha::Import::Records->find($import_record_id);
my $record_from_import_biblio = $import_record->get_marc_record();

$original_record->leader($record_from_import_biblio->leader());
is_deeply( $record_from_import_biblio, $original_record, 'Koha::Import::Record::get_marc_record should return the record in original state' );
my $utf8_field = $record_from_import_biblio->subfield($item_tag, 'e');
is($utf8_field, 'my edition ❤');

my $another_biblio = $builder->build_sample_biblio;
C4::ImportBatch::SetMatchedBiblionumber( $import_record_id, $another_biblio->biblionumber );
my $import_biblios = GetImportBiblios( $import_record_id );
is( $import_biblios->[0]->{matched_biblionumber}, $another_biblio->biblionumber, 'SetMatchedBiblionumber  should set the correct biblionumber' );

# Add a few tests for GetItemNumbersFromImportBatch
my @a = GetItemNumbersFromImportBatch( $id_import_batch1 );
is( @a, 0, 'No item numbers expected since we did not commit' );
my $itemno = $builder->build_sample_item->itemnumber;
# Link this item to the import item to fool GetItemNumbersFromImportBatch
my $sql = "UPDATE import_items SET itemnumber=? WHERE import_record_id=?";
$dbh->do( $sql, undef, $itemno, $import_record_id );
@a = GetItemNumbersFromImportBatch( $id_import_batch1 );
is( @a, 2, 'Expecting two items now' );
is( $a[0], $itemno, 'Check the first returned itemnumber' );
# Now delete the item and check again
$dbh->do( "DELETE FROM items WHERE itemnumber=?", undef, $itemno );
@a = GetItemNumbersFromImportBatch( $id_import_batch1 );
is( @a, 0, 'No item numbers expected since we deleted the item' );
$dbh->do( $sql, undef, undef, $import_record_id ); # remove link again

# fresh data
my $sample_import_batch3 = {
    matcher_id => 3,
    template_id => 3,
    branchcode => 'QRT',
    overlay_action => 'create_new',
    nomatch_action => 'create_new',
    item_action => 'always_add',
    import_status => 'staged',
    batch_type => 'z3950',
    file_name => 'test.mrc',
    comments => 'test',
    record_type => 'auth',
};

my $id_import_batch3 = C4::ImportBatch::AddImportBatch($sample_import_batch3);

# Test CleanBatch
C4::ImportBatch::CleanBatch( $id_import_batch3 );
$import_record = get_import_record( $id_import_batch3 );
is( $import_record, "0E0", "Batch 3 has been cleaned" );

# Test DeleteBatch
C4::ImportBatch::DeleteBatch( $id_import_batch3 );
my $import_batch = C4::ImportBatch::GetImportBatch( $id_import_batch3 );
is( $import_batch, undef, "Batch 3 has been deleted");

subtest "_batchCommitItems" => sub {
    plan tests => 3;

    my $exist_item = $builder->build_sample_item;
    my $import_item = $builder->build_object({ class => 'Koha::Import::Record::Items', value => {
        marcxml => q{<?xml version="1.0" encoding="UTF-8"?>
<collection
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">

<record>
  <leader>00000    a              </leader>
  <datafield tag="952" ind1=" " ind2=" ">
    <subfield code="a">CPL</subfield>
    <subfield code="b">CPL</subfield>
    <subfield code="c">GEN</subfield>
    <subfield code="p">}.$exist_item->barcode.q{</subfield>
    <subfield code="y">BK</subfield>
  </datafield>
</record>
</collection>
        },
    }});

    my ( $num_items_added, $num_items_replaced, $num_items_errored ) =
        C4::ImportBatch::_batchCommitItems( $import_item->import_record_id, 32, 'always_add',64 );
    is( $num_items_errored, 1, "Item with duplicate barcode fails when action always_add" );
    $import_item->discard_changes();
    is( $import_item->status, 'error', "Import item marked as error when duplicate barcode and action always_add");
    is( $import_item->import_error, 'duplicate item barcode', 'Error correctly set when import item has duplicate barcode and action always_add' );
};

subtest "RecordsFromMarcPlugin" => sub {
    plan tests => 5;

    # Create a test file
    my ( $fh, $name ) = tempfile();
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        print $fh q{
003 = NLAmRIJ
100,a = 20220520d        u||y0frey50      ba
700,a = Author
200,ind2 = 0
200,a = Silence in the library
500 , a= Some note

700,a = Another
245,a = Noise in the library};
        close $fh;
    } else {
        print $fh q|
003 = NLAmRIJ
100,a = Author
245,ind2 = 0
245,a = Silence in the library
500 , a= Some note

100,a = Another
245,a = Noise in the library|;
        close $fh;
    }

    t::lib::Mocks::mock_config( 'enable_plugins', 1 );

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;
    my ($plugin) = $plugins->GetPlugins({ all => 1, metadata => { name => 'MarcFieldValues' } });
    isnt( $plugin, undef, "Plugin found" );
    my $records = C4::ImportBatch::RecordsFromMarcPlugin( $name, ref $plugin, 'UTF-8' );
    is( @$records, 2, 'Two results returned' );
    is( ref $records->[0], 'MARC::Record', 'Returned MARC::Record object' );
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        is( $records->[0]->subfield('200', 'a'), 'Silence in the library',
            'Checked one field in first record' );
        is( $records->[1]->subfield('700', 'a'), 'Another',
            'Checked one field in second record' );
    } else {
        is( $records->[0]->subfield('245', 'a'), 'Silence in the library',
            'Checked one field in first record' );
        is( $records->[1]->subfield('100', 'a'), 'Another',
            'Checked one field in second record' );
    }
};

subtest "_get_commit_action" => sub {
    plan tests => 24;
    my $mock_import = Test::MockModule->new("C4::ImportBatch");

    $mock_import->mock( GetBestRecordMatch => sub { return 5; } );
    foreach my $record_type ( ('biblio','authority') ){
        foreach my $match_action ( ('replace','create_new','ignore') ){
            foreach my $no_match_action ( ('create_new','ignore') ){
                my ($result, $match, $item_result) =
                    C4::ImportBatch::_get_commit_action($match_action, $no_match_action, 'always_add', 'auto_match', 42, $record_type);
                is( $result, $match_action, "When match found amd chosen we return the match_action for $record_type records with match action $match_action and no match action $no_match_action");
            }
        }
    }

    $mock_import->mock( GetBestRecordMatch => sub { my $matches = undef; return $matches; } );
    foreach my $record_type ( ('biblio','authority') ){
        foreach my $match_action ( ('replace','create_new','ignore') ){
            foreach my $no_match_action ( ('create_new','ignore') ){
                my ($result, $match, $item_result) =
                    C4::ImportBatch::_get_commit_action($match_action, $no_match_action, 'always_add', 'auto_match', 42, $record_type);
                is( $result, $no_match_action, "When no match found or chosen we return the match_action for $record_type records with match action $match_action and no match action $no_match_action");
            }
        }
    }

};

subtest "BatchCommitRecords overlay into framework" => sub {
    plan tests => 1;
    t::lib::Mocks::mock_config( 'enable_plugins', 0 );
    my $mock_import = Test::MockModule->new("C4::ImportBatch");
    my $biblio = $builder->build_sample_biblio;
    $mock_import->mock( _get_commit_action => sub { return ('replace','ignore',$biblio->biblionumber); } );

    my $import_batch = {
        matcher_id => 2,
        template_id => 2,
        branchcode => 'QRZ',
        overlay_action => 'replace',
        nomatch_action => 'ignore',
        item_action => 'ignore',
        import_status => 'staged',
        batch_type => 'z3950',
        file_name => 'test.mrc',
        comments => 'test',
        record_type => 'auth',
    };
    my $id_import_batch = C4::ImportBatch::AddImportBatch($import_batch);
    my $import_record_id = AddBiblioToBatch( $id_import_batch, 0, $biblio->metadata->record, 'utf8', 0 );

    BatchCommitRecords({
        batch_id  => $id_import_batch,
        framework => "",
        overlay_framework => "QQ",
    });
    $biblio->discard_changes;
    is( $biblio->frameworkcode, "QQ", "Framework set on overlay" );
};

subtest "Do not adjust biblionumber when replacing items during import" => sub {
    plan tests => 7;

    my $item1 = $builder->build_sample_item;
    my $original_biblionumber = $item1->biblionumber;
    my $original_biblioitemnumber = $item1->biblioitemnumber;
    my $item2 = $builder->build_sample_item;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    my $import_item = $builder->build_object({ class => 'Koha::Import::Record::Items', value => {
        marcxml => qq{<?xml version="1.0" encoding="UTF-8"?>
<collection
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">

<record>
  <leader>00000    a              </leader>
  <datafield tag="952" ind1=" " ind2=" ">
    <subfield code="a">${\($library->branchcode)}</subfield>
    <subfield code="b">${\($library->branchcode)}</subfield>
    <subfield code="c">GEN</subfield>
    <subfield code="p">${\($item1->barcode)}</subfield>
    <subfield code="y">BK</subfield>
  </datafield>
</record>
</collection>
        },
    }});

    isnt( $item1->homebranch, $library->branchcode, "Item's homebranch is currently not the same as our created branch's branchcode" );

    my ( $num_items_added, $num_items_replaced, $num_items_errored ) =
        C4::ImportBatch::_batchCommitItems( $import_item->import_record_id, $item2->biblionumber, 'replace' );

    $item1->discard_changes();

    is( $num_items_errored, 0, 'Item was replaced' );
    $import_item->discard_changes();
    is( $import_item->status, 'imported', 'Import was successful');
    is( $import_item->import_error, undef, 'No error was reported' );

    is( $item1->biblionumber, $original_biblionumber, "Item's biblionumber has not changed" );
    is( $item1->biblionumber, $original_biblioitemnumber, "Item's biblioitemnumber has not changed" );
    is( $item1->homebranch, $library->branchcode, "Item was overlaid successfully" );
};

sub get_import_record {
    my $id_import_batch = shift;
    return $dbh->do('SELECT * FROM import_records WHERE import_batch_id = ?', undef, $id_import_batch);
}

$schema->storage->txn_rollback;
