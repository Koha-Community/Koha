package C4::AuthoritiesMarc;
# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use C4::Context;
use MARC::Record;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc::MARC21;
use C4::AuthoritiesMarc::UNIMARC;
use C4::Charset;
use C4::Log;
use Koha::Authority;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;

	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
	    &GetTagsLabels
	    &GetAuthType
	    &GetAuthTypeCode
    	&GetAuthMARCFromKohaField 

    	&AddAuthority
    	&ModAuthority
    	&DelAuthority
    	&GetAuthority
    	&GetAuthorityXML

    	&CountUsage
    	&CountUsageChildren
    	&SearchAuthorities
    
        &BuildSummary
        &BuildAuthHierarchies
        &BuildAuthHierarchy
        &GenerateHierarchy
    
    	&merge
    	&FindDuplicateAuthority

        &GuessAuthTypeCode
        &GuessAuthId
 	);
}


=head1 NAME

C4::AuthoritiesMarc

=head2 GetAuthMARCFromKohaField 

  ( $tag, $subfield ) = &GetAuthMARCFromKohaField ($kohafield,$authtypecode);

returns tag and subfield linked to kohafield

Comment :
Suppose Kohafield is only linked to ONE subfield

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

  (\@finalresult, $nbresults)= &SearchAuthorities($tags, $and_or, 
     $excluding, $operator, $value, $offset,$length,$authtypecode,
     $sortby[, $skipmetadata])

returns ref to array result and count of results returned

=cut

sub SearchAuthorities {
    my ($tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode,$sortby,$skipmetadata) = @_;
    # warn Dumper($tags, $and_or, $excluding, $operator, $value, $offset,$length,$authtypecode,$sortby);
    my $dbh=C4::Context->dbh;
    my $query;
    my $qpquery = '';
    my $QParser;
    $QParser = C4::Context->queryparser if (C4::Context->preference('UseQueryParser'));
    my $attr = '';
        # the marclist may contain "mainentry". In this case, search the tag_to_report, that depends on
        # the authtypecode. Then, search on $a of this tag_to_report
        # also store main entry MARC tag, to extract it at end of search
    my $mainentrytag;
    ##first set the authtype search and may be multiple authorities
    if ($authtypecode) {
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
        if ($QParser) {
            $qpquery .= '(authtype:' . join('|| authtype:', @auths) . ')';
        }
    }

    my $dosearch;
    my $and=" \@and " ;
    my $q2;
    my $attr_cnt = 0;
    for ( my $i = 0 ; $i <= $#{$value} ; $i++ ) {
        if ( @$value[$i] ) {
            if ( @$tags[$i] ) {
                if ( @$tags[$i] eq "mainmainentry" ) {
                    $attr = " \@attr 1=Heading-Main ";
                }
                elsif ( @$tags[$i] eq "mainentry" ) {
                    $attr = " \@attr 1=Heading ";
                }
                elsif ( @$tags[$i] eq "match" ) {
                    $attr = " \@attr 1=Match ";
                }
                elsif ( @$tags[$i] eq "match-heading" ) {
                    $attr = " \@attr 1=Match-heading ";
                }
                elsif ( @$tags[$i] eq "see-from" ) {
                    $attr = " \@attr 1=Match-heading-see-from ";
                }
                elsif ( @$tags[$i] eq "thesaurus" ) {
                    $attr = " \@attr 1=Subject-heading-thesaurus ";
                }
                else {    # Assume any if no index was specified
                    $attr = " \@attr 1=Any ";
                }
            }         #if @$tags[$i]
            else {    # Assume any if no index was specified
                $attr = " \@attr 1=Any ";
            }

            my $operator = @$operator[$i];
            if ( $operator and $operator eq 'is' ) {
                $attr .= " \@attr 4=1  \@attr 5=100 "
                  ;    ##Phrase, No truncation,all of subfield field must match
            }
            elsif ( $operator and $operator eq "=" ) {
                $attr .= " \@attr 4=107 ";    #Number Exact match
            }
            elsif ( $operator and $operator eq "start" ) {
                $attr .= " \@attr 3=2 \@attr 4=1 \@attr 5=1 "
                  ;    #Firstinfield Phrase, Right truncated
            }
            elsif ( $operator and $operator eq "exact" ) {
                $attr .= " \@attr 4=1  \@attr 5=100 \@attr 6=3 "
                  ;    ##Phrase, No truncation,all of subfield field must match
            }
            else {
                $attr .= " \@attr 5=1 \@attr 4=6 "
                  ;    ## Word list, right truncated, anywhere
                if ( $sortby eq 'Relevance' ) {
                    $attr .= "\@attr 2=102 ";
                }
            }
            @$value[$i] =~
              s/"/\\"/g;    # Escape the double-quotes in the search value
            $attr = $attr . "\"" . @$value[$i] . "\"";
            $q2 .= $attr;
            $dosearch = 1;
            ++$attr_cnt;
            if ($QParser) {
                $qpquery .= " $tags->[$i]:\"$value->[$i]\"";
            }
        }    #if value
    }
    ##Add how many queries generated
    if (defined $query && $query=~/\S+/){
      $query= $and x $attr_cnt . $query . (defined $q2 ? $q2 : '');
    } else {
      $query= $q2;
    }
    ## Adding order
    #$query=' @or  @attr 7=2 @attr 1=Heading 0 @or  @attr 7=1 @attr 1=Heading 1'.$query if ($sortby eq "HeadingDsc");
    my $orderstring;
    if ($sortby eq 'HeadingAsc') {
        $orderstring = '@attr 7=1 @attr 1=Heading 0';
    } elsif ($sortby eq 'HeadingDsc') {
        $orderstring = '@attr 7=2 @attr 1=Heading 0';
    } elsif ($sortby eq 'AuthidAsc') {
        $orderstring = '@attr 7=1 @attr 4=109 @attr 1=Local-Number 0';
    } elsif ($sortby eq 'AuthidDsc') {
        $orderstring = '@attr 7=2 @attr 4=109 @attr 1=Local-Number 0';
    }
    if ($QParser) {
        $qpquery .= ' all:all' unless $value->[0];

        if ( $value->[0] =~ m/^qp=(.*)$/ ) {
            $qpquery = $1;
        }

        $qpquery .= " #$sortby" unless $sortby eq '';

        $QParser->parse( $qpquery );
        $query = $QParser->target_syntax('authorityserver');
    } else {
        $query=($query?$query:"\@attr 1=_ALLRECORDS \@attr 2=103 ''");
        $query="\@or $orderstring $query" if $orderstring;
    }

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
        my $separator=C4::Context->preference('AuthoritySeparator');
        my $authrecord = C4::Search::new_record_from_zebra(
            'authorityserver',
            $rec->raw()
        );

        if ( !defined $authrecord or !defined $authrecord->field('001') ) {
            $counter++;
            next;
        }

        my $authid=$authrecord->field('001')->data();
        my %newline;
        $newline{authid} = $authid;
        if ( !$skipmetadata ) {
            my $query_auth_tag =
"SELECT auth_tag_to_report FROM auth_types WHERE authtypecode=?";
            my $sth = $dbh->prepare($query_auth_tag);
            $sth->execute($authtypecode);
            my $auth_tag_to_report = $sth->fetchrow;
            my $reported_tag;
            my $mainentry = $authrecord->field($auth_tag_to_report);
            if ($mainentry) {
                foreach ( $mainentry->subfields() ) {
                    $reported_tag .= '$' . $_->[0] . $_->[1];
                }
            }
            my $thisauthtypecode = GetAuthTypeCode($authid);
            my $thisauthtype = GetAuthType($thisauthtypecode);
            unless (defined $thisauthtype) {
                $thisauthtypecode = $authtypecode;
                $thisauthtype = GetAuthType($authtypecode);
            }
            my $summary = BuildSummary( $authrecord, $authid, $thisauthtypecode );

            $newline{authtype}     = defined($thisauthtype) ?
                                        $thisauthtype->{'authtypetext'} : '';
            $newline{summary}      = $summary;
            $newline{even}         = $counter % 2;
            $newline{reported_tag} = $reported_tag;
        }
        $counter++;
        push @finalresult, \%newline;
        }## while counter
        ###
        if (! $skipmetadata) {
            for (my $z=0; $z<@finalresult; $z++){
                my  $count=CountUsage($finalresult[$z]{authid});
                $finalresult[$z]{used}=$count;
            }# all $z's
        }

    }## if nbresult
    NOLUCK:
    $oAResult->destroy();
    # $oAuth[0]->destroy();

    return (\@finalresult, $nbresults);
}

