package C4::Biblio;
# $Id$
# $Log$
# Revision 1.43  2003/04/10 13:56:02  tipaul
# Fix some bugs :
# * worked in 1.9.0, but not in 1.9.1 :
# - modif of a biblio didn't work
# - empty fields where not shown when modifying a biblio. empty fields managed by the library (ie in tab 0->9 in MARC parameter table) MUST be entered, even if not presented.
#
# * did not work before :
# - repeatable subfields now works correctly. Enter 2 subfields separated by | and they will be splitted during saving.
# - dropped the last subfield of the MARC form :-(
#
# Internal changes :
# - MARCmodbiblio now works by deleting and recreating the biblio. It's not perf optimized, but MARC is a "do_something_impossible_to_trace" standard, so, it's the best solution. not a problem for me, as biblio are rarely modified.
# Note the MARCdelbiblio has been rewritted to enable deletion of a biblio WITHOUT deleting items.
#
# Revision 1.42  2003/04/04 08:41:11  tipaul
# last commits before 1.9.1
#
# Revision 1.41  2003/04/01 12:26:43  tipaul
# fixes
#
# Revision 1.40  2003/03/11 15:14:03  tipaul
# pod updating
#
# Revision 1.39  2003/03/07 16:35:42  tipaul
# * moving generic functions to Koha.pm
# * improvement of SearchMarc.pm
# * bugfixes
# * code cleaning
#
# Revision 1.38  2003/02/27 16:51:59  tipaul
# * moving prepare / execute to ? form.
# * some # cleaning
# * little bugfix.
# * road to 1.9.2 => acquisition and cataloguing merging
#
# Revision 1.37  2003/02/12 11:03:03  tipaul
# Support for 000 -> 010 fields.
# Those fields doesn't have subfields.
# In koha, we will use a specific "trick" : fields <10 will have a "virtual" subfield : "@".
# Note it's only virtual : when rebuilding the MARC::Record, the koha API handle correctly "@" subfields => the resulting MARC record has a 00x field without subfield.
#
# Revision 1.36  2003/02/12 11:01:01  tipaul
# Support for 000 -> 010 fields.
# Those fields doesn't have subfields.
# In koha, we will use a specific "trick" : fields <10 will have a "virtual" subfield : "@".
# Note it's only virtual : when rebuilding the MARC::Record, the koha API handle correctly "@" subfields => the resulting MARC record has a 00x field without subfield.
#
# Revision 1.35  2003/02/03 18:46:00  acli
# Minor factoring in C4/Biblio.pm, plus change to export the per-tag
# 'mandatory' property to a per-subfield 'tag_mandatory' template parameter,
# so that addbiblio.tmpl can distinguish between mandatory subfields in a
# mandatory tag and mandatory subfields in an optional tag
#
# Not-minor factoring in acqui.simple/addbiblio.pl to make the if-else blocks
# smaller, and to add some POD; need further testing for this
#
# Added function to check if a MARC subfield name is "koha-internal" (instead
# of checking it for 'lib' and 'tag' everywhere); temporarily added to Koha.pm
#
# Use above function in acqui.simple/additem.pl and search.marc/search.pl
#
# Revision 1.34  2003/01/28 14:50:04  tipaul
# fixing MARCmodbiblio API and reindenting code
#
# Revision 1.33  2003/01/23 12:22:37  tipaul
# adding char_decode to decode MARC21 or UNIMARC extended chars
#
# Revision 1.32  2002/12/16 15:08:50  tipaul
# small but important bugfix (fixes a problem in export)
#
# Revision 1.31  2002/12/13 16:22:04  tipaul
# 1st draft of marc export
#
# Revision 1.30  2002/12/12 21:26:35  tipaul
# YAB ! (Yet Another Bugfix) => related to biblio modif
# (some warning cleaning too)
#
# Revision 1.29  2002/12/12 16:35:00  tipaul
# adding authentification with Auth.pm and
# MAJOR BUGFIX on marc biblio modification
#
# Revision 1.28  2002/12/10 13:30:03  tipaul
# fugfixes from Dombes Abbey work
#
# Revision 1.27  2002/11/19 12:36:16  tipaul
# road to 1.3.2
# various bugfixes, improvments, and migration from acquisition.pm to biblio.pm
#
# Revision 1.26  2002/11/12 15:58:43  tipaul
# road to 1.3.2 :
# * many bugfixes
# * adding value_builder : you can map a subfield in the marc_subfield_structure to a sub stored in "value_builder" directory. In this directory you can create screen used to build values with any method. In this commit is a 1st draft of the builder for 100$a unimarc french subfield, which is composed of 35 digits, with 12 differents values (only the 4th first are provided for instance)
#
# Revision 1.25  2002/10/25 10:58:26  tipaul
# Road to 1.3.2
# * bugfixes and improvements
#
# Revision 1.24  2002/10/24 12:09:01  arensb
# Fixed "no title" warning when generating HTML documentation from POD.
#
# Revision 1.23  2002/10/16 12:43:08  arensb
# Added some FIXME comments.
#
# Revision 1.22  2002/10/15 13:39:17  tipaul
# removing Acquisition.pm
# deleting unused code in biblio.pm, rewriting POD and answering most FIXME comments
#
# Revision 1.21  2002/10/13 11:34:14  arensb
# Replaced expressions of the form "$x = $x <op> $y" with "$x <op>= $y".
# Thus, $x = $x+2 becomes $x += 2, and so forth.
#
# Revision 1.20  2002/10/13 08:28:32  arensb
# Deleted unused variables.
# Removed trailing whitespace.
#
# Revision 1.19  2002/10/13 05:56:10  arensb
# Added some FIXME comments.
#
# Revision 1.18  2002/10/11 12:34:53  arensb
# Replaced &requireDBI with C4::Context->dbh
#
# Revision 1.17  2002/10/10 14:48:25  tipaul
# bugfixes
#
# Revision 1.16  2002/10/07 14:04:26  tipaul
# road to 1.3.1 : viewing MARC biblio
#
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
# The last thing to solve was to manage biblios through real MARC import : they must populate the old-db, but must populate the MARC-DB too, without loosing information (if we go from MARC::Record to old-data then back to MARC::Record, we loose A LOT OF ROWS). To do this, there are subs beginning by "NEWxxx" : they manage datas with MARC::Record datas. they call OLDxxx sub too (to populate old-DB), but MARCxxx subs too, with a complete MARC::Record ;-)
#
# In Biblio.pm, there are some subs that permits to build a old-style record from a MARC::Record, and the opposite. There is also a sub finding a MARC-bibid from a old-biblionumber and the opposite too.
# Note we have decided with steve that a old-biblio <=> a MARC-Biblio.
#


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
#
# don't forget MARCxxx subs are here only for testing purposes. Should not be used
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
	     &getitemtypes &getbiblio
	     &getbiblioitembybiblionumber
	     &getbiblioitem &getitemsbybiblioitem
	     &skip
	     &newcompletebiblioitem

	     &MARCfind_oldbiblionumber_from_MARCbibid
	     &MARCfind_MARCbibid_from_oldbiblionumber
		&MARCfind_marc_from_kohafield
	     &MARCfindsubfield
	     &MARCgettagslib

		&NEWnewbiblio &NEWnewitem
		&NEWmodbiblio &NEWmoditem

	     &MARCaddbiblio &MARCadditem
	     &MARCmodsubfield &MARCaddsubfield
	     &MARCmodbiblio &MARCmoditem
	     &MARCkoha2marcBiblio &MARCmarc2koha
		&MARCkoha2marcItem &MARChtml2marc
	     &MARCgetbiblio &MARCgetitem
	     &MARCaddword &MARCdelword
		&char_decode
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

