package C4::Biblio;

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
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
                    shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

@ISA = qw(Exporter);

#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT = qw(
  &updateBiblio &updateBiblioItem &updateItem
  &itemcount &newbiblio &newbiblioitem
  &modnote &newsubject &newsubtitle
  &modbiblio &checkitems
  &newitems &modbibitem
  &modsubtitle &modsubject &modaddauthor &moditem &countitems
  &delitem &deletebiblioitem &delbiblio
  &getbiblio
  &getbiblioitembybiblionumber
  &getbiblioitem &getitemsbybiblioitem
  &skip &getitemtypes
  &newcompletebiblioitem

  &MARCfind_oldbiblionumber_from_MARCbibid
  &MARCfind_MARCbibid_from_oldbiblionumber
  &MARCfind_marc_from_kohafield
  &MARCfindsubfield
  &MARCfind_frameworkcode
  &MARCgettagslib

  &NEWnewbiblio &NEWnewitem
  &NEWmodbiblio &NEWmoditem
  &NEWdelbiblio &NEWdelitem
  &NEWmodbiblioframework

  &MARCaddbiblio &MARCadditem
  &MARCmodsubfield &MARCaddsubfield
  &MARCmodbiblio &MARCmoditem
  &MARCkoha2marcBiblio &MARCmarc2koha
  &MARCkoha2marcItem &MARChtml2marc &MARChtml2xml
  &MARCgetbiblio &MARCgetitem
  &MARCaddword &MARCdelword
  &MARCdelsubfield
  &char_decode
  
  &FindDuplicate
  &DisplayISBN
  &getitemstatus
  &getitemlocation
);

#
#
# MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC
#
#
# all the following subs takes a MARC::Record as parameter and manage
# the MARC-DB. They are called by the 1.0/1.2 xxx subs, and by the
# NEWxxx subs (xxx deals with old-DB parameters, the NEWxxx deals with MARC-DB parameter)

=head1 NAME

C4::Biblio - acquisition, catalog  management functions

=head1 SYNOPSIS

move from 1.2 to 1.4 version :
1.2 and previous version uses a specific API to manage biblios. This API uses old-DB style parameters.
In the 1.4 version, we want to do 2 differents things :
 - keep populating the old-DB, that has a LOT less datas than MARC
 - populate the MARC-DB
To populate the DBs we have 2 differents sources :
 - the standard acquisition system (through book sellers), that does'nt use MARC data
 - the MARC acquisition system, that uses MARC data.

Thus, we have 2 differents cases :
- with the standard acquisition system, we have non MARC data and want to populate old-DB and MARC-DB, knowing it's an incomplete MARC-record
- with the MARC acquisition system, we have MARC datas, and want to loose nothing in MARC-DB. So, we can't store datas in old-DB, then copy in MARC-DB. we MUST have an API for true MARC data, that populate MARC-DB then old-DB

That's why we need 4 subs :
all I<subs beginning by MARC> manage only MARC tables. They manage MARC-DB with MARC::Record parameters
all I<subs beginning by OLD> manage only OLD-DB tables. They manage old-DB with old-DB parameters
all I<subs beginning by NEW> manage both OLD-DB and MARC tables. They use MARC::Record as parameters. it's the API that MUST be used in MARC acquisition system
all I<subs beginning by seomething else> are the old-style API. They use old-DB as parameter, then call internally the OLD and MARC subs.

- NEW and old-style API should be used in koha to manage biblio
- MARCsubs are divided in 2 parts :
* some of them manage MARC parameters. They are heavily used in koha.
* some of them manage MARC biblio : they are mostly used by NEW and old-style subs.
- OLD are used internally only

all subs requires/use $dbh as 1st parameter.

I<NEWxxx related subs>

all subs requires/use $dbh as 1st parameter.
those subs are used by the MARC-compliant version of koha : marc import, or marc management.

I<OLDxxx related subs>

all subs requires/use $dbh as 1st parameter.
those subs are used by the MARC-compliant version of koha : marc import, or marc management.

They all are the exact copy of 1.0/1.2 version of the sub without the OLD.
The OLDxxx is called by the original xxx sub.
the 1.4 xxx sub also builds MARC::Record an calls the MARCxxx

WARNING : there is 1 difference between initialxxx and OLDxxx :
the db header $dbh is always passed as parameter to avoid over-DB connexion

=head1 DESCRIPTION

=over 4

=item @tagslib = &MARCgettagslib($dbh,1|0,$itemtype);

last param is 1 for liblibrarian and 0 for libopac
$itemtype contains the itemtype framework reference. If empty or does not exist, the default one is used
returns a hash with tag/subfield meaning
=item ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,$kohafield);

finds MARC tag and subfield for a given kohafield
kohafield is "table.field" where table= biblio|biblioitems|items, and field a field of the previous table

=item $biblionumber = &MARCfind_oldbiblionumber_from_MARCbibid($dbh,$MARCbibi);

finds a old-db biblio number for a given MARCbibid number

=item $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber);

finds a MARC bibid from a old-db biblionumber

=item $MARCRecord = &MARCkoha2marcBiblio($dbh,$biblionumber,biblioitemnumber);

MARCkoha2marcBiblio is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB biblio/biblioitem

=item $MARCRecord = &MARCkoha2marcItem($dbh,$biblionumber,itemnumber);

MARCkoha2marcItem is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB item

=item $MARCRecord = &MARCkoha2marcSubtitle($dbh,$biblionumber,$subtitle);

MARCkoha2marcSubtitle is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB subtitle

=item $olddb = &MARCmarc2koha($dbh,$MARCRecord);

builds a hash with old-db datas from a MARC::Record

=item &MARCaddbiblio($dbh,$MARC::Record,$biblionumber);

creates a biblio (in the MARC tables only). $biblionumber is the old-db biblionumber of the biblio

=item &MARCaddsubfield($dbh,$bibid,$tagid,$indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);

adds a subfield in a biblio (in the MARC tables only).

=item $MARCRecord = &MARCgetbiblio($dbh,$bibid);

Returns a MARC::Record for the biblio $bibid.

=item &MARCmodbiblio($dbh,$bibid,$record,$frameworkcode,$delete);

MARCmodbiblio changes a biblio for a biblio,MARC::Record passed as parameter
It 1st delete the biblio, then recreates it.
WARNING : the $delete parameter is not used anymore (too much unsolvable cases).
=item ($subfieldid,$subfieldvalue) = &MARCmodsubfield($dbh,$subfieldid,$subfieldvalue);

MARCmodsubfield changes the value of a given subfield

=item $subfieldid = &MARCfindsubfield($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue);

MARCfindsubfield returns a subfield number given a bibid/tag/subfieldvalue values.
Returns -1 if more than 1 answer

=item $subfieldid = &MARCfindsubfieldid($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCfindsubfieldid find a subfieldid for a bibid/tag/tagorder/subfield/subfieldorder

=item &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCdelsubfield delete a subfield for a bibid/tag/tagorder/subfield/subfieldorder
If $subfieldorder is not set, delete all the $tag$subfield subfields 

=item &MARCdelbiblio($dbh,$bibid);

MARCdelbiblio delete biblio $bibid

=item &MARCkoha2marcOnefield

used by MARCkoha2marc and should not be useful elsewhere

=item &MARCmarc2kohaOnefield

used by MARCmarc2koha and should not be useful elsewhere

=item MARCaddword

used to manage MARC_word table and should not be useful elsewhere

=item MARCdelword

used to manage MARC_word table and should not be useful elsewhere

=cut

sub MARCgettagslib {
    my ( $dbh, $forlibrarian, $frameworkcode ) = @_;
    $frameworkcode = "" unless $frameworkcode;
    my $sth;
    my $libfield = ( $forlibrarian eq 1 ) ? 'liblibrarian' : 'libopac';

    # check that framework exists
    $sth =
      $dbh->prepare(
        "select count(*) from marc_tag_structure where frameworkcode=?");
    $sth->execute($frameworkcode);
    my ($total) = $sth->fetchrow;
    $frameworkcode = "" unless ( $total > 0 );
    $sth =
      $dbh->prepare(
"select tagfield,liblibrarian,libopac,mandatory,repeatable from marc_tag_structure where frameworkcode=? order by tagfield"
    );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tab}->{tab}        = "";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }

    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,kohafield,seealso,hidden,isurl,link from marc_subfield_structure where frameworkcode=? order by tagfield,tagsubfield"
    );
    $sth->execute($frameworkcode);

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

sub MARCfind_marc_from_kohafield {
    my ( $dbh, $kohafield,$frameworkcode ) = @_;
    return 0, 0 unless $kohafield;
	my $relations = C4::Context->marcfromkohafield;
	return ($relations->{$frameworkcode}->{$kohafield}->[0],$relations->{$frameworkcode}->{$kohafield}->[1]);
}

sub MARCfind_oldbiblionumber_from_MARCbibid {
    my ( $dbh, $MARCbibid ) = @_;
    my $sth =
      $dbh->prepare("select biblionumber from marc_biblio where bibid=?");
    $sth->execute($MARCbibid);
    my ($biblionumber) = $sth->fetchrow;
    return $biblionumber;
}

sub MARCfind_MARCbibid_from_oldbiblionumber {
    my ( $dbh, $oldbiblionumber ) = @_;
    my $sth =
      $dbh->prepare("select bibid from marc_biblio where biblionumber=?");
    $sth->execute($oldbiblionumber);
    my ($bibid) = $sth->fetchrow;
    return $bibid;
}

sub MARCaddbiblio {
    # pass the MARC::Record to this function, and it will create the records in the marc tables
	my ($dbh,$record,$biblionumber,$frameworkcode,$bibid) = @_;
	my @fields=$record->fields();
# adding main table, and retrieving bibid
# if bibid is sent, then it's not a true add, it's only a re-add, after a delete (ie, a mod)
    # if bibid empty => true add, find a new bibid number  (and there are no items)
    if ($bibid) {
    	#shift the items' tagorders for this biblio so we don't overwrite item tags with biblio tags..
    	my $sth = $dbh->prepare("SELECT tagfield FROM marc_subfield_structure WHERE kohafield LIKE 'items.%'");
    	$sth->execute;
    	my $itemtag = $sth->fetchrow_hashref->{tagfield};
		my $save_items_sth = $dbh->prepare("SELECT subfieldid, tagorder FROM marc_subfield_table WHERE bibid=? AND tag=? ORDER BY tagorder");
    	my $updatesth = $dbh->prepare("UPDATE marc_subfield_table SET tagorder=? WHERE subfieldid=?");
		my $fieldcount = (scalar @fields) + 1 ;
		my $itemtagorder = 0;
    	$save_items_sth->execute($bibid,$itemtag);
    	# for every item, update the tagorder
   		 while (my ($subfieldid,$tagorder) = ($save_items_sth->fetchrow_array())) {
        	if ($tagorder != $itemtagorder) {
				$fieldcount++;
				$itemtagorder = $tagorder;
			}
        	$updatesth->execute($fieldcount,$subfieldid);
		}
    } else {
        $dbh->do(
"lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ"
        );
        my $sth =
          $dbh->prepare(
"insert into marc_biblio (datecreated,biblionumber,frameworkcode) values (now(),?,?)"
        );
        $sth->execute( $biblionumber, $frameworkcode );
        $sth = $dbh->prepare("select max(bibid) from marc_biblio");
        $sth->execute;
        ($bibid) = $sth->fetchrow;
        $sth->finish;
    }
    my $fieldcount = 1;
    # save leader first
    &MARCaddsubfield($dbh,$bibid,'000','',$fieldcount,'',1,$record->leader);

    # now, add subfields...
    foreach my $field (@fields) {
        $fieldcount++;
		# make sure we're dealing with valid MARC tags
		if ($field->tag =~ /^[0-9A-Za-z]{3}$/) {
        
            # save fixed fields
        if ( $field->tag() < 10 ) {
            &MARCaddsubfield( $dbh, $bibid, $field->tag(), '', $fieldcount, '',
                1, $field->data() );
        }
            
            # save normal subfields
        else {
            my @subfields = $field->subfields();
            foreach my $subfieldcount ( 0 .. $#subfields ) {
                &MARCaddsubfield(
                    $dbh,
                    $bibid,
                    $field->tag(),
                    $field->indicator(1) . $field->indicator(2),
                    $fieldcount,
                    $subfields[$subfieldcount][0],
                    $subfieldcount + 1,
                    $subfields[$subfieldcount][1]
                );
            }
        }
		}
    }

    $dbh->do("unlock tables");
    
    return $bibid;
}

