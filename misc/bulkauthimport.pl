#!/usr/bin/perl
# small script that import an iso2709 file into koha 2.0

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::AuthoritiesMarc;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version, $delete, $test_parameter,$char_encoding, $verbose);
GetOptions(
    'file:s'    => \$input_marc_file,
    'n' => \$number,
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    'c:s' => \$char_encoding,
    'v:s' => \$verbose,
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
small script to import an iso2709 file into Koha.
parameters :
\th : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tv : verbose mode. 1 means "some infos", 2 means "MARC dumping"
\tn : the number of the record to import. If missing, all the file is imported
\tt : test mode : parses the file, saying what he would do, but doing nothing.
\tc : the char encoding. At the moment, only MARC21 and UNIMARC supported. MARC21 by default.
\td : delete EVERYTHING related to biblio in koha-DB before import  :tables :
\t\tbiblio, \t\tbiblioitems, \t\tsubjects,\titems
\tmarc_biblio,
\t\tmarc_subfield_table, \tmarc_word, \t\tmarc_blob_subfield
IMPORTANT : don't use this script before you've entered and checked twice (or more) your  MARC parameters tables.
If you fail this, the import won't work correctly and you will get invalid datas.

SAMPLE : ./bulkmarcimport.pl -file /home/paul/koha.dev/local/npl -n 1
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;

if ($delete) {
	print "deleting authorities\n";
	$dbh->do("delete from auth_header");
}
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

$char_encoding = 'MARC21' unless ($char_encoding);
print "CHAR : $char_encoding\n" if $verbose;
my $starttime = gettimeofday;
my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
while ( my $record = $batch->next() ) {
	$i++;
	#now, parse the record, extract the item fields, and store them in somewhere else.

    ## create an empty record object to populate
    my $newRecord = MARC::Record->new();
	$newRecord->leader($record->leader);
    # go through each field in the existing record
    foreach my $oldField ( $record->fields() ) {
		# just reproduce tags < 010 in our new record
		if ( $oldField->tag() < 10 ) {
			$newRecord->append_fields( $oldField );
			next();
		}
		# store our new subfield data in this list
		my @newSubfields = ();
	
		# go through each subfield code/data pair
		foreach my $pair ( $oldField->subfields() ) { 
			$pair->[1] =~ s/\<//g;
			$pair->[1] =~ s/\>//g;
			push( @newSubfields, $pair->[0], char_decode($pair->[1],$char_encoding) );
		}
	
		# add the new field to our new record
		my $newField = MARC::Field->new(
			$oldField->tag(),
			$oldField->indicator(1),
			$oldField->indicator(2),
			@newSubfields
		);
		$newRecord->append_fields( $newField );
    }
	warn "$i ==>".$newRecord->as_formatted() if $verbose eq 2;
	my $authtypecode=substr($newRecord->leader(),9,1);
	$authtypecode="NP" if ($authtypecode eq 'a'); # personnes
	$authtypecode="CO" if ($authtypecode eq 'b'); # collectivit�
	$authtypecode="NG" if ($authtypecode eq 'c'); # g�graphique
	$authtypecode="NM" if ($authtypecode eq 'd'); # marque
	$authtypecode="NF" if ($authtypecode eq 'e'); # famille
	$authtypecode="TI" if ($authtypecode eq 'f'); # Titre uniforme
	$authtypecode="TI" if ($authtypecode eq 'h'); # auteur/titre
	$authtypecode="MM" if ($authtypecode eq 'j'); # mot mati�e
	warn "XX => $authtypecode";
	# now, create biblio and items with NEWnewXX call.
	unless ($test_parameter) {
		my ($authid) = AddAuthority($newRecord,0,$authtypecode);
		warn "ADDED authority NB $authid in DB\n" if $verbose;
	}
}
# $dbh->do("unlock tables");
my $timeneeded = gettimeofday - $starttime;
print "$i MARC record done in $timeneeded seconds";
