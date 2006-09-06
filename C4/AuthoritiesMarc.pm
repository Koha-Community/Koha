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
use C4::Koha;
use Encode;
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

	&AUTHfind_marc_from_kohafield
	&AUTHgetauth_type
	&AUTHcount_usage
	&getsummary
	&authoritysearch
	&XMLgetauthority
	&XMLgetauthorityhash
	&XML_readline_withtags
	&merge
	&FindDuplicateauth
	&ZEBRAdelauthority
 );

sub AUTHfind_marc_from_kohafield {
    my ( $dbh, $kohafield,$authtypecode ) = @_;
    return 0, 0 unless $kohafield;
$authtypecode="" unless $authtypecode;
my $marcfromkohafield;
	my $sth = $dbh->prepare("select tagfield,tagsubfield from auth_subfield_structure where kohafield= ? and authtypecode=? ");
	$sth->execute($kohafield,$authtypecode);
	my ($tagfield,$tagsubfield) = $sth->fetchrow;	
	return  ($tagfield,$tagsubfield);
}
sub authoritysearch {
## This routine requires rewrite--TG
	my ($dbh, $tags, $operator, $value, $offset,$length,$authtypecode,$dictionary) = @_;
###Dictionary flag used to set what to show in summary;
	my $query;
	my $attr;
	my $server;
	my $mainentrytag;
	##first set the authtype search and may be multiple authorities( linked authorities)
	my $n=0;
	my @authtypecode;
				my @auths=split / /,$authtypecode ;
				my ($attrfield)=MARCfind_attr_from_kohafield("auth_authtypecode");
				foreach my  $auth (@auths){
				$query .=$attrfield." ".$auth." "; ##No truncation on authtype
				push @authtypecode ,$auth;
				$n++;
				}
			if ($n>1){
			 $query= "\@or ".$query;
			}
	
	my $dosearch;
	my $and;
	my $q2;
	for(my $i = 0 ; $i <= $#{$value} ; $i++)
	{

	if (@$value[$i]){
	##If mainentry search $a tag
		if (@$tags[$i] eq "mainentry") {
		 ($attr)=MARCfind_attr_from_kohafield("auth_mainentry")." ";		
		}else{
		($attr) =MARCfind_attr_from_kohafield("auth_allentry")." ";
		}
		if (@$operator[$i] eq 'phrase') {
			 $attr.="  \@attr 4=1  \@attr 5=100  \@attr 6=3 ";##Phrase, No truncation,all of subfield field must match
		
		} else {
		
			 $attr .=" \@attr 4=6  \@attr 5=1  ";## Word list, right truncated, anywhere
		}		 
	
		
		$and .=" \@and " ;
		$attr =$attr."\"".@$value[$i]."\"";
		$q2 .=$attr;
	$dosearch=1;		
	}#if value		
		
	}## value loop
##Add how many queries generated
$query= $and.$query.$q2;
#warn $query;

$offset=0 unless $offset;
my $counter = $offset;
$length=10 unless $length;
my @oAuth;
my $i;
 $oAuth[0]=C4::Context->Zconnauth("authorityserver");
my ($mainentry)=MARCfind_attr_from_kohafield("auth_mainentry");
my ($allentry)=MARCfind_attr_from_kohafield("auth_allentry");

$query="\@attr 2=102 \@or \@or ".$query." \@attr 7=1 ".$mainentry." 0 \@attr 7=1 ".$allentry." 1"; ## sort on mainfield and subfields


my $oAResult;
 $oAResult= $oAuth[0]->search_pqf($query) ; 
while (($i = ZOOM::event(\@oAuth)) != 0) {
    my $ev = $oAuth[$i-1]->last_event();
#   warn("Authority ", $i-1, ": event $ev (", ZOOM::event_str($ev), ")\n");
    last if $ev == ZOOM::Event::ZEND;
}
 my($error, $errmsg, $addinfo, $diagset) = $oAuth[0]->error_x();
    if ($error) {
	warn  "oAuth error: $errmsg ($error) $addinfo $diagset\n";
	goto NOLUCK;
    }


my $nbresults;
 $nbresults=$oAResult->size();
my $nremains=$nbresults;	
	my @result = ();
	my @finalresult = ();

if ($nbresults>0){

##Find authid and linkid fields


while (($counter < $nbresults) && ($counter < ($offset + $length))) {
##Here we have to extract MARC record and $authid from ZEBRA AUTHORITIES
my $rec=$oAResult->record($counter);
my $marcdata=$rec->raw();
my $authrecord=Encode::decode("utf8",$marcdata);
$authrecord=XML_xml2hash_onerecord($authrecord);		
my @linkids;	
my $separator=C4::Context->preference('authoritysep');
my $linksummary=" ".$separator;	
my $authid=XML_readline_onerecord($authrecord,"auth_authid","authorities");	
my @linkid=XML_readline_asarray($authrecord,"auth_linkid","authorities");##May have many linked records	
	
	foreach my $linkid (@linkid){
		my $linktype=AUTHfind_authtypecode($dbh,$linkid);
#		my $linkrecord=XMLgetauthorityhash($dbh,$linkid);
#		$linksummary.="<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href='detail.pl?authid=$linkid'>".getsummary($dbh,$linkrecord,$linkid,$linktype).".</a>".$separator;
		
 	}
my  $summary;
unless ($dictionary){
 $summary=getsummary($dbh,$authrecord,$authid,$authtypecode);
$summary="<a href='detail.pl?authid=$authid'>".$summary.".</a>";
	if ( $linksummary ne " ".$separator){
	$summary="<b>".$summary."</b>".$linksummary;
	}
}else{
 $summary=getdictsummary($dbh,$authrecord,$authid,$authtypecode);
}
my $toggle;
	if ($counter % 2) {
		$toggle="#ffffcc";
	} else {
		$toggle="white";
	}
my %newline;
	$newline{'toggle'}=$toggle;	
	$newline{summary} = $summary;
	$newline{authid} = $authid;
	$newline{linkid} = $linkid[0];
	$newline{even} = $counter % 2;
	$counter++;
	push @finalresult, \%newline;
	}## while counter


for (my $z=0; $z<$length; $z++){
		$finalresult[$z]{used}=AUTHcount_usage($finalresult[$z]{authid});
	
 }# all $z's


}## if nbresult
NOLUCK:
$oAResult->destroy();
$oAuth[0]->destroy();

	return (\@finalresult, $nbresults);
}



sub AUTHcount_usage {
	my ($authid) = @_;
### try ZOOM search here
my @oConnection;
$oConnection[0]=C4::Context->Zconn("biblioserver");
my $query;
my ($attrfield)=MARCfind_attr_from_kohafield("auth_authid");
$query= $attrfield." ".$authid;

my $oResult = $oConnection[0]->search_pqf($query);
my $event;
my $i;
   while (($i = ZOOM::event(\@oConnection)) != 0) {
	$event = $oConnection[$i-1]->last_event();
	last if $event == ZOOM::Event::ZEND;
   }# while
my $result=$oResult->size() ;
	return ($result);
}



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


	# check that authority exists
	$sth=$dbh->prepare("select count(*) from auth_tag_structure where authtypecode=?");
	$sth->execute($authtypecode);
	my ($total) = $sth->fetchrow;
	$authtypecode="" unless ($total >0);
	$sth= $dbh->prepare(
"select tagfield,liblibrarian,libopac,mandatory,repeatable from auth_tag_structure where authtypecode=? order by tagfield"
    );

$sth->execute($authtypecode);
	 my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tab}->{tab}        = "";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }
	$sth=      $dbh->prepare("select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,seealso,hidden,isurl,link from auth_subfield_structure where authtypecode=? order by tagfield,tagsubfield"
    );
	$sth->execute($authtypecode);

	 my $subfield;
    my $authorised_value;
    my $authtypecode;
    my $value_builder;
    my $kohafield;
    my $seealso;
    my $hidden;
    my $isurl;
	my $link;

    while (
        ( $tag,         $subfield,   $liblibrarian,   , $libopac,      $tab,
        $mandatory,     $repeatable, $authorised_value, $authtypecode,
        $value_builder,   $seealso,          $hidden,
        $isurl,			$link )
        = $sth->fetchrow
      )
    {
        $res->{$tag}->{$subfield}->{lib}              = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tag}->{$subfield}->{tab}              = $tab;
        $res->{$tag}->{$subfield}->{mandatory}        = $mandatory;
        $res->{$tag}->{$subfield}->{repeatable}       = $repeatable;
        $res->{$tag}->{$subfield}->{authorised_value} = $authorised_value;
        $res->{$tag}->{$subfield}->{authtypecode}     = $authtypecode;
        $res->{$tag}->{$subfield}->{value_builder}    = $value_builder;
        $res->{$tag}->{$subfield}->{seealso}          = $seealso;
        $res->{$tag}->{$subfield}->{hidden}           = $hidden;
        $res->{$tag}->{$subfield}->{isurl}            = $isurl;
        $res->{$tag}->{$subfield}->{link}            = $link;
    }
    return $res;
}

