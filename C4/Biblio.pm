package C4::Biblio;
# $Id$
# $Log$
# Revision 1.15  2002/10/05 09:49:25  arensb
# Merged with arensb-context branch: use C4::Context->dbh instead of
# &C4Connect, and generally prefer C4::Context over C4::Database.
#
# Revision 1.14  2002/10/03 11:28:18  tipaul
# Extending Context.pm to add stopword management and using it in MARC-API.
# First benchmarks show a medium speed improvement, which  is nice as this part is heavily called.
#
# Revision 1.13  2002/10/02 16:26:44  tipaul
# road to 1.3.1
#
# Revision 1.12.2.4  2002/10/05 07:09:31  arensb
# Merged in changes from main branch.
#
# Revision 1.12.2.3  2002/10/05 06:12:10  arensb
# Added a whole mess of FIXME comments.
#
# Revision 1.12.2.2  2002/10/05 04:03:14  arensb
# Added some missing semicolons.
#
# Revision 1.12.2.1  2002/10/04 02:24:01  arensb
# Use C4::Connect instead of C4::Database, C4::Connect->dbh instead
# C4Connect.
#
# Revision 1.12.2.3  2002/10/05 06:12:10  arensb
# Added a whole mess of FIXME comments.
#
# Revision 1.12.2.2  2002/10/05 04:03:14  arensb
# Added some missing semicolons.
#
# Revision 1.12.2.1  2002/10/04 02:24:01  arensb
# Use C4::Connect instead of C4::Database, C4::Connect->dbh instead
# C4Connect.
#
# Revision 1.12  2002/10/01 11:48:51  arensb
# Added some FIXME comments, mostly marking duplicate functions.
#
# Revision 1.11  2002/09/24 13:49:26  tipaul
# long WAS the road to 1.3.0...
# coming VERY SOON NOW...
# modifying installer and buildrelease to update the DB
#
# Revision 1.10  2002/09/22 16:50:08  arensb
# Added some FIXME comments.
#
# Revision 1.9  2002/09/20 12:57:46  tipaul
# long is the road to 1.4.0
# * MARCadditem and MARCmoditem now wroks
# * various bugfixes in MARC management
# !!! 1.3.0 should be released very soon now. Be careful !!!
#
# Revision 1.8  2002/09/10 13:53:52  tipaul
# MARC API continued...
# * some bugfixes
# * multiple item management : MARCadditem and MARCmoditem have been added. They suppose that ALL the MARC field linked to koha-item are in the same MARC tag (on the same line of MARC file)
#
# Note : it should not be hard for marcimport and marcexport to re-link fields from internal tag/subfield to "legal" tag/subfield.
#
# Revision 1.7  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.6  2002/07/25 13:40:31  tipaul
# pod documenting the API.
#
# Revision 1.5  2002/07/24 16:11:37  tipaul
# Now, the API...
# Database.pm and Output.pm are almost not modified (var test...)
#
# Biblio.pm is almost completly rewritten.
#
# WHAT DOES IT ??? ==> END of Hitchcock suspens
#
# 1st, it does... nothing...
# Every old API should be there. So if MARC-stuff is not done, the behaviour is EXACTLY the same (if there is no added bug, of course). So, if you use normal acquisition, you won't find anything new neither on screen or old-DB tables ...
#
# All old-API functions have been cloned. for example, the "newbiblio" sub, now has become :
# * a "newbiblio" sub, with the same parameters. It just call a sub named OLDnewbiblio
# * a "OLDnewbiblio" sub, which is a copy/paste of the previous newbiblio sub. Then, when you want to add the MARC-DB stuff, you can modify the newbiblio sub without modifying the OLDnewbiblio one. If we correct a bug in 1.2 in newbiblio, we can do the same in main branch by correcting OLDnewbiblio.
# * The MARC stuff is usually done through a sub named MARCxxx where xxx is the same as OLDxxx. For example, newbiblio calls MARCnewbiblio. the MARCxxx subs use a MARC::Record as parameter.
# The last thing to solve was to manage biblios through real MARC import : they must populate the old-db, but must populate the MARC-DB too, without loosing information (if we go from MARC::Record to old-data then back to MARC::Record, we loose A LOT OF ROWS). To do this, there are subs beginning by "ALLxxx" : they manage datas with MARC::Record datas. they call OLDxxx sub too (to populate old-DB), but MARCxxx subs too, with a complete MARC::Record ;-)
#
# In Biblio.pm, there are some subs that permits to build a old-style record from a MARC::Record, and the opposite. There is also a sub finding a MARC-bibid from a old-biblionumber and the opposite too.
# Note we have decided with steve that a old-biblio <=> a MARC-Biblio.
#


# move from 1.2 to 1.4 version : 
# 1.2 and previous version uses a specific API to manage biblios. This API uses old-DB style parameters.
# In the 1.4 version, we want to do 2 differents things :
#  - keep populating the old-DB, that has a LOT less datas than MARC
#  - populate the MARC-DB
# To populate the DBs we have 2 differents sources :
#  - the standard acquisition system (through book sellers), that does'nt use MARC data
#  - the MARC acquisition system, that uses MARC data.
#
# thus, we have 2 differents cases :
#   - with the standard acquisition system, we have non MARC data and want to populate old-DB and MARC-DB, knowing it's an incomplete MARC-record
#   - with the MARC acquisition system, we have MARC datas, and want to loose nothing in MARC-DB. So, we can't store datas in old-DB, then copy in MARC-DB.
#       we MUST have an API for true MARC data, that populate MARC-DB then old-DB
#
# That's why we need 4 subs :
# all subs beginning by MARC manage only MARC tables. They manage MARC-DB with MARC::Record parameters
# all subs beginning by OLD manage only OLD-DB tables. They manage old-DB with old-DB parameters
# all subs beginning by ALL manage both OLD-DB and MARC tables. They use MARC::Record as parameters. it's the API that MUST be used in MARC acquisition system
# all subs beginning by seomething else are the old-style API. They use old-DB as parameter, then call internally the OLD and MARC subs.
#
# only ALL and old-style API should be used in koha. MARC and OLD is used internally only
#
# Thus, we assume a nice translation to future versions : if we want in a 1.6 release completly forget old-DB, we can do it easily.
# in 1.4 version, the translations will be nicer, as we have NOTHING to do in code. Everything has to be done in Biblio.pm ;-)



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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
#
# don't forget MARCxxx subs are here only for testing purposes. Should not be used
# as the old-style API and the ALL one are the only public functions.
#
@EXPORT = qw(
	     &updateBiblio &updateBiblioItem &updateItem 
	     &itemcount &newbiblio &newbiblioitem 
	     &modnote &newsubject &newsubtitle
	     &modbiblio &checkitems
	     &newitems &modbibitem
	     &modsubtitle &modsubject &modaddauthor &moditem &countitems 
	     &delitem &deletebiblioitem &delbiblio  
	     &getitemtypes &getbiblio
	     &getbiblioitembybiblionumber
	     &getbiblioitem &getitemsbybiblioitem &isbnsearch
	     &skip
	     &newcompletebiblioitem

	     &MARCfind_oldbiblionumber_from_MARCbibid
	     &MARCfind_MARCbibid_from_oldbiblionumber

	     &ALLnewbiblio &ALLnewitem

	     &MARCgettagslib
	     &MARCaddbiblio &MARCadditem
	     &MARCmodsubfield &MARCaddsubfield 
	     &MARCmodbiblio &MARCmoditem
	     &MARCfindsubfield 
	     &MARCkoha2marcBiblio &MARCmarc2koha &MARCkoha2marcItem
	     &MARCgetbiblio &MARCgetitem
	     &MARCaddword &MARCdelword
 );

%EXPORT_TAGS = ( );

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);	# FIXME - These are never used

#
#
# MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC
#
#
# all the following subs takes a MARC::Record as parameter and manage
# the MARC-DB. They are called by the 1.0/1.2 xxx subs, and by the
# ALLxxx subs (xxx deals with old-DB parameters, the ALLxxx deals with MARC-DB parameter)

=head1 SYNOPSIS

  MARCxxx related subs
  all subs requires/use $dbh as 1st parameter.
  NOTE : all those subs are private and must be used only inside Biblio.pm (called by a old API sub, or the ALLsub)

=head1 DESCRIPTION

=head2 @tagslib = &MARCgettagslib($dbh,1|0);
      last param is 1 for liblibrarian and 0 for libopac
      returns a hash with tag/subfield meaning

=head2 ($tagfield,$tagsubfield) = &MARCfindmarc_from_kohafield($dbh,$kohafield);
      finds MARC tag and subfield for a given kohafield
      kohafield is "table.field" where table= biblio|biblioitems|items, and field a field of the previous table

=head2 $biblionumber = &MARCfind_oldbiblionumber_from_MARCbibid($dbh,$MARCbibi);
      finds a old-db biblio number for a given MARCbibid number

=head2 $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber);
      finds a MARC bibid from a old-db biblionumber

=head2 &MARCaddbiblio($dbh,$MARC::Record,$biblionumber);
      creates a biblio (in the MARC tables only). $biblionumber is the old-db biblionumber of the biblio

=head2 &MARCaddsubfield($dbh,$bibid,$tagid,$indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
      adds a subfield in a biblio (in the MARC tables only).
     
=head2 $MARCRecord = &MARCgetbiblio($dbh,$bibid);
      Returns a MARC::Record for the biblio $bibid.

=head2 &MARCmodbiblio($dbh,$bibid,$delete,$record);
      MARCmodbiblio changes a biblio for a biblio,MARC::Record passed as parameter
      if $delete == 1, every field/subfield not found is deleted in the biblio
      otherwise, only data passed to MARCmodbiblio is managed.
      thus, you can change only a small part of a biblio (like an item, or a subtitle, or a additionalauthor...)

=head2 ($subfieldid,$subfieldvalue) = &MARCmodsubfield($dbh,$subfieldid,$subfieldvalue);
      MARCmodsubfield changes the value of a given subfield

=head2 $subfieldid = &MARCfindsubfield($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue);
      MARCfindsubfield returns a subfield number given a bibid/tag/subfieldvalue values.
      Returns -1 if more than 1 answer

=head2 $subfieldid = &MARCfindsubfieldid($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);
      MARCfindsubfieldid find a subfieldid for a bibid/tag/tagorder/subfield/subfieldorder

=head2 &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);
      MARCdelsubfield delete a subfield for a bibid/tag/tagorder/subfield/subfieldorder

=head2 &MARCdelbiblio($dbh,$bibid);
      MARCdelbiblio delete biblio $bibid

=head2 $MARCRecord = &MARCkoha2marcBiblio($dbh,$biblionumber,biblioitemnumber);
      MARCkoha2marcBiblio is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB biblio/biblioitem

=head2 $MARCRecord = &MARCkoha2marcItem($dbh,$biblionumber,itemnumber);
      MARCkoha2marcItem is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB item

=head2 $MARCRecord = &MARCkoha2marcSubtitle($dbh,$biblionumber,$subtitle);
      MARCkoha2marcSubtitle is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB subtitle

=head2 &MARCkoha2marcOnefield => used by MARCkoha2marc and should not be useful elsewhere

=head2 $olddb = &MARCmarc2koha($dbh,$MARCRecord);
      builds a hash with old-db datas from a MARC::Record

=head2 &MARCmarc2kohaOnefield => used by MARCmarc2koha and should not be useful elsewhere

=head2 MARCaddword => used to manage MARC_word table and should not be useful elsewhere

=head2 MARCdelword => used to manage MARC_word table and should not be useful elsewhere

=head1 AUTHOR

Paul POULAIN paul.poulain@free.fr

=cut

sub MARCgettagslib {
    my ($dbh,$forlibrarian)= @_;
    my $sth;
    if ($forlibrarian eq 1) {
	$sth=$dbh->prepare("select tagfield,liblibrarian as lib from marc_tag_structure");
    } else {
	$sth=$dbh->prepare("select tagfield,libopac as lib from marc_tag_structure");
    }
    $sth->execute;
    my ($lib,$tag,$res);
    while ( ($tag,$lib) = $sth->fetchrow) {
	$res->{$tag}->{lib}=$lib;
    }

    if ($forlibrarian eq 1) {
	$sth=$dbh->prepare("select tagfield,tagsubfield,liblibrarian as lib from marc_subfield_structure");
    } else {
	$sth=$dbh->prepare("select tagfield,tagsubfield,libopac as lib from marc_subfield_structure");
    }
    $sth->execute;

    my $subfield;
    while ( ($tag,$subfield,$lib) = $sth->fetchrow) {
	$res->{$tag}->{$subfield}=$lib;
    }
    return $res;
}

sub MARCfind_marc_from_kohafield {
    my ($dbh,$kohafield) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    $sth->execute($kohafield);
    my ($tagfield,$tagsubfield) = $sth->fetchrow;
    return ($tagfield,$tagsubfield);
}

sub MARCfind_oldbiblionumber_from_MARCbibid {
    my ($dbh,$MARCbibid) = @_;
    my $sth=$dbh->prepare("select biblionumber from marc_biblio where bibid=?");
    $sth->execute($MARCbibid);
    my ($biblionumber) = $sth->fetchrow;
    return $biblionumber;
}

sub MARCfind_MARCbibid_from_oldbiblionumber {
    my ($dbh,$oldbiblionumber) = @_;
    my $sth=$dbh->prepare("select bibid from marc_biblio where biblionumber=?");
    $sth->execute($oldbiblionumber);
    my ($bibid) = $sth->fetchrow;
    return $bibid;
}