sub MARCadditem {

# pass the MARC::Record to this function, and it will create the records in the marc tables
    my ($dbh,$record,$biblionumber) = @_;
# search for MARC biblionumber
    $dbh->do("lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ");
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
    my @fields=$record->fields();
    my $sth = $dbh->prepare("select max(tagorder) from marc_subfield_table where bibid=?");
    $sth->execute($bibid);
    my ($fieldcount) = $sth->fetchrow;

    # now, add subfields...
    foreach my $field (@fields) {
		unless ($field->tag<100){
			my @subfields = $field->subfields();
			$fieldcount++;
			foreach my $subfieldcount ( 0 .. $#subfields ) {
				&MARCaddsubfield(
					$dbh,
					$bibid,
					$field->tag(),
					$field->indicator(1) . $field->indicator(2),
					$fieldcount,
					$subfields[$subfieldcount][0],
					$subfieldcount + 1,
					$subfields[$subfieldcount][1]
				);
			}
		}
    }
    $dbh->do("unlock tables");
    return $bibid;
}

sub MARCaddsubfield {

    # Add a new subfield to a tag into the DB.
    my (
        $dbh,      $bibid,        $tagid,         $tag_indicator,
        $tagorder, $subfieldcode, $subfieldorder, $subfieldvalues
      )
      = @_;
	  return unless defined($subfieldvalues);
# warn "$tagid / $subfieldcode / $subfieldvalues";
    # if not value, end of job, we do nothing
#     if ( length($subfieldvalues) == 0 ) {
#         return;
#     }
    if ( not($subfieldcode) ) {
        $subfieldcode = ' ' unless $subfieldcode eq '0';
    }
    my @subfieldvalues; # = split /\||#/, $subfieldvalues;
	push @subfieldvalues,$subfieldvalues;
    foreach my $subfieldvalue (@subfieldvalues) {
        if ( length($subfieldvalue) > 255 ) {
            $dbh->do(
"lock tables marc_blob_subfield WRITE, marc_subfield_table WRITE"
            );
            my $sth =
              $dbh->prepare(
                "insert into marc_blob_subfield (subfieldvalue) values (?)");
            $sth->execute($subfieldvalue);
            $sth =
              $dbh->prepare("select max(blobidlink)from marc_blob_subfield");
            $sth->execute;
            my ($res) = $sth->fetchrow;
            $sth =
              $dbh->prepare(
"insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,valuebloblink) values (?,?,?,?,?,?,?)"
            );
            $sth->execute( $bibid, ( sprintf "%03s", $tagid ), $tagorder,
                $tag_indicator, $subfieldcode, $subfieldorder, $res );

            if ( $sth->errstr ) {
                warn
"ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
            }
            $dbh->do("unlock tables");
        }
        else {
            my $sth =
              $dbh->prepare(
"insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?,?)"
            );
            $sth->execute(
                $bibid,        ( sprintf "%03s", $tagid ),
                $tagorder,     $tag_indicator,
                $subfieldcode, $subfieldorder,
                $subfieldvalue
            );
            if ( $sth->errstr ) {
                warn
"ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
            }
        }
        &MARCaddword(
            $dbh,          $bibid,         $tagid,       $tagorder,
            $subfieldcode, $subfieldorder, $subfieldvalue
        );
    }
}

sub MARCgetbiblio {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $bibid ) = @_;
    my $record = MARC::Record->new();

    my $sth =
      $dbh->prepare(
"select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? order by tag,tagorder,subfieldorder
		 	 "
    );
    my $sth2 =
      $dbh->prepare(
        "select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute($bibid);
    my $prevtagorder = 1;
    my $prevtag      = 'XXX';
    my $previndicator;
    my $field;        # for >=10 tags
    my $prevvalue;    # for <10 tags
    while ( my $row = $sth->fetchrow_hashref ) {

        if ( $row->{'valuebloblink'} ) {    #---- search blob if there is one
            $sth2->execute( $row->{'valuebloblink'} );
            my $row2 = $sth2->fetchrow_hashref;
            $sth2->finish;
            $row->{'subfieldvalue'} = $row2->{'subfieldvalue'};
        }
        if ( $row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag ) {
            $previndicator .= "  ";
            if ( $prevtag < 10 ) {
				if ($prevtag ne '000') {
                	$record->add_fields( ( sprintf "%03s", $prevtag ), $prevvalue ) unless $prevtag eq "XXX";    # ignore the 1st loop
				} else {
					$record->leader(sprintf("%-24s",$prevvalue));
				}
            }
            else {
                $record->add_fields($field) unless $prevtag eq "XXX";
            }
            undef $field;
            $prevtagorder  = $row->{tagorder};
            $prevtag       = $row->{tag};
            $previndicator = $row->{tag_indicator};
            if ( $row->{tag} < 10 ) {
                $prevvalue = $row->{subfieldvalue};
            }
            else {
                $field = MARC::Field->new(
                    ( sprintf "%03s", $prevtag ),
                    substr( $row->{tag_indicator} . '  ', 0, 1 ),
                    substr( $row->{tag_indicator} . '  ', 1, 1 ),
                    $row->{'subfieldcode'},
                    $row->{'subfieldvalue'}
                );
            }
        }
        else {
            if ( $row->{tag} < 10 ) {
                $record->add_fields( ( sprintf "%03s", $row->{tag} ),
                    $row->{'subfieldvalue'} );
            }
            else {
                $field->add_subfields( $row->{'subfieldcode'},
                    $row->{'subfieldvalue'} );
            }
            $prevtag       = $row->{tag};
            $previndicator = $row->{tag_indicator};
        }
    }

    # the last has not been included inside the loop... do it now !
    if ( $prevtag ne "XXX" )
    { # check that we have found something. Otherwise, prevtag is still XXX and we
         # must return an empty record, not make MARC::Record fail because we try to
         # create a record with XXX as field :-(
        if ( $prevtag < 10 ) {
            $record->add_fields( $prevtag, $prevvalue );
        }
        else {

            #  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
            $record->add_fields($field);
        }
    }
    return $record;
}

sub MARCgetitem {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $bibid, $itemnumber ) = @_;
    my $record = MARC::Record->new();

    # search MARC tagorder
    my $sth2 =
      $dbh->prepare(
"select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?"
    );
    $sth2->execute( $bibid, $itemnumber );
    my ($tagorder) = $sth2->fetchrow_array();

    #---- TODO : the leader is missing
    my $sth =
      $dbh->prepare(
"select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? and tagorder=? order by subfieldcode,subfieldorder
		 	 "
    );
    $sth2 =
      $dbh->prepare(
        "select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute( $bibid, $tagorder );
    while ( my $row = $sth->fetchrow_hashref ) {
        if ( $row->{'valuebloblink'} ) {    #---- search blob if there is one
            $sth2->execute( $row->{'valuebloblink'} );
            my $row2 = $sth2->fetchrow_hashref;
            $sth2->finish;
            $row->{'subfieldvalue'} = $row2->{'subfieldvalue'};
        }
        if ( $record->field( $row->{'tag'} ) ) {
            my $field;

#--- this test must stay as this, because of strange behaviour of mySQL/Perl DBI with char var containing a number...
            #--- sometimes, eliminates 0 at beginning, sometimes no ;-\\\
            if ( length( $row->{'tag'} ) < 3 ) {
                $row->{'tag'} = "0" . $row->{'tag'};
            }
            $field = $record->field( $row->{'tag'} );
            if ($field) {
                my $x =
                  $field->add_subfields( $row->{'subfieldcode'},
                    $row->{'subfieldvalue'} );
                $record->delete_field($field);
                $record->add_fields($field);
            }
        }
        else {
            if ( length( $row->{'tag'} ) < 3 ) {
                $row->{'tag'} = "0" . $row->{'tag'};
            }
            my $temp =
              MARC::Field->new( $row->{'tag'}, " ", " ",
                $row->{'subfieldcode'} => $row->{'subfieldvalue'} );
            $record->add_fields($temp);
        }

    }
    return $record;
}

sub MARCmodbiblio {
	my ($dbh,$bibid,$record,$frameworkcode,$delete)=@_;
# 1st delete the biblio,
# 2nd recreate it
	my $biblionumber = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	&MARCdelbiblio($dbh,$bibid,1);
	&MARCaddbiblio($dbh,$record,$biblionumber,$frameworkcode,$bibid);
}

sub MARCdelbiblio {
    my ( $dbh, $bibid, $keep_items ) = @_;

    # if the keep_item is set to 1, then all items are preserved.
    # This flag is set when the delbiblio is called by modbiblio
    # due to a too complex structure of MARC (repeatable fields and subfields),
    # the best solution for a modif is to delete / recreate the record.

# 1st of all, copy the MARC::Record to deletedbiblio table => if a true deletion, MARC data will be kept.
# if deletion called before MARCmodbiblio => won't do anything, as the oldbiblionumber doesn't
    # exist in deletedbiblio table
    my $record = MARCgetbiblio( $dbh, $bibid );
    my $oldbiblionumber =
      MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    my $copy2deleted =
      $dbh->prepare("update deletedbiblio set marc=? where biblionumber=?");
    $copy2deleted->execute( $record->as_usmarc(), $oldbiblionumber );

    # now, delete in MARC tables.
    if ( $keep_items eq 1 ) {

        #search item field code
        my $sth =
          $dbh->prepare(
"select tagfield from marc_subfield_structure where kohafield like 'items.%'"
        );
        $sth->execute;
        my $itemtag = $sth->fetchrow_hashref->{tagfield};
        $dbh->do(
"delete from marc_subfield_table where bibid=$bibid and tag<>$itemtag"
        );
        $dbh->do(
"delete from marc_word where bibid=$bibid and not (tagsubfield like \"$itemtag%\")"
        );
    }
    else {
        $dbh->do("delete from marc_biblio where bibid=$bibid");
        $dbh->do("delete from marc_subfield_table where bibid=$bibid");
        $dbh->do("delete from marc_word where bibid=$bibid");
    }
}

sub MARCdelitem {

    # delete the item passed in parameter in MARC tables.
    my ( $dbh, $bibid, $itemnumber ) = @_;

    #    my $record = MARC::Record->new();
    # search MARC tagorder
    my $record = MARCgetitem( $dbh, $bibid, $itemnumber );
    my $copy2deleted =
      $dbh->prepare("update deleteditems set marc=? where itemnumber=?");
    $copy2deleted->execute( $record->as_usmarc(), $itemnumber );

    my $sth2 =
      $dbh->prepare(
"select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?"
    );
    $sth2->execute( $bibid, $itemnumber );
    my ($tagorder) = $sth2->fetchrow_array();
    my $sth =
      $dbh->prepare(
        "delete from marc_subfield_table where bibid=? and tagorder=?");
    $sth->execute( $bibid, $tagorder );
    $sth = $dbh->prepare("delete from marc_word where bibid=? and tagorder=?");
    $sth->execute( $bibid, $tagorder );
}

sub MARCmoditem {
	my ($dbh,$record,$bibid,$itemnumber,$delete)=@_;
	my $biblionumber = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	&MARCdelitem($dbh,$bibid,$itemnumber);
	&MARCadditem($dbh,$record,$biblionumber);
}

sub MARCmodsubfield {

    # Subroutine changes a subfield value given a subfieldid.
    my ( $dbh, $subfieldid, $subfieldvalue ) = @_;
    $dbh->do("lock tables marc_blob_subfield WRITE,marc_subfield_table WRITE");
    my $sth1 =
      $dbh->prepare(
        "select valuebloblink from marc_subfield_table where subfieldid=?");
    $sth1->execute($subfieldid);
    my ($oldvaluebloblink) = $sth1->fetchrow;
    $sth1->finish;
    my $sth;

    # if too long, use a bloblink
    if ( length($subfieldvalue) > 255 ) {

        # if already a bloblink, update it, otherwise, insert a new one.
        if ($oldvaluebloblink) {
            $sth =
              $dbh->prepare(
"update marc_blob_subfield set subfieldvalue=? where blobidlink=?"
            );
            $sth->execute( $subfieldvalue, $oldvaluebloblink );
        }
        else {
            $sth =
              $dbh->prepare(
                "insert into marc_blob_subfield (subfieldvalue) values (?)");
            $sth->execute($subfieldvalue);
            $sth =
              $dbh->prepare("select max(blobidlink) from marc_blob_subfield");
            $sth->execute;
            my ($res) = $sth->fetchrow;
            $sth =
              $dbh->prepare(
"update marc_subfield_table set subfieldvalue=null, valuebloblink=? where subfieldid=?"
            );
            $sth->execute( $res, $subfieldid );
        }
    }
    else {

# note this can leave orphan bloblink. Not a big problem, but we should build somewhere a orphan deleting script...
        $sth =
          $dbh->prepare(
"update marc_subfield_table set subfieldvalue=?,valuebloblink=null where subfieldid=?"
        );
        $sth->execute( $subfieldvalue, $subfieldid );
    }
    $dbh->do("unlock tables");
    $sth->finish;
    $sth =
      $dbh->prepare(
"select bibid,tag,tagorder,subfieldcode,subfieldid,subfieldorder from marc_subfield_table where subfieldid=?"
    );
    $sth->execute($subfieldid);
    my ( $bibid, $tagid, $tagorder, $subfieldcode, $x, $subfieldorder ) =
      $sth->fetchrow;
    $subfieldid = $x;
    &MARCdelword( $dbh, $bibid, $tagid, $tagorder, $subfieldcode,
        $subfieldorder );
    &MARCaddword(
        $dbh,          $bibid,         $tagid,       $tagorder,
        $subfieldcode, $subfieldorder, $subfieldvalue
    );
    return ( $subfieldid, $subfieldvalue );
}

sub MARCfindsubfield {
    my ( $dbh, $bibid, $tag, $subfieldcode, $subfieldorder, $subfieldvalue ) =
      @_;
    my $resultcounter = 0;
    my $subfieldid;
    my $lastsubfieldid;
    my $query =
"select subfieldid from marc_subfield_table where bibid=? and tag=? and subfieldcode=?";
    my @bind_values = ( $bibid, $tag, $subfieldcode );
    if ($subfieldvalue) {
        $query .= " and subfieldvalue=?";
        push ( @bind_values, $subfieldvalue );
    }
    else {
        if ( $subfieldorder < 1 ) {
            $subfieldorder = 1;
        }
        $query .= " and subfieldorder=?";
        push ( @bind_values, $subfieldorder );
    }
    my $sti = $dbh->prepare($query);
    $sti->execute(@bind_values);
    while ( ($subfieldid) = $sti->fetchrow ) {
        $resultcounter++;
        $lastsubfieldid = $subfieldid;
    }
    if ( $resultcounter > 1 ) {

# Error condition.  Values given did not resolve into a unique record.  Don't know what to edit
# should rarely occur (only if we use subfieldvalue with a value that exists twice, which is strange)
        return -1;
    }
    else {
        return $lastsubfieldid;
    }
}

sub MARCfindsubfieldid {
    my ( $dbh, $bibid, $tag, $tagorder, $subfield, $subfieldorder ) = @_;
    my $sth = $dbh->prepare( "select subfieldid from marc_subfield_table
				where bibid=? and tag=? and tagorder=?
					and subfieldcode=? and subfieldorder=?"
    );
    $sth->execute( $bibid, $tag, $tagorder, $subfield, $subfieldorder );
    my ($res) = $sth->fetchrow;
    unless ($res) {
        $sth = $dbh->prepare( "select subfieldid from marc_subfield_table
				where bibid=? and tag=? and tagorder=?
					and subfieldcode=?"
        );
        $sth->execute( $bibid, $tag, $tagorder, $subfield );
        ($res) = $sth->fetchrow;
    }
    return $res;
}

sub MARCfind_frameworkcode {
    my ( $dbh, $bibid ) = @_;
    my $sth =
      $dbh->prepare("select frameworkcode from marc_biblio where bibid=?");
    $sth->execute($bibid);
    my ($frameworkcode) = $sth->fetchrow;
    return $frameworkcode;
}

sub MARCdelsubfield {

    # delete a subfield for $bibid / tag / tagorder / subfield / subfieldorder
    my ( $dbh, $bibid, $tag, $tagorder, $subfield, $subfieldorder ) = @_;
	if ($subfieldorder) {
		$dbh->do( "delete from marc_subfield_table where bibid='$bibid' and
				tag='$tag' and tagorder='$tagorder'
				and subfieldcode='$subfield' and subfieldorder='$subfieldorder'
				"
		);
		$dbh->do( "delete from marc_word where bibid='$bibid' and
				tagsubfield='$tag$subfield' and tagorder='$tagorder'
				and subfieldorder='$subfieldorder'
				"
		);
	} else {
		$dbh->do( "delete from marc_subfield_table where bibid='$bibid' and
				tag='$tag' and tagorder='$tagorder'
				and subfieldcode='$subfield'"
		);
		$dbh->do( "delete from marc_word where bibid='$bibid' and
				tagsubfield='$tag$subfield' and tagorder='$tagorder'"
		);
	}
}

sub MARCkoha2marcBiblio {

    # this function builds partial MARC::Record from the old koha-DB fields
    my ( $dbh, $biblionumber, $biblioitemnumber ) = @_;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
    );
    my $record = MARC::Record->new();

    #--- if bibid, then retrieve old-style koha data
    if ( $biblionumber > 0 ) {
        my $sth2 =
          $dbh->prepare("SELECT biblio.biblionumber,title,itemtype,author,unititle,biblio.notes,abstract,
                                serial,seriestitle,copyrightdate,biblio.timestamp,
                                biblioitemnumber,volume,number,classification,
                                url,isbn,issn,dewey,subclass,publicationyear,publishercode,
                                volumedate,volumeddesc,illus,pages,biblioitems.notes AS bnotes,size,place
                            FROM biblio
                            LEFT JOIN biblioitems on biblio.biblionumber=biblioitems.biblionumber 
                            WHERE biblio.biblionumber=?"
        );
        $sth2->execute($biblionumber);
        my @row = $sth2->fetchrow;
        &MARCkoha2marcOnefield( $sth, $record, "biblio.biblionumber", $row[0], '') if $row[0];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.title", $row[1], '') if $row[1];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.itemtype", $row[2], '') if $row[2];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.author", $row[3], '') if $row[3];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.unititle", $row[4], '') if $row[4];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.notes", $row[5], '') if $row[5];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.abstract", $row[6], '') if $row[6];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.serial", $row[7], '') if $row[7];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.seriestitle", $row[8], '') if $row[8];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.copyrightdate", $row[9], '') if $row[9];
        &MARCkoha2marcOnefield( $sth, $record, "biblio.timestamp", $row[10], '') if $row[10];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.biblioitemnumber", $row[11], '') if $row[11];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.volume", $row[12], '') if $row[12];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.number", $row[13], '') if $row[13];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.classification", $row[14], '') if $row[14];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.url", $row[15], '') if $row[15];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.isbn", $row[16], '') if $row[16];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.issn", $row[17], '') if $row[17];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.dewey", $row[18], '') if $row[18];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.subclass", $row[19], '') if $row[19];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.publicationyear", $row[20], '') if $row[20];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.volumedate", $row[21], '') if $row[21];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.volumeddesc", $row[22], '') if $row[22];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.illus", $row[23], '') if $row[23];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.pages", $row[24], '') if $row[24];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.notes", $row[25], '') if $row[25];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.size", $row[26], '') if $row[26];
        &MARCkoha2marcOnefield( $sth, $record, "biblioitems.place", $row[27], '') if $row[27];
    }
    # other fields => additional authors, subjects, subtitles
    my $sth2 =
      $dbh->prepare(
        " SELECT author FROM additionalauthors WHERE biblionumber=?");
    $sth2->execute($biblionumber);
    while ( my $row = $sth2->fetchrow_hashref ) {
        &MARCkoha2marcOnefield( $sth, $record, "additionalauthors.author",
            $row->{'author'},'' );
    }
    $sth2 =
      $dbh->prepare(" SELECT subject FROM bibliosubject WHERE biblionumber=?");
    $sth2->execute($biblionumber);
    while ( my $row = $sth2->fetchrow_hashref ) {
        &MARCkoha2marcOnefield( $sth, $record, "bibliosubject.subject",
            $row->{'subject'},'' );
    }
    $sth2 =
      $dbh->prepare(
        " SELECT subtitle FROM bibliosubtitle WHERE biblionumber=?");
    $sth2->execute($biblionumber);
    while ( my $row = $sth2->fetchrow_hashref ) {
        &MARCkoha2marcOnefield( $sth, $record, "bibliosubtitle.subtitle",
            $row->{'subtitle'},'' );
    }
#     warn "REC : ".$record->as_formatted;
    return $record;
}

sub MARCkoha2marcItem {

    # this function builds partial MARC::Record from the old koha-DB fields
    my ( $dbh, $biblionumber, $itemnumber ) = @_;

    #    my $dbh=&C4Connect;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
    );
    my $record = MARC::Record->new();

    #--- if item, then retrieve old-style koha data
    if ( $itemnumber > 0 ) {

        #	print STDERR "prepare $biblionumber,$itemnumber\n";
        my $sth2 =
          $dbh->prepare(
"SELECT itemnumber,biblionumber,multivolumepart,biblioitemnumber,barcode,dateaccessioned,
						booksellerid,homebranch,price,replacementprice,replacementpricedate,datelastborrowed,
						datelastseen,multivolume,stack,notforloan,itemlost,wthdrawn,itemcallnumber,issues,renewals,
					reserves,restricted,binding,itemnotes,holdingbranch,timestamp
					FROM items
					WHERE itemnumber=?"
        );
        $sth2->execute($itemnumber);
        my $row = $sth2->fetchrow_hashref;
        my $code;
        foreach $code ( keys %$row ) {
            if ( $row->{$code} ) {
                &MARCkoha2marcOnefield( $sth, $record, "items." . $code,
                    $row->{$code},'' );
            }
        }
    }
    return $record;
}

sub MARCkoha2marcSubtitle {

    # this function builds partial MARC::Record from the old koha-DB fields
    my ( $dbh, $bibnum, $subtitle ) = @_;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
    );
    my $record = MARC::Record->new();
    &MARCkoha2marcOnefield( $sth, $record, "bibliosubtitle.subtitle",
        $subtitle,'' );
    return $record;
}

sub MARCkoha2marcOnefield {
    my ( $sth, $record, $kohafieldname, $value,$frameworkcode ) = @_;
    my $tagfield;
    my $tagsubfield;
    $sth->execute($frameworkcode,$kohafieldname);
    if ( ( $tagfield, $tagsubfield ) = $sth->fetchrow ) {
        if ( $record->field($tagfield) ) {
            my $tag = $record->field($tagfield);
            if ($tag) {
                $tag->add_subfields( $tagsubfield, $value );
                $record->delete_field($tag);
                $record->add_fields($tag);
            }
        }
        else {
            $record->add_fields( $tagfield, " ", " ", $tagsubfield => $value );
        }
    }
    return $record;
}
sub MARChtml2xml {
	my ($tags,$subfields,$values,$indicator,$ind_tag) = @_;        
	use MARC::File::XML;
	my $xml= MARC::File::XML::header(C4::Context->preference('TemplateEncoding'),C4::Context->preference('marcflavour')); 
	#$xml =~ s/UTF-8/ISO-8859-1/;
	#tell perl that $xml is whatever default encoding is
	my $prevvalue;
	my $prevtag=-1;
	my $first=1;
	my $j = -1;
    for (my $i=0;$i<=@$tags;$i++){
		@$values[$i] =~ s/&/&amp;/g;
		@$values[$i] =~ s/</&lt;/g;
		@$values[$i] =~ s/>/&gt;/g;
		@$values[$i] =~ s/"/&quot;/g;
		@$values[$i] =~ s/'/&apos;/g;
		if ((@$tags[$i] ne $prevtag)){
			$j++ unless (@$tags[$i] eq "");
			#warn "IND:".substr(@$indicator[$j],0,1).substr(@$indicator[$j],1,1)." ".@$tags[$i];
			if (!$first){
		    	$xml.="</datafield>\n";
				if ((@$tags[$i] > 10) && (@$values[$i] ne "")){
						my $ind1 = substr(@$indicator[$j],0,1);
                        my $ind2 = substr(@$indicator[$j],1,1);
                        $xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first=0;
				} else {
		    	$first=1;
				}
            } else {
		    	if (@$values[$i] ne "") {
		    		# leader
		    		if (@$tags[$i] eq "000") {
						$xml.="<leader>@$values[$i]</leader>\n";
						$first=1;
					# rest of the fixed fields
		    		} elsif (@$tags[$i] < 10) {
						$xml.="<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
						$first=1;
		    		} else {
						my $ind1 = substr(@$indicator[$j],0,1);
						my $ind2 = substr(@$indicator[$j],1,1);
						$xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
						$first=0;			
		    		}
		    	}
			}
		} else { # @$tags[$i] eq $prevtag
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
	return $xml;
}
sub MARChtml2marc {
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
# 	my %subfieldlist=();
	my $prevvalue; # if tag <10
	my $field; # if tag >=10
	for (my $i=0; $i< @$rtags; $i++) {
		# rebuild MARC::Record
# 			warn "0=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ";
		if (@$rtags[$i] ne $prevtag) {
			if ($prevtag < 10) {
				if ($prevvalue) {
					if (($prevtag ne '000') && ($prevvalue ne "")) {
						$record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
					} elsif ($prevvalue ne ""){
						$record->leader($prevvalue);
					}
				}
			} else {
				if (($field) && ($field ne "")) {
					$record->add_fields($field);
				}
			}
			$indicators{@$rtags[$i]}.='  ';
		        # skip blank tags, I hope this works 
		        if (@$rtags[$i] eq ''){
			    $prevtag = @$rtags[$i];
			    undef $field;
			    next;
			}
			if (@$rtags[$i] <10) {
				$prevvalue= @$rvalues[$i];
				undef $field;
			} else {
				undef $prevvalue;
				if (@$rvalues[$i] eq "") {
				undef $field;
				} else {
				$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
				}
# 			warn "1=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (length(@$rvalues[$i])>0) {
					if ($field) {
						$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
					} else {
					$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
					}
# 			warn "2=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
				}
			}
			$prevtag= @$rtags[$i];
		}
	}
	#}
	# the last has not been included inside the loop... do it now !
	#use Data::Dumper;
	#warn Dumper($field->{_subfields});
	$record->add_fields($field) if (($field) && $field ne "");
 	#warn "HTML2MARC=".$record->as_formatted;
	return $record;
}

sub MARCmarc2koha {
	my ($dbh,$record,$frameworkcode) = @_;
	my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?");
	my $result;
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblio");
	$sth2->execute;
	my $field;
	while (($field)=$sth2->fetchrow) {
# 		warn "biblio.".$field;
		$result=&MARCmarc2kohaOneField($sth,"biblio",$field,$record,$result,$frameworkcode);
	}
	$sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
		if ($field eq 'notes') { $field = 'bnotes'; }
# 		warn "biblioitems".$field;
		$result=&MARCmarc2kohaOneField($sth,"biblioitems",$field,$record,$result,$frameworkcode);
	}
	$sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
# 		warn "items".$field;
		$result=&MARCmarc2kohaOneField($sth,"items",$field,$record,$result,$frameworkcode);
	}
	# additional authors : specific
	$result = &MARCmarc2kohaOneField($sth,"bibliosubtitle","subtitle",$record,$result,$frameworkcode);
	$result = &MARCmarc2kohaOneField($sth,"additionalauthors","additionalauthors",$record,$result,$frameworkcode);
# modify copyrightdate to keep only the 1st year found
	my $temp = $result->{'copyrightdate'};
	if ($temp){
		$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
		if ($1>0) {
			$result->{'copyrightdate'} = $1;
		} else { # if no cYYYY, get the 1st date.
			$temp =~ m/(\d\d\d\d)/;
			$result->{'copyrightdate'} = $1;
		}
	}
# modify publicationyear to keep only the 1st year found
	$temp = $result->{'publicationyear'};
	if ($temp){
		$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
		if ($1) {
			$result->{'publicationyear'} = $1;
		} else { # if no cYYYY, get the 1st date.
			$temp =~ m/(\d\d\d\d)/;
			$result->{'publicationyear'} = $1;
		}
	}
	return $result;
}

sub MARCmarc2kohaOneField {

# FIXME ? if a field has a repeatable subfield that is used in old-db, only the 1st will be retrieved...
    my ( $sth, $kohatable, $kohafield, $record, $result,$frameworkcode ) = @_;
    #    warn "kohatable / $kohafield / $result / ";
    my $res = "";
    my $tagfield;
    my $subfield;
    ( $tagfield, $subfield ) = MARCfind_marc_from_kohafield("",$kohatable.".".$kohafield,$frameworkcode);
	if (($tagfield) && $record->field($tagfield)) {
		my $field =$record->field($tagfield);
		if ($field->tag()<10) {
			if ($result->{$kohafield}) {
				# Reverse array filled with elements from repeated subfields 
				# from first to last to avoid last to first concatenation of 
				# elements in Koha DB.  -- thd
				$result->{$kohafield} .= " | " . reverse($field->data());
			} else {
				$result->{$kohafield} = $field->data() ;
			}
		} else {
			if ( $field->subfields ) {
				my @subfields = $field->subfields();
				foreach my $subfieldcount ( 0 .. $#subfields ) {
					if ($subfields[$subfieldcount][0] eq $subfield) {
						if ( $result->{$kohafield} ) {
							$result->{$kohafield} .= " | " . $subfields[$subfieldcount][1] if ($subfields[$subfieldcount][1]);
						}
						else {
							$result->{$kohafield} = $subfields[$subfieldcount][1] if ($subfields[$subfieldcount][1]);
						}
					}
				}
			}
		}
	}
# 	warn "OneField for $kohatable.$kohafield and $frameworkcode=> $tagfield, $subfield";
    return $result;
}

sub MARCaddword {

    # split a subfield string and adds it into the word table.
    # removes stopwords
    my (
        $dbh,        $bibid,         $tag,    $tagorder,
        $subfieldid, $subfieldorder, $sentence
      )
      = @_;
    $sentence =~ s/(\.|\?|\:|\!|;|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)/ /g;
    my @words = split / /, $sentence;
    my $stopwords = C4::Context->stopwords;
    my $sth       =
      $dbh->prepare(
"insert into marc_word (bibid, tagsubfield, tagorder, subfieldorder, word, sndx_word)
			values (?,concat(?,?),?,?,?,soundex(?))"
    );
    foreach my $word (@words) {
# we record only words one char long and not in stopwords hash
	if (length($word)>=1 and !($stopwords->{uc($word)})) {
	    $sth->execute($bibid,$tag,$subfieldid,$tagorder,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		warn "ERROR ==> insert into marc_word (bibid, tagsubfield, tagorder, subfieldorder, word, sndx_word) values ($bibid,concat($tag,$subfieldid),$tagorder,$subfieldorder,$word,soundex($word))\n";
	    }
	}
    }
}

sub MARCdelword {

# delete words. this sub deletes all the words from a sentence. a subfield modif is done by a delete then a add
    my ( $dbh, $bibid, $tag, $tagorder, $subfield, $subfieldorder ) = @_;
    my $sth =
      $dbh->prepare(
"delete from marc_word where bibid=? and tagsubfield=concat(?,?) and tagorder=? and subfieldorder=?"
    );
    $sth->execute( $bibid, $tag, $subfield, $tagorder, $subfieldorder );
}

#
#
# NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
#
#
# all the following subs are useful to manage MARC-DB with complete MARC records.
# it's used with marcimport, and marc management tools
#

=item ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbibilio($dbh,$MARCRecord,$oldbiblio,$oldbiblioitem);

creates a new biblio from a MARC::Record. The 3rd and 4th parameter are hashes and may be ignored. If only 2 params are passed to the sub, the old-db hashes
are builded from the MARC::Record. If they are passed, they are used.

=item NEWnewitem($dbh, $record,$bibid);

adds an item in the db.

=cut

sub NEWnewbiblio {
    my ( $dbh, $record, $frameworkcode ) = @_;
    my $oldbibnum;
    my $oldbibitemnum;
    my $olddata = MARCmarc2koha( $dbh, $record,$frameworkcode );
    $oldbibnum = OLDnewbiblio( $dbh, $olddata );
	$olddata->{'biblionumber'} = $oldbibnum;
    $oldbibitemnum = OLDnewbiblioitem( $dbh, $olddata );

    # search subtiles, addiauthors and subjects
    my ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, "additionalauthors.author",$frameworkcode );
    my @addiauthfields = $record->field($tagfield);
    foreach my $addiauthfield (@addiauthfields) {
        my @addiauthsubfields = $addiauthfield->subfield($tagsubfield);
        foreach my $subfieldcount ( 0 .. $#addiauthsubfields ) {
            OLDmodaddauthor( $dbh, $oldbibnum,
                $addiauthsubfields[$subfieldcount] );
        }
    }
    ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, "bibliosubtitle.subtitle",$frameworkcode );
    my @subtitlefields = $record->field($tagfield);
    foreach my $subtitlefield (@subtitlefields) {
        my @subtitlesubfields = $subtitlefield->subfield($tagsubfield);
        foreach my $subfieldcount ( 0 .. $#subtitlesubfields ) {
            OLDnewsubtitle( $dbh, $oldbibnum,
                $subtitlesubfields[$subfieldcount] );
        }
    }
    ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, "bibliosubject.subject",$frameworkcode );
    my @subj = $record->field($tagfield);
    my @subjects;
    foreach my $subject (@subj) {
        my @subjsubfield = $subject->subfield($tagsubfield);
        foreach my $subfieldcount ( 0 .. $#subjsubfield ) {
            push @subjects, $subjsubfield[$subfieldcount];
        }
    }
    OLDmodsubject( $dbh, $oldbibnum, 1, @subjects );

    # we must add bibnum and bibitemnum in MARC::Record...
    # we build the new field with biblionumber and biblioitemnumber
    # we drop the original field
    # we add the new builded field.
# NOTE : Works only if the field is ONLY for biblionumber and biblioitemnumber
    # (steve and paul : thinks 090 is a good choice)
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where kohafield=?"
    );
    $sth->execute("biblio.biblionumber");
    ( my $tagfield1, my $tagsubfield1 ) = $sth->fetchrow;
    $sth->execute("biblioitems.biblioitemnumber");
    ( my $tagfield2, my $tagsubfield2 ) = $sth->fetchrow;
	my $newfield;
	# biblionumber & biblioitemnumber are in different fields
    if ( $tagfield1 != $tagfield2 ) {
		# deal with biblionumber
		if ($tagfield1<10) {
			$newfield = MARC::Field->new(
				$tagfield1, $oldbibnum,
			);
		} else {
			$newfield = MARC::Field->new(
				$tagfield1, '', '', "$tagsubfield1" => $oldbibnum,
			);
		}
		# drop old field and create new one...
		my $old_field = $record->field($tagfield1);
		$record->delete_field($old_field);
		$record->add_fields($newfield);
		# deal with biblioitemnumber
		if ($tagfield2<10) {
			$newfield = MARC::Field->new(
				$tagfield2, $oldbibitemnum,
			);
		} else {
			$newfield = MARC::Field->new(
				$tagfield2, '', '', "$tagsubfield2" => $oldbibitemnum,
			);
		}
		# drop old field and create new one...
		$old_field = $record->field($tagfield2);
		$record->delete_field($old_field);
		$record->add_fields($newfield);
	# biblionumber & biblioitemnumber are in the same field (can't be <10 as fields <10 have only 1 value)
	} else {
		my $newfield = MARC::Field->new(
			$tagfield1, '', '', "$tagsubfield1" => $oldbibnum,
			"$tagsubfield2" => $oldbibitemnum
		);
		# drop old field and create new one...
		my $old_field = $record->field($tagfield1);
		$record->delete_field($old_field);
		$record->add_fields($newfield);
	}
# 	warn "REC : ".$record->as_formatted;
    my $bibid = MARCaddbiblio( $dbh, $record, $oldbibnum, $frameworkcode );
    return ( $bibid, $oldbibnum, $oldbibitemnum );
}

sub NEWmodbiblioframework {
	my ($dbh,$bibid,$frameworkcode) =@_;
	my $sth = $dbh->prepare("Update marc_biblio SET frameworkcode=? WHERE bibid=$bibid");
	$sth->execute($frameworkcode);
	return 1;
}
sub NEWmodbiblio {
	my ($dbh,$record,$bibid,$frameworkcode) =@_;
	$frameworkcode="" unless $frameworkcode;
	&MARCmodbiblio($dbh,$bibid,$record,$frameworkcode,0);
	my $oldbiblio = MARCmarc2koha($dbh,$record,$frameworkcode);
	my $oldbiblionumber = OLDmodbiblio($dbh,$oldbiblio);
	OLDmodbibitem($dbh,$oldbiblio);
	# now, modify addi authors, subject, addititles.
	my ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"additionalauthors.author",$frameworkcode);
	my @addiauthfields = $record->field($tagfield);
	foreach my $addiauthfield (@addiauthfields) {
		my @addiauthsubfields = $addiauthfield->subfield($tagsubfield);
		$dbh->do("delete from additionalauthors where biblionumber=$oldbiblionumber");
		foreach my $subfieldcount (0..$#addiauthsubfields) {
			OLDmodaddauthor($dbh,$oldbiblionumber,$addiauthsubfields[$subfieldcount]);
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubtitle.subtitle",$frameworkcode);
	my @subtitlefields = $record->field($tagfield);
	foreach my $subtitlefield (@subtitlefields) {
		my @subtitlesubfields = $subtitlefield->subfield($tagsubfield);
		# delete & create subtitle again because OLDmodsubtitle can't handle new subtitles
		# between 2 modifs
		$dbh->do("delete from bibliosubtitle where biblionumber=$oldbiblionumber");
		foreach my $subfieldcount (0..$#subtitlesubfields) {
			foreach my $subtit(split /\||#/,$subtitlesubfields[$subfieldcount]) {
				OLDnewsubtitle($dbh,$oldbiblionumber,$subtit);
			}
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubject.subject",$frameworkcode);
	my @subj = $record->field($tagfield);
	my @subjects;
	foreach my $subject (@subj) {
		my @subjsubfield = $subject->subfield($tagsubfield);
		foreach my $subfieldcount (0..$#subjsubfield) {
			push @subjects,$subjsubfield[$subfieldcount];
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"items.itemnotes",$frameworkcode);
	my @notes = $record->field($tagfield);
	my @itemnotes;
	foreach my $note (@notes) {
		my @itemnotefields = $note->subfield($tagsubfield);
		foreach my $subfieldcount (0..$#itemnotes) {
			push @itemnotes,$itemnotefields[$subfieldcount];
		}
	}
	OLDmodsubject($dbh,$oldbiblionumber,1,@subjects);
	return 1;
}

sub NEWdelbiblio {
    my ( $dbh, $bibid ) = @_;
    my $biblio = &MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    &OLDdelbiblio( $dbh, $biblio );
    my $sth =
      $dbh->prepare(
        "select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblio);
    while ( my ($biblioitemnumber) = $sth->fetchrow ) {
        OLDdeletebiblioitem( $dbh, $biblioitemnumber );
    }
    # delete from other koha tables
    $sth = $dbh->prepare("DELETE FROM bibliosubject WHERE biblionumber=?");
    $sth->execute($biblio);
    $sth = $dbh->prepare("DELETE FROM additionalauthors WHERE biblionumber=?");
    $sth->execute($biblio);
    &MARCdelbiblio( $dbh, $bibid, 0 );
}

sub NEWnewitem {
    my ( $dbh, $record, $bibid ) = @_;

    # add item in old-DB
	my $frameworkcode=MARCfind_frameworkcode($dbh,$bibid);
    my $item = &MARCmarc2koha( $dbh, $record,$frameworkcode );
    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} =
      MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    my $sth =
      $dbh->prepare(
        "select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute( $item->{'biblionumber'} );
    ( $item->{'biblioitemnumber'} ) = $sth->fetchrow;
    my ( $itemnumber, $error ) = &OLDnewitems( $dbh, $item, $item->{barcode} );

    # add itemnumber to MARC::Record before adding the item.
    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
    );
    &MARCkoha2marcOnefield( $sth, $record, "items.itemnumber", $itemnumber,$frameworkcode );

    # add the item
    my $bib = &MARCadditem( $dbh, $record, $item->{'biblionumber'} );
}

sub NEWmoditem {
    my ( $dbh, $record, $bibid, $itemnumber, $delete ) = @_;
	&MARCmoditem( $dbh, $record, $bibid, $itemnumber, $delete );
	my $frameworkcode=MARCfind_frameworkcode($dbh,$bibid);
    my $olditem = MARCmarc2koha( $dbh, $record,$frameworkcode );
    OLDmoditem( $dbh, $olditem );
}

sub NEWdelitem {
    my ( $dbh, $bibid, $itemnumber ) = @_;
    my $biblio = &MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    &OLDdelitem( $dbh, $itemnumber );
    &MARCdelitem( $dbh, $bibid, $itemnumber );
}

#
#
# OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
#
#

=item $biblionumber = OLDnewbiblio($dbh,$biblio);

adds a record in biblio table. Datas are in the hash $biblio.

=item $biblionumber = OLDmodbiblio($dbh,$biblio);

modify a record in biblio table. Datas are in the hash $biblio.

=item OLDmodsubtitle($dbh,$bibnum,$subtitle);

modify subtitles in bibliosubtitle table.

=item OLDmodaddauthor($dbh,$bibnum,$author);

adds or modify additional authors
NOTE :  Strange sub : seems to delete MANY and add only ONE author... maybe buggy ?

=item $errors = OLDmodsubject($dbh,$bibnum, $force, @subject);

modify/adds subjects

=item OLDmodbibitem($dbh, $biblioitem);

modify a biblioitem

=item OLDmodnote($dbh,$bibitemnum,$note

modify a note for a biblioitem

=item OLDnewbiblioitem($dbh,$biblioitem);

adds a biblioitem ($biblioitem is a hash with the values)

=item OLDnewsubject($dbh,$bibnum);

adds a subject

=item OLDnewsubtitle($dbh,$bibnum,$subtitle);

create a new subtitle

=item ($itemnumber,$errors)= OLDnewitems($dbh,$item,$barcode);

create a item. $item is a hash and $barcode the barcode.

=item OLDmoditem($dbh,$item);

modify item

=item OLDdelitem($dbh,$itemnum);

delete item

=item OLDdeletebiblioitem($dbh,$biblioitemnumber);

deletes a biblioitem
NOTE : not standard sub name. Should be OLDdelbiblioitem()

=item OLDdelbiblio($dbh,$biblio);

delete a biblio

=cut

sub OLDnewbiblio {
    my ( $dbh, $biblio ) = @_;

    #  my $dbh    = &C4Connect;
    my $sth = $dbh->prepare("Select max(biblionumber) from biblio");
    $sth->execute;
    my $data   = $sth->fetchrow_arrayref;
    my $bibnum = $$data[0] + 1;
    my $series = 0;

    if ( $biblio->{'seriestitle'} ) { $series = 1 }
    $sth->finish;
    $sth =
      $dbh->prepare(
"insert into biblio set biblionumber  = ?, title = ?, author = ?, copyrightdate = ?, serial = ?, seriestitle = ?, notes = ?, abstract = ?, unititle = ?"
    );
    $sth->execute(
        $bibnum,             $biblio->{'title'},
        $biblio->{'author'}, $biblio->{'copyrightdate'},
        $biblio->{'serial'},             $biblio->{'seriestitle'},
        $biblio->{'notes'},  $biblio->{'abstract'},
		$biblio->{'unititle'},
    );

    $sth->finish;

    #  $dbh->disconnect;
    return ($bibnum);
}

sub OLDmodbiblio {
    my ( $dbh, $biblio ) = @_;

    #  my $dbh   = C4Connect;
    my $query;
    my $sth;

    $query = "";
    $sth   =
      $dbh->prepare(
"Update biblio set title = ?, author = ?, abstract = ?, copyrightdate = ?, seriestitle = ?, serial = ?, unititle = ?, notes = ? where biblionumber = ?"
    );
    $sth->execute(
        $biblio->{'title'},       $biblio->{'author'},
        $biblio->{'abstract'},    $biblio->{'copyrightdate'},
        $biblio->{'seriestitle'}, $biblio->{'serial'},
        $biblio->{'unititle'},    $biblio->{'notes'},
        $biblio->{'biblionumber'}
    );

    $sth->finish;
    return ( $biblio->{'biblionumber'} );
}    # sub modbiblio

sub OLDmodsubtitle {
    my ( $dbh, $bibnum, $subtitle ) = @_;
    my $sth =
      $dbh->prepare(
        "update bibliosubtitle set subtitle = ? where biblionumber = ?");
    $sth->execute( $subtitle, $bibnum );
    $sth->finish;
}    # sub modsubtitle

sub OLDmodaddauthor {
    my ( $dbh, $bibnum, @authors ) = @_;

    #    my $dbh   = C4Connect;
    my $sth =
      $dbh->prepare("Delete from additionalauthors where biblionumber = ?");

    $sth->execute($bibnum);
    $sth->finish;
    foreach my $author (@authors) {
        if ( $author ne '' ) {
            $sth =
              $dbh->prepare(
                "Insert into additionalauthors set author = ?, biblionumber = ?"
            );

            $sth->execute( $author, $bibnum );

            $sth->finish;
        }    # if
    }
}    # sub modaddauthor

sub OLDmodsubject {
    my ( $dbh, $bibnum, $force, @subject ) = @_;

    #  my $dbh   = C4Connect;
    my $count = @subject;
    my $error="";
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        $subject[$i] =~ s/^ //g;
        $subject[$i] =~ s/ $//g;
        my $sth =
          $dbh->prepare(
"select * from catalogueentry where entrytype = 's' and catalogueentry = ?"
        );
        $sth->execute( $subject[$i] );

        if ( my $data = $sth->fetchrow_hashref ) {
        }
        else {
            if ( $force eq $subject[$i] || $force == 1 ) {

                # subject not in aut, chosen to force anway
                # so insert into cataloguentry so its in auth file
                my $sth2 =
                  $dbh->prepare(
"Insert into catalogueentry (entrytype,catalogueentry) values ('s',?)"
                );

                $sth2->execute( $subject[$i] ) if ( $subject[$i] );
                $sth2->finish;
            }
            else {
                $error =
                  "$subject[$i]\n does not exist in the subject authority file";
                my $sth2 =
                  $dbh->prepare(
"Select * from catalogueentry where entrytype = 's' and (catalogueentry like ? or catalogueentry like ? or catalogueentry like ?)"
                );
                $sth2->execute( "$subject[$i] %", "% $subject[$i] %",
                    "% $subject[$i]" );
                while ( my $data = $sth2->fetchrow_hashref ) {
                    $error .= "<br>$data->{'catalogueentry'}";
                }    # while
                $sth2->finish;
            }    # else
        }    # else
        $sth->finish;
    }    # else
    if ($error eq '') {
        my $sth =
          $dbh->prepare("Delete from bibliosubject where biblionumber = ?");
        $sth->execute($bibnum);
        $sth->finish;
        $sth =
          $dbh->prepare(
            "Insert into bibliosubject (subject,biblionumber) values (?,?)");
        my $query;
        foreach $query (@subject) {
            $sth->execute( $query, $bibnum ) if ( $query && $bibnum );
        }    # foreach
        $sth->finish;
    }    # if

    #  $dbh->disconnect;
    return ($error);
}    # sub modsubject

sub OLDmodbibitem {
# modified by rhariram to fix koha bug 1230
# See http://bugs.koha.org/cgi-bin/bugzilla/show_bug.cgi?id=1230
    my ( $dbh, $biblioitem ) = @_;
    my $query;
    my $sth;

    $query = "";
    $sth   =
      $dbh->prepare(
    "Update biblioitems set
	itemtype        = ?,
	url             = ?,
	isbn            = ?,
	issn            = ?,
	publishercode   = ?,
	publicationyear = ?,
	classification  = ?,
	dewey           = ?,
	subclass        = ?,
	illus           = ?,
	pages           = ?,
	volumeddesc     = ?,
	volumedate     = ?,
	notes 		= ?,
	size		= ?,
	place		= ?,
	volume		= ?,
	number		= ?,
	lccn		= ?
	where biblioitemnumber = ?"
    );

    $sth->execute(
	$biblioitem->{'itemtype'},
	$biblioitem->{'url'},
	$biblioitem->{'isbn'},
	$biblioitem->{'issn'},
	$biblioitem->{'publishercode'},
	$biblioitem->{'publicationyear'},
	$biblioitem->{'classification'},
	$biblioitem->{'dewey'},
	$biblioitem->{'subclass'},
	$biblioitem->{'illus'},
	$biblioitem->{'pages'},
	$biblioitem->{'volumeddesc'},
	$biblioitem->{'volumedate'},
	$biblioitem->{'bnotes'},
	$biblioitem->{'size'},
	$biblioitem->{'place'},
	$biblioitem->{'volume'},
	$biblioitem->{'number'},
	$biblioitem->{'lccn'},
	$biblioitem->{'biblioitemnumber'}
    );
    $sth->finish;
}    # sub modbibitem

sub OLDmodnote {
    my ( $dbh, $bibitemnum, $note ) = @_;

    #  my $dbh=C4Connect;
    my $query = "update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;

    #  $dbh->disconnect;
}

sub OLDnewbiblioitem {
    my ( $dbh, $biblioitem ) = @_;

    #  my $dbh   = C4Connect;
    my $sth = $dbh->prepare("Select max(biblioitemnumber) from biblioitems");
    my $data;
    my $bibitemnum;

    $sth->execute;
    $data       = $sth->fetchrow_arrayref;
    $bibitemnum = $$data[0] + 1;

    $sth->finish;

    $sth = $dbh->prepare( "insert into biblioitems set
									biblioitemnumber = ?,		biblionumber 	 = ?,
									volume		 = ?,			number		 = ?,
									classification  = ?,			itemtype         = ?,
									url              = ?,				isbn		 = ?,
									issn		 = ?,				dewey		 = ?,
									subclass	 = ?,				publicationyear	 = ?,
									publishercode	 = ?,		volumedate	 = ?,
									volumeddesc	 = ?,		illus		 = ?,
									pages		 = ?,				notes		 = ?,
									size		 = ?,				lccn		 = ?,
									marc		 = ?,				place		 = ?"
    );
    $sth->execute(
        $bibitemnum,                     $biblioitem->{'biblionumber'},
        $biblioitem->{'volume'},         $biblioitem->{'number'},
        $biblioitem->{'classification'}, $biblioitem->{'itemtype'},
        $biblioitem->{'url'},            $biblioitem->{'isbn'},
        $biblioitem->{'issn'},           $biblioitem->{'dewey'},
        $biblioitem->{'subclass'},       $biblioitem->{'publicationyear'},
        $biblioitem->{'publishercode'},  $biblioitem->{'volumedate'},
        $biblioitem->{'volumeddesc'},    $biblioitem->{'illus'},
        $biblioitem->{'pages'},          $biblioitem->{'bnotes'},
        $biblioitem->{'size'},           $biblioitem->{'lccn'},
        $biblioitem->{'marc'},           $biblioitem->{'place'}
    );
    $sth->finish;

    #    $dbh->disconnect;
    return ($bibitemnum);
}

sub OLDnewsubject {
    my ( $dbh, $bibnum ) = @_;
    my $sth =
      $dbh->prepare("insert into bibliosubject (biblionumber) values (?)");
    $sth->execute($bibnum);
    $sth->finish;
}

sub OLDnewsubtitle {
    my ( $dbh, $bibnum, $subtitle ) = @_;
    my $sth =
      $dbh->prepare(
        "insert into bibliosubtitle set biblionumber = ?, subtitle = ?");
    $sth->execute( $bibnum, $subtitle ) if $subtitle;
    $sth->finish;
}

sub OLDnewitems {
    my ( $dbh, $item, $barcode ) = @_;

    #  my $dbh   = C4Connect;
    my $sth = $dbh->prepare("Select max(itemnumber) from items");
    my $data;
    my $itemnumber;
    my $error = "";

    $sth->execute;
    my ($maxitemnumber)= $sth->fetchrow;
    $itemnumber = $maxitemnumber + 1;
    $sth->finish;

# FIXME the "notforloan" field seems to be named "loan" in some places. workaround bugfix.
    if ( $item->{'loan'} ) {
        $item->{'notforloan'} = $item->{'loan'};
    }

    # if dateaccessioned is provided, use it. Otherwise, set to NOW()
    if ( $item->{'dateaccessioned'} ) {
        $sth = $dbh->prepare( "Insert into items set
							itemnumber           = ?,			biblionumber         = ?,
							multivolumepart      = ?,
							biblioitemnumber     = ?,			barcode              = ?,
							booksellerid         = ?,			dateaccessioned      = ?,
							homebranch           = ?,			holdingbranch        = ?,
							price                = ?,			replacementprice     = ?,
							replacementpricedate = NOW(),		datelastseen		= NOW(),
							multivolume			= ?,			stack				= ?,
							itemlost			= ?,			wthdrawn			= ?,
							paidfor				= ?,			itemnotes            = ?,
							itemcallnumber	=?, 							notforloan = ?,
							location = ?
							"
        );
        $sth->execute(
			$itemnumber,				$item->{'biblionumber'},
			$item->{'multivolumepart'},
			$item->{'biblioitemnumber'},$barcode,
			$item->{'booksellerid'},	$item->{'dateaccessioned'},
			$item->{'homebranch'},		$item->{'holdingbranch'},
			$item->{'price'},			$item->{'replacementprice'},
			$item->{multivolume},		$item->{stack},
			$item->{itemlost},			$item->{wthdrawn},
			$item->{paidfor},			$item->{'itemnotes'},
			$item->{'itemcallnumber'},	$item->{'notforloan'},
			$item->{'location'}
        );
    }
    else {
        $sth = $dbh->prepare( "Insert into items set
							itemnumber           = ?,			biblionumber         = ?,
							multivolumepart      = ?,
							biblioitemnumber     = ?,			barcode              = ?,
							booksellerid         = ?,			dateaccessioned      = NOW(),
							homebranch           = ?,			holdingbranch        = ?,
							price                = ?,			replacementprice     = ?,
							replacementpricedate = NOW(),		datelastseen		= NOW(),
							multivolume			= ?,			stack				= ?,
							itemlost			= ?,			wthdrawn			= ?,
							paidfor				= ?,			itemnotes            = ?,
							itemcallnumber	=?, 							notforloan = ?,
							location = ?
							"
        );
        $sth->execute(
			$itemnumber,				$item->{'biblionumber'},
			$item->{'multivolumepart'},
			$item->{'biblioitemnumber'},$barcode,
			$item->{'booksellerid'},
			$item->{'homebranch'},		$item->{'holdingbranch'},
			$item->{'price'},			$item->{'replacementprice'},
			$item->{multivolume},		$item->{stack},
			$item->{itemlost},			$item->{wthdrawn},
			$item->{paidfor},			$item->{'itemnotes'},
			$item->{'itemcallnumber'},	$item->{'notforloan'},
			$item->{'location'}
        );
    }
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
    $sth->finish;
    return ( $itemnumber, $error );
}

sub OLDmoditem {
    my ( $dbh, $item ) = @_;
    $item->{'itemnum'} = $item->{'itemnumber'} unless $item->{'itemnum'};
    my $query = "update items set  barcode=?,itemnotes=?,itemcallnumber=?,notforloan=?,location=?,multivolumepart=?,multivolume=?,stack=?,wthdrawn=?";
    my @bind = (
        $item->{'barcode'},			$item->{'itemnotes'},
        $item->{'itemcallnumber'},	$item->{'notforloan'},
        $item->{'location'},		$item->{multivolumepart},
		$item->{multivolume},		$item->{stack},
		$item->{wthdrawn},
    );
    if ( $item->{'lost'} ne '' ) {
        $query = "update items set biblioitemnumber=?,barcode=?,itemnotes=?,homebranch=?,
							itemlost=?,wthdrawn=?,itemcallnumber=?,notforloan=?,
				 			location=?,multivolumepart=?,multivolume=?,stack=?,wthdrawn=?";
        @bind = (
            $item->{'bibitemnum'},     $item->{'barcode'},
            $item->{'itemnotes'},          $item->{'homebranch'},
            $item->{'lost'},           $item->{'wthdrawn'},
            $item->{'itemcallnumber'}, $item->{'notforloan'},
            $item->{'location'},		$item->{multivolumepart},
			$item->{multivolume},		$item->{stack},
			$item->{wthdrawn},
        );
    }
    if ($item->{homebranch}) {
        $query.=",homebranch=?";
        push @bind, $item->{homebranch};
    }
    if ($item->{holdingbranch}) {
        $query.=",holdingbranch=?";
        push @bind, $item->{holdingbranch};
    }
	$query.=" where itemnumber=?";
	push @bind,$item->{'itemnum'};
   if ( $item->{'replacement'} ne '' ) {
        $query =~ s/ where/,replacementprice='$item->{'replacement'}' where/;
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $sth->finish;

    #  $dbh->disconnect;
}

sub OLDdelitem {
    my ( $dbh, $itemnum ) = @_;

    #  my $dbh=C4Connect;
    my $sth = $dbh->prepare("select * from items where itemnumber=?");
    $sth->execute($itemnum);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $query = "Insert into deleteditems set ";
    my @bind  = ();
    foreach my $temp ( keys %$data ) {
        $query .= "$temp = ?,";
        push ( @bind, $data->{$temp} );
    }
    $query =~ s/\,$//;

    #  print $query;
    $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $sth->finish;
    $sth = $dbh->prepare("Delete from items where itemnumber=?");
    $sth->execute($itemnum);
    $sth->finish;

    #  $dbh->disconnect;
}

sub OLDdeletebiblioitem {
    my ( $dbh, $biblioitemnumber ) = @_;

    #    my $dbh   = C4Connect;
    my $sth = $dbh->prepare( "Select * from biblioitems
where biblioitemnumber = ?"
    );
    my $results;

    $sth->execute($biblioitemnumber);

    if ( $results = $sth->fetchrow_hashref ) {
        $sth->finish;
        $sth =
          $dbh->prepare(
"Insert into deletedbiblioitems (biblioitemnumber, biblionumber, volume, number, classification, itemtype,
					isbn, issn ,dewey ,subclass ,publicationyear ,publishercode ,volumedate ,volumeddesc ,timestamp ,illus ,
     					pages ,notes ,size ,url ,lccn ) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        );

        $sth->execute(
            $results->{biblioitemnumber}, $results->{biblionumber},
            $results->{volume},           $results->{number},
            $results->{classification},   $results->{itemtype},
            $results->{isbn},             $results->{issn},
            $results->{dewey},            $results->{subclass},
            $results->{publicationyear},  $results->{publishercode},
            $results->{volumedate},       $results->{volumeddesc},
            $results->{timestamp},        $results->{illus},
            $results->{pages},            $results->{notes},
            $results->{size},             $results->{url},
            $results->{lccn}
        );
        my $sth2 =
          $dbh->prepare("Delete from biblioitems where biblioitemnumber = ?");
        $sth2->execute($biblioitemnumber);
        $sth2->finish();
    }    # if
    $sth->finish;

    # Now delete all the items attached to the biblioitem
    $sth = $dbh->prepare("Select * from items where biblioitemnumber = ?");
    $sth->execute($biblioitemnumber);
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        my $query = "Insert into deleteditems set ";
        my @bind  = ();
        foreach my $temp ( keys %$data ) {
			next if ($temp =~/itemcallnumber/);
            $query .= "$temp = ?,";
            push ( @bind, $data->{$temp} );
        }
        $query =~ s/\,$//;
        my $sth2 = $dbh->prepare($query);
        $sth2->execute(@bind);
    }    # while
    $sth->finish;
    $sth = $dbh->prepare("Delete from items where biblioitemnumber = ?");
    $sth->execute($biblioitemnumber);
    $sth->finish();

    #    $dbh->disconnect;
}    # sub deletebiblioitem

sub OLDdelbiblio {
    my ( $dbh, $biblio ) = @_;
    my $sth = $dbh->prepare("select * from biblio where biblionumber=?");
    $sth->execute($biblio);
    if ( my $data = $sth->fetchrow_hashref ) {
        $sth->finish;
        my $query = "Insert into deletedbiblio set ";
        my @bind  = ();
        foreach my $temp ( keys %$data ) {
            $query .= "$temp = ?,";
            push ( @bind, $data->{$temp} );
        }

        #replacing the last , by ",?)"
        $query =~ s/\,$//;
        $sth = $dbh->prepare($query);
        $sth->execute(@bind);
        $sth->finish;
        $sth = $dbh->prepare("Delete from biblio where biblionumber=?");
        $sth->execute($biblio);
        $sth->finish;
    }
    $sth->finish;
}

#
#
# old functions
#
#

sub itemcount {
    my ($biblio) = @_;
    my $dbh = C4::Context->dbh;

    #  print $query;
    my $sth = $dbh->prepare("Select count(*) from items where biblionumber=?");
    $sth->execute($biblio);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ( $data->{'count(*)'} );
}

sub newbiblio {
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
    my $bibnum = OLDnewbiblio( $dbh, $biblio );
    # finds new (MARC bibid
    # 	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$bibnum);
    my $record = &MARCkoha2marcBiblio( $dbh, $bibnum );
    MARCaddbiblio( $dbh, $record, $bibnum,'' );
    return ($bibnum);
}

=item modbiblio

  $biblionumber = &modbiblio($biblio);

Update a biblio record.

C<$biblio> is a reference-to-hash whose keys are the fields in the
biblio table in the Koha database. All fields must be present, not
just the ones you wish to change.

C<&modbiblio> updates the record defined by
C<$biblio-E<gt>{biblionumber}> with the values in C<$biblio>.

C<&modbiblio> returns C<$biblio-E<gt>{biblionumber}> whether it was
successful or not.

=cut

sub modbiblio {
	my ($biblio) = @_;
	my $dbh  = C4::Context->dbh;
	my $biblionumber=OLDmodbiblio($dbh,$biblio);
	my $record = MARCkoha2marcBiblio($dbh,$biblionumber,$biblionumber);
	# finds new (MARC bibid
	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
	MARCmodbiblio($dbh,$bibid,$record,"",0);
	return($biblionumber);
} # sub modbiblio

=item modsubtitle

  &modsubtitle($biblionumber, $subtitle);

Sets the subtitle of a book.

C<$biblionumber> is the biblionumber of the book to modify.

C<$subtitle> is the new subtitle.

=cut

sub modsubtitle {
    my ( $bibnum, $subtitle ) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmodsubtitle( $dbh, $bibnum, $subtitle );
}    # sub modsubtitle

=item modaddauthor

  &modaddauthor($biblionumber, $author);

Replaces all additional authors for the book with biblio number
C<$biblionumber> with C<$author>. If C<$author> is the empty string,
C<&modaddauthor> deletes all additional authors.

=cut

sub modaddauthor {
    my ( $bibnum, @authors ) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmodaddauthor( $dbh, $bibnum, @authors );
}    # sub modaddauthor

=item modsubject

  $error = &modsubject($biblionumber, $force, @subjects);

$force - a subject to force

$error - Error message, or undef if successful.

=cut

sub modsubject {
    my ( $bibnum, $force, @subject ) = @_;
    my $dbh = C4::Context->dbh;
    my $error = &OLDmodsubject( $dbh, $bibnum, $force, @subject );
    if ($error eq ''){
		# When MARC is off, ensures that the MARC biblio table gets updated with new
		# subjects, of course, it deletes the biblio in marc, and then recreates.
		# This check is to ensure that no MARC data exists to lose.
		if (C4::Context->preference("MARC") eq '0'){
			my $MARCRecord = &MARCkoha2marcBiblio($dbh,$bibnum);
			my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$bibnum);
			&MARCmodbiblio($dbh,$bibid, $MARCRecord);
		}
	}
	return ($error);
}    # sub modsubject

sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmodbibitem( $dbh, $biblioitem );
}    # sub modbibitem

sub modnote {
    my ( $bibitemnum, $note ) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmodnote( $dbh, $bibitemnum, $note );
}

sub newbiblioitem {
    my ($biblioitem) = @_;
    my $dbh        = C4::Context->dbh;
    my $bibitemnum = &OLDnewbiblioitem( $dbh, $biblioitem );

    my $MARCbiblio =
      MARCkoha2marcBiblio( $dbh, $biblioitem->{biblionumber}, $bibitemnum );
      # the 0 means "do NOT retrieve biblio, only biblioitem, in the MARC record
    my $bibid =
      &MARCfind_MARCbibid_from_oldbiblionumber( $dbh,
        $biblioitem->{biblionumber} );
    # delete biblio, as we will reintroduce it the line after
    # the biblio is complete from MARCkoha2marcBiblio (3 lines before)
    &MARCdelbiblio($dbh,$bibid,1);
    &MARCaddbiblio( $dbh, $MARCbiblio, $biblioitem->{biblionumber}, '',$bibid );
    return ($bibitemnum);
}

sub newsubject {
    my ($bibnum) = @_;
    my $dbh = C4::Context->dbh;
    &OLDnewsubject( $dbh, $bibnum );
}

sub newsubtitle {
    my ( $bibnum, $subtitle ) = @_;
    my $dbh = C4::Context->dbh;
    &OLDnewsubtitle( $dbh, $bibnum, $subtitle );
}

sub newitems {
    my ( $item, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $errors;
    my $itemnumber;
    my $error;
    foreach my $barcode (@barcodes) {
        ( $itemnumber, $error ) = &OLDnewitems( $dbh, $item, uc($barcode) );
        $errors .= $error;
        my $MARCitem =
          &MARCkoha2marcItem( $dbh, $item->{biblionumber}, $itemnumber );
        &MARCadditem( $dbh, $MARCitem, $item->{biblionumber} );
    }
    return ($errors);
}

sub moditem {
    my ($item) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmoditem( $dbh, $item );
    my $MARCitem =
      &MARCkoha2marcItem( $dbh, $item->{'biblionumber'}, $item->{'itemnum'} );
    my $bibid =
      &MARCfind_MARCbibid_from_oldbiblionumber( $dbh, $item->{biblionumber} );
    &MARCmoditem( $dbh, $MARCitem, $bibid, $item->{itemnum}, 0 );
}

sub checkitems {
    my ( $count, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $error;
    my $sth = $dbh->prepare("Select * from items where barcode=?");
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        $barcodes[$i] = uc $barcodes[$i];
        $sth->execute( $barcodes[$i] );
        if ( my $data = $sth->fetchrow_hashref ) {
            $error .= " Duplicate Barcode: $barcodes[$i]";
        }
    }
    $sth->finish;
    return ($error);
}

sub countitems {
    my ($bibitemnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "";
    my $sth   =
      $dbh->prepare("Select count(*) from items where biblioitemnumber=?");
    $sth->execute($bibitemnum);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ( $data->{'count(*)'} );
}

sub delitem {
    my ($itemnum) = @_;
    my $dbh = C4::Context->dbh;
    &OLDdelitem( $dbh, $itemnum );
}

sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh = C4::Context->dbh;
    &OLDdeletebiblioitem( $dbh, $biblioitemnumber );
}    # sub deletebiblioitem

sub delbiblio {
    my ($biblio) = @_;
    my $dbh = C4::Context->dbh;
    &OLDdelbiblio( $dbh, $biblio );
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber( $dbh, $biblio );
    &MARCdelbiblio( $dbh, $bibid, 0 );
}

sub getbiblio {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select * from biblio where biblionumber = ?");

    # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);

    # || die "Cannot execute $query\n" . $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getbiblio

sub getbiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "Select * from biblioitems where
biblioitemnumber = ?"
    );
    my $count = 0;
    my @results;

    $sth->execute($biblioitemnum);

    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getbiblioitem

sub getbiblioitembybiblionumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select * from biblioitems where biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);

    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub

sub getitemtypes {
    my $dbh   = C4::Context->dbh;
    my $query = "select * from itemtypes order by description";
    my $sth   = $dbh->prepare($query);

    # || die "Cannot prepare $query" . $dbh->errstr;      
    my $count = 0;
    my @results;

    $sth->execute;

    # || die "Cannot execute $query\n" . $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getitemtypes

sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "Select * from items, biblio where
biblio.biblionumber = items.biblionumber and biblioitemnumber
= ?"
    );

    # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;

    $sth->execute($biblioitemnum);

    # || die "Cannot execute $query\n" . $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getitemsbybiblioitem

sub logchange {

    # Subroutine to log changes to databases
# Eventually, this subroutine will be used to create a log of all changes made,
    # with the possibility of "undo"ing some changes
    my $database = shift;
    if ( $database eq 'kohadb' ) {
        my $type     = shift;
        my $section  = shift;
        my $item     = shift;
        my $original = shift;
        my $new      = shift;

        #	print STDERR "KOHA: $type $section $item $original $new\n";
    }
    elsif ( $database eq 'marc' ) {
        my $type        = shift;
        my $Record_ID   = shift;
        my $tag         = shift;
        my $mark        = shift;
        my $subfield_ID = shift;
        my $original    = shift;
        my $new         = shift;

#	print STDERR "MARC: $type $Record_ID $tag $mark $subfield_ID $original $new\n";
    }
}

#------------------------------------------------

#---------------------------------------
# Find a biblio entry, or create a new one if it doesn't exist.
#  If a "subtitle" entry is in hash, add it to subtitle table
sub getoraddbiblio {

    # input params
    my (
        $dbh,       # db handle
                    # FIXME - Unused argument
        $biblio,    # hash ref to fields
    ) = @_;

    # return
    my $biblionumber;

    my $debug = 0;
    my $sth;
    my $error;

    #-----
    $dbh = C4::Context->dbh;

    print "<PRE>Looking for biblio </PRE>\n" if $debug;
    $sth = $dbh->prepare( "select biblionumber
		from biblio
		where title=? and author=?
		  and copyrightdate=? and seriestitle=?"
    );
    $sth->execute(
        $biblio->{title},     $biblio->{author},
        $biblio->{copyright}, $biblio->{seriestitle}
    );
    if ( $sth->rows ) {
        ($biblionumber) = $sth->fetchrow;
        print "<PRE>Biblio exists with number $biblionumber</PRE>\n" if $debug;
    }
    else {

        # Doesn't exist.  Add new one.
        print "<PRE>Adding biblio</PRE>\n" if $debug;
        ( $biblionumber, $error ) = &newbiblio($biblio);
        if ($biblionumber) {
            print "<PRE>Added with biblio number=$biblionumber</PRE>\n"
              if $debug;
            if ( $biblio->{subtitle} ) {
                &newsubtitle( $biblionumber, $biblio->{subtitle} );
            }    # if subtitle
        }
        else {
            print "<PRE>Couldn't add biblio: $error</PRE>\n" if $debug;
        }    # if added
    }

    return $biblionumber, $error;

}    # sub getoraddbiblio

sub char_decode {

    # converts ISO 5426 coded string to ISO 8859-1
    # sloppy code : should be improved in next issue
    my ( $string, $encoding ) = @_;
    $_ = $string;

    # 	$encoding = C4::Context->preference("marcflavour") unless $encoding;
    if ( $encoding eq "UNIMARC" ) {
#         s/\xe1/Æ/gm;
        s/\xe2/Ð/gm;
        s/\xe9/Ø/gm;
        s/\xec/þ/gm;
        s/\xf1/æ/gm;
        s/\xf3/ð/gm;
        s/\xf9/ø/gm;
        s/\xfb/ß/gm;
        s/\xc1\x61/à/gm;
        s/\xc1\x65/è/gm;
        s/\xc1\x69/ì/gm;
        s/\xc1\x6f/ò/gm;
        s/\xc1\x75/ù/gm;
        s/\xc1\x41/À/gm;
        s/\xc1\x45/È/gm;
        s/\xc1\x49/Ì/gm;
        s/\xc1\x4f/Ò/gm;
        s/\xc1\x55/Ù/gm;
        s/\xc2\x41/Á/gm;
        s/\xc2\x45/É/gm;
        s/\xc2\x49/Í/gm;
        s/\xc2\x4f/Ó/gm;
        s/\xc2\x55/Ú/gm;
        s/\xc2\x59/Ý/gm;
        s/\xc2\x61/á/gm;
        s/\xc2\x65/é/gm;
        s/\xc2\x69/í/gm;
        s/\xc2\x6f/ó/gm;
        s/\xc2\x75/ú/gm;
        s/\xc2\x79/ý/gm;
        s/\xc3\x41/Â/gm;
        s/\xc3\x45/Ê/gm;
        s/\xc3\x49/Î/gm;
        s/\xc3\x4f/Ô/gm;
        s/\xc3\x55/Û/gm;
        s/\xc3\x61/â/gm;
        s/\xc3\x65/ê/gm;
        s/\xc3\x69/î/gm;
        s/\xc3\x6f/ô/gm;
        s/\xc3\x75/û/gm;
        s/\xc4\x41/Ã/gm;
        s/\xc4\x4e/Ñ/gm;
        s/\xc4\x4f/Õ/gm;
        s/\xc4\x61/ã/gm;
        s/\xc4\x6e/ñ/gm;
        s/\xc4\x6f/õ/gm;
        s/\xc8\x41/Ä/gm;
        s/\xc8\x45/Ë/gm;
        s/\xc8\x49/Ï/gm;
        s/\xc8\x61/ä/gm;
        s/\xc8\x65/ë/gm;
        s/\xc8\x69/ï/gm;
        s/\xc8\x6F/ö/gm;
        s/\xc8\x75/ü/gm;
        s/\xc8\x76/ÿ/gm;
        s/\xc9\x41/Ä/gm;
        s/\xc9\x45/Ë/gm;
        s/\xc9\x49/Ï/gm;
        s/\xc9\x4f/Ö/gm;
        s/\xc9\x55/Ü/gm;
        s/\xc9\x61/ä/gm;
        s/\xc9\x6f/ö/gm;
        s/\xc9\x75/ü/gm;
        s/\xca\x41/Å/gm;
        s/\xca\x61/å/gm;
        s/\xd0\x43/Ç/gm;
        s/\xd0\x63/ç/gm;

        # this handles non-sorting blocks (if implementation requires this)
        $string = nsb_clean($_);
    }
    elsif ( $encoding eq "USMARC" || $encoding eq "MARC21" ) {
        if (/[\xc1-\xff]/) {
            s/\xe1\x61/à/gm;
            s/\xe1\x65/è/gm;
            s/\xe1\x69/ì/gm;
            s/\xe1\x6f/ò/gm;
            s/\xe1\x75/ù/gm;
            s/\xe1\x41/À/gm;
            s/\xe1\x45/È/gm;
            s/\xe1\x49/Ì/gm;
            s/\xe1\x4f/Ò/gm;
            s/\xe1\x55/Ù/gm;
            s/\xe2\x41/Á/gm;
            s/\xe2\x45/É/gm;
            s/\xe2\x49/Í/gm;
            s/\xe2\x4f/Ó/gm;
            s/\xe2\x55/Ú/gm;
            s/\xe2\x59/Ý/gm;
            s/\xe2\x61/á/gm;
            s/\xe2\x65/é/gm;
            s/\xe2\x69/í/gm;
            s/\xe2\x6f/ó/gm;
            s/\xe2\x75/ú/gm;
            s/\xe2\x79/ý/gm;
            s/\xe3\x41/Â/gm;
            s/\xe3\x45/Ê/gm;
            s/\xe3\x49/Î/gm;
            s/\xe3\x4f/Ô/gm;
            s/\xe3\x55/Û/gm;
            s/\xe3\x61/â/gm;
            s/\xe3\x65/ê/gm;
            s/\xe3\x69/î/gm;
            s/\xe3\x6f/ô/gm;
            s/\xe3\x75/û/gm;
            s/\xe4\x41/Ã/gm;
            s/\xe4\x4e/Ñ/gm;
            s/\xe4\x4f/Õ/gm;
            s/\xe4\x61/ã/gm;
            s/\xe4\x6e/ñ/gm;
            s/\xe4\x6f/õ/gm;
            s/\xe8\x45/Ë/gm;
            s/\xe8\x49/Ï/gm;
            s/\xe8\x65/ë/gm;
            s/\xe8\x69/ï/gm;
            s/\xe8\x76/ÿ/gm;
            s/\xe9\x41/Ä/gm;
            s/\xe9\x4f/Ö/gm;
            s/\xe9\x55/Ü/gm;
            s/\xe9\x61/ä/gm;
            s/\xe9\x6f/ö/gm;
            s/\xe9\x75/ü/gm;
            s/\xea\x41/Å/gm;
            s/\xea\x61/å/gm;

            # this handles non-sorting blocks (if implementation requires this)
            $string = nsb_clean($_);
        }
    }
    return ($string);
}

sub nsb_clean {
    my $NSB = '\x88';    # NSB : begin Non Sorting Block
    my $NSE = '\x89';    # NSE : Non Sorting Block end
                         # handles non sorting blocks
    my ($string) = @_;
    $_ = $string;
    s/$NSB/(/gm;
    s/[ ]{0,1}$NSE/) /gm;
    $string = $_;
    return ($string);
}

sub FindDuplicate {
	my ($record)=@_;
	my $dbh = C4::Context->dbh;
	my $result = MARCmarc2koha($dbh,$record,'');
	my $sth;
	my ($biblionumber,$bibid,$title);
	# search duplicate on ISBN, easy and fast...
	if ($result->{isbn}) {
		$sth = $dbh->prepare("select biblio.biblionumber,bibid,title from biblio,biblioitems,marc_biblio where biblio.biblionumber=biblioitems.biblionumber and marc_biblio.biblionumber=biblioitems.biblionumber and isbn=?");
		$sth->execute($result->{'isbn'});
		($biblionumber,$bibid,$title) = $sth->fetchrow;
		return $biblionumber,$bibid,$title if ($biblionumber);
	}
	# a more complex search : build a request for SearchMarc::catalogsearch()
	my (@tags, @and_or, @excluding, @operator, @value, $offset,$length);
	# search on biblio.title
	my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblio.title","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "contains";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for title, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubtitle.subtitle","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "contains";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for title, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	# ... and on biblio.author
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblio.author","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "contains";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for author, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	# ... and on publicationyear.
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.publicationyear","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for publicationyear, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	# ... and on size.
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.size","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for size, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	# ... and on publisher.
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.publishercode","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for publishercode, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}
	# ... and on volume.
	($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.volume","");
	if ($record->field($tag)) {
		if ($record->field($tag)->subfields($subfield)) {
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $record->field($tag)->subfield($subfield);
# 			warn "for volume, I add $tag / $subfield".$record->field($tag)->subfield($subfield);
		}
	}

	my ($finalresult,$nbresult) = C4::SearchMarc::catalogsearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10);
	# there is at least 1 result => return the 1st one
	if ($nbresult) {
# 		warn "$nbresult => ".@$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
		return @$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
	}
	# no result, returns nothing
	return;
}

