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
use C4::Date;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use ZOOM;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT = qw(
  &newbiblio &newbiblioitem
  &newsubject &newsubtitle &newitems 
  
  &modbiblio &checkitems &modbibitem
  &modsubtitle &modsubject &modaddauthor &moditem
  
  &delitem &deletebiblioitem &delbiblio
  
  &getbiblio &bibdata &bibitems &bibitemdata 
  &barcodes &ItemInfo &itemdata &itemissues &itemcount 
  &getsubject &getaddauthor &getsubtitle
  &getwebbiblioitems &getwebsites
  &getbiblioitembybiblionumber
  &getbiblioitem &getitemsbybiblioitem

  &MARCfind_marc_from_kohafield
  &MARCfind_frameworkcode
  &find_biblioitemnumber
  &MARCgettagslib

  &NEWnewbiblio &NEWnewitem
  &NEWmodbiblio &NEWmoditem
  &NEWdelbiblio &NEWdelitem
  &NEWmodbiblioframework

  &MARCkoha2marcBiblio &MARCmarc2koha
  &MARCkoha2marcItem &MARChtml2marc
  &MARCgetbiblio &MARCgetitem
  &XMLgetbiblio
  &char_decode
  
  &FindDuplicate
  &DisplayISBN
    
    get_item_from_barcode
    MARCfind_MARCbibid_from_oldbiblionumber
);

=head1 NAME

C4::Biblio - acquisition, catalog  management functions

=head1 SYNOPSIS

( lot of changes for Koha 3.0)

Koha 1.2 and previous version used a specific API to manage biblios. This API uses old-DB style parameters.
They are based on a hash, and store data in biblio/biblioitems/items tables (plus additionalauthors, bibliosubject and bibliosubtitle where applicable)

In Koha 2.0, we introduced a MARC-DB.

In Koha 3.0 we removed this MARC-DB for search as we wanted to use Zebra as search system.

So in Koha 3.0, saving a record means :
 - storing the raw marc record (iso2709) in biblioitems.marc field. It contains both biblio & items informations.
 - storing the "decoded information" in biblio/biblioitems/items as previously.
 - using zebra to manage search & indexing on the MARC datas.
 
 In Koha, there is a systempreference saying "MARC=ON" or "MARC=OFF"
 
 * MARC=ON : when MARC=ON, koha uses a MARC::Record object (in sub parameters). Saving informations in the DB means : 
 - transform the MARC record into a hash
 - add the raw marc record into the hash
 - store them & update zebra
 
 * MARC=OFF : when MARC=OFF, koha uses a hash object (in sub parameters). Saving informations in the DB means :
 - transform the hash into a MARC record
 - add the raw marc record into the hash
 - store them and update zebra
 
 
That's why we need 3 types of subs :

=head2 REALxxx subs

all I<subs beginning by REAL> does effective storage of information (with a hash, one field of the hash being the raw marc record). Those subs also update the record in zebra. REAL subs should be only for internal use (called by NEW or "something else" subs

=head2 NEWxxx related subs

=over 4

all I<subs beginning by NEW> use MARC::Record as parameters. it's the API that MUST be used in MARC acquisition system. They just create the hash, add it the raw marc record. Then, they call REALxxx sub.

all subs requires/use $dbh as 1st parameter and a MARC::Record object as 2nd parameter. they sometimes requires another parameter.

=back

=head2 something_elsexxx related subs

=over 4

all I<subs beginning by seomething else> are the old-style API. They use a hash as parameter, transform the hash into a -small- marc record, and calls REAL subs.

all subs requires/use $dbh as 1st parameter and a hash as 2nd parameter.

=back

=head1 API

=cut

sub zebra_create {
	my ($biblionumber,$record) = @_;
	# create the iso2709 file for zebra
# 	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
# 	unless (opendir(DIR, "$cgidir")) {
# 			$cgidir = C4::Context->intranetdir."/";
# 	} 
# 	closedir DIR;
# 	my $filename = $cgidir."/zebra/biblios/BIBLIO".$biblionumber."iso2709";
# 	open F,"> $filename";
# 	print F $record->as_usmarc();
# 	close F;
# 	my $res = system("cd $cgidir/zebra;/usr/local/bin/zebraidx update biblios");
# 	unlink($filename);
        my $Zconn;
        my $xmlrecord;
#	warn "zebra_create : $biblionumber =".$record->as_formatted;
        eval {
	    $xmlrecord=$record->as_xml();
	    };
        if ($@){
	    warn "ERROR badly formatted marc record";
	    warn "Skipping record";
	} 
        else {
	    eval {
		$Zconn = new ZOOM::Connection(C4::Context->config("zebradb"));
	    };
	    if ($@){
	        warn "Error ", $@->code(), ": ", $@->message(), "\n";
	        die "Fatal error, cant connect to z3950 server";
	    }
	    
	    $Zconn->option(cqlfile => C4::Context->config("intranetdir")."/zebra/pqf.properties");
	    my $Zpackage = $Zconn->package();
	    $Zpackage->option(action => "specialUpdate");        
	    $Zpackage->option(record => $xmlrecord);
	    $Zpackage->send("update");
	    $Zpackage->destroy;
	}
}

=head2 @tagslib = &MARCgettagslib($dbh,1|0,$frameworkcode);

=over 4

2nd param is 1 for liblibrarian and 0 for libopac
$frameworkcode contains the framework reference. If empty or does not exist, the default one is used

returns a hash with all values for all fields and subfields for a given MARC framework :
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
                    ->{tab}        = "";            # XXX
                    ->{mandatory}  = $mandatory;
                    ->{repeatable} = $repeatable;
                    ->{$subfield}->{lib}              = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
                                 ->{tab}              = $tab;
                                 ->{mandatory}        = $mandatory;
                                 ->{repeatable}       = $repeatable;
                                 ->{authorised_value} = $authorised_value;
                                 ->{authtypecode}     = $authtypecode;
                                 ->{value_builder}    = $value_builder;
                                 ->{kohafield}        = $kohafield;
                                 ->{seealso}          = $seealso;
                                 ->{hidden}           = $hidden;
                                 ->{isurl}            = $isurl;
                                 ->{link}            = $link;

=back

=cut

sub MARCgettagslib {
    my ( $dbh, $forlibrarian, $frameworkcode ) = @_;
    $frameworkcode = "" unless $frameworkcode;
    $forlibrarian = 1 unless $forlibrarian;
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
        $res->{$tag}->{tab}        = "";            # XXX
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

=head2 ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,$kohafield);

=over 4

finds MARC tag and subfield for a given kohafield
kohafield is "table.field" where table= biblio|biblioitems|items, and field a field of the previous table

=back

=cut

sub MARCfind_marc_from_kohafield {
    my ( $dbh, $kohafield,$frameworkcode ) = @_;
    return 0, 0 unless $kohafield;
    $frameworkcode='' unless $frameworkcode;
	my $relations = C4::Context->marcfromkohafield;
	return ($relations->{$frameworkcode}->{$kohafield}->[0],$relations->{$frameworkcode}->{$kohafield}->[1]);
}

=head2 $MARCRecord = &MARCgetbiblio($dbh,$biblionumber);

=over 4

Returns a MARC::Record for the biblio $biblionumber.

=cut

sub MARCgetbiblio {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $biblionumber ) = @_;
	my $sth = $dbh->prepare('select marc from biblioitems where biblionumber=?');
	$sth->execute($biblionumber);
	my ($marc) = $sth->fetchrow;
	my $record = MARC::Record::new_from_usmarc($marc);
    return $record;
}

=head2 $XML = &XMLgetbiblio($dbh,$biblionumber);

=over 4

Returns a raw XML for the biblio $biblionumber.

=cut

sub XMLgetbiblio {

    # Returns MARC::Record of the biblio passed in parameter.
    my ( $dbh, $biblionumber ) = @_;
	my $sth = $dbh->prepare('select marcxml,marc from biblioitems where biblionumber=?');
	$sth->execute($biblionumber);
	my ($XML,$marc) = $sth->fetchrow;
# 	my $record =MARC::Record::new_from_usmarc($marc);
# 	warn "MARC : \n*-************************\n".$record->as_xml."\n*-************************\n";
    return $XML;
}

=head2 $MARCrecord = &MARCgetitem($dbh,$biblionumber);

=over 4

Returns a MARC::Record with all items of biblio # $biblionumber

=back

=cut