sub MARCaddbiblio {
# pass the MARC::Record to this function, and it will create the records in the marc tables
    my ($dbh,$record,$biblionumber) = @_;
    my @fields=$record->fields();
    my $bibid;
    # adding main table, and retrieving bibid
    $dbh->do("lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ");
    my $sth=$dbh->prepare("insert into marc_biblio (datecreated,biblionumber) values (now(),?)");
    $sth->execute($biblionumber);
    $sth=$dbh->prepare("select max(bibid) from marc_biblio");
    $sth->execute;
    ($bibid)=$sth->fetchrow;
    $sth->finish;
    my $fieldcount=0;
    # now, add subfields...
    foreach my $field (@fields) {
	my @subfields=$field->subfields();
	$fieldcount++;
	foreach my $subfieldcount (0..$#subfields) {
		    &MARCaddsubfield($dbh,$bibid,
				 $field->tag(),
				 $field->indicator(1).$field->indicator(2),
				 $fieldcount,
				 $subfields[$subfieldcount][0],
				 $subfieldcount+1,
				 $subfields[$subfieldcount][1]
				 );
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
	my @subfields=$field->subfields();
	$fieldcount++;
	foreach my $subfieldcount (0..$#subfields) {
		    &MARCaddsubfield($dbh,$bibid,
				 $field->tag(),
				 $field->indicator(1).$field->indicator(2),
				 $fieldcount,
				 $subfields[$subfieldcount][0],
				 $subfieldcount+1,
				 $subfields[$subfieldcount][1]
				 );
	}
    }
    $dbh->do("unlock tables");
    return $bibid;
}

sub MARCaddsubfield {
# Add a new subfield to a tag into the DB.
    my ($dbh,$bibid,$tagid,$indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue) = @_;
    # if not value, end of job, we do nothing
    if (not($subfieldvalue)) {
	return;
    }
    if (not($subfieldcode)) {
	$subfieldcode=' ';
    }
    if (length($subfieldvalue)>255) {
#	$dbh->do("lock tables marc_blob_subfield WRITE, marc_subfield_table WRITE");
	my $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
	$sth->execute($subfieldvalue);
	$sth=$dbh->prepare("select max(blobidlink)from marc_blob_subfield");
	$sth->execute;
	my ($res)=$sth->fetchrow;
	$sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,subfieldcode,subfieldorder,valuebloblink) values (?,?,?,?,?,?)");
	if ($tagid<100) {
	    $sth->execute($bibid,'0'.$tagid,$tagorder,$subfieldcode,$subfieldorder,$res);
	} else {
	    $sth->execute($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$res);
	}
	if ($sth->errstr) {
	    print STDERR "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
	}
#	$dbh->do("unlock tables");
    } else {
	my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?)");
	$sth->execute($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	if ($sth->errstr) {
	    print STDERR "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
	}
    }
    &MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
}


sub MARCgetbiblio {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink 
		 		 from marc_subfield_table 
		 		 where bibid=? order by tagorder,subfieldorder
		 	 ");
    my $sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute($bibid);
    while (my $row=$sth->fetchrow_hashref) {
	if ($row->{'valuebloblink'}) { #---- search blob if there is one
	    $sth2->execute($row->{'valuebloblink'});
	    my $row2=$sth2->fetchrow_hashref;
	    $sth2->finish;
	    $row->{'subfieldvalue'}=$row2->{'subfieldvalue'};
	}
	if ($record->field($row->{'tag'})) {
	    my $field;
#--- this test must stay as this, because of strange behaviour of mySQL/Perl DBI with char var containing a number...
#--- sometimes, eliminates 0 at beginning, sometimes no ;-\\\
	    if (length($row->{'tag'}) <3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    $field =$record->field($row->{'tag'});
	    if ($field) {
		my $x = $field->add_subfields($row->{'subfieldcode'},$row->{'subfieldvalue'});
		$record->delete_field($field);
		$record->add_fields($field);
	    }
	} else {
	    if (length($row->{'tag'}) < 3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    my $temp = MARC::Field->new($row->{'tag'}," "," ", $row->{'subfieldcode'} => $row->{'subfieldvalue'});
	    $record->add_fields($temp);
	}

    }
    return $record;
}
sub MARCgetitem {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid,$itemnumber)=@_;
    warn "MARCgetitem :   $bibid, $itemnumber\n";
    my $record = MARC::Record->new();
# search MARC tagorder
    my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
    $sth2->execute($bibid,$itemnumber);
    my ($tagorder) = $sth2->fetchrow_array();
#---- TODO : the leader is missing
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink 
		 		 from marc_subfield_table 
		 		 where bibid=? and tagorder=? order by subfieldorder
		 	 ");
    # FIXME - There's already a $sth2 in this scope.
    my $sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
    $sth->execute($bibid,$tagorder);
    while (my $row=$sth->fetchrow_hashref) {
	if ($row->{'valuebloblink'}) { #---- search blob if there is one
	    $sth2->execute($row->{'valuebloblink'});
	    my $row2=$sth2->fetchrow_hashref;
	    $sth2->finish;
	    $row->{'subfieldvalue'}=$row2->{'subfieldvalue'};
	}
	if ($record->field($row->{'tag'})) {
	    my $field;
#--- this test must stay as this, because of strange behaviour of mySQL/Perl DBI with char var containing a number...
#--- sometimes, eliminates 0 at beginning, sometimes no ;-\\\
	    if (length($row->{'tag'}) <3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    $field =$record->field($row->{'tag'});
	    if ($field) {
		my $x = $field->add_subfields($row->{'subfieldcode'},$row->{'subfieldvalue'});
		$record->delete_field($field);
		$record->add_fields($field);
	    }
	} else {
	    if (length($row->{'tag'}) < 3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    my $temp = MARC::Field->new($row->{'tag'}," "," ", $row->{'subfieldcode'} => $row->{'subfieldvalue'});
	    $record->add_fields($temp);
	}

    }
    return $record;
}

sub MARCmodbiblio {
    my ($dbh,$record,$bibid,$itemnumber,$delete)=@_;
    my $oldrecord=&MARCgetbiblio($dbh,$bibid);
# if nothing to change, don't waste time...
    if ($oldrecord eq $record) {
	return;
    }
# otherwise, skip through each subfield...
    my @fields = $record->fields();
    my $tagorder=0;
    foreach my $field (@fields) {
	my $oldfield = $oldrecord->field($field->tag());
	my @subfields=$field->subfields();
	my $subfieldorder=0;
	$tagorder++;
	foreach my $subfield (@subfields) {
	    $subfieldorder++;
	    if ($oldfield eq 0 or (! $oldfield->subfield(@$subfield[0])) ) {
# just adding datas...
		&MARCaddsubfield($dbh,$bibid,$field->tag(),$field->indicator(1).$field->indicator(2),
				 1,@$subfield[0],$subfieldorder,@$subfield[1]);
	    } else {
# modify he subfield if it's a different string
		if ($oldfield->subfield(@$subfield[0]) ne @$subfield[1] ) {
		    my $subfieldid=&MARCfindsubfieldid($dbh,$bibid,$field->tag(),$tagorder,@$subfield[0],$subfieldorder);
		    &MARCmodsubfield($dbh,$subfieldid,@$subfield[1]);
		} else {
		}
	    }
	}
    }
}
sub MARCmoditem {
    my ($dbh,$record,$bibid,$itemnumber,$delete)=@_;
    my $oldrecord=&MARCgetitem($dbh,$bibid,$itemnumber);
# if nothing to change, don't waste time...
    if ($oldrecord eq $record) {
	return;
    }
# otherwise, skip through each subfield...
    my @fields = $record->fields();
# search old MARC item 
    my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
    $sth2->execute($bibid,$itemnumber);
    my ($tagorder) = $sth2->fetchrow_array();
    foreach my $field (@fields) {
	my $oldfield = $oldrecord->field($field->tag());
	my @subfields=$field->subfields();
	my $subfieldorder=0;
	foreach my $subfield (@subfields) {
	    $subfieldorder++;
	    if ($oldfield eq 0 or (! $oldfield->subfield(@$subfield[0])) ) {
# just adding datas...
warn "ADD = $bibid,".$field->tag().",".$field->indicator(1).".".$field->indicator(2).", $tagorder,".@$subfield[0].",$subfieldorder,@$subfield[1])\n";
		&MARCaddsubfield($dbh,$bibid,$field->tag(),$field->indicator(1).$field->indicator(2),
				 $tagorder,@$subfield[0],$subfieldorder,@$subfield[1]);
	    } else {
# modify he subfield if it's a different string
warn "MODIFY = $bibid,".$field->tag().",".$field->indicator(1).".".$field->indicator(2).", $tagorder,".@$subfield[0].",$subfieldorder,@$subfield[1])\n";
		if ($oldfield->subfield(@$subfield[0]) ne @$subfield[1] ) {
		    my $subfieldid=&MARCfindsubfieldid($dbh,$bibid,$field->tag(),$tagorder,@$subfield[0],$subfieldorder);
warn "MODIFY2 = $bibid, $subfieldid, ".@$subfield[1]."\n";
		    &MARCmodsubfield($dbh,$subfieldid,@$subfield[1]);
		} else {
		}
	    }
	}
    }
}


sub MARCmodsubfield {
# Subroutine changes a subfield value given a subfieldid.
    my ($dbh, $subfieldid, $subfieldvalue )=@_;
    $dbh->do("lock tables marc_blob_subfield WRITE,marc_subfield_table WRITE");
    my $sth1=$dbh->prepare("select valuebloblink from marc_subfield_table where subfieldid=?");
    $sth1->execute($subfieldid);
    my ($oldvaluebloblink)=$sth1->fetchrow;
    $sth1->finish;
    my $sth;
    # if too long, use a bloblink
    if (length($subfieldvalue)>255 ) {
	# if already a bloblink, update it, otherwise, insert a new one.
	if ($oldvaluebloblink) {
	    $sth=$dbh->prepare("update marc_blob_subfield set subfieldvalue=? where blobidlink=?");
	    $sth->execute($subfieldvalue,$oldvaluebloblink);
	} else {
	    $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
	    $sth->execute($subfieldvalue);
	    $sth=$dbh->prepare("select max(blobidlink) from marc_blob_subfield");
	    $sth->execute;
	    my ($res)=$sth->fetchrow;
	    $sth=$dbh->prepare("update marc_subfield_table set subfieldvalue=null, valuebloblink=$res where subfieldid=?");
	    $sth->execute($subfieldid);
	}
    } else {
	# note this can leave orphan bloblink. Not a big problem, but we should build somewhere a orphan deleting script...
	$sth=$dbh->prepare("update marc_subfield_table set subfieldvalue=?,valuebloblink=null where subfieldid=?");
	$sth->execute($subfieldvalue, $subfieldid);
    }
    $dbh->do("unlock tables");
    $sth->finish;
    $sth=$dbh->prepare("select bibid,tag,tagorder,subfieldcode,subfieldid,subfieldorder from marc_subfield_table where subfieldid=?");
    $sth->execute($subfieldid);
    my ($bibid,$tagid,$tagorder,$subfieldcode,$x,$subfieldorder) = $sth->fetchrow;
    $subfieldid=$x;
    &MARCdelword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder);
    &MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
    return($subfieldid, $subfieldvalue);
}

sub MARCfindsubfield {
    my ($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue) = @_;
    my $resultcounter=0;
    my $subfieldid;
    my $lastsubfieldid;
    my $query="select subfieldid from marc_subfield_table where bibid=? and tag=? and subfieldcode=?";
    if ($subfieldvalue) {
	$query .= " and subfieldvalue=".$dbh->quote($subfieldvalue);
    } else {
	if ($subfieldorder<1) {
	    $subfieldorder=1;
	}
	$query .= " and subfieldorder=$subfieldorder";
    }
    my $sti=$dbh->prepare($query);
    $sti->execute($bibid,$tag, $subfieldcode);
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

sub MARCfindsubfieldid {
    my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    my $sth=$dbh->prepare("select subfieldid from marc_subfield_table
			where bibid=? and tag=? and tagorder=? 
				and subfieldcode=? and subfieldorder=?");
    $sth->execute($bibid,$tag,$tagorder,$subfield,$subfieldorder);
    my ($res) = $sth->fetchrow;
    return $res;
}

sub MARCdelsubfield {
# delete a subfield for $bibid / tag / tagorder / subfield / subfieldorder
    my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    $dbh->do("delete from marc_subfield_table where bibid='$bibid' and
			tag='$tag' and tagorder='$tagorder' 
			and subfieldcode='$subfield' and subfieldorder='$subfieldorder
			");
}

sub MARCdelbiblio {
# delete a biblio for a $bibid
    my ($dbh,$bibid) = @_;
    $dbh->do("delete from marc_subfield_table where bibid='$bibid'");
    $dbh->do("delete from marc_biblio where bibid='$bibid'");
}

sub MARCkoha2marcBiblio {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$biblionumber,$biblioitemnumber) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
#--- if bibid, then retrieve old-style koha data
    if ($biblionumber>0) {
	my $sth2=$dbh->prepare("select biblionumber,author,title,unititle,notes,abstract,serial,seriestitle,copyrightdate,timestamp 
		from biblio where biblionumber=?");		
	$sth2->execute($biblionumber);
	my $row=$sth2->fetchrow_hashref;
	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"biblio.".$code,$row->{$code});
	    }
	}
    }
#--- if biblioitem, then retrieve old-style koha data
    if ($biblioitemnumber>0) {
	my $sth2=$dbh->prepare(" SELECT biblioitemnumber,biblionumber,volume,number,classification,
						itemtype,url,isbn,issn,dewey,subclass,publicationyear,publishercode,
						volumedate,volumeddesc,timestamp,illus,pages,notes,size,place 
					FROM biblioitems
					WHERE biblionumber=? and biblioitemnumber=?
					");		
	$sth2->execute($biblionumber,$biblioitemnumber);
	my $row=$sth2->fetchrow_hashref;
	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"biblioitems.".$code,$row->{$code});
	    }
	}
    }
    return $record;
# TODO : retrieve notes, additionalauthors
}

sub MARCkoha2marcItem {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$biblionumber,$itemnumber) = @_;
#    my $dbh=&C4Connect;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
#--- if item, then retrieve old-style koha data
    if ($itemnumber>0) {
#	print STDERR "prepare $biblionumber,$itemnumber\n";
	my $sth2=$dbh->prepare("SELECT itemnumber,biblionumber,multivolumepart,biblioitemnumber,barcode,dateaccessioned,
						booksellerid,homebranch,price,replacementprice,replacementpricedate,datelastborrowed,
						datelastseen,multivolume,stack,notforloan,itemlost,wthdrawn,bulk,issues,renewals,
					reserves,restricted,binding,itemnotes,holdingbranch,timestamp 
					FROM items
					WHERE itemnumber=?");
	$sth2->execute($itemnumber);
	my $row=$sth2->fetchrow_hashref;
	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"items.".$code,$row->{$code});
	    }
	}
    }
    return $record;
# TODO : retrieve notes, additionalauthors
}

sub MARCkoha2marcSubtitle {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$bibnum,$subtitle) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
    &MARCkoha2marcOnefield($sth,$record,"bibliosubtitle.subtitle",$subtitle);
    return $record;
}

