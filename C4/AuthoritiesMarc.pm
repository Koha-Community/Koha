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
use C4::Koha;
use MARC::Record;
use C4::Biblio;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	&AUTHgettagslib
	&AUTHfindsubfield
	&AUTHfind_authtypecode

	&AUTHaddauthority
	&AUTHmodauthority
	&AUTHdelauthority
	&AUTHaddsubfield
	&AUTHgetauthority
	
	&AUTHgetauth_type
	&AUTHcount_usage
	
	&authoritysearch
	
	&MARCmodsubfield
	&AUTHhtml2marc &AUTHhtml2xml
	&AUTHaddword
	&MARCaddword &MARCdelword
	&char_decode
	&FindDuplicate
	&BuildSummary
	&BuildUnimarcHierarchies
	&BuildUnimarcHierarchy
    &AUTHsavetrees
    &AUTHgetheader
 );

sub authoritysearch {
	my ($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode) = @_;
	# build the sql request. She will look like :
	# select m1.bibid
	#		from auth_subfield_table as m1, auth_subfield_table as m2
	#		where m1.authid=m2.authid and
	#		(m1.subfieldvalue like "Des%" and m2.subfieldvalue like "27%")

	# the marclist may contain "mainentry". In this case, search the tag_to_report, that depends on
	# the authtypecode. Then, search on $a of this tag_to_report
	# also store main entry MARC tag, to extract it at end of search
	my $mainentrytag;
	my $sth;
    if ($authtypecode){
      $sth= $dbh->prepare('select auth_tag_to_report from auth_types where authtypecode=?');
      $sth->execute($authtypecode);
    }else{
      $sth= $dbh->prepare('select auth_tag_to_report from auth_types');
      $sth->execute;
    }
	my ($tag_to_report) = $sth->fetchrow;
	$mainentrytag = $tag_to_report;
	for (my $i=0;$i<$#{$tags};$i++) {
		if (@$tags[$i] eq "mainentry") {
			@$tags[$i] = $tag_to_report."a";
		}
	}

	# "Normal" statements
	# quote marc fields/subfields
	for (my $i=0;$i<=$#{$tags};$i++) {
		if (@$tags[$i]) {
			@$tags[$i] = $dbh->quote(@$tags[$i]);
		}
	}
	my @normal_tags = ();
	my @normal_and_or = ();
	my @normal_operator = ();
	my @normal_value = ();
	# Extracts the NOT statements from the list of statements
	for(my $i = 0 ; $i <= $#{$value} ; $i++)
	{
		# replace * by %
		@$value[$i] =~ s/\*/%/g;
		# remove % at the beginning
		@$value[$i] =~ s/^%//g;
	    @$value[$i] =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g if @$operator[$i] eq "contains";
		if(@$operator[$i] eq "contains") # if operator is contains, splits the words in separate requests
		{
			foreach my $word (split(/ /, @$value[$i]))
			{
				unless (C4::Context->stopwords->{uc($word)}) {	#it's NOT a stopword => use it. Otherwise, ignore
					my $tag = substr(@$tags[$i],0,3);
					my $subf = substr(@$tags[$i],3,1);
					push @normal_tags, @$tags[$i];
					push @normal_and_or, "and";	# assumes "foo" and "bar" if "foo bar" is entered
					push @normal_operator, @$operator[$i];
					push @normal_value, $word;
				}
			}
		}
		else
		{
			push @normal_tags, @$tags[$i];
			push @normal_and_or, @$and_or[$i];
			push @normal_operator, @$operator[$i];
			push @normal_value, @$value[$i];
		}
	}

	# Finds the basic results without the NOT requests
	my ($sql_tables, $sql_where1, $sql_where2) = create_request($dbh,\@normal_tags, \@normal_and_or, \@normal_operator, \@normal_value);

	my $sth;

	if ($authtypecode){
      if ($sql_where2) {
          $sth = $dbh->prepare("select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and auth_header.authtypecode=? and $sql_where2 and ($sql_where1)");
          warn "Q2 : select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and auth_header.authtypecode=? and $sql_where2 and ($sql_where1)";
      } else {
          $sth = $dbh->prepare("select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and auth_header.authtypecode=? and $sql_where1");
          warn "Q : select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and auth_header.authtypecode=? and $sql_where1";
      }
      $sth->execute("$authtypecode");
    } else {
      if ($sql_where2) {
          $sth = $dbh->prepare("select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and $sql_where2 and ($sql_where1)");
          warn "Q2 : select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid  and $sql_where2 and ($sql_where1)";
      } else {
          $sth = $dbh->prepare("select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and $sql_where1");
          warn "Q : select distinct m1.authid from auth_header,$sql_tables where  m1.authid=auth_header.authid and $sql_where1";
      }
      $sth->execute;
    }
	my @result = ();
	while (my ($authid) = $sth->fetchrow) {
			push @result,$authid;
		}
	# we have authid list. Now, loads summary from [offset] to [offset]+[length]
# 	my $counter = $offset;
	my @finalresult = ();
	my $oldline;
# 	while (($counter <= $#result) && ($counter <= ($offset + $length))) {
	# retrieve everything
	for (my $counter=0;$counter <=$#result;$counter++) {
# 		warn " HERE : $counter, $#result, $offset, $length";
		# get MARC::Record of the authority
		my $record = AUTHgetauthority($dbh,$result[$counter]);
		# then build the summary
		#FIXME: all of this should be moved to the template eventually
		my $authtypecode = AUTHfind_authtypecode($dbh,$result[$counter]);
		my $authref = getauthtype($authtypecode);
		my $authtype =$authref->{authtypetext};
		my $summary = $authref->{summary};
        my $query_auth_tag = "SELECT auth_tag_to_report FROM auth_types WHERE authtypecode=?";
        my $sth = $dbh->prepare($query_auth_tag);
        $sth->execute($authtypecode);
        my $auth_tag_to_report = $sth->fetchrow;
		# find biblio MARC field using this authtypecode (to jump to biblio)
		my $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
		$sth->execute($authtypecode);
		my $tags_using_authtype;
		while (my ($tagfield) = $sth->fetchrow) {
# 			warn "TAG : $tagfield";
			$tags_using_authtype.= $tagfield."9,";
		}
		chop $tags_using_authtype;
		my $reported_tag;
		# if the library has a summary defined, use it. Otherwise, build a standard one
		if ($summary) {
			my @fields = $record->fields();
            $reported_tag = '$9'.$result[$counter];
			foreach my $field (@fields) {
				my $tag = $field->tag();
				my $tagvalue = $field->as_string();
				$summary =~ s/\[(.?.?.?.?)$tag\*(.*?)]/$1$tagvalue$2\[$1$tag$2]/g;
				if ($tag<10) {
                    if ($tag eq '001') {
                        $reported_tag.='$3'.$field->data();
                    }

				} else {
					my @subf = $field->subfields;
					for my $i (0..$#subf) {
						my $subfieldcode = $subf[$i][0];
						my $subfieldvalue = $subf[$i][1];
						my $tagsubf = $tag.$subfieldcode;
						$summary =~ s/\[(.?.?.?.?)$tagsubf(.*?)]/$1$subfieldvalue$2\[$1$tagsubf$2]/g;
                        if ($tag eq $auth_tag_to_report) {
                            $reported_tag.='$'.$subfieldcode.$subfieldvalue;
                        }

					}
				}
			}
			$summary =~ s/\[(.*?)]//g;
			$summary =~ s/\n/<br>/g;
		} else {
			my $heading; # = $authref->{summary};
			my $altheading;
			my $seeheading;
			my $see;
			my @fields = $record->fields();
			if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
			# construct UNIMARC summary, that is quite different from MARC21 one
				# accepted form
				foreach my $field ($record->field('2..')) {
					$heading.= $field->as_string();
				}
				# rejected form(s)
				foreach my $field ($record->field('4..')) {
					$summary.= "&nbsp;&nbsp;&nbsp;<i>".$field->as_string()."</i><br/>";
					$summary.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$heading."<br/>";
				}
				# see :
				foreach my $field ($record->field('5..')) {
					$summary.= "&nbsp;&nbsp;&nbsp;<i>".$field->as_string()."</i><br/>";
					$summary.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$heading."<br/>";
				}
				# // form
				foreach my $field ($record->field('7..')) {
					$seeheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$field->as_string()."<br />";	
					$altheading.= "&nbsp;&nbsp;&nbsp;".$field->as_string()."<br />";
					$altheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$heading."<br />";
				}
				$summary = "<b>".$heading."</b><br />".$seeheading.$altheading.$summary;	
			} else {
			# construct MARC21 summary
				foreach my $field ($record->field('1..')) {
					if ($record->field('100')) {
						$heading.= $field->as_string('abcdefghjklmnopqrstvxyz68');
					} elsif ($record->field('110')) {
	                                        $heading.= $field->as_string('abcdefghklmnoprstvxyz68');
					} elsif ($record->field('111')) {
	                                        $heading.= $field->as_string('acdefghklnpqstvxyz68');
					} elsif ($record->field('130')) {
	                                        $heading.= $field->as_string('adfghklmnoprstvxyz68');
					} elsif ($record->field('148')) {
	                                        $heading.= $field->as_string('abvxyz68');
					} elsif ($record->field('150')) {
											$heading.= $field->as_string('abvxyz68');	
					} elsif ($record->field('151')) {
	                                        $heading.= $field->as_string('avxyz68');
					} elsif ($record->field('155')) {
	                                        $heading.= $field->as_string('abvxyz68');
					} elsif ($record->field('180')) {
	                                        $heading.= $field->as_string('vxyz68');
					} elsif ($record->field('181')) {
	                                        $heading.= $field->as_string('vxyz68');
					} elsif ($record->field('182')) {
	                                        $heading.= $field->as_string('vxyz68');
					} elsif ($record->field('185')) {
	                                        $heading.= $field->as_string('vxyz68');
					} else {
						$heading.= $field->as_string();
					}
				} #See From
				foreach my $field ($record->field('4..')) {
					$seeheading.= "&nbsp;&nbsp;&nbsp;".$field->as_string()."<br />";
					$seeheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$seeheading."<br />";	
				} #See Also
				foreach my $field ($record->field('5..')) {
					$altheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$field->as_string()."<br />";	
					$altheading.= "&nbsp;&nbsp;&nbsp;".$field->as_string()."<br />";
					$altheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$altheading."<br />";
				}
				$summary.=$heading.$seeheading.$altheading;
			}
		}
		# then add a line for the template loop
		my %newline;
		$newline{summary} = $summary;
		$newline{authtype} = $authtype;
		$newline{reported_tag} = $reported_tag;
		$newline{authid} = $result[$counter];
		$newline{used} = &AUTHcount_usage($result[$counter]);
		$newline{biblio_fields} = $tags_using_authtype;
		$newline{even} = $counter % 2;
		$newline{mainentry} = $record->field($mainentrytag)->subfield('a')." ".$record->field($mainentrytag)->subfield('b') if $record->field($mainentrytag);
		push @finalresult, \%newline;
	}
	# sort everything
	my @finalresult3= sort {$a->{summary} cmp $b->{summary}} @finalresult;
	# cut from $offset to $offset+$length;
	my @finalresult2;
	for (my $i=$offset;$i<=$offset+$length;$i++) {
		push @finalresult2,$finalresult3[$i] if $finalresult3[$i];
	}
	my $nbresults = $#result + 1;

	return (\@finalresult2, $nbresults);
}

