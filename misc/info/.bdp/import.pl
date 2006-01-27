#!/usr/bin/perl
# small script that import an iso2709 file into koha 2.0

use strict;

use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use C4::Date;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file) = ('');
my ($version, $test_parameter,$char_encoding, $annexe);
GetOptions(
    'file:s'    => \$input_marc_file,
    'h' => \$version,
    't' => \$test_parameter,
    'c:s' => \$char_encoding,
	'a:s' => \$annexe,
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
Script pour importer un fichier iso2709 dans Koha.
Paramètres :
\th : Cet écran d'aide
\tfile /chemin/vers/fichier/fichier.iso2709 : Le fichier à importer
\tt : test mode : Ne fait rien, sauf parser le fichier.
\tc : L'encodate des caractères. UNIMARC (valeur par défaut) ou MARC21
SAMPLE : ./import.pl -file /home/koha/bdp82-janvier.iso2709
EOF
;#'/
die;
}

my $dbh = C4::Context->dbh;
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output

$char_encoding = 'UNIMARC' unless ($char_encoding);
my $starttime = gettimeofday;
my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.itemnumber");
while ( my $record = $batch->next() ) {
	$i++;
	print ".";
	my $timeneeded = gettimeofday - $starttime;
	print "$i in $timeneeded s\n" unless ($i % 50);
	#now, parse the record, extract the item fields, and store them in somewhere else.

    ## create an empty record object to populate
    my $newRecord = MARC::Record->new();

# noter le champ 908 (public visé). => ca ne doit rien donner dans les fichiers BDP

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
			# supprimer les - dans l'ISBN
			if ($oldField->tag() eq '010' && $pair->[0] eq 'a') {
				$pair->[1] =~ s/-//g;
			}
			# supprimer les () dans le titre
			if ($oldField->tag() eq '200' && $pair->[0] eq 'a') {
# 			warn "==>".$pair->[1];
				$pair->[1] =~ s/\x88//g;
				$pair->[1] =~ s/\x89//g;
			}
			if ($oldField->tag() eq '995' && $pair->[0] eq 'f') {
# 			warn "==>".$pair->[1];
				$pair->[0] = 'j';
				$pair->[1] = "a".$pair->[1]."b";
			}
			if ($oldField->tag() eq '995' && $pair->[0] eq 'c') {
# 			warn "==>".$pair->[1];
				$pair->[1] = "BIB";
			}
			if ($oldField->tag() eq '995' && $pair->[0] eq 'a') {
# 			warn "==>".$pair->[1];
				$pair->[1] = "Med";
				$pair->[0] = 'b';
			}
			# on ignore le 995$o (notforloan dans Koha)
			push( @newSubfields, $pair->[0], char_decode($pair->[1],$char_encoding)) unless ($oldField->tag() eq 995 and $pair->[0] eq 'o');
		}
	
		# Ajouter le nouveau champ dans le MARC::Record, en déplacant le 906 en 610 (indexation libre)
		my $newField;
# 		if ($oldField->tag() eq 906) {
# 			$newField = MARC::Field->new(
# 				610,
# 				$oldField->indicator(1),
# 				$oldField->indicator(2),
# 				@newSubfields
# 			);
# 		} else {
			$newField = MARC::Field->new(
				$oldField->tag(),
				$oldField->indicator(1),
				$oldField->indicator(2),
				@newSubfields
			);
# 		}
		$newRecord->append_fields( $newField );
    }
	# ajouter itemtypes