sub DisplayISBN {
	my ($isbn)=@_;
	if ($isbn =~ /-/) {
		return $isbn;
	}
	else {
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
	my $seg3=substr($x,length($seg2));
	$seg3=substr($seg3,0,length($seg3)-1) ;
	my $seg4 = substr($x, -1, 1);
	return "$seg1-$seg2-$seg3-$seg4";
	}
}

=head2 getitemstatus

  $itemstatushash = &getitemstatus($fwkcode);
  returns information about status.
  Can be MARC dependant.
  fwkcode is optional.
  But basically could be can be loan or not
  Create a status selector with the following code
  
=head3 in PERL SCRIPT

my $itemstatushash = getitemstatus;
my @itemstatusloop;
foreach my $thisstatus (keys %$itemstatushash) {
	my %row =(value => $thisstatus,
				statusname => $itemstatushash->{$thisstatus}->{'statusname'},
			);
	push @itemstatusloop, \%row;
}
$template->param(statusloop=>\@itemstatusloop);


=head3 in TEMPLATE  
			<select name="statusloop">
				<option value="">Default</option>
			<!-- TMPL_LOOP name="statusloop" -->
				<option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="statusname" --></option>
			<!-- /TMPL_LOOP -->
			</select>

=cut
sub getitemstatus {
# returns a reference to a hash of references to status...
	my ($fwk)=@_;
	my %itemstatus;
 	my $dbh = C4::Context->dbh;
 	my $sth;
	$fwk='' unless ($fwk);
 	my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.notforloan",$fwk);
	if ($tag and $subfield){
		my $sth = $dbh->prepare("select authorised_value from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
		$sth->execute($tag,$subfield,$fwk);
		if (my ($authorisedvaluecat)=$sth->fetchrow){
			my $authvalsth=$dbh->prepare("select authorised_value, lib from authorised_values where category=? order by lib");
			$authvalsth->execute($authorisedvaluecat);
			while (my ($authorisedvalue, $lib)=$authvalsth->fetchrow){
				$itemstatus{$authorisedvalue}=$lib;
			}
			$authvalsth->finish;
			return \%itemstatus;
			exit 1;
		} else{
			#No authvalue list
			# build default
		}
		$sth->finish;
	}
	#No authvalue list
	#build default
	$itemstatus{"1"}="Not For Loan";
	return \%itemstatus;
}
=head2 getitemlocation

  $itemlochash = &getitemlocation($fwk);
  returns informations about location.
  where fwk stands for an optional framework code.
  Create a location selector with the following code
  
=head3 in PERL SCRIPT

my $itemlochash = getitemlocation;
my @itemlocloop;
foreach my $thisloc (keys %$itemlochash) {
	my $selected = 1 if $thisbranch eq $branch;
	my %row =(locval => $thisloc,
				selected => $selected,
				locname => $itemlochash->{$thisloc},
			);
	push @itemlocloop, \%row;
}
$template->param(itemlocationloop => \@itemlocloop);

=head3 in TEMPLATE  
			<select name="location">
				<option value="">Default</option>
			<!-- TMPL_LOOP name="itemlocationloop" -->
				<option value="<!-- TMPL_VAR name="locval" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="locname" --></option>
			<!-- /TMPL_LOOP -->
			</select>

=cut
sub getitemlocation {
# returns a reference to a hash of references to location...
	my ($fwk)=@_;
	my %itemlocation;
 	my $dbh = C4::Context->dbh;
 	my $sth;
	$fwk='' unless ($fwk);
 	my ($tag,$subfield)=MARCfind_marc_from_kohafield($dbh,"items.location",$fwk);
	if ($tag and $subfield){
		my $sth = $dbh->prepare("select authorised_value from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
		$sth->execute($tag,$subfield,$fwk);
		if (my ($authorisedvaluecat)=$sth->fetchrow){
			my $authvalsth=$dbh->prepare("select authorised_value, lib from authorised_values where category=? order by lib");
			$authvalsth->execute($authorisedvaluecat);
			while (my ($authorisedvalue, $lib)=$authvalsth->fetchrow){
				$itemlocation{$authorisedvalue}=$lib;
			}
			$authvalsth->finish;
			return \%itemlocation;
			exit 1;
		} else{
			#No authvalue list
			# build default
		}
		$sth->finish;
	}
	#No authvalue list
	#build default
	$itemlocation{"1"}="Not For Loan";
	return \%itemlocation;
}

END { }    # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.115.2.64.2.3  2007/04/30 14:00:38  tipaul
# I switched my desktop to mandriva 2007.1 with UTF-8 enabled, and it seems that caused some problems, once again in Biblio.pm char_decode sub.
#
# Revision 1.115.2.64.2.2  2007/04/27 13:08:28  tipaul
# porting bugfixes from rel_2_2 to rel_2_2_7 for 2.2.9 release
#
# Revision 1.115.2.64.2.1  2007/02/12 10:12:49  toins
# Commiting BUG FIX for 2.2.7.1.
#
# ( Applying patch to fix bug 1230.On editing marc entry: Publisher fields(tag 260) NOT stored as utf8 in mysql)
#
# Revision 1.115.2.64  2006/11/22 16:02:52  tipaul
# fix for #1177 = removal of additionnal authors & bibliosubjects
#
# Revision 1.115.2.63  2006/11/22 13:58:11  tipaul
# there are some strange problems with mysql_fetchrow_hashref, that reorders silently the hashref returned.
# This hack fixes them by retrieving the results in an array & rebuilding the MARC record from that.
# This function is used in acquisition, when the librarian creates a new order from a new biblio : the MARC::Record was incorrect (at least in UNIMARC, but this fix should change nothing in MARC21)
#
# Revision 1.115.2.62  2006/10/13 08:34:21  tipaul
# removing warn
#
# Revision 1.115.2.61  2006/09/13 14:30:31  tipaul
# oups...
# homebranch & holdingbranch modifications where just in an improper {} : should be done everytime (not only when item is lost)
#
# Fixes bug #1163
#
# Revision 1.115.2.60  2006/08/04 15:00:50  kados
# fix for bug 1139: ISBN search fails with double dashes
#
# In fact, ISBNs shouldn't have dashes inserted if they already exist
# in the ISBN field.
#
# Revision 1.115.2.59  2006/08/03 16:10:53  tipaul
# fix for 1052 : Major Bug in MARC tables Sync
#
# Revision 1.115.2.58  2006/06/19 13:18:17  tipaul
# reverting cloneTag bugs (see joshua mail on koha-devel) :
# * going back to a previous version, with server call to clone a Tag
# * keeping BIG_LOOP in template (just 1 template for every tag)
# I didn't check npl templates, but synch'ing them should not be too hard.
#
# (ps : i've reverted default templates to 1.33.2.23)
#
# Revision 1.115.2.54  2006/06/02 15:36:18  tipaul
# - fixing a small bug in html2marc, when the 1st subfield of a field was empty, the 2nd could not be filled as the MARC::Field had not been created.
#
# Revision 1.115.2.53  2006/05/11 14:55:24  kados
# MARC::File::XML switched the API in 0.83, this code updates Koha --
# it will break your record editing if you don't upgrade MARC::File::XML
# to 0.83 on CPAN.
