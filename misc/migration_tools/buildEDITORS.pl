#!/usr/bin/perl
# script that rebuild EDITORS

use strict;
#use warnings; FIXME - Bug 2505

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
my ($version, $verbose, $test_parameter, $confirm,$delete);
GetOptions(
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    'v' => \$verbose,
    'c' => \$confirm,
);

if ($version or !$confirm) {
	print <<EOF
small script to recreate a authority table into Koha.
This will parse all your biblios to recreate isbn / editor / collections for the unimarc_210c and unimarc_225a plugins.

Remember those plugins will work only if you have an EDITORS authority type, with
\t200a being the first 2 parts of an ISBN
\t200b being the editor name
\t200c (repeatable) being the series title

parameters :
\t-c : confirmation flag. the script will run only with this flag. Otherwise, it will just show this help screen.
\t-d : delete existing EDITORS before rebuilding them
\t-t : test parameters : run the script but don't create really the EDITORS
EOF
;#'

exit;
}

my $dbh = C4::Context->dbh;
if ($delete) {
	print "deleting EDITORS\n";
	my $del1 = $dbh->prepare("delete from auth_subfield_table where authid=?");
	my $del2 = $dbh->prepare("delete from auth_word where authid=?");
	my $sth = $dbh->prepare("select authid from auth_header where authtypecode='EDITORS'");
	$sth->execute;
	while (my ($authid) = $sth->fetchrow) {
		$del1->execute($authid);
		$del2->execute($authid);
	}
	$dbh->do("delete from auth_header where authtypecode='EDITORS'");
}

if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$|=1; # flushes output
my $starttime = gettimeofday;
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
my $i=1;
my %alreadydone;
my $counter;
my %hash;
while (my ($bibid) = $sth->fetchrow) {
	my $record = GetMarcBiblio($bibid);
	my $isbnField = $record->field('010');
	next unless $isbnField;
	my $isbn=$isbnField->subfield('a');
	my $seg1;
	if(substr($isbn, 0, 1) <=7) {
		$seg1 = substr($isbn, 0, 1);
	} elsif(substr($isbn, 0, 2) <= 94) {
		$seg1 = substr($isbn, 0, 2);
	} elsif(substr($isbn, 0, 3) <= 995) {
		$seg1 = substr($isbn, 0, 3);
	} elsif(substr($isbn, 0, 4) <= 9989) {
		$seg1 = substr($isbn, 0, 4);
	} else {
		$seg1 = substr($isbn, 0, 5);
	}
	my $x = substr($isbn, length($seg1));
	my $seg2;
	if(substr($x, 0, 2) <= 19) {
# 		if(sTmp2 < 10) sTmp2 = "0" sTmp2;
		$seg2 = substr($x, 0, 2);
	} elsif(substr($x, 0, 3) <= 699) {
		$seg2 = substr($x, 0, 3);
	} elsif(substr($x, 0, 4) <= 8399) {
		$seg2 = substr($x, 0, 4);
	} elsif(substr($x, 0, 5) <= 89999) {
		$seg2 = substr($x, 0, 5);
	} elsif(substr($x, 0, 6) <= 9499999) {
		$seg2 = substr($x, 0, 6);
	} else {
		$seg2 = substr($x, 0, 7);
	}
	$counter++;
	print ".";
	my $timeneeded = gettimeofday - $starttime;
	print "$counter in $timeneeded s\n" unless ($counter % 100);
	
	my $field = $record->field('210');
	my $editor;
	$editor=$field->subfield('c') if $field;
	
	$field = $record->field('225');
	my $collection;
	$collection=$field->subfield('a') if $field;
	
# 	print "WARNING : editor empty for ".$record->as_formatted unless $editor and !$verbose;

	$hash{$seg1.$seg2}->{editors} = $editor unless ($hash{$seg1.$seg2}->{editors});
	$hash{$seg1.$seg2}->{collections}->{$collection}++ if $collection;
}

foreach my $isbnstart (sort keys %hash) {
	print "$isbnstart -- ".$hash{$isbnstart}->{editors} if $verbose;
	my $collections = $hash{$isbnstart}->{collections};
	my $seriestitlelist;
	foreach my $collection (sort keys %$collections) {
		print " CC $collection : ".$collections->{$collection} if $verbose;
		$seriestitlelist.=$collection."|";
	}
	my $authorityRecord = MARC::Record->new();
	my $newfield = MARC::Field->new(200,'','','a' => "".$isbnstart,
												'b' => "".$hash{$isbnstart}->{editors},
												'c' => "".$seriestitlelist);
	$authorityRecord->insert_fields_ordered($newfield);
	my $authid=AUTHaddauthority($dbh,$authorityRecord,'','EDITORS');

# 	print $authorityRecord->as_formatted."\n";
	print "\n" if $verbose;
}
exit;

