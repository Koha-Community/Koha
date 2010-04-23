#!/usr/bin/perl
# small script that rebuilds the non-MARC DB

use strict;
#use warnings; FIXME - Bug 2505
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::Record;
use C4::Context;
use C4::Biblio;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version, $confirm,$test_parameter);
GetOptions(
	'c' => \$confirm,
	'h' => \$version,
	't' => \$test_parameter,
);

if ($version || (!$confirm)) {
	print <<EOF
This script cleans unused subfields in the MARC DB.
If you alter the MARC parameters and remove a subfield (ie : move it to ignore (10) tab), existing subfields are NOT removed.
It's not a bug, it prevents deleting useful values in case of erroneous move.
This script definetly remove unused subfields in the MARC DB.
syntax :
\t./cleanmarcdb.pl -h (or without arguments => shows this screen)
\t./cleanmarcdb.pl -c (c like confirm => cleans the marc DB (may be long)
\t-t => test only, change nothing in DB
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;
my $i=0;
my $starttime = gettimeofday;
my $cleansubfield = $dbh->prepare("delete from marc_subfield_table where tag=? and subfieldcode=?");
my $cleanword = $dbh->prepare("delete from marc_word where tag=? and subfieldid=?");

# get tags structure
my $tags = GetMarcStructure(1);
foreach my $tag (sort keys(%{$tags})) {
	foreach my $subfield (sort keys(%{$tags->{$tag}})) {
		next if $subfield eq "lib";
		next if $subfield eq "mandatory";
		next if $subfield eq "tab";
		# DO NOT drop biblionumber, biblioitemnumber and itemnumber.
		# they are stored internally, and are mapped to tab -1. This script must keep them or it will completly break Koha DB !!!
		next if ($tags->{$tag}->{$subfield}->{kohafield} eq "biblio.biblionumber");
		next if ($tags->{$tag}->{$subfield}->{kohafield} eq "biblioitems.biblioitemnumber");
		next if ($tags->{$tag}->{$subfield}->{kohafield} eq "items.itemnumber");
		# now, test => if field is ignored (in tab -1 or '') => drop everything in the MARC table !
		if ($tags->{$tag}->{$subfield}->{tab} eq -1 || $tags->{$tag}->{$subfield}->{tab} eq '') {
			print "dropping $tag \$ $subfield\n";
			$cleansubfield->execute($tag,$subfield) unless $test_parameter;
			$cleanword->execute($tag,$subfield) unless $test_parameter;
			print "TEST " if $test_parameter;
			print "done\n";
		}
	}
}
my $timeneeded = gettimeofday - $starttime;
print "done in $timeneeded seconds\n";