sub AUTHaddauthority {
# pass the XML hash to this function, and it will create the records in the authority table
	my ($dbh,$record,$authid,$authtypecode) = @_;
# if authid empty => true add, find a new authid number
	if (!$authid) {
	my	$sth=$dbh->prepare("select max(authid) from auth_header");
		$sth->execute;
		($authid)=$sth->fetchrow;
		$authid=$authid+1;
	}	

##Modified record may also come here use REPLACE -- bulk import comes here
XML_writeline($record,"auth_authid",$authid,"authorities");
XML_writeline($record,"auth_authtypecode",$authtypecode,"authorities");
my $xml=XML_hash2xml($record);
	my $sth=$dbh->prepare("REPLACE auth_header set marcxml=?  authid=?,authtypecode=?,datecreated=now()");
	$sth->execute($xml,$authid,$authtypecode);
	$sth->finish;
	
	
	ZEBRAop($dbh,$authid,'specialUpdate',"authorityserver");
## If the record is linked to another update the linked authorities with new authid
my @linkids=XML_readline_asarray($record,"auth_linkid","authorities");
	foreach my $linkid (@linkids){
	##Modify the record of linked 
	AUTHaddlink($dbh,$linkid,$authid);
	}
return ($authid);
}

sub AUTHaddlink{
my ($dbh,$linkid,$authid)=@_;
my $record=XMLgetauthorityhash($dbh,$linkid);
my $authtypecode=AUTHfind_authtypecode($dbh,$linkid);
#warn "adding l:$linkid,a:$authid,auth:$authtypecode";
XML_writeline($record,"auth_linkid",$authid,"authorities");
my $xml=XML_hash2xml($record);
$dbh->do("lock tables auth_header WRITE");
	my $sth=$dbh->prepare("update auth_header set marcxml=? where authid=?");
	$sth->execute($xml,$linkid);
	$sth->finish;	
	$dbh->do("unlock tables");
	ZEBRAop($dbh,$linkid,'specialUpdate',"authorityserver");
}



