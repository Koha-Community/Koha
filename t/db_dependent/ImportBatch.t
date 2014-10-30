#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::More tests => 5;

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
