package C4::Breeding;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Biblio;
use C4::Search;
use MARC::File::USMARC;
use MARC::Record;
use Encode;
require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Breeding : script to add a biblio in marc_breeding table.

=head1 SYNOPSIS
	&ImportBreeding($marcrecords,$overwrite_biblio,$filename,$z3950random);

	C<$marcrecord> => the MARC::Record
	C<$overwrite_biblio> => if set to 1 a biblio with the same ISBN will be overwritted.
  								if set to 0 a biblio with the same isbn will be ignored (the previous will be kept)
								if set to -1 the biblio will be added anyway (more than 1 biblio with the same ISBN possible in the breeding
	C<$encoding> => USMARC
						or UNIMARC. used for char_decoding.
						If not present, the parameter marcflavour is used instead
	C<$z3950random> => the random value created during a z3950 search result.

=head1 DESCRIPTION

This is for depository of records coming from z3950 or directly imported.

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&ImportBreeding &BreedingSearch);

sub  ImportBreeding {
	my ($marcrecords,$overwrite_biblio,$filename,$encoding,$z3950random) = @_;
## use marc:batch send them in one by one
#	my @marcarray = split /\x1D/, $marcrecords;
	my $dbh = C4::Context->dbh;
my @kohafields;
my @values;
my @relations;
my $sort;
my @and_or;
my @results;
my $count;
	my $searchbreeding = $dbh->prepare("select id from marc_breeding where isbn=? and title=?");
	my $insertsql = $dbh->prepare("insert into marc_breeding (file,isbn,title,author,marc,encoding,z3950random,classification,subclass) values(?,?,?,?,?,?,?,?,?)");
	my $replacesql = $dbh->prepare("update marc_breeding set file=?,isbn=?,title=?,author=?,marc=?,encoding=?,z3950random=?,classification=?,subclass=? where id=?");
	$encoding = C4::Context->preference("marcflavour") unless $encoding;
	# fields used for import results
	my $imported=0;
	my $alreadyindb = 0;
	my $alreadyinfarm = 0;
	my $notmarcrecord = 0;
	my $breedingid;
#	for (my $i=0;$i<=$#marcarray;$i++) {
		my $marcrecord = MARC::File::USMARC::decode($marcrecords);
		my $marcxml=$marcrecord->as_xml_record($marcrecord);
		$marcxml=Encode::encode('utf8',$marcxml);
		my @warnings = $marcrecord->warnings();
		if (scalar($marcrecord->fields()) == 0) {
			$notmarcrecord++;
		} else {
			my $xmlhash=XML_xml2hash_onerecord($marcxml);	
			my $oldbiblio = XMLmarc2koha_onerecord($dbh,$xmlhash,'biblios');
			# if isbn found and biblio does not exist, add it. If isbn found and biblio exists, overwrite or ignore depending on user choice
			# drop every "special" char : spaces, - ...
			$oldbiblio->{isbn} =~ s/ |-|\.//g,
			$oldbiblio->{isbn} = substr($oldbiblio->{isbn},0,10);
			$oldbiblio->{issn} =~ s/ |-|\.//g,
			$oldbiblio->{issn} = substr($oldbiblio->{issn},0,10);
			# search if biblio exists
			my $biblioitemnumber;
			my $facets;
		    if ( !$z3950random){
			if ($oldbiblio->{isbn}) {
			push @kohafields,"isbn";
			push @values,$oldbiblio->{isbn};
			push @relations,"";
			push @and_or,"";
			
			($count,$facets,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations);
			} else {
			push @kohafields,"issn";
			push @values,$oldbiblio->{issn};
			push @relations,"";
			push @and_or,"";
			$sort="";
			($count,$facets,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations);
			}
	    	     }
			if ($count>0 && !$z3950random) {
				$alreadyindb++;
			} else {
				# search in breeding farm
				
				if ($oldbiblio->{isbn}) {
					$searchbreeding->execute($oldbiblio->{isbn},$oldbiblio->{title});
					($breedingid) = $searchbreeding->fetchrow;
				} elsif ($oldbiblio->{issn}){
					$searchbreeding->execute($oldbiblio->{issn},$oldbiblio->{title});
					($breedingid) = $searchbreeding->fetchrow;
				}
				if ($breedingid && $overwrite_biblio eq 0) {
					$alreadyinfarm++;
				} else {
					my $recoded=MARC::Record->new_from_xml($marcxml,"UTF-8");
					$recoded->encoding('UTF-8');
					
					if ($breedingid && $overwrite_biblio eq 1) {
						$replacesql ->execute($filename,substr($oldbiblio->{isbn}.$oldbiblio->{issn},0,10),$oldbiblio->{title},$oldbiblio->{author},$recoded->as_usmarc,$encoding,$z3950random,$oldbiblio->{classification},$oldbiblio->{subclass},$breedingid);
					} else {
						$insertsql ->execute($filename,substr($oldbiblio->{isbn}.$oldbiblio->{issn},0,10),$oldbiblio->{title},$oldbiblio->{author},$recoded->as_usmarc,$encoding,$z3950random,$oldbiblio->{classification},$oldbiblio->{subclass});
					
					$breedingid=$dbh->{'mysql_insertid'};
					}
					$imported++;
				}
			}
		}
	#}
	return ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported,$breedingid);
}


=item BreedingSearch

  ($count, @results) = &BreedingSearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<marc_breeding> table of the Koha database.

=cut

sub BreedingSearch {
	my ($title,$isbn,$z3950random) = @_;
	my $dbh   = C4::Context->dbh;
	my $count = 0;
	my ($query,@bind);
	my $sth;
	my @results;

	$query = "Select id,file,isbn,title,author,classification,subclass from marc_breeding where ";
	if ($z3950random) {
		$query .= "z3950random = ?";
		@bind=($z3950random);
	} else {
	    @bind=();
		if ($title) {
			$query .= "title like ?";
			push(@bind,"$title%");
		}
		if ($title && $isbn) {
			$query .= " and ";
		}
		if ($isbn) {
			$query .= "isbn like ?";
			push(@bind,"$isbn%");
		}
	}
	$sth   = $dbh->prepare($query);
	$sth->execute(@bind);
	while (my $data = $sth->fetchrow_hashref) {
			$results[$count] = $data;
			$count++;
	} # while

	$sth->finish;
	return($count, @results);
} # sub breedingsearch


END { }       # module clean-up code here (global destructor)