# 	my $timeneeded = gettimeofday - $starttime;
# 	print "$i in $timeneeded s\n" unless ($i % 50);
# 	foreach my $field ($record->field(995)) {
# 		$record->delete_field($field);
# 	}
# 	my $totdone=0;
# 	my $authid;
# 	foreach my $fieldnumber (('710','711','712')) {
# 		foreach my $field ($record->field($fieldnumber)) {
# 	# 		print "=>".$field->as_formatted."\n";
# 			foreach my $authentry ($field->subfield("a")) {
# 				my $hashentry = $authentry;
# 				# la particularit�de ce script l� c'est que l'entr� dans la table d'autorit�est $a -- $b (et pas $x -- $x -- $x -- $a comme pour les autorit� NC)
# 				# si n�essaire, compl�er avec le $c (n'existe pas dans le fichier que j'ai migr�avec cette moulinette
# 				# supprimer les accents, certaines entr�s sont sans, d'autres avec !
# 				# mysql ne diff�encie pas, mais les hash perl oui !
# 				$hashentry =~ s/���e/g;
# 				$hashentry =~ s/��a/g;
# 				$hashentry =~ s/�i/g;
# 				$hashentry =~ s/�o/g;
# 				$hashentry =~ s/|/u/g;
# 				$hashentry = uc($hashentry);
# 				print "==>$hashentry" if $hashentry =~ /.*ETATS.*/;
# 				$totdone++;
# 				if ($alreadydone{$hashentry}) {
# 					$authid = $alreadydone{$hashentry};
# 					print ".";
# 				} else {
# 					print "*";
# 					#create authority.
# 					my $authorityRecord = MARC::Record->new();
# 					my $newfield = MARC::Field->new(210,'','','a' => "".$authentry, 
# 												'b' => "".$field->subfield('b'),
# 												'c' => "".$field->subfield('c'),
# 												);
# 					$authorityRecord->insert_fields_ordered($newfield);
# 					$authid=AUTHaddauthority($dbh,$authorityRecord,'','CO');
# 					$alreadydone{$hashentry} = $authid;
# 					# OK, on garde la notice d'autorit� on cherche les notices biblio et on les met �jour...
# 					if ($fieldnumber eq '710') {
# 						$sthBIBLIOS710->execute($authentry);
# 						while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOS710->fetchrow) {
# 							my $inbiblio = GetMarcBiblio($bibid);
# 							my $isOK = 0;
# 							foreach my $in7xx ($inbiblio->field($fieldnumber)) {
# 								# !!!!! ici, il faut reconstruire l'entr� de la table de hachage comme ci dessus
# 								# sinon, 
# 								my $inEntry = $in7xx->subfield('a');
# 								$inEntry =~ s/���e/g;
# 								$inEntry =~ s/��a/g;
# 								$inEntry =~ s/�i/g;
# 								$inEntry =~ s/�o/g;
# 								$inEntry =~ s/|/u/g;
# 								$inEntry = uc($inEntry);
# 								$isOK=1 if $inEntry eq $hashentry;
# 							}
# 							C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
# 						}
# 					}
# 					if ($fieldnumber eq '711') {
# 						$sthBIBLIOS711->execute($authentry);
# 						while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOS711->fetchrow) {
# 							my $inbiblio = GetMarcBiblio($bibid);
# 							my $isOK = 0;
# 							foreach my $in7xx ($inbiblio->field($fieldnumber)) {
# 								# !!!!! ici, il faut reconstruire l'entr� de la table de hachage comme ci dessus
# 								# sinon, 
# 								my $inEntry = $in7xx->subfield('a');
# 								$inEntry =~ s/���e/g;
# 								$inEntry =~ s/��a/g;
# 								$inEntry =~ s/�i/g;
# 								$inEntry =~ s/�o/g;
# 								$inEntry =~ s/|/u/g;
# 								$inEntry = uc($inEntry);
# 								$isOK=1 if $inEntry eq $hashentry;
# 							}
# 							C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
# 						}
# 					}
# 					if ($fieldnumber eq '712') {
# 						$sthBIBLIOS712->execute($authentry);
# 						while (my ($bibid,$tag,$tagorder,$subfieldorder) = $sthBIBLIOS712->fetchrow) {
# 							my $inbiblio = GetMarcBiblio($bibid);
# 							my $isOK = 0;
# 							foreach my $in7xx ($inbiblio->field($fieldnumber)) {
# 								# !!!!! ici, il faut reconstruire l'entr� de la table de hachage comme ci dessus
# 								# sinon, 
# 								my $inEntry = $in7xx->subfield('a');
# 								$inEntry =~ s/���e/g;
# 								$inEntry =~ s/��a/g;
# 								$inEntry =~ s/�i/g;
# 								$inEntry =~ s/�o/g;
# 								$inEntry =~ s/|/u/g;
# 								$inEntry = uc($inEntry);
# 								$isOK=1 if $inEntry eq $hashentry;
# 							}
# 							C4::Biblio::MARCaddsubfield($dbh,$bibid,$tag,'',$tagorder,9,$subfieldorder,$authid) if $isOK;
# 						}
# 					}
# 				}
# 			}
# 		}
# 	}
# 	$i++;
# }
# my $timeneeded = gettimeofday - $starttime;
# print "$i entries done in $timeneeded seconds (".($i/$timeneeded)." per second)\n";
