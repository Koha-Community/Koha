#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::Authorities;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version, $verbose, $test_parameter, $field,$delete,$category,$subfields);
GetOptions(
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    's:s' => \$subfields,
    'v' => \$verbose,
    'c:s' => \$category,
);

if ($version || ($category eq '')) {
	print <<EOF
small script to recreate a authority table into Koha.
parameters :
\th : this version/help screen
\tc : thesaurus category
\tv : verbose mode.
\tt : test mode : parses the file, saying what he would do, but doing nothing.
\ts : the subfields
\d : delete every entry of the selected category before doing work.

SAMPLES :
 ./rebuildthesaurus.pl -c NP -s "##700#a, ##700#b (##700#c ; ##700#d)" => will build authority file NP with value constructed with 700 field \$a, \$b, \$c & \$d subfields In UNIMARC this rebuild author authority file.
 ./rebuildthesaurus.pl -c EDITORS -s "##210#c -- ##225#a" => will build authority for editor and collection. The EDITORS authority category is used with plugins for 210 & 225 in UNIMARC.
EOF
;#
die;
}

my $dbh = C4::Context->dbh;
my @subf = $subfields =~ /(##\d\d\d##.)/g;
if ($delete) {
	print "deleting thesaurus\n";
	my $sth = $dbh->prepare("delete from bibliothesaurus where category=?");
	$sth->execute($category);
}
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output

my $starttime = gettimeofday;
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
my $i=1;
while (my ($bibid) = $sth->fetchrow) {
	my $record = MARCgetbiblio($dbh,$bibid);
	print ".";
	my $timeneeded = gettimeofday - $starttime;
	print "$i in $timeneeded s\n" unless ($i % 50);

#	warn $record->as_formatted;
	my $resultstring = $subfields;
	foreach my $fieldwanted ($record->fields) {
		next if $fieldwanted->tag()<=10;
		foreach my $pair ( $fieldwanted->subfields() ) {
			my $fieldvalue = $fieldwanted->tag();
#			warn "$fieldvalue ==> #$fieldvalue#$pair->[0]/$pair->[1]";
			$resultstring =~ s/##$fieldvalue##$pair->[0]/$pair->[1]/g;
		}
	}
		# deals empty subfields
		foreach my $empty (@subf) {
			$resultstring =~ s/$empty//g;
		}
		if ($resultstring ne $subfields && $resultstring) {
			&newauthority($dbh,$category,$resultstring);
		}
		$i++;
}
my $timeneeded = gettimeofday - $starttime;
print "$i entries done in $timeneeded seconds (".($i/$timeneeded)." per second)\n";