sub MARCgetitem {

    my ( $dbh, $biblionumber, $itemnumber ) = @_;
	my $frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber);
	# get the complete MARC record
	my $sth = $dbh->prepare("select marc from biblioitems where biblionumber=?");
	$sth->execute($biblionumber);
	my ($rawmarc) = $sth->fetchrow;
	my $record = MARC::File::USMARC::decode($rawmarc);
	# now, find the relevant itemnumber
	my ($itemnumberfield,$itemnumbersubfield) = MARCfind_marc_from_kohafield($dbh,'items.itemnumber',$frameworkcode);
	# prepare the new item record
	my $itemrecord = MARC::Record->new();
	# parse all fields fields from the complete record
	foreach ($record->field($itemnumberfield)) {
		# when the item field is found, save it
		if ($_->subfield($itemnumbersubfield) == $itemnumber) {
			$itemrecord->append_fields($_);
		}
	}

    return $itemrecord;
}

=head2 sub find_biblioitemnumber($dbh,$biblionumber);

=over 4

Returns the 1st biblioitemnumber related to $biblionumber. When MARC=ON we should have 1 biblionumber = 1 and only 1 biblioitemnumber
This sub is useless when MARC=OFF

=back

=cut
sub find_biblioitemnumber {
	my ( $dbh, $biblionumber ) = @_;
	my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
	$sth->execute($biblionumber);
	my ($biblioitemnumber) = $sth->fetchrow;
	return $biblioitemnumber;
}

=head2 $frameworkcode = MARCfind_frameworkcode($dbh,$biblionumber);

=over 4

returns the framework of a given biblio

=back

=cut

sub MARCfind_frameworkcode {
	my ( $dbh, $biblionumber ) = @_;
	my $sth = $dbh->prepare("select frameworkcode from biblio where biblionumber=?");
	$sth->execute($biblionumber);
	my ($frameworkcode) = $sth->fetchrow;
	return $frameworkcode;
}

=head2 $MARCRecord = &MARCkoha2marcBiblio($dbh,$bibliohash);

=over 4

MARCkoha2marcBiblio is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB biblio/biblioitem :
all entries of the hash are transformed into their matching MARC field/subfield.

=back

=cut

sub MARCkoha2marcBiblio {

	# this function builds partial MARC::Record from the old koha-DB fields
	my ( $dbh, $bibliohash ) = @_;
	# we don't have biblio entries in the hash, so we add them first
	my $sth = $dbh->prepare("select * from biblio where biblionumber=?");
	$sth->execute($bibliohash->{biblionumber});
	my $biblio = $sth->fetchrow_hashref;
	foreach (keys %$biblio) {
		$bibliohash->{$_}=$biblio->{$_};
	}
	$sth = $dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?");
	my $record = MARC::Record->new();
	foreach ( keys %$bibliohash ) {
		&MARCkoha2marcOnefield( $sth, $record, "biblio." . $_, $bibliohash->{$_}, '') if $bibliohash->{$_};
		&MARCkoha2marcOnefield( $sth, $record, "biblioitems." . $_, $bibliohash->{$_}, '') if $bibliohash->{$_};
	}

	# other fields => additional authors, subjects, subtitles
	my $sth2 = $dbh->prepare(" SELECT author FROM additionalauthors WHERE biblionumber=?");
	$sth2->execute($bibliohash->{biblionumber});
	while ( my $row = $sth2->fetchrow_hashref ) {
		&MARCkoha2marcOnefield( $sth, $record, "additionalauthors.author", $bibliohash->{'author'},'' );
	}
	$sth2 = $dbh->prepare(" SELECT subject FROM bibliosubject WHERE biblionumber=?");
	$sth2->execute($bibliohash->{biblionumber});
	while ( my $row = $sth2->fetchrow_hashref ) {
		&MARCkoha2marcOnefield( $sth, $record, "bibliosubject.subject", $row->{'subject'},'' );
	}
	$sth2 = $dbh->prepare(" SELECT subtitle FROM bibliosubtitle WHERE biblionumber=?");
	$sth2->execute($bibliohash->{biblionumber});
	while ( my $row = $sth2->fetchrow_hashref ) {
		&MARCkoha2marcOnefield( $sth, $record, "bibliosubtitle.subtitle", $row->{'subtitle'},'' );
	}
	
	return $record;
}

=head2 $MARCRecord = &MARCkoha2marcItem($dbh,$biblionumber,itemnumber);

MARCkoha2marcItem is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB items :
all entries of the hash are transformed into their matching MARC field/subfield.

=over 4

=back

=cut

sub MARCkoha2marcItem {

    # this function builds partial MARC::Record from the old koha-DB fields
    my ( $dbh, $item ) = @_;

    #    my $dbh=&C4Connect;
    my $sth = $dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?");
    my $record = MARC::Record->new();

	foreach( keys %$item ) {
		if ( $item->{$_} ) {
			&MARCkoha2marcOnefield( $sth, $record, "items." . $_,
				$item->{$_},'' );
		}
	}
    return $record;
}

=head2 MARCkoha2marcOnefield

=over 4

This sub is for internal use only, used by koha2marcBiblio & koha2marcItem

=back

=cut

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

=head2 $MARCrecord = MARChtml2marc($dbh,$rtags,$rsubfields,$rvalues,%indicators);

=over 4

transforms the parameters (coming from HTML form) into a MARC::Record
parameters with r are references to arrays.

FIXME : should be improved for 3.0, to avoid having 4 differents arrays

=back

=cut

sub MARChtml2marc {
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
# 	my %subfieldlist=();
	my $prevvalue; # if tag <10
	my $field; # if tag >=10
	for (my $i=0; $i< @$rtags; $i++) {
		next unless @$rvalues[$i];
		# rebuild MARC::Record
# 			warn "0=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ";
		if (@$rtags[$i] ne $prevtag) {
			if ($prevtag < 10) {
				if ($prevvalue) {
					if ($prevtag ne '000') {
						$record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
					} else {
						$record->leader($prevvalue);
					}
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
# 			warn "1=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (length(@$rvalues[$i])>0) {
					$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
# 			warn "2=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
				}
			}
			$prevtag= @$rtags[$i];
		}
	}
	# the last has not been included inside the loop... do it now !
	$record->add_fields($field) if $field;
# 	warn "HTML2MARC=".$record->as_formatted;
	return $record;
}


=head2 $hash = &MARCmarc2koha($dbh,$MARCRecord);

=over 4

builds a hash with old-db datas from a MARC::Record

=back

=cut

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
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'publicationyear'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'publicationyear'} = $1;
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
    foreach my $field ( $record->field($tagfield) ) {
		if ($field->tag()<10) {
			if ($result->{$kohafield}) {
				# Reverse array filled with elements from repeated subfields 
				# from first to last to avoid last to first concatenation of 
				# elements in Koha DB.  -- thd.
				$result->{$kohafield} .= " | ".reverse($field->data());
			} else {
				$result->{$kohafield} = $field->data();
			}
		} else {
			if ( $field->subfields ) {
				my @subfields = $field->subfields();
				foreach my $subfieldcount ( 0 .. $#subfields ) {
					if ($subfields[$subfieldcount][0] eq $subfield) {
						if ( $result->{$kohafield} ) {
							$result->{$kohafield} .= " | " . $subfields[$subfieldcount][1];
						}
						else {
							$result->{$kohafield} = $subfields[$subfieldcount][1];
						}
					}
				}
			}
		}
    }
# 	warn "OneField for $kohatable.$kohafield and $frameworkcode=> $tagfield, $subfield";
    return $result;
}

=head2 ($biblionumber,$biblioitemnumber) = NEWnewbibilio($dbh,$MARCRecord,$frameworkcode);

=over 4

creates a biblio from a MARC::Record.

=back

=cut

