#!/usr/bin/perl
# script that rebuild thesaurus from biblio table.

# delete  FROM  `marc_subfield_table`  WHERE tag =  "606" AND subfieldcode = 9;
use strict;
#use warnings; FIXME - Bug 2505

# Koha modules used
use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $fields, $number,$language) = ('',0);
my ($version, $verbose, $test_parameter, $field,$delete,$subfields);
GetOptions(
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    's:s' => \$fields,
    'v' => \$verbose,
	'l:s' => \$language,
);

if ($version or !$fields) {
	print <<EOF
Small script to recreate the COUNTRY list in authorised values from existing countries in the catalogue.
This script is useful when you migrate your datas with bulkmarcimport.pl as it populates parameters tables that are not modified by bulkmarcimport.

parameters :
\th : this version/help screen
\ts : the field or field list where the lang codes are stored.
\td : delete every entry of COUNTRY category before doing work.
\tl : the language of the language list (fr or en for instance)

The table is populated with iso codes and meaning (in french).
If the complete language name is unknown, the code is used instead and you will be warned by the script

SAMPLES :
 ./buildCOUNTRY.pl -d -s "('102a')"
EOF
;#
exit;
}

my %codesiso;

%codesiso = (
	'eng' => 'english',
	'fre' => 'french'
	);

%codesiso = (
	'an' => 'Antilles Néerlandaises',
	'at' => 'Autriche',
	'cr' => 'Costa Rica',
	'er' => 'Erythrée',
	'fr' => ' France',
	'in' => 'Inde',
	'is' => 'Islande',
	'lt' => 'Lituanie',
	'nd' => 'Pays Bas',
	'nf' => 'Norfolk',
	'ng' => 'Nigéria',
	'pa' => 'Manama',
	'pn' => 'Pitcairn',
	're' => 'Réunion (ile)',
	'sp' => 'Espagne',
	'us' => 'Etats Unis',
	) if $language eq 'fr';

my $dbh = C4::Context->dbh;
if ($delete) {
	print "deleting country list\n";
	$dbh->do("delete from authorised_values where category='COUNTRY'");
}

if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
my $starttime = gettimeofday;

my $sth = $dbh->prepare("SELECT count(*) as tot,subfieldvalue FROM marc_subfield_table WHERE tag + subfieldcode IN $fields group by subfieldvalue");

$sth->execute;
my $i=1;

print "=========================\n";
my $sth2 = $dbh->prepare("insert into authorised_values (category, authorised_value, lib) values (?,?,?)");
while (my ($tot,$langue) = $sth->fetchrow) {
	$sth2->execute('COUNTRY',$langue,$langue?$codesiso{$langue}:$langue);
	print "$langue is unknown is iso list (used $tot times)\n" unless $codesiso{$langue};
}
print "=========================\n";