=head2 CountUsage 

  $count= &CountUsage($authid)

counts Usage of Authid in bibliorecords. 

=cut

sub CountUsage {
    my ($authid) = @_;
        ### ZOOM search here
        my $query;
        $query= "an:".$authid;
  		my ($err,$res,$result) = C4::Search::SimpleSearch($query,0,10);
        if ($err) {
            warn "Error: $err from search $query";
            $result = 0;
        }

        return $result;
}

=head2 CountUsageChildren 

  $count= &CountUsageChildren($authid)

counts Usage of narrower terms of Authid in bibliorecords.

=cut

sub CountUsageChildren {
  my ($authid) = @_;
}

=head2 GetAuthTypeCode

  $authtypecode= &GetAuthTypeCode($authid)

returns authtypecode of an authid

=cut

sub GetAuthTypeCode {
#AUTHfind_authtypecode
  my ($authid) = @_;
  my $dbh=C4::Context->dbh;
  my $sth = $dbh->prepare("select authtypecode from auth_header where authid=?");
  $sth->execute($authid);
  my $authtypecode = $sth->fetchrow;
  return $authtypecode;
}
 
=head2 GuessAuthTypeCode

  my $authtypecode = GuessAuthTypeCode($record);

Get the record and tries to guess the adequate authtypecode from its content.

=cut

sub GuessAuthTypeCode {
    my ($record, $heading_fields) = @_;
    return unless defined $record;
    $heading_fields //= {
    "MARC21"=>{
        '100'=>{authtypecode=>'PERSO_NAME'},
        '110'=>{authtypecode=>'CORPO_NAME'},
        '111'=>{authtypecode=>'MEETI_NAME'},
        '130'=>{authtypecode=>'UNIF_TITLE'},
        '148'=>{authtypecode=>'CHRON_TERM'},
        '150'=>{authtypecode=>'TOPIC_TERM'},
        '151'=>{authtypecode=>'GEOGR_NAME'},
        '155'=>{authtypecode=>'GENRE/FORM'},
        '180'=>{authtypecode=>'GEN_SUBDIV'},
        '181'=>{authtypecode=>'GEO_SUBDIV'},
        '182'=>{authtypecode=>'CHRON_SUBD'},
        '185'=>{authtypecode=>'FORM_SUBD'},
    },
#200 Personal name	700, 701, 702 4-- with embedded 700, 701, 702 600
#                    604 with embedded 700, 701, 702
#210 Corporate or meeting name	710, 711, 712 4-- with embedded 710, 711, 712 601 604 with embedded 710, 711, 712
#215 Territorial or geographic name 	710, 711, 712 4-- with embedded 710, 711, 712 601, 607 604 with embedded 710, 711, 712
#216 Trademark 	716 [Reserved for future use]
#220 Family name 	720, 721, 722 4-- with embedded 720, 721, 722 602 604 with embedded 720, 721, 722
#230 Title 	500 4-- with embedded 500 605
#240 Name and title (embedded 200, 210, 215, or 220 and 230) 	4-- with embedded 7-- and 500 7--  604 with embedded 7-- and 500 500
#245 Name and collective title (embedded 200, 210, 215, or 220 and 235) 	4-- with embedded 7-- and 501 604 with embedded 7-- and 501 7-- 501
#250 Topical subject 	606
#260 Place access 	620
#280 Form, genre or physical characteristics 	608
#
#
# Could also be represented with :
#leader position 9
#a = personal name entry
#b = corporate name entry
#c = territorial or geographical name
#d = trademark
#e = family name
#f = uniform title
#g = collective uniform title
#h = name/title
#i = name/collective uniform title
#j = topical subject
#k = place access
#l = form, genre or physical characteristics
    "UNIMARC"=>{
        '200'=>{authtypecode=>'NP'},
        '210'=>{authtypecode=>'CO'},
        '215'=>{authtypecode=>'SNG'},
        '216'=>{authtypecode=>'TM'},
        '220'=>{authtypecode=>'FAM'},
        '230'=>{authtypecode=>'TU'},
        '235'=>{authtypecode=>'CO_UNI_TI'},
        '240'=>{authtypecode=>'SAUTTIT'},
        '245'=>{authtypecode=>'NAME_COL'},
        '250'=>{authtypecode=>'SNC'},
        '260'=>{authtypecode=>'PA'},
        '280'=>{authtypecode=>'GENRE/FORM'},
    }
};
    foreach my $field (keys %{$heading_fields->{uc(C4::Context->preference('marcflavour'))} }) {
       return $heading_fields->{uc(C4::Context->preference('marcflavour'))}->{$field}->{'authtypecode'} if (defined $record->field($field));
    }
    return;
}

=head2 GuessAuthId

  my $authtid = GuessAuthId($record);

Get the record and tries to guess the adequate authtypecode from its content.

=cut

sub GuessAuthId {
    my ($record) = @_;
    return unless ($record && $record->field('001'));
#    my $authtypecode=GuessAuthTypeCode($record);
#    my ($tag,$subfield)=GetAuthMARCFromKohaField("auth_header.authid",$authtypecode);
#    if ($tag > 010) {return $record->subfield($tag,$subfield)}
#    else {return $record->field($tag)->data}
    return $record->field('001')->data;
}

=head2 GetTagsLabels

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

=cut

sub GetTagsLabels {
  my ($forlibrarian,$authtypecode)= @_;
  my $dbh=C4::Context->dbh;
  $authtypecode="" unless $authtypecode;
  my $sth;
  my $libfield = ($forlibrarian == 1)? 'liblibrarian' : 'libopac';


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
"SELECT tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,frameworkcode as authtypecode,value_builder,kohafield,seealso,hidden,isurl,defaultvalue
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
    my $defaultvalue;

    while (
        ( $tag,         $subfield,   $liblibrarian,   , $libopac,      $tab,
        $mandatory,     $repeatable, $authorised_value, $authtypecode,
        $value_builder, $kohafield,  $seealso,          $hidden,
        $isurl,         $defaultvalue, $link )
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
        $res->{$tag}->{$subfield}->{defaultvalue}     = $defaultvalue;
    }
    return $res;
}

=head2 AddAuthority

  $authid= &AddAuthority($record, $authid,$authtypecode)

Either Create Or Modify existing authority.
returns authid of the newly created authority

=cut

sub AddAuthority {
# pass the MARC::Record to this function, and it will create the records in the authority table
  my ($record,$authid,$authtypecode) = @_;
  my $dbh=C4::Context->dbh;
	my $leader='     nz  a22     o  4500';#Leader for incomplete MARC21 record

# if authid empty => true add, find a new authid number
    my $format;
    if (uc(C4::Context->preference('marcflavour')) eq 'UNIMARC') {
        $format= 'UNIMARCAUTH';
    }
    else {
        $format= 'MARC21';
    }

    #update date/time to 005 for marc and unimarc
    my $time=POSIX::strftime("%Y%m%d%H%M%S",localtime);
    my $f5=$record->field('005');
    if (!$f5) {
      $record->insert_fields_ordered( MARC::Field->new('005',$time.".0") );
    }
    else {
      $f5->update($time.".0");
    }

    SetUTF8Flag($record);
	if ($format eq "MARC21") {
		if (!$record->leader) {
			$record->leader($leader);
		}
		if (!$record->field('003')) {
			$record->insert_fields_ordered(
				MARC::Field->new('003',C4::Context->preference('MARCOrgCode'))
			);
		}
		my $date=POSIX::strftime("%y%m%d",localtime);
		if (!$record->field('008')) {
            # Get a valid default value for field 008
            my $default_008 = C4::Context->preference('MARCAuthorityControlField008');
            if(!$default_008 or length($default_008)<34) {
                $default_008 = '|| aca||aabn           | a|a     d';
            }
            else {
                $default_008 = substr($default_008,0,34);
            }

            $record->insert_fields_ordered( MARC::Field->new('008',$date.$default_008) );
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

  if ($format eq "UNIMARCAUTH") {
        $record->leader("     nx  j22             ") unless ($record->leader());
        my $date=POSIX::strftime("%Y%m%d",localtime);
	my $defaultfield100 = C4::Context->preference('UNIMARCAuthorityField100');
    if (my $string=$record->subfield('100',"a")){
      	$string=~s/fre50/frey50/;
      	$record->field('100')->update('a'=>$string);
    }
    elsif ($record->field('100')){
          $record->field('100')->update('a'=>$date.$defaultfield100);
    } else {      
        $record->append_fields(
        MARC::Field->new('100',' ',' '
            ,'a'=>$date.$defaultfield100)
        );
    }      
  }
  my ($auth_type_tag, $auth_type_subfield) = get_auth_type_location($authtypecode);
  if (!$authid and $format eq "MARC21") {
    # only need to do this fix when modifying an existing authority
    C4::AuthoritiesMarc::MARC21::fix_marc21_auth_type_location($record, $auth_type_tag, $auth_type_subfield);
  } 
  if (my $field=$record->field($auth_type_tag)){
    $field->update($auth_type_subfield=>$authtypecode);
  }
  else {
    $record->add_fields($auth_type_tag,'','', $auth_type_subfield=>$authtypecode); 
  }

  my $auth_exists=0;
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
  } else {
    $auth_exists=$dbh->do(qq(select authid from auth_header where authid=?),undef,$authid);
#     warn "auth_exists = $auth_exists";
  }
  if ($auth_exists>0){
      $oldRecord=GetAuthority($authid);
      $record->add_fields('001',$authid) unless ($record->field('001'));
#       warn "\n\n\n enregistrement".$record->as_formatted;
      my $sth=$dbh->prepare("update auth_header set authtypecode=?,marc=?,marcxml=? where authid=?");
      $sth->execute($authtypecode,$record->as_usmarc,$record->as_xml_record($format),$authid) or die $sth->errstr;
      $sth->finish;
  }
  else {
    my $sth=$dbh->prepare("insert into auth_header (authid,datecreated,authtypecode,marc,marcxml) values (?,now(),?,?,?)");
    $sth->execute($authid,$authtypecode,$record->as_usmarc,$record->as_xml_record($format));
    $sth->finish;
    logaction( "AUTHORITIES", "ADD", $authid, "authority" ) if C4::Context->preference("AuthoritiesLog");
  }
  ModZebra($authid,'specialUpdate',"authorityserver",$oldRecord,$record);
  return ($authid);
}


=head2 DelAuthority

  $authid= &DelAuthority($authid)

Deletes $authid

=cut

sub DelAuthority {
    my ($authid) = @_;
    my $dbh=C4::Context->dbh;

    logaction( "AUTHORITIES", "DELETE", $authid, "authority" ) if C4::Context->preference("AuthoritiesLog");
    ModZebra($authid,"recordDelete","authorityserver",GetAuthority($authid),undef);
    my $sth = $dbh->prepare("DELETE FROM auth_header WHERE authid=?");
    $sth->execute($authid);
}

=head2 ModAuthority

  $authid= &ModAuthority($authid,$record,$authtypecode)

Modifies authority record, optionally updates attached biblios.

=cut

sub ModAuthority {
  my ($authid,$record,$authtypecode)=@_; # deprecated $merge parameter removed

  my $dbh=C4::Context->dbh;
  #Now rewrite the $record to table with an add
  my $oldrecord=GetAuthority($authid);
  $authid=AddAuthority($record,$authid,$authtypecode);

  # If a library thinks that updating all biblios is a long process and wishes
  # to leave that to a cron job, use misc/migration_tools/merge_authority.pl.
  # In that case set system preference "dontmerge" to 1. Otherwise biblios will
  # be updated.
  unless(C4::Context->preference('dontmerge') eq '1'){
      &merge($authid,$oldrecord,$authid,$record);
  } else {
      # save a record in need_merge_authorities table
      my $sqlinsert="INSERT INTO need_merge_authorities (authid, done) ".
	"VALUES (?,?)";
      $dbh->do($sqlinsert,undef,($authid,0));
  }
  logaction( "AUTHORITIES", "MODIFY", $authid, "authority BEFORE=>" . $oldrecord->as_formatted ) if C4::Context->preference("AuthoritiesLog");
  return $authid;
}

=head2 GetAuthorityXML 

  $marcxml= &GetAuthorityXML( $authid)

returns xml form of record $authid

=cut

sub GetAuthorityXML {
  # Returns MARC::XML of the authority passed in parameter.
  my ( $authid ) = @_;
  if (uc(C4::Context->preference('marcflavour')) eq 'UNIMARC') {
      my $dbh=C4::Context->dbh;
      my $sth = $dbh->prepare("select marcxml from auth_header where authid=? "  );
      $sth->execute($authid);
      my ($marcxml)=$sth->fetchrow;
      return $marcxml;
  }
  else { 
      # for MARC21, call GetAuthority instead of
      # getting the XML directly since we may
      # need to fix up the location of the authority
      # code -- note that this is reasonably safe
      # because GetAuthorityXML is used only by the 
      # indexing processes like zebraqueue_start.pl
      my $record = GetAuthority($authid);
      return $record->as_xml_record('MARC21');
  }
}

=head2 GetAuthority 

  $record= &GetAuthority( $authid)

Returns MARC::Record of the authority passed in parameter.

=cut

sub GetAuthority {
    my ($authid)=@_;
    my $authority = Koha::Authority->get_from_authid($authid);
    return unless $authority;
    return ($authority->record);
}

=head2 GetAuthType 

  $result = &GetAuthType($authtypecode)

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


=head2 FindDuplicateAuthority

  $record= &FindDuplicateAuthority( $record, $authtypecode)

return $authid,Summary if duplicate is found.

Comments : an improvement would be to return All the records that match.

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
    my $QParser;
    $QParser = C4::Context->queryparser if (C4::Context->preference('UseQueryParser'));
    my $op;
    if ($QParser) {
        $op = '&&';
    } else {
        $op = 'and';
    }
    my $query='at:'.$authtypecode.' ';
    my $filtervalues=qr([\001-\040\Q!'"`#$%&*+,-./:;<=>?@(){[}_|~\E\]]);
    if ($record->field($auth_tag_to_report)) {
        foreach ($record->field($auth_tag_to_report)->subfields()) {
            $_->[1]=~s/$filtervalues/ /g; $query.= " $op he:\"".$_->[1]."\"" if ($_->[0]=~/[A-z]/);
        }
    }
    my ($error, $results, $total_hits) = C4::Search::SimpleSearch( $query, 0, 1, [ "authorityserver" ] );
    # there is at least 1 result => return the 1st one
    if (!defined $error && @{$results} ) {
        my $marcrecord = C4::Search::new_record_from_zebra(
            'authorityserver',
            $results->[0]
        );
        return $marcrecord->field('001')->data,BuildSummary($marcrecord,$marcrecord->field('001')->data,$authtypecode);
    }
    # no result, returns nothing
    return;
}

=head2 BuildSummary

  $summary= &BuildSummary( $record, $authid, $authtypecode)

Returns a hashref with a summary of the specified record.

Comment : authtypecode can be infered from both record and authid.
Moreover, authid can also be inferred from $record.
Would it be interesting to delete those things.

=cut

sub BuildSummary {
    ## give this a Marc record to return summary
    my ($record,$authid,$authtypecode)=@_;
    my $dbh=C4::Context->dbh;
    my %summary;
    my $summary_template;
    # handle $authtypecode is NULL or eq ""
    if ($authtypecode) {
        my $authref = GetAuthType($authtypecode);
        $summary{authtypecode} = $authref->{authtypecode};
        $summary{type} = $authref->{authtypetext};
        $summary_template = $authref->{summary};
        # for MARC21, the authority type summary displays a label meant for
        # display
        if (C4::Context->preference('marcflavour') ne 'UNIMARC') {
            $summary{summary} = $authref->{summary};
        }
    }
    my $marc21subfields = 'abcdfghjklmnopqrstuvxyz68';
    my %marc21controlrefs = ( 'a' => 'earlier',
        'b' => 'later',
        'd' => 'acronym',
        'f' => 'musical',
        'g' => 'broader',
        'h' => 'narrower',
        'n' => 'notapplicable',
        'i' => 'subfi',
        't' => 'parent'
    );
    my %unimarc_relation_from_code = (
        g => 'broader',
        h => 'narrower',
        a => 'seealso',
    );
    my %thesaurus;
    $thesaurus{'1'}="Peuples";
    $thesaurus{'2'}="Anthroponymes";
    $thesaurus{'3'}="Oeuvres";
    $thesaurus{'4'}="Chronologie";
    $thesaurus{'5'}="Lieux";
    $thesaurus{'6'}="Sujets";
    #thesaurus a remplir
    my $reported_tag;
# if the library has a summary defined, use it. Otherwise, build a standard one
# FIXME - it appears that the summary field in the authority frameworks
#         can work as a display template.  However, this doesn't
#         suit the MARC21 version, so for now the "templating"
#         feature will be enabled only for UNIMARC for backwards
#         compatibility.
    if ($summary_template and C4::Context->preference('marcflavour') eq 'UNIMARC') {
        my @fields = $record->fields();
#             $reported_tag = '$9'.$result[$counter];
        my @repets;
        foreach my $field (@fields) {
            my $tag = $field->tag();
            my $tagvalue = $field->as_string();
            my $localsummary= $summary_template;
            $localsummary =~ s/\[(.?.?.?.?)$tag\*(.*?)\]/$1$tagvalue$2\[$1$tag$2\]/g;
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
                    $localsummary =~ s/\[(.?.?.?.?)$tagsubf(.*?)\]/$1$subfieldvalue$2\[$1$tagsubf$2\]/g;
                }
            }
            if ($localsummary ne $summary_template) {
                $localsummary =~ s/\[(.*?)\]//g;
                $localsummary =~ s/\n/<br>/g;
                push @repets, $localsummary;
            }
        }
        $summary{repets} = \@repets;
    }
    my @authorized;
    my @notes;
    my @seefrom;
    my @seealso;
    my @otherscript;
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
# construct UNIMARC summary, that is quite different from MARC21 one
# accepted form
        foreach my $field ($record->field('2..')) {
            push @authorized, {
                heading => $field->as_string('abcdefghijlmnopqrstuvwxyz'),
                hemain  => ( $field->subfield('a') // undef ),
                field   => $field->tag(),
            };
        }
# rejected form(s)
        foreach my $field ($record->field('3..')) {
            push @notes, { note => $field->subfield('a'), field => $field->tag() };
        }
        foreach my $field ($record->field('4..')) {
            my $thesaurus = $field->subfield('2') ? "thes. : ".$thesaurus{"$field->subfield('2')"}." : " : '';
            push @seefrom, {
                heading => $thesaurus . $field->as_string('abcdefghijlmnopqrstuvwxyz'),
                hemain  => ( $field->subfield('a') // undef ),
                type    => 'seefrom',
                field   => $field->tag(),
            };
        }

        # see :
        @seealso = map {
            my $type = $unimarc_relation_from_code{$_->subfield('5') || 'a'};
            my $heading = $_->as_string('abcdefgjxyz');
            {
                field   => $_->tag,
                type    => $type,
                heading => $heading,
                hemain  => ( $_->subfield('a') // undef ),
                search  => $heading,
                authid  => ( $_->subfield('9') // undef ),
            }
        } $record->field('5..');

        # Other forms
        @otherscript = map { {
            lang      => length ($_->subfield('8')) == 6 ? substr ($_->subfield('8'), 3, 3) : $_->subfield('8') || '',
            term      => $_->subfield('a') . ($_->subfield('b') ? ', ' . $_->subfield('b') : ''),
            direction => 'ltr',
            field     => $_->tag,
        } } $record->field('7..');

    } else {
# construct MARC21 summary
# FIXME - looping over 1XX is questionable
# since MARC21 authority should have only one 1XX
        my $subfields_to_report;
        foreach my $field ($record->field('1..')) {
            my $tag = $field->tag();
            next if "152" eq $tag;
# FIXME - 152 is not a good tag to use
# in MARC21 -- purely local tags really ought to be
# 9XX
            if ($tag eq '100') {
                $subfields_to_report = 'abcdefghjklmnopqrstvxyz';
            } elsif ($tag eq '110') {
                $subfields_to_report = 'abcdefghklmnoprstvxyz';
            } elsif ($tag eq '111') {
                $subfields_to_report = 'acdefghklnpqstvxyz';
            } elsif ($tag eq '130') {
                $subfields_to_report = 'adfghklmnoprstvxyz';
            } elsif ($tag eq '148') {
                $subfields_to_report = 'abvxyz';
            } elsif ($tag eq '150') {
                $subfields_to_report = 'abvxyz';
            } elsif ($tag eq '151') {
                $subfields_to_report = 'avxyz';
            } elsif ($tag eq '155') {
                $subfields_to_report = 'abvxyz';
            } elsif ($tag eq '180') {
                $subfields_to_report = 'vxyz';
            } elsif ($tag eq '181') {
                $subfields_to_report = 'vxyz';
            } elsif ($tag eq '182') {
                $subfields_to_report = 'vxyz';
            } elsif ($tag eq '185') {
                $subfields_to_report = 'vxyz';
            }
            if ($subfields_to_report) {
                push @authorized, {
                    heading => $field->as_string($subfields_to_report),
                    hemain  => ( $field->subfield( substr($subfields_to_report, 0, 1) ) // undef ),
                    field   => $tag,
                };
            } else {
                push @authorized, {
                    heading => $field->as_string(),
                    hemain  => ( $field->subfield( 'a' ) // undef ),
                    field   => $tag,
                };
            }
        }
        foreach my $field ($record->field('4..')) { #See From
            my $type = 'seefrom';
            $type = ($marc21controlrefs{substr $field->subfield('w'), 0, 1} || '') if ($field->subfield('w'));
            if ($type eq 'notapplicable') {
                $type = substr $field->subfield('w'), 2, 1;
                $type = 'earlier' if $type && $type ne 'n';
            }
            if ($type eq 'subfi') {
                push @seefrom, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => ($field->subfield('i') || ''),
                    field   => $field->tag(),
                };
            } else {
                push @seefrom, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => $type,
                    field   => $field->tag(),
                };
            }
        }
        foreach my $field ($record->field('5..')) { #See Also
            my $type = 'seealso';
            $type = ($marc21controlrefs{substr $field->subfield('w'), 0, 1} || '') if ($field->subfield('w'));
            if ($type eq 'notapplicable') {
                $type = substr $field->subfield('w'), 2, 1;
                $type = 'earlier' if $type && $type ne 'n';
            }
            if ($type eq 'subfi') {
                push @seealso, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => $field->subfield('i'),
                    field   => $field->tag(),
                    search  => $field->as_string($marc21subfields) || '',
                    authid  => $field->subfield('9') || ''
                };
            } else {
                push @seealso, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => $type,
                    field   => $field->tag(),
                    search  => $field->as_string($marc21subfields) || '',
                    authid  => $field->subfield('9') || ''
                };
            }
        }
        foreach my $field ($record->field('6..')) {
            push @notes, { note => $field->as_string(), field => $field->tag() };
        }
        foreach my $field ($record->field('880')) {
            my $linkage = $field->subfield('6');
            my $category = substr $linkage, 0, 1;
            if ($category eq '1') {
                $category = 'preferred';
            } elsif ($category eq '4') {
                $category = 'seefrom';
            } elsif ($category eq '5') {
                $category = 'seealso';
            }
            my $type;
            if ($field->subfield('w')) {
                $type = $marc21controlrefs{substr $field->subfield('w'), '0'};
            } else {
                $type = $category;
            }
            my $direction = $linkage =~ m#/r$# ? 'rtl' : 'ltr';
            push @otherscript, { term => $field->as_string($subfields_to_report), category => $category, type => $type, direction => $direction, linkage => $linkage };
        }
    }
    $summary{mainentry} = $authorized[0]->{heading};
    $summary{mainmainentry} = $authorized[0]->{hemain};
    $summary{authorized} = \@authorized;
    $summary{notes} = \@notes;
    $summary{seefrom} = \@seefrom;
    $summary{seealso} = \@seealso;
    $summary{otherscript} = \@otherscript;
    return \%summary;
}

=head2 GetAuthorizedHeading

  $heading = &GetAuthorizedHeading({ record => $record, authid => $authid })

Takes a MARC::Record object describing an authority record or an authid, and
returns a string representation of the first authorized heading. This routine
should be considered a temporary shim to ease the future migration of authority
data from C4::AuthoritiesMarc to the object-oriented Koha::*::Authority.

=cut

sub GetAuthorizedHeading {
    my $args = shift;
    my $record;
    unless ($record = $args->{record}) {
        return unless $args->{authid};
        $record = GetAuthority($args->{authid});
    }
    return unless (ref $record eq 'MARC::Record');
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
# construct UNIMARC summary, that is quite different from MARC21 one
# accepted form
        foreach my $field ($record->field('2..')) {
            return $field->as_string('abcdefghijlmnopqrstuvwxyz');
        }
    } else {
        foreach my $field ($record->field('1..')) {
            my $tag = $field->tag();
            next if "152" eq $tag;
# FIXME - 152 is not a good tag to use
# in MARC21 -- purely local tags really ought to be
# 9XX
            if ($tag eq '100') {
                return $field->as_string('abcdefghjklmnopqrstvxyz68');
            } elsif ($tag eq '110') {
                return $field->as_string('abcdefghklmnoprstvxyz68');
            } elsif ($tag eq '111') {
                return $field->as_string('acdefghklnpqstvxyz68');
            } elsif ($tag eq '130') {
                return $field->as_string('adfghklmnoprstvxyz68');
            } elsif ($tag eq '148') {
                return $field->as_string('abvxyz68');
            } elsif ($tag eq '150') {
                return $field->as_string('abvxyz68');
            } elsif ($tag eq '151') {
                return $field->as_string('avxyz68');
            } elsif ($tag eq '155') {
                return $field->as_string('abvxyz68');
            } elsif ($tag eq '180') {
                return $field->as_string('vxyz68');
            } elsif ($tag eq '181') {
                return $field->as_string('vxyz68');
            } elsif ($tag eq '182') {
                return $field->as_string('vxyz68');
            } elsif ($tag eq '185') {
                return $field->as_string('vxyz68');
            } else {
                return $field->as_string();
            }
        }
    }
    return;
}

=head2 BuildAuthHierarchies

  $text= &BuildAuthHierarchies( $authid, $force)

return text containing trees for hierarchies
for them to be stored in auth_header

Example of text:
122,1314,2452;1324,2342,3,2452

=cut

sub BuildAuthHierarchies{
    my $authid = shift @_;
#   warn "authid : $authid";
    my $force = shift @_ || (C4::Context->preference('marcflavour') eq 'UNIMARC' ? 0 : 1);
    my @globalresult;
    my $dbh=C4::Context->dbh;
    my $hierarchies;
    my $data = GetHeaderAuthority($authid);
    if ($data->{'authtrees'} and not $force){
        return $data->{'authtrees'};
#  } elsif ($data->{'authtrees'}){
#    $hierarchies=$data->{'authtrees'};
    } else {
        my $record = GetAuthority($authid);
        my $found;
        return unless $record;
        foreach my $field ($record->field('5..')){
            my $broader = 0;
            $broader = 1 if (
                    (C4::Context->preference('marcflavour') eq 'UNIMARC' && $field->subfield('5') && $field->subfield('5') eq 'g') ||
                    (C4::Context->preference('marcflavour') ne 'UNIMARC' && $field->subfield('w') && substr($field->subfield('w'), 0, 1) eq 'g'));
            if ($broader) {
                my $subfauthid=_get_authid_subfield($field) || '';
                next if ($subfauthid eq $authid);
                my $parentrecord = GetAuthority($subfauthid);
                next unless $parentrecord;
                my $localresult=$hierarchies;
                my $trees;
                $trees = BuildAuthHierarchies($subfauthid);
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

=head2 BuildAuthHierarchy

  $ref= &BuildAuthHierarchy( $record, $class,$authid)

return a hashref in order to display hierarchy for record and final Authid $authid

"loopparents"
"loopchildren"
"class"
"loopauthid"
"current_value"
"value"

=cut

sub BuildAuthHierarchy{
    my $record = shift @_;
    my $class = shift @_;
    my $authid_constructed = shift @_;
    return unless ($record && $record->field('001'));
    my $authid=$record->field('001')->data();
    my %cell;
    my $parents=""; my $children="";
    my (@loopparents,@loopchildren);
    my $marcflavour = C4::Context->preference('marcflavour');
    my $relationshipsf = $marcflavour eq 'UNIMARC' ? '5' : 'w';
    foreach my $field ($record->field('5..')){
        my $subfauthid=_get_authid_subfield($field);
        if ($subfauthid && $field->subfield($relationshipsf) && $field->subfield('a')){
            my $relationship = substr($field->subfield($relationshipsf), 0, 1);
            if ($relationship eq 'h'){
                push @loopchildren, { "authid"=>$subfauthid,"value"=>$field->subfield('a')};
            }
            elsif ($relationship eq 'g'){
                push @loopparents, { "authid"=>$subfauthid,"value"=>$field->subfield('a')};
            }
# brothers could get in there with an else
        }
    }
    $cell{"parents"}=\@loopparents;
    $cell{"children"}=\@loopchildren;
    $cell{"class"}=$class;
    $cell{"authid"}=$authid;
    $cell{"current_value"} =1 if ($authid eq $authid_constructed);
    $cell{"value"}=C4::Context->preference('marcflavour') eq 'UNIMARC' ? $record->subfield('2..',"a") : $record->subfield('1..', 'a');
    return \%cell;
}

=head2 BuildAuthHierarchyBranch

  $branch = &BuildAuthHierarchyBranch( $tree, $authid[, $cnt])

Return a data structure representing an authority hierarchy
given a list of authorities representing a single branch in
an authority hierarchy tree. $authid is the current node in
the tree (which may or may not be somewhere in the middle).
$cnt represents the level of the upper-most item, and is only
used when BuildAuthHierarchyBranch is called recursively (i.e.,
don't ever pass in anything but zero to it).

=cut

sub BuildAuthHierarchyBranch {
    my ($tree, $authid, $cnt) = @_;
    $cnt |= 0;
    my $elementdata = GetAuthority(shift @$tree);
    my $branch = BuildAuthHierarchy($elementdata,"child".$cnt, $authid);
    if (scalar @$tree > 0) {
        my $nextBranch = BuildAuthHierarchyBranch($tree, $authid, ++$cnt);
        my $nextAuthid = $nextBranch->{authid};
        my $found;
        # If we already have the next branch listed as a child, let's
        # replace the old listing with the new one. If not, we will add
        # the branch at the end.
        foreach my $cell (@{$branch->{children}}) {
            if ($cell->{authid} eq $nextAuthid) {
                $cell = $nextBranch;
                $found = 1;
                last;
            }
        }
        push @{$branch->{children}}, $nextBranch unless $found;
    }
    return $branch;
}

=head2 GenerateHierarchy

  $hierarchy = &GenerateHierarchy($authid);

Return an arrayref holding one or more "trees" representing
authority hierarchies.

=cut

sub GenerateHierarchy {
    my ($authid) = @_;
    my $trees    = BuildAuthHierarchies($authid);
    my @trees    = split /;/,$trees ;
    push @trees,$trees unless (@trees);
    my @loophierarchies;
    foreach my $tree (@trees){
        my @tree=split /,/,$tree;
        push @tree, $tree unless (@tree);
        my $branch = BuildAuthHierarchyBranch(\@tree, $authid);
        push @loophierarchies, [ $branch ];
    }
    return \@loophierarchies;
}

sub _get_authid_subfield{
    my ($field)=@_;
    return $field->subfield('9')||$field->subfield('3');
}
=head2 GetHeaderAuthority

  $ref= &GetHeaderAuthority( $authid)

return a hashref in order auth_header table data

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

  $ref= &AddAuthorityTrees( $authid, $trees)

return success or failure

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

  $ref= &merge(mergefrom,$MARCfrom,$mergeto,$MARCto)

Could add some feature : Migrating from a typecode to an other for instance.
Then we should add some new parameter : bibliotargettag, authtargettag

=cut

sub merge {
    my ($mergefrom,$MARCfrom,$mergeto,$MARCto) = @_;
    my ($counteditedbiblio,$countunmodifiedbiblio,$counterrors)=(0,0,0);        
    my $dbh=C4::Context->dbh;
    my $authtypecodefrom = GetAuthTypeCode($mergefrom);
    my $authtypecodeto = GetAuthTypeCode($mergeto);
#     warn "mergefrom : $authtypecodefrom $mergefrom mergeto : $authtypecodeto $mergeto ";
    # return if authority does not exist
    return "error MARCFROM not a marcrecord ".Data::Dumper::Dumper($MARCfrom) if scalar($MARCfrom->fields()) == 0;
    return "error MARCTO not a marcrecord".Data::Dumper::Dumper($MARCto) if scalar($MARCto->fields()) == 0;
    # search the tag to report
    my $sth = $dbh->prepare("select auth_tag_to_report from auth_types where authtypecode=?");
    $sth->execute($authtypecodefrom);
    my ($auth_tag_to_report_from) = $sth->fetchrow;
    $sth->execute($authtypecodeto);
    my ($auth_tag_to_report_to) = $sth->fetchrow;
    
    my @record_to;
    @record_to = $MARCto->field($auth_tag_to_report_to)->subfields() if $MARCto->field($auth_tag_to_report_to);
    my @record_from;
    @record_from = $MARCfrom->field($auth_tag_to_report_from)->subfields() if $MARCfrom->field($auth_tag_to_report_from);
    
    my @reccache;
    # search all biblio tags using this authority.
    #Getting marcbiblios impacted by the change.
    #zebra connection
    my $oConnection=C4::Context->Zconn("biblioserver",0);
    # We used to use XML syntax here, but that no longer works.
    # Thankfully, we don't need it.
    my $query;
    $query= "an=".$mergefrom;
    my $oResult = $oConnection->search(new ZOOM::Query::CCL2RPN( $query, $oConnection ));
    my $count = 0;
    if  ($oResult) {
        $count=$oResult->size();
    }
    my $z=0;
    while ( $z<$count ) {
        my $marcrecordzebra = C4::Search::new_record_from_zebra(
            'biblioserver',
            $oResult->record($z)->raw()
        );
        my ( $biblionumbertagfield, $biblionumbertagsubfield ) = &GetMarcFromKohaField( "biblio.biblionumber", '' );
        my $i = ($biblionumbertagfield < 10)
            ? $marcrecordzebra->field( $biblionumbertagfield )->data
            : $marcrecordzebra->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
        my $marcrecorddb = GetMarcBiblio($i);
        push @reccache, $marcrecorddb;
        $z++;
    }
    $oResult->destroy();
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
        foreach my $tagfield (@tags_using_authtype){
#             warn "tagfield : $tagfield ";
            foreach my $field ($marcrecord->field($tagfield)){
                # biblio is linked to authority with $9 subfield containing authid
                my $auth_number=$field->subfield("9");
                my $tag=$field->tag();          
                if ($auth_number==$mergefrom) {
                my $field_to=MARC::Field->new(($tag_to?$tag_to:$tag),$field->indicator(1),$field->indicator(2),"9"=>$mergeto);
		my $exclude='9';
                foreach my $subfield (grep {$_->[0] ne '9'} @record_to) {
                    $field_to->add_subfields($subfield->[0] =>$subfield->[1]);
		    $exclude.= $subfield->[0];
                }
		$exclude='['.$exclude.']';
#		add subfields in $field not included in @record_to
		my @restore= grep {$_->[0]!~/$exclude/} $field->subfields();
                foreach my $subfield (@restore) {
                   $field_to->add_subfields($subfield->[0] =>$subfield->[1]);
		}
                $marcrecord->delete_field($field);
                $marcrecord->insert_grouped_field($field_to);            
                $update=1;
                }
            }#for each tag
        }#foreach tagfield
        my ($bibliotag,$bibliosubf) = GetMarcFromKohaField("biblio.biblionumber","") ;
        my $biblionumber;
        if ($bibliotag<10){
            $biblionumber=$marcrecord->field($bibliotag)->data;
        }
        else {
            $biblionumber=$marcrecord->subfield($bibliotag,$bibliosubf);
        }
        unless ($biblionumber){
            warn "pas de numéro de notice bibliographique dans : ".$marcrecord->as_formatted;
            next;
        }
        if ($update==1){
            &ModBiblio($marcrecord,$biblionumber,GetFrameworkCode($biblionumber)) ;
            $counteditedbiblio++;
            warn $counteditedbiblio if (($counteditedbiblio % 10) and $ENV{DEBUG});
        }    
    }#foreach $marc
    return $counteditedbiblio;  
  # now, find every other authority linked with this authority
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

  my ($tag, $subfield) = get_auth_type_location($auth_type_code);

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
    if (defined $tag and defined $subfield and $tag != 0 and $subfield ne '' and $subfield ne ' ') {
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

Koha Development Team <http://koha-community.org/>

Paul POULAIN paul.poulain@free.fr

=cut

