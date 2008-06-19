#!/usr/bin/perl

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Biblio;
use C4::Items;
use Getopt::Long;

$| = 1;

# command-line parameters
my $want_help = 0;
my $do_update = 0;

my $result = GetOptions(
    'run-update'    => \$do_update,
    'h|help'        => \$want_help,
);

if (not $result or $want_help or not $do_update) {
    print_usage();
    exit 0;
}

my $num_bibs_processed = 0;
my $num_bibs_modified = 0;
my $num_marc_items_deleted = 0;
my $num_marc_items_added = 0;
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

        if (($num_bibs_processed % 100) == 0) {
            print_progress_and_commit($num_bibs_processed);
        }
    }

    $dbh->commit;

    print <<_SUMMARY_;

Embedded item synchronization report
------------------------------------
Number of bibs checked:                   $num_bibs_processed
Number of bibs modified:                  $num_bibs_modified
Number of item fields removed from bibs:  $num_marc_items_deleted
Number of item fields added to bibs:      $num_marc_items_added
Number of bibs with errors:               $num_bad_bibs
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

    my $bib_modified = 0;

    # delete any item tags
    my ($itemtag, $itemsubfield) = GetMarcFromKohaField("items.itemnumber", '');
    foreach my $field ($bib->field($itemtag)) {
        $bib->delete_field($field);
        $num_marc_items_deleted++;
        $bib_modified = 1;
    }

    # add back items from items table
    my $item_sth = $dbh->prepare("SELECT itemnumber FROM items WHERE biblionumber = ?");
    $item_sth->execute($biblionumber);
    while (my $itemnumber = $item_sth->fetchrow_array) {
        my $marc_item = C4::Items::GetMarcItem($biblionumber, $itemnumber);
        foreach my $item_field ($marc_item->field($itemtag)) {
            $bib->insert_fields_ordered($item_field);
            $num_marc_items_added++;
            $bib_modified = 1;
        }
    }

    if ($bib_modified) {
        ModBiblioMarc($bib, $biblionumber, GetFrameworkCode($biblionumber));
        $num_bibs_modified++;
    }

}

sub print_progress_and_commit {
    my $recs = shift;
    $dbh->commit();
    print "... processed $recs records\n";
}

sub print_usage {
    print <<_USAGE_;
$0: synchronize item data embedded in MARC bibs

Replaces the item data embedded in the MARC bib 
records (for indexing) with the authoritative 
item data as stored in the items table.

If Zebra is used, run rebuild_zebra.pl -b -r after
running this script.

NOTE: this script should be run only if there is
reason to suspect that the embedded item tags are
not in sync with the items table.

Parameters:
    --run-update            run the synchronization
    --help or -h            show this message.
_USAGE_
}