sub MARCkoha2marcOnefield {
    my ($sth,$record,$kohafieldname,$value)=@_;
    my $tagfield;
    my $tagsubfield;
    $sth->execute($kohafieldname);
    if (($tagfield,$tagsubfield)=$sth->fetchrow) {
	if ($record->field($tagfield)) {
	    my $tag =$record->field($tagfield);
	    if ($tag) {
		$tag->add_subfields($tagsubfield,$value);
		$record->delete_field($tag);
		$record->add_fields($tag);
	    }
	} else {
	    $record->add_fields($tagfield," "," ",$tagsubfield => $value);
	}
    }
    return $record;
}

sub MARCmarc2koha {
    my ($dbh,$record) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $result;
    my $sth2=$dbh->prepare("SHOW COLUMNS from biblio");
    $sth2->execute;
    my $field;
#    print STDERR $record->as_formatted;
    while (($field)=$sth2->fetchrow) {
	$result=&MARCmarc2kohaOneField($sth,"biblio",$field,$record,$result);
    }
    # FIXME - There's already a $sth2 in this scope.
    my $sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
    $sth2->execute;
    # FIXME - There's already a $field in this scope.
    my $field;
    while (($field)=$sth2->fetchrow) {
	$result=&MARCmarc2kohaOneField($sth,"biblioitems",$field,$record,$result);
    }
    # FIXME - There's already a $sth2 in this scope.
    my $sth2=$dbh->prepare("SHOW COLUMNS from items");
    $sth2->execute;
    # FIXME - There's already a $field in this scope.
    my $field;
    while (($field)=$sth2->fetchrow) {
	$result = &MARCmarc2kohaOneField($sth,"items",$field,$record,$result);
    }
# additional authors : specific 
    $result = &MARCmarc2kohaOneField($sth,"additionalauthors","additionalauthors",$record,$result);
    return $result;
}

sub MARCmarc2kohaOneField {
# to check : if a field has a repeatable subfield that is used in old-db, only the 1st will be retrieved...
    my ($sth,$kohatable,$kohafield,$record,$result)= @_;
    my $res="";
    my $tagfield;
    my $subfield;
    $sth->execute($kohatable.".".$kohafield);
    ($tagfield,$subfield) = $sth->fetchrow;
    foreach my $field ($record->field($tagfield)) {
	if ($field->subfield($subfield)) {
	    if ($result->{$kohafield}) {
		$result->{$kohafield} .= " | ".$field->subfield($subfield);
	    } else {
		$result->{$kohafield}=$field->subfield($subfield);
	    }
	}
    }
    return $result;
}

sub MARCaddword {
# split a subfield string and adds it into the word table.
# removes stopwords
    my ($dbh,$bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$sentence) =@_;
    $sentence =~ s/(\.|\?|\:|\!|\'|,|\-)/ /g;
    my @words = split / /,$sentence;
# build stopword list
#    my $sth2 =$dbh->prepare("select word from stopwords");
#    $sth2->execute;
#    my $stopwords;
#    my $stopword;
#    while(($stopword) = $sth2->fetchrow_array)  {
#	$stopwords->{$stopword} = $stopword;
#    }
    my $stopwords= C4::Context->stopwords;
    my $sth=$dbh->prepare("insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word)
			values (?,?,?,?,?,?,soundex(?))");
    foreach my $word (@words) {
# we record only words longer than 2 car and not in stopwords hash
	if (length($word)>1 and !($stopwords->{uc($word)})) {
	    $sth->execute($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		print STDERR "ERROR ==> insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word) values ($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,soundex($word))\n";
	    }
	}
    }
}

sub MARCdelword {
# delete words. this sub deletes all the words from a sentence. a subfield modif is done by a delete then a add
    my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    my $sth=$dbh->prepare("delete from marc_word where bibid=? and tag=? and tagorder=? and subfieldid=? and subfieldorder=?");
    $sth->execute($bibid,$tag,$tagorder,$subfield,$subfieldorder);
}

#
#
# ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL ALL 
#
#
# all the following subs are useful to manage MARC-DB with complete MARC records.
# it's used with marcimport, and marc management tools
#

=head1 SYNOPSIS
  ALLxxx related subs
  all subs requires/use $dbh as 1st parameter.
  those subs are used by the MARC-compliant version of koha : marc import, or marc management.

=head1 DESCRIPTION

=head2 (oldbibnum,$oldbibitemnum) = ALLnewbibilio($dbh,$MARCRecord,$oldbiblio,$oldbiblioitem);
  creates a new biblio from a MARC::Record. The 3rd and 4th parameter are hashes and may be ignored. If only 2 params are passed to the sub, the old-db hashes
  are builded from the MARC::Record. If they are passed, they are used.

=head2 ALLnewitem($dbh,$olditem);
  adds an item in the db. $olditem is a old-db hash.

=head1 AUTHOR

Paul POULAIN paul.poulain@free.fr

=cut

sub ALLnewbiblio {
    my ($dbh, $record, $oldbiblio, $oldbiblioitem) = @_;
# note $oldbiblio and $oldbiblioitem are not mandatory.
# if not present, they will be builded from $record with MARCmarc2koha function
    if (($oldbiblio) and not($oldbiblioitem)) {
	print STDERR "ALLnewbiblio : missing parameter\n";
	print "ALLnewbiblio : missing parameter : contact koha development  team\n";
	die;
    }
    my $oldbibnum;
    my $oldbibitemnum;
    if ($oldbiblio) {
	$oldbibnum = OLDnewbiblio($dbh,$oldbiblio);
	$oldbiblioitem->{'biblionumber'} = $oldbibnum;
	$oldbibitemnum = OLDnewbiblioitem($dbh,$oldbiblioitem);
    } else {
	my $olddata = MARCmarc2koha($dbh,$record);
	$oldbibnum = OLDnewbiblio($dbh,$olddata);
	$oldbibitemnum = OLDnewbiblioitem($dbh,$olddata);
    }
# we must add bibnum and bibitemnum in MARC::Record...
# we build the new field with biblionumber and biblioitemnumber
# we drop the original field
# we add the new builded field.
# NOTE : Works only if the field is ONLY for biblionumber and biblioitemnumber
# (steve and paul : thinks 090 is a good choice)
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    $sth->execute("biblio.biblionumber");
    (my $tagfield1, my $tagsubfield1) = $sth->fetchrow;
    $sth->execute("biblioitems.biblioitemnumber");
    (my $tagfield2, my $tagsubfield2) = $sth->fetchrow;
    print STDERR "tag1 : $tagfield1 / $tagsubfield1\n tag2 : $tagfield2 / $tagsubfield2\n";
    if ($tagsubfield1 != $tagsubfield2) {
	print STDERR "Error in ALLnewbiblio : biblio.biblionumber and biblioitems.biblioitemnumber MUST have the same field number";
 	print "Error in ALLnewbiblio : biblio.biblionumber and biblioitems.biblioitemnumber MUST have the same field number";
	die;
    }
    my $newfield = MARC::Field->new( $tagfield1,'','', 
				     "$tagsubfield1" => $oldbibnum,
				     "$tagsubfield2" => $oldbibitemnum);
# drop old field and create new one...
    my $old_field = $record->field($tagfield1);
    $record->delete_field($old_field);
    $record->add_fields($newfield);
    my $bibid = MARCaddbiblio($dbh,$record,$oldbibnum);
    return ( $oldbibnum,$oldbibitemnum );
}

sub ALLnewitem {
    my ($dbh, $item) = @_;
    my $itemnumber;
    my $error;
    ($itemnumber,$error) = &OLDnewitems($dbh,$item,$item->{'barcode'});
# search MARC biblionumber 
    my $bibid=&MARCfind_MARCbibid_from_oldbiblionumber($dbh,$item->{'biblionumber'});
# calculate tagorder
    my $sth = $dbh->prepare("select max(tagorder) from marc_subfield_table where bibid=?");
    $sth->execute($bibid);
    my ($tagorder) = $sth->fetchrow;
    $tagorder++;
    my $subfieldorder=0;
# for each field, find MARC tag and subfield, and call the proper MARC sub
    foreach my $itemkey (keys %$item) {
	my $tagfield;
	my $tagsubfield;
	print STDERR "=============> $itemkey : ".$item->{$itemkey}."\n";
	if ($itemkey eq "biblionumber" || $itemkey eq "biblioitemnumber") {
	    ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"biblio.".$itemkey);
	} else {
	    ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"items.".$itemkey);
	}
	if ($tagfield && $item->{$itemkey} ne 'NULL') {
	    $subfieldorder++;
	    &MARCaddsubfield($dbh,
			     $bibid,
			     $tagfield,
			     "  ",
			     $tagorder,
			     $tagsubfield,
			     $subfieldorder,
			     $item->{$itemkey}
			     );
	}
    }
} # ALLnewitems


#
#
# OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
#
#

=head1 SYNOPSIS
  OLDxxx related subs
  all subs requires/use $dbh as 1st parameter.
  those subs are used by the MARC-compliant version of koha : marc import, or marc management.

  They all are the exact copy of 1.0/1.2 version of the sub
  without the OLD. The OLDxxx is called by the original xxx sub.
  the 1.4 xxx sub also builds MARC::Record an calls the MARCxxx
 
  WARNING : there is 1 difference between initialxxx and OLDxxx :
  the db header $dbh is always passed as parameter
  to avoid over-DB connexion

=head1 DESCRIPTION

=head2 $biblionumber = OLDnewbiblio($dbh,$biblio);
  adds a record in biblio table. Datas are in the hash $biblio.

=head2 $biblionumber = OLDmodbiblio($dbh,$biblio);
  modify a record in biblio table. Datas are in the hash $biblio.

=head2 OLDmodsubtitle($dbh,$bibnum,$subtitle);
  modify subtitles in bibliosubtitle table.

=head2 OLDmodaddauthor($dbh,$bibnum,$author);
  adds or modify additional authors
  NOTE :  Strange sub : seems to delete MANY and add only ONE author... maybe buggy ?

=head2 $errors = OLDmodsubject($dbh,$bibnum, $force, @subject);
  modify/adds subjects

=head2 OLDmodbibitem($dbh, $biblioitem);
  modify a biblioitem

