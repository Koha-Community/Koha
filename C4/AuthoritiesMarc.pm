package C4::AuthoritiesMarc;
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
require Exporter;
use C4::Context;
use C4::Database;
use MARC::Record;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	&AUTHgettagslib
	&MARCfindsubfield
	&MARCfind_frameworkcode

	&AUTHaddauthority
	&AUTHmodauthority
	&AUTHdelauthority
	&AUTHaddsubfield
	&AUTHgetauthority
	
	&MARCmodsubfield
	&AUTHhtml2marc
	&AUTHaddword
	&MARCaddword &MARCdelword
	&char_decode
 );

 
sub AUTHgettagslib {
	my ($dbh,$forlibrarian,$authtypecode)= @_;
	warn "AUTH : $authtypecode";
	$authtypecode="" unless $authtypecode;
	warn "AUTH : $authtypecode";
	my $sth;
	my $libfield = ($forlibrarian eq 1)? 'liblibrarian' : 'libopac';
	# check that framework exists
	$sth=$dbh->prepare("select count(*) from auth_tag_structure where authtypecode=?");
	$sth->execute($authtypecode);
	my ($total) = $sth->fetchrow;
	$authtypecode="" unless ($total >0);
	$sth=$dbh->prepare("select tagfield,$libfield as lib,mandatory,repeatable from auth_tag_structure where authtypecode=? order by tagfield");
	$sth->execute($authtypecode);
	my ($lib,$tag,$res,$tab,$mandatory,$repeatable);
	while ( ($tag,$lib,$mandatory,$repeatable) = $sth->fetchrow) {
		$res->{$tag}->{lib}=$lib;
		$res->{$tab}->{tab}=""; # XXX
		$res->{$tag}->{mandatory}=$mandatory;
		$res->{$tag}->{repeatable}=$repeatable;
	}

	$sth=$dbh->prepare("select tagfield,tagsubfield,$libfield as lib,tab, mandatory, repeatable,authorised_value,value_builder,seealso from auth_subfield_structure where authtypecode=? order by tagfield,tagsubfield");
	$sth->execute($authtypecode);

	my $subfield;
	my $authorised_value;
	my $thesaurus_category;
	my $value_builder;
	my $kohafield;
	my $seealso;
	my $hidden;
	my $isurl;
	while ( ($tag, $subfield, $lib, $tab, $mandatory, $repeatable,$authorised_value,$value_builder,$seealso) = $sth->fetchrow) {
		$res->{$tag}->{$subfield}->{lib}=$lib;
		$res->{$tag}->{$subfield}->{tab}=$tab;
		$res->{$tag}->{$subfield}->{mandatory}=$mandatory;
		$res->{$tag}->{$subfield}->{repeatable}=$repeatable;
		$res->{$tag}->{$subfield}->{authorised_value}=$authorised_value;
		$res->{$tag}->{$subfield}->{thesaurus_category}=$thesaurus_category;
		$res->{$tag}->{$subfield}->{value_builder}=$value_builder;
		$res->{$tag}->{$subfield}->{seealso}=$seealso;
		$res->{$tag}->{$subfield}->{hidden}=$hidden;
		$res->{$tag}->{$subfield}->{isurl}=$isurl;
	}
	return $res;
}

sub AUTHaddauthority {
# pass the MARC::Record to this function, and it will create the records in the marc tables
	my ($dbh,$record,$authid,$authtypecode) = @_;
	my @fields=$record->fields();
# 	warn "IN AUTHaddauthority $authid => ".$record->as_formatted;
# adding main table, and retrieving authid
# if authid is sent, then it's not a true add, it's only a re-add, after a delete (ie, a mod)
# if authid empty => true add, find a new authid number
	unless ($authid) {
		$dbh->do("lock tables auth_header WRITE,auth_subfield_table WRITE, auth_word WRITE, stopwords READ");
		my $sth=$dbh->prepare("insert into auth_header (datecreated,authtypecode) values (now(),?)");
		$sth->execute($authtypecode);
		$sth=$dbh->prepare("select max(authid) from auth_header");
		$sth->execute;
		($authid)=$sth->fetchrow;
		$sth->finish;
	}
	my $fieldcount=0;
	# now, add subfields...
	foreach my $field (@fields) {
		$fieldcount++;
		if ($field->tag() <10) {
				&AUTHaddsubfield($dbh,$authid,
						$field->tag(),
						'',
						$fieldcount,
						'',
						1,
						$field->data()
						);
		} else {
			my @subfields=$field->subfields();
			foreach my $subfieldcount (0..$#subfields) {
				&AUTHaddsubfield($dbh,$authid,
						$field->tag(),
						$field->indicator(1).$field->indicator(2),
						$fieldcount,
						$subfields[$subfieldcount][0],
						$subfieldcount+1,
						$subfields[$subfieldcount][1]
						);
			}
		}
	}
	$dbh->do("unlock tables");
	return $authid;
}