sub NEWnewbiblio {
    my ( $dbh, $record, $frameworkcode ) = @_;
    my $biblionumber;
    my $biblioitemnumber;
    my $olddata = MARCmarc2koha( $dbh, $record,$frameworkcode );
	$olddata->{frameworkcode} = $frameworkcode;
    $biblionumber = REALnewbiblio( $dbh, $olddata );
	$olddata->{biblionumber} = $biblionumber;
	# add biblionumber into the MARC record (it's the ID for zebra)
	my ( $tagfield, $tagsubfield ) =
					MARCfind_marc_from_kohafield( $dbh, "biblio.biblionumber",$frameworkcode );
	# create the field
	my $newfield;
	if ($tagfield<10) {
		$newfield = MARC::Field->new(
			$tagfield, $biblionumber,
		);
	} else {
		$newfield = MARC::Field->new(
			$tagfield, '', '', "$tagsubfield" => $biblionumber,
		);
	}
	# drop old field (just in case it already exist and create new one...
	my $old_field = $record->field($tagfield);
	$record->delete_field($old_field);
	$record->add_fields($newfield);

	#create the marc entry, that stores the rax marc record in Koha 3.0
	$olddata->{marc} = $record->as_usmarc();
	$olddata->{marcxml} = $record->as_xml();
	# and create biblioitem, that's all folks !
    $biblioitemnumber = REALnewbiblioitem( $dbh, $olddata );

    # search subtiles, addiauthors and subjects
    ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, "additionalauthors.author",$frameworkcode );
    my @addiauthfields = $record->field($tagfield);
    foreach my $addiauthfield (@addiauthfields) {
        my @addiauthsubfields = $addiauthfield->subfield($tagsubfield);
        foreach my $subfieldcount ( 0 .. $#addiauthsubfields ) {
            REALmodaddauthor( $dbh, $biblionumber,
                $addiauthsubfields[$subfieldcount] );
        }
    }
    ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, "bibliosubtitle.subtitle",$frameworkcode );
    my @subtitlefields = $record->field($tagfield);
    foreach my $subtitlefield (@subtitlefields) {
        my @subtitlesubfields = $subtitlefield->subfield($tagsubfield);
        foreach my $subfieldcount ( 0 .. $#subtitlesubfields ) {
            REALnewsubtitle( $dbh, $biblionumber,
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
    REALmodsubject( $dbh, $biblionumber, 1, @subjects );
    return ( $biblionumber, $biblioitemnumber );
}

=head2 NEWmodbilbioframework($dbh,$biblionumber,$frameworkcode);

=over 4

modify the framework of a biblio

=back

=cut

sub NEWmodbiblioframework {
	my ($dbh,$biblionumber,$frameworkcode) =@_;
	my $sth = $dbh->prepare("Update biblio SET frameworkcode=? WHERE biblionumber=?");
	$sth->execute($frameworkcode,$biblionumber);
	return 1;
}

=head2 NEWmodbiblio($dbh,$MARCrecord,$biblionumber,$frameworkcode);

=over 4

modify a biblio (MARC=ON)

=back

=cut

sub NEWmodbiblio {
	my ($dbh,$record,$biblionumber,$frameworkcode) =@_;
	$frameworkcode="" unless $frameworkcode;
# 	&MARCmodbiblio($dbh,$bibid,$record,$frameworkcode,0);
	my $oldbiblio = MARCmarc2koha($dbh,$record,$frameworkcode);
	
	$oldbiblio->{frameworkcode} = $frameworkcode;
	#create the marc entry, that stores the rax marc record in Koha 3.0
	$oldbiblio->{biblionumber} = $biblionumber unless $oldbiblio->{biblionumber};
	$oldbiblio->{marc} = $record->as_usmarc();
	$oldbiblio->{marcxml} = $record->as_xml();
	warn "dans NEWmodbiblio $biblionumber = ".$oldbiblio->{biblionumber}." = ".$oldbiblio->{marcxml};
	REALmodbiblio($dbh,$oldbiblio);
	REALmodbiblioitem($dbh,$oldbiblio);
	# now, modify addi authors, subject, addititles.
	my ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"additionalauthors.author",$frameworkcode);
	my @addiauthfields = $record->field($tagfield);
	foreach my $addiauthfield (@addiauthfields) {
		my @addiauthsubfields = $addiauthfield->subfield($tagsubfield);
		$dbh->do("delete from additionalauthors where biblionumber=$biblionumber");
		foreach my $subfieldcount (0..$#addiauthsubfields) {
			REALmodaddauthor($dbh,$biblionumber,$addiauthsubfields[$subfieldcount]);
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubtitle.subtitle",$frameworkcode);
	my @subtitlefields = $record->field($tagfield);
	foreach my $subtitlefield (@subtitlefields) {
		my @subtitlesubfields = $subtitlefield->subfield($tagsubfield);
		# delete & create subtitle again because REALmodsubtitle can't handle new subtitles
		# between 2 modifs
		$dbh->do("delete from bibliosubtitle where biblionumber=$biblionumber");
		foreach my $subfieldcount (0..$#subtitlesubfields) {
			foreach my $subtit(split /\||#/,$subtitlesubfields[$subfieldcount]) {
				REALnewsubtitle($dbh,$biblionumber,$subtit);
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
	REALmodsubject($dbh,$biblionumber,1,@subjects);
	return 1;
}

=head2 NEWmodbilbioframework($dbh,$biblionumber,$frameworkcode);

=over 4

delete a biblio

=back

=cut

sub NEWdelbiblio {
    my ( $dbh, $bibid ) = @_;
    my $biblio = &MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    &REALdelbiblio( $dbh, $biblio );
    my $sth =
      $dbh->prepare(
        "select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblio);
    while ( my ($biblioitemnumber) = $sth->fetchrow ) {
        REALdelbiblioitem( $dbh, $biblioitemnumber );
    }
    &MARCdelbiblio( $dbh, $bibid, 0 );
}

=head2 $itemnumber = NEWnewitem($dbh, $record, $biblionumber, $biblioitemnumber);

=over 4

creates an item from a MARC::Record

=back

=cut

sub NEWnewitem {
    my ( $dbh, $record, $biblionumber, $biblioitemnumber ) = @_;

    # add item in old-DB
	my $frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber);
    my $item = &MARCmarc2koha( $dbh, $record,$frameworkcode );
    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} = $biblionumber;
    $item->{'biblioitemnumber'}=$biblioitemnumber;
    $item->{marc} = $record->as_usmarc();
    warn $item->{marc};
    my ( $itemnumber, $error ) = &REALnewitems( $dbh, $item, $item->{barcode} );
	return $itemnumber;
}


=head2 $itemnumber = NEWmoditem($dbh, $record, $biblionumber, $biblioitemnumber,$itemnumber);

=over 4

Modify an item

=back

=cut

sub NEWmoditem {
    my ( $dbh, $record, $biblionumber, $biblioitemnumber, $itemnumber) = @_;
    
	my $frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber);
    my $olditem = MARCmarc2koha( $dbh, $record,$frameworkcode );
	# add MARC record
	$olditem->{marc} = $record->as_usmarc();
	$olditem->{biblionumber} = $biblionumber;
	$olditem->{biblioitemnumber} = $biblioitemnumber;
	# and modify item
    REALmoditem( $dbh, $olditem );
}


=head2 $itemnumber = NEWdelitem($dbh, $biblionumber, $biblioitemnumber, $itemnumber);

=over 4

delete an item

=back

=cut

sub NEWdelitem {
    my ( $dbh, $bibid, $itemnumber ) = @_;
    my $biblio = &MARCfind_oldbiblionumber_from_MARCbibid( $dbh, $bibid );
    &REALdelitem( $dbh, $itemnumber );
    &MARCdelitem( $dbh, $bibid, $itemnumber );
}


=head2 $biblionumber = REALnewbiblio($dbh,$biblio);

=over 4

adds a record in biblio table. Datas are in the hash $biblio.

=back

=cut

sub REALnewbiblio {
    my ( $dbh, $biblio ) = @_;

	$dbh->do('lock tables biblio WRITE');
    my $sth = $dbh->prepare("Select max(biblionumber) from biblio");
    $sth->execute;
    my $data   = $sth->fetchrow_arrayref;
    my $bibnum = $$data[0] + 1;
    my $series = 0;

    if ( $biblio->{'seriestitle'} ) { $series = 1 }
    $sth->finish;
    $sth =
      $dbh->prepare("insert into biblio set	biblionumber=?,	title=?,		author=?,	copyrightdate=?,
	  										serial=?,		seriestitle=?,	notes=?,	abstract=?,
											unititle=?"
    );
    $sth->execute(
        $bibnum,             $biblio->{'title'},
        $biblio->{'author'}, $biblio->{'copyrightdate'},
        $biblio->{'serial'},             $biblio->{'seriestitle'},
        $biblio->{'notes'},  $biblio->{'abstract'},
		$biblio->{'unititle'}
    );

    $sth->finish;
	$dbh->do('unlock tables');
    return ($bibnum);
}

=head2 $biblionumber = REALmodbiblio($dbh,$biblio);

=over 4

modify a record in biblio table. Datas are in the hash $biblio.

=back

=cut

sub REALmodbiblio {
    my ( $dbh, $biblio ) = @_;
    my $sth = $dbh->prepare("Update biblio set	title=?,		author=?,	abstract=?,	copyrightdate=?,
												seriestitle=?,	serial=?,	unititle=?,	notes=?,	frameworkcode=? 
											where biblionumber = ?"
    );
    $sth->execute(
		$biblio->{'title'},       $biblio->{'author'},
		$biblio->{'abstract'},    $biblio->{'copyrightdate'},
		$biblio->{'seriestitle'}, $biblio->{'serial'},
		$biblio->{'unititle'},    $biblio->{'notes'},
		$biblio->{frameworkcode},
		$biblio->{'biblionumber'}
    );
	$sth->finish;
	return ( $biblio->{'biblionumber'} );
}    # sub modbiblio

=head2 REALmodsubtitle($dbh,$bibnum,$subtitle);

=over 4

modify subtitles in bibliosubtitle table.

=back

=cut

sub REALmodsubtitle {
    my ( $dbh, $bibnum, $subtitle ) = @_;
    my $sth =
      $dbh->prepare(
        "update bibliosubtitle set subtitle = ? where biblionumber = ?");
    $sth->execute( $subtitle, $bibnum );
    $sth->finish;
}    # sub modsubtitle

=head2 REALmodaddauthor($dbh,$bibnum,$author);

=over 4

adds or modify additional authors
NOTE :  Strange sub : seems to delete MANY and add only ONE author... maybe buggy ?

=back

=cut

sub REALmodaddauthor {
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

=head2 $errors = REALmodsubject($dbh,$bibnum, $force, @subject);

=over 4

modify/adds subjects

=back

=cut
sub REALmodsubject {
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

=head2 REALmodbiblioitem($dbh, $biblioitem);

=over 4

modify a biblioitem

=back

=cut
sub REALmodbiblioitem {
    my ( $dbh, $biblioitem ) = @_;
    my $query;

    my $sth = $dbh->prepare("update biblioitems set number=?,volume=?,			volumedate=?,		lccn=?,
										itemtype=?,			url=?,				isbn=?,				issn=?,
										publishercode=?,	publicationyear=?,	classification=?,	dewey=?,
										subclass=?,			illus=?,			pages=?,			volumeddesc=?,
										notes=?,			size=?,				place=?,			marc=?,
										marcxml=?
							where biblioitemnumber=?");
	$sth->execute(	$biblioitem->{number},			$biblioitem->{volume},	$biblioitem->{volumedate},	$biblioitem->{lccn},
					$biblioitem->{itemtype},		$biblioitem->{url},		$biblioitem->{isbn},	$biblioitem->{issn},
    				$biblioitem->{publishercode},	$biblioitem->{publicationyear}, $biblioitem->{classification},	$biblioitem->{dewey},
    				$biblioitem->{subclass},		$biblioitem->{illus},		$biblioitem->{pages},	$biblioitem->{volumeddesc},
    				$biblioitem->{bnotes},			$biblioitem->{size},		$biblioitem->{place},	$biblioitem->{marc},
					$biblioitem->{marcxml},			$biblioitem->{biblioitemnumber});
	my $record = MARC::File::USMARC::decode($biblioitem->{marc});
	zebra_create($biblioitem->{biblionumber}, $record);
# 	warn "MOD : $biblioitem->{biblioitemnumber} = ".$biblioitem->{marc};
}    # sub modbibitem

=head2 REALnewbiblioitem($dbh,$biblioitem);

=over 4

adds a biblioitem ($biblioitem is a hash with the values)

=back

=cut

sub REALnewbiblioitem {
	my ( $dbh, $biblioitem ) = @_;

	$dbh->do("lock tables biblioitems WRITE, biblio WRITE, marc_subfield_structure READ");
	my $sth = $dbh->prepare("Select max(biblioitemnumber) from biblioitems");
	my $data;
	my $biblioitemnumber;

	$sth->execute;
	$data       = $sth->fetchrow_arrayref;
	$biblioitemnumber = $$data[0] + 1;
	
	# Insert biblioitemnumber in MARC record, we need it to manage items later...
	my $frameworkcode=MARCfind_frameworkcode($dbh,$biblioitem->{biblionumber});
	my ($biblioitemnumberfield,$biblioitemnumbersubfield) = MARCfind_marc_from_kohafield($dbh,'biblioitems.biblioitemnumber',$frameworkcode);
	my $record = MARC::File::USMARC::decode($biblioitem->{marc});
	my $field=$record->field($biblioitemnumberfield);
	$field->update($biblioitemnumbersubfield => "$biblioitemnumber");
	$biblioitem->{marc} = $record->as_usmarc();
	$biblioitem->{marcxml} = $record->as_xml();

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
									marc		 = ?,				place		 = ?,
									marcxml		 = ?"
	);
	$sth->execute(
		$biblioitemnumber,               $biblioitem->{'biblionumber'},
		$biblioitem->{'volume'},         $biblioitem->{'number'},
		$biblioitem->{'classification'}, $biblioitem->{'itemtype'},
		$biblioitem->{'url'},            $biblioitem->{'isbn'},
		$biblioitem->{'issn'},           $biblioitem->{'dewey'},
		$biblioitem->{'subclass'},       $biblioitem->{'publicationyear'},
		$biblioitem->{'publishercode'},  $biblioitem->{'volumedate'},
		$biblioitem->{'volumeddesc'},    $biblioitem->{'illus'},
		$biblioitem->{'pages'},          $biblioitem->{'bnotes'},
		$biblioitem->{'size'},           $biblioitem->{'lccn'},
		$biblioitem->{'marc'},           $biblioitem->{'place'},
		$biblioitem->{marcxml},
	);
	$dbh->do("unlock tables");
	zebra_create($biblioitem->{biblionumber}, $record);
	return ($biblioitemnumber);
}

=head2 REALnewsubtitle($dbh,$bibnum,$subtitle);

=over 4

create a new subtitle

=back

=cut
sub REALnewsubtitle {
    my ( $dbh, $bibnum, $subtitle ) = @_;
    my $sth =
      $dbh->prepare(
        "insert into bibliosubtitle set biblionumber = ?, subtitle = ?");
    $sth->execute( $bibnum, $subtitle ) if $subtitle;
    $sth->finish;
}

=head2 ($itemnumber,$errors)= REALnewitems($dbh,$item,$barcode);

=over 4

create a item. $item is a hash and $barcode the barcode.

=back

=cut

sub REALnewitems {
    my ( $dbh, $item, $barcode ) = @_;

# 	warn "OLDNEWITEMS";
	
	$dbh->do('lock tables items WRITE, biblio WRITE,biblioitems WRITE,marc_subfield_structure WRITE');
    my $sth = $dbh->prepare("Select max(itemnumber) from items");
    my $data;
    my $itemnumber;
    my $error = "";
    $sth->execute;
    $data       = $sth->fetchrow_hashref;
    $itemnumber = $data->{'max(itemnumber)'} + 1;

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
			$item->{'biblioitemnumber'},$item->{barcode},
			$item->{'booksellerid'},	$item->{'dateaccessioned'},
			$item->{'homebranch'},		$item->{'holdingbranch'},
			$item->{'price'},			$item->{'replacementprice'},
			$item->{multivolume},		$item->{stack},
			$item->{itemlost},			$item->{wthdrawn},
			$item->{paidfor},			$item->{'itemnotes'},
			$item->{'itemcallnumber'},	$item->{'notforloan'},
			$item->{'location'}
        );
		if ( defined $sth->errstr ) {
			$error .= $sth->errstr;
		}
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
			$item->{'biblioitemnumber'},$item->{barcode},
			$item->{'booksellerid'},
			$item->{'homebranch'},		$item->{'holdingbranch'},
			$item->{'price'},			$item->{'replacementprice'},
			$item->{multivolume},		$item->{stack},
			$item->{itemlost},			$item->{wthdrawn},
			$item->{paidfor},			$item->{'itemnotes'},
			$item->{'itemcallnumber'},	$item->{'notforloan'},
			$item->{'location'}
        );
		if ( defined $sth->errstr ) {
			$error .= $sth->errstr;
		}
    }
	# item stored, now, deal with the marc part...
	$sth = $dbh->prepare("select biblioitems.marc,biblio.frameworkcode from biblioitems,biblio 
							where 	biblio.biblionumber=biblioitems.biblionumber and 
									biblio.biblionumber=?");
	$sth->execute($item->{biblionumber});
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
	my ($rawmarc,$frameworkcode) = $sth->fetchrow;
	warn "ERROR IN REALnewitem, MARC record not found FOR $item->{biblionumber} => $rawmarc <=" unless $rawmarc;
	my $record = MARC::File::USMARC::decode($rawmarc);
	# ok, we have the marc record, add item number to the item field (in {marc}, and add the field to the record)
	my ($itemnumberfield,$itemnumbersubfield) = MARCfind_marc_from_kohafield($dbh,'items.itemnumber',$frameworkcode);
	my $itemrecord = MARC::Record->new_from_usmarc($item->{marc});
        warn $itemrecord;
        warn $itemnumberfield;
        warn $itemrecord->field($itemnumberfield);
	my $itemfield = $itemrecord->field($itemnumberfield);
	$itemfield->add_subfields($itemnumbersubfield => "$itemnumber");
	$record->insert_grouped_field($itemfield);
	# save the record into biblioitem
	$sth=$dbh->prepare("update biblioitems set marc=?,marcxml=? where biblionumber=?");
	$sth->execute($record->as_usmarc(),$record->as_xml(),$item->{biblionumber});
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
	zebra_create($item->{biblionumber},$record);
	$dbh->do('unlock tables');
    return ( $itemnumber, $error );
}

=head2 REALmoditem($dbh,$item);

=over 4

modify item

=back

=cut

sub REALmoditem {
    my ( $dbh, $item ) = @_;
	my $error;
	$dbh->do('lock tables items WRITE, biblio WRITE,biblioitems WRITE');
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
		if ($item->{homebranch}) {
			$query.=",homebranch=?";
			push @bind, $item->{homebranch};
		}
		if ($item->{holdingbranch}) {
			$query.=",holdingbranch=?";
			push @bind, $item->{holdingbranch};
		}
    }
	$query.=" where itemnumber=?";
	push @bind,$item->{'itemnum'};
   if ( $item->{'replacement'} ne '' ) {
        $query =~ s/ where/,replacementprice='$item->{'replacement'}' where/;
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
	
	# item stored, now, deal with the marc part...
	$sth = $dbh->prepare("select biblioitems.marc,biblio.frameworkcode from biblioitems,biblio 
							where 	biblio.biblionumber=biblioitems.biblionumber and 
									biblio.biblionumber=? and 
									biblioitems.biblioitemnumber=?");
	$sth->execute($item->{biblionumber},$item->{biblioitemnumber});
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
	my ($rawmarc,$frameworkcode) = $sth->fetchrow;
	warn "ERROR IN REALmoditem, MARC record not found" unless $rawmarc;
	my $record = MARC::File::USMARC::decode($rawmarc);
	# ok, we have the marc record, find the previous item record for this itemnumber and delete it
	my ($itemnumberfield,$itemnumbersubfield) = MARCfind_marc_from_kohafield($dbh,'items.itemnumber',$frameworkcode);
	# prepare the new item record
	my $itemrecord = MARC::File::USMARC::decode($item->{marc});
	my $itemfield = $itemrecord->field($itemnumberfield);
	$itemfield->add_subfields($itemnumbersubfield => '$itemnumber');
	# parse all fields fields from the complete record
	foreach ($record->field($itemnumberfield)) {
		# when the previous field is found, replace by the new one
		if ($_->subfield($itemnumbersubfield) == $item->{itemnum}) {
			$_->replace_with($itemfield);
		}
	}
# 	$record->insert_grouped_field($itemfield);
	# save the record into biblioitem
	$sth=$dbh->prepare("update biblioitems set marc=?,marcxml=? where biblionumber=? and biblioitemnumber=?");
	$sth->execute($record->as_usmarc(),$record->as_xml(),$item->{biblionumber},$item->{biblioitemnumber});
	zebra_create($item->biblionumber,$record);
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
	$dbh->do('unlock tables');

    #  $dbh->disconnect;
}

=head2 REALdelitem($dbh,$itemnum);

=over 4

delete item

=back

=cut

sub REALdelitem {
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

=head2 REALdelbiblioitem($dbh,$biblioitemnumber);

=over 4

deletes a biblioitem
NOTE : not standard sub name. Should be REALdelbiblioitem()

=back

=cut

sub REALdelbiblioitem {
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

=head2 REALdelbiblio($dbh,$biblio);

=over 4

delete a biblio

=back

=cut

sub REALdelbiblio {
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

=head2 $number = itemcount($biblio);

=over 4

returns the number of items attached to a biblio

=back

=cut

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

=head2 $biblionumber = newbiblio($biblio);

=over 4

create a biblio. The parameter is a hash

=back

=cut

sub newbiblio {
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
    my $bibnum = REALnewbiblio( $dbh, $biblio );
    # finds new (MARC bibid
    # 	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$bibnum);
#     my $record = &MARCkoha2marcBiblio( $dbh, $bibnum );
#     MARCaddbiblio( $dbh, $record, $bibnum,'' );
    return ($bibnum);
}

=head2   $biblionumber = &modbiblio($biblio);

=over 4

Update a biblio record.

C<$biblio> is a reference-to-hash whose keys are the fields in the
biblio table in the Koha database. All fields must be present, not
just the ones you wish to change.

C<&modbiblio> updates the record defined by
C<$biblio-E<gt>{biblionumber}> with the values in C<$biblio>.

C<&modbiblio> returns C<$biblio-E<gt>{biblionumber}> whether it was
successful or not.

=back

=cut

sub modbiblio {
	my ($biblio) = @_;
	my $dbh  = C4::Context->dbh;
	my $biblionumber=REALmodbiblio($dbh,$biblio);
	my $record = MARCkoha2marcBiblio($dbh,$biblionumber,$biblionumber);
	# finds new (MARC bibid
	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
	MARCmodbiblio($dbh,$bibid,$record,"",0);
	return($biblionumber);
} # sub modbiblio

=head2   &modsubtitle($biblionumber, $subtitle);

=over 4

Sets the subtitle of a book.

C<$biblionumber> is the biblionumber of the book to modify.

C<$subtitle> is the new subtitle.

=back

=cut

sub modsubtitle {
    my ( $bibnum, $subtitle ) = @_;
    my $dbh = C4::Context->dbh;
    &REALmodsubtitle( $dbh, $bibnum, $subtitle );
}    # sub modsubtitle

=head2 &modaddauthor($biblionumber, $author);

=over 4

Replaces all additional authors for the book with biblio number
C<$biblionumber> with C<$author>. If C<$author> is the empty string,
C<&modaddauthor> deletes all additional authors.

=back

=cut

sub modaddauthor {
    my ( $bibnum, @authors ) = @_;
    my $dbh = C4::Context->dbh;
    &REALmodaddauthor( $dbh, $bibnum, @authors );
}    # sub modaddauthor

=head2 $error = &modsubject($biblionumber, $force, @subjects);

=over 4

$force - a subject to force
$error - Error message, or undef if successful.

=back

=cut

sub modsubject {
    my ( $bibnum, $force, @subject ) = @_;
    my $dbh = C4::Context->dbh;
    my $error = &REALmodsubject( $dbh, $bibnum, $force, @subject );
    if ($error eq ''){
		# When MARC is off, ensures that the MARC biblio table gets updated with new
		# subjects, of course, it deletes the biblio in marc, and then recreates.
		# This check is to ensure that no MARC data exists to lose.
# 		if (C4::Context->preference("MARC") eq '0'){
# 		warn "in modSUBJECT";
# 			my $MARCRecord = &MARCkoha2marcBiblio($dbh,$bibnum);
# 			my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$bibnum);
# 			&MARCmodbiblio($dbh,$bibid, $MARCRecord);
# 		}
	}
	return ($error);
}    # sub modsubject

=head2 modbibitem($biblioitem);

=over 4

modify a biblioitem. The parameter is a hash

=back

=cut

sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh = C4::Context->dbh;
    &REALmodbiblioitem( $dbh, $biblioitem );
}    # sub modbibitem

=head2 $biblioitemnumber = newbiblioitem($biblioitem)

=over 4

create a biblioitem, the parameter is a hash

=back

=cut

sub newbiblioitem {
    my ($biblioitem) = @_;
    my $dbh        = C4::Context->dbh;
	# add biblio information to the hash
    my $MARCbiblio = MARCkoha2marcBiblio( $dbh, $biblioitem );
	$biblioitem->{marc} = $MARCbiblio->as_usmarc();
    my $bibitemnum = &REALnewbiblioitem( $dbh, $biblioitem );
    return ($bibitemnum);
}

=head2 newsubtitle($biblionumber,$subtitle);

=over 4

insert a subtitle for $biblionumber biblio

=back

=cut


sub newsubtitle {
    my ( $bibnum, $subtitle ) = @_;
    my $dbh = C4::Context->dbh;
    &REALnewsubtitle( $dbh, $bibnum, $subtitle );
}

=head2 $errors = newitems($item, @barcodes);

=over 4

insert items ($item is a hash)

=back

=cut


sub newitems {
    my ( $item, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $errors;
    my $itemnumber;
    my $error;
    foreach my $barcode (@barcodes) {
		# add items, one by one for each barcode.
		my $oneitem=$item;
		$oneitem->{barcode}= $barcode;
        my $MARCitem = &MARCkoha2marcItem( $dbh, $oneitem);
		$oneitem->{marc} = $MARCitem->as_usmarc;
        ( $itemnumber, $error ) = &REALnewitems( $dbh, $oneitem);
#         $errors .= $error;
#         &MARCadditem( $dbh, $MARCitem, $item->{biblionumber} );
    }
    return ($errors);
}

=head2 moditem($item);

=over 4

modify an item ($item is a hash with all item informations)

=back

=cut


sub moditem {
    my ($item) = @_;
    my $dbh = C4::Context->dbh;
    &REALmoditem( $dbh, $item );
    my $MARCitem =
      &MARCkoha2marcItem( $dbh, $item->{'biblionumber'}, $item->{'itemnum'} );
    my $bibid =
      &MARCfind_MARCbibid_from_oldbiblionumber( $dbh, $item->{biblionumber} );
    &MARCmoditem( $dbh, $MARCitem, $bibid, $item->{itemnum}, 0 );
}

=head2 $error = checkitems($count,@barcodes);

=over 4

check for each @barcode entry that the barcode is not a duplicate

=back

=cut

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

=head2 $delitem($itemnum);

=over 4

delete item $itemnum being the item number to delete

=back

=cut

sub delitem {
    my ($itemnum) = @_;
    my $dbh = C4::Context->dbh;
    &REALdelitem( $dbh, $itemnum );
}

=head2 deletebiblioitem($biblioitemnumber);

=over 4

delete the biblioitem $biblioitemnumber

=back

=cut

sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh = C4::Context->dbh;
    &REALdelbiblioitem( $dbh, $biblioitemnumber );
}    # sub deletebiblioitem

=head2 delbiblio($biblionumber)

=over 4

delete biblio $biblionumber

=back

=cut

sub delbiblio {
    my ($biblio) = @_;
    my $dbh = C4::Context->dbh;
    &REALdelbiblio( $dbh, $biblio );
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber( $dbh, $biblio );
    &MARCdelbiblio( $dbh, $bibid, 0 );
}

=head2 ($count,@results) = getbiblio($biblionumber);

=over 4

return an array with hash of biblios.

FIXME : biblionumber being the primary key, this sub will always return only 1 result, API should be modified...

=back

=cut

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

=item bibdata

  $data = &bibdata($biblionumber, $type);

Returns information about the book with the given biblionumber.

C<$type> is ignored.

C<&bibdata> returns a reference-to-hash. The keys are the fields in
the C<biblio>, C<biblioitems>, and C<bibliosubtitle> tables in the
Koha database.

In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).

If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=cut
#'
sub bibdata {
	my ($bibnum, $type) = @_;
	my $dbh   = C4::Context->dbh;
	my $sth   = $dbh->prepare("Select *, biblioitems.notes AS bnotes, biblio.notes
								from biblio 
								left join biblioitems on biblioitems.biblionumber = biblio.biblionumber
								left join bibliosubtitle on
								biblio.biblionumber = bibliosubtitle.biblionumber
								left join itemtypes on biblioitems.itemtype=itemtypes.itemtype
								where biblio.biblionumber = ?
								");
	$sth->execute($bibnum);
	my $data;
	$data  = $sth->fetchrow_hashref;
	$sth->finish;
	# handle management of repeated subtitle
	$sth   = $dbh->prepare("Select * from bibliosubtitle where biblionumber = ?");
	$sth->execute($bibnum);
	my @subtitles;
	while (my $dat = $sth->fetchrow_hashref){
		my %line;
		$line{subtitle} = $dat->{subtitle};
		push @subtitles, \%line;
	} # while
	$data->{subtitles} = \@subtitles;
	$sth->finish;
	$sth   = $dbh->prepare("Select * from bibliosubject where biblionumber = ?");
	$sth->execute($bibnum);
	my @subjects;
	while (my $dat = $sth->fetchrow_hashref){
		my %line;
		$line{subject} = $dat->{'subject'};
		push @subjects, \%line;
	} # while
	$data->{subjects} = \@subjects;
	$sth->finish;
	$sth   = $dbh->prepare("Select * from additionalauthors where biblionumber = ?");
	$sth->execute($bibnum);
	while (my $dat = $sth->fetchrow_hashref){
		$data->{'additionalauthors'} .= "$dat->{'author'} - ";
	} # while
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
	$sth->finish;
	return($data);
} # sub bibdata

=head2 ($count,@results) = getbiblioitem($biblioitemnumber);

=over 4

return an array with hash of biblioitemss.

FIXME : biblioitemnumber being unique, this sub will always return only 1 result, API should be modified...

=back

=cut

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

=head2 ($count,@results) = getbiblioitembybiblionumber($biblionumber);

=over 4

return an array with hash of biblioitems for the given biblionumber.

=back

=cut

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

=head2 ($count,@results) = getitemsbybiblioitem($biblionumber);

=over 4

returns an array with hash of items

=back

=cut

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

=item ItemInfo

  @results = &ItemInfo($env, $biblionumber, $type);

Returns information about books with the given biblionumber.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<$env> is ignored.

C<&ItemInfo> returns a list of references-to-hash. Each element
contains a number of keys. Most of them are table items from the
C<biblio>, C<biblioitems>, C<items>, and C<itemtypes> tables in the
Koha database. Other keys include:

=over 4

=item C<$data-E<gt>{branchname}>

The name (not the code) of the branch to which the book belongs.

=item C<$data-E<gt>{datelastseen}>

This is simply C<items.datelastseen>, except that while the date is
stored in YYYY-MM-DD format in the database, here it is converted to
DD/MM/YYYY format. A NULL date is returned as C<//>.

=item C<$data-E<gt>{datedue}>

=item C<$data-E<gt>{class}>

This is the concatenation of C<biblioitems.classification>, the book's
Dewey code, and C<biblioitems.subclass>.

=item C<$data-E<gt>{ocount}>

I think this is the number of copies of the book available.

=item C<$data-E<gt>{order}>

If this is set, it is set to C<One Order>.

=back

=cut
#'
sub ItemInfo {
	my ($env,$biblionumber,$type) = @_;
	my $dbh   = C4::Context->dbh;
	my $query = "SELECT *,items.notforloan as itemnotforloan FROM items, biblio, biblioitems 
					left join itemtypes on biblioitems.itemtype = itemtypes.itemtype
					WHERE items.biblionumber = ?
					AND biblioitems.biblioitemnumber = items.biblioitemnumber
					AND biblio.biblionumber = items.biblionumber";
	$query .= " order by items.dateaccessioned desc";
	my $sth=$dbh->prepare($query);
	$sth->execute($biblionumber);
	my $i=0;
	my @results;
	while (my $data=$sth->fetchrow_hashref){
		my $datedue = '';
		my $isth=$dbh->prepare("Select issues.*,borrowers.cardnumber from issues,borrowers where itemnumber = ? and returndate is null and issues.borrowernumber=borrowers.borrowernumber");
		$isth->execute($data->{'itemnumber'});
		if (my $idata=$isth->fetchrow_hashref){
		$data->{borrowernumber} = $idata->{borrowernumber};
		$data->{cardnumber} = $idata->{cardnumber};
		$datedue = format_date($idata->{'date_due'});
		}
		if ($datedue eq ''){
			my ($restype,$reserves)=C4::Reserves2::CheckReserves($data->{'itemnumber'});
			if ($restype) {
				$datedue=$restype;
			}
		}
		$isth->finish;
	#get branch information.....
		my $bsth=$dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
		$bsth->execute($data->{'holdingbranch'});
		if (my $bdata=$bsth->fetchrow_hashref){
			$data->{'branchname'} = $bdata->{'branchname'};
		}
		my $date=format_date($data->{'datelastseen'});
		$data->{'datelastseen'}=$date;
		$data->{'datedue'}=$datedue;
	# get notforloan complete status if applicable
		my $sthnflstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.notforloan"');
		$sthnflstatus->execute;
		my ($authorised_valuecode) = $sthnflstatus->fetchrow;
		if ($authorised_valuecode) {
			$sthnflstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$sthnflstatus->execute($authorised_valuecode,$data->{itemnotforloan});
			my ($lib) = $sthnflstatus->fetchrow;
			$data->{notforloan} = $lib;
		}
		$results[$i]=$data;
		$i++;
	}
	$sth->finish;
	return(@results);
}

=item bibitems

  ($count, @results) = &bibitems($biblionumber);

Given the biblionumber for a book, C<&bibitems> looks up that book's
biblioitems (different publications of the same book, the audio book
and film versions, etc.).

C<$count> is the number of elements in C<@results>.

C<@results> is an array of references-to-hash; the keys are the fields
of the C<biblioitems> and C<itemtypes> tables of the Koha database. In
addition, C<itemlost> indicates the availability of the item: if it is
"2", then all copies of the item are long overdue; if it is "1", then
all copies are lost; otherwise, there is at least one copy available.

=cut
#'
sub bibitems {
    my ($bibnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("SELECT biblioitems.*,
                        itemtypes.*,
                        MIN(items.itemlost)        as itemlost,
                        MIN(items.dateaccessioned) as dateaccessioned
                          FROM biblioitems, itemtypes, items
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                           AND biblioitems.biblioitemnumber = items.biblioitemnumber
                      GROUP BY items.biblioitemnumber");
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while
    $sth->finish;
    return($count, @results);
} # sub bibitems


=item bibitemdata

  $itemdata = &bibitemdata($biblioitemnumber);

Looks up the biblioitem with the given biblioitemnumber. Returns a
reference-to-hash. The keys are the fields from the C<biblio>,
C<biblioitems>, and C<itemtypes> tables in the Koha database, except
that C<biblioitems.notes> is given as C<$itemdata-E<gt>{bnotes}>.

=cut
#'
sub bibitemdata {
    my ($bibitem) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select *,biblioitems.notes as bnotes from biblio, biblioitems,itemtypes where biblio.biblionumber = biblioitems.biblionumber and biblioitemnumber = ? and biblioitems.itemtype = itemtypes.itemtype");
    my $data;

    $sth->execute($bibitem);

    $data = $sth->fetchrow_hashref;

    $sth->finish;
    return($data);
} # sub bibitemdata


=item getbibliofromitemnumber

  $item = &getbibliofromitemnumber($env, $dbh, $itemnumber);

Looks up the item with the given itemnumber.

C<$env> and C<$dbh> are ignored.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=cut
#'
sub getbibliofromitemnumber {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio,items,biblioitems
    where items.itemnumber = ?
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber");
#  print $query;
  $sth->execute($itemnumber);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item barcodes

  @barcodes = &barcodes($biblioitemnumber);

Given a biblioitemnumber, looks up the corresponding items.

Returns an array of references-to-hash; the keys are C<barcode> and
C<itemlost>.

The returned items include very overdue items, but not lost ones.

=cut
#'
sub barcodes{
    #called from request.pl
    my ($biblioitemnumber)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("SELECT barcode, itemlost, holdingbranch FROM items
                           WHERE biblioitemnumber = ?
                             AND (wthdrawn <> 1 OR wthdrawn IS NULL)");
    $sth->execute($biblioitemnumber);
    my @barcodes;
    my $i=0;
    while (my $data=$sth->fetchrow_hashref){
	$barcodes[$i]=$data;
	$i++;
    }
    $sth->finish;
    return(@barcodes);
}


=item itemdata

  $item = &itemdata($barcode);

Looks up the item with the given barcode, and returns a
reference-to-hash containing information about that item. The keys of
the hash are the fields from the C<items> and C<biblioitems> tables in
the Koha database.

=cut
#'
sub get_item_from_barcode {
  my ($barcode)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from items,biblioitems where barcode=?
  and items.biblioitemnumber=biblioitems.biblioitemnumber");
  $sth->execute($barcode);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}


=item itemissues

  @issues = &itemissues($biblioitemnumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblioitemnumber.

C<$biblio> is ignored.

C<&itemissues> returns an array of references-to-hash. The keys
include the fields from the C<items> table in the Koha database.
Additional keys include:

=over 4

=item C<date_due>

If the item is currently on loan, this gives the due date.

If the item is not on loan, then this is either "Available" or
"Cancelled", if the item has been withdrawn.

=item C<card>

If the item is currently on loan, this gives the card number of the
patron who currently has the item.

=item C<timestamp0>, C<timestamp1>, C<timestamp2>

These give the timestamp for the last three times the item was
borrowed.

=item C<card0>, C<card1>, C<card2>

The card number of the last three patrons who borrowed this item.

=item C<borrower0>, C<borrower1>, C<borrower2>

The borrower number of the last three patrons who borrowed this item.

=back

=cut
#'
sub itemissues {
    my ($bibitem, $biblio)=@_;
    my $dbh   = C4::Context->dbh;
    # FIXME - If this function die()s, the script will abort, and the
    # user won't get anything; depending on how far the script has
    # gotten, the user might get a blank page. It would be much better
    # to at least print an error message. The easiest way to do this
    # is to set $SIG{__DIE__}.
    my $sth   = $dbh->prepare("Select * from items where
items.biblioitemnumber = ?")
      || die $dbh->errstr;
    my $i     = 0;
    my @results;

    $sth->execute($bibitem)
      || die $sth->errstr;

    while (my $data = $sth->fetchrow_hashref) {
        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2   = $dbh->prepare("select * from issues,borrowers
where itemnumber = ?
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber");

        $sth2->execute($data->{'itemnumber'});
        if (my $data2 = $sth2->fetchrow_hashref) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
	    $data->{'borrower'}     = $data2->{'borrowernumber'};
        } else {
            if ($data->{'wthdrawn'} eq '1') {
                $data->{'date_due'} = 'Cancelled';
            } else {
                $data->{'date_due'} = 'Available';
            } # else
        } # else

        $sth2->finish;

        # Find the last 3 people who borrowed this item.
        $sth2 = $dbh->prepare("select * from issues, borrowers
						where itemnumber = ?
									and issues.borrowernumber = borrowers.borrowernumber
									and returndate is not NULL
									order by returndate desc,timestamp desc") || die $dbh->errstr;
        $sth2->execute($data->{'itemnumber'}) || die $sth2->errstr;
        for (my $i2 = 0; $i2 < 2; $i2++) { # FIXME : error if there is less than 3 pple borrowing this item
            if (my $data2 = $sth2->fetchrow_hashref) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
            } # if
        } # for

        $sth2->finish;
        $results[$i] = $data;
        $i++;
    }

    $sth->finish;
    return(@results);
}

=item getsubject

  ($count, $subjects) = &getsubject($biblionumber);

Looks up the subjects of the book with the given biblionumber. Returns
a two-element list. C<$subjects> is a reference-to-array, where each
element is a subject of the book, and C<$count> is the number of
elements in C<$subjects>.

=cut
#'
sub getsubject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from bibliosubject where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item getaddauthor

  ($count, $authors) = &getaddauthor($biblionumber);

Looks up the additional authors for the book with the given
biblionumber.

Returns a two-element list. C<$authors> is a reference-to-array, where
each element is an additional author, and C<$count> is the number of
elements in C<$authors>.

=cut
#'
sub getaddauthor {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from additionalauthors where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}


=item getsubtitle

  ($count, $subtitles) = &getsubtitle($biblionumber);

Looks up the subtitles for the book with the given biblionumber.

Returns a two-element list. C<$subtitles> is a reference-to-array,
where each element is a subtitle, and C<$count> is the number of
elements in C<$subtitles>.

=cut
#'
sub getsubtitle {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from bibliosubtitle where biblionumber=?");
  $sth->execute($bibnum);
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}


=item getwebsites

  ($count, @websites) = &getwebsites($biblionumber);

Looks up the web sites pertaining to the book with the given
biblionumber.

C<$count> is the number of elements in C<@websites>.

C<@websites> is an array of references-to-hash; the keys are the
fields from the C<websites> table in the Koha database.

=cut
#FIXME : could maybe be deleted. Otherwise, would be better in a Websites.pm package
#(with add / modify / delete subs)

sub getwebsites {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select * from websites where biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        # FIXME - The URL scheme shouldn't be stripped off, at least
        # not here, since it's part of the URL, and will be useful in
        # constructing a link to the site. If you don't want the user
        # to see the "http://" part, strip that off when building the
        # HTML code.
        $data->{'url'} =~ s/^http:\/\///;	# FIXME - Leaning toothpick
						# syndrome
        $results[$count] = $data;
    	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebsites

=item getwebbiblioitems

  ($count, @results) = &getwebbiblioitems($biblionumber);

Given a book's biblionumber, looks up the web versions of the book
(biblioitems with itemtype C<WEB>).

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<biblioitems> table of the Koha database.

=cut
#'
sub getwebbiblioitems {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth   = $dbh->prepare("Select * from biblioitems where biblionumber = ?
and itemtype = 'WEB'");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
        $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebbiblioitems

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


END { }    # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

=cut

# $Id$
# $Log$
# Revision 1.142  2006/02/16 20:49:56  kados
# destroy a connection after we're done -- we really should just have one
# connection object and not destroy it until the whole transaction is
# finished -- but this will do for now
#
# Revision 1.141  2006/02/16 19:47:22  rangi
# Trying to error trap a little more.
#
# Revision 1.140  2006/02/14 21:36:03  kados
# adding a 'use ZOOM' to biblio.pm, needed for non-mod_perl install.
# also adding diagnostic error if not able to connect to Zebra
#
# Revision 1.139  2006/02/14 19:53:25  rangi
# Just a little missing my
#
# Seems to be working great Paul, and I like what you did with zebradb
#
# Revision 1.138  2006/02/14 11:25:22  tipaul
# road to 3.0 : updating a biblio in zebra seems to work. Still working on it, there are probably some bugs !
#
# Revision 1.137  2006/02/13 16:34:26  tipaul
# fixing some warnings (perl -w should be quiet)
#
# Revision 1.136  2006/01/10 17:01:29  tipaul
# adding a XMLgetbiblio in Biblio.pm (1st draft, to use with zebra)
#
# Revision 1.135  2006/01/06 16:39:37  tipaul
# synch'ing head and rel_2_2 (from 2.2.5, including npl templates)
# Seems not to break too many things, but i'm probably wrong here.
# at least, new features/bugfixes from 2.2.5 are here (tested on some features on my head local copy)
#
# - removing useless directories (koha-html and koha-plucene)
#
# Revision 1.134  2006/01/04 15:54:55  tipaul
# utf8 is a : go for beta test in HEAD.
# some explanations :
# - updater/updatedatabase => will transform all tables in innoDB (not related to utf8, just to warn you) AND collate them in utf8 / utf8_general_ci. The SQL command is : ALTER TABLE tablename DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci.
# - *-top.inc will show the pages in utf8
# - THE HARD THING : for me, mysql-client and mysql-server were set up to communicate in iso8859-1, whatever the mysql collation ! Thus, pages were improperly shown, as datas were transmitted in iso8859-1 format ! After a full day of investigation, someone on usenet pointed "set NAMES 'utf8'" to explain that I wanted utf8. I could put this in my.cnf, but if I do that, ALL databases will "speak" in utf8, that's not what we want. Thus, I added a line in Context.pm : everytime a DB handle is opened, the communication is set to utf8.
# - using marcxml field and no more the iso2709 raw marc biblioitems.marc field.
#
# Revision 1.133  2005/12/12 14:25:51  thd
#
#
# Reverse array filled with elements from repeated subfields
# to avoid last to first concatenation of elements in Koha DB.-
#
# Revision 1.132  2005-10-26 09:12:33  tipaul
# big commit, still breaking things...
#
# * synch with rel_2_2. Probably the last non manual synch, as rel_2_2 should not be modified deeply.
# * code cleaning (cleaning warnings from perl -w) continued
#
# Revision 1.131  2005/09/22 10:01:45  tipaul
# see mail on koha-devel : code cleaning on Search.pm + normalizing API + use of biblionumber everywhere (instead of bn, biblio, ...)
#
# Revision 1.130  2005/09/02 14:34:14  tipaul
# continuing the work to move to zebra. Begin of work for MARC=OFF support.
# IMPORTANT NOTE : the MARCkoha2marc sub API has been modified. Instead of biblionumber & biblioitemnumber, it now gets a hash.
# The sub is used only in Biblio.pm, so the API change should be harmless (except for me, but i'm aware ;-) )
#
# Revision 1.129  2005/08/12 13:50:31  tipaul
# removing useless sub declarations
#
# Revision 1.128  2005/08/11 16:12:47  tipaul
# Playing with the zebra...
#
# * go to koha cvs home directory
# * in misc/zebra there is a unimarc directory. I suggest that marc21 libraries create a marc21 directory
# * put your zebra.cfg files here & create your database.
# * from koha cvs home directory, ln -s misc/zebra/marc21 zebra (I mean create a symbolic link to YOUR zebra directory)
# * now, everytime you add/modify a biblio/item your zebra DB is updated correctly.
#
# NOTE :
# * this uses a system call in perl. CPU consumming, but we are waiting for indexdata Perl/zoom
# * deletion still not work
# * UNIMARC zebra config files are provided in misc/zebra/unimarc directory. The most important line being :
# in zebra.cfg :
# recordId: (bib1,Local-number)
# storeKeys:1
#
# in .abs file :
# elm 090            Local-number            -
# elm 090/?          Local-number            -
# elm 090/?/9        Local-number            !:w
#
# (090$9 being the field mapped to biblio.biblionumber in Koha)
#
# Revision 1.127  2005/08/11 14:37:32  tipaul
# * POD documenting
# * removing useless subs
# * removing some subs that are also elsewhere
# * renaming all OLDxxx subs to REALxxx subs (should not change anything, as OLDxxx, as well as REAL, are supposed to be for Biblio.pm internal use only)
#
# Revision 1.126  2005/08/11 09:13:28  tipaul
# just removing useless subs (a lot !!!) for code cleaning
#
# Revision 1.125  2005/08/11 09:00:07  tipaul
# Ok guys, this time, it seems that item add and modif begin working as expected...
# Still a lot of bugs to fix, of course
#
# Revision 1.124  2005/08/10 10:21:15  tipaul
# continuing the road to zebra :
# - the biblio add begins to work.
# - the biblio modif begins to work.
#
# (still without doing anything on zebra)
# (no new change in updatedatabase)
#
# Revision 1.123  2005/08/09 14:10:28  tipaul
# 1st commit to go to zebra.
# don't update your cvs if you want to have a working head...
#
# this commit contains :
# * updater/updatedatabase : get rid with marc_* tables, but DON'T remove them. As a lot of things uses them, it would not be a good idea for instance to drop them. If you really want to play, you can rename them to test head without them but being still able to reintroduce them...
# * Biblio.pm : modify MARCgetbiblio to find the raw marc record in biblioitems.marc field, not from marc_subfield_table, modify MARCfindframeworkcode to find frameworkcode in biblio.frameworkcode, modify some other subs to use biblio.biblionumber & get rid of bibid.
# * other files : get rid of bibid and use biblionumber instead.
#
# What is broken :
# * does not do anything on zebra yet.
# * if you rename marc_subfield_table, you can't search anymore.
# * you can view a biblio & bibliodetails, go to MARC editor, but NOT save any modif.
# * don't try to add a biblio, it would add data poorly... (don't try to delete either, it may work, but that would be a surprise ;-) )
#
# IMPORTANT NOTE : you need MARC::XML package (http://search.cpan.org/~esummers/MARC-XML-0.7/lib/MARC/File/XML.pm), that requires a recent version of MARC::Record
# Updatedatabase stores the iso2709 data in biblioitems.marc field & an xml version in biblioitems.marcxml Not sure we will keep it when releasing the stable version, but I think it's a good idea to have something readable in sql, at least for development stage.

# tipaul cutted previous commit notes
