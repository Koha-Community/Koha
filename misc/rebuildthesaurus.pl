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
    'f:s' => \$field,
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
\tf : the field
\ts : the subfields
\d : delete every entry of the selected category before doing work.

SAMPLE : ./bulkmarcimport.pl -c NP -f 700 -s "\$a, \$b (\$c ; \$d)" => will build authority file NP with value constructed with 700 field \$a, \$b, \$c & \$d subfields
In UNIMARC this rebuild author authority file.
EOF
;#
die;
}

my $dbh = C4::Context->dbh;
my @subfields = $subfields =~ /(\S)/g;
if ($delete) {
	print "deleting thesaurus\n";
	my $sth = $dbh->prepare("delete from bibliothesaurus where category=?");
	$sth->execute($category);
}
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

my $starttime = gettimeofday;
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
my $i;
while (my ($bibid) = $sth->fetchrow) {
	my $record = MARCgetbiblio($dbh,$bibid);
#	warn $record->as_formatted;
	foreach my $fieldwanted ($record->field($field)) {
		my $resultstring = $subfields;
		foreach my $pair ( $fieldwanted->subfields() ) {
			$resultstring =~ s/\$$pair->[0]/$pair->[1]/g;
		}
		# deals empty subfields
		foreach my $empty (@subfields) {
			$resultstring =~ s/\$$empty//g;
		}
		warn "result : $resultstring" if $verbose;
		&newauthority($dbh,$category,$resultstring);
		$i++;
	}

}
my $timeneeded = gettimeofday - $starttime;
print "$i entries done in $timeneeded seconds\n";