=head2 OLDmodnote($dbh,$bibitemnum,$note
  modify a note for a biblioitem

=head2 OLDnewbiblioitem($dbh,$biblioitem);
  adds a biblioitem ($biblioitem is a hash with the values)

=head2 OLDnewsubject($dbh,$bibnum);
  adds a subject
=head2 OLDnewsubtitle($dbh,$bibnum,$subtitle);
  create a new subtitle

=head2 ($itemnumber,$errors)= OLDnewitems($dbh,$item,$barcode);
  create a item. $item is a hash and $barcode the barcode.

=head2 OLDmoditem($dbh,$item);
  modify item

=head2 OLDdelitem($dbh,$itemnum);
  delete item

=head2 OLDdeletebiblioitem($dbh,$biblioitemnumber);
  deletes a biblioitem
  NOTE : not standard sub name. Should be OLDdelbiblioitem()
 
=head2 OLDdelbiblio($dbh,$biblio);
  delete a biblio

=head1 AUTHOR

Paul POULAIN paul.poulain@free.fr

=cut

sub OLDnewbiblio {
  my ($dbh,$biblio) = @_;
#  my $dbh    = &C4Connect;
  my $query  = "Select max(biblionumber) from biblio";
  my $sth    = $dbh->prepare($query);
  $sth->execute;
  my $data   = $sth->fetchrow_arrayref;
  my $bibnum = $$data[0] + 1;
  my $series = 0;

  $biblio->{'title'}       = $dbh->quote($biblio->{'title'});
  $biblio->{'author'}      = $dbh->quote($biblio->{'author'});
  $biblio->{'copyright'}   = $dbh->quote($biblio->{'copyright'});
  $biblio->{'seriestitle'} = $dbh->quote($biblio->{'seriestitle'});
  $biblio->{'notes'}	   = $dbh->quote($biblio->{'notes'});
  $biblio->{'abstract'}    = $dbh->quote($biblio->{'abstract'});
  if ($biblio->{'seriestitle'}) { $series = 1 };

  $sth->finish;
  $query = "insert into biblio set
biblionumber  = $bibnum,
title         = $biblio->{'title'},
author        = $biblio->{'author'},
copyrightdate = $biblio->{'copyright'},
serial        = $series,
seriestitle   = $biblio->{'seriestitle'},
notes         = $biblio->{'notes'},
abstract      = $biblio->{'abstract'}";

  $sth = $dbh->prepare($query);
  $sth->execute;

  $sth->finish;
#  $dbh->disconnect;
  return($bibnum);
}

sub OLDmodbiblio {
    my ($dbh,$biblio) = @_;
#  my $dbh   = C4Connect;
    my $query;
    my $sth;
    
    $biblio->{'title'}         = $dbh->quote($biblio->{'title'});
    $biblio->{'author'}        = $dbh->quote($biblio->{'author'});
    $biblio->{'abstract'}      = $dbh->quote($biblio->{'abstract'});
    $biblio->{'copyrightdate'} = $dbh->quote($biblio->{'copyrightdate'});
    $biblio->{'seriestitle'}   = $dbh->quote($biblio->{'serirestitle'});
    $biblio->{'serial'}        = $dbh->quote($biblio->{'serial'});
    $biblio->{'unititle'}      = $dbh->quote($biblio->{'unititle'});
    $biblio->{'notes'}         = $dbh->quote($biblio->{'notes'});
    
    $query = "Update biblio set
title         = $biblio->{'title'},
author        = $biblio->{'author'},
abstract      = $biblio->{'abstract'},
copyrightdate = $biblio->{'copyrightdate'},
seriestitle   = $biblio->{'seriestitle'},
serial        = $biblio->{'serial'},
unititle      = $biblio->{'unititle'},
notes         = $biblio->{'notes'}
where biblionumber = $biblio->{'biblionumber'}";
    $sth   = $dbh->prepare($query);
    
    $sth->execute;
    
    $sth->finish;
    return($biblio->{'biblionumber'});
} # sub modbiblio

sub OLDmodsubtitle {
  my ($dbh,$bibnum, $subtitle) = @_;
#  my $dbh   = C4Connect;
  my $query = "update bibliosubtitle set
subtitle = '$subtitle'
where biblionumber = $bibnum";
  my $sth   = $dbh->prepare($query);

  $sth->execute;
  $sth->finish;
#  $dbh->disconnect;
} # sub modsubtitle


sub OLDmodaddauthor {
    my ($dbh,$bibnum, $author) = @_;
#    my $dbh   = C4Connect;
    my $query = "Delete from additionalauthors where biblionumber = $bibnum";
    my $sth = $dbh->prepare($query);

    $sth->execute;
    $sth->finish;

    if ($author ne '') {
        $query = "Insert into additionalauthors set
                        author       = '$author',
                        biblionumber = '$bibnum'";
        $sth   = $dbh->prepare($query);

        $sth->execute;

        $sth->finish;
    } # if
} # sub modaddauthor


sub OLDmodsubject {
    my ($dbh,$bibnum, $force, @subject) = @_;
#  my $dbh   = C4Connect;
    my $count = @subject;
    my $error;
    for (my $i = 0; $i < $count; $i++) {
	$subject[$i] =~ s/^ //g;
	$subject[$i] =~ s/ $//g;
	my $query = "select * from catalogueentry
			where entrytype = 's'
				and catalogueentry = '$subject[$i]'";
	my $sth   = $dbh->prepare($query);
	$sth->execute;
	
	if (my $data = $sth->fetchrow_hashref) {
	} else {
	    if ($force eq $subject[$i]) {
		# subject not in aut, chosen to force anway
		# so insert into cataloguentry so its in auth file
		$query = "Insert into catalogueentry
				(entrytype,catalogueentry)
			    values ('s','$subject[$i]')";
	 my $sth2 = $dbh->prepare($query);

	 $sth2->execute;
	 $sth2->finish;
      } else {
        $error = "$subject[$i]\n does not exist in the subject authority file";
        $query = "Select * from catalogueentry
			    where entrytype = 's'
			    and (catalogueentry like '$subject[$i] %'
				 or catalogueentry like '% $subject[$i] %'
				 or catalogueentry like '% $subject[$i]')";
        my $sth2 = $dbh->prepare($query);

        $sth2->execute;
        while (my $data = $sth2->fetchrow_hashref) {
          $error = $error."<br>$data->{'catalogueentry'}";
        } # while
        $sth2->finish;
      } # else
    } # else
    $sth->finish;
  } # else
  if ($error eq '') {
    my $query = "Delete from bibliosubject where biblionumber = $bibnum";
    my $sth   = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    for (my $i = 0; $i < $count; $i++) {
      $sth = $dbh->prepare("Insert into bibliosubject
			    values ('$subject[$i]', $bibnum)");

      $sth->execute;
      $sth->finish;
    } # for
  } # if

#  $dbh->disconnect;
  return($error);
} # sub modsubject

sub OLDmodbibitem {
    my ($dbh,$biblioitem) = @_;
#    my $dbh   = C4Connect;
    my $query;

    $biblioitem->{'itemtype'}        = $dbh->quote($biblioitem->{'itemtype'});
    $biblioitem->{'url'}             = $dbh->quote($biblioitem->{'url'});
    $biblioitem->{'isbn'}            = $dbh->quote($biblioitem->{'isbn'});
    $biblioitem->{'publishercode'}   = $dbh->quote($biblioitem->{'publishercode'});
    $biblioitem->{'publicationyear'} = $dbh->quote($biblioitem->{'publicationyear'});
    $biblioitem->{'classification'}  = $dbh->quote($biblioitem->{'classification'});
    $biblioitem->{'dewey'}	     = $dbh->quote($biblioitem->{'dewey'});
    $biblioitem->{'subclass'}	     = $dbh->quote($biblioitem->{'subclass'});
    $biblioitem->{'illus'}           = $dbh->quote($biblioitem->{'illus'});
    $biblioitem->{'pages'}           = $dbh->quote($biblioitem->{'pages'});
    $biblioitem->{'volumeddesc'}     = $dbh->quote($biblioitem->{'volumeddesc'});
    $biblioitem->{'notes'}           = $dbh->quote($biblioitem->{'notes'});
    $biblioitem->{'size'}            = $dbh->quote($biblioitem->{'size'});
    $biblioitem->{'place'}           = $dbh->quote($biblioitem->{'place'});

    $query = "Update biblioitems set
itemtype        = $biblioitem->{'itemtype'},
url             = $biblioitem->{'url'},
isbn            = $biblioitem->{'isbn'},
publishercode   = $biblioitem->{'publishercode'},
publicationyear = $biblioitem->{'publicationyear'},
classification  = $biblioitem->{'classification'},
dewey           = $biblioitem->{'dewey'},
subclass        = $biblioitem->{'subclass'},
illus           = $biblioitem->{'illus'},
pages           = $biblioitem->{'pages'},
volumeddesc     = $biblioitem->{'volumeddesc'},
notes 		= $biblioitem->{'notes'},
size		= $biblioitem->{'size'},
place		= $biblioitem->{'place'}
where biblioitemnumber = $biblioitem->{'biblioitemnumber'}";

    $dbh->do($query);

#    $dbh->disconnect;
} # sub modbibitem

sub OLDmodnote {
  my ($dbh,$bibitemnum,$note)=@_;
#  my $dbh=C4Connect;
  my $query="update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
#  $dbh->disconnect;
}

sub OLDnewbiblioitem {
    my ($dbh,$biblioitem) = @_;
#  my $dbh   = C4Connect;
    my $query = "Select max(biblioitemnumber) from biblioitems";
    my $sth   = $dbh->prepare($query);
    my $data;
    my $bibitemnum;
    
    $biblioitem->{'volume'}          = $dbh->quote($biblioitem->{'volume'});
    $biblioitem->{'number'} 	   = $dbh->quote($biblioitem->{'number'});
    $biblioitem->{'classification'}  = $dbh->quote($biblioitem->{'classification'});
    $biblioitem->{'itemtype'}        = $dbh->quote($biblioitem->{'itemtype'});
    $biblioitem->{'url'}             = $dbh->quote($biblioitem->{'url'});
    $biblioitem->{'isbn'}            = $dbh->quote($biblioitem->{'isbn'});
    $biblioitem->{'issn'}            = $dbh->quote($biblioitem->{'issn'});
    $biblioitem->{'dewey'}           = $dbh->quote($biblioitem->{'dewey'});
    $biblioitem->{'subclass'}        = $dbh->quote($biblioitem->{'subclass'});
    $biblioitem->{'publicationyear'} = $dbh->quote($biblioitem->{'publicationyear'});
    $biblioitem->{'publishercode'}   = $dbh->quote($biblioitem->{'publishercode'});
    $biblioitem->{'volumedate'}      = $dbh->quote($biblioitem->{'volumedate'});
    $biblioitem->{'volumeddesc'}     = $dbh->quote($biblioitem->{'volumeddesc'});  $biblioitem->{'illus'}            = $dbh->quote($biblioitem->{'illus'});
    $biblioitem->{'illus'}	   = $dbh->quote($biblioitem->{'illus'});
    $biblioitem->{'pages'}           = $dbh->quote($biblioitem->{'pages'});
    $biblioitem->{'notes'}           = $dbh->quote($biblioitem->{'notes'});
    $biblioitem->{'size'}            = $dbh->quote($biblioitem->{'size'});
    $biblioitem->{'place'}           = $dbh->quote($biblioitem->{'place'});
    $biblioitem->{'lccn'}            = $dbh->quote($biblioitem->{'lccn'});
    $biblioitem->{'marc'}            = $dbh->quote($biblioitem->{'marc'});
  
    $sth->execute;
    $data       = $sth->fetchrow_arrayref;
    $bibitemnum = $$data[0] + 1;

    $sth->finish;

    $query = "insert into biblioitems set
                        biblioitemnumber = $bibitemnum,
                        biblionumber 	 = $biblioitem->{'biblionumber'},
                        volume		 = $biblioitem->{'volume'},
                        number		 = $biblioitem->{'number'},
                        classification   = $biblioitem->{'classification'},
                        itemtype         = $biblioitem->{'itemtype'},
                        url              = $biblioitem->{'url'},
                        isbn		 = $biblioitem->{'isbn'},
                        issn		 = $biblioitem->{'issn'},
                        dewey		 = $biblioitem->{'dewey'},
                        subclass	 = $biblioitem->{'subclass'},
                        publicationyear	 = $biblioitem->{'publicationyear'},
                        publishercode	 = $biblioitem->{'publishercode'},
                        volumedate	 = $biblioitem->{'volumedate'},
                        volumeddesc	 = $biblioitem->{'volumeddesc'},
                        illus		 = $biblioitem->{'illus'},
                        pages		 = $biblioitem->{'pages'},
                        notes		 = $biblioitem->{'notes'},
                        size		 = $biblioitem->{'size'},
                        lccn		 = $biblioitem->{'lccn'},
                        marc		 = $biblioitem->{'marc'},
                        place		 = $biblioitem->{'place'}";

    $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
#    $dbh->disconnect;
    return($bibitemnum);
}

sub OLDnewsubject {
  my ($dbh,$bibnum)=@_;
#  my $dbh=C4Connect;
  my $query="insert into bibliosubject (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
#  $dbh->disconnect;
}

sub OLDnewsubtitle {
    my ($dbh,$bibnum, $subtitle) = @_;
#  my $dbh   = C4Connect;
    $subtitle = $dbh->quote($subtitle);
    my $query = "insert into bibliosubtitle set
                            biblionumber = $bibnum,
                            subtitle = $subtitle";
    my $sth   = $dbh->prepare($query);

    $sth->execute;

    $sth->finish;
#  $dbh->disconnect;
}


sub OLDnewitems {
  my ($dbh,$item, $barcode) = @_;
#  my $dbh   = C4Connect;
  my $query = "Select max(itemnumber) from items";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $itemnumber;
  my $error = "";

  $sth->execute;
  $data       = $sth->fetchrow_hashref;
  $itemnumber = $data->{'max(itemnumber)'} + 1;
  $sth->finish;
  
  $item->{'booksellerid'}     = $dbh->quote($item->{'booksellerid'});
  $item->{'homebranch'}       = $dbh->quote($item->{'homebranch'});
  $item->{'price'}            = $dbh->quote($item->{'price'});
  $item->{'replacementprice'} = $dbh->quote($item->{'replacementprice'});
  $item->{'itemnotes'}        = $dbh->quote($item->{'itemnotes'});

#  foreach my $barcode (@barcodes) {
#    $barcode = uc($barcode);
  $barcode = $dbh->quote($barcode);
  $query   = "Insert into items set
                            itemnumber           = $itemnumber,
                            biblionumber         = $item->{'biblionumber'},
                            biblioitemnumber     = $item->{'biblioitemnumber'},
                            barcode              = $barcode,
                            booksellerid         = $item->{'booksellerid'},
                            dateaccessioned      = NOW(),
                            homebranch           = $item->{'homebranch'},
                            holdingbranch        = $item->{'homebranch'},
                            price                = $item->{'price'},
                            replacementprice     = $item->{'replacementprice'},
                            replacementpricedate = NOW(),
                            itemnotes            = $item->{'itemnotes'}";
  if ($item->{'loan'}) {
      $query .= ",notforloan           = $item->{'loan'}";
  } # if

  $sth = $dbh->prepare($query);
  $sth->execute;
  if (defined $sth->errstr) {
      $error .= $sth->errstr;
  }
  $sth->finish;
#  $itemnumber++;
#  $dbh->disconnect;
  return($itemnumber,$error);
}

sub OLDmoditem {
    my ($dbh,$item) = @_;
#  my ($dbh,$loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
#  my $dbh=C4Connect;
  my $query="update items set biblioitemnumber=$item->{'bibitemnum'},
                              barcode='$item->{'barcode'}',itemnotes='$item->{'notes'}'
                          where itemnumber=$item->{'itemnum'}";
  if ($item->{'barcode'} eq ''){
    $query="update items set biblioitemnumber=$item->{'bibitemnum'},notforloan=$item->{'loan'} where itemnumber=$item->{'itemnum'}";
  }
  if ($item->{'lost'} ne ''){
    $query="update items set biblioitemnumber=$item->{'bibitemnum'},
                             barcode='$item->{'barcode'}',
                             itemnotes='$item->{'notes'}',
                             homebranch='$item->{'homebranch'}',
                             itemlost='$item->{'lost'}',
                             wthdrawn='$item->{'wthdrawn'}' 
                          where itemnumber=$item->{'itemnum'}";
  }
  if ($item->{'replacement'} ne ''){
    $query=~ s/ where/,replacementprice='$item->{'replacement'}' where/;
  }

  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
#  $dbh->disconnect;
}

# FIXME - A nearly-identical function, &delitem, appears in
# C4::Acquisitions
sub OLDdelitem{
  my ($dbh,$itemnum)=@_;
#  my $dbh=C4Connect;
  my $query="select * from items where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @data=$sth->fetchrow_array;
  $sth->finish;
  $query="Insert into deleteditems values (";
  foreach my $temp (@data){
    $query=$query."'$temp',";
  }
  $query=~ s/\,$/\)/;
#  print $query;
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query = "Delete from items where itemnumber=$itemnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
#  $dbh->disconnect;
}

sub OLDdeletebiblioitem {
    my ($dbh,$biblioitemnumber) = @_;
#    my $dbh   = C4Connect;
    my $query = "Select * from biblioitems
where biblioitemnumber = $biblioitemnumber";
    my $sth   = $dbh->prepare($query);
    my @results;

    $sth->execute;
  
    if (@results = $sth->fetchrow_array) {
        $query = "Insert into deletedbiblioitems values (";
        foreach my $value (@results) {
            $value  = $dbh->quote($value);
            $query .= "$value,";
        } # foreach

        $query =~ s/\,$/\)/;
        $dbh->do($query);

        $query = "Delete from biblioitems
                        where biblioitemnumber = $biblioitemnumber";
        $dbh->do($query);
    } # if
    $sth->finish;
# Now delete all the items attached to the biblioitem
    $query = "Select * from items where biblioitemnumber = $biblioitemnumber";
    $sth   = $dbh->prepare($query);
    $sth->execute;
    while (@results = $sth->fetchrow_array) {
	$query = "Insert into deleteditems values (";
	foreach my $value (@results) {
	    $value  = $dbh->quote($value);
	    $query .= "$value,";
	} # foreach
	$query =~ s/\,$/\)/;
	$dbh->do($query);
    } # while
    $sth->finish;
    $query = "Delete from items where biblioitemnumber = $biblioitemnumber";
    $dbh->do($query);