sub XMLgetauthority {
    # Returns MARC::XML of the authority passed in parameter.
    my ( $dbh, $authid ) = @_;
    my $sth =  $dbh->prepare("select marcxml from auth_header where authid=? "  );
    $sth->execute($authid);
 my ($marcxml)=$sth->fetchrow;
	$marcxml=Encode::decode('utf8',$marcxml);
 return ($marcxml);
}

sub XMLgetauthorityhash {
## Utility to return  hashed MARCXML
my ($dbh,$authid)=@_;
my $xml=XMLgetauthority($dbh,$authid);
my $xmlhash=XML_xml2hash_onerecord($xml);
return $xmlhash;
}




sub AUTHgetauth_type {
	my ($authtypecode) = @_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select * from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	return $sth->fetchrow_hashref;
}


sub AUTHmodauthority {
## $record is expected to be an xmlhash
	my ($dbh,$authid,$record,$authtypecode)=@_;
	my ($oldrecord)=&AUTHgetauthorityhash($dbh,$authid);
### This equality is very dodgy ,It porobaby wont work
	if ($oldrecord eq $record) {
		return;
	}
##
my $sth=$dbh->prepare("update auth_header set marcxml=? where authid=?");
# find if linked records exist and delete the link in them
my @linkids=XML_readline_asarray($oldrecord,"auth_linkid","authorities");

	foreach my $linkid (@linkids){
		##Modify the record of linked 
		my $linkrecord=AUTHgetauthorityhash($dbh,$linkid);
		my $linktypecode=AUTHfind_authtypecode($dbh,$linkid);
		my @linkfields=XML_readline_asarray($linkrecord,"auth_linkid","authorities");
		my $updated;
		       foreach my $linkfield (@linkfields){
			if ($linkfield eq $authid){
				XML_writeline_id($linkrecord,"auth_linkid",$linkfield,"","authorities");
				$updated=1;
			}
		       }#foreach linkfield
			my $linkedxml=XML_hash2xml($linkrecord);
			if ($updated==1){
			$sth->execute($linkedxml,$linkid);
			ZEBRAop($dbh,$linkid,'specialUpdate',"authorityserver");
			}
	
	}#foreach linkid

#Now rewrite the $record to table with an add
$authid=AUTHaddauthority($dbh,$record,$authid,$authtypecode);


### If a library thinks that updating all biblios is a long process and wishes to leave that to a cron job to use merge_authotities.pl
### they should have a system preference "dontmerge=1" otherwise by default biblios will be updated

if (C4::Context->preference('dontmerge') ){
# save the file in localfile/modified_authorities
	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
	unless (opendir(DIR, "$cgidir")) {
			$cgidir = C4::Context->intranetdir."/";
	} 

	my $filename = $cgidir."/localfile/modified_authorities/$authid.authid";
	open AUTH, "> $filename";
	print AUTH $authid;
	close AUTH;
}else{
	&merge($dbh,$authid,$record,$authid,$record);
}
return $authid;
}

