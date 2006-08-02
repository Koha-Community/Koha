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
#use ZOOM;
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
	&AUTHfind_marc_from_kohafield
	&AUTHgetauth_type
	&AUTHcount_usage
	&getsummary
	&authoritysearch
	&XMLgetauthority
	
	&AUTHhtml2marc
	
	&merge
	&FindDuplicate
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
	my ($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode) = @_;
	my $query;
	my $attr;
	# the marclist may contain "mainentry". In this case, search the tag_to_report, that depends on
	# the authtypecode. Then, search on $a of this tag_to_report
	# also store main entry MARC tag, to extract it at end of search
	my $mainentrytag;
	##first set the authtype search and may be multiple authorities
	my $n=0;
	my @authtypecode;
				my @auths=split / /,$authtypecode ;
				foreach my  $auth (@auths){
				$query .=" \@attr 1=1013 \@attr 5=100 ".$auth; ##No truncation on authtype
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
		$attr =" \@attr 1=21 ";
		}else{
		$attr =" \@attr 1=47 ";
		}
		

	
		
		if (@$operator[$i] eq 'phrase') {
			 $attr.=" \@attr 4=1  \@attr 5=100 \@attr 6=2 ";##Phrase, No truncation,all of subfield field must match
		
		} else {
		
			 $attr .=" \@attr 4=6  \@attr 5=1  ";## Word list, right truncated, anywhere
		}		 
	
		
		$and .=" \@and " ;
		$attr =$attr."\"".@$value[$i]."\"";
		$q2 .=$attr;
	$dosearch=1;		
	}#if value		
		
	}
##Add how many queries generated
$query= $and.$query.$q2;
#warn $query;

$offset=0 unless $offset;
my $counter = $offset;
$length=10 unless $length;
my @oAuth;
my $i;
 $oAuth[0]=C4::Context->Zconnauth("authorityserver");
#$oAuth[0]->connect;
my $Anewq= new ZOOM::Query::PQF($query);
$Anewq->sortby("1=21 i< 1=47 i< ");
my $oAResult;
 $oAResult= $oAuth[0]->search($Anewq) ; 