#    $dbh->disconnect;
} # sub deletebiblioitem

sub OLDdelbiblio{
  my ($dbh,$biblio)=@_;
#  my $dbh=C4Connect;
  my $query="select * from biblio where biblionumber=$biblio";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my @data=$sth->fetchrow_array){
    $sth->finish;
    $query="Insert into deletedbiblio values (";
    foreach my $temp (@data){
      $temp=~ s/\'/\\\'/g;
      $query=$query."'$temp',";
    }
    $query=~ s/\,$/\)/;
#   print $query;
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query = "Delete from biblio where biblionumber=$biblio";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
  }
  $sth->finish;
#  $dbh->disconnect;
}

#
#
# old functions
#
#

# FIXME - This is the same as &C4::Acquisitions::itemcount, but not
# the same as &C4::Search::itemcount
# Since they're both exported, acqui/acquire.pl doesn't compile with -w.
sub itemcount{
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from items where biblionumber=$biblio";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'count(*)'});
}

sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select ordernumber 
 	from aqorders 
 	where biblionumber=? and biblioitemnumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bib,$bi);
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

# FIXME - This is practically the same function as
# &C4::Acquisitions::getsingleorder and &C4::Catalogue::getsingleorder
sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber=? 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute($ordnum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

# FIXME - This is in effect identical to &C4::Acquisitions::newbiblio.
# Pick one and stick with it.
sub newbiblio {
  my ($biblio) = @_;
  my $dbh    = C4::Context->dbh;
  my $bibnum=OLDnewbiblio($dbh,$biblio);
# TODO : MARC add
  return($bibnum);
}

# FIXME - This is in effect the same as &C4::Acquisitions::modbiblio.
# Pick one and stick with it.
sub modbiblio {
  my ($biblio) = @_;
  my $dbh  = C4::Context->dbh;
  my $biblionumber=OLDmodbiblio($dbh,$biblio);
  return($biblionumber);
} # sub modbiblio

# FIXME - This is in effect identical to &C4::Acquisitions::modsubtitle.
# Pick one and stick with it.
sub modsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4::Context->dbh;
  &OLDmodsubtitle($dbh,$bibnum,$subtitle);
} # sub modsubtitle


# FIXME - This is functionally identical to
# &C4::Acquisitions::modaddauthor
# Pick one and stick with it.
sub modaddauthor {
    my ($bibnum, $author) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDmodaddauthor($dbh,$bibnum,$author);
} # sub modaddauthor


# FIXME - This is in effect identical to &C4::Acquisitions::modsubject.
# Pick one and stick with it.
sub modsubject {
  my ($bibnum, $force, @subject) = @_;
  my $dbh   = C4::Context->dbh;
  my $error= &OLDmodsubject($dbh,$bibnum,$force, @subject);
  return($error);
} # sub modsubject

# FIXME - This is very similar to &C4::Acquisitions::modbibitem.
# Pick one and stick with it.
sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDmodbibitem($dbh,$biblioitem);
    my $MARCbibitem = MARCkoha2marcBiblio($dbh,$biblioitem);
    &MARCmodbiblio($dbh,$biblioitem->{biblionumber},0,$MARCbibitem);
} # sub modbibitem

# FIXME - This is in effect identical to &C4::Acquisitions::modnote.
# Pick one and stick with it.
sub modnote {
  my ($bibitemnum,$note)=@_;
  my $dbh = C4::Context->dbh;
  &OLDmodnote($dbh,$bibitemnum,$note);
}

# FIXME - This is quite similar in effect to &C4::newbiblioitem,
# except for the MARC stuff. There's also a &newbiblioitem in
# acqui.simple/addbookslccn.pl
sub newbiblioitem {
  my ($biblioitem) = @_;
  my $dbh   = C4::Context->dbh;
  my $bibitemnum = &OLDnewbiblioitem($dbh,$biblioitem);
#  print STDERR "bibitemnum : $bibitemnum\n";
  my $MARCbiblio= MARCkoha2marcBiblio($dbh,$biblioitem->{biblionumber},$bibitemnum);
#  print STDERR $MARCbiblio->as_formatted();
  &MARCaddbiblio($dbh,$MARCbiblio,$biblioitem->{biblionumber});
  return($bibitemnum);
}

# FIXME - This is in effect identical to &C4::Acquisitions::newsubject.
# Pick one and stick with it.
sub newsubject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  &OLDnewsubject($dbh,$bibnum);
}

# FIXME - This is just a wrapper around &OLDnewsubtitle
# FIXME - This is in effect the same as &C4::Acquisitions::newsubtitle
sub newsubtitle {
    my ($bibnum, $subtitle) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDnewsubtitle($dbh,$bibnum,$subtitle);
}

# FIXME - This is different from &C4::Acquisitions::newitems, though
# both are exported.
sub newitems {
  my ($item, @barcodes) = @_;
  my $dbh   = C4::Context->dbh;
  my $errors;
  my $itemnumber;
  my $error;
  foreach my $barcode (@barcodes) {
      ($itemnumber,$error)=&OLDnewitems($dbh,$item,uc($barcode));
      $errors .=$error;
#      print STDERR "biblionumber : $item->{biblionumber} / MARCbibid : $MARCbibid / itemnumber : $itemnumber\n";
      my $MARCitem = &MARCkoha2marcItem($dbh,$item->{biblionumber},$itemnumber);
#      print STDERR "MARCitem ".$MARCitem->as_formatted()."\n";
      &MARCadditem($dbh,$MARCitem,$item->{biblionumber});
#      print STDERR "MARCmodbiblio called\n";
  }
  return($errors);
}

# FIXME - This appears to be functionally equivalent to
# &C4::Acquisitions::moditem.
# Pick one and stick with it.
sub moditem {
    my ($item) = @_;
#  my ($loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
    my $dbh = C4::Context->dbh;
    &OLDmoditem($dbh,$item);
    warn "biblionumber : $item->{'biblionumber'} / $item->{'itemnum'}\n";
    my $MARCitem = &MARCkoha2marcItem($dbh,$item->{'biblionumber'},$item->{'itemnum'});
    warn "before MARCmoditem : $item->{biblionumber}, $item->{'itemnum'}\n";
    warn $MARCitem->as_formatted();
#      print STDERR "MARCitem ".$MARCitem->as_formatted()."\n";
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$item->{biblionumber});
    &MARCmoditem($dbh,$MARCitem,$bibid,$item->{itemnum},0);
}

# FIXME - This is the same as &C4::Acquisitions::Checkitems.
# Pick one and stick with it.
sub checkitems{
  my ($count,@barcodes)=@_;
  my $dbh = C4::Context->dbh;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $barcodes[$i]=uc $barcodes[$i];
    my $query="Select * from items where barcode='$barcodes[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref){
      $error.=" Duplicate Barcode: $barcodes[$i]";
    }
    $sth->finish;
  }
  return($error);
}

# FIXME - This is identical to &C4::Acquisitions::countitems.
# Pick one and stick with it.
sub countitems{
  my ($bibitemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from items where biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'count(*)'});
}

# FIXME - This is just a wrapper around &OLDdelitem, and acts
# identically to &C4::Acquisitions::delitem
# Pick one and stick with it.
sub delitem{
  my ($itemnum)=@_;
  my $dbh = C4::Context->dbh;
  &OLDdelitem($dbh,$itemnum);
}

# FIXME - This is functionally identical to
# &C4::Acquisitions::deletebiblioitem.
# Pick one and stick with it.
sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDdeletebiblioitem($dbh,$biblioitemnumber);
} # sub deletebiblioitem


# FIXME - This is functionally identical to &C4::Acquisitions::delbiblio.
# Pick one and stick with it.
sub delbiblio {
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  &OLDdelbiblio($dbh,$biblio);
}

# FIXME - This is identical to &C4::Acquisitions::getitemtypes.
# Pick one and stick with it.
sub getitemtypes {
  my $dbh   = C4::Context->dbh;
  my $query = "select * from itemtypes";
  my $sth   = $dbh->prepare($query);
    # || die "Cannot prepare $query" . $dbh->errstr;
  my $count = 0;
  my @results;
  
  $sth->execute;
    # || die "Cannot execute $query\n" . $sth->errstr;
  while (my $data = $sth->fetchrow_hashref) {
    $results[$count] = $data;
    $count++;
  } # while
  
  $sth->finish;
  return($count, @results);
} # sub getitemtypes

sub getbiblio {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblio where biblionumber = $biblionumber";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    return($count, @results);
} # sub getbiblio

# FIXME - This is identical to &C4::Acquisitions::getbiblioitem.
# Pick one and stick with it.
sub getbiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems where
biblioitemnumber = $biblioitemnum";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getbiblioitem

# FIXME - This is identical to
# &C4::Acquisitions::getbiblioitembybiblionumber.
# Pick one and stick with it.
sub getbiblioitembybiblionumber {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems where biblionumber =
$biblionumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub

# FIXME - This is identical to
# &C4::Acquisitions::getbiblioitembybiblionumber.
# Pick one and stick with it.
sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from items, biblio where
biblio.biblionumber = items.biblionumber and biblioitemnumber
= $biblioitemnum";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    return($count, @results);
} # sub getitemsbybiblioitem

