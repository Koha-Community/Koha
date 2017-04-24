#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;

use C4::ImportBatch;
use C4::Matcher;


my ($matcherid, $help);
my $result = GetOptions(
    'matcherid'   => \$matcherid,
    'help|h'      => \$help,
);


sub usage {
    print <<HELP;

    --matcherid  The id of the matcher to use to match ALL imported records.
    --help       This scrawny help.

HELP
    exit;
}

unless ($matcherid) {
    die "--matcherid not defined. You must use a matcher to match imported records against Biblios in the Catalog.";
}

my $batches = GetAllImportBatches();
foreach my $b (@$batches) {
    BatchFindDuplicates($b->{import_batch_id}, C4::Matcher->fetch($matcherid), 1000, 1000, undef);
}