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
use C4::Context;
use C4::Koha;
use MARC::Record;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc::MARC21;
use C4::AuthoritiesMarc::UNIMARC;
use C4::Charset;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;

	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
	    &GetTagsLabels
	    &GetAuthType
	    &GetAuthTypeCode
    	&GetAuthMARCFromKohaField 
    	&AUTHhtml2marc

    	&AddAuthority
    	&ModAuthority
    	&DelAuthority
    	&GetAuthority
    	&GetAuthorityXML
    
    	&CountUsage
    	&CountUsageChildren
    	&SearchAuthorities
    
    	&BuildSummary
    	&BuildUnimarcHierarchies
    	&BuildUnimarcHierarchy
    
    	&merge
    	&FindDuplicateAuthority
 	);
}

=head2 GetAuthMARCFromKohaField 

=over 4

( $tag, $subfield ) = &GetAuthMARCFromKohaField ($kohafield,$authtypecode);
returns tag and subfield linked to kohafield

Comment :
Suppose Kohafield is only linked to ONE subfield

=back

=cut

sub GetAuthMARCFromKohaField {
#AUTHfind_marc_from_kohafield
  my ( $kohafield,$authtypecode ) = @_;
  my $dbh=C4::Context->dbh;
  return 0, 0 unless $kohafield;
  $authtypecode="" unless $authtypecode;
  my $marcfromkohafield;
  my $sth = $dbh->prepare("select tagfield,tagsubfield from auth_subfield_structure where kohafield= ? and authtypecode=? ");
  $sth->execute($kohafield,$authtypecode);
  my ($tagfield,$tagsubfield) = $sth->fetchrow;
    
  return  ($tagfield,$tagsubfield);
}

=head2 SearchAuthorities 

=over 4

(\@finalresult, $nbresults)= &SearchAuthorities($tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode,$sortby)
returns ref to array result and count of results returned

=back

=cut

sub SearchAuthorities {
    my ($tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode,$sortby) = @_;
#     warn "CALL : $tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode,$sortby";
    my $dbh=C4::Context->dbh;
    if (C4::Context->preference('NoZebra')) {
    
        #
        # build the query
        #
        my $query;
        my @auths=split / /,$authtypecode ;
        foreach my  $auth (@auths){
            $query .="AND auth_type= $auth ";
        }
        $query =~ s/^AND //;
        my $dosearch;
        for(my $i = 0 ; $i <= $#{$value} ; $i++)
        {
            if (@$value[$i]){
                if (@$tags[$i] eq "mainmainentry") {
                    $query .=" AND mainmainentry";
                }elsif (@$tags[$i] eq "mainentry") {
                    $query .=" AND mainentry";
                } else {
                    $query .=" AND ";
                }
                if (@$operator[$i] eq 'is') {
                    $query.=(@$tags[$i]?"=":""). '"'.@$value[$i].'"';
                }elsif (@$operator[$i] eq "="){
                    $query.=(@$tags[$i]?"=":""). '"'.@$value[$i].'"';
                }elsif (@$operator[$i] eq "start"){
                    $query.=(@$tags[$i]?"=":"").'"'.@$value[$i].'%"';
                } else {
                    $query.=(@$tags[$i]?"=":"").'"'.@$value[$i].'%"';
                }
                $dosearch=1;
            }#if value
        }
        #
        # do the query (if we had some search term
        #
        if ($dosearch) {
#             warn "QUERY : $query";
            my $result = C4::Search::NZanalyse($query,'authorityserver');
#             warn "result : $result";
            my %result;
            foreach (split /;/,$result) {
                my ($authid,$title) = split /,/,$_;
                # hint : the result is sorted by title.biblionumber because we can have X biblios with the same title
                # and we don't want to get only 1 result for each of them !!!
                # hint & speed improvement : we can order without reading the record
                # so order, and read records only for the requested page !
                $result{$title.$authid}=$authid;
            }
            # sort the hash and return the same structure as GetRecords (Zebra querying)
            my @listresult = ();
            my $numbers=0;
            if ($sortby eq 'HeadingDsc') { # sort by mainmainentry desc
                foreach my $key (sort {$b cmp $a} (keys %result)) {
                    push @listresult, $result{$key};
#                     warn "push..."$#finalresult;
                    $numbers++;
                }
            } else { # sort by mainmainentry ASC
                foreach my $key (sort (keys %result)) {
                    push @listresult, $result{$key};
#                     warn "push..."$#finalresult;
                    $numbers++;
                }
            }
            # limit the $results_per_page to result size if it's more
            $length = $numbers-$offset if $numbers < ($offset+$length);
            # for the requested page, replace authid by the complete record
            # speed improvement : avoid reading too much things
            my @finalresult;      
            for (my $counter=$offset;$counter<=$offset+$length-1;$counter++) {
#                 $finalresult[$counter] = GetAuthority($finalresult[$counter])->as_usmarc;
                my $separator=C4::Context->preference('authoritysep');
                my $authrecord =GetAuthority($listresult[$counter]);
                my $authid=$listresult[$counter]; 
                my $summary=BuildSummary($authrecord,$authid,$authtypecode);
                my $query_auth_tag = "SELECT auth_tag_to_report FROM auth_types WHERE authtypecode=?";
                my $sth = $dbh->prepare($query_auth_tag);
                $sth->execute($authtypecode);
                my $auth_tag_to_report = $sth->fetchrow;
                my %newline;
                $newline{used}=CountUsage($authid);
                $newline{summary} = $summary;
                $newline{authid} = $authid;
                $newline{even} = $counter % 2;
                push @finalresult, \%newline;
            }
            return (\@finalresult, $numbers);
        } else {
            return;
        }
    } else {
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
            $query .=" \@attr 1=authtype \@attr 5=100 ".$auth; ##No truncation on authtype
            push @authtypecode ,$auth;
            $n++;
        }
        if ($n>1){
            while ($n>1){$query= "\@or ".$query;$n--;}
        }
        
        my $dosearch;
        my $and;
        my $q2;
        for(my $i = 0 ; $i <= $#{$value} ; $i++)
        {
            if (@$value[$i]){
            ##If mainentry search $a tag
                if (@$tags[$i] eq "mainmainentry") {
                $attr =" \@attr 1=Heading-Main ";
                }elsif (@$tags[$i] eq "mainentry") {
                $attr =" \@attr 1=Heading ";
                }else{
                $attr =" \@attr 1=Any ";
                }
                if (@$operator[$i] eq 'is') {
                    $attr.=" \@attr 4=1  \@attr 5=100 ";##Phrase, No truncation,all of subfield field must match
                }elsif (@$operator[$i] eq "="){
                    $attr.=" \@attr 4=107 ";           #Number Exact match
                }elsif (@$operator[$i] eq "start"){
                    $attr.=" \@attr 3=2 \@attr 4=1 \@attr 5=1 ";#Firstinfield Phrase, Right truncated
                } else {
                    $attr .=" \@attr 5=1 \@attr 4=6 ";## Word list, right truncated, anywhere
                }
                $and .=" \@and " ;
                $attr =$attr."\"".@$value[$i]."\"";
                $q2 .=$attr;
            $dosearch=1;
            }#if value
        }
        ##Add how many queries generated
        if ($query=~/\S+/){    
          $query= $and.$query.$q2 
        } else {
          $query=$q2;    
        }         
        ## Adding order
        #$query=' @or  @attr 7=2 @attr 1=Heading 0 @or  @attr 7=1 @attr 1=Heading 1'.$query if ($sortby eq "HeadingDsc");
        my $orderstring= ($sortby eq "HeadingAsc"?
                           '@attr 7=1 @attr 1=Heading 0'
                         :
                           $sortby eq "HeadingDsc"?      
                            '@attr 7=2 @attr 1=Heading 0'
                           :''
                        );            
        $query=($query?"\@or $orderstring $query":"\@or \@attr 1=_ALLRECORDS \@attr 2=103 '' $orderstring ");
        
        $offset=0 unless $offset;
        my $counter = $offset;
        $length=10 unless $length;
        my @oAuth;
        my $i;
        $oAuth[0]=C4::Context->Zconn("authorityserver" , 1);
        my $Anewq= new ZOOM::Query::PQF($query,$oAuth[0]);
        my $oAResult;
        $oAResult= $oAuth[0]->search($Anewq) ; 
        while (($i = ZOOM::event(\@oAuth)) != 0) {
            my $ev = $oAuth[$i-1]->last_event();
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
        ## FIXME this assumes that all authid and linkid fields are the same for all authority types
        # my ($authidfield,$authidsubfield)=GetAuthMARCFromKohaField($dbh,"auth_header.authid",$authtypecode[0]);
        # my ($linkidfield,$linkidsubfield)=GetAuthMARCFromKohaField($dbh,"auth_header.linkid",$authtypecode[0]);
            while (($counter < $nbresults) && ($counter < ($offset + $length))) {
            
            ##Here we have to extract MARC record and $authid from ZEBRA AUTHORITIES
            my $rec=$oAResult->record($counter);
            my $marcdata=$rec->raw();
            my $authrecord;
            my $separator=C4::Context->preference('authoritysep');
            $authrecord = MARC::File::USMARC::decode($marcdata);
            my $authid=$authrecord->field('001')->data(); 
            my $summary=BuildSummary($authrecord,$authid,$authtypecode);
            my $query_auth_tag = "SELECT auth_tag_to_report FROM auth_types WHERE authtypecode=?";
            my $sth = $dbh->prepare($query_auth_tag);
            $sth->execute($authtypecode);
            my $auth_tag_to_report = $sth->fetchrow;
            my $reported_tag;
            my $mainentry = $authrecord->field($auth_tag_to_report);
            if ($mainentry) {
                foreach ($mainentry->subfields()) {
                    $reported_tag .='$'.$_->[0].$_->[1];
                }
            }
            my %newline;
            $newline{summary} = $summary;
            $newline{authid} = $authid;
            $newline{even} = $counter % 2;
            $newline{reported_tag} = $reported_tag;
            $counter++;
            push @finalresult, \%newline;
            }## while counter
        ###
        for (my $z=0; $z<@finalresult; $z++){
                my  $count=CountUsage($finalresult[$z]{authid});
                $finalresult[$z]{used}=$count;
        }# all $z's
        
        }## if nbresult
        NOLUCK:
        # $oAResult->destroy();
        # $oAuth[0]->destroy();
        
        return (\@finalresult, $nbresults);
    }
}

=head2 CountUsage 

=over 4

$count= &CountUsage($authid)
counts Usage of Authid in bibliorecords. 

=back

=cut

sub CountUsage {
    my ($authid) = @_;
    if (C4::Context->preference('NoZebra')) {
        # Read the index Koha-Auth-Number for this authid and count the lines
        my $result = C4::Search::NZanalyse("an=$authid");
        my @tab = split /;/,$result;
        return scalar @tab;
    } else {
        ### ZOOM search here
        my $oConnection=C4::Context->Zconn("biblioserver",1);
        my $query;
        $query= "an=".$authid;
        my $oResult = $oConnection->search(new ZOOM::Query::CCL2RPN( $query, $oConnection ));
        my $result;
        while ((my $i = ZOOM::event([ $oConnection ])) != 0) {
            my $ev = $oConnection->last_event();
            if ($ev == ZOOM::Event::ZEND) {
                $result = $oResult->size();
            }
        }
        return ($result);
    }
}

=head2 CountUsageChildren 

=over 4

$count= &CountUsageChildren($authid)
counts Usage of narrower terms of Authid in bibliorecords.

=back

=cut

sub CountUsageChildren {
  my ($authid) = @_;
}

=head2 GetAuthTypeCode

=over 4

$authtypecode= &GetAuthTypeCode($authid)
returns authtypecode of an authid

=back

=cut

sub GetAuthTypeCode {
#AUTHfind_authtypecode
  my ($authid) = @_;
  my $dbh=C4::Context->dbh;
  my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
  $sth->execute($authid);
  my ($authtypecode) = $sth->fetchrow;
  return $authtypecode;
}
 
=head2 GetTagsLabels

=over 4

$tagslabel= &GetTagsLabels($forlibrarian,$authtypecode)
returns a ref to hashref of authorities tag and subfield structure.

tagslabel usage : 
$tagslabel->{$tag}->{$subfield}->{'attribute'}
where attribute takes values in :
  lib
  tab
  mandatory
  repeatable
  authorised_value
  authtypecode
  value_builder
  kohafield
  seealso
  hidden
  isurl
  link

=back

=cut

sub GetTagsLabels {
  my ($forlibrarian,$authtypecode)= @_;
  my $dbh=C4::Context->dbh;
  $authtypecode="" unless $authtypecode;
  my $sth;
  my $libfield = ($forlibrarian eq 1)? 'liblibrarian' : 'libopac';


  # check that authority exists
  $sth=$dbh->prepare("SELECT count(*) FROM auth_tag_structure WHERE authtypecode=?");
  $sth->execute($authtypecode);
  my ($total) = $sth->fetchrow;
  $authtypecode="" unless ($total >0);
  $sth= $dbh->prepare(
"SELECT auth_tag_structure.tagfield,auth_tag_structure.liblibrarian,auth_tag_structure.libopac,auth_tag_structure.mandatory,auth_tag_structure.repeatable 
 FROM auth_tag_structure 
 WHERE authtypecode=? 
 ORDER BY tagfield"
    );

  $sth->execute($authtypecode);
  my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

  while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tag}->{tab}        = " ";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
  }
  $sth=      $dbh->prepare(
"SELECT tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,frameworkcode as authtypecode,value_builder,kohafield,seealso,hidden,isurl 
FROM auth_subfield_structure 
WHERE authtypecode=? 
ORDER BY tagfield,tagsubfield"
    );
    $sth->execute($authtypecode);

    my $subfield;
    my $authorised_value;
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
        $isurl,            $link )
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

=head2 AddAuthority

=over 4

$authid= &AddAuthority($record, $authid,$authtypecode)
returns authid of the newly created authority

Either Create Or Modify existing authority.

=back

=cut

sub AddAuthority {
# pass the MARC::Record to this function, and it will create the records in the authority table
  my ($record,$authid,$authtypecode) = @_;
  my $dbh=C4::Context->dbh;
	my $leader='     nz  a22     o  4500';#Leader for incomplete MARC21 record

# if authid empty => true add, find a new authid number
  my $format= 'UNIMARCAUTH' if (uc(C4::Context->preference('marcflavour')) eq 'UNIMARC');
  $format= 'MARC21' if (uc(C4::Context->preference('marcflavour')) ne 'UNIMARC');

	if ($format eq "MARC21") {
		if (!$record->leader) {
			$record->leader($leader);
		}
		if (!$record->field('003')) {
			$record->insert_fields_ordered(
				MARC::Field->new('003',C4::Context->preference('MARCOrgCode'))
			);
		}
		my $time=POSIX::strftime("%Y%m%d%H%M%S",localtime);
		if (!$record->field('005')) {
			$record->insert_fields_ordered(
				MARC::Field->new('005',$time.".0")
			);
		}
		my $date=POSIX::strftime("%y%m%d",localtime);
		if (!$record->field('008')) {
			$record->insert_fields_ordered(
				MARC::Field->new('008',$date."|||a||||||           | |||     d")
			);
		}
		if (!$record->field('040')) {
		 $record->insert_fields_ordered(
        MARC::Field->new('040','','',
				'a' => C4::Context->preference('MARCOrgCode'),
				'c' => C4::Context->preference('MARCOrgCode')
				) 
			);
    }
	}

  if (($format eq "UNIMARCAUTH") && (!$record->subfield('100','a'))){
        $record->leader("     nx  j22             ");
        my $date=POSIX::strftime("%Y%m%d",localtime);    
        if ($record->field('100')){
          $record->field('100')->update('a'=>$date."afrey50      ba0");
        } else {      
          $record->append_fields(
            MARC::Field->new('100',' ',' '
              ,'a'=>$date."afrey50      ba0")
          );
        }      
  }
  my ($auth_type_tag, $auth_type_subfield) = get_auth_type_location($authtypecode);
  if (!$authid and $format eq "MARC21") {
    # only need to do this fix when modifying an existing authority
    C4::AuthoritiesMarc::MARC21::fix_marc21_auth_type_location($record, $auth_type_tag, $auth_type_subfield);
  } 

  unless ($record->field($auth_type_tag) && $record->subfield($auth_type_tag, $auth_type_subfield)) {
    $record->add_fields($auth_type_tag,'','', $auth_type_subfield=>$authtypecode); 
  }

  my $oldRecord;
  if (!$authid) {
    my $sth=$dbh->prepare("select max(authid) from auth_header");
    $sth->execute;
    ($authid)=$sth->fetchrow;
    $authid=$authid+1;
  ##Insert the recordID in MARC record 
    unless ($record->field('001') && $record->field('001')->data() eq $authid){
        $record->delete_field($record->field('001'));
        $record->insert_fields_ordered(MARC::Field->new('001',$authid));
    }
#     warn $record->as_formatted;
    $sth=$dbh->prepare("insert into auth_header (authid,datecreated,authtypecode,marc,marcxml) values (?,now(),?,?,?)");
    $sth->execute($authid,$authtypecode,$record->as_usmarc,$record->as_xml_record($format));
    $sth->finish;
  }else{
      if (C4::Context->preference('NoZebra')) {
        $oldRecord = GetAuthority($authid);
      }
      $record->add_fields('001',$authid) unless ($record->field('001'));
      my $sth=$dbh->prepare("update auth_header set marc=?,marcxml=? where authid=?");
      $sth->execute($record->as_usmarc,$record->as_xml_record($format),$authid);
      $sth->finish;
      $dbh->do("unlock tables");
  }
  ModZebra($authid,'specialUpdate',"authorityserver",$oldRecord,$record);
  return ($authid);
}


=head2 DelAuthority

=over 4

$authid= &DelAuthority($authid)
Deletes $authid

=back

=cut


sub DelAuthority {
    my ($authid) = @_;
    my $dbh=C4::Context->dbh;

    ModZebra($authid,"recordDelete","authorityserver",GetAuthority($authid),undef);
    $dbh->do("delete from auth_header where authid=$authid") ;

}

sub ModAuthority {
  my ($authid,$record,$authtypecode,$merge)=@_;
  my $dbh=C4::Context->dbh;
  #Now rewrite the $record to table with an add
  my $oldrecord=GetAuthority($authid);
  $authid=AddAuthority($record,$authid,$authtypecode);

### If a library thinks that updating all biblios is a long process and wishes to leave that to a cron job to use merge_authotities.p
### they should have a system preference "dontmerge=1" otherwise by default biblios will be updated
### the $merge flag is now depreceated and will be removed at code cleaning
  if (C4::Context->preference('dontmerge') ){
  # save the file in tmp/modified_authorities
      my $cgidir = C4::Context->intranetdir ."/cgi-bin";
      unless (opendir(DIR,"$cgidir")) {
              $cgidir = C4::Context->intranetdir."/";
              closedir(DIR);
      }
  
      my $filename = $cgidir."/tmp/modified_authorities/$authid.authid";
      open AUTH, "> $filename";
      print AUTH $authid;
      close AUTH;
  } else {
      &merge($authid,$oldrecord,$authid,$record);
  }
  return $authid;
}

=head2 GetAuthorityXML 

=over 4

$marcxml= &GetAuthorityXML( $authid)
returns xml form of record $authid

=back

=cut

sub GetAuthorityXML {
  # Returns MARC::XML of the authority passed in parameter.
  my ( $authid ) = @_;
  my $format= 'UNIMARCAUTH' if (uc(C4::Context->preference('marcflavour')) eq 'UNIMARC');
  $format= 'MARC21' if (uc(C4::Context->preference('marcflavour')) ne 'UNIMARC');
  if ($format eq "MARC21") {
    # for MARC21, call GetAuthority instead of
    # getting the XML directly since we may
    # need to fix up the location of the authority
    # code -- note that this is reasonably safe
    # because GetAuthorityXML is used only by the 
    # indexing processes like zebraqueue_start.pl
    my $record = GetAuthority($authid);
    return $record->as_xml_record($format);
  } else {
    my $dbh=C4::Context->dbh;
    my $sth = $dbh->prepare("select marcxml from auth_header where authid=? "  );
    $sth->execute($authid);
    my ($marcxml)=$sth->fetchrow;
    return $marcxml;
  }
}

=head2 GetAuthority 

=over 4

$record= &GetAuthority( $authid)
Returns MARC::Record of the authority passed in parameter.

=back

=cut

sub GetAuthority {
    my ($authid)=@_;
    my $dbh=C4::Context->dbh;
    my $sth=$dbh->prepare("select authtypecode, marcxml from auth_header where authid=?");
    $sth->execute($authid);
    my ($authtypecode, $marcxml) = $sth->fetchrow;
    my $record=eval {MARC::Record->new_from_xml(StripNonXmlChars($marcxml),'UTF-8',
        (C4::Context->preference("marcflavour") eq "UNIMARC"?"UNIMARCAUTH":C4::Context->preference("marcflavour")))};
    return undef if ($@);
    $record->encoding('UTF-8');
    if (C4::Context->preference("marcflavour") eq "MARC21") {
      my ($auth_type_tag, $auth_type_subfield) = get_auth_type_location($authtypecode);
      C4::AuthoritiesMarc::MARC21::fix_marc21_auth_type_location($record, $auth_type_tag, $auth_type_subfield);
    }
    return ($record);
}

=head2 GetAuthType 

=over 4

$result = &GetAuthType($authtypecode)

=back

If the authority type specified by C<$authtypecode> exists,
returns a hashref of the type's fields.  If the type
does not exist, returns undef.

=cut

sub GetAuthType {
    my ($authtypecode) = @_;
    my $dbh=C4::Context->dbh;
    my $sth;
    if (defined $authtypecode){ # NOTE - in MARC21 framework, '' is a valid authority 
                                # type (FIXME but why?)
        $sth=$dbh->prepare("select * from auth_types where authtypecode=?");
        $sth->execute($authtypecode);
        if (my $res = $sth->fetchrow_hashref) {
            return $res; 
        }
    }
    return;
}


sub AUTHhtml2marc {
    my ($rtags,$rsubfields,$rvalues,%indicators) = @_;
    my $dbh=C4::Context->dbh;
    my $prevtag = -1;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing

#     my %subfieldlist=();
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

=head2 FindDuplicateAuthority

=over 4

$record= &FindDuplicateAuthority( $record, $authtypecode)
return $authid,Summary if duplicate is found.

Comments : an improvement would be to return All the records that match.

=back

=cut

sub FindDuplicateAuthority {

    my ($record,$authtypecode)=@_;
#    warn "IN for ".$record->as_formatted;
    my $dbh = C4::Context->dbh;
#    warn "".$record->as_formatted;
    my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
    $sth->execute($authtypecode);
    my ($auth_tag_to_report) = $sth->fetchrow;
    $sth->finish;
#     warn "record :".$record->as_formatted."  auth_tag_to_report :$auth_tag_to_report";
    # build a request for SearchAuthorities
    my $query='at='.$authtypecode.' ';
    map {$query.= " and he=\"".$_->[1]."\"" if ($_->[0]=~/[A-z]/)}  $record->field($auth_tag_to_report)->subfields() if $record->field($auth_tag_to_report);
    my ($error, $results, $total_hits)=SimpleSearch( $query, 0, 1, [ "authorityserver" ] );
    # there is at least 1 result => return the 1st one
    if (@$results>0) {
      my $marcrecord = MARC::File::USMARC::decode($results->[0]);
      return $marcrecord->field('001')->data,BuildSummary($marcrecord,$marcrecord->field('001')->data,$authtypecode);
    }
    # no result, returns nothing
    return;
}

=head2 BuildSummary

=over 4

$text= &BuildSummary( $record, $authid, $authtypecode)
return HTML encoded Summary

Comment : authtypecode can be infered from both record and authid.
Moreover, authid can also be inferred from $record.
Would it be interesting to delete those things.

=back

=cut

sub BuildSummary{
## give this a Marc record to return summary
  my ($record,$authid,$authtypecode)=@_;
  my $dbh=C4::Context->dbh;
  my $summary;
  # handle $authtypecode is NULL or eq ""
  if ($authtypecode) {
  	my $authref = GetAuthType($authtypecode);
  	$summary = $authref->{summary};
  }
  # FIXME: should use I18N.pm
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
  my @fields = $record->fields();
  my $reported_tag;
  # if the library has a summary defined, use it. Otherwise, build a standard one
  # FIXME - it appears that the summary field in the authority frameworks
  #         can work as a display template.  However, this doesn't
  #         suit the MARC21 version, so for now the "templating"
  #         feature will be enabled only for UNIMARC for backwards
  #         compatibility.
  if ($summary and C4::Context->preference('marcflavour') eq 'UNIMARC') {
    my @fields = $record->fields();
    #             $reported_tag = '$9'.$result[$counter];
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
      } else {
      # construct MARC21 summary
          # FIXME - looping over 1XX is questionable
          # since MARC21 authority should have only one 1XX
          foreach my $field ($record->field('1..')) {
              next if "152" eq $field->tag(); # FIXME - 152 is not a good tag to use
                                              # in MARC21 -- purely local tags really ought to be
                                              # 9XX
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
          #    $heading.= $field->as_string('abvxyz68');
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
              $seeheading.= "<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>used for/see from:</i> ".$field->as_string();
          } #See Also
          foreach my $field ($record->field('5..')) {
              $altheading.= "<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>see also:</i> ".$field->as_string();
          }
          $summary .= ": " if $summary;
          $summary.=$heading.$seeheading.$altheading;
      }
  }
  return $summary;
}

=head2 BuildUnimarcHierarchies

=over 4

$text= &BuildUnimarcHierarchies( $authid, $force)
return text containing trees for hierarchies
for them to be stored in auth_header

Example of text:
122,1314,2452;1324,2342,3,2452

=back

=cut

sub BuildUnimarcHierarchies{
  my $authid = shift @_;
#   warn "authid : $authid";
  my $force = shift @_;
  my @globalresult;
  my $dbh=C4::Context->dbh;
  my $hierarchies;
  my $data = GetHeaderAuthority($authid);
  if ($data->{'authtrees'} and not $force){
    return $data->{'authtrees'};
  } elsif ($data->{'authtrees'}){
    $hierarchies=$data->{'authtrees'};
  } else {
    my $record = GetAuthority($authid);
    my $found;
    foreach my $field ($record->field('550')){
      if ($field->subfield('5') && $field->subfield('5') eq 'g'){
        my $parentrecord = GetAuthority($field->subfield('3'));
        my $localresult=$hierarchies;
        my $trees;
        $trees = BuildUnimarcHierarchies($field->subfield('3'));
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
        $found=1;
      }
      $hierarchies=join(";",@globalresult);
    }
    #Unless there is no ancestor, I am alone.
    $hierarchies="$authid" unless ($hierarchies);
  }
  AddAuthorityTrees($authid,$hierarchies);
  return $hierarchies;
}

=head2 BuildUnimarcHierarchy

=over 4

$ref= &BuildUnimarcHierarchy( $record, $class,$authid)
return a hashref in order to display hierarchy for record and final Authid $authid

"loopparents"
"loopchildren"
"class"
"loopauthid"
"current_value"
"value"

"ifparents"  
"ifchildren" 
Those two latest ones should disappear soon.

=back

=cut

sub BuildUnimarcHierarchy{
  my $record = shift @_;
  my $class = shift @_;
  my $authid_constructed = shift @_;
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
  $cell{"loopauthid"}=$authid;
  $cell{"current_value"} =1 if $authid eq $authid_constructed;
  $cell{"value"}=$record->subfield('250',"a");
  return \%cell;
}

=head2 GetHeaderAuthority

=over 4

$ref= &GetHeaderAuthority( $authid)
return a hashref in order auth_header table data

=back

=cut

sub GetHeaderAuthority{
  my $authid = shift @_;
  my $sql= "SELECT * from auth_header WHERE authid = ?";
  my $dbh=C4::Context->dbh;
  my $rq= $dbh->prepare($sql);
  $rq->execute($authid);
  my $data= $rq->fetchrow_hashref;
  return $data;
}

=head2 AddAuthorityTrees

=over 4

$ref= &AddAuthorityTrees( $authid, $trees)
return success or failure

=back

=cut

sub AddAuthorityTrees{
  my $authid = shift @_;
  my $trees = shift @_;
  my $sql= "UPDATE IGNORE auth_header set authtrees=? WHERE authid = ?";
  my $dbh=C4::Context->dbh;
  my $rq= $dbh->prepare($sql);
  return $rq->execute($trees,$authid);
}

=head2 merge

=over 4

$ref= &merge(mergefrom,$MARCfrom,$mergeto,$MARCto)


Could add some feature : Migrating from a typecode to an other for instance.
Then we should add some new parameter : bibliotargettag, authtargettag

=back

=cut

sub merge {
    my ($mergefrom,$MARCfrom,$mergeto,$MARCto) = @_;
    my ($counteditedbiblio,$countunmodifiedbiblio,$counterrors)=(0,0,0);        
    my $dbh=C4::Context->dbh;
    my $authtypecodefrom = GetAuthTypeCode($mergefrom);
    my $authtypecodeto = GetAuthTypeCode($mergeto);
    # return if authority does not exist
    my @X = $MARCfrom->fields();
    return "error MARCFROM not a marcrecord ".Data::Dumper::Dumper($MARCfrom) if $#X == -1;
    @X = $MARCto->fields();
    return "error MARCTO not a marcrecord".Data::Dumper::Dumper($MARCto) if $#X == -1;
    # search the tag to report
    my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
    $sth->execute($authtypecodefrom);
    my ($auth_tag_to_report) = $sth->fetchrow;
    
    my @record_to;
    @record_to = $MARCto->field($auth_tag_to_report)->subfields() if $MARCto->field($auth_tag_to_report);
    my @record_from;
    @record_from = $MARCfrom->field($auth_tag_to_report)->subfields() if $MARCfrom->field($auth_tag_to_report);
    
    my @reccache;
    # search all biblio tags using this authority.
    #Getting marcbiblios impacted by the change.
    if (C4::Context->preference('NoZebra')) {
        #nozebra way    
        my $dbh=C4::Context->dbh;
        my $rq=$dbh->prepare(qq(SELECT biblionumbers from nozebra where indexname="an" and server="biblioserver" and value="$mergefrom" ));
        $rq->execute;
        while (my $biblionumbers=$rq->fetchrow){
            my @biblionumbers=split /;/,$biblionumbers;
            map {
                my $biblionumber=$1 if ($_=~/(\d+),.*/);
                my $marc=GetMarcBiblio($biblionumber);        
                push @reccache,$marc;        
            } @biblionumbers;
        }
    } else {
        #zebra connection  
        my $oConnection=C4::Context->Zconn("biblioserver",0);
        my $query;
        $query= "an=".$mergefrom;
        my $oResult = $oConnection->search(new ZOOM::Query::CCL2RPN( $query, $oConnection ));
        my $count=$oResult->size() if  ($oResult);
        my $z=0;
        while ( $z<$count ) {
            my $rec;
            $rec=$oResult->record($z);
            my $marcdata = $rec->raw();
            push @reccache, $marcdata;
        $z++;
        }
        $oConnection->destroy();    
    }
    #warn scalar(@reccache)." biblios to update";
    # Get All candidate Tags for the change 
    # (This will reduce the search scope in marc records).
    $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
    $sth->execute($authtypecodefrom);
    my @tags_using_authtype;
    while (my ($tagfield) = $sth->fetchrow) {
        push @tags_using_authtype,$tagfield ;
    }
    my $tag_to=0;  
    if ($authtypecodeto ne $authtypecodefrom){  
        # If many tags, take the first
        $sth->execute($authtypecodeto);    
        $tag_to=$sth->fetchrow;
        #warn $tag_to;    
    }  
    # BulkEdit marc records
    # May be used as a template for a bulkedit field  
    foreach my $marcrecord(@reccache){
        my $update;           
        $marcrecord= MARC::File::USMARC::decode($marcrecord) unless(C4::Context->preference('NoZebra'));
        foreach my $tagfield (@tags_using_authtype){
            foreach my $field ($marcrecord->field($tagfield)){
                my $auth_number=$field->subfield("9");
                my $tag=$field->tag();          
                if ($auth_number==$mergefrom) {
                    my $field_to=MARC::Field->new(($tag_to?$tag_to:$tag),$field->indicator(1),$field->indicator(2),"9"=>$mergeto);
                    foreach my $subfield (@record_to) {
                        $field_to->add_subfields($subfield->[0] =>$subfield->[1]);
                    }
                    $marcrecord->delete_field($field);
                    $marcrecord->insert_grouped_field($field_to);            
                    $update=1;
                }
            }#for each tag
        }#foreach tagfield
        my $oldbiblio = TransformMarcToKoha($dbh,$marcrecord,"") ;
        if ($update==1){
            &ModBiblio($marcrecord,$oldbiblio->{'biblionumber'},GetFrameworkCode($oldbiblio->{'biblionumber'})) ;
            $counteditedbiblio++;
            warn $counteditedbiblio if (($counteditedbiblio % 10) and $ENV{DEBUG});
        }    
    }#foreach $marc
    return $counteditedbiblio;  
  # now, find every other authority linked with this authority
#   my $oConnection=C4::Context->Zconn("authorityserver");
#   my $query;
# # att 9210               Auth-Internal-authtype
# # att 9220               Auth-Internal-LN
# # ccl.properties to add for authorities
#   $query= "= ".$mergefrom;
#   my $oResult = $oConnection->search(new ZOOM::Query::CCL2RPN( $query, $oConnection ));
#   my $count=$oResult->size() if  ($oResult);
#   my @reccache;
#   my $z=0;
#   while ( $z<$count ) {
#   my $rec;
#           $rec=$oResult->record($z);
#       my $marcdata = $rec->raw();
#   push @reccache, $marcdata;
#   $z++;
#   }
#   $oResult->destroy();
#   foreach my $marc(@reccache){
#     my $update;
#     my $marcrecord;
#     $marcrecord = MARC::File::USMARC::decode($marc);
#     foreach my $tagfield (@tags_using_authtype){
#       $tagfield=substr($tagfield,0,3);
#       my @tags = $marcrecord->field($tagfield);
#       foreach my $tag (@tags){
#         my $tagsubs=$tag->subfield("9");
#     #warn "$tagfield:$tagsubs:$mergefrom";
#         if ($tagsubs== $mergefrom) {
#           $tag->update("9" =>$mergeto);
#           foreach my $subfield (@record_to) {
#     #        warn "$subfield,$subfield->[0],$subfield->[1]";
#             $tag->update($subfield->[0] =>$subfield->[1]);
#           }#for $subfield
#         }
#         $marcrecord->delete_field($tag);
#         $marcrecord->add_fields($tag);
#         $update=1;
#       }#for each tag
#     }#foreach tagfield
#     my $authoritynumber = TransformMarcToKoha($dbh,$marcrecord,"") ;
#     if ($update==1){
#       &ModAuthority($marcrecord,$authoritynumber,GetAuthTypeCode($authoritynumber)) ;
#     }
# 
#   }#foreach $marc
}#sub

=head2 get_auth_type_location

=over 4

my ($tag, $subfield) = get_auth_type_location($auth_type_code);

=back

Get the tag and subfield used to store the heading type
for indexing purposes.  The C<$auth_type> parameter is
optional; if it is not supplied, assume ''.

This routine searches the MARC authority framework
for the tag and subfield whose kohafield is 
C<auth_header.authtypecode>; if no such field is
defined in the framework, default to the hardcoded value
specific to the MARC format.

=cut

sub get_auth_type_location {
    my $auth_type_code = @_ ? shift : '';

    my ($tag, $subfield) = GetAuthMARCFromKohaField('auth_header.authtypecode', $auth_type_code);
    if (defined $tag and defined $subfield and $tag != 0 and $subfield != 0) {
        return ($tag, $subfield);
    } else {
        if (C4::Context->preference('marcflavour') eq "MARC21")  {
            return C4::AuthoritiesMarc::MARC21::default_auth_type_location();
        } else {
            return C4::AuthoritiesMarc::UNIMARC::default_auth_type_location();
        }
    }
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

