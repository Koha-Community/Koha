#!/usr/bin/perl
use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
use C4::Biblio;
use MARC::Record;

use Getopt::Long;
my $USAGE = "
USAGE: update_items.pl -[options]

OPTIONS:
 -today				Items with a modified timestamp today
 -biblionumber <integer>	One biblionumber to update
 -itemnumber <integer>		One itemnumber to update

DEVELOPMENT OPTIONS:

EXAMPLES:
\$ ./update_items.pl -today
[ update items modified today ]

\$ ./update_items.pl -biblionumber 2
[ update items for biblionumber 2 ]
";
my ($today_only,$biblionumber_to_update,$itemnumber_to_update,$help);
GetOptions(
	'today' => \$today_only,
	'biblionumber:o' => \$biblionumber_to_update,
	'itemnumber:o' => \$itemnumber_to_update,
	'h' => \$help,
);

if ($help) {
    print $USAGE."\n";
    exit;
}

# This script can be run from cron or on the command line. It updates
# a zebra index with modifications for the period covered or the 
# biblionumber or itemnumber specified.
#
# You will need to customize this for your installation
# I hope that the comments will help -- Josha Ferraro <jmf@liblime.com>
my $dbh = C4::Context->dbh;

# Get the date, used both for filename and for period we're updating
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
$year +=1900;
$mon +=1;
# nice to zero-pad these dates
my $pad_mday= sprintf("%0*d", "2",$mday);
my $pad_mon = sprintf("%0*d", "2",$mon);

# FIXME: we should define a syspref for 'how often to run this script'
my $period = "$year-$pad_mon-$pad_mday%"; # today only - you'll want to customize this bit
print "period: $period\n";
my $date = "$year$mon$mday$hour$min$sec";

# This is the file that zebra will use to update the index at the end of this script
my $filename = "records.$date.iso2709";
my $biblioserverdir = C4::Context->zebraconfig('biblioserver')->{directory};

# check that directory exist, otherwise create.
unless (-d "$biblioserverdir/specialUpdate") {
    system("mkdir -p $biblioserverdir/specialUpdate");
    print "Info: created $biblioserverdir/specialUpdate\n";
}

my $outfile = "$biblioserverdir/specialUpdate/$filename";

# open a filehandle for writing records -- notice it's UTF-8
open OUT,">utf8",$outfile or die "can't open filehandle\n";

# if there aren't any changes, and all we're doing is updating things from today, don't bother
print "counting first\n";
my $countitems_sth = $dbh->prepare("SELECT COUNT(*) FROM items WHERE timestamp LIKE ?");
$countitems_sth->execute($period);
my $number_of_items = $countitems_sth->fetchrow();
unless ($number_of_items) {
	print "no recent items to update\n";
	exit if $today_only;
}

# get all the relevant biblionumbers, we're gonna update every item in these biblionumbers
print "finding biblionumbers\n";
my $biblionumber_sth;
if ($today_only) {
	$biblionumber_sth = $dbh->prepare("SELECT DISTINCT biblioitems.biblionumber FROM biblioitems LEFT JOIN items ON (biblioitems.biblionumber=items.biblionumber) WHERE items.timestamp LIKE ? AND biblioitems.marcxml IS NOT NULL");
	$biblionumber_sth->execute($period) or die "problem with query\n";
}
elsif ($biblionumber_to_update) {
	$biblionumber_sth = $dbh->prepare("SELECT biblionumber FROM biblioitems WHERE marcxml IS NOT NULL AND biblionumber=?");
	$biblionumber_sth->execute($biblionumber_to_update) or die "problem with query\n";
}
my $count;

print "fetching marc and items data, updating\n";
# for each itemnumber, find the biblionumber, get all the items data for that biblio,
# update all the items data in biblioitems.marc, and finally, index it in zebra

#
# 1st : find where some informations are hidden : itemnumber, date_due, popularity
#
my ($itemnumberTag,$itemnumberSubfield) = GetMarcFromKohaField("items.itemnumber","");
my ($date_dueTag,$date_dueSubfield) = GetMarcFromKohaField("items.issues","");
while (my $biblionumber=$biblionumber_sth->fetchrow) {
	$count++;

	# get this biblio's MARC record
    my $record = MARCgetbiblio($biblionumber);

	# delete all existing items data from this record FIXME: 952 shouldn't be hardcoded
	for my $field_to_del ($record->field("952")) {
		my $del_count = $record->delete_field($field_to_del);
		print "deleted $del_count fields";
	}
	# Find out the itemnumbers this biblio has
	my $itemnumbers_sth = $dbh->prepare("SELECT itemnumber FROM items WHERE biblionumber=?");
	$itemnumbers_sth->execute($biblionumber);
	
	# for each of the items, get all the item data
	while (my $data = $itemnumbers_sth->fetchrow_hashref) {
		my $itemnumber = $data->{itemnumber};
		my $item_data_sth = $dbh->prepare("SELECT * FROM items WHERE itemnumber=?");
		$item_data_sth->execute($data->{itemnumber});
		my $item_data_hashref = $item_data_sth->fetchrow_hashref();
		
		# create a new MARC::Field object and put a date_due in it (from issues table)
		my $date_due_sth = $dbh->prepare("SELECT date_due FROM issues WHERE itemnumber=? AND returndate IS NULL");
		$date_due_sth->execute($itemnumber);
		my ($date_due) = $date_due_sth->fetchrow();
		$date_due = "0000-00-00" unless ($date_due);

		# FIXME: this should use Frameworks!!! -- I'll do it soon -- JF
		my $items_field = MARC::Field->new( 952, " ", " ", "2" => $date_due, );

		# put all the data into our MARC::Record field, based on the Koha2MARC mappings
		for my $label (keys %$item_data_hashref) {
			if ($item_data_hashref->{$label}) {
				my $find_tag_subfield_sth = $dbh->prepare("SELECT tagfield,tagsubfield FROM marc_subfield_structure WHERE kohafield=?");
				$find_tag_subfield_sth->execute("items.$label");
				my ($tag,$subfield) = $find_tag_subfield_sth->fetchrow;
				if ($tag) {
					$items_field->add_subfields($subfield => $item_data_hashref->{$label} ) unless (!$item_data_hashref->{$label});
					print "added: $label ($tag $subfield): $item_data_hashref->{$label}";
                		}
				else {
					# You probably want to update your mappings if you see anything here ... but
					# in some cases it's safe to ignore these warnings
					print "WARN: no items.$label mapping found: $item_data_hashref->{$label}\n";
                		}
			}
		}
		# now update our original record, appending this field
		$record->insert_fields_ordered($items_field);
	}
	# at this point, we have an up-to-date MARC record
	# put it back in biblioitems.marc
	my $put_back_sth = $dbh->prepare("UPDATE biblioitems SET marc=? WHERE biblionumber=?");
	$put_back_sth->execute($record->as_usmarc(),$biblionumber);

	# schedule it for a zebra index update FIXME: we need better error handling
	print OUT $record->as_usmarc();	
}
# FIXME: add time taken
print "finished with $count items in\n";
# now we're ready to index this change in Zebra and commit it
# FIXME: these dirs shouldn't be hardcoded and sudo probably isn't what you use
chdir "/koha/zebradb/biblios/tab";
my $error = system("sudo zebraidx -g iso2709 -c /koha/etc/zebra-biblios.cfg -d biblios update $outfile");
if ($error) {
	die "update operation failed";
}
$error = system("sudo zebraidx -g iso2709 -c /koha/etc/zebra-biblios.cfg commit");

if ($error) {
	die "commit operation failed";
}

`sudo mv $outfile $outfile.finished`;