=item @tagslib = &MARCgettagslib($dbh,1|0);

last param is 1 for liblibrarian and 0 for libopac
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

=item &MARCmodbiblio($dbh,$bibid,$record,$delete);

MARCmodbiblio changes a biblio for a biblio,MARC::Record passed as parameter
if $delete == 1, every field/subfield not found is deleted in the biblio
otherwise, only data passed to MARCmodbiblio is managed.
thus, you can change only a small part of a biblio (like an item, or a subtitle, or a additionalauthor...)

=item ($subfieldid,$subfieldvalue) = &MARCmodsubfield($dbh,$subfieldid,$subfieldvalue);

MARCmodsubfield changes the value of a given subfield

=item $subfieldid = &MARCfindsubfield($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue);

MARCfindsubfield returns a subfield number given a bibid/tag/subfieldvalue values.
Returns -1 if more than 1 answer

=item $subfieldid = &MARCfindsubfieldid($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCfindsubfieldid find a subfieldid for a bibid/tag/tagorder/subfield/subfieldorder

=item &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCdelsubfield delete a subfield for a bibid/tag/tagorder/subfield/subfieldorder

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
	my ($dbh,$forlibrarian)= @_;
	my $sth;
	my $libfield = ($forlibrarian eq 1)? 'liblibrarian' : 'libopac';
	$sth=$dbh->prepare("select tagfield,$libfield as lib,mandatory from marc_tag_structure order by tagfield");
	$sth->execute;
	my ($lib,$tag,$res,$tab,$mandatory,$repeatable);
	while ( ($tag,$lib,$mandatory) = $sth->fetchrow) {
		$res->{$tag}->{lib}=$lib;
		$res->{$tab}->{tab}=""; # XXX
		$res->{$tag}->{mandatory}=$mandatory;
	}

	$sth=$dbh->prepare("select tagfield,tagsubfield,$libfield as lib,tab, mandatory, repeatable,authorised_value,thesaurus_category,value_builder from marc_subfield_structure order by tagfield,tagsubfield");
	$sth->execute;

	my $subfield;
	my $authorised_value;
	my $thesaurus_category;
	my $value_builder;
	while ( ($tag, $subfield, $lib, $tab, $mandatory, $repeatable,$authorised_value,$thesaurus_category,$value_builder) = $sth->fetchrow) {
		$res->{$tag}->{$subfield}->{lib}=$lib;
		$res->{$tag}->{$subfield}->{tab}=$tab;
		$res->{$tag}->{$subfield}->{mandatory}=$mandatory;
		$res->{$tag}->{$subfield}->{repeatable}=$repeatable;
		$res->{$tag}->{$subfield}->{authorised_value}=$authorised_value;
		$res->{$tag}->{$subfield}->{thesaurus_category}=$thesaurus_category;
		$res->{$tag}->{$subfield}->{value_builder}=$value_builder;
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
	my ($dbh,$record,$biblionumber,$bibid) = @_;
	my @fields=$record->fields();
# my $bibid;
# adding main table, and retrieving bibid
# if bibid is sent, then it's not a true add, it's only a re-add, after a delete (ie, a mod)
# if bibid empty => true add, find a new bibid number
	unless ($bibid) {
		$dbh->do("lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ");
		my $sth=$dbh->prepare("insert into marc_biblio (datecreated,biblionumber) values (now(),?)");
		$sth->execute($biblionumber);
		$sth=$dbh->prepare("select max(bibid) from marc_biblio");
		$sth->execute;
		($bibid)=$sth->fetchrow;
		$sth->finish;
	}
	my $fieldcount=0;
	# now, add subfields...
	foreach my $field (@fields) {
		$fieldcount++;
		if ($field->tag() <10) {
				&MARCaddsubfield($dbh,$bibid,
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
	}
	$dbh->do("unlock tables");
	return $bibid;
}

sub MARCadditem {
# pass the MARC::Record to this function, and it will create the records in the marc tables
    my ($dbh,$record,$biblionumber) = @_;
#    warn "adding : ".$record->as_formatted();
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
	my ($dbh,$bibid,$tagid,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalues) = @_;
	# if not value, end of job, we do nothing
	if (length($subfieldvalues) ==0) {
		return;
	}
	if (not($subfieldcode)) {
		$subfieldcode=' ';
	}
	my @subfieldvalues = split /\|/,$subfieldvalues;
	foreach my $subfieldvalue (@subfieldvalues) {
		if (length($subfieldvalue)>255) {
		#	$dbh->do("lock tables marc_blob_subfield WRITE, marc_subfield_table WRITE");
			my $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
			$sth->execute($subfieldvalue);
			$sth=$dbh->prepare("select max(blobidlink)from marc_blob_subfield");
			$sth->execute;
			my ($res)=$sth->fetchrow;
			$sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,valuebloblink) values (?,?,?,?,?,?,?)");
			$sth->execute($bibid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$res);
			if ($sth->errstr) {
				warn "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
			}
	#	$dbh->do("unlock tables");
		} else {
			my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?,?)");
			$sth->execute($bibid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue);
			if ($sth->errstr) {
			warn "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
			}
		}
		&MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	}
}

sub MARCgetbiblio {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
	$record->leader('                   ');
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? order by tag,tagorder,subfieldcode
		 	 ");
	my $sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
	$sth->execute($bibid);
	my $prevtagorder=1;
	my $prevtag='XXX';
	my $previndicator;
	my $field; # for >=10 tags
	my $prevvalue; # for <10 tags
	while (my $row=$sth->fetchrow_hashref) {
		if ($row->{'valuebloblink'}) { #---- search blob if there is one
			$sth2->execute($row->{'valuebloblink'});
			my $row2=$sth2->fetchrow_hashref;
			$sth2->finish;
			$row->{'subfieldvalue'}=$row2->{'subfieldvalue'};
		}
		if ($row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag) {
			$previndicator.="  ";
			if ($prevtag <10) {
   				$record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
			} else {
				$record->add_fields($field);
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
	if ($prevtag <10) {
 		$record->add_fields($prevtag,$prevvalue);
 	} else {
#  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
 		$record->add_fields($field);
 	}
	return $record;
}
sub MARCgetitem {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid,$itemnumber)=@_;
    my $record = MARC::Record->new();
# search MARC tagorder
    my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
    $sth2->execute($bibid,$itemnumber);
    my ($tagorder) = $sth2->fetchrow_array();
#---- TODO : the leader is missing
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? and tagorder=? order by subfieldcode,subfieldorder
		 	 ");
	$sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
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
	my ($dbh,$bibid,$record,$delete)=@_;
	my $oldrecord=&MARCgetbiblio($dbh,$bibid);
	if ($oldrecord eq $record) {
		return;
	}
# 1st delete the biblio,
# 2nd recreate it
	&MARCdelbiblio($dbh,$bibid,1);
	my $biblionumber = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	&MARCaddbiblio($dbh,$record,$biblionumber,$bibid);
}

sub MARCdelbiblio {
	my ($dbh,$bibid,$keep_items) = @_;
# if the keep_item is set to 1, then all items are preserved.
# This flag is set when the delbiblio is called by modbiblio
# due to a too complex structure of MARC (repeatable fields and subfields),
# the best solution for a modif is to delete / recreate the record.
	if ($keep_items eq 1) {
	#search item field code
		my $sth = $dbh->prepare("select tagfield from marc_subfield_structure where kohafield like 'items.%'");
		$sth->execute;
		my $itemtag = $sth->fetchrow_hashref->{tagfield};
		$dbh->do("delete from marc_subfield_table where bibid=$bibid and tag<>$itemtag");
		$dbh->do("delete from marc_word where bibid=$bibid and tag<>$itemtag");
	} else {
		$dbh->do("delete from marc_biblio where bibid=$bibid");
		$dbh->do("delete from marc_subfield_table where bibid=$bibid");
		$dbh->do("delete from marc_word where bibid=$bibid");
	}
}
sub MARCmoditem {
	my ($dbh,$record,$bibid,$itemnumber,$delete)=@_;
	my $oldrecord=&MARCgetitem($dbh,$bibid,$itemnumber);
	# if nothing to change, don't waste time...
	if ($oldrecord eq $record) {
		return;
	}
#	warn "MARCmoditem : ".$record->as_formatted;
#	warn "OLD : ".$oldrecord->as_formatted;

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
#			warn "compare : $oldfield".$oldfield->subfield(@$subfield[0]);
			if ($oldfield eq 0 or (length($oldfield->subfield(@$subfield[0])) ==0) ) {
		# just adding datas...
#		warn "addfield : / $subfieldorder / @$subfield[0] - @$subfield[1]";
#				warn "NEW subfield : $bibid,".$field->tag().",".$tagorder.",".@$subfield[0].",".$subfieldorder.",".@$subfield[1].")";
				&MARCaddsubfield($dbh,$bibid,$field->tag(),$field->indicator(1).$field->indicator(2),
						$tagorder,@$subfield[0],$subfieldorder,@$subfield[1]);
			} else {
#		warn "modfield : / $subfieldorder / @$subfield[0] - @$subfield[1]";
		# modify he subfield if it's a different string
				if ($oldfield->subfield(@$subfield[0]) ne @$subfield[1] ) {
					my $subfieldid=&MARCfindsubfieldid($dbh,$bibid,$field->tag(),$tagorder,@$subfield[0],$subfieldorder);
#					warn "changing : $subfieldid, $bibid,".$field->tag(),",$tagorder,@$subfield[0],@$subfield[1],$subfieldorder";
					&MARCmodsubfield($dbh,$subfieldid,@$subfield[1]);
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
	unless ($res) {
		$sth=$dbh->prepare("select subfieldid from marc_subfield_table
				where bibid=? and tag=? and tagorder=?
					and subfieldcode=?");
		$sth->execute($bibid,$tag,$tagorder,$subfield);
		($res) = $sth->fetchrow;
	}
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

sub MARChtml2marc {
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
	warn $record->as_formatted;
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
	$sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
		$result=&MARCmarc2kohaOneField($sth,"biblioitems",$field,$record,$result);
	}
	$sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
		$result = &MARCmarc2kohaOneField($sth,"items",$field,$record,$result);
	}
	# additional authors : specific
	$result = &MARCmarc2kohaOneField($sth,"additionalauthors","additionalauthors",$record,$result);
	return $result;
}

sub MARCmarc2kohaOneField {
# FIXME ? if a field has a repeatable subfield that is used in old-db, only the 1st will be retrieved...
	my ($sth,$kohatable,$kohafield,$record,$result)= @_;
#    warn "kohatable / $kohafield / $result / ";
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
    my $stopwords= C4::Context->stopwords;
    my $sth=$dbh->prepare("insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word)
			values (?,?,?,?,?,?,soundex(?))");
    foreach my $word (@words) {
# we record only words longer than 2 car and not in stopwords hash
	if (length($word)>1 and !($stopwords->{uc($word)})) {
	    $sth->execute($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		warn "ERROR ==> insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word) values ($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,soundex($word))\n";
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
# NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
#
#
# all the following subs are useful to manage MARC-DB with complete MARC records.
# it's used with marcimport, and marc management tools
#


=item (oldbibnum,$oldbibitemnum) = NEWnewbibilio($dbh,$MARCRecord,$oldbiblio,$oldbiblioitem);

creates a new biblio from a MARC::Record. The 3rd and 4th parameter are hashes and may be ignored. If only 2 params are passed to the sub, the old-db hashes
are builded from the MARC::Record. If they are passed, they are used.

=item NEWnewitem($dbh, $record,$bibid);

adds an item in the db.

=cut

sub NEWnewbiblio {
    my ($dbh, $record, $oldbiblio, $oldbiblioitem) = @_;
# note $oldbiblio and $oldbiblioitem are not mandatory.
# if not present, they will be builded from $record with MARCmarc2koha function
    if (($oldbiblio) and not($oldbiblioitem)) {
	print STDERR "NEWnewbiblio : missing parameter\n";
	print "NEWnewbiblio : missing parameter : contact koha development  team\n";
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
	$olddata->{'biblionumber'} = $oldbibnum;
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
    if ($tagfield1 != $tagfield2) {
	warn "Error in NEWnewbiblio : biblio.biblionumber and biblioitems.biblioitemnumber MUST have the same field number";
 	print "Content-Type: text/html\n\nError in NEWnewbiblio : biblio.biblionumber and biblioitems.biblioitemnumber MUST have the same field number";
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
    return ($bibid,$oldbibnum,$oldbibitemnum );
}

sub NEWmodbiblio {
my ($dbh,$record,$bibid) =@_;
&MARCmodbiblio($dbh,$bibid,$record,0);
my $oldbiblio = MARCmarc2koha($dbh,$record);
my $oldbiblionumber = OLDmodbiblio($dbh,$oldbiblio);
OLDmodbibitem($dbh,$oldbiblio);
return 1;
}


sub NEWnewitem {
	my ($dbh, $record,$bibid) = @_;
	# add item in old-DB
	my $item = &MARCmarc2koha($dbh,$record);
	# needs old biblionumber and biblioitemnumber
	$item->{'biblionumber'} = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
	$sth->execute($item->{'biblionumber'});
	($item->{'biblioitemnumber'}) = $sth->fetchrow;
	my ($itemnumber,$error) = &OLDnewitems($dbh,$item,$item->{barcode});
	# add itemnumber to MARC::Record before adding the item.
	my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
	&MARCkoha2marcOnefield($sth,$record,"items.itemnumber",$itemnumber);
	# add the item
	my $bib = &MARCadditem($dbh,$record,$item->{'biblionumber'});
}

sub NEWmoditem {
	my ($dbh,$record,$bibid,$itemnumber,$delete) = @_;
	&MARCmoditem($dbh,$record,$bibid,$itemnumber,$delete);
	my $olditem = MARCmarc2koha($dbh,$record);
	OLDmoditem($dbh,$olditem);
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
  my ($dbh,$biblio) = @_;
#  my $dbh    = &C4Connect;
  my $query  = "Select max(biblionumber) from biblio";
  my $sth    = $dbh->prepare($query);
  $sth->execute;
  my $data   = $sth->fetchrow_arrayref;
  my $bibnum = $$data[0] + 1;
  my $series = 0;

  if ($biblio->{'seriestitle'}) { $series = 1 };
  $sth->finish;
  $query = "insert into biblio set biblionumber  = ?, title         = ?, author        = ?, copyrightdate = ?,
									serial        = ?, seriestitle   = ?, notes         = ?, abstract      = ?";
  $sth = $dbh->prepare($query);
  $sth->execute($bibnum,$biblio->{'title'},$biblio->{'author'},$biblio->{'copyright'},$series,$biblio->{'seriestitle'},$biblio->{'notes'},$biblio->{'abstract'});

  $sth->finish;
#  $dbh->disconnect;
  return($bibnum);
}

sub OLDmodbiblio {
	my ($dbh,$biblio) = @_;
	#  my $dbh   = C4Connect;
	my $query;
	my $sth;

	$query = "Update biblio set title         = ?, author        = ?, abstract      = ?, copyrightdate = ?,
					seriestitle   = ?, serial        = ?, unititle      = ?, notes         = ? where biblionumber = ?";
	$sth   = $dbh->prepare($query);
	$sth->execute($biblio->{'title'},$biblio->{'author'},$biblio->{'abstract'},$biblio->{'copyrightdate'},
						$biblio->{'seriestitle'},$biblio->{'serial'},$biblio->{'unititle'},$biblio->{'notes'},$biblio->{'biblionumber'});

	$sth->finish;
	return($biblio->{'biblionumber'});
} # sub modbiblio

sub OLDmodsubtitle {
	my ($dbh,$bibnum, $subtitle) = @_;
	my $query = "update bibliosubtitle set subtitle = ? where biblionumber = ?";
	my $sth   = $dbh->prepare($query);
	$sth->execute($subtitle,$bibnum);
	$sth->finish;
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
                        author       = ?,
                        biblionumber = ?";
        $sth   = $dbh->prepare($query);

        $sth->execute($author,$bibnum);

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
          $error .= "<br>$data->{'catalogueentry'}";
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

	$sth->execute;
	$data       = $sth->fetchrow_arrayref;
	$bibitemnum = $$data[0] + 1;

	$sth->finish;

	$sth = $dbh->prepare("insert into biblioitems set
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
									marc		 = ?,				place		 = ?");
	$sth->execute($bibitemnum,							$biblioitem->{'biblionumber'},
						$biblioitem->{'volume'},			$biblioitem->{'number'},
						$biblioitem->{'classification'},		$biblioitem->{'itemtype'},
						$biblioitem->{'url'},					$biblioitem->{'isbn'},
						$biblioitem->{'issn'},				$biblioitem->{'dewey'},
						$biblioitem->{'subclass'},			$biblioitem->{'publicationyear'},
						$biblioitem->{'publishercode'},	$biblioitem->{'volumedate'},
						$biblioitem->{'volumeddesc'},		$biblioitem->{'illus'},
						$biblioitem->{'pages'},				$biblioitem->{'notes'},
						$biblioitem->{'size'},				$biblioitem->{'lccn'},
						$biblioitem->{'marc'},				$biblioitem->{'place'});
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
    my $query = "insert into bibliosubtitle set
                            biblionumber = ?,
                            subtitle = ?";
    my $sth   = $dbh->prepare($query);

    $sth->execute($bibnum,$subtitle);

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

	$sth=$dbh->prepare("Insert into items set
						itemnumber           = ?,				biblionumber         = ?,
						biblioitemnumber     = ?,				barcode              = ?,
						booksellerid         = ?,					dateaccessioned      = NOW(),
						homebranch           = ?,				holdingbranch        = ?,
						price                = ?,						replacementprice     = ?,
						replacementpricedate = NOW(),	itemnotes            = ?,
						notforloan = ?
						");
	$sth->execute($itemnumber,	$item->{'biblionumber'},
							$item->{'biblioitemnumber'},$barcode,
							$item->{'booksellerid'},
							$item->{'homebranch'},$item->{'homebranch'},
							$item->{'price'},$item->{'replacementprice'},
							$item->{'itemnotes'},$item->{'loan'});
	if (defined $sth->errstr) {
		$error .= $sth->errstr;
	}
	$sth->finish;
	return($itemnumber,$error);
}

sub OLDmoditem {
    my ($dbh,$item) = @_;
#  my ($dbh,$loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
#  my $dbh=C4Connect;
$item->{'itemnum'}=$item->{'itemnumber'} unless $item->{'itemnum'};
  my $query="update items set  barcode='$item->{'barcode'}',itemnotes='$item->{'notes'}'
                          where itemnumber=$item->{'itemnum'}";
  if ($item->{'barcode'} eq ''){
    $query="update items set notforloan=$item->{'loan'} where itemnumber=$item->{'itemnum'}";
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
    $query .= "'$temp',";
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
      $query .= "'$temp',";
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

=item getorder

  ($order, $ordernumber) = &getorder($biblioitemnumber, $biblionumber);

Looks up the order with the given biblionumber and biblioitemnumber.

Returns a two-element array. C<$ordernumber> is the order number.
C<$order> is a reference-to-hash describing the order; its keys are
fields from the biblio, biblioitems, aqorders, and aqorderbreakdown
tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to &C4::Catalogue::getorder.
# Pick one and stick with it.
sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select ordernumber
 	from aqorders
 	where biblionumber=? and biblioitemnumber=?";
  my $sth=$dbh->prepare($query);
  $sth->execute($bib,$bi);
  # FIXME - Use fetchrow_array(), since we're only interested in the one
  # value.
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

=item getsingleorder

  $order = &getsingleorder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders, and
aqorderbreakdown tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to
# &C4::Catalogue::getsingleorder.
# Pick one and stick with it.
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

sub newbiblio {
  my ($biblio) = @_;
  my $dbh    = C4::Context->dbh;
  my $bibnum=OLDnewbiblio($dbh,$biblio);
# FIXME : MARC add
  return($bibnum);
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
  return($biblionumber);
# FIXME : MARC mod
} # sub modbiblio

=item modsubtitle

  &modsubtitle($biblionumber, $subtitle);

Sets the subtitle of a book.

C<$biblionumber> is the biblionumber of the book to modify.

C<$subtitle> is the new subtitle.

=cut

sub modsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4::Context->dbh;
  &OLDmodsubtitle($dbh,$bibnum,$subtitle);
} # sub modsubtitle

=item modaddauthor

  &modaddauthor($biblionumber, $author);

Replaces all additional authors for the book with biblio number
C<$biblionumber> with C<$author>. If C<$author> is the empty string,
C<&modaddauthor> deletes all additional authors.

=cut

sub modaddauthor {
    my ($bibnum, $author) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDmodaddauthor($dbh,$bibnum,$author);
} # sub modaddauthor

=item modsubject

  $error = &modsubject($biblionumber, $force, @subjects);

$force - a subject to force

$error - Error message, or undef if successful.

=cut

sub modsubject {
  my ($bibnum, $force, @subject) = @_;
  my $dbh   = C4::Context->dbh;
  my $error= &OLDmodsubject($dbh,$bibnum,$force, @subject);
  return($error);
} # sub modsubject

sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDmodbibitem($dbh,$biblioitem);
    my $MARCbibitem = MARCkoha2marcBiblio($dbh,$biblioitem);
    &MARCmodbiblio($dbh,$biblioitem->{biblionumber},$MARCbibitem,0);
} # sub modbibitem

sub modnote {
  my ($bibitemnum,$note)=@_;
  my $dbh = C4::Context->dbh;
  &OLDmodnote($dbh,$bibitemnum,$note);
}

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

sub newsubject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  &OLDnewsubject($dbh,$bibnum);
}

sub newsubtitle {
    my ($bibnum, $subtitle) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDnewsubtitle($dbh,$bibnum,$subtitle);
}

sub newitems {
  my ($item, @barcodes) = @_;
  my $dbh   = C4::Context->dbh;
  my $errors;
  my $itemnumber;
  my $error;
  foreach my $barcode (@barcodes) {
      ($itemnumber,$error)=&OLDnewitems($dbh,$item,uc($barcode));
      $errors .=$error;
      my $MARCitem = &MARCkoha2marcItem($dbh,$item->{biblionumber},$itemnumber);
      &MARCadditem($dbh,$MARCitem,$item->{biblionumber});
  }
  return($errors);
}

sub moditem {
    my ($item) = @_;
    my $dbh = C4::Context->dbh;
    &OLDmoditem($dbh,$item);
    my $MARCitem = &MARCkoha2marcItem($dbh,$item->{'biblionumber'},$item->{'itemnum'});
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$item->{biblionumber});
    &MARCmoditem($dbh,$MARCitem,$bibid,$item->{itemnum},0);
}

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

sub delitem{
  my ($itemnum)=@_;
  my $dbh = C4::Context->dbh;
  &OLDdelitem($dbh,$itemnum);
}

sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh   = C4::Context->dbh;
    &OLDdeletebiblioitem($dbh,$biblioitemnumber);
} # sub deletebiblioitem


sub delbiblio {
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  &OLDdelbiblio($dbh,$biblio);
}

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
#	print STDERR "KOHA: $type $section $item $original $new\n";
    } elsif ($database eq 'marc') {
	my $type=shift;
	my $Record_ID=shift;
	my $tag=shift;
	my $mark=shift;
	my $subfield_ID=shift;
	my $original=shift;
	my $new=shift;
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
	  $dbh,		# db handle
			# FIXME - Unused argument
	  $biblio,	# hash ref to fields
	)=@_;

	# return
	my $biblionumber;

	my $debug=0;
	my $sth;
	my $error;

	#-----
    	$dbh = C4::Context->dbh;

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

sub char_decode {
	# converts ISO 5426 coded string to ISO 8859-1
	# sloppy code : should be improved in next issue
	my ($string) = @_ ;
	$_ = $string ;
	if (C4::Context->preference("marcflavour") eq "UNIMARC") {
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
	} else {
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
		}
	}
	# this handles non-sorting blocks (if implementation requires this)
	$string = nsb_clean($_) ;
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