sub AUTHdelauthority {
	my ($dbh,$authid,$keep_biblio) = @_;

# if the keep_biblio is set to 1, then authority entries in biblio are preserved.
# FIXME : delete or not in biblio tables (depending on $keep_biblio flag) is not implemented
ZEBRAop($dbh,$authid,"recordDelete","authorityserver");
}

sub ZEBRAdelauthority {
my ($dbh,$authid)=@_;
	$dbh->do("delete from auth_header where authid=$authid") ;
}

sub AUTHfind_authtypecode {
	my ($dbh,$authid) = @_;
	my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
	$sth->execute($authid);
	my ($authtypecode) = $sth->fetchrow;
	return $authtypecode;
}


sub FindDuplicateauth {
### Should receive an xmlhash
	my ($record,$authtypecode)=@_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	my ($auth_tag_to_report) = $sth->fetchrow;
	$sth->finish;
	# build a request for authoritysearch
	my (@tags, @and_or, @excluding, @operator, @value, $offset, $length);
	
#	if ($record->field($auth_tag_to_report)) {
				push @tags, $auth_tag_to_report;
				push @operator, "all";
				 @value, XML_readline_asarray($record,"","",$auth_tag_to_report);
#		 	}
 
	my ($finalresult,$nbresult) = authoritysearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10,$authtypecode);
	# there is at least 1 result => return the 1st one
	if ($nbresult>0) {
		return @$finalresult[0]->{authid},@$finalresult[0]->{summary};
	}
	# no result, returns nothing
	return;
}

