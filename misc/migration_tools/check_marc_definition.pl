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
my ($version,$confirm,$all,$autoclean,$autoactivate);
GetOptions(
    'h' => \$version,
    'c' => \$confirm,
	'a' => \$all,
	'l' => \$autoclean,
	'm' => \$autoactivate,
);

if ($version || ($confirm eq '')) {
	print <<EOF
Script that compare the datas in the DB and the setting of MARC structure 
It show all fields/subfields that are in the MARC DB but NOT in any tab (= fields used but not visible) Usually, this means you made an error in your MARC editor. Sometimes, this is something normal.

options
\t-l : autoclean => all unused subfields will be unactivated automatically in frameworks. Use carefully !!!!
\t-m : autoactivate => all subfields used but unactivated will automatically be activated in tab 1. Use carrefully !!!
\t-a : will show all subfields usages, not only subfields in tab ignore that are used.
Enter $0 -c to run this script (the -c being here only to "confirm"
EOF
;#
exit;
}#/

my $dbh = C4::Context->dbh;
print "Checking\n";
my $sth = $dbh->prepare("SELECT count(*), tag, subfieldcode, frameworkcode FROM marc_subfield_table, marc_biblio WHERE marc_biblio.bibid = marc_subfield_table.bibid group by frameworkcode,tag,subfieldcode");
$sth->execute;
my %tags;
my $sth2 = $dbh->prepare("select tab,liblibrarian,kohafield from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
if ($all) {
	print "framework|tag|subfield|value|used|tab\n";
}
my $sth3 = $dbh->prepare("update marc_subfield_structure set tab=1 where frameworkcode=? and tagfield=? and tagsubfield=?");
while (my ($total,$tag,$subfield,$frameworkcode) = $sth->fetchrow) {
	$sth2->execute($tag,$subfield,$frameworkcode);
	$tags{$frameworkcode." / ".$tag." / ".$subfield} ++;
	my ($tab,$liblibrarian,$kohafield) = $sth2->fetchrow;
	if ($all) {
		print $frameworkcode."|".$tag.'|$'.$subfield."|".$liblibrarian."|".$total."|".$tab."\n";
	} else {
		if ($tab eq -1 && $kohafield ne "biblio.biblionumber" && $kohafield ne "biblioitems.biblioitemnumber" && $kohafield ne "items.itemnumber") {
			print "Tab ignore for framework $frameworkcode, $tag\$$subfield - $liblibrarian (used $total times)\n";
			$sth3->execute($frameworkcode,$tag,$subfield) if $autoactivate && tab eq -1;
			
		}
	}
}

$sth = $dbh->prepare("select frameworkcode,tagfield,tagsubfield from marc_subfield_structure where tab<>-1 order by frameworkcode,tagfield,tagsubfield");
$sth->execute;
print "===================\n";
# for autoclean...
my $sth2 = $dbh->prepare("update marc_subfield_structure set tab=-1 where frameworkcode=? and tagfield=? and tagsubfield=?");
while (my ($frameworkcode,$tag,$subfield) = $sth->fetchrow) {
	print "$tag, $subfield in framework $frameworkcode is active, but never filled" unless $tags{$frameworkcode." / ".$tag." / ".$subfield};
	print "... auto cleaned" if $autoclean;
	print "\n" unless $tags{$frameworkcode." / ".$tag." / ".$subfield};
	$sth2->execute($frameworkcode,$tag,$subfield) if $autoclean;
}
print "Done\n";