sub AUTHaddsubfield {
# Add a new subfield to a tag into the DB.
	my ($dbh,$authid,$tagid,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalues) = @_;
	# if not value, end of job, we do nothing
	if (length($subfieldvalues) ==0) {
		return;
	}
	if (not($subfieldcode)) {
		$subfieldcode=' ';
	}
	my @subfieldvalues = split /\|/,$subfieldvalues;
	foreach my $subfieldvalue (@subfieldvalues) {
		my $sth=$dbh->prepare("insert into auth_subfield_table (authid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?,?)");
		$sth->execute($authid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue);
		if ($sth->errstr) {
			warn "ERROR ==> insert into auth_subfield_table (authid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($authid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
		}
		&AUTHaddword($dbh,$authid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	}
}

sub AUTHgetauthority {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$authid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
	$record->leader('                        ');
    my $sth=$dbh->prepare("select authid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from auth_subfield_table
		 		 where authid=? order by tag,tagorder,subfieldcode
		 	 ");
	$sth->execute($authid);
	my $prevtagorder=1;
	my $prevtag='XXX';
	my $previndicator;
	my $field; # for >=10 tags
	my $prevvalue; # for <10 tags
	while (my $row=$sth->fetchrow_hashref) {
		if ($row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag) {
			$previndicator.="  ";
			if ($prevtag <10) {
 			$record->add_fields((sprintf "%03s",$prevtag),$prevvalue) unless $prevtag eq "XXX"; # ignore the 1st loop
			} else {
				$record->add_fields($field) unless $prevtag eq "XXX";
			}
			undef $field;
			$prevtagorder=$row->{tagorder};
			$prevtag = $row->{tag};
			$previndicator=$row->{tag_indicator};
			if ($row->{tag}<10) {
				$prevvalue = $row->{subfieldvalue};
			} else {
				$field = MARC::Field->new((sprintf "%03s",$prevtag), substr($row->{tag_indicator}.'  ',0,1), substr($row->{tag_indicator}.'  ',1,1), $row->{'subfieldcode'}, $row->{'subfieldvalue'} );
			}
		} else {
			if ($row->{tag} <10) {
 				$record->add_fields((sprintf "%03s",$row->{tag}), $row->{'subfieldvalue'});
 			} else {
				$field->add_subfields($row->{'subfieldcode'}, $row->{'subfieldvalue'} );
 			}
 			$prevtag= $row->{tag};
			$previndicator=$row->{tag_indicator};
		}
	}
	# the last has not been included inside the loop... do it now !
	if ($prevtag ne "XXX") { # check that we have found something. Otherwise, prevtag is still XXX and we
						# must return an empty record, not make MARC::Record fail because we try to
						# create a record with XXX as field :-(
		if ($prevtag <10) {
			$record->add_fields($prevtag,$prevvalue);
		} else {
	#  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
			$record->add_fields($field);
		}
	}
	return $record;
}

sub AUTHmodauthority {
	my ($dbh,$authid,$record,$delete)=@_;
	my $oldrecord=&AUTHgetauthority($dbh,$authid);
	if ($oldrecord eq $record) {
		return;
	}
# 1st delete the authority,
# 2nd recreate it
	&AUTHdelauthority($dbh,$authid,1);
	&AUTHaddauthority($dbh,$record,$authid);
	# FIXME : modify the authority in biblio too.
}

sub AUTHdelauthority {
	my ($dbh,$authid,$keep_biblio) = @_;
# if the keep_biblio is set to 1, then authority entries in biblio are preserved.
# This flag is set when the delauthority is called by modauthority
# due to a too complex structure of MARC (repeatable fields and subfields),
# the best solution for a modif is to delete / recreate the record.

	my $record = AUTHgetauthority($dbh,$authid);
	$dbh->do("delete from auth_biblio where authid=$authid");
	$dbh->do("delete from auth_subfield_table where authid=$authid");
	$dbh->do("delete from auth_word where authid=$authid");
# FIXME : delete or not in biblio tables (depending on $keep_biblio flag)
}

sub AUTHmodsubfield {
# Subroutine changes a subfield value given a subfieldid.
	my ($dbh, $subfieldid, $subfieldvalue )=@_;
	$dbh->do("lock tables auth_subfield_table WRITE");
	my $sth=$dbh->prepare("update auth_subfield_table set subfieldvalue=? where subfieldid=?");
	$sth->execute($subfieldvalue, $subfieldid);
	$dbh->do("unlock tables");
	$sth->finish;
	$sth=$dbh->prepare("select authid,tag,tagorder,subfieldcode,subfieldid,subfieldorder from auth_subfield_table where subfieldid=?");
	$sth->execute($subfieldid);
	my ($authid,$tagid,$tagorder,$subfieldcode,$x,$subfieldorder) = $sth->fetchrow;
	$subfieldid=$x;
	&AUTHdelword($dbh,$authid,$tagid,$tagorder,$subfieldcode,$subfieldorder);
	&AUTHaddword($dbh,$authid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	return($subfieldid, $subfieldvalue);
}

sub AUTHfindsubfield {
    my ($dbh,$authid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue) = @_;
    my $resultcounter=0;
    my $subfieldid;
    my $lastsubfieldid;
    my $query="select subfieldid from auth_subfield_table where authid=? and tag=? and subfieldcode=?";
    my @bind_values = ($authid,$tag, $subfieldcode);
    if ($subfieldvalue) {
	$query .= " and subfieldvalue=?";
	push(@bind_values,$subfieldvalue);
    } else {
	if ($subfieldorder<1) {
	    $subfieldorder=1;
	}
	$query .= " and subfieldorder=?";
	push(@bind_values,$subfieldorder);
    }
    my $sti=$dbh->prepare($query);
    $sti->execute(@bind_values);
    while (($subfieldid) = $sti->fetchrow) {
	$resultcounter++;
	$lastsubfieldid=$subfieldid;
    }
    if ($resultcounter>1) {
		# Error condition.  Values given did not resolve into a unique record.  Don't know what to edit
		# should rarely occur (only if we use subfieldvalue with a value that exists twice, which is strange)
		return -1;
    } else {
		return $lastsubfieldid;
    }
}

sub AUTHfindsubfieldid {
	my ($dbh,$authid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
	my $sth=$dbh->prepare("select subfieldid from auth_subfield_table
				where authid=? and tag=? and tagorder=?
					and subfieldcode=? and subfieldorder=?");
	$sth->execute($authid,$tag,$tagorder,$subfield,$subfieldorder);
	my ($res) = $sth->fetchrow;
	unless ($res) {
		$sth=$dbh->prepare("select subfieldid from auth_subfield_table
				where authid=? and tag=? and tagorder=?
					and subfieldcode=?");
		$sth->execute($authid,$tag,$tagorder,$subfield);
		($res) = $sth->fetchrow;
	}
    return $res;
}

sub AUTHfind_authtypecode {
	my ($dbh,$authid) = @_;
	my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
	$sth->execute($authid);
	my ($authtypecode) = $sth->fetchrow;
	return $authtypecode;
}

sub AUTHdelsubfield {
# delete a subfield for $authid / tag / tagorder / subfield / subfieldorder
    my ($dbh,$authid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    $dbh->do("delete from auth_subfield_table where authid='$authid' and
			tag='$tag' and tagorder='$tagorder'
			and subfieldcode='$subfield' and subfieldorder='$subfieldorder'
			");
}

sub AUTHhtml2marc {
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
# 	my %subfieldlist=();
	my $prevvalue; # if tag <10
	my $field; # if tag >=10
	for (my $i=0; $i< @$rtags; $i++) {
		# rebuild MARC::Record
		if (@$rtags[$i] ne $prevtag) {
			if ($prevtag < 10) {
				if ($prevvalue) {
					$record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
				}
			} else {
				if ($field) {
					$record->add_fields($field);
				}
			}
			$indicators{@$rtags[$i]}.='  ';
			if (@$rtags[$i] <10) {
				$prevvalue= @$rvalues[$i];
			} else {
				$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (@$rvalues[$i]) {
					$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
				}
			}
			$prevtag= @$rtags[$i];
		}
	}
	# the last has not been included inside the loop... do it now !
	$record->add_fields($field);
# 	warn $record->as_formatted;
	return $record;
}

sub AUTHaddword {
# split a subfield string and adds it into the word table.
# removes stopwords
    my ($dbh,$authid,$tag,$tagorder,$subfieldid,$subfieldorder,$sentence) =@_;
    $sentence =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
    my @words = split / /,$sentence;
    my $stopwords= C4::Context->stopwords;
    my $sth=$dbh->prepare("insert into auth_word (authid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word)
			values (?,?,?,?,?,?,soundex(?))");
    foreach my $word (@words) {
# we record only words longer than 2 car and not in stopwords hash
	if (length($word)>2 and !($stopwords->{uc($word)})) {
	    $sth->execute($authid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		warn "ERROR ==> insert into auth_word (authid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word) values ($authid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,soundex($word))\n";
	    }
	}
    }
}

sub AUTHdelword {
# delete words. this sub deletes all the words from a sentence. a subfield modif is done by a delete then a add
    my ($dbh,$authid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    my $sth=$dbh->prepare("delete from auth_word where authid=? and tag=? and tagorder=? and subfieldid=? and subfieldorder=?");
    $sth->execute($authid,$tag,$tagorder,$subfield,$subfieldorder);
}

sub char_decode {
	# converts ISO 5426 coded string to ISO 8859-1
	# sloppy code : should be improved in next issue
	my ($string,$encoding) = @_ ;
	$_ = $string ;
# 	$encoding = C4::Context->preference("marcflavour") unless $encoding;
	if ($encoding eq "UNIMARC") {
		s/\xe1/Æ/gm ;
		s/\xe2/Ð/gm ;
		s/\xe9/Ø/gm ;
		s/\xec/þ/gm ;
		s/\xf1/æ/gm ;
		s/\xf3/ð/gm ;
		s/\xf9/ø/gm ;
		s/\xfb/ß/gm ;
		s/\xc1\x61/à/gm ;
		s/\xc1\x65/è/gm ;
		s/\xc1\x69/ì/gm ;
		s/\xc1\x6f/ò/gm ;
		s/\xc1\x75/ù/gm ;
		s/\xc1\x41/À/gm ;
		s/\xc1\x45/È/gm ;
		s/\xc1\x49/Ì/gm ;
		s/\xc1\x4f/Ò/gm ;
		s/\xc1\x55/Ù/gm ;
		s/\xc2\x41/Á/gm ;
		s/\xc2\x45/É/gm ;
		s/\xc2\x49/Í/gm ;
		s/\xc2\x4f/Ó/gm ;
		s/\xc2\x55/Ú/gm ;
		s/\xc2\x59/Ý/gm ;
		s/\xc2\x61/á/gm ;
		s/\xc2\x65/é/gm ;
		s/\xc2\x69/í/gm ;
		s/\xc2\x6f/ó/gm ;
		s/\xc2\x75/ú/gm ;
		s/\xc2\x79/ý/gm ;
		s/\xc3\x41/Â/gm ;
		s/\xc3\x45/Ê/gm ;
		s/\xc3\x49/Î/gm ;
		s/\xc3\x4f/Ô/gm ;
		s/\xc3\x55/Û/gm ;
		s/\xc3\x61/â/gm ;
		s/\xc3\x65/ê/gm ;
		s/\xc3\x69/î/gm ;
		s/\xc3\x6f/ô/gm ;
		s/\xc3\x75/û/gm ;
		s/\xc4\x41/Ã/gm ;
		s/\xc4\x4e/Ñ/gm ;
		s/\xc4\x4f/Õ/gm ;
		s/\xc4\x61/ã/gm ;
		s/\xc4\x6e/ñ/gm ;
		s/\xc4\x6f/õ/gm ;
		s/\xc8\x45/Ë/gm ;
		s/\xc8\x49/Ï/gm ;
		s/\xc8\x65/ë/gm ;
		s/\xc8\x69/ï/gm ;
		s/\xc8\x76/ÿ/gm ;
		s/\xc9\x41/Ä/gm ;
		s/\xc9\x4f/Ö/gm ;
		s/\xc9\x55/Ü/gm ;
		s/\xc9\x61/ä/gm ;
		s/\xc9\x6f/ö/gm ;
		s/\xc9\x75/ü/gm ;
		s/\xca\x41/Å/gm ;
		s/\xca\x61/å/gm ;
		s/\xd0\x43/Ç/gm ;
		s/\xd0\x63/ç/gm ;
		# this handles non-sorting blocks (if implementation requires this)
		$string = nsb_clean($_) ;
	} elsif ($encoding eq "USMARC" || $encoding eq "MARC21") {
		if(/[\xc1-\xff]/) {
			s/\xe1\x61/à/gm ;
			s/\xe1\x65/è/gm ;
			s/\xe1\x69/ì/gm ;
			s/\xe1\x6f/ò/gm ;
			s/\xe1\x75/ù/gm ;
			s/\xe1\x41/À/gm ;
			s/\xe1\x45/È/gm ;
			s/\xe1\x49/Ì/gm ;
			s/\xe1\x4f/Ò/gm ;
			s/\xe1\x55/Ù/gm ;
			s/\xe2\x41/Á/gm ;
			s/\xe2\x45/É/gm ;
			s/\xe2\x49/Í/gm ;
			s/\xe2\x4f/Ó/gm ;
			s/\xe2\x55/Ú/gm ;
			s/\xe2\x59/Ý/gm ;
			s/\xe2\x61/á/gm ;
			s/\xe2\x65/é/gm ;
			s/\xe2\x69/í/gm ;
			s/\xe2\x6f/ó/gm ;
			s/\xe2\x75/ú/gm ;
			s/\xe2\x79/ý/gm ;
			s/\xe3\x41/Â/gm ;
			s/\xe3\x45/Ê/gm ;
			s/\xe3\x49/Î/gm ;
			s/\xe3\x4f/Ô/gm ;
			s/\xe3\x55/Û/gm ;
			s/\xe3\x61/â/gm ;
			s/\xe3\x65/ê/gm ;
			s/\xe3\x69/î/gm ;
			s/\xe3\x6f/ô/gm ;
			s/\xe3\x75/û/gm ;
			s/\xe4\x41/Ã/gm ;
			s/\xe4\x4e/Ñ/gm ;
			s/\xe4\x4f/Õ/gm ;
			s/\xe4\x61/ã/gm ;
			s/\xe4\x6e/ñ/gm ;
			s/\xe4\x6f/õ/gm ;
			s/\xe8\x45/Ë/gm ;
			s/\xe8\x49/Ï/gm ;
			s/\xe8\x65/ë/gm ;
			s/\xe8\x69/ï/gm ;
			s/\xe8\x76/ÿ/gm ;
			s/\xe9\x41/Ä/gm ;
			s/\xe9\x4f/Ö/gm ;
			s/\xe9\x55/Ü/gm ;
			s/\xe9\x61/ä/gm ;
			s/\xe9\x6f/ö/gm ;
			s/\xe9\x75/ü/gm ;
			s/\xea\x41/Å/gm ;
			s/\xea\x61/å/gm ;
			# this handles non-sorting blocks (if implementation requires this)
			$string = nsb_clean($_) ;
		}
	}
	return($string) ;
}

sub nsb_clean {
	my $NSB = '\x88' ;		# NSB : begin Non Sorting Block
	my $NSE = '\x89' ;		# NSE : Non Sorting Block end
	# handles non sorting blocks
	my ($string) = @_ ;
	$_ = $string ;
	s/$NSB/(/gm ;
	s/[ ]{0,1}$NSE/) /gm ;
	$string = $_ ;
	return($string) ;
}

END { }       # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.1  2004/06/07 07:35:01  tipaul
# MARC authority management package
#