sub getsummary{
## give this an XMLhash record to return summary
my ($dbh,$record,$authid,$authtypecode)=@_;
 my $authref = getauthtype($authtypecode);
		my $summary = $authref->{summary};
		# if the library has a summary defined, use it. Otherwise, build a standard one
	if ($summary) {
			my $fields = $record->{'datafield'};
			foreach my $field (@$fields) {
				my $tag = $field->{'tag'};				
				if ($tag<10) {
				my $tagvalue = XML_readline_onerecord($record,"","",$field->{tag});
				$summary =~ s/\[(.?.?.?.?)$tag\*(.*?)]/$1$tagvalue$2\[$1$tag$2]/g;
				} else {
					my @subf = XML_readline_withtags($record,"","",$tag);
					for my $i (0..$#subf) {
						my $subfieldcode = $subf[$i][0];
						my $subfieldvalue = $subf[$i][1];
						my $tagsubf = $tag.$subfieldcode;
						$summary =~ s/\[(.?.?.?.?)$tagsubf(.*?)]/$1$subfieldvalue$2\[$1$tagsubf$2]/g;
					}## each subf
				}#tag >10
			}##each field
			$summary =~ s/\[(.*?)]//g;
			$summary =~ s/\n/<br>/g;
	} else {
## $summary did not exist create a standard summary
			my $heading; # = $authref->{summary};
			my $altheading;
			my $seeheading;
			my $see;
			my $fields = $record->{datafield};
			if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
			# construct UNIMARC summary, that is quite different from MARC21 one
			foreach my $field (@$fields) {
				# accepted form
				if ($field->{tag} = ~/'2..'/) {
					foreach my $subfield ("a".."z"){
					## Fixme-- if UNICODE uses numeric subfields as well add them
					$heading.=XML_readline_onerecord($record,"","",$field->{tag},$subfield); 
					}
				}##tag 2..
				# rejected form(s)
				if ($field->{tag} = ~/'4..'/) {
					my $value;
					foreach my $subfield ("a".."z"){
					## Fixme-- if UNICODE uses numeric subfields as well add them
					$value.=XML_readline_onerecord($record,"","",$field->{tag},$subfield);
					}
					$summary.= "&nbsp;&nbsp;&nbsp;<i>".$value."</i><br/>";
					$summary.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$heading."<br/>";
				}##tag 4..
				# see :
				if ($field->{tag} = ~/'5..'/) {
					my $value;
					foreach my $subfield ("a".."z"){
					## Fixme-- if UNICODE uses numeric subfields as well add them
					$value.=XML_readline_onerecord($record,"","",$field->{tag},$subfield);
					}
					$summary.= "&nbsp;&nbsp;&nbsp;<i>".$value."</i><br/>";
					$summary.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$heading."<br/>";
				}# tag 5..
				# // form
				if ($field->{tag} = ~/'7..'/) {
					my $value;
					foreach my $subfield ("a".."z"){
					## Fixme-- if UNICODE uses numeric subfields as well add them
					$value.=XML_readline_onerecord($record,"","",$field->{tag},$subfield);
					}
					$seeheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$value."<br />";	
					$altheading.= "&nbsp;&nbsp;&nbsp;".$value."<br />";
					$altheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$heading."<br />";
				}# tag 7..
			}## Foreach fields
				$summary = "<b>".$heading."</b><br />".$seeheading.$altheading.$summary;	
		     } else {
			# construct MARC21 summary
			foreach my $field (@$fields) {
				my $tag="1..";
				  if($field->{tag}  =~ /^$tag/) {
					      if ($field->{tag} eq '150') {
						my $value;
						foreach my $subfield ("a".."z"){
						 $value=XML_readline_onerecord($record,"","","150",$subfield); 
						$heading.="\$".$subfield.$value if $value;
							}
					      }else{				
						foreach my $subfield ("a".."z"){
						$heading.=XML_readline_onerecord($record,"","",$field->{tag},$subfield); 
							}
					     }### tag 150 or else
				   }##tag 1..
				my $tag="4..";
				 if($field->{tag}  =~ /^$tag/) {
					foreach my $subfield ("a".."z"){
						$seeheading.=XML_readline_onerecord($record,"","",$field->{tag},$subfield); 
						}
					$seeheading.= "&nbsp;&nbsp;&nbsp;".$seeheading."<br />";
					$seeheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see:</i> ".$seeheading."<br />";	
				} #tag 4..
				my $tag="5..";
				 if($field->{tag}  =~ /^$tag/) {
					my $value;
					foreach my $subfield ("a".."z"){
						$value.=XML_readline_onerecord($record,"","",$field->{tag},$subfield); 
						}
					$seeheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$value."<br />";	
					$altheading.= "&nbsp;&nbsp;&nbsp;".$value."<br />";
					$altheading.= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$altheading."<br />";
				}#tag 5..
					
			}##for each field
		    $summary.=$heading.$seeheading.$altheading;		
		}##USMARC vs UNIMARC
	}###Summary exists or not
