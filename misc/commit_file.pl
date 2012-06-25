#!/usr/bin/perl

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use C4::Context;
use C4::ImportBatch;
use Getopt::Long;

$| = 1;

# command-line parameters
my $batch_number = "";
my $list_batches = 0;
my $revert = 0;
my $want_help = 0;

my $result = GetOptions(
    'batch-number:s' => \$batch_number,
    'list-batches'   => \$list_batches,
    'revert'         => \$revert,
    'h|help'         => \$want_help
);

if ($want_help or (not $batch_number and not $list_batches)) {
    print_usage();
    exit 0;
}

if ($list_batches) {
    list_batches();
    exit 0;
}

# FIXME dummy user so that logging won't fail
# in future, probably should tie to a real user account
C4::Context->set_userenv(0, 'batch', 0, 'batch', 'batch', 'batch', 'batch', 'batch');

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
if ($batch_number =~ /^\d+$/ and $batch_number > 0) {
    my $batch = GetImportBatch($batch_number);
    die "$0: import batch $batch_number does not exist in database\n" unless defined $batch;
    if ($revert) {
        die "$0: import batch $batch_number status is '" . $batch->{'import_status'} . "', and therefore cannot be imported\n"
            unless $batch->{'import_status'} eq "imported";
        revert_batch($batch_number);
    } else {
        die "$0: import batch $batch_number status is '" . $batch->{'import_status'} . "', and therefore cannot be imported\n"
            unless $batch->{'import_status'} eq "staged" or $batch->{'import_status'} eq "reverted";
        process_batch($batch_number);
    }
    $dbh->commit();
} else {
    die "$0: please specify a numeric batch ID\n";
}

exit 0;

sub list_batches {
    my $results = GetAllImportBatches();
    print sprintf("%5.5s %-25.25s %-25.25s %-10.10s\n", "#", "File name", "Batch comments", "Status");
    print '-' x 5, ' ' , '-' x 25, ' ', '-' x 25, ' ', '-' x 10, "\n" ;
    foreach my $batch (@{ $results}) {
        if ($batch->{'import_status'} eq "staged" or $batch->{'import_status'} eq "reverted") {
            print sprintf("%5.5s %-25.25s %-25.25s %-10.10s\n",
                          $batch->{'import_batch_id'},
                          $batch->{'file_name'},
                          $batch->{'comments'},
                          $batch->{'import_status'});
        }
    }
}

sub process_batch {
    my ($import_batch_id) = @_;

    print "... importing MARC records -- please wait\n";
    my ($num_added, $num_updated, $num_items_added, $num_items_errored, $num_ignored) =
        BatchCommitRecords($import_batch_id, '', 100, \&print_progress_and_commit);
    print "... finished importing MARC records\n";

    print <<_SUMMARY_;

MARC record import report
----------------------------------------
Batch number:                    $import_batch_id
Number of new records added:     $num_added
Number of records replaced:      $num_updated
Number of records ignored:       $num_ignored
Number of items added:           $num_items_added
Number of items ignored:         $num_items_errored

Note: an item is ignored if its barcode is a
duplicate of one already in the database.
_SUMMARY_
}

sub revert_batch {
    my ($import_batch_id) = @_;

    print "... reverting batch -- please wait\n";
    my ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored) =
        BatchRevertRecords($import_batch_id, 100, \&print_progress_and_commit);
    print "... finished reverting batch\n";

    print <<_SUMMARY_;

MARC record import report
----------------------------------------
Batch number:                    $import_batch_id
Number of records deleted:       $num_deleted
Number of errors:                $num_errors
Number of records reverted:      $num_reverted
Number of records ignored:       $num_ignored
Number of items added:           $num_items_deleted

_SUMMARY_
}


sub print_progress_and_commit {
    my $recs = shift;
    print "... processed $recs records\n";
    $dbh->commit();
}

sub print_usage {
    print <<_USAGE_;
$0: import a batch of staged MARC records into database.

Use this batch job to complete the import of a batch of
MARC records that was staged either by the batch job
stage_file.pl or by the Koha Tools option
"Stage MARC Records for Import".

Parameters:
    --batch-number <#>   number of the record batch
                         to import
    --list-batches       print a list of record batches
                         available to commit
    --revert             revert a batch instead of importing it
    --help or -h         show this message.
_USAGE_
}
