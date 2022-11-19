package C4::AuthoritiesMarc;

# Copyright 2000-2002 Katipo Communications
# Copyright 2018 The National Library of Finland, University of Helsinki
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
use MARC::Field;

use C4::Context;
use C4::Biblio qw( GetFrameworkCode ModBiblio );
use C4::Search qw( FindDuplicate new_record_from_zebra );
use C4::AuthoritiesMarc::MARC21;
use C4::AuthoritiesMarc::UNIMARC;
use C4::Charset qw( SetUTF8Flag );
use C4::Log qw( logaction );
use Koha::MetadataRecord::Authority;
use Koha::Authorities;
use Koha::Authority::MergeRequests;
use Koha::Authority::Types;
use Koha::Authority;
use Koha::Libraries;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;
use Koha::SearchEngine::Search;

our (@ISA, @EXPORT_OK);
BEGIN {

    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
      GetTagsLabels
      GetAuthMARCFromKohaField

      AddAuthority
      ModAuthority
      DelAuthority
      GetAuthority
      GetAuthorityXML
      GetAuthorizedHeading

      SearchAuthorities

      BuildSummary
      BuildAuthHierarchies
      BuildAuthHierarchy
      GenerateHierarchy
      GetHeaderAuthority
      AddAuthorityTrees
      CompareFieldWithAuthority

      merge
      FindDuplicateAuthority

      GuessAuthTypeCode
      GuessAuthId
      compare_fields
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
    $sortby="" unless $sortby;
    my $query;
    my $qpquery = '';
    my $attr = '';
        # the marclist may contain "mainentry". In this case, search the tag_to_report, that depends on
        # the authtypecode. Then, search on $a of this tag_to_report
        # also store main entry MARC tag, to extract it at end of search
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
                elsif ( @$tags[$i] eq "all" ) {
                    $attr = " \@attr 1=Any ";
                }
                else {    # Use the index passed in params
                    $attr = " \@attr 1=" . @$tags[$i] . " ";
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
                $attr .= " \@attr 3=2 \@attr 4=1 \@attr 5=1 \@attr 6=3 "
                  ;    #Firstinfield Phrase, Right truncated, Complete field
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
        }    #if value
    }
    ##Add how many queries generated
    if ( defined $query && $query =~ /\S+/ ) {
        #NOTE: This code path is used by authority search in cataloguing plugins...
        #FIXME: This does not quite work the way the author probably intended.
        #It creates a ($query prefix) AND (query 1) AND (query 2) structure instead of
        #($query prefix) AND (query 1 AND query 2)
        $query = $and x $attr_cnt . $query . ( defined $q2 ? $q2 : '' );
    } else {
        #NOTE: This code path is used by authority search in authority home and record matching rules...
        my $op_prefix = '';
        #NOTE: Without the following code, multiple queries will never be joined together
        #with a Boolean operator.
        if ( $attr_cnt > 1 ) {
            #NOTE: We always need 1 less operator than we have operands,
            #so long as there is more than 1 operand
            my $or_cnt = $attr_cnt - 1;
            #NOTE: We hard-code OR here because that's what Elasticsearch does
            $op_prefix = ' @or ' x $or_cnt;
            #NOTE: This evaluates to a logical structure like (query 1) OR (query 2) OR (query 3)
        }
        $query = $op_prefix . $q2;
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
    $query=($query?$query:"\@attr 1=_ALLRECORDS \@attr 2=103 ''");
    $query="\@or $orderstring $query" if $orderstring;

    $offset = 0 if not defined $offset or $offset < 0;
    my $counter = $offset;
    $length=10 unless $length;
    my @oAuth;
    my $i;
    $oAuth[0]=C4::Context->Zconn("authorityserver" , 1);
    my $Anewq= ZOOM::Query::PQF->new($query,$oAuth[0]);
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

        SetUTF8Flag( $authrecord );

        my $authid=$authrecord->field('001')->data();
        my %newline;
        $newline{authid} = $authid;
        if ( !$skipmetadata ) {
            my $auth_tag_to_report;
            $auth_tag_to_report = Koha::Authority::Types->find($authtypecode)->auth_tag_to_report
                if $authtypecode;
            my $reported_tag;
            my $mainentry = $authrecord->field($auth_tag_to_report);
            if ($mainentry) {
                foreach ( $mainentry->subfields() ) {
                    $reported_tag .= '$' . $_->[0] . $_->[1];
                }
            }

            my ( $thisauthtype, $thisauthtypecode );
            if ( my $authority = Koha::Authorities->find($authid) ) {
                $thisauthtypecode = $authority->authtypecode;
                $thisauthtype = Koha::Authority::Types->find($thisauthtypecode);
            }
            unless (defined $thisauthtype) {
                $thisauthtypecode = $authtypecode;
                $thisauthtype = Koha::Authority::Types->find($thisauthtypecode);
            }
            my $summary = BuildSummary( $authrecord, $authid, $thisauthtypecode );

            if ( C4::Context->preference('ShowHeadingUse') ) {
                # checking valid heading use
                my $f008 = $authrecord->field('008');
                my $pos14to16 = substr( $f008->data, 14, 3 );
                my $main = substr( $pos14to16, 0, 1 );
                $newline{main} = 1 if $main eq 'a';
                my $subject = substr( $pos14to16, 1, 1);
                $newline{subject} = 1 if $subject eq 'a';
                my $series = substr( $pos14to16, 2, 1 );
                $newline{series} = 1 if $series eq 'a';
            }

            $newline{authtype}     = defined($thisauthtype) ?
                                        $thisauthtype->authtypetext : '';
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
                my $count = Koha::Authorities->get_usage_count({ authid => $finalresult[$z]{authid} });
                $finalresult[$z]{used}=$count;
            }# all $z's
        }

    }## if nbresult
    NOLUCK:
    $oAResult->destroy();
    # $oAuth[0]->destroy();

    return (\@finalresult, $nbresults);
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
        '147'=>{authtypecode=>'NAME_EVENT'},
        '148'=>{authtypecode=>'CHRON_TERM'},
        '150'=>{authtypecode=>'TOPIC_TERM'},
        '151'=>{authtypecode=>'GEOGR_NAME'},
        '155'=>{authtypecode=>'GENRE/FORM'},
        '162'=>{authtypecode=>'MED_PERFRM'},
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
  my $libfield = ($forlibrarian) ? 'liblibrarian' : 'libopac';


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
"SELECT tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,frameworkcode as authtypecode,value_builder,kohafield,seealso,hidden,isurl,defaultvalue, display_order
FROM auth_subfield_structure 
WHERE authtypecode=? 
ORDER BY tagfield, display_order, tagsubfield"
    );
    $sth->execute($authtypecode);

    my $subfield;
    my $authorised_value;
    my $value_builder;
    my $kohafield;
    my $seealso;
    my $hidden;
    my $isurl;
    my $defaultvalue;
    my $display_order;

    while (
        ( $tag,         $subfield,   $liblibrarian,   , $libopac,      $tab,
        $mandatory,     $repeatable, $authorised_value, $authtypecode,
        $value_builder, $kohafield,  $seealso,          $hidden,
        $isurl,         $defaultvalue, $display_order )
        = $sth->fetchrow
      )
    {
        $res->{$tag}->{$subfield}->{subfield}         = $subfield;
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
        $res->{$tag}->{$subfield}->{defaultvalue}     = $defaultvalue;
        $res->{$tag}->{$subfield}->{display_order}    = $display_order;
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
    my ( $record, $authid, $authtypecode, $params ) = @_;

    my $skip_record_index = $params->{skip_record_index} || 0;

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
        my $userenv = C4::Context->userenv;
        my $library;
        my $marcorgcode = C4::Context->preference('MARCOrgCode');
        if ( $userenv && $userenv->{'branch'} ) {
            $library = Koha::Libraries->find( $userenv->{'branch'} );
            # userenv's library could not exist because of a trick in misc/commit_file.pl (see FIXME and set_userenv statement)
            $marcorgcode = $library ? $library->get_effective_marcorgcode : $marcorgcode;
        }
		if (!$record->leader) {
			$record->leader($leader);
		}
		if (!$record->field('003')) {
			$record->insert_fields_ordered(
                MARC::Field->new('003', $marcorgcode),
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
            'a' => $marcorgcode,
            'c' => $marcorgcode,
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

    # Save record into auth_header, update 001
    my $action;
    my $authority;
    if (!$authid ) {
        $action = 'create';
        # Save a blank record, get authid
        $authority = Koha::Authority->new({ datecreated => \'NOW()', marcxml => '' })->store();
        $authority->discard_changes();
        $authid = $authority->authid;
        logaction( "AUTHORITIES", "ADD", $authid, "authority" ) if C4::Context->preference("AuthoritiesLog");
    } else {
        $action = 'modify';
        $authority = Koha::Authorities->find($authid);
    }

    # Insert/update the recordID in MARC record
    $record->delete_field( $record->field('001') );
    $record->insert_fields_ordered( MARC::Field->new( '001', $authid ) );
    # Update
    $authority->update({ authtypecode => $authtypecode, marc => $record->as_usmarc, marcxml => $record->as_xml_record($format) });

    unless ( $skip_record_index ) {
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
        $indexer->index_records( $authid, "specialUpdate", "authorityserver", $record );
    }

    _after_authority_action_hooks({ action => $action, authority_id => $authid });
    return ( $authid );
}

=head2 DelAuthority

    DelAuthority({ authid => $authid, [ skip_merge => 1 ] });

Deletes $authid and calls merge to cleanup linked biblio records.
Parameter skip_merge is used in authorities/merge.pl. You should normally not
use it.

skip_record_index will skip the indexation step.

=cut

sub DelAuthority {
    my ( $params ) = @_;
    my $authid = $params->{authid} || return;
    my $skip_merge = $params->{skip_merge};
    my $skip_record_index = $params->{skip_record_index} || 0;

    my $dbh = C4::Context->dbh;

    # Remove older pending merge requests for $authid to itself. (See bug 22437)
    my $condition = { authid => $authid, authid_new => [undef, 0, $authid], done => 0 };
    Koha::Authority::MergeRequests->search($condition)->delete;

    merge({ mergefrom => $authid }) if !$skip_merge;
    $dbh->do( "DELETE FROM auth_header WHERE authid=?", undef, $authid );
    logaction( "AUTHORITIES", "DELETE", $authid, "authority" ) if C4::Context->preference("AuthoritiesLog");
    unless ( $skip_record_index ) {
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
        $indexer->index_records( $authid, "recordDelete", "authorityserver", undef );
    }

    _after_authority_action_hooks({ action => 'delete', authority_id => $authid });
}

=head2 ModAuthority

  $authid= &ModAuthority($authid,$record,$authtypecode, [ { skip_merge => 1 ] )

Modifies authority record, optionally updates attached biblios.
The parameter skip_merge is optional and should be used with care.

skip_record_index will skip the indexation step.

=cut

sub ModAuthority {
    my ( $authid, $record, $authtypecode, $params ) = @_;

    my $skip_record_index = $params->{skip_record_index} || 0;

    my $oldrecord = GetAuthority($authid);
    #Now rewrite the $record to table with an add
    $authid = AddAuthority($record, $authid, $authtypecode, { skip_record_index => $skip_record_index });
    merge({ mergefrom => $authid, MARCfrom => $oldrecord, mergeto => $authid, MARCto => $record }) if !$params->{skip_merge};
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
    my $authority = Koha::MetadataRecord::Authority->get_from_authid($authid);
    return unless $authority;
    return ($authority->record);
}

=head2 FindDuplicateAuthority

  $record= &FindDuplicateAuthority( $record, $authtypecode)

return $authid,Summary if duplicate is found.

Comments : an improvement would be to return All the records that match.

=cut

sub FindDuplicateAuthority {

    my ($record,$authtypecode)=@_;
    my $dbh = C4::Context->dbh;
    my $auth_tag_to_report = Koha::Authority::Types->find($authtypecode)->auth_tag_to_report;
    # build a request for SearchAuthorities
    my $op = 'AND';
    my $query='at:"'.$authtypecode.'" '; # Quote authtype code to avoid unescaping slash in GENRE/FORM later
    my $filtervalues=qr([\001-\040\Q!'"`#$%&*+,-./:;<=>?@(){[}_|~\E\]]);
    if ($record->field($auth_tag_to_report)) {
        foreach ($record->field($auth_tag_to_report)->subfields()) {
            $_->[1]=~s/$filtervalues/ /g; $query.= " $op he:\"".$_->[1]."\"" if ($_->[0]=~/[A-z]/);
        }
    }
    my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::AUTHORITIES_INDEX});
    my ($error, $results, $total_hits) = $searcher->simple_search_compat( $query, 0, 1, [ 'authorityserver' ] );
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

Comment : authtypecode can be inferred from both record and authid.
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
        my $authref = Koha::Authority::Types->find($authtypecode);
        if ( $authref ) {
            $summary{authtypecode} = $authref->authtypecode;
            $summary{type} = $authref->authtypetext;
            $summary_template = $authref->summary;
            # for MARC21, the authority type summary displays a label meant for
            # display
            if (C4::Context->preference('marcflavour') ne 'UNIMARC') {
                $summary{label} = $authref->summary;
            } else {
                $summary{summary} = $authref->summary;
            }
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
    if ($summary{summary} and C4::Context->preference('marcflavour') eq 'UNIMARC') {
        my @matches = ($summary{summary} =~ m/\[(.*?)(\d{3})([\*a-z0-9])(.*?)\]/g);
        my (@textbefore, @tag, @subtag, @textafter);
        for(my $i = 0; $i < scalar @matches; $i++){
            push @textbefore, $matches[$i] if($i%4 == 0);
            push @tag,        $matches[$i] if($i%4 == 1);
            push @subtag,     $matches[$i] if($i%4 == 2);
            push @textafter,  $matches[$i] if($i%4 == 3);
        }
        for(my $i = scalar @tag; $i >= 0; $i--){
            my $textbefore = $textbefore[$i] || '';
            my $tag = $tag[$i] || '';
            my $subtag = $subtag[$i] || '';
            my $textafter = $textafter[$i] || '';
            my $value = '';
            my $field = $record->field($tag);
            if ( $field ) {
                if($subtag eq '*') {
                    if($tag < 10) {
                        $value = $textbefore . $field->data() . $textafter;
                    }
                } else {
                    my @subfields = $field->subfield($subtag);
                    if(@subfields > 0) {
                        $value = $textbefore . join (" - ", @subfields) . $textafter;
                    }
                }
            }
            $summary{summary} =~ s/\[\Q$textbefore$tag$subtag$textafter\E\]/$value/;
        }
        $summary{summary} =~ s/\\n/<br \/>/g;
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
        use C4::Heading::MARC21;
        my $handler = C4::Heading::MARC21->new();
        my $subfields_to_report;
        foreach my $field ($record->field('1..')) {
            my $tag = $field->tag();
            next if "152" eq $tag;
# FIXME - 152 is not a good tag to use
# in MARC21 -- purely local tags really ought to be
# 9XX

            $subfields_to_report = $handler->get_auth_heading_subfields_to_report($tag);

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
                    hemain  => scalar $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => ($field->subfield('i') || ''),
                    field   => $field->tag(),
                };
            } else {
                push @seefrom, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => scalar $field->subfield( substr($marc21subfields, 0, 1) ),
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
                    hemain  => scalar $field->subfield( substr($marc21subfields, 0, 1) ),
                    type    => scalar $field->subfield('i'),
                    field   => $field->tag(),
                    search  => $field->as_string($marc21subfields) || '',
                    authid  => $field->subfield('9') || ''
                };
            } else {
                push @seealso, {
                    heading => $field->as_string($marc21subfields),
                    hemain  => scalar $field->subfield( substr($marc21subfields, 0, 1) ),
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
        use C4::Heading::MARC21;
        my $handler = C4::Heading::MARC21->new();

        foreach my $field ($record->field('1..')) {
            my $subfields = $handler->get_valid_bib_heading_subfields($field->tag());
            return $field->as_string($subfields) if ($subfields);
        }
    }
    return;
}

=head2 CompareFieldWithAuthority

  $match = &CompareFieldWithAuthority({ field => $field, authid => $authid })

Takes a MARC::Field from a bibliographic record and an authid, and returns true if they match.

=cut

sub CompareFieldWithAuthority {
    my $args = shift;

    my $record = GetAuthority($args->{authid});
    return unless (ref $record eq 'MARC::Record');
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        # UNIMARC has same subfields for bibs and authorities
        foreach my $field ($record->field('2..')) {
            return compare_fields($field, $args->{field}, 'abcdefghijlmnopqrstuvwxyz');
        }
    } else {
        use C4::Heading::MARC21;
        my $handler = C4::Heading::MARC21->new();

        foreach my $field ($record->field('1..')) {
            my $subfields = $handler->get_valid_bib_heading_subfields($field->tag());
            return compare_fields($field, $args->{field}, $subfields) if ($subfields);
        }
    }
    return 0;
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

    $count = merge({
        mergefrom => $mergefrom,
        [ MARCfrom => $MARCfrom, ]
        [ mergeto => $mergeto, ]
        [ MARCto => $MARCto, ]
        [ biblionumbers => [ $a, $b, $c ], ]
        [ override_limit => 1, ]
    });

Merge biblios linked to authority $mergefrom (mandatory parameter).
If $mergeto equals mergefrom, the linked biblio field is updated.
If $mergeto is different, the biblio field will be linked to $mergeto.
If $mergeto is missing, the biblio field is deleted.

MARCfrom is used to determine if a cleared subfield in the authority record
should be removed from a biblio. MARCto is used to populate the biblio
record with the updated values; if you do not pass it, the biblio field
will be deleted (same as missing mergeto).

Normally all biblio records linked to $mergefrom, will be considered. But
you can pass specific numbers via the biblionumbers parameter.

The parameter override_limit is used by the cron job to force larger
postponed merges.

Note: Although $mergefrom and $mergeto will normally be of the same
authority type, merge also supports moving to another authority type.

=cut

sub merge {
    my ( $params ) = @_;
    my $mergefrom = $params->{mergefrom} || return;
    my $MARCfrom = $params->{MARCfrom};
    my $mergeto = $params->{mergeto};
    my $MARCto = $params->{MARCto};
    my $override_limit = $params->{override_limit};

    # If we do not have biblionumbers, we get all linked biblios if the
    # number of linked records does not exceed the limit UNLESS we override.
    my @biblionumbers;
    if( $params->{biblionumbers} ) {
        @biblionumbers = @{ $params->{biblionumbers} };
    } elsif( $override_limit ) {
        @biblionumbers = Koha::Authorities->linked_biblionumbers({ authid => $mergefrom });
    } else { # now first check number of linked records
        my $max = C4::Context->preference('AuthorityMergeLimit') // 0;
        my $hits = Koha::Authorities->get_usage_count({ authid => $mergefrom });
        if( $hits > 0 && $hits <= $max ) {
            @biblionumbers = Koha::Authorities->linked_biblionumbers({ authid => $mergefrom });
        } elsif( $hits > $max ) { #postpone this merge to the cron job
            Koha::Authority::MergeRequest->new({
                authid => $mergefrom,
                oldrecord => $MARCfrom,
                authid_new => $mergeto,
            })->store;
        }
    }
    return 0 if !@biblionumbers;

    # Search authtypes and reporting tags
    my $authfrom = Koha::Authorities->find($mergefrom);
    my $authto = Koha::Authorities->find($mergeto);
    my $authtypefrom;
    my $authtypeto   = $authto ? Koha::Authority::Types->find($authto->authtypecode) : undef;
    if( $mergeto && $mergefrom == $mergeto && $MARCfrom ) {
        # bulkmarcimport may have changed the authtype; see BZ 19693
        my $old_type = $MARCfrom->subfield( get_auth_type_location() ); # going via default
        if( $old_type && $authto && $old_type ne $authto->authtypecode ) {
            # Type change: handled by simulating a postponed merge where the auth record has been deleted already
            # This triggers a walk through all auth controlled tags
            undef $authfrom;
        }
    }
    $authtypefrom = Koha::Authority::Types->find($authfrom->authtypecode) if $authfrom;
    my $auth_tag_to_report_from = $authtypefrom ? $authtypefrom->auth_tag_to_report : '';
    my $auth_tag_to_report_to   = $authtypeto ? $authtypeto->auth_tag_to_report : '';

    my @record_to;
    @record_to = $MARCto->field($auth_tag_to_report_to)->subfields() if $auth_tag_to_report_to && $MARCto && $MARCto->field($auth_tag_to_report_to);
    # Exceptional: If MARCto and authtypeto exist but $auth_tag_to_report_to
    # is empty, make sure that $9 and $a remain (instead of clearing the
    # reference) in order to allow for data recovery.
    # Note: We need $a too, since a single $9 does not pass ModBiblio.
    if( $MARCto && $authtypeto && !@record_to  ) {
        push @record_to, [ 'a', ' ' ]; # do not remove the space
    }

    my @record_from;
    if( !$authfrom && $MARCfrom && $MARCfrom->field('1..','2..') ) {
    # postponed merge, authfrom was deleted and MARCfrom only contains the old reporting tag (and possibly a 100 for UNIMARC)
    # 2XX is for UNIMARC; we use -1 in order to skip 100 in UNIMARC; this will not impact MARC21, since there is only one tag
        @record_from = ( $MARCfrom->field('1..','2..') )[-1]->subfields;
    } elsif( $auth_tag_to_report_from && $MARCfrom && $MARCfrom->field($auth_tag_to_report_from) ) {
        @record_from = $MARCfrom->field($auth_tag_to_report_from)->subfields;
    }

    # Get all candidate tags for the change
    # (This will reduce the search scope in marc records).
    # For a deleted authority record, we scan all auth controlled fields
    my $dbh = C4::Context->dbh;
    my $sql = "SELECT DISTINCT tagfield FROM marc_subfield_structure WHERE authtypecode=?";
    my $tags_using_authtype = $authtypefrom && $authtypefrom->authtypecode ? $dbh->selectcol_arrayref( $sql, undef, ( $authtypefrom->authtypecode )) : $dbh->selectcol_arrayref( "SELECT DISTINCT tagfield FROM marc_subfield_structure WHERE authtypecode IS NOT NULL AND authtypecode<>''" );
    my $tags_new;
    if( $authtypeto && ( !$authtypefrom || $authtypeto->authtypecode ne $authtypefrom->authtypecode )) {
        $tags_new = $dbh->selectcol_arrayref( $sql, undef, ( $authtypeto->authtypecode ));
    }  

    my $overwrite = C4::Context->preference( 'AuthorityMergeMode' ) eq 'strict';
    my $skip_subfields = $overwrite
        # This hash contains all subfields from the authority report fields
        # Including $MARCfrom as well as $MARCto
        # We only need it in loose merge mode; replaces the former $exclude
        ? {}
        : { map { ( $_->[0], 1 ); } ( @record_from, @record_to ) };

    my $counteditedbiblio = 0;
    foreach my $biblionumber ( @biblionumbers ) {
        my $biblio = Koha::Biblios->find($biblionumber);
        next unless $biblio;
        my $marcrecord = $biblio->metadata->record;
        my $update = 0;
        foreach my $tagfield (@$tags_using_authtype) {
            my $countfrom = 0;    # used in strict mode to remove duplicates
            foreach my $field ( $marcrecord->field($tagfield) ) {
                my $auth_number = $field->subfield("9");    # link to authority
                my $tag         = $field->tag();
                next if !defined($auth_number) || $auth_number ne $mergefrom;
                $countfrom++;
                if ( !$mergeto || !@record_to ||
                  ( $overwrite && $countfrom > 1 ) ) {
                    # !mergeto or !record_to indicates a delete
                    # Other condition: remove this duplicate in strict mode
                    $marcrecord->delete_field($field);
                    $update = 1;
                    next;
                }
                my $newtag = $tags_new && @$tags_new
                  ? _merge_newtag( $tag, $tags_new )
                  : $tag;
                my $controlled_ind = $authto->controlled_indicators({ record => $MARCto, biblio_tag => $newtag });
                my $field_to = MARC::Field->new(
                    $newtag,
                    $controlled_ind->{ind1} // $field->indicator(1),
                    $controlled_ind->{ind2} // $field->indicator(2),
                    9 => $mergeto, # Needed to create field, will be moved
                );
                my ( @prefix, @postfix );
                if ( !$overwrite ) {
                    # add subfields back in loose mode, check skip_subfields
                    # The first extra subfields will be in front of the
                    # controlled block, the rest at the end.
                    my $prefix_flag = 1;
                    foreach my $subfield ( $field->subfields ) {
                        next if $subfield->[0] eq '9'; # skip but leave flag
                        if ( $skip_subfields->{ $subfield->[0] } ) {
                            # This marks the beginning of the controlled block
                            $prefix_flag = 0;
                            next;
                        }
                        if ($prefix_flag) {
                            push @prefix, [ $subfield->[0], $subfield->[1] ];
                        } else {
                            push @postfix, [ $subfield->[0], $subfield->[1] ];
                        }
                    }
                }
                foreach my $subfield ( @prefix, @record_to, @postfix ) {
                    $field_to->add_subfields($subfield->[0] => $subfield->[1]);
                }
                if( exists $controlled_ind->{sub2} ) { # thesaurus info
                    if( defined $controlled_ind->{sub2} ) {
                        # Add or replace
                        $field_to->update( 2 => $controlled_ind->{sub2} );
                    } else {
                        # Key alerts us here to remove $2
                        $field_to->delete_subfield( code => '2' );
                    }
                }
                # Move $9 to the end
                $field_to->delete_subfield( code => '9' );
                $field_to->add_subfields( 9 => $mergeto );

                if ($tags_new && @$tags_new) {
                    $marcrecord->delete_field($field);
                    append_fields_ordered( $marcrecord, $field_to );
                } else {
                    $field->replace_with($field_to);
                }
                $update = 1;
            }
        }
        next if !$update;
        ModBiblio($marcrecord, $biblionumber, GetFrameworkCode($biblionumber));
        $counteditedbiblio++;
    }
    return $counteditedbiblio;
}

sub _merge_newtag {
# Routine is only called for an (exceptional) authtypecode change
# Fixes old behavior of returning the first tag found
    my ( $oldtag, $new_tags ) = @_;

    # If we e.g. have 650 and 151,651,751 try 651 and check presence
    my $prefix = substr( $oldtag, 0, 1 );
    my $guess = $prefix . substr( $new_tags->[0], -2 );
    if( grep { $_ eq $guess } @$new_tags ) {
        return $guess;
    }
    # Otherwise return one from the same block e.g. 6XX for 650
    # If not there too, fall back to first new tag (old behavior!)
    my @same_block = grep { /^$prefix/ } @$new_tags;
    return @same_block ? $same_block[0] : $new_tags->[0];
}

sub append_fields_ordered {
# while we lack this function in MARC::Record
# we do not want insert_fields_ordered since it inserts before
    my ( $record, $field ) = @_;
    if( my @flds = $record->field( $field->tag ) ) {
        $record->insert_fields_after( pop @flds, $field );
    } else { # now fallback to insert_fields_ordered
        $record->insert_fields_ordered( $field );
    }
}

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

=head2 compare_fields

  my match = compare_fields($field1, $field2, 'abcde');

Compares the listed subfields of both fields and return true if they all match

=cut

sub compare_fields {
    my ($field1, $field2, $subfields) = @_;

    foreach my $subfield (split(//, $subfields)) {
        my $subfield1 = $field1->subfield($subfield) // '';
        my $subfield2 = $field2->subfield($subfield) // '';
        return 0 unless $subfield1 eq $subfield2;
    }
    return 1;
}


=head2 _after_authority_action_hooks

Helper method that takes care of calling all plugin hooks

=cut

sub _after_authority_action_hooks {
    my ( $args ) = @_; # hash keys: action, authority_id
    return Koha::Plugins->call( 'after_authority_action', $args );
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Paul POULAIN paul.poulain@free.fr
Ere Maijala ere.maijala@helsinki.fi

=cut

