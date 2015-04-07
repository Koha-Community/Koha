#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::More tests => 7;

BEGIN {
        use_ok('C4::ImportBatch');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

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

is_deeply( $importbatch2, $sample_import_batch2,
    "GetImportBatch returns the right informations about $sample_import_batch2" );

my $importbatch1 = C4::ImportBatch::GetImportBatch( $id_import_batch1 );
delete $importbatch1->{upload_timestamp};
delete $importbatch1->{import_batch_id};
delete $importbatch1->{num_records};
delete $importbatch1->{num_items};

is_deeply( $importbatch1, $sample_import_batch1,
    "GetImportBatch returns the right informations about $sample_import_batch1" );

my $record = MARC::Record->new;
# FIXME Create another MARC::Record which won't be modified
# AddItemsToImportBiblio will remove the items field from the record passed in parameter.
my $original_record = MARC::Record->new;
$record->leader('03174nam a2200445 a 4500');
$original_record->leader('03174nam a2200445 a 4500');
my ($item_tag, $item_subfield) = C4::Biblio::GetMarcFromKohaField('items.itemnumber','');
my @fields = (
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
        e => 'my edition',
        i => 'my item part',
    ),
    MARC::Field->new(
        $item_tag, ' ', ' ',
        e => 'my edition 2',
        i => 'my item part 2',
    ),
);
$record->append_fields(@fields);
$original_record->append_fields(@fields);
my $import_record_id = AddBiblioToBatch( $id_import_batch1, 0, $record, 'utf8', int(rand(99999)), 0 );
AddItemsToImportBiblio( $id_import_batch1, $import_record_id, $record, 0 );

my $record_from_import_biblio_with_items = C4::ImportBatch::GetRecordFromImportBiblio( $import_record_id, 'embed_items' );
$original_record->leader($record_from_import_biblio_with_items->leader());
is_deeply( $record_from_import_biblio_with_items, $original_record, 'GetRecordFromImportBiblio should return the record with items if specified' );
$original_record->delete_fields($original_record->field($item_tag)); #Remove items fields
my $record_from_import_biblio_without_items = C4::ImportBatch::GetRecordFromImportBiblio( $import_record_id );
$original_record->leader($record_from_import_biblio_without_items->leader());
is_deeply( $record_from_import_biblio_without_items, $original_record, 'GetRecordFromImportBiblio should return the record without items by default' );