return $summary;
}
sub getdictsummary{
## give this a Marc record to return summary
my ($dbh,$record,$authid,$authtypecode)=@_;
 my $authref = getauthtype($authtypecode);
		my $summary = $authref->{summary};
		my @fields = $record->fields();
#		chop $tags_using_authtype;
		# if the library has a summary defined, use it. Otherwise, build a standard one
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
					}#for $i
				}#tag >10
			}## each field
			$summary =~ s/\[(.*?)]//g;
			$summary =~ s/\n/<br>/g;
		} else {
			my $heading; # = $authref->{summary};
			my $altheading;
			my $seeheading;
			my $see;
			my @fields = $record->{datafields};
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
				foreach my $field (@fields) {	
					if ($field->{tag}=~/'1..'/){			
						$heading.= XML_readline_onerecord($record,"","",$field->{tag},"a");
					}
				} #each fieldd
				
				$summary=$heading;
			}# USMARC vs UNIMARC
		}### Summary exists
return $summary;
}


sub merge {
##mergefrom is authid MARCfrom is marcxml hash of authority
### mergeto ditto
	my ($dbh,$mergefrom,$MARCfrom,$mergeto,$MARCto) = @_;
	return unless (defined $MARCfrom);
	return unless (defined $MARCto);
	my $authtypecodefrom = AUTHfind_authtypecode($dbh,$mergefrom);
	my $authtypecodeto = AUTHfind_authtypecode($dbh,$mergeto);
	# return if authority does not exist
	
	# search the tag to report
	my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
	$sth->execute($authtypecodefrom);
	my ($auth_tag_to_report) = $sth->fetchrow;
	my @record_to;
	# search all biblio tags using this authority.
	$sth = $dbh->prepare("select distinct tagfield from biblios_subfield_structure where authtypecode=? ");
	$sth->execute($authtypecodefrom);
my @tags_using_authtype;
	while (my ($tagfield) = $sth->fetchrow) {
		push @tags_using_authtype,$tagfield ;
	}
## The subfield for linking authorities is stored in koha_attr named auth_biblio_link_subf
## This way we may use whichever subfield we want without harcoding 9 in
my ($dummyfield,$tagsubfield)=MARCfind_marc_from_kohafield("auth_biblio_link_subf","biblios");
	# now, find every biblio using this authority
### try ZOOM search here
my @oConnection;
 $oConnection[0]=C4::Context->Zconn("biblioserver");
##$oConnection[0]->option(elementSetName=>"biblios"); ##  Needs a fix
my $query;
my ($attr2)=MARCfind_attr_from_kohafield("auth_authid");
my $attrfield.=$attr2;
$query= $attrfield." ".$mergefrom;
my ($event,$i);
my $oResult = $oConnection[0]->search_pqf($query);
  while (($i = ZOOM::event(\@oConnection)) != 0) {
	$event = $oConnection[$i-1]->last_event();
	last if $event == ZOOM::Event::ZEND;
   }# while event
my $count=$oResult->size();
my @reccache;
my $z=0;
while ( $z<$count ) {
my $rec;
	$rec=$oResult->record($z);
	my $marcdata = $rec->raw();
my $koharecord=Encode::decode("utf8",$marcdata);
$koharecord=XML_xml2hash($koharecord);
 my ( $xmlrecord, @itemsrecord) = XML_separate($koharecord);

push @reccache, $xmlrecord;
$z++;
}
$oResult->destroy();
$oConnection[0]->destroy();
      foreach my $xmlhash (@reccache){
	my $update;
      	foreach my $tagfield (@tags_using_authtype){

	###Change the authid in biblio
	$xmlhash=XML_writeline_id($xmlhash,$mergefrom,$mergeto,$tagfield,$tagsubfield);
	### delete all subfields of bibliorecord
	$xmlhash=XML_delete_withid($xmlhash,$mergeto,$tagfield,$tagsubfield);
	####Read all the data in from authrecord
	my @record_to=XML_readline_withtags($MARCto,"","",$auth_tag_to_report);
	##Write the data to biblio
		foreach my $subfield (@record_to) {
		## Replace the data in MARCXML with the new matching authid
		XML_writeline_withid($xmlhash,$tagsubfield,$mergeto,$subfield->[1],$tagfield,$subfield->[0]);
		$update=1;
		}#foreach  $subfield		
       	}#foreach tagfield
		if ($update==1){
		my $biblionumber=XML_readline_onerecord($xmlhash,"biblionumber","biblios");
		my $frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber);
		NEWmodbiblio($dbh,$biblionumber,$xmlhash,$frameworkcode) ;
		}
		
     }#foreach $xmlhash
}#sub

