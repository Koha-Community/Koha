#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version,$confirm);
GetOptions(
    'h' => \$version,
    'c' => \$confirm,
);

if ($version || ($confirm eq '')) {
	print <<EOF
Script that compare the datas in the DB and the setting of MARC structure 
It show all fields/subfields that are in the MARC DB but NOT in any tab (= fields used but not visible) Usually, this means you made an error in your MARC editor. Sometimes, this is something normal.

Enter $0 -c to run this script (the -c being here only to "confirm"
EOF
;#
exit;
}#/

my $dbh = C4::Context->dbh;
print "Checking\n";
my $sth = $dbh->prepare("SELECT count(*), tag, subfieldcode, frameworkcode FROM marc_subfield_table, marc_biblio WHERE marc_biblio.bibid = marc_subfield_table.bibid group by frameworkcode,tag,subfieldcode");
$sth->execute;
my $sth2 = $dbh->prepare("select tab,liblibrarian,kohafield from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
while (my ($total,$tag,$subfield,$frameworkcode) = $sth->fetchrow) {
	$sth2->execute($tag,$subfield,$frameworkcode);
	my ($tab,$liblibrarian,$kohafield) = $sth2->fetchrow;
	if ($tab eq -1 && $kohafield ne "biblio.biblionumber" && $kohafield ne "biblioitems.biblioitemnumber" && $kohafield ne "items.itemnumber") {
		print "Tab ignore for framework $frameworkcode, $tag\$$subfield - $liblibrarian (used $total times)\n";
	}
}

print "Done\n";
