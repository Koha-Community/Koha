package C4::Catalogue; #asummes C4/Acquisitions.pm

use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&newBiblio &newBiblioItem &newItem &updateBiblio &updateBiblioItem
	     &updateItem &changeSubfield);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;



sub newBiblio {
# This subroutine makes no modifications to the MARC tables.  MARC records are
# only created when new biblioitems are added.
    my ($env, $biblio) = @_;
    my $title=$biblio->{'title'};
    my $q_title=$dbh->quote($title);
    my $subtitle=$biblio->{'subtitle'};
    my $q_subtitle=$dbh->quote($subtitle);
    ($q_subtitle) || ($q_subtitle="''");
    my $author=$biblio->{'author'};
    my $q_author=$dbh->quote($author);
    my $unititle=$biblio->{'unititle'};
    my $q_unititle=$dbh->quote($unititle);
    my $copyrightdate=$biblio->{'copyrightdate'};
    my $serial=$biblio->{'serial'};
    my $seriestitle=$biblio->{'seriestitle'};
    my $q_seriestitle=$dbh->quote($seriestitle);
    my $notes=$biblio->{'notes'};
    my $q_notes=$dbh->quote($notes);
    my $subject=$biblio->{'subject'};
    my $additionalauthors=$biblio->{'additionalauthors'};
    my $sth=$dbh->prepare("select max(biblionumber) from biblio");
    $sth->execute;
    my ($biblionumber) = $sth->fetchrow;
    $biblionumber++;
    $sth=$dbh->prepare("insert into biblio (biblionumber,title,author,unititle,copyrightdate,serial,seriestitle,notes) values ($biblionumber,$q_title,$q_author,$q_unititle,$copyrightdate,$serial,$q_seriestitle,$q_notes)");
    $sth->execute;
    $sth=$dbh->prepare("insert into bibliosubtitle (biblionumber,subtitle) values ($biblionumber,$q_subtitle)");
    $sth->execute;
    foreach (@$subject) {
	my $q_subject=$dbh->quote($_);
	my $sth=$dbh->prepare("insert into bibliosubject (biblionumber,subject) values ($biblionumber,$q_subject)");
	$sth->execute;
    }
    foreach (@$additionalauthors) {
	my $q_additionalauthor=$dbh->quote($_);
	my $sth=$dbh->prepare("insert into additionalauthors (biblionumber,author) values ($biblionumber,$q_additionalauthor)");
	$sth->execute;
    }
}


sub changeSubfield {
# Subroutine changes a subfield value given a Record_ID, Tag, and Subfield_Mark.
# Routine should be made more robust.  It currently checks to make sure that
# the existing Subfield_Value is the same as the one passed in.  What if no
# subfield matches this Subfield_OldValue?  Create a new Subfield?  Maybe check
# to make sure that the mark is repeatable first and that no other subfield
# with that mark already exists?  Ability to return errors and status?
# 
# Also, currently, if more than one subfield matches the Record_ID, Tag,
# Subfield_Mark, and Subfield_OldValue, only the first one will be modified.
#
# Might be nice to be able to pass a Subfield_ID directly to this routine to
# remove ambiguity, if possible.

    my $Record_ID=shift;
    my $tag=shift;
    my $firstdigit=substr($tag, 0, 1);
    my $Subfield_Mark=shift;
    my $Subfield_OldValue=shift;
    my $Subfield_Value=shift;
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select S.Subfield_ID, S.Subfield_Value from Bib_Table B, $firstdigit\XX_Tag_Table T, $firstdigit\XX_Subfield_Table S where B.Record_ID=$Record_ID and B.Tag_$firstdigit\XX_ID=T.Tag_ID and T.Subfield_ID=S.Subfield_ID and S.Subfield_Mark='$Subfield_Mark'");
    $sth->execute;
    while (my ($ID, $Value) = $sth->fetchrow) {
	if ($Value eq $Subfield_OldValue) {
	    my $q_Subfield_Value=$dbh->quote($Subfield_Value);
	    my $sti=$dbh->prepare("update $firstdigit\XX_Subfield_Table set Subfield_Value=$q_Subfield_Value where Subfield_ID=$ID");
	    $sti->execute;
	    last;
	}
    }
}