#	print $record->as_formatted unless $record->field("995");
	my $cote =$record->field("995")->subfield("k");
	my $itemtypefield;
	if ($newRecord->field('200')) {
		my $type;
		$type = "SF" if $cote=~/^SF /;
		$type = "RP" if $cote=~/^RP /;
		$type = "BDA" if ($cote=~/^BD / && $cote!~/\([J|R|B]\)/);
		$type = "BD" if ($cote=~/^BD / && $cote=~/\([J|R|B]\)\s*$/);
		$type = "JR" if ($cote=~/^R? / && $cote=~/\([J|R|B]\)\s*$/);
		$type = "R" if ($cote=~/^R / && $cote!~/\([J|R|B]\)/);
		$type = "RP" if ($cote=~/^RP / && $cote!~/\([J|R|B]\)/);
		$type = "RV" if ($cote=~/^RV / && $cote!~/\([J|R|B]\)/);
		$type = "RH" if ($cote=~/^RH / && $cote!~/\([J|R|B]\)/);
		$type = "JD" if ($cote=~/^[0-9.]* / && $cote=~/\([J|R|B]\)\s*$/);
		$type = "RP" if ($cote=~/^RP / && $cote!~/\([J|R|B]\)/);
		$type = "ED" if ($cote=~/^C / && $cote=~/\([J|R|B]\)\s*$/);
		$type = "RV" if ($cote=~/^[0-9.]* / && $cote!~/\([J|R|B]\)/);
		$type = "A" if ($cote=~/^A /);
		$type = "N" if ($cote=~/^N /);
		$type = "BDP" unless ($type);
		$newRecord->field('200')->add_subfields('b' => $type,
		);
	}
	if ($newRecord->field('317')) {
		my $date;
		$date = format_date('today');
		$newRecord->field('317')->add_subfields('a' => $date,
		);
	} else {
		my $date;
		$date = format_date('today');
		my $newField = MARC::Field->new('317','','','a'=>$date);
		$newRecord->append_fields($newField)
	}
	if ($newRecord->field('010') && $newRecord->field('010')->subfield('d')){
		my $tmpField = $newRecord->field('010')->clone;
		$newRecord->delete_field($tmpField);
		if ($newRecord->field('995')){
			$newRecord->field('995')->add_subfields('u'=>$tmpField->subfield('d'));
		}else{
			my $Field= MARC::Field->new('995','','','u'=>$tmpField->subfield('d'));
			$newRecord->insert_fields_ordered($Field);
		}
	}

	my @fields = $newRecord->field($tagfield);
	my @items;
	my $nbitems=0;

	foreach my $field (@fields) {
		my $item = MARC::Record->new();
		if ($field->subfield('b')){$field->update('b' => 'Med');} else {$field->add_subfields('b' => 'Med');}
		if ($field->subfield('c')){$field->update('c' => 'BIB');} else {$field->add_subfields('c' => 'BIB');}
		$field->add_subfields('s' => 'Médiathèque');
# 		if ($public_vise eq "A partir de 1 an") {
# 			$field->update('q' => '0-5');
# 		} elsif ($public_vise eq "A partir de 2 ans") {
# 			$field->update('q' => '0-5');
# 		} elsif ($public_vise eq "A partir de 3 ans") {
# 			$field->update('q' => '0-5');
# 		} elsif ($public_vise eq "A partir de 4 ans") {
# 			$field->update('q' => '0-5');
# 		} elsif ($public_vise eq "A partir de 6 ans") {
# 			$field->update('q' => '06-09');
# 		} elsif ($public_vise eq "A partir de 7 ans") {
# 			$field->update('q' => '06-09');
# 		} elsif ($public_vise eq "A partir de 8 ans") {
# 			$field->update('q' => '06-09');
# 		} elsif ($public_vise eq "A partir de 9 ans") {
# 			$field->update('q' => '06-09');
# 		} elsif ($public_vise eq "A partir de 10 ans") {
# 			$field->update('q' => '10-11');
# 		} elsif ($public_vise eq "A partir de 11 ans") {
# 			$field->update('q' => '10-11');
# 		} elsif ($public_vise eq "A partir de 12 ans") {
# 			$field->update('q' => '12-16');
# 		} elsif ($public_vise eq "A partir de 13 ans") {
# 			$field->update('q' => '12-16');
# 		} elsif ($public_vise eq "A partir de 14 ans") {
# 			$field->update('q' => '12-16');
# 		} else {
# 			$field->update('q' => '18');
# 		}
		$item->append_fields($field);
		push @items,$item;
		$newRecord->delete_field($field);
		$nbitems++;
	}
	# now, create biblio and items with NEWnewXX call.
	unless ($test_parameter) {
		warn "biblio : ".$newRecord->as_formatted;
		my ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$newRecord,'') if $nbitems>0;
		for (my $i=0;$i<$nbitems;$i++) {
			my $itemfield = $items[$i];
		warn "Exemplaire $i : ".$itemfield->as_formatted;
			NEWnewitem($dbh,$itemfield,$bibid,'');
		}
	}
}
# $dbh->do("unlock tables");
my $timeneeded = gettimeofday - $starttime;
print "$i MARC record done in $timeneeded seconds\n";