# FIXME - This is identical to &C4::Acquisitions::isbnsearch.
# Pick one and stick with it.
sub isbnsearch {
    my ($isbn) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my $query;
    my $sth;
    my @results;
    
    $isbn  = $dbh->quote($isbn);
    $query = "Select biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber
and isbn = $isbn";
    $sth   = $dbh->prepare($query);
    
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch

#sub skip {
# At the moment this is just a straight copy of the subject code.  Needs heavy
# modification to work for additional authors, obviously.
# Check for additional author changes
    
#    my $newadditionalauthor='';
#    my $additionalauthors;
#    foreach $newadditionalauthor (@{$biblio->{'additionalauthor'}}) {
#	$additionalauthors->{$newadditionalauthor}=1;
#	if ($origadditionalauthors->{$newadditionalauthor}) {
#	    $additionalauthors->{$newadditionalauthor}=2;
#	} else {
#	    my $q_newadditionalauthor=$dbh->quote($newadditionalauthor);
#	    my $sth=$dbh->prepare("insert into biblioadditionalauthors (additionalauthor,biblionumber) values ($q_newadditionalauthor, $biblionumber)");
#	    $sth->execute;
#	    logchange('kohadb', 'add', 'biblio', 'additionalauthor', $newadditionalauthor);
#	    my $subfields;
#	    $subfields->{1}->{'Subfield_Mark'}='a';
#	    $subfields->{1}->{'Subfield_Value'}=$newadditionalauthor;
#	    my $tag='650';
#	    my $Record_ID;
#	    foreach $Record_ID (@marcrecords) {
#		addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
#		logchange('marc', 'add', $Record_ID, '650', 'a', $newadditionalauthor);
#	    }
#	}
#    }
#    my $origadditionalauthor;
#    foreach $origadditionalauthor (keys %$origadditionalauthors) {
#	if ($additionalauthors->{$origadditionalauthor} == 1) {
#	    my $q_origadditionalauthor=$dbh->quote($origadditionalauthor);
#	    logchange('kohadb', 'delete', 'biblio', '$biblionumber', 'additionalauthor', $origadditionalauthor);
#	    my $sth=$dbh->prepare("delete from biblioadditionalauthors where biblionumber=$biblionumber and additionalauthor=$q_origadditionalauthor");
#	    $sth->execute;
#	}
#    }
#
#}
#    $dbh->disconnect;
#}

sub logchange {
# Subroutine to log changes to databases
# Eventually, this subroutine will be used to create a log of all changes made,
# with the possibility of "undo"ing some changes
    my $database=shift;
    if ($database eq 'kohadb') {
	my $type=shift;
	my $section=shift;
	my $item=shift;
	my $original=shift;
	my $new=shift;
	print STDERR "KOHA: $type $section $item $original $new\n";
    } elsif ($database eq 'marc') {
	my $type=shift;
	my $Record_ID=shift;
	my $tag=shift;
	my $mark=shift;
	my $subfield_ID=shift;
	my $original=shift;
	my $new=shift;
	print STDERR "MARC: $type $Record_ID $tag $mark $subfield_ID $original $new\n";
    }
}

#------------------------------------------------


#---------------------------------------
# Find a biblio entry, or create a new one if it doesn't exist.
#  If a "subtitle" entry is in hash, add it to subtitle table
sub getoraddbiblio {
	# input params
	my (
	  $dbh,		# db handle
	  $biblio,	# hash ref to fields
	)=@_;

	# return
	my $biblionumber;

	my $debug=0;
	my $sth;
	my $error;

	#-----
    	requireDBI($dbh,"getoraddbiblio");

	print "<PRE>Looking for biblio </PRE>\n" if $debug;
	$sth=$dbh->prepare("select biblionumber
		from biblio
		where title=? and author=? 
		  and copyrightdate=? and seriestitle=?");
	$sth->execute(
		$biblio->{title}, $biblio->{author},
		$biblio->{copyright}, $biblio->{seriestitle} );
	if ($sth->rows) {
	    ($biblionumber) = $sth->fetchrow;
	    print "<PRE>Biblio exists with number $biblionumber</PRE>\n" if $debug;
	} else {
	    # Doesn't exist.  Add new one.
	    print "<PRE>Adding biblio</PRE>\n" if $debug;
	    ($biblionumber,$error)=&newbiblio($biblio);
	    if ( $biblionumber ) {
	      print "<PRE>Added with biblio number=$biblionumber</PRE>\n" if $debug;
	      if ( $biblio->{subtitle} ) {
	    	&newsubtitle($biblionumber,$biblio->{subtitle} );
	      } # if subtitle
	    } else {
		print "<PRE>Couldn't add biblio: $error</PRE>\n" if $debug;
	    } # if added
	}

	return $biblionumber,$error;

} # sub getoraddbiblio

#
#
# UNUSEFUL SUBs. Could be deleted, kept only until beta test
# maybe useful for some MARC tricks steve used.
#

sub OLD_MAYBE_DELETED_newBiblioItem {
    my ($env, $biblioitem) = @_;
    my $dbh = C4::Context->dbh;
    my $biblionumber=$biblioitem->{'biblionumber'};
    my $biblioitemnumber=$biblioitem->{'biblioitemnumber'};
    my $volume=$biblioitem->{'volume'};
    my $q_volume=$dbh->quote($volume);
    my $number=$biblioitem->{'number'};
    my $q_number=$dbh->quote($number);
    my $classification=$biblioitem->{'classification'};
    my $q_classification=$dbh->quote($classification);
    my $itemtype=$biblioitem->{'itemtype'};
    my $q_itemtype=$dbh->quote($itemtype);
    my $isbn=$biblioitem->{'isbn'};
    my $q_isbn=$dbh->quote($isbn);
    my $issn=$biblioitem->{'issn'};
    my $q_issn=$dbh->quote($issn);
    my $dewey=$biblioitem->{'dewey'};
    $dewey=~s/\.*0*$//;
    ($dewey == 0) && ($dewey='');
    my $subclass=$biblioitem->{'subclass'};
    my $q_subclass=$dbh->quote($subclass);
    my $publicationyear=$biblioitem->{'publicationyear'};
    my $publishercode=$biblioitem->{'publishercode'};
    my $q_publishercode=$dbh->quote($publishercode);
    my $volumedate=$biblioitem->{'volumedate'};
    my $q_volumedate=$dbh->quote($volumedate);
    my $illus=$biblioitem->{'illus'};
    my $q_illus=$dbh->quote($illus);
    my $pages=$biblioitem->{'pages'};
    my $q_pages=$dbh->quote($pages);
    my $notes=$biblioitem->{'notes'};
    my $q_notes=$dbh->quote($notes);
    my $size=$biblioitem->{'size'};
    my $q_size=$dbh->quote($size);
    my $place=$biblioitem->{'place'};
    my $q_place=$dbh->quote($place);
    my $lccn=$biblioitem->{'lccn'};
    my $q_lccn=$dbh->quote($lccn);


# Unless the $env->{'marconly'} flag is set, update the biblioitems table with
# the new data

    unless ($env->{'marconly'}) {
	#my $sth=$dbh->prepare("lock tables biblioitems write");
	#$sth->execute;
	my $sth=$dbh->prepare("select max(biblioitemnumber) from biblioitems");
	$sth->execute;
	my ($biblioitemnumber) =$sth->fetchrow;
	$biblioitemnumber++;
	$sth=$dbh->prepare("insert into biblioitems (biblionumber,biblioitemnumber,volume,number,classification,itemtype,isbn,issn,dewey,subclass,publicationyear,publishercode,volumedate,illus,pages,notes,size,place,lccn) values ($biblionumber, $biblioitemnumber, $q_volume, $q_number, $q_classification, $q_itemtype, $q_isbn, $q_issn, $dewey, $q_subclass, $publicationyear, $q_publishercode, $q_volumedate, $q_illus, $q_pages,$q_notes, $q_size, $q_place, $q_lccn)");
	$sth->execute;
	#my $sth=$dbh->prepare("unlock tables");
	#$sth->execute;
    }


# Should we check if there is already a biblioitem/amrc with the
# same isbn/lccn/issn?

    my $sth=$dbh->prepare("select title,unititle,seriestitle,copyrightdate,notes,author from biblio where biblionumber=$biblionumber");
    $sth->execute;
    my ($title, $unititle,$seriestitle,$copyrightdate,$biblionotes,$author) = $sth->fetchrow;
    $sth=$dbh->prepare("select subtitle from bibliosubtitle where biblionumber=$biblionumber");
    $sth->execute;
    my ($subtitle) = $sth->fetchrow;
    $sth=$dbh->prepare("select author from additionalauthors where biblionumber=$biblionumber");
    $sth->execute;
    my @additionalauthors;
    while (my ($additionalauthor) = $sth->fetchrow) {
	push (@additionalauthors, $additionalauthor);
    }
    $sth=$dbh->prepare("select subject from bibliosubject where biblionumber=$biblionumber");
    $sth->execute;
    my @subjects;
    while (my ($subject) = $sth->fetchrow) {
	push (@subjects, $subject);
    }

# MARC SECTION

    $sth=$dbh->prepare("insert into Resource_Table (Record_ID) values (0)");
    $sth->execute;
    my $Resource_ID=$dbh->{'mysql_insertid'};
    my $Record_ID=$Resource_ID;
    $sth=$dbh->prepare("update Resource_Table set Record_ID=$Record_ID where Resource_ID=$Resource_ID");
    $sth->execute;

# Title
    {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$title;
	if ($subtitle) {
	    $subfields->{2}->{'Subfield_Mark'}='b';
	    $subfields->{2}->{'Subfield_Value'}=$subtitle;
	}
	my $tag='245';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }

# author
    {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$author;
	my $tag='100';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Series Title
    if ($seriestitle) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$seriestitle;
	my $tag='440';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Biblio Note
    if ($biblionotes) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$biblionotes;
	$subfields->{2}->{'Subfield_Mark'}='3';
	$subfields->{2}->{'Subfield_Value'}='biblio';
	my $tag='500';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Additional Authors
    foreach (@additionalauthors) {
	my $author=$_;
	(next) unless ($author);
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$author;
	$subfields->{2}->{'Subfield_Mark'}='e';
	$subfields->{2}->{'Subfield_Value'}='author';
	my $tag='700';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Illustrator
    if ($illus) {
	(next) unless ($illus);
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$illus;
	$subfields->{2}->{'Subfield_Mark'}='e';
	$subfields->{2}->{'Subfield_Value'}='illustrator';
	my $tag='700';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Subjects
    foreach (@subjects) {
	my $subject=$_;
	(next) unless ($subject);
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$subject;
	my $tag='650';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }


# ISBN
    if ($isbn) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$isbn;
	my $tag='020';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# LCCN
    if ($lccn) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$lccn;
	my $tag='010';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# ISSN
    if ($issn) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$issn;
	my $tag='022';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# DEWEY
    if ($dewey) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$dewey;
	my $tag='082';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# DEWEY subclass and itemtype
    {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$itemtype;
	$subfields->{2}->{'Subfield_Mark'}='b';
	$subfields->{2}->{'Subfield_Value'}=$subclass;
	$subfields->{3}->{'Subfield_Mark'}='c';
	$subfields->{3}->{'Subfield_Value'}=$biblionumber;
	$subfields->{4}->{'Subfield_Mark'}='d';
	$subfields->{4}->{'Subfield_Value'}=$biblioitemnumber;
	my $tag='090';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# PUBLISHER
    {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$place;
	$subfields->{2}->{'Subfield_Mark'}='b';
	$subfields->{2}->{'Subfield_Value'}=$publishercode;
	$subfields->{3}->{'Subfield_Mark'}='c';
	$subfields->{3}->{'Subfield_Value'}=$publicationyear;
	if ($copyrightdate) {
	    $subfields->{4}->{'Subfield_Mark'}='c';
	    $subfields->{4}->{'Subfield_Value'}="c$copyrightdate";
	}
	my $tag='260';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# PHYSICAL
    if ($pages || $size) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$pages;
	$subfields->{2}->{'Subfield_Mark'}='c';
	$subfields->{2}->{'Subfield_Value'}=$size;
	my $tag='300';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Volume/Number
    if ($volume || $number) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='v';
	$subfields->{1}->{'Subfield_Value'}=$volume;
	$subfields->{2}->{'Subfield_Mark'}='n';
	$subfields->{2}->{'Subfield_Value'}=$number;
	my $tag='440';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
# Biblioitem Note
    if ($notes) {
	my $subfields;
	$subfields->{1}->{'Subfield_Mark'}='a';
	$subfields->{1}->{'Subfield_Value'}=$notes;
	$subfields->{2}->{'Subfield_Mark'}='3';
	$subfields->{2}->{'Subfield_Value'}='biblioitem';
	my $tag='500';
	addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    }
    $sth->finish;
    return ($env, $Record_ID);
}

sub OLD_MAYBE_DELETED_newItem {
    my ($env, $Record_ID, $item) = @_;
    my $dbh = C4::Context->dbh;
    my $barcode=$item->{'barcode'};
    my $q_barcode=$dbh->quote($barcode);
    my $biblionumber=$item->{'biblionumber'};
    my $biblioitemnumber=$item->{'biblioitemnumber'};
    my $dateaccessioned=$item->{'dateaccessioned'};
    my $booksellerid=$item->{'booksellerid'};
    my $q_booksellerid=$dbh->quote($booksellerid);
    my $homebranch=$item->{'homebranch'};
    my $q_homebranch=$dbh->quote($homebranch);
    my $holdingbranch=$item->{'holdingbranch'};
    my $price=$item->{'price'};
    my $replacementprice=$item->{'replacementprice'};
    my $replacementpricedate=$item->{'replacementpricedate'};
    my $q_replacementpricedate=$dbh->quote($replacementpricedate);
    my $notforloan=$item->{'notforloan'};
    my $itemlost=$item->{'itemlost'};
    my $wthdrawn=$item->{'wthdrawn'};
    my $restricted=$item->{'restricted'};
    my $itemnotes=$item->{'itemnotes'};
    my $q_itemnotes=$dbh->quote($itemnotes);
    my $itemtype=$item->{'itemtype'};
    my $subclass=$item->{'subclass'};

# KOHADB Section

    unless ($env->{'marconly'}) {
	my $sth=$dbh->prepare("select max(itemnumber) from items");
	$sth->execute;
	my ($itemnumber) =$sth->fetchrow;
	$itemnumber++;
	$sth=$dbh->prepare("insert into items (itemnumber,biblionumber,biblioitemnumber,barcode,dateaccessioned,booksellerid,homebranch,price,replacementprice,replacementpricedate,notforloan,itemlost,wthdrawn,restricted,itemnotes) values ($itemnumber,$biblionumber,$biblioitemnumber,$q_barcode,$dateaccessioned,$q_booksellerid,$q_homebranch,$price,$q_replacementpricedate,$notforloan,$itemlost,$wthdrawn,$restricted,$q_itemnotes)");
	$sth->execute;
    }


# MARC SECTION
    my $subfields;
    $subfields->{1}->{'Subfield_Mark'}='p';
    $subfields->{1}->{'Subfield_Value'}=$barcode;
    $subfields->{2}->{'Subfield_Mark'}='d';
    $subfields->{2}->{'Subfield_Value'}=$dateaccessioned;
    $subfields->{3}->{'Subfield_Mark'}='e';
    $subfields->{3}->{'Subfield_Value'}=$booksellerid;
    $subfields->{4}->{'Subfield_Mark'}='b';
    $subfields->{4}->{'Subfield_Value'}=$homebranch;
    $subfields->{5}->{'Subfield_Mark'}='l';
    $subfields->{5}->{'Subfield_Value'}=$holdingbranch;
    $subfields->{6}->{'Subfield_Mark'}='c';
    $subfields->{6}->{'Subfield_Value'}=$price;
    $subfields->{7}->{'Subfield_Mark'}='c';
    $subfields->{7}->{'Subfield_Value'}=$replacementprice;
    $subfields->{8}->{'Subfield_Mark'}='d';
    $subfields->{8}->{'Subfield_Value'}=$replacementpricedate;
    if ($notforloan) {
	$subfields->{9}->{'Subfield_Mark'}='h';
	$subfields->{9}->{'Subfield_Value'}='Not for loan';
    }
    if ($notforloan) {
	$subfields->{10}->{'Subfield_Mark'}='j';
	$subfields->{10}->{'Subfield_Value'}='Item lost';
    }
    if ($notforloan) {
	$subfields->{11}->{'Subfield_Mark'}='j';
	$subfields->{11}->{'Subfield_Value'}='Item withdrawn';
    }
    if ($notforloan) {
	$subfields->{12}->{'Subfield_Mark'}='z';
	$subfields->{12}->{'Subfield_Value'}=$itemnotes;
    }
    my $tag='876';
    my $Tag_ID;
    $env->{'linkage'}=1;
    ($env, $Tag_ID) = addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
    $env->{'linkage'}=0;
    $env->{'linkid'}=$Tag_ID;
    $tag='852';
    my $subfields2;
    $subfields2->{1}->{'Subfield_Mark'}='a';
    $subfields2->{1}->{'Subfield_Value'}='Coast Mountains School District';
    $subfields2->{1}->{'Subfield_Mark'}='b';
    $subfields2->{1}->{'Subfield_Value'}=$homebranch;
    $subfields2->{1}->{'Subfield_Mark'}='c';
    $subfields2->{1}->{'Subfield_Value'}=$itemtype;
    $subfields2->{2}->{'Subfield_Mark'}='m';
    $subfields2->{2}->{'Subfield_Value'}=$subclass;
    addTag($env, $Record_ID, $tag, ' ', ' ', $subfields2);
    $env->{'linkid'}='';
}

sub OLD_MAYBE_DELETED_updateBiblio {
# Update the biblio with biblionumber $biblio->{'biblionumber'}
# I guess this routine should search through all marc records for a record that
# has the same biblionumber stored in it, and modify the MARC record as well as
# the biblio table.
#
# Also, this subroutine should search through the $biblio object and compare it
# to the existing record and _LOG ALL CHANGES MADE_ in some way.  I'd like for
# this logging feature to be usable to undo changes easily.

    my ($env, $biblio) = @_;
    my $Record_ID;
    my $biblionumber=$biblio->{'biblionumber'};
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select * from biblio where biblionumber=$biblionumber");
    $sth->execute;
    my $origbiblio=$sth->fetchrow_hashref;
    $sth=$dbh->prepare("select subtitle from bibliosubtitle where biblionumber=$biblionumber");
    $sth->execute;
    my ($subtitle)=$sth->fetchrow;
    $origbiblio->{'subtitle'}=$subtitle;
    $sth=$dbh->prepare("select author from additionalauthors where biblionumber=$biblionumber");
    $sth->execute;
    my $origadditionalauthors;
    while (my ($author) = $sth->fetchrow) {
	push (@{$origbiblio->{'additionalauthors'}}, $author);
	$origadditionalauthors->{$author}=1;
    }
    $sth=$dbh->prepare("select subject from bibliosubject where biblionumber=$biblionumber");
    $sth->execute;
    my $origsubjects;
    while (my ($subject) = $sth->fetchrow) {
	push (@{$origbiblio->{'subjects'}}, $subject);
	$origsubjects->{$subject}=1;
    }

    
# Obtain a list of MARC Record_ID's that are tied to this biblio
    $sth=$dbh->prepare("select bibid from marc_subfield_table where tag='090' and subfieldvalue=$biblionumber and subfieldcode='c'");
    $sth->execute;
    my @marcrecords;
    while (my ($bibid) = $sth->fetchrow) {
	push(@marcrecords, $bibid);
    }

    my $bibid='';
    if ($biblio->{'author'} ne $origbiblio->{'author'}) {
	my $q_author=$dbh->quote($biblio->{'author'});
	logchange('kohadb', 'change', 'biblio', 'author', $origbiblio->{'author'}, $biblio->{'author'});
	my $sti=$dbh->prepare("update biblio set author=$q_author where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $bibid (@marcrecords) {
	    logchange('marc', 'change', $bibid, '100', 'a', $origbiblio->{'author'}, $biblio->{'author'});
	    changeSubfield($bibid, '100', 'a', $origbiblio->{'author'}, $biblio->{'author'});
	}
    }
    if ($biblio->{'title'} ne $origbiblio->{'title'}) {
	my $q_title=$dbh->quote($biblio->{'title'});
	logchange('kohadb', 'change', 'biblio', 'title', $origbiblio->{'title'}, $biblio->{'title'});
	my $sti=$dbh->prepare("update biblio set title=$q_title where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $Record_ID (@marcrecords) {
	    logchange('marc', 'change', $Record_ID, '245', 'a', $origbiblio->{'title'}, $biblio->{'title'});
	    changeSubfield($Record_ID, '245', 'a', $origbiblio->{'title'}, $biblio->{'title'});
	}
    }
    if ($biblio->{'subtitle'} ne $origbiblio->{'subtitle'}) {
	my $q_subtitle=$dbh->quote($biblio->{'subtitle'});
	logchange('kohadb', 'change', 'biblio', 'subtitle', $origbiblio->{'subtitle'}, $biblio->{'subtitle'});
	my $sti=$dbh->prepare("update bibliosubtitle set subtitle=$q_subtitle where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $Record_ID (@marcrecords) {
	    logchange('marc', 'change', $Record_ID, '245', 'b', $origbiblio->{'subtitle'}, $biblio->{'subtitle'});
	    changeSubfield($Record_ID, '245', 'b', $origbiblio->{'subtitle'}, $biblio->{'subtitle'});
	}
    }
    if ($biblio->{'unititle'} ne $origbiblio->{'unititle'}) {
	my $q_unititle=$dbh->quote($biblio->{'unititle'});
	logchange('kohadb', 'change', 'biblio', 'unititle', $origbiblio->{'unititle'}, $biblio->{'unititle'});
	my $sti=$dbh->prepare("update biblio set unititle=$q_unititle where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
    }
    if ($biblio->{'notes'} ne $origbiblio->{'notes'}) {
	my $q_notes=$dbh->quote($biblio->{'notes'});
	logchange('kohadb', 'change', 'biblio', 'notes', $origbiblio->{'notes'}, $biblio->{'notes'});
	my $sti=$dbh->prepare("update biblio set notes=$q_notes where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $Record_ID (@marcrecords) {
	    logchange('marc', 'change', $Record_ID, '500', 'a', $origbiblio->{'notes'}, $biblio->{'notes'});
	    changeSubfield($Record_ID, '500', 'a', $origbiblio->{'notes'}, $biblio->{'notes'});
	}
    }
    if ($biblio->{'serial'} ne $origbiblio->{'serial'}) {
	my $q_serial=$dbh->quote($biblio->{'serial'});
	logchange('kohadb', 'change', 'biblio', 'serial', $origbiblio->{'serial'}, $biblio->{'serial'});
	my $sti=$dbh->prepare("update biblio set serial=$q_serial where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
    }
    if ($biblio->{'seriestitle'} ne $origbiblio->{'seriestitle'}) {
	my $q_seriestitle=$dbh->quote($biblio->{'seriestitle'});
	logchange('kohadb', 'change', 'biblio', 'seriestitle', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	my $sti=$dbh->prepare("update biblio set seriestitle=$q_seriestitle where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $Record_ID (@marcrecords) {
	    logchange('marc', 'change', $Record_ID, '440', 'a', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	    changeSubfield($Record_ID, '440', 'a', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	}
    }
    if ($biblio->{'copyrightdate'} ne $origbiblio->{'copyrightdate'}) {
	my $q_copyrightdate=$dbh->quote($biblio->{'copyrightdate'});
	logchange('kohadb', 'change', 'biblio', 'copyrightdate', $origbiblio->{'copyrightdate'}, $biblio->{'copyrightdate'});
	my $sti=$dbh->prepare("update biblio set copyrightdate=$q_copyrightdate where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	foreach $Record_ID (@marcrecords) {
	    logchange('marc', 'change', $Record_ID, '260', 'c', "c$origbiblio->{'notes'}", "c$biblio->{'notes'}");
	    changeSubfield($Record_ID, '260', 'c', "c$origbiblio->{'notes'}", "c$biblio->{'notes'}");
	}
    }

# Check for subject heading changes
    
    my $newsubject='';
    my $subjects;
    foreach $newsubject (@{$biblio->{'subject'}}) {
	$subjects->{$newsubject}=1;
	if ($origsubjects->{$newsubject}) {
	    $subjects->{$newsubject}=2;
	} else {
	    my $q_newsubject=$dbh->quote($newsubject);
	    my $sth=$dbh->prepare("insert into bibliosubject (subject,biblionumber) values ($q_newsubject, $biblionumber)");
	    $sth->execute;
	    logchange('kohadb', 'add', 'biblio', 'subject', $newsubject);
	    my $subfields;
	    $subfields->{1}->{'Subfield_Mark'}='a';
	    $subfields->{1}->{'Subfield_Value'}=$newsubject;
	    my $tag='650';
	    my $Record_ID;
	    foreach $Record_ID (@marcrecords) {
		addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
		logchange('marc', 'add', $Record_ID, '650', 'a', $newsubject);
	    }
	}
    }
    my $origsubject;
    foreach $origsubject (keys %$origsubjects) {
	if ($subjects->{$origsubject} == 1) {
	    my $q_origsubject=$dbh->quote($origsubject);
	    logchange('kohadb', 'delete', 'biblio', '$biblionumber', 'subject', $origsubject);
	    my $sth=$dbh->prepare("delete from bibliosubject where biblionumber=$biblionumber and subject=$q_origsubject");
	    $sth->execute;
	}
    }
}

sub OLD_MAYBE_DELETED_updateBiblioItem {
# Update the biblioitem with biblioitemnumber $biblioitem->{'biblioitemnumber'}
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $biblioitem) = @_;
    my $dbh = C4::Context->dbh;

    my $biblioitemnumber=$biblioitem->{'biblioitemnumber'};
    my $sth=$dbh->prepare("select * from biblioitems where biblioitemnumber=$biblioitemnumber");
# obi = original biblioitem
    my $obi=$sth->fetchrow_hashref;
    $sth=$dbh->prepare("select B.Record_ID from Bib_Table B, 0XX_Tag_Table T, 0XX_Subfield_Table S where B.Tag_0XX_ID=T.Tag_ID and T.Subfield_ID=S.Subfield_ID and T.Tag='090' and S.Subfield_Mark='c' and S.Subfield_Value=$biblioitemnumber");
    $sth->execute;
    my ($Record_ID) = $sth->fetchrow;
    if ($biblioitem->{'biblionumber'} ne $obi->{'biblionumber'}) {
	logchange('kohadb', 'change', 'biblioitems', 'biblionumber', $obi->{'biblionumber'}, $biblioitem->{'biblionumber'});
	my $sth=$dbh->prepare("update biblioitems set biblionumber=$biblioitem->{'biblionumber'} where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '090', 'c', $obi->{'biblionumber'}, $biblioitem->{'biblionumber'});
	changeSubfield($Record_ID, '090', 'c', $obi->{'biblionumber'}, $biblioitem->{'biblionumber'});
    }
    if ($biblioitem->{'volume'} ne $obi->{'volume'}) {
	logchange('kohadb', 'change', 'biblioitems', 'volume', $obi->{'volume'}, $biblioitem->{'volume'});
	my $q_volume=$dbh->quote($biblioitem->{'volume'});
	my $sth=$dbh->prepare("update biblioitems set volume=$q_volume where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '440', 'v', $obi->{'volume'}, $biblioitem->{'volume'});
	changeSubfield($Record_ID, '440', 'v', $obi->{'volume'}, $biblioitem->{'volume'});
    }
    if ($biblioitem->{'number'} ne $obi->{'number'}) {
	logchange('kohadb', 'change', 'biblioitems', 'number', $obi->{'number'}, $biblioitem->{'number'});
	my $q_number=$dbh->quote($biblioitem->{'number'});
	my $sth=$dbh->prepare("update biblioitems set number=$q_number where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '440', 'v', $obi->{'number'}, $biblioitem->{'number'});
	changeSubfield($Record_ID, '440', 'v', $obi->{'number'}, $biblioitem->{'number'});
    }
    if ($biblioitem->{'itemtype'} ne $obi->{'itemtype'}) {
	logchange('kohadb', 'change', 'biblioitems', 'itemtype', $obi->{'itemtype'}, $biblioitem->{'itemtype'});
	my $q_itemtype=$dbh->quote($biblioitem->{'itemtype'});
	my $sth=$dbh->prepare("update biblioitems set itemtype=$q_itemtype where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '090', 'a', $obi->{'itemtype'}, $biblioitem->{'itemtype'});
	changeSubfield($Record_ID, '090', 'a', $obi->{'itemtype'}, $biblioitem->{'itemtype'});
    }
    if ($biblioitem->{'isbn'} ne $obi->{'isbn'}) {
	logchange('kohadb', 'change', 'biblioitems', 'isbn', $obi->{'isbn'}, $biblioitem->{'isbn'});
	my $q_isbn=$dbh->quote($biblioitem->{'isbn'});
	my $sth=$dbh->prepare("update biblioitems set isbn=$q_isbn where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '020', 'a', $obi->{'isbn'}, $biblioitem->{'isbn'});
	changeSubfield($Record_ID, '020', 'a', $obi->{'isbn'}, $biblioitem->{'isbn'});
    }
    if ($biblioitem->{'issn'} ne $obi->{'issn'}) {
	logchange('kohadb', 'change', 'biblioitems', 'issn', $obi->{'issn'}, $biblioitem->{'issn'});
	my $q_issn=$dbh->quote($biblioitem->{'issn'});
	my $sth=$dbh->prepare("update biblioitems set issn=$q_issn where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '022', 'a', $obi->{'issn'}, $biblioitem->{'issn'});
	changeSubfield($Record_ID, '022', 'a', $obi->{'issn'}, $biblioitem->{'issn'});
    }
    if ($biblioitem->{'dewey'} ne $obi->{'dewey'}) {
	logchange('kohadb', 'change', 'biblioitems', 'dewey', $obi->{'dewey'}, $biblioitem->{'dewey'});
	my $sth=$dbh->prepare("update biblioitems set dewey=$biblioitem->{'dewey'} where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '082', 'a', $obi->{'dewey'}, $biblioitem->{'dewey'});
	changeSubfield($Record_ID, '082', 'a', $obi->{'dewey'}, $biblioitem->{'dewey'});
    }
    if ($biblioitem->{'subclass'} ne $obi->{'subclass'}) {
	logchange('kohadb', 'change', 'biblioitems', 'subclass', $obi->{'subclass'}, $biblioitem->{'subclass'});
	my $q_subclass=$dbh->quote($biblioitem->{'subclass'});
	my $sth=$dbh->prepare("update biblioitems set subclass=$q_subclass where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '090', 'b', $obi->{'subclass'}, $biblioitem->{'subclass'});
	changeSubfield($Record_ID, '090', 'b', $obi->{'subclass'}, $biblioitem->{'subclass'});
    }
    if ($biblioitem->{'place'} ne $obi->{'place'}) {
	logchange('kohadb', 'change', 'biblioitems', 'place', $obi->{'place'}, $biblioitem->{'place'});
	my $q_place=$dbh->quote($biblioitem->{'place'});
	my $sth=$dbh->prepare("update biblioitems set place=$q_place where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '260', 'a', $obi->{'place'}, $biblioitem->{'place'});
	changeSubfield($Record_ID, '260', 'a', $obi->{'place'}, $biblioitem->{'place'});
    }
    if ($biblioitem->{'publishercode'} ne $obi->{'publishercode'}) {
	logchange('kohadb', 'change', 'biblioitems', 'publishercode', $obi->{'publishercode'}, $biblioitem->{'publishercode'});
	my $q_publishercode=$dbh->quote($biblioitem->{'publishercode'});
	my $sth=$dbh->prepare("update biblioitems set publishercode=$q_publishercode where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '260', 'b', $obi->{'publishercode'}, $biblioitem->{'publishercode'});
	changeSubfield($Record_ID, '260', 'b', $obi->{'publishercode'}, $biblioitem->{'publishercode'});
    }
    if ($biblioitem->{'publicationyear'} ne $obi->{'publicationyear'}) {
	logchange('kohadb', 'change', 'biblioitems', 'publicationyear', $obi->{'publicationyear'}, $biblioitem->{'publicationyear'});
	my $q_publicationyear=$dbh->quote($biblioitem->{'publicationyear'});
	my $sth=$dbh->prepare("update biblioitems set publicationyear=$q_publicationyear where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '260', 'c', $obi->{'publicationyear'}, $biblioitem->{'publicationyear'});
	changeSubfield($Record_ID, '260', 'c', $obi->{'publicationyear'}, $biblioitem->{'publicationyear'});
    }
    if ($biblioitem->{'illus'} ne $obi->{'illus'}) {
	logchange('kohadb', 'change', 'biblioitems', 'illus', $obi->{'illus'}, $biblioitem->{'illus'});
	my $q_illus=$dbh->quote($biblioitem->{'illus'});
	my $sth=$dbh->prepare("update biblioitems set illus=$q_illus where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '700', 'a', $obi->{'illus'}, $biblioitem->{'illus'});
	changeSubfield($Record_ID, '700', 'a', $obi->{'illus'}, $biblioitem->{'illus'});
    }
    if ($biblioitem->{'pages'} ne $obi->{'pages'}) {
	logchange('kohadb', 'change', 'biblioitems', 'pages', $obi->{'pages'}, $biblioitem->{'pages'});
	my $q_pages=$dbh->quote($biblioitem->{'pages'});
	my $sth=$dbh->prepare("update biblioitems set pages=$q_pages where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '300', 'a', $obi->{'pages'}, $biblioitem->{'pages'});
	changeSubfield($Record_ID, '300', 'a', $obi->{'pages'}, $biblioitem->{'pages'});
    }
    if ($biblioitem->{'size'} ne $obi->{'size'}) {
	logchange('kohadb', 'change', 'biblioitems', 'size', $obi->{'size'}, $biblioitem->{'size'});
	my $q_size=$dbh->quote($biblioitem->{'size'});
	my $sth=$dbh->prepare("update biblioitems set size=$q_size where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '300', 'c', $obi->{'size'}, $biblioitem->{'size'});
	changeSubfield($Record_ID, '300', 'c', $obi->{'size'}, $biblioitem->{'size'});
    }
    if ($biblioitem->{'notes'} ne $obi->{'notes'}) {
	logchange('kohadb', 'change', 'biblioitems', 'notes', $obi->{'notes'}, $biblioitem->{'notes'});
	my $q_notes=$dbh->quote($biblioitem->{'notes'});
	my $sth=$dbh->prepare("update biblioitems set notes=$q_notes where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '500', 'a', $obi->{'notes'}, $biblioitem->{'notes'});
	changeSubfield($Record_ID, '500', 'a', $obi->{'notes'}, $biblioitem->{'notes'});
    }
    if ($biblioitem->{'lccn'} ne $obi->{'lccn'}) {
	logchange('kohadb', 'change', 'biblioitems', 'lccn', $obi->{'lccn'}, $biblioitem->{'lccn'});
	my $q_lccn=$dbh->quote($biblioitem->{'lccn'});
	my $sth=$dbh->prepare("update biblioitems set lccn=$q_lccn where biblioitemnumber=$biblioitemnumber");
	logchange('marc', 'change', $Record_ID, '010', 'a', $obi->{'lccn'}, $biblioitem->{'lccn'});
	changeSubfield($Record_ID, '010', 'a', $obi->{'lccn'}, $biblioitem->{'lccn'});
    }
    $sth->finish;
}

sub OLD_MAYBE_DELETED_updateItem {
# Update the item with itemnumber $item->{'itemnumber'}
# This routine should also modify the corresponding MARC record data. (852 and
# 876 tags with 876p tag the same as $item->{'barcode'}
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $item) = @_;
    my $dbh = C4::Context->dbh;
    my $itemnumber=$item->{'itemnumber'};
    my $biblionumber=$item->{'biblionumber'};
    my $biblioitemnumber=$item->{'biblioitemnumber'};
    my $barcode=$item->{'barcode'};
    my $dateaccessioned=$item->{'dateaccessioned'};
    my $booksellerid=$item->{'booksellerid'};
    my $homebranch=$item->{'homebranch'};
    my $price=$item->{'price'};
    my $replacementprice=$item->{'replacementprice'};
    my $replacementpricedate=$item->{'replacementpricedate'};
    my $multivolume=$item->{'multivolume'};
    my $stack=$item->{'stack'};
    my $notforloan=$item->{'notforloan'};
    my $itemlost=$item->{'itemlost'};
    my $wthdrawn=$item->{'wthdrawn'};
    my $bulk=$item->{'bulk'};
    my $restricted=$item->{'restricted'};
    my $binding=$item->{'binding'};
    my $itemnotes=$item->{'itemnotes'};
    my $holdingbranch=$item->{'holdingbranch'};
    my $interim=$item->{'interim'};
    my $sth=$dbh->prepare("select * from items where itemnumber=$itemnumber");
    $sth->execute;
    my $olditem=$sth->fetchrow_hashref;
    my $q_barcode=$dbh->quote($olditem->{'barcode'});
    $sth=$dbh->prepare("select S.Subfield_ID, B.Record_ID from 8XX_Subfield_Table S, 8XX_Tag_Table T, Bib_Table B where B.Tag_8XX_ID=T.Tag_ID and T.Subfield_ID=S.Subfield_ID and Subfield_Mark='p' and Subfield_Value=$q_barcode");
    $sth->execute;
    my ($Subfield876_ID, $Record_ID) = $sth->fetchrow;
    $sth=$dbh->prepare("select Subfield_Value from 8XX_Subfield_Table where Subfield_Mark=8 and Subfield_ID=$Subfield876_ID");
    $sth->execute;
    my ($link) = $sth->fetchrow;
    $sth=$dbh->prepare("select Subfield_ID from 8XX_Subfield_Table where Subfield_Mark=8 and Subfield_Value=$link and !(Subfield_ID=$Subfield876_ID)");
    $sth->execute;
    my ($Subfield852_ID) = $sth->fetchrow;
    
    if ($item->{'barcode'} ne $olditem->{'barcode'}) {
	logchange('kohadb', 'change', 'items', 'barcode', $olditem->{'barcode'}, $item->{'barcode'});
	my $q_barcode=$dbh->quote($item->{'barcode'});
	my $sth=$dbh->prepare("update items set barcode=$q_barcode where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'p', $olditem->{'barcode'}, $item->{'barcode'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'p', $Subfield_Key, $olditem->{'barcode'}, $item->{'barcode'});
    }
    if ($item->{'booksellerid'} ne $olditem->{'booksellerid'}) {
	logchange('kohadb', 'change', 'items', 'booksellerid', $olditem->{'booksellerid'}, $item->{'booksellerid'});
	my $q_booksellerid=$dbh->quote($item->{'booksellerid'});
	my $sth=$dbh->prepare("update items set booksellerid=$q_booksellerid where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'e', $olditem->{'booksellerid'}, $item->{'booksellerid'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'e', $Subfield_Key, $olditem->{'booksellerid'}, $item->{'booksellerid'});
    }
    if ($item->{'dateaccessioned'} ne $olditem->{'dateaccessioned'}) {
	logchange('kohadb', 'change', 'items', 'dateaccessioned', $olditem->{'dateaccessioned'}, $item->{'dateaccessioned'});
	my $q_dateaccessioned=$dbh->quote($item->{'dateaccessioned'});
	my $sth=$dbh->prepare("update items set dateaccessioned=$q_dateaccessioned where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'd', $olditem->{'dateaccessioned'}, $item->{'dateaccessioned'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'd', $Subfield_Key, $olditem->{'dateaccessioned'}, $item->{'dateaccessioned'});
    }
    if ($item->{'homebranch'} ne $olditem->{'homebranch'}) {
	logchange('kohadb', 'change', 'items', 'homebranch', $olditem->{'homebranch'}, $item->{'homebranch'});
	my $q_homebranch=$dbh->quote($item->{'homebranch'});
	my $sth=$dbh->prepare("update items set homebranch=$q_homebranch where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'b', $olditem->{'homebranch'}, $item->{'homebranch'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'b', $Subfield_Key, $olditem->{'homebranch'}, $item->{'homebranch'});
    }
    if ($item->{'holdingbranch'} ne $olditem->{'holdingbranch'}) {
	logchange('kohadb', 'change', 'items', 'holdingbranch', $olditem->{'holdingbranch'}, $item->{'holdingbranch'});
	my $q_holdingbranch=$dbh->quote($item->{'holdingbranch'});
	my $sth=$dbh->prepare("update items set holdingbranch=$q_holdingbranch where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'l', $olditem->{'holdingbranch'}, $item->{'holdingbranch'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'l', $Subfield_Key, $olditem->{'holdingbranch'}, $item->{'holdingbranch'});
    }
    if ($item->{'price'} ne $olditem->{'price'}) {
	logchange('kohadb', 'change', 'items', 'price', $olditem->{'price'}, $item->{'price'});
	my $q_price=$dbh->quote($item->{'price'});
	my $sth=$dbh->prepare("update items set price=$q_price where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'c', $olditem->{'price'}, $item->{'price'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'c', $Subfield_Key, $olditem->{'price'}, $item->{'price'});
    }
    if ($item->{'itemnotes'} ne $olditem->{'itemnotes'}) {
	logchange('kohadb', 'change', 'items', 'itemnotes', $olditem->{'itemnotes'}, $item->{'itemnotes'});
	my $q_itemnotes=$dbh->quote($item->{'itemnotes'});
	my $sth=$dbh->prepare("update items set itemnotes=$q_itemnotes where itemnumber=$itemnumber");
	$sth->execute;
	my ($Subfield_ID, $Subfield_Key) = changeSubfield($Record_ID, '876', 'c', $olditem->{'itemnotes'}, $item->{'itemnotes'}, $Subfield876_ID);
	logchange('marc', 'change', $Record_ID, '876', 'c', $Subfield_Key, $olditem->{'itemnotes'}, $item->{'itemnotes'});
    }
    if ($item->{'notforloan'} ne $olditem->{'notforloan'}) {
	logchange('kohadb', 'change', 'items', 'notforloan', $olditem->{'notforloan'}, $item->{'notforloan'});
	my $sth=$dbh->prepare("update items set notforloan=$notforloan where itemnumber=$itemnumber");
	$sth->execute;
	if ($item->{'notforloan'}) {
	    my ($Subfield_ID, $Subfield_Key) = addSubfield($Record_ID, '876', 'h', 'Not for loan', $Subfield876_ID);
	    logchange('marc', 'add', $Record_ID, '876', 'h', $Subfield_Key, 'Not for loan');
	} else {
	    my ($Subfield_ID, $Subfield_Key) = deleteSubfield($Record_ID, '876', 'h', 'Not for loan', $Subfield876_ID);
	    logchange('marc', 'delete', $Record_ID, '876', 'h', $Subfield_Key, 'Not for loan');
	}
    }
    if ($item->{'itemlost'} ne $olditem->{'itemlost'}) {
	logchange('kohadb', 'change', 'items', 'itemlost', $olditem->{'itemlost'}, $item->{'itemlost'});
	my $sth=$dbh->prepare("update items set itemlost=$itemlost where itemnumber=$itemnumber");
	$sth->execute;
	if ($item->{'itemlost'}) {
	    my ($Subfield_ID, $Subfield_Key) = addSubfield($Record_ID, '876', 'h', 'Item lost', $Subfield876_ID);
	    logchange('marc', 'add', $Record_ID, '876', 'h', $Subfield_Key, 'Item lost');
	} else {
	    my ($Subfield_ID, $Subfield_Key) = deleteSubfield($Record_ID, '876', 'h', 'Item lost', $Subfield876_ID);
	    logchange('marc', 'delete', $Record_ID, '876', 'h', $Subfield_Key, 'Item lost');
	}
    }
    if ($item->{'wthdrawn'} ne $olditem->{'wthdrawn'}) {
	logchange('kohadb', 'change', 'items', 'wthdrawn', $olditem->{'wthdrawn'}, $item->{'wthdrawn'});
	my $sth=$dbh->prepare("update items set wthdrawn=$wthdrawn where itemnumber=$itemnumber");
	$sth->execute;
	if ($item->{'wthdrawn'}) {
	    my ($Subfield_ID, $Subfield_Key) = addSubfield($Record_ID, '876', 'h', 'Withdrawn', $Subfield876_ID);
	    logchange('marc', 'add', $Record_ID, '876', 'h', $Subfield_Key, 'Withdrawn');
	} else {
	    my ($Subfield_ID, $Subfield_Key) = deleteSubfield($Record_ID, '876', 'h', 'Withdrawn', $Subfield876_ID);
	    logchange('marc', 'delete', $Record_ID, '876', 'h', $Subfield_Key, 'Withdrawn');
	}
    }
    if ($item->{'restricted'} ne $olditem->{'restricted'}) {
	logchange('kohadb', 'change', 'items', 'restricted', $olditem->{'restricted'}, $item->{'restricted'});
	my $sth=$dbh->prepare("update items set restricted=$restricted where itemnumber=$itemnumber");
	$sth->execute;
	if ($item->{'restricted'}) {
	    my ($Subfield_ID, $Subfield_Key) = addSubfield($Record_ID, '876', 'h', 'Restricted', $Subfield876_ID);
	    logchange('marc', 'add', $Record_ID, '876', 'h', $Subfield_Key, 'Restricted');
	} else {
	    my ($Subfield_ID, $Subfield_Key) = deleteSubfield($Record_ID, '876', 'h', 'Restricted', $Subfield876_ID);
	    logchange('marc', 'delete', $Record_ID, '876', 'h', $Subfield_Key, 'Restricted');
	}
    }
    $sth->finish;
}

# Add a biblioitem and related data to Koha database
sub OLD_MAY_BE_DELETED_newcompletebiblioitem {
	use strict;

	my (
	  $dbh,			# DBI handle
	  $biblio,		# hash ref to biblio record
	  $biblioitem,		# hash ref to biblioitem record
	  $subjects,		# list ref of subjects
	  $addlauthors,		# list ref of additional authors
	)=@_ ;

	my ( $biblionumber, $biblioitemnumber, $error);		# return values

	my $debug=0;
	my $sth;
	my $subjectheading;
	my $additionalauthor;

	#--------
    	requireDBI($dbh,"newcompletebiblioitem");

	print "<PRE>Trying to add biblio item Title=$biblio->{title} " .
		"ISBN=$biblioitem->{isbn} </PRE>\n" if $debug;

	# Make sure master biblio entry exists
	($biblionumber,$error)=getoraddbiblio($dbh, $biblio);

        if ( ! $error ) {

	  $biblioitem->{biblionumber}=$biblionumber;

	  # Add biblioitem
	  $biblioitemnumber=newbiblioitem($biblioitem);

	  # Add subjects
	  $sth=$dbh->prepare("insert into bibliosubject
		(biblionumber,subject)
		values (?, ? )" );
	  foreach $subjectheading (@{$subjects} ) {
	      $sth->execute($biblionumber, $subjectheading)
			or $error.=$sth->errstr ;

	  } # foreach subject

	  # Add additional authors
	  $sth=$dbh->prepare("insert into additionalauthors
		(biblionumber,author)
		values (?, ? )");
	  foreach $additionalauthor (@{$addlauthors} ) {
	    $sth->execute($biblionumber, $additionalauthor)
			or $error.=$sth->errstr ;
	  } # foreach author

	} else {
	  # couldn't get biblio
	  $biblionumber='';
	  $biblioitemnumber='';

	} # if no biblio error

	return ( $biblionumber, $biblioitemnumber, $error);

} # sub newcompletebiblioitem

#
#
# END OF UNUSEFUL SUBs
#
#

END { }       # module clean-up code here (global destructor)
