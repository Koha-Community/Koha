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
Small script to recreate the LANG list in authorised values from existing langs in the catalogue.
This script is useful when you migrate your datas with bulkmarcimport.pl as it populates parameters tables that are not modified by bulkmarcimport.

parameters :
\th : this version/help screen
\ts : the field or field list where the lang codes are stored.
\td : delete every entry of LANG category before doing work.
\tl : the language of the language list (fr or en for instance)

The table is populated with iso codes and meaning (in french).
If the complete language name is unknown, the code is used instead and you will be warned by the script

SAMPLES :
 ./buildLANG -d -s "('101a','101b')"
EOF
;#/
exit;
}

my %codesiso;

%codesiso = (
	'eng' => 'english',
	'fre' => 'french'
	);

%codesiso = (
	'mis' => 'diverses',
	'und' => 'inconnue',
	'mul' => 'multilingue',
	'ger' => 'allemand',
	'eng' => 'anglais',
	'afr' => 'afrikaans',
	'akk' => 'akkadien',
	'amh' => 'amharique',
	'ang' => 'anglo-saxon (ca. 450-1100)',
	'arc' => 'araméen',
	'ara' => 'arabe',
	'arm' => 'arménien',
	'baq' => 'basque',
	'ber' => 'berbere',
	'bre' => 'breton',
	'bul' => 'bulgare',
	'cat' => 'catalan',
	'chi' => 'chinois',
	'cop' => 'copte',
	'cro' => 'croate',
	'cze' => 'tchèque',
	'dan' => 'danois',
	'dum' => 'néerlandais moyen (ca. 1050-1350)',
	'dut' => 'néerlandais',
	'spa' => 'espagnol',
	'egy' => 'egyptien',
	'esp' => 'espéranto',
	'fin' => 'finnois',
	'fra' => 'français ancien',
	'fre' => 'français',
	'frm' => 'français moyen (ca. 1400-1600)',
	'fro' => 'français ancien (842-ca. 1400)',
	'gmh' => 'allemand, moyen haut (ca. 1050-1500)',
	'got' => 'gothique',
	'grc' => 'grec classique',
	'gre' => 'grec moderne',
	'heb' => 'hébreu',
	'hin' => 'hindi',
	'hun' => 'hongrois',
	'ind' => 'indonésien',
	'ine' => 'indo-européennes, autres',
	'ita' => 'italien',
	'jap' => 'japonais',
	'jpn' => 'japonais',
	'kor' => 'coréen',
	'lan' => 'occitan (post 1500)',
	'lat' => 'latin',
	'map' => 'malayo-polynésiennes, autres',
	'mla' => 'malgache',
	'nic' => 'nigéro-congolaises, autres',
	'nor' => 'norvégien',
	'per' => 'persan',
	'pro' => 'provencal ancien (jusqu\'à 1500)',
	'pol' => 'polonais',
	'por' => 'portugais',
	'rom' => 'tzigane',
	'rum' => 'roumain',
	'rus' => 'russe',
	'sam' => 'samaritain',
	'san' => 'sanskrit',
	'scr' => 'serbo-croate',
	'sem' => 'sémitique, autres langues',
	'ser' => 'serbe',
	'sla' => 'slave, autres langues',
	'slo' => 'slovène',
	'syr' => 'syriaque',
	'swe' => 'suedois',
	'tib' => 'tibétain',
	'tur' => 'turc',
	'uga' => 'ougaritique',
	'ukr' => 'ukraine',
	'wel' => 'gallois',
	'yid' => 'yiddish',
	) if $language eq 'fr';

my $dbh = C4::Context->dbh;
if ($delete) {
	print "deleting lang list\n";
	$dbh->do("delete from authorised_values where category='LANG'");
}

if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
my $starttime = gettimeofday;

my $sth = $dbh->prepare("SELECT DISTINCT subfieldvalue FROM marc_subfield_table WHERE tag + subfieldcode IN $fields order by subfieldvalue");

$sth->execute;
my $i=1;

print "=========================\n";
my $sth2 = $dbh->prepare("insert into authorised_values (category, authorised_value, lib) values (?,?,?)");
while (my ($langue) = $sth->fetchrow) {
	$sth2->execute('LANG',$langue,$langue?$codesiso{$langue}:$langue);
	print "lang : $langue is unknown is iso list\n" unless $codesiso{$langue};
}
print "=========================\n";