while (($i = ZOOM::event(\@oAuth)) != 0) {
    my $ev = $oAuth[$i-1]->last_event();
#    warn("Authority ", $i-1, ": event $ev (", ZOOM::event_str($ev), ")\n");
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
##we may be searching multiple authoritytypes.
##Fix me this assumes that all authid and linkid fields are the same for all authority types
my ($authidfield,$authidsubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.authid",$authtypecode[0]);
my ($linkidfield,$linkidsubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.linkid",$authtypecode[0]);
while (($counter < $nbresults) && ($counter < ($offset + $length))) {

##Here we have to extract MARC record and $authid from ZEBRA AUTHORITIES
my $rec=$oAResult->record($counter);
my $marcdata=$rec->raw();
my $authrecord;		
my $linkid;
my @linkids;	
my $separator=C4::Context->preference('authoritysep');
my $linksummary=" ".$separator;	
	
	$authrecord = MARC::File::USMARC::decode($marcdata);
		
my $authid=$authrecord->field($authidfield)->subfield($authidsubfield); 
	if ($authrecord->field($linkidfield)){
my @fields=$authrecord->field($linkidfield);

	foreach my $field (@fields){
	$linkid=$field->subfield($linkidsubfield) ;
		if ($linkid){ ##There is a linked record add fields to produce summary
my $linktype=AUTHfind_authtypecode($dbh,$linkid);
		my $linkrecord=AUTHgetauthority($dbh,$linkid);
		$linksummary.="<br>&nbsp;&nbsp;&nbsp;&nbsp;<a href='detail.pl?authid=$linkid'>".getsummary($dbh,$linkrecord,$linkid,$linktype).".</a>".$separator;
		}
 	}
	}#

my $summary=getsummary($dbh,$authrecord,$authid,$authtypecode);
$summary="<a href='detail.pl?authid=$authid'>".$summary.".</a>";
if ($linkid && $linksummary ne " ".$separator){
$summary="<b>".$summary."</b>".$linksummary;
}
	my %newline;
	$newline{summary} = $summary;
	$newline{authid} = $authid;
	$newline{linkid} = $linkid;
#	$newline{used} =0;
#	$newline{biblio_fields} = $tags_using_authtype;
	$newline{even} = $counter % 2;
	$counter++;
	push @finalresult, \%newline;
	}## while counter


###
my @oConnection;


my @oResult;
$oConnection[0]=C4::Context->Zconnauth("biblioserver");
for (my $z=0; $z<@finalresult; $z++){
	my $nquery;
		
		$nquery= "\@attr GILS 1=2057 ".$finalresult[$z]{authid};
		$nquery="\@or ".$nquery." \@attr GILS 1=2057 ".$finalresult[$z]{linkid} if $finalresult[$z]{linkid};
		 $oResult[$z] = $oConnection[0]->search_pqf($nquery);


OTHERS:
while (($i = ZOOM::event(\@oConnection)) != 0) {
    my $ev = $oConnection[0]->last_event();
#    warn("connection ", $i-1, ": event $ev (", ZOOM::event_str($ev), ")\n");
    last if $ev == ZOOM::Event::ZEND;
}
if ($i !=0){
 my($error, $errmsg, $addinfo, $diagset) = $oConnection[0]->error_x();
    if ($error) {
	warn  "oConnection $ error: $errmsg ($error) $addinfo\n";
	 ##In fact its an error. Should we inform at least the librarian?
	next;
  	  }
		
		my  $count=$oResult[$z]->size()  ;
		$finalresult[$z]{used}=$count;
#		$oResult->destroy();
#		$oConnection[$i-1]->destroy();
}
 }# all $z's


}## if nbresult
NOLUCK:
$oAResult->destroy();
$oAuth[0]->destroy();

	return (\@finalresult, $nbresults);
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
				
					$sql_tables = "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "( m$nb_table.subfieldvalue like '@$value[$i]' ";
					if (@$tags[$i]) {
						$sql_where1 .=" and concat(m$nb_table.tag,m$nb_table.subfieldcode) IN (@$tags[$i])";
							}
					$sql_where1.=")";
					} else {
				
					
					
					
					$nb_table++;
					
					$sql_tables .= "auth_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue   like '@$value[$i]' ";
					if (@$tags[$i]) {
					 	$sql_where1 .=" and concat(m$nb_table.tag,m$nb_table.subfieldcode) IN (@$tags[$i])";
							}
					$sql_where1.=")";
					$sql_where2.="m1.authid=m$nb_table.authid and ";
								
				
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
### try ZOOM search here
my $oConnection=C4::Context->Zconn("biblioserver");
my $query;
$query= "\@attr GILS 1=2057 ".$authid;

my $oResult = $oConnection->search_pqf($query);

my $result=$oResult->size() if  ($oResult);
	
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
	$sth=      $dbh->prepare("select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,kohafield,seealso,hidden,isurl,link from auth_subfield_structure where authtypecode=? order by tagfield,tagsubfield"
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
        $value_builder, $kohafield,  $seealso,          $hidden,
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
        $res->{$tag}->{$subfield}->{kohafield}        = $kohafield;
        $res->{$tag}->{$subfield}->{seealso}          = $seealso;
        $res->{$tag}->{$subfield}->{hidden}           = $hidden;
        $res->{$tag}->{$subfield}->{isurl}            = $isurl;
        $res->{$tag}->{$subfield}->{link}            = $link;
    }
    return $res;
}

sub AUTHaddauthority {
# pass the MARC::Record to this function, and it will create the records in the authority table
	my ($dbh,$record,$authid,$authtypecode) = @_;

#my $leadercode=AUTHfind_leader($dbh,$authtypecode);
my $leader='         a              ';##Fixme correct leader as this one just adds utf8 to MARC21
#substr($leader,8,1)=$leadercode;
#	$record->leader($leader);
my ($authfield,$authidsubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.authid",$authtypecode);
my ($authfield2,$authtypesubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.authtypecode",$authtypecode);
my ($linkidfield,$linkidsubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.linkid",$authtypecode);

# if authid empty => true add, find a new authid number
	if (!$authid) {
	my	$sth=$dbh->prepare("select max(authid) from auth_header");
		$sth->execute;
		($authid)=$sth->fetchrow;
		$authid=$authid+1;
		
##Insert the recordID in MARC record 

##Both authid and authtypecode is expected to be in the same field. Modify if other requirements arise
	$record->add_fields($authfield,'','',$authidsubfield=>$authid,$authtypesubfield=>$authtypecode);

		$dbh->do("lock tables auth_header WRITE");
		 $sth=$dbh->prepare("insert into auth_header (authid,datecreated,authtypecode,marc) values (?,now(),?,?)");
		$sth->execute($authid,$authtypecode,$record->as_usmarc);		
		$sth->finish;
	
	}else{
##Modified record reinsertid
my $idfield=$record->field($authfield);
$record->delete_field($idfield);
$record->add_fields($authfield,'','',$authtypesubfield=>$authtypecode,$authidsubfield=>$authid);

	$dbh->do("lock tables auth_header WRITE");
	my $sth=$dbh->prepare("update auth_header set marc=? where authid=?");
	$sth->execute($record->as_usmarc,$authid);
	$sth->finish;
	}
	$dbh->do("unlock tables");
	zebraop($dbh,$authid,'specialUpdate',"authorityserver");

if ($record->field($linkidfield)){
my @fields=$record->field($linkidfield);

	foreach my $field (@fields){
my	$linkid=$field->subfield($linkidsubfield) ;
		if ($linkid){
	##Modify the record of linked 
	AUTHaddlink($dbh,$linkid,$authid);
	}
	}
}
	return ($authid);
}

sub AUTHaddlink{
my ($dbh,$linkid,$authid)=@_;
my $record=AUTHgetauthority($dbh,$linkid);
my $authtypecode=AUTHfind_authtypecode($dbh,$linkid);
#warn "adding l:$linkid,a:$authid,auth:$authtypecode";
$record=AUTH2marcOnefieldlink($dbh,$record,"auth_header.linkid",$authid,$authtypecode);
$dbh->do("lock tables auth_header WRITE");
	my $sth=$dbh->prepare("update auth_header set marc=? where authid=?");
	$sth->execute($record->as_usmarc,$linkid);
	$sth->finish;	
	$dbh->do("unlock tables");
	zebraop($dbh,$linkid,'specialUpdate',"authorityserver");
}

sub AUTH2marcOnefieldlink {
    my ( $dbh, $record, $kohafieldname, $newvalue,$authtypecode ) = @_;
my $sth =      $dbh->prepare(
"select tagfield,tagsubfield from auth_subfield_structure where authtypecode=? and kohafield=?"
    );
    $sth->execute($authtypecode,$kohafieldname);
my  ($tagfield,$tagsubfield)=$sth->fetchrow;
            $record->add_fields( $tagfield, " ", " ", $tagsubfield => $newvalue );
    return $record;
}

sub XMLgetauthority {

    # Returns MARC::XML of the authority passed in parameter.
    my ( $dbh, $authid ) = @_;
  

    my $sth =
      $dbh->prepare("select marc from auth_header where authid=? "  );
    
    $sth->execute($authid);
   my ($marc)=$sth->fetchrow;
$marc=MARC::File::USMARC::decode($marc);
 my $marcxml=$marc->as_xml_record();
 return $marcxml;

}


sub AUTHfind_leader{
##Hard coded for NEU auth types 
my($dbh,$authtypecode)=@_;

my $leadercode;
if ($authtypecode eq "AUTH"){
$leadercode="a";
}elsif ($authtypecode eq "ESUB"){
$leadercode="b";
}elsif ($authtypecode eq "TSUB"){
$leadercode="c";
}else{
$leadercode=" ";
}
return $leadercode;
}

sub AUTHgetauthority {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$authid)=@_;
my	$sth=$dbh->prepare("select marc from auth_header where authid=?");
		$sth->execute($authid);
	my ($marc) = $sth->fetchrow; 
my $record=MARC::File::USMARC::decode($marc);

	return ($record);
}

sub AUTHgetauth_type {
	my ($authtypecode) = @_;
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select * from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	return $sth->fetchrow_hashref;
}
sub AUTHmodauthority {

	my ($dbh,$authid,$record,$authtypecode,$merge)=@_;
	my ($oldrecord)=&AUTHgetauthority($dbh,$authid);
	if ($oldrecord eq $record) {
		return;
	}
my $sth=$dbh->prepare("update auth_header set marc=? where authid=?");
#warn find if linked records exist and delete them
my($linkidfield,$linkidsubfield)=AUTHfind_marc_from_kohafield($dbh,"auth_header.linkid",$authtypecode);

if ($oldrecord->field($linkidfield)){
my @fields=$oldrecord->field($linkidfield);
	foreach my $field (@fields){
my	$linkid=$field->subfield($linkidsubfield) ;
	if ($linkid){			
		##Modify the record of linked 
		my $linkrecord=AUTHgetauthority($dbh,$linkid);
		my $linktypecode=AUTHfind_authtypecode($dbh,$linkid);
		my ( $linkidfield2,$linkidsubfield2)=AUTHfind_marc_from_kohafield($dbh,"auth_header.linkid",$linktypecode);
		my @linkfields=$linkrecord->field($linkidfield2);
			foreach my $linkfield (@linkfields){
			if ($linkfield->subfield($linkidsubfield2) eq $authid){
				$linkrecord->delete_field($linkfield);
				$sth->execute($linkrecord->as_usmarc,$linkid);
				zebraop($dbh,$linkid,'specialUpdate',"authorityserver");
			}
			}#foreach linkfield
	}
	}#foreach linkid
}
#Now rewrite the $record to table with an add
$authid=AUTHaddauthority($dbh,$record,$authid,$authtypecode);


### If a library thinks that updating all biblios is a long process and wishes to leave that to a cron job to use merge_authotities.p
### they should have a system preference "dontmerge=1" otherwise by default biblios will be updated
### the $merge flag is now depreceated and will be removed at code cleaning

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

zebraop($dbh,$authid,"recordDelete","authorityserver");
	$dbh->do("delete from auth_header where authid=$authid") ;

# FIXME : delete or not in biblio tables (depending on $keep_biblio flag)
}



sub AUTHfind_authtypecode {
	my ($dbh,$authid) = @_;
	my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
	$sth->execute($authid);
	my ($authtypecode) = $sth->fetchrow;
	return $authtypecode;
}



sub AUTHhtml2marc {
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
#---- TODO : the leader is missing

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




sub FindDuplicate {

	my ($record,$authtypecode)=@_;
#	warn "IN for ".$record->as_formatted;
	my $dbh = C4::Context->dbh;
#	warn "".$record->as_formatted;
	my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
	$sth->execute($authtypecode);
	my ($auth_tag_to_report) = $sth->fetchrow;
	$sth->finish;
	# build a request for authoritysearch
	my (@tags, @and_or, @excluding, @operator, @value, $offset, $length);
	if ($record->field($auth_tag_to_report)) {
				push @tags, $auth_tag_to_report;
				push @and_or, "";
				push @excluding, "";
				push @operator, "all";
				push @value, $record->field($auth_tag_to_report)->as_string();
		 	}
 
	my ($finalresult,$nbresult) = authoritysearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10,$authtypecode);
	# there is at least 1 result => return the 1st one
	if ($nbresult>0) {
		return @$finalresult[0]->{authid},@$finalresult[0]->{summary};
	}
	# no result, returns nothing
	return;
}

sub getsummary{
## give this a Marc record to return summary
my ($dbh,$record,$authid,$authtypecode)=@_;

# my $authtypecode = AUTHfind_authtypecode($dbh,$authid);
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
				#	$heading.= $field->as_string('abvxyz68');
				$heading.= $field->as_formatted();
					my $tag=$field->tag();
					$heading=~s /^$tag//g;
					$heading =~s /\_/\$/g;		
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
return $summary;
}
sub merge {
	my ($dbh,$mergefrom,$MARCfrom,$mergeto,$MARCto) = @_;
	my $authtypecodefrom = AUTHfind_authtypecode($dbh,$mergefrom);
	my $authtypecodeto = AUTHfind_authtypecode($dbh,$mergeto);
	# return if authority does not exist
	my @X = $MARCfrom->fields();
	return if $#X == -1;
	my @X = $MARCto->fields();
	return if $#X == -1;
	
	
	# search the tag to report
	my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
	$sth->execute($authtypecodefrom);
	my ($auth_tag_to_report) = $sth->fetchrow;

	my @record_to;
	@record_to = $MARCto->field($auth_tag_to_report)->subfields() if $MARCto->field($auth_tag_to_report);
	my @record_from;
	@record_from = $MARCfrom->field($auth_tag_to_report)->subfields() if $MARCfrom->field($auth_tag_to_report);
	
	# search all biblio tags using this authority.
	$sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
	$sth->execute($authtypecodefrom);
my @tags_using_authtype;
	while (my ($tagfield) = $sth->fetchrow) {
		push @tags_using_authtype,$tagfield."9" ;
	}

	# now, find every biblio using this authority
### try ZOOM search here
my $oConnection=C4::Context->Zconn("biblioserver");
my $query;
$query= "\@attr GILS 1=2057 ".$mergefrom;
my $oResult = $oConnection->search_pqf($query);
my $count=$oResult->size() if  ($oResult);
my @reccache;
my $z=0;
while ( $z<$count ) {
my $rec;
		 $rec=$oResult->record($z);
	my $marcdata = $rec->raw();
push @reccache, $marcdata;
$z++;
}
$oResult->destroy();
foreach my $marc(@reccache){

my $update;
	my $marcrecord;					
	$marcrecord = MARC::File::USMARC::decode($marc);
	foreach my $tagfield (@tags_using_authtype){
	$tagfield=substr($tagfield,0,3);
		my @tags = $marcrecord->field($tagfield);
		foreach my $tag (@tags){
	    		my $tagsubs=$tag->subfield("9");
#warn "$tagfield:$tagsubs:$mergefrom";
            		if ($tagsubs== $mergefrom) {
               
			$tag->update("9" =>$mergeto);
	foreach my $subfield (@record_to) {
#		warn "$subfield,$subfield->[0],$subfield->[1]";
			$tag->update($subfield->[0] =>$subfield->[1]);
			}#for $subfield
		}
         	$marcrecord->delete_field($tag);
                $marcrecord->add_fields($tag);
		$update=1;
		}#for each tag
	}#foreach tagfield
my $oldbiblio = MARCmarc2koha($dbh,$marcrecord,"") ;
		if ($update==1){
		&NEWmodbiblio($dbh,$marcrecord,$oldbiblio->{'biblionumber'},undef,"0000") ;
		}
		
}#foreach $marc
}#sub
END { }       # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.28  2006/08/02 16:40:23  kados
# rolling back previous merge, will do manually
#
# Revision 1.9.2.17.2.1  2006/05/28 18:49:12  tgarip1957
# This is an unusual commit. The main purpose is a working model of Zebra on a modified rel2_2.
# Any questions regarding these commits should be asked to Joshua Ferraro unless you are Joshua whom I'll report to
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