# Creates the SQL Request

sub create_request {
	my ($dbh,$tags, $and_or, $operator, $value) = @_;

	my $sql_tables; # will contain marc_subfield_table as m1,...
	my $sql_where1; # will contain the "true" where
	my $sql_where2 = "("; # will contain m1.authid=m2.authid
	my $nb_active=0; # will contain the number of "active" entries. and entry is active is a value is provided.
	my $nb_table=1; # will contain the number of table. ++ on each entry EXCEPT when an OR  is provided.


	for(my $i=0; $i<=@$value;$i++) {
		if (@$value[$i]) {
			$nb_active++;
			if ($nb_active==1) {
				if (@$operator[$i] eq "start") {
					$sql_tables .= "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue like ".$dbh->quote("@$value[$i]%");
					if (@$tags[$i]) {
						$sql_where1 .=" and concat(m1.tag,m1.subfieldcode) in (@$tags[$i])";
					}
					$sql_where1.=")";
				} elsif (@$operator[$i] eq "contains") {	
				$sql_tables .= "auth_word as m$nb_table,";
					$sql_where1 .= "(m1.word  like ".$dbh->quote("@$value[$i]%");
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tagsubfield in (@$tags[$i])";
					}
					$sql_where1.=")";
				} else {

					$sql_tables .= "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue @$operator[$i] ".$dbh->quote("@$value[$i]");
					if (@$tags[$i]) {
						 $sql_where1 .=" and concat(m1.tag,m1.subfieldcode) in (@$tags[$i])";
					}
					$sql_where1.=")";
				}
			} else {
				if (@$operator[$i] eq "start") {
					$nb_table++;
					$sql_tables .= "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue like ".$dbh->quote("@$value[$i]%");
					if (@$tags[$i]) {
					 	$sql_where1 .=" and concat(m$nb_table.tag,m$nb_table.subfieldcode) in (@$tags[$i])";
					}
					$sql_where1.=")";
					$sql_where2 .= "m1.authid=m$nb_table.authid and ";
				} elsif (@$operator[$i] eq "contains") {
					if (@$and_or[$i] eq 'and') {
						$nb_table++;
						$sql_tables .= "auth_word as m$nb_table,";
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like ".$dbh->quote("@$value[$i]%");
						if (@$tags[$i]) {
							$sql_where1 .=" and m$nb_table.tagsubfield in(@$tags[$i])";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.authid=m$nb_table.authid and ";
					} else {
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like ".$dbh->quote("@$value[$i]%");
						if (@$tags[$i]) {
							$sql_where1 .="  and concat(m$nb_table.tag,m$nb_table.subfieldid) in (@$tags[$i])";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.authid=m$nb_table.authid and ";
					}
				} else {
					$nb_table++;
					$sql_tables .= "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue @$operator[$i] ".$dbh->quote(@$value[$i]);
					if (@$tags[$i]) {
					 	$sql_where1 .="  and concat(m$nb_table.tag,m$nb_table.subfieldcode) in (@$tags[$i])";
					}
					$sql_where2 .= "m1.authid=m$nb_table.authid and ";
					$sql_where1.=")";
				}
			}
		}
	}

	if($sql_where2 ne "(")	# some datas added to sql_where2, processing
	{
		$sql_where2 = substr($sql_where2, 0, (length($sql_where2)-5)); # deletes the trailing ' and '
		$sql_where2 .= ")";
	}
	else	# no sql_where2 statement, deleting '('
	{
		$sql_where2 = "";
	}
	chop $sql_tables;	# deletes the trailing ','
	
	return ($sql_tables, $sql_where1, $sql_where2);
}


sub AUTHcount_usage {
	my ($authid) = @_;
	my $dbh = C4::Context->dbh;
	# find MARC fields using this authtype
	my $authtypecode = AUTHfind_authtypecode($dbh,$authid);
	my $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
	$sth->execute($authtypecode);
	my $tags_using_authtype;
	while (my ($tagfield) = $sth->fetchrow) {
# 		warn "TAG : $tagfield";
		$tags_using_authtype.= "'".$tagfield."9',";
	}
	chop $tags_using_authtype;
	if ($tags_using_authtype) {
		$sth = $dbh->prepare("select count(*) from marc_subfield_table where concat(tag,subfieldcode) in ($tags_using_authtype) and subfieldvalue=?");
# 	} else {
# 		$sth = $dbh->prepare("select count(*) from marc_subfield_table where subfieldvalue=?");
	}
# 	warn "Q : select count(*) from marc_subfield_table where concat(tag,subfieldcode) in ($tags_using_authtype) and subfieldvalue=$authid";
	$sth->execute($authid);
	my ($result) = $sth->fetchrow;
# 	warn "Authority $authid TOTAL USED : $result";
	return $result;
}

# merging 2 authority entries. After a merge, the "from" can be deleted.
# sub AUTHmerge {
# 	my ($auth_merge_from,$auth_merge_to) = @_;
# 	my $dbh = C4::Context->dbh;
# 	# find MARC fields using this authtype
# 	my $authtypecode = AUTHfind_authtypecode($dbh,$authid);
# 	# retrieve records
# 	my $record_from = AUTHgetauthority($dbh,$auth_merge_from);
# 	my $record_to = AUTHgetauthority($dbh,$auth_merge_to);
# 	my $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
# 	$sth->execute($authtypecode);
# 	my $tags_using_authtype;
# 	while (my ($tagfield) = $sth->fetchrow) {
# 		warn "TAG : $tagfield";
# 		$tags_using_authtype.= "'".$tagfield."9',";
# 	}
# 	chop $tags_using_authtype;
# 	# now, find every biblio using this authority
# 	$sth = $dbh->prepare("select bibid,tag,tag_indicator,tagorder from marc_subfield_table where tag+subfieldid in ($tags_using_authtype) and subfieldvalue=?");
# 	$sth->execute($authid);
# 	# and delete entries before recreating them
# 	while (my ($bibid,$tag,$tag_indicator,$tagorder) = $sth->fetchrow) {
# 		&MARCdelsubfield($dbh,$bibid,$tag);
# 		
# 	}
# 
# }

sub AUTHfind_authtypecode {
	my ($dbh,$authid) = @_;
	my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
	$sth->execute($authid);
	my ($authtypecode) = $sth->fetchrow;
	return $authtypecode;
}
 

sub AUTHgettagslib {
	my ($dbh,$forlibrarian,$authtypecode)= @_;
	$authtypecode="" unless $authtypecode;
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
# adding main table, and retrieving authid
# if authid is sent, then it's not a true add, it's only a re-add, after a delete (ie, a mod)
#  In fact, it could still be a true add, in the case of a bulkauthimort for instance with previously
#  existing authids in the records. I've adjusted below to account for this instance --JF.
	if ($authid) {
		$dbh->do("lock tables auth_header WRITE,auth_subfield_table WRITE, auth_word WRITE, stopwords READ");
		my $sth=$dbh->prepare("insert into auth_header (authid,datecreated,authtypecode) values (?,now(),?)");
		$sth->execute($authid,$authtypecode);
		$sth->finish;
# if authid empty => true add, find a new authid number
	} else {
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
			my $subfieldorder;
			foreach my $subfield (@subfields) {
				foreach (split /\|/,@$subfield[1]) {
					$subfieldorder++;
					&AUTHaddsubfield($dbh,$authid,
							$field->tag(),
							$field->indicator(1).$field->indicator(2),
							$fieldcount,
							@$subfield[0],
							$subfieldorder,
							$_
							);
				}
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
# 		warn "==> $authid,".(sprintf "%03s",$tagid).",TAG : $tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue";
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
    my $sth=$dbh->prepare("select authid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue
		 		 from auth_subfield_table
		 		 where authid=? order by tag,tagorder,subfieldorder
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

sub AUTHgetauth_type {
	my ($authtypecode) = @_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select * from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	return $sth->fetchrow_hashref;
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
	&AUTHaddauthority($dbh,$record,$authid,AUTHfind_authtypecode($dbh,$authid));
	# save the file in localfile/modified_authorities
	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
	unless (opendir(DIR, "$cgidir")) {
			$cgidir = C4::Context->intranetdir."/";
	} 

	my $filename = $cgidir."/localfile/modified_authorities/$authid.authid";
	open AUTH, "> $filename";
	print AUTH $authid;
	close AUTH;
}

sub AUTHdelauthority {
	my ($dbh,$authid,$keep_biblio) = @_;
# if the keep_biblio is set to 1, then authority entries in biblio are preserved.
# This flag is set when the delauthority is called by modauthority
# due to a too complex structure of MARC (repeatable fields and subfields),
# the best solution for a modif is to delete / recreate the record.

	my $record = AUTHgetauthority($dbh,$authid);
	$dbh->do("delete from auth_header where authid=$authid") unless $keep_biblio;
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

sub AUTHhtml2xml {
        my ($tags,$subfields,$values,$indicator,$ind_tag) = @_;
        use MARC::File::XML;
        my $xml= MARC::File::XML::header();
        my $prevvalue;
        my $prevtag=-1;
        my $first=1;
        my $j = -1;
        for (my $i=0;$i<=@$tags;$i++){

            if ((@$tags[$i] ne $prevtag)){
                $j++ unless (@$tags[$i] eq "");
                warn "IND:".substr(@$indicator[$j],0,1).substr(@$indicator[$j],1,1)." ".@$tags[$i];

                if (!$first){
                    $xml.="</datafield>\n";
                    $first=1;
                }
                else {
                    if (@$values[$i] ne "") {
                    # leader
                    if (@$tags[$i] eq "000") {
                        $xml.="<leader>@$values[$i]</leader>\n";
                        $first=1;
                        # rest of the fixed fields
                    } elsif (@$tags[$i] < 10) {
                        $xml.="<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
                        $first=1;
                    }
                    else {
                        my $ind1 = substr(@$indicator[$j],0,1);
                        my $ind2 = substr(@$indicator[$j],1,1);
                        $xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first=0;
                    }
                    }
                }
            } else {
                if (@$values[$i] eq "") {
                }
                else {
                if ($first){
                my $ind1 = substr(@$indicator[$j],0,1);
                my $ind2 = substr(@$indicator[$j],1,1);
                $xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                $first=0;
                }
                    $xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";

                }
            }
            $prevtag = @$tags[$i];
        }
        $xml.= MARC::File::XML::footer();
        warn $xml;
        return $xml
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
				undef $field;
			} else {
				undef $prevvalue;
				$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (length(@$rvalues[$i])>0) {
					$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
				}
			}
			$prevtag= @$rtags[$i];
		}
	}
	# the last has not been included inside the loop... do it now !
	$record->add_fields($field) if $field;
	return $record;
}

sub AUTHaddword {
# split a subfield string and adds it into the word table.
# removes stopwords
    my ($dbh,$authid,$tag,$tagorder,$subfieldid,$subfieldorder,$sentence) =@_;
    $sentence =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
    my @words = split / /,$sentence;
    my $stopwords= C4::Context->stopwords;
    my $sth=$dbh->prepare("insert into auth_word (authid, tagsubfield, tagorder, subfieldorder, word, sndx_word)
			values (?,concat(?,?),?,?,?,soundex(?))");
    foreach my $word (@words) {
# we record only words longer than 2 car and not in stopwords hash
	if (length($word)>2 and !($stopwords->{uc($word)})) {
	    $sth->execute($authid,$tag,$subfieldid,$tagorder,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		warn "ERROR ==> insert into auth_word (authid, tagsubfield, tagorder, subfieldorder, word, sndx_word) values ($authid,concat($tag,$subfieldid),$tagorder,$subfieldorder,$word,soundex($word))\n";
	    }
	}
    }
}

sub AUTHdelword {
# delete words. this sub deletes all the words from a sentence. a subfield modif is done by a delete then a add
    my ($dbh,$authid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    my $sth=$dbh->prepare("delete from auth_word where authid=? and tagsubfield=concat(?,?) and tagorder=? and subfieldorder=?");
    $sth->execute($authid,$tag,$subfield,$tagorder,$subfieldorder);
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

sub FindDuplicate {
	my ($record,$authtypecode)=@_;
	warn "IN for ".$record->as_formatted;
	my $dbh = C4::Context->dbh;

#	warn "".$record->as_formatted;
	my $sth = $dbh->prepare("select auth_tag_to_report,summary from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	my ($auth_tag_to_report,$taglist) = $sth->fetchrow;
	$sth->finish;
	# build a request for authoritysearch
	my (@tags, @and_or, @excluding, @operator, @value, $offset, $length);
	# search on biblio.title
#	warn " tag a reporter : $auth_tag_to_report";
# 	warn "taglist ".$taglist;
	my @subfield = split /\[/,  $taglist;
	my $max = @subfield;
	for (my $i=1; $i<$max;$i++){
		warn " ".$subfield[$i];
		$subfield[$i]=substr($subfield[$i],3,1);
# 		warn " ".$subfield[$i];
	}
	
	if ($record->fields($auth_tag_to_report)) {
		my $sth = $dbh->prepare("select tagfield,tagsubfield from auth_subfield_structure where tagfield=? and authtypecode=? ");
		$sth->execute($auth_tag_to_report,$authtypecode);
#		warn " field $auth_tag_to_report exists";
		while (my ($tag,$subfield) = $sth->fetchrow){
			if ($record->field($tag)->subfield($subfield)) {
				warn "tag :".$tag." subfield: $subfield value : ".$record->field($tag)->subfield($subfield);
				push @tags, $tag.$subfield;
#				warn "'".$tag.$subfield."' value :". $record->field($tag)->subfield($subfield);
				push @and_or, "and";
				push @excluding, "";
				push @operator, "=";
				push @value, $record->field($tag)->subfield($subfield);
			}
		}
 	}
 
	my ($finalresult,$nbresult) = authoritysearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10,$authtypecode);
	# there is at least 1 result => return the 1st one
	if ($nbresult) {
		warn "XXXXX $nbresult => ".@$finalresult[0]->{authid},@$finalresult[0]->{summary};
		return @$finalresult[0]->{authid},@$finalresult[0]->{summary};
	}
	# no result, returns nothing
	return;
}

sub BuildSummary{
	my $record = shift @_;
	my $summary = shift @_;
    ##TODO : use langages from authorised_values
    ## AND Thesaurii from auth_types
	my %language;
	$language{'fre'}="Français";
	$language{'eng'}="Anglais";
	$language{'ger'}="Allemand";
	$language{'ita'}="Italien";
	$language{'spa'}="Espagnol";
	my %thesaurus;
	$thesaurus{'1'}="Peuples";
	$thesaurus{'2'}="Anthroponymes";
	$thesaurus{'3'}="Oeuvres";
	$thesaurus{'4'}="Chronologie";
	$thesaurus{'5'}="Lieux";
	$thesaurus{'6'}="Sujets";
	#thesaurus a remplir
	if ($summary) {
		my @fields = $record->fields();
		foreach my $field (@fields) {
			my $tag = $field->tag();
			my $tagvalue = $field->as_string();
			$summary =~ s/\[(.?.?.?.?)$tag\*(.*?)]/$1$tagvalue$2\[$1$tag$2]/g;
			if ($tag<10) {
			} else {
				my @subf = $field->subfields;
				for my $i (0..$#subf) {
					my $subfieldcode = $subf[$i][0];
					my $subfieldvalue = $subf[$i][1];
					my $tagsubf = $tag.$subfieldcode;
					$summary =~ s/\[(.?.?.?.?)$tagsubf(.*?)]/$1$subfieldvalue$2\[$1$tagsubf$2]/g;
				}
			}
		}
		$summary =~ s/\[(.*?)]//g;
		$summary =~ s/\n/<br>/g;
	} else {
		my $heading; 
		my $authid; 
		my $altheading;
		my $seealso;
		my $broaderterms;
		my $narrowerterms;
		my $see;
		my $seeheading;
        my $notes;
		my @fields = $record->fields();
		if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
		# construct UNIMARC summary, that is quite different from MARC21 one
			# accepted form
			foreach my $field ($record->field('2..')) {
				$heading.= $field->subfield('a');
                $authid=$field->subfield('3');
			}
			# rejected form(s)
			foreach my $field ($record->field('3..')) {
			  $notes.= '<span class="note">'.$field->subfield('a')."</span>\n";
			}
			foreach my $field ($record->field('4..')) {
			  my $thesaurus = "thes. : ".$thesaurus{"$field->subfield('2')"}." : " if ($field->subfield('2'));
			  $see.= '<span class="UF">'.$thesaurus.$field->subfield('a')."</span> -- \n";
			}
			# see :
			foreach my $field ($record->field('5..')) {
		        
				if (($field->subfield('5')) && ($field->subfield('a')) && ($field->subfield('5') eq 'g')) {
				  $broaderterms.= '<span class="BT"> <a href="detail.pl?authid='.$field->subfield('3').'">'.$field->subfield('a')."</a></span> -- \n";
				} elsif (($field->subfield('5')) && ($field->subfield('a')) && ($field->subfield('5') eq 'h')){
				  $narrowerterms.= '<span class="NT"><a href="detail.pl?authid='.$field->subfield('3').'">'.$field->subfield('a')."</a></span> -- \n";
				} elsif ($field->subfield('a')) {
				  $seealso.= '<span class="RT"><a href="detail.pl?authid='.$field->subfield('3').'">'.$field->subfield('a')."</a></span> -- \n";
				}
			}
			# // form
			foreach my $field ($record->field('7..')) {
				my $lang = substr($field->subfield('8'),3,3);
				$seeheading.= '<span class="langue"> En '.$language{$lang}.' : </span><span class="OT"> '.$field->subfield('a')."</span><br />\n";	
			}
            $broaderterms =~s/-- \n$//;
            $narrowerterms =~s/-- \n$//;
            $seealso =~s/-- \n$//;
            $see =~s/-- \n$//;
			$summary = "<b><a href=\"detail.pl?authid=$authid\">".$heading."</a></b><br />".($notes?"$notes <br />":"");
			$summary.= '<p><div class="label">TG : '.$broaderterms.'</div></p>' if ($broaderterms);
			$summary.= '<p><div class="label">TS : '.$narrowerterms.'</div></p>' if ($narrowerterms);
			$summary.= '<p><div class="label">TA : '.$seealso.'</div></p>' if ($seealso);
			$summary.= '<p><div class="label">EP : '.$see.'</div></p>' if ($see);
			$summary.= '<p><div class="label">'.$seeheading.'</div></p>' if ($seeheading);
		}
	}
	return $summary;
}

sub BuildUnimarcHierarchies{
  my $authid = shift @_;
#   warn "authid : $authid";
  my $force = shift @_;
  my @globalresult;
  my $dbh=C4::Context->dbh;
  my $hierarchies;
  my $data = AUTHgetheader($dbh,$authid);
  
  if ($data->{'authtrees'} and not $force){
    return $data->{'authtrees'};
  } elsif ($data->{'authtrees'}){
    $hierarchies=$data->{'authtrees'};
  } else {
    my $record = AUTHgetauthority($dbh,$authid);
    my $found;
    my ($result,$total)=authoritysearch($dbh,['5503'],['and'],'',['='],[$authid],0,100);
    if ($total){
      foreach my $parentauthid (map { $_->{'authid'} } @$result){
        my $parentrecord = AUTHgetauthority($dbh,$parentauthid);
        #checking results
        foreach my $field ($parentrecord->field('550')){
          if (($field->subfield('3')) && ($field->subfield('3') eq $authid) && ($field->subfield('5')) && ($field->subfield('5') eq 'h')) {
            my $localresult=$hierarchies;
            my $trees;
            $trees = BuildUnimarcHierarchies($parentauthid);
            my @trees;
            if ($trees=~/;/){
              @trees = split(/;/,$trees);
            } else {
              push @trees, $trees;
            }
            foreach (@trees){
              $_.= ",$authid";
            }
            @globalresult = (@globalresult,@trees);
          }
          $found=1;
        }
      }
      $hierarchies=join(";",@globalresult);
    }
    #Unless there is no ancestor, I am alone.
    $hierarchies="$authid" unless ($hierarchies);
  }
  AUTHsavetrees($authid,$hierarchies);
  return $hierarchies;
}

sub BuildUnimarcHierarchy{
	my $record = shift @_;
    my $class = shift @_;
	my $authid=$record->subfield('250','3');
    my %cell;
	my $parents=""; my $children="";
    my (@loopparents,@loopchildren);
	foreach my $field ($record->field('550')){
		if ($field->subfield('5') && $field->subfield('a')){
		  if ($field->subfield('5') eq 'h'){
            push @loopchildren, { "childauthid"=>$field->subfield('3'),"childvalue"=>$field->subfield('a')};
		  }elsif ($field->subfield('5') eq 'g'){
            push @loopparents, { "parentauthid"=>$field->subfield('3'),"parentvalue"=>$field->subfield('a')};
		  }
		# brothers could get in there with an else
		}
	}
    $cell{"ifparents"}=1 if (scalar(@loopparents)>0);
    $cell{"ifchildren"}=1 if (scalar(@loopchildren)>0);
    $cell{"loopparents"}=\@loopparents if (scalar(@loopparents)>0);
    $cell{"loopchildren"}=\@loopchildren if (scalar(@loopchildren)>0);
    $cell{"class"}=$class;
    $cell{"authid"}=$authid;
    $cell{"value"}=$record->subfield('250',"a");
	return \%cell;
}

sub AUTHgetheader{
	my $authid = shift @_;
	my $sql= "SELECT * from auth_header WHERE authid = ?";
	my $dbh=C4::Context->dbh;
	my $rq= $dbh->prepare($sql);
    $rq->execute($authid);
	my $data= $rq->fetchrow_hashref;
	return $data;
}

sub AUTHsavetrees{
	my $authid = shift @_;
	my $trees = shift @_;
	my $sql= "UPDATE IGNORE auth_header set authtrees=? WHERE authid = ?";
	my $dbh=C4::Context->dbh;
	my $rq= $dbh->prepare($sql);
    $rq->execute($trees,$authid);
}

END { }       # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.9.2.19  2006/07/31 10:15:42  hdl
# BugFixing : MARCdetail : displayin field values with ESCAPE=HTML  (in order to manage  '<''>' characters)
#
# Adding  Hierarchy display for authorities.
# Please Note That it relies on the fact that authorities id are stored in $3 of authorities notice.
# And Broader terms is supposed to be indicated by a g for 550$5 subfield, narrower term : an h for the same subfield.
#
# It CAN SURELY be generalised but only with a bunch of sytem preferences.
#
# I added the ability to do a search on ANY authtypecode.
#
# Revision 1.9.2.18  2006/07/25 12:30:51  tipaul
# adding some informations to the array that is passed as result to an authority search : mainly, the tag_to_report & the $3 information (unimarc specific)
#
# Revision 1.9.2.17  2006/04/10 20:06:15  kados
# Adding support for bulkauthimport of records where authid already exists.
# This commit should be tested with other uses of AUTHaddauthority to ensure
# it works.
#
# Revision 1.9.2.16  2006/04/03 12:52:50  tipaul
# oups, sorry kados, I had removed something you wrote for MARC21 authorities...
#
# Revision 1.9.2.15  2006/03/30 14:20:03  tipaul
# don't use + on a numeric value when you want to do a concat !!!
#
# Revision 1.9.2.14  2006/03/15 15:10:29  tipaul
# added a new feature in summary building (for an authority)
# If you enter [XXX*] ([250*] for example), the whole field will be displayed as it's saved. This will solve the problem with reordered subfields.
#
# Revision 1.9.2.13  2006/03/15 10:46:31  tipaul
# removing hardcoded link in summary of authority (on $heading) : it can be set in the template (in the # of biblios column) :
# <a href="/cgi-bin/koha/opac-search.pl?type=opac&amp;op=do_search&amp;marclist=<!-- TMPL_VAR NAME="biblio_fields" -->&amp;operator==&amp;value=<!-- TMPL_VAR NAME="authid" -->&amp;and_or=and&amp;excluding="><!-- TMPL_VAR NAME="used" --></a>  <!-- TMPL_VAR NAME="used" -->
#
# that's what I did for css templates, it work like a charm. It's better I think because when the library defines it's own summary, the hardcoded link didn't appear.
#
# Revision 1.9.2.12  2006/03/09 01:45:14  kados
# Refining list of appropriate subfields to display for the authorized
# heading.
#
# Revision 1.9.2.11  2006/03/08 15:17:09  tipaul
# fixing some UNIMARC behaviour + removing some hardcoded strings
#
# Revision 1.9.2.10  2006/03/06 19:11:55  kados
# Fixes buggy use of ISBD for summary in Authorities display. Previously,
# it was not possible to properly display repeated tags/subfields in the
# correct order. This code uses the MARC21 guidelines for display of the
# main heading, see and see also listings.
#
# Revision 1.9.2.9  2005/12/01 17:30:26  tipaul
# no need to do a search on an authority when the authority has no MARC field (like EDITORS pseudo authority)
#
# Revision 1.9.2.8  2005/10/25 12:38:59  tipaul
# * fixing bug in summary (separator before subfield was in fact after)
# * fixing bug in authority order : authorities are not ordered alphabetically instead of no order. Requires all the dataset to be retrieved, but the benefits is important !
#
# Revision 1.9.2.7  2005/08/01 15:14:50  tipaul
# minor change in summary handling (accepting 4 digits before the field)
#
# Revision 1.9.2.6  2005/06/07 10:02:00  tipaul
# porting dictionnary search from head to 2.2. there is now a ... facing titles, author & subject, to search in biblio & authorities existing values.
#
# Revision 1.9.2.5  2005/05/31 14:50:46  tipaul
# fix for authority merging. There was a bug on official installs
#
# Revision 1.9.2.4  2005/05/30 11:24:15  tipaul
# fixing a bug : when a field was repeated, the last field was also repeated. (Was due to the "empty" field in html between fields : to separate fields, in html, an empty field is automatically added. in AUTHhtml2marc, this empty field was not discarded correctly)
#
# Revision 1.9.2.3  2005/04/28 08:45:33  tipaul
# porting FindDuplicate feature for authorities from HEAD to rel_2_2, works correctly now.
#
# Revision 1.9.2.2  2005/02/28 14:03:13  tipaul
# * adding search on "main entry" (ie $a subfield) on a given authority (the "search everywhere" field is still here).
# * adding a select box to requet "contain" or "begin with" search.
# * fixing some bug in authority search (related to "main entry" search)
#
# Revision 1.9.2.1  2005/02/24 13:12:13  tipaul
# saving authority modif in a text file. This will be used soon with another script (in crontab). The script in crontab will retrieve every authorityid in the directory localfile/authorities and modify every biblio using this authority. Those modifs may be long. So they can't be done through http, because we may encounter a webserver timeout, and kill the process before end of the job.
# So, it will be done through a cron job.
# (/me agree we need some doc for command line scripts)
#
# Revision 1.9  2004/12/23 09:48:11  tipaul
# Minor changes in summary "exploding" (the 3 digits AFTER the subfield were not on the right place).
#
# Revision 1.8  2004/11/05 10:11:39  tipaul
# export auth_count_usage (bugfix)
#
# Revision 1.7  2004/09/23 16:13:00  tipaul
# Bugfix in modification
#
# Revision 1.6  2004/08/18 16:00:24  tipaul
# fixes for authorities management
#
# Revision 1.5  2004/07/05 13:37:22  doxulting
# First step for working authorities
#
# Revision 1.4  2004/06/22 11:35:37  tipaul
# removing % at the beginning of a string to avoid loooonnnngggg searchs
#
# Revision 1.3  2004/06/17 08:02:13  tipaul
# merging tag & subfield in auth_word for better perfs
#
# Revision 1.2  2004/06/10 08:29:01  tipaul
# MARC authority management (continued)
#
# Revision 1.1  2004/06/07 07:35:01  tipaul
# MARC authority management package
#
