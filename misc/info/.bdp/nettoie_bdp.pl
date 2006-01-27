#!/usr/bin/perl
# small script that deletes biblios which barcodes are in the parameter file.

use strict;

use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_file) = ('');
my ($version, $test_parameter,$char_encoding, $annexe);
GetOptions(
    'file:s'    => \$input_file,
    'h' => \$version,
    't' => \$test_parameter,
);

if ($version || ($input_file eq '')) {
	print <<EOF
Script pour supprimer des notices en série dans Koha
Paramètres :
\th : Cet écran d'aide
\tfile /chemin/vers/fichier/fichier.codebarres : Le fichier contenant les code-barres à supprimer. Chaque code-barre est sur une ligne différente.
\tt : test mode : Ne fait rien, sauf parser le fichier.
SAMPLE : ./nettoie_bdp.pl -file /home/koha/liste_barcodes.txt
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output

my $starttime = gettimeofday;
open FILE, $input_file || die "erreur : fichier introuvable";

my $i=0;
#1st of all, find barcode MARC tag.
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.barcode");
my $sth = $dbh->prepare("select bibid from marc_subfield_table where tag=$tagfield and subfieldcode='$tagsubfield' and subfieldvalue=?");

while ( my $barcode = <FILE> ) {
	$barcode=~tr#\n\r\l#   #;
	$barcode=~s/\s//g;
	chomp $barcode;
	$barcode="a".$barcode."b" if not ($barcode=~/a|b/);
	$i++;
	$sth->execute($barcode);
	my ($bibid) = $sth->fetchrow;
	if ($test_parameter) {
		if ($bibid) {
			print "suppression de $bibid (code barre $barcode)\n";
		} else {
			print "Problème avec le code barre $barcode : introuvable dans la base\n";
		}
	} else {
		if ($bibid) {
			&NEWdelbiblio($dbh,$bibid);
		} else {
			print "Problème avec le code barre $barcode : introuvable dans la base\n";
		}
		print ".";
		my $timeneeded = gettimeofday - $starttime;
		print "$i in $timeneeded s\n" unless ($i % 50);

	}
# 	print "B : $barcode";
}
# $dbh->do("unlock tables");
my $timeneeded = gettimeofday - $starttime;
print "$i MARC record done in $timeneeded seconds\n";