sub updateBiblio {
# Update the biblio with biblionumber $biblio->{'biblionumber'}
# I guess this routine should search through all marc records for a record that
# has the same biblionumber stored in it, and modify the MARC record as well as
# the biblio table.
#
# Also, this subroutine should search through the $biblio object and compare it
# to the existing record and _LOG ALL CHANGES MADE_ in some way.  I'd like for
# this logging feature to be usable to undo changes easily.
#
# Need to add support for bibliosubject, additionalauthors, bibliosubtitle tables

    my ($env, $biblio) = @_;
    my $biblionumber=$biblio->{'biblionumber'};
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select * from biblio where biblionumber=$biblionumber");
    $sth->execute;
    my $origbiblio=$sth->fetchrow_hashref;

    
# Obtain a list of MARC Record_ID's that are tied to this biblio
    $sth=$dbh->prepare("select B.Record_ID from Bib_Table B, 0XX_Tag_Table T, 0XX_Subfield_Table S where B.Tag_0XX_ID=T.Tag_ID and T.Subfield_ID=S.Subfield_ID and T.Tag='090' and S.Subfield_Value=$biblionumber and S.Subfield_Mark='c'");
    $sth->execute;
    my @marcrecords;
    while (my ($Record_ID) = $sth->fetchrow) {
	push(@marcrecords, $Record_ID);
    }



    if ($biblio->{'author'} ne $origbiblio->{'author'}) {
	my $q_author=$dbh->quote($biblio->{'author'});
	logchange('kohadb', 'biblio', 'author', $origbiblio->{'author'}, $biblio->{'author'});
	my $sti=$dbh->prepare("update biblio set author=$q_author where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	logchange('marc', '100', 'a', $origbiblio->{'author'}, $biblio->{'author'});
	foreach (@marcrecords) {
	    changeSubfield($_, '100', 'a', $origbiblio->{'author'}, $biblio->{'author'});
	}
    }
    if ($biblio->{'title'} ne $origbiblio->{'title'}) {
	my $q_title=$dbh->quote($biblio->{'title'});
	logchange('kohadb', 'biblio', 'title', $origbiblio->{'title'}, $biblio->{'title'});
	my $sti=$dbh->prepare("update biblio set title=$q_title where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	logchange('marc', '245', 'a', $origbiblio->{'title'}, $biblio->{'title'});
	foreach (@marcrecords) {
	    changeSubfield($_, '245', 'a', $origbiblio->{'title'}, $biblio->{'title'});
	}
    }
    if ($biblio->{'unititle'} ne $origbiblio->{'unititle'}) {
	my $q_unititle=$dbh->quote($biblio->{'unititle'});
	logchange('kohadb', 'biblio', 'unititle', $origbiblio->{'unititle'}, $biblio->{'unititle'});
	my $sti=$dbh->prepare("update biblio set unititle=$q_unititle where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
    }
    if ($biblio->{'notes'} ne $origbiblio->{'notes'}) {
	my $q_notes=$dbh->quote($biblio->{'notes'});
	logchange('kohadb', 'biblio', 'notes', $origbiblio->{'notes'}, $biblio->{'notes'});
	my $sti=$dbh->prepare("update biblio set notes=$q_notes where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	logchange('marc', '500', 'a', $origbiblio->{'notes'}, $biblio->{'notes'});
	foreach (@marcrecords) {
	    changeSubfield($_, '500', 'a', $origbiblio->{'notes'}, $biblio->{'notes'});
	}
    }
    if ($biblio->{'serial'} ne $origbiblio->{'serial'}) {
	my $q_serial=$dbh->quote($biblio->{'serial'});
	logchange('kohadb', 'biblio', 'serial', $origbiblio->{'serial'}, $biblio->{'serial'});
	my $sti=$dbh->prepare("update biblio set serial=$q_serial where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
    }
    if ($biblio->{'seriestitle'} ne $origbiblio->{'seriestitle'}) {
	my $q_seriestitle=$dbh->quote($biblio->{'seriestitle'});
	logchange('kohadb', 'biblio', 'seriestitle', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	my $sti=$dbh->prepare("update biblio set seriestitle=$q_seriestitle where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	logchange('marc', '440', 'a', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	foreach (@marcrecords) {
	    changeSubfield($_, '440', 'a', $origbiblio->{'seriestitle'}, $biblio->{'seriestitle'});
	}
    }
    if ($biblio->{'copyrightdate'} ne $origbiblio->{'copyrightdate'}) {
	my $q_copyrightdate=$dbh->quote($biblio->{'copyrightdate'});
	logchange('kohadb', 'biblio', 'copyrightdate', $origbiblio->{'copyrightdate'}, $biblio->{'copyrightdate'});
	my $sti=$dbh->prepare("update biblio set copyrightdate=$q_copyrightdate where biblionumber=$biblio->{'biblionumber'}");
	$sti->execute;
	logchange('marc', '260', 'c', "c$origbiblio->{'notes'}", "c$biblio->{'notes'}");
	foreach (@marcrecords) {
	    changeSubfield($_, '260', 'c', "c$origbiblio->{'notes'}", "c$biblio->{'notes'}");
	}
    }
}

sub logchange {
# Subroutine to log changes to databases
    my $database=shift;
    my $section=shift;
    my $item=shift;
    my $original=shift;
    my $new=shift;
}

sub addTag {
# Subroutine to add a tag to an existing MARC Record.  If a new linkage id is
# desired, set $env->{'linkage'} to 1.  If an existing linkage id should be
# set, set $env->{'linkid'} to the link number.
    my ($env, $Record_ID, $tag, $Indicator1, $Indicator2, $subfields) = @_;
    my $dbh=&C4Connect;  
    ($Indicator1) || ($Indicator1=' ');
    ($Indicator2) || ($Indicator2=' ');
    my $firstdigit=substr($tag,0,1);
    my $Subfield_ID;
    foreach (sort keys %$subfields) {
	my $Subfield_Mark=$subfields->{$_}->{'Subfield_Mark'};
	my $Subfield_Value=$subfields->{$_}->{'Subfield_Value'};
	my $q_Subfield_Value=$dbh->quote($Subfield_Value);
	if ($Subfield_ID) {
	    my $sth=$dbh->prepare("insert into $firstdigit\XX_Subfield_Table (Subfield_ID, Subfield_Mark, Subfield_Value) values ($Subfield_ID, '$Subfield_Mark', $q_Subfield_Value)");
	    $sth->execute;
	} else {
	    my $sth=$dbh->prepare("insert into $firstdigit\XX_Subfield_Table (Subfield_Mark, Subfield_Value) values ('$Subfield_Mark', $q_Subfield_Value)");
	    $sth->execute;
	    my $Subfield_Key=$dbh->{'mysql_insertid'};
	    $Subfield_ID=$Subfield_Key;
	    $sth=$dbh->prepare("update $firstdigit\XX_Subfield_Table set Subfield_ID=$Subfield_ID where Subfield_Key=$Subfield_Key");
	    $sth->execute;
	}
    }
    if (my $linkid=$env->{'linkid'}) {
	$env->{'linkage'}=0;
	my $sth=$dbh->prepare("insert into $firstdigit\XX_Subfield_Table (Subfield_ID, Subfield_Mark, Subfield_Value) values ($Subfield_ID, '8', '$linkid')");
	$sth->execute;
    }
    my $sth=$dbh->prepare("insert into $firstdigit\XX_Tag_Table (Indicator1, Indicator2, Tag, Subfield_ID) values ('$Indicator1', '$Indicator2', '$tag', $Subfield_ID)");
    $sth->execute;
    my $Tag_Key=$dbh->{'mysql_insertid'};
    my $Tag_ID=$Tag_Key;
    $sth=$dbh->prepare("update $firstdigit\XX_Tag_Table set Tag_ID=$Tag_ID where Tag_Key=$Tag_Key");
    $sth->execute;
    $sth=$dbh->prepare("insert into Bib_Table (Record_ID, Tag_$firstdigit\XX_ID) values ($Record_ID, $Tag_ID)");
    $sth->execute;
    if ($env->{'linkage'}) {
	my $sth=$dbh->prepare("insert into $firstdigit\XX_Subfield_Table (Subfield_ID, Subfield_Mark, Subfield_Value) values ($Subfield_ID, '8', '$Tag_ID')");
	$sth->execute;
	
    }
    $sth->finish;
    $dbh->disconnect;
    return ($env, $Tag_ID);
}

sub newBiblioItem {
    my ($env, $biblioitem) = @_;
    my $dbh=&C4Connect;  
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
	$sth=$dbh->prepare("insert into biblioitems (biblionumber,biblioitemnumber,volume,number,classification,itemtype,isbn,issn,dewey,subclass,publicationyear,publishercode,volumedate,illus,pages,notes,size,place,lccn) values ($biblionumber, $biblioitemnumber, $q_volume, $q_number, $q_classification, $q_itemtype, $q_isbn, $q_issn, $dewey, $q_subclass, $q_publicationyear, $q_publishercode, $q_volumedate, $q_illus, $q_pages,$q_notes, $q_size, $q_place, $q_lccn)");
	$sth->execute;
	#my $sth=$dbh->prepare("unlock tables");
	#$sth->execute;
    }


# Should we check if there is already a biblioitem/marc with the
# same isbn/lccn/issn?

    $sth=$dbh->prepare("select title,unititle,seriestitle,copyrightdate,notes,author from biblio where biblionumber=$biblionumber");
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
	my $tag='440';
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
    $dbh->disconnect;
    return ($env, $Record_ID);
}

sub updateBiblioItem {
# Update the biblioitem with biblioitemnumber $biblioitem->{'biblioitemnumber'}
# This routine should also modify the corresponding MARC record data.
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $biblioitem) = @_;
}


sub newItem {
    my ($env, $Record_ID, $item) = @_;
    my $barcode=$item->{'barcode'};
    my $dateaccessioned=$item->{'dateaccessioned'};
    my $booksellerid=$item->{'booksellerid'};
    my $homebranch=$item->{'homebranch'};
    my $holdingbranch=$item->{'holdingbranch'};
    my $price=$item->{'price'};
    my $replacementprice=$item->{'replacementprice'};
    my $replacementpricedate=$item->{'replacementpricedate'};
    my $notforloan=$item->{'notforloan'};
    my $itemlost=$item->{'itemlost'};
    my $wthdrawn=$item->{'wthdrawn'};
    my $restricted=$item->{'restricted'};
    my $itemnotes=$item->{'itemnotes'};
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

sub updateItem {
# Update the item with itemnumber $item->{'itemnumber'}
# This routine should also modify the corresponding MARC record data. (852 and
# 876 tags with 876p tag the same as $item->{'barcode'}
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $item) = @_;
}

END { }       # module clean-up code here (global destructor)