sub XML_writeline_withid{
## Only used in authorities to update biblios with matching authids
my ($xml,$idsubf,$id,$newvalue,$tag,$subf)=@_;
my $biblio=$xml->{'datafield'};
my $updated=0;
    if ($tag>9){
	foreach my $data (@$biblio){
        		if ($data->{'tag'} eq $tag){
			my @subfields=$data->{'subfield'};
			foreach my $subfield ( @subfields){
	 		      foreach my $code ( @$subfield){
				if ($code->{'code'} eq $idsubf && $code->{'content'} eq $id){
				###This is the correct tag -- Now reiterate and update
					my @newsubs;
					  foreach my $code ( @$subfield){		
						if ($code->{'code'} eq $subf ){
						$code->{'content'}=$newvalue;
						$updated=1;
						}
					   push @newsubs, $code;
					}## each code updated
					if (!$updated){
					##Create the subfield if it did not exist	
			 		push @newsubs,{code=>$subf,content=>$newvalue};
					$data->{subfield}= \@newsubs;
					$updated=1;
		    			 }### created	
				}### correct tag with id
	  		      }#each code
			}##each subfield	
		}# tag match
       	 }## each datafield
    }### tag >9
return $xml;
}
sub XML_delete_withid{
## Currently  only usedin authorities
### deletes all the subfields of a matching authid
my ($xml,$id,$tag,$idsubf)=@_;
my $biblio=$xml->{'datafield'};
    if ($tag>9){
	foreach my $data (@$biblio){
        		if ($data->{'tag'} eq $tag){
			my @subfields=$data->{'subfield'};
			foreach my $subfield ( @subfields){
	 		      foreach my $code ( @$subfield){
				if ($code->{'code'} eq $idsubf && $code->{'content'} eq $id){
				###This is the correct tag -- Now reiterate and delete all but id subfield
					  foreach my $code ( @$subfield){		
						if ($code->{'code'} ne $idsubf ){
						$code->{'content'}="";					
						}					   
					  }## each code deleted	
				}### correct tag with id
	  		      }#each code
			}## each subfield	
		}## tag matches
       	 }## each datafield
    }# tag >9
return $xml;
}

sub XML_readline_withtags {
my ($xml,$kohafield,$recordtype,$tag,$subf)=@_;
#$xml represents one record of MARCXML as perlhashed 
## returns an array of read fields--useful for reading repeated fields
### $recordtype is needed for mapping the correct field if supplied
### If only $tag is give reads the whole tag
###Returns subfieldcodes as well
my @value;
 ($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype) if $kohafield;
if ($tag){
### Only datafields are read
my $biblio=$xml->{'datafield'};
 if ($tag>9){
	foreach my $data (@$biblio){
   	    if ($data->{'tag'} eq $tag){
		foreach my $subfield ( $data->{'subfield'}){
		    foreach my $code ( @$subfield){
			if ($code->{'code'} eq $subf || !$subf){
			push @value,[$code->{'code'},$code->{'content'}];
			}
		   }# each code
		}# each subfield
  	   }### tag found
	}## each tag
   }##tag >9
}## if tag 
return @value;
}

END { }       # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.30  2006/09/06 16:21:03  tgarip1957
# Clean up before final commits
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
