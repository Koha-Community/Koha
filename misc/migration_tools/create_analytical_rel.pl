#!/usr/bin/perl

use strict;
#use warnings; FIXME - Bug 2505
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
my $wherestrings;

my $result = GetOptions(
    'run-update'    => \$do_update,
    'where=s@'         => \$wherestrings,
    'h|help'        => \$want_help,
);

if (not $result or $want_help or not $do_update) {
    print_usage();
    exit 0;
}

my $num_bibs_processed     = 0;
my $num_bibs_modified      = 0;
my $num_nobib_foritemnumber = 0;
my $num_noitem_forbarcode = 0;
my $num_nobarcode_inhostfield =0;
my $num_hostfields_unabletomodify =0;
my $num_bad_bibs           = 0;
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;

process_bibs();
$dbh->commit();

exit 0;

sub process_bibs {
    my $sql = "SELECT biblionumber FROM biblio JOIN biblioitems USING (biblionumber)";
    $sql.="WHERE ". join(" AND ",@$wherestrings) if ($wherestrings);
    $sql.="ORDER BY biblionumber ASC";
    my $sth = $dbh->prepare($sql);
    eval{$sth->execute();};
    if ($@){ die "error $@";};
    while (my ($biblionumber) = $sth->fetchrow_array()) {
        $num_bibs_processed++;
        process_bib($biblionumber);

        if (($num_bibs_processed % 100) == 0) {
            print_progress_and_commit($num_bibs_processed);
        }
    }

    $dbh->commit;

    print <<_SUMMARY_;

Create Analytical records relationships report
-----------------------------------------------
Number of bibs checked:                   $num_bibs_processed
Number of bibs modified:                  $num_bibs_modified
Number of hostfields with no barcodes:		$num_nobarcode_inhostfield
Number of barcodes not found:                   $num_noitem_forbarcode
Number of hostfields unable to modify:		$num_hostfields_unabletomodify
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
	#loop through each host field and populate subfield 0 and 9
    my $analyticfield = '773';
	foreach my $hostfield ( $bib->field($analyticfield) ) {
		if(my $barcode = $hostfield->subfield('o')){
			my $itemnumber = GetItemnumberFromBarcode($barcode);
			if ($itemnumber ne undef){
				my $bibnumber = GetBiblionumberFromItemnumber($itemnumber);
				if ($bibnumber ne undef){
					my $modif;
					if ($hostfield->subfield('0') ne $bibnumber){
						$hostfield->update('0', $bibnumber);
						$modif = 1;
					}
					if ($hostfield->subfield('9') ne $itemnumber){
						$hostfield->update('9', $itemnumber);
						$modif=1;
					}
					if ($modif){
						$num_bibs_modified++;
						my $modresult = ModBiblio($bib, $biblionumber, '');
						warn "Modifying biblio $biblionumber";
						if (!$modresult){
							warn "Unable to modify biblio $biblionumber with update host field";
							$num_hostfields_unabletomodify++;
						}
					}
				} else {
					warn "No biblio record found corressponding to itemnumber $itemnumber";
					$num_nobib_foritemnumber++;
				}
			} else {
				warn "No item record found for barcode $barcode";
				$num_noitem_forbarcode++;
			}
		} else{
			warn "No barcode in host field for biblionumber $biblionumber";
			$num_nobarcode_inhostfield++;
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
$0: establish relationship to host items

Based on barcode in host field populates subfield 0 with host biblionumber and subfield 9 with host itemnumber.

Subfield 0 and 9 are used in Koha screns to display relationships between analytical records and host bibs and items.

NOT usable with UNIMARC data. You can use it only if you have tag 461 with also an items id (like barcode or item numbers). In UNIMARC this situation is very rare. If you have data coded in this way, send a mail to koha-dev mailing list and ask for the feature.

Parameters:
    --run-update            run the synchronization
    --where condition       selects the biblios on a criterium (Repeatable)
    --help or -h            show this message.
_USAGE_
}
