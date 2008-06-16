#!/usr/bin/perl

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use C4::Context;
use C4::Biblio;
use Getopt::Long;

$| = 1;

# command-line parameters
my $verbose   = 0;
my $test_only = 0;
my $want_help = 0;

my $result = GetOptions(
    'verbose'       => \$verbose,
    'test'          => \$test_only,
    'h|help'        => \$want_help
);

if (not $result or $want_help) {
    print_usage();
    exit 0;
}

my $num_bibs_processed = 0;
my $num_bibs_modified = 0;
my $num_bad_bibs = 0;
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
process_bibs();
$dbh->commit();

exit 0;

sub process_bibs {
    my $sql = "SELECT biblionumber FROM biblio ORDER BY biblionumber ASC";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my ($biblionumber) = $sth->fetchrow_array()) {
        $num_bibs_processed++;
        process_bib($biblionumber);

        if (not $test_only and ($num_bibs_processed % 100) == 0) {
            print_progress_and_commit($num_bibs_processed);
        }
    }

    if (not $test_only) {
        $dbh->commit;
    }

    print <<_SUMMARY_;

Bib authority heading linking report
------------------------------------
Number of bibs checked:       $num_bibs_processed
Number of bibs modified:      $num_bibs_modified
Number of bibs with errors:   $num_bad_bibs
_SUMMARY_
}

sub process_bib {
    my $biblionumber = shift;

    my $bib = GetMarcBiblio($biblionumber);
    unless (defined $bib) {
        print "\nCould not retrieve bib $biblionumber from the database - record is corrupt.\n";
        $num_bad_bibs++;
        return;
    }

    my $headings_changed = LinkBibHeadingsToAuthorities($bib);

    if ($headings_changed) {   
        if ($verbose) {
            my $title = substr($bib->title, 0, 20);
            print "Bib $biblionumber ($title): $headings_changed headings changed\n";
        }
        if (not $test_only) {
            ModBiblio($bib, $biblionumber, GetFrameworkCode($biblionumber));
            $num_bibs_modified++;
        }
    }
}

sub print_progress_and_commit {
    my $recs = shift;
    $dbh->commit();
    print "... processed $recs records\n";
}

sub print_usage {
    print <<_USAGE_;
$0: link headings in bib records to authorities.

This batch job checks each bib record in the Koha
database and attempts to link each of its headings
to the matching authority record.

Parameters:
    --verbose               print the number of headings changed
                            for each bib
    --test                  only test the authority linking
                            and report the results; do not
                            change the bib records.
    --comment <comment>     optional comment to describe
                            the record batch; if the comment
                            has spaces in it, surround the
                            comment with quotation marks.
    --help or -h            show this message.
_USAGE_
}
