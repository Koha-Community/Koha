package C4::Catalogue; #asummes C4/Acquisitions.pm

# Continue working on updateItem!!!!!!
#
# updateItem is looking not bad.  Need to add addSubfield and deleteSubfield
# functions
#
# Trying to track down $dbh's that aren't disconnected....
#


use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&newBiblio &newBiblioItem &newItem &updateBiblio &updateBiblioItem
	     &updateItem &changeSubfield &addSubfield &findSubfield 
	     &addMarcBiblio

	     &getorders &bookseller &breakdown &basket &newbasket &bookfunds
	     &ordersearch &newbiblio &newbiblioitem &newsubject &newsubtitle &neworder
	     &newordernum &modbiblio &modorder &getsingleorder &invoice &receiveorder
	     &bookfundbreakdown &curconvert &updatesup &insertsup &newitems &modbibitem
	     &getcurrencies &modsubtitle &modsubject &modaddauthor &moditem &countitems 
	     &findall &needsmod &delitem &deletebiblioitem &delbiblio &delorder &branches
	     &getallorders &getrecorders &updatecurrencies &getorder &getcurrency &updaterecorder
	     &updatecost &checkitems &modnote &getitemtypes &getbiblio
	     &getbiblioitembybiblionumber
	     &getbiblioitem &getitemsbybiblioitem &isbnsearch
	     &websitesearch &addwebsite &updatewebsite &deletewebsite);
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
    my $dbh=&C4Connect;  
    my $subject=$biblio->{'subject'};
    my $additionalauthors=$biblio->{'additionalauthors'};

# Why am I doing this?  This is a potential race condition.  At the very least,
# this needs code to ensure that two inserts didn't use the same
# biblionumber...

    # Get next biblio number
    my $sth=$dbh->prepare("select max(biblionumber) from biblio");
    $sth->execute;
    my ($biblionumber) = $sth->fetchrow;
    $biblionumber++;

    $sth=$dbh->prepare("insert into biblio 
	(biblionumber,title,author,
	unititle,copyrightdate,
	serial,seriestitle,notes)
	 values (?, ?, ?, ?, ?, ?, ?, ?)");
    $sth->execute($biblionumber, $biblio->{'title'}, $biblio->{'author'},
        $biblio->{'unititle'}, $biblio->{'copyrightdate'}, 
    	$biblio->{'serial'}, $biblio->{'seriestitle'}, $biblio->{'notes'} );
    $sth=$dbh->prepare("insert into bibliosubtitle 
	(biblionumber,subtitle) 
	values (?,?)");
    $sth->execute($biblionumber, $biblio->{'subtitle'} );

    my $sth=$dbh->prepare("insert into bibliosubject
	(biblionumber,subject)
 	values (?,?) ");
    foreach $_ (@$subject) {
	$sth->execute($biblionumber,$_);
    }
    my $sth=$dbh->prepare("insert into additionalauthors 
	(biblionumber,author)
	 values (?, ?)");
    foreach $_ (@$additionalauthors) {
	$sth->execute($biblionumber, $_ );
    }
}


sub changeSubfield {
# Subroutine changes a subfield value given a subfieldid.
    my ( $subfieldid, $subfieldvalue )=@_;

    my $dbh=&C4Connect;
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
    $dbh->disconnect;
    return($subfieldid, $subfieldvalue);
}

sub findSubfield {
    my ($bibid,$tag,$subfieldcode,$subfieldvalue,$subfieldorder) = @_;
    my $resultcounter=0;
    my $subfieldid;
    my $lastsubfieldid;
    my $dbh=&C4Connect;
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

sub addSubfield {
# Add a new subfield to a tag.
    my $bibid=shift;
    my $tagid=shift;
    my $tagorder=shift;
    my $subfieldcode=shift;
    my $subfieldorder=shift;
    my $subfieldvalue=shift;

    my $dbh=&C4Connect;
    unless ($subfieldorder) {
	my $sth=$dbh->prepare("select max(subfieldorder) from marc_subfield_table where tagid=$tagid");
	$sth->execute;
	if ($sth->rows) {
	    ($subfieldorder) = $sth->fetchrow;
	    $subfieldorder++;
	} else {
	    $subfieldorder=1;
	}
    }
    if (length($subfieldvalue)>255) {
	$dbh->do("lock tables marc_blob_subfield WRITE, marc_subfield_table WRITE");
	my $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
	$sth->execute($subfieldvalue);
	$sth=$dbh->prepare("select max(blobidlink)from marc_blob_subfield");
	$sth->execute;
	my ($res)=$sth->fetchrow;
	my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tagid,tagorder,subfieldcode,subfieldorder,valuebloblink) values (?,?,?,?,?,?)");
	$sth->execute($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$res);
	$dbh->do("unlock tables");
    } else {
	my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?)");
	$sth->execute($bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
    }
}

sub addMarcBiblio {
# pass the marcperlstructure to this function, and it will create the records in the marc tables
    my ($marcstructure) = @_;
    my $dbh=C4Connect;
    my $tags;
    my $i;
    my $j;
    # adding main table, and retrieving bibid
    $dbh->do("lock tables marc_biblio WRITE");
    my $sth=$dbh->prepare("insert into marc_biblio (datecreated,origincode) values (now(),?)");
    $sth->execute($marcstructure->{origincode});
    $sth=$dbh->prepare("select max(bibid) from marc_biblio");
    $sth->execute;
    ($marcstructure->{bibid})=$sth->fetchrow;
    print "BIBID :::".$marcstructure->{bibid}."\n";
    $sth->finish;
    $dbh->do("unlock tables");
    # now, add subfields...
    foreach $tags ($marcstructure->{tags}) {
	foreach $i (keys %{$tags}) {
	    foreach $j (keys %{$tags->{$i}->{subfields}}) {
		&addSubfield($marcstructure->{bibid},
			     $tags->{$i}->{tag},
			     $tags->{$i}->{tagorder},
			     $tags->{$i}->{subfields}->{$j}->{mark},
			     $tags->{$i}->{subfields}->{$j}->{subfieldorder},
			     $tags->{$i}->{subfields}->{$j}->{value}
			     );
		print $tags->{$i}->{tag}."//".$tags->{$i}->{subfields}->{$j}->{value}."\n";
	    }
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

    my ($env, $biblio) = @_;
    my $Record_ID;
    my $biblionumber=$biblio->{'biblionumber'};
    my $dbh=&C4Connect;  
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

sub skip {
# At the moment this is just a straight copy of the subject code.  Needs heavy
# modification to work for additional authors, obviously.
# Check for additional author changes
    
    my $newadditionalauthor='';
    my $additionalauthors;
    foreach $newadditionalauthor (@{$biblio->{'additionalauthor'}}) {
	$additionalauthors->{$newadditionalauthor}=1;
	if ($origadditionalauthors->{$newadditionalauthor}) {
	    $additionalauthors->{$newadditionalauthor}=2;
	} else {
	    my $q_newadditionalauthor=$dbh->quote($newadditionalauthor);
	    my $sth=$dbh->prepare("insert into biblioadditionalauthors (additionalauthor,biblionumber) values ($q_newadditionalauthor, $biblionumber)");
	    $sth->execute;
	    logchange('kohadb', 'add', 'biblio', 'additionalauthor', $newadditionalauthor);
	    my $subfields;
	    $subfields->{1}->{'Subfield_Mark'}='a';
	    $subfields->{1}->{'Subfield_Value'}=$newadditionalauthor;
	    my $tag='650';
	    my $Record_ID;
	    foreach $Record_ID (@marcrecords) {
		addTag($env, $Record_ID, $tag, ' ', ' ', $subfields);
		logchange('marc', 'add', $Record_ID, '650', 'a', $newadditionalauthor);
	    }
	}
    }
    my $origadditionalauthor;
    foreach $origadditionalauthor (keys %$origadditionalauthors) {
	if ($additionalauthors->{$origadditionalauthor} == 1) {
	    my $q_origadditionalauthor=$dbh->quote($origadditionalauthor);
	    logchange('kohadb', 'delete', 'biblio', '$biblionumber', 'additionalauthor', $origadditionalauthor);
	    my $sth=$dbh->prepare("delete from biblioadditionalauthors where biblionumber=$biblionumber and additionalauthor=$q_origadditionalauthor");
	    $sth->execute;
	}
    }

}
    $dbh->disconnect;
}

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
	$sth=$dbh->prepare("insert into biblioitems (biblionumber,biblioitemnumber,volume,number,classification,itemtype,isbn,issn,dewey,subclass,publicationyear,publishercode,volumedate,illus,pages,notes,size,place,lccn) values ($biblionumber, $biblioitemnumber, $q_volume, $q_number, $q_classification, $q_itemtype, $q_isbn, $q_issn, $dewey, $q_subclass, $publicationyear, $q_publishercode, $q_volumedate, $q_illus, $q_pages,$q_notes, $q_size, $q_place, $q_lccn)");
	$sth->execute;
	#my $sth=$dbh->prepare("unlock tables");
	#$sth->execute;
    }


# Should we check if there is already a biblioitem/marc with the
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
    $dbh->disconnect;
    return ($env, $Record_ID);
}

sub updateBiblioItem {
# Update the biblioitem with biblioitemnumber $biblioitem->{'biblioitemnumber'}
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $biblioitem) = @_;
    my $dbh=&C4Connect;  

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
    $dbh->disconnect;

}


sub newItem {
    my ($env, $Record_ID, $item) = @_;
    my $dbh=&C4Connect;  
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

sub updateItem {
# Update the item with itemnumber $item->{'itemnumber'}
# This routine should also modify the corresponding MARC record data. (852 and
# 876 tags with 876p tag the same as $item->{'barcode'}
#
# This routine should also check to see which fields are actually being
# modified, and log all changes.

    my ($env, $item) = @_;
    my $dbh=&C4Connect;  
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
    $dbh->disconnect;
}


sub getorders {
  my ($supplierid)=@_;
  my $dbh=C4Connect;
  my $query = "Select count(*),authorisedby,entrydate,basketno from aqorders where 
  booksellerid='$supplierid' and (quantity > quantityreceived or
  quantityreceived is NULL)
  and (datecancellationprinted is NULL or datecancellationprinted = '0000-00-00')";
  $query.=" group by basketno order by entrydate desc";
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return ($i,\@results);
}

sub itemcount{
  my ($biblio)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from items where biblionumber=$biblio";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub getorder{
  my ($bi,$bib)=@_;
  my $dbh=C4Connect;
  my $query="Select ordernumber from aqorders where biblionumber=$bib and
  biblioitemnumber='$bi'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
  $dbh->disconnect;
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber='$ordnum' 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub invoice {
  my ($invoice)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where
  booksellerinvoicenumber='$invoice'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber group by aqorders.ordernumber,aqorders.biblioitemnumber";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub getallorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and (quantityreceived < quantity or quantityreceived is NULL)
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber
  group by aqorders.biblioitemnumber
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub getrecorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=                    
  aqorders.biblioitemnumber and
  aqorders.quantityreceived>0
  and aqorders.datereceived >=now()
  group by aqorders.biblioitemnumber 
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub ordersearch {
  my ($search,$biblio,$catview) = @_;
  my $dbh   = C4Connect;
  my $query = "Select *,biblio.title from aqorders,biblioitems,biblio
where aqorders.biblioitemnumber = biblioitems.biblioitemnumber
and biblio.biblionumber=aqorders.biblionumber
and ((datecancellationprinted is NULL)
or (datecancellationprinted = '0000-00-00'))
and ((";
  my @data  = split(' ',$search);
  my $count = @data;
  for (my $i = 0; $i < $count; $i++) {
    $query .= "(biblio.title like '$data[$i]%' or biblio.title like '% $data[$i]%') and ";
  }
  $query=~ s/ and $//;
  $query.=" ) or biblioitems.isbn='$search'
  or (aqorders.ordernumber='$search' and aqorders.biblionumber='$biblio')) ";
  if ($catview ne 'yes'){
    $query.=" and (quantityreceived < quantity or quantityreceived is NULL)";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
     my $sth2=$dbh->prepare("Select * from biblio where
     biblionumber='$data->{'biblionumber'}'");
     $sth2->execute;
     my $data2=$sth2->fetchrow_hashref;
     $sth2->finish;
     $data->{'author'}=$data2->{'author'};
     $data->{'seriestitle'}=$data2->{'seriestitle'};
     $sth2=$dbh->prepare("Select * from aqorderbreakdown where
    ordernumber=$data->{'ordernumber'}");
    $sth2->execute;
    $data2=$sth2->fetchrow_hashref;
    $sth2->finish;
    $data->{'branchcode'}=$data2->{'branchcode'};
    $data->{'bookfundid'}=$data2->{'bookfundid'};
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}


sub bookseller {
  my ($searchstring)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqbooksellers where name like '%$searchstring%' or
  id = '$searchstring'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub breakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorderbreakdown where ordernumber='$id'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub basket {
  my ($basketno,$supplier)=@_;
  my $dbh=C4Connect;
  my $query="Select *,biblio.title from aqorders,biblio,biblioitems 
  where basketno='$basketno'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
  =aqorders.biblioitemnumber 
  and (datecancellationprinted is NULL or datecancellationprinted =
  '0000-00-00')";
  if ($supplier ne ''){
    $query.=" and aqorders.booksellerid='$supplier'";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
#  print $query;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub newbasket {
  my $dbh=C4Connect;
  my $query="Select max(basketno) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $basket=$$data[0];
  $basket++;
  $sth->finish;
  $dbh->disconnect;
  return($basket);
}

sub bookfunds {
  my $dbh=C4Connect;
  my $query="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
  =aqbudget.bookfundid
  group by aqbookfund.bookfundid order by bookfundname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub branches {
    my $dbh   = C4Connect;
    my $query = "Select * from branches";
    my $sth   = $dbh->prepare($query);
    my $i     = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$i] = $data;
    	$i++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($i, @results);
} # sub branches

sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select quantity,datereceived,freight,unitprice,listprice,ecost,quantityreceived,subscription
  from aqorders,aqorderbreakdown where bookfundid='$id' and 
  aqorders.ordernumber=aqorderbreakdown.ordernumber
  and (datecancellationprinted is NULL or
  datecancellationprinted='0000-00-00')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $comtd=0;
  my $spent=0;
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'subscription'} == 1){
      $spent+=$data->{'quantity'}*$data->{'unitprice'};
    } else {
      my $leftover=$data->{'quantity'}-$data->{'quantityreceived'};
      $comtd+=($data->{'ecost'})*$leftover;
      $spent+=($data->{'unitprice'})*$data->{'quantityreceived'};
    }
  }
  $sth->finish;
  $dbh->disconnect;
  return($spent,$comtd);
}
      

sub newbiblio {
  my ($biblio) = @_;
  my $dbh    = &C4Connect;
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
  $dbh->disconnect;
  return($bibnum);
}


sub modbiblio {
  my ($biblio) = @_;
  my $dbh   = C4Connect;
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
  $dbh->disconnect;
  return($biblio->{'biblionumber'});
} # sub modbiblio


sub modsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4Connect;
  my $query = "update bibliosubtitle set
subtitle = '$subtitle'
where biblionumber = $bibnum";
  my $sth   = $dbh->prepare($query);

  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
} # sub modsubtitle


sub modaddauthor {
    my ($bibnum, $author) = @_;
    my $dbh   = C4Connect;
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

  $dbh->disconnect;
} # sub modaddauthor


sub modsubject {
  my ($bibnum, $force, @subject) = @_;
  my $dbh   = C4Connect;
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

  $dbh->disconnect;
  return($error);
} # sub modsubject


sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh   = C4Connect;
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

    $dbh->disconnect;
} # sub modbibitem


sub modnote {
  my ($bibitemnum,$note)=@_;
  my $dbh=C4Connect;
  my $query="update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newbiblioitem {
  my ($biblioitem) = @_;
  my $dbh   = C4Connect;
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
  $dbh->disconnect;
  return($bibitemnum);
}

sub newsubject {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="insert into bibliosubject (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4Connect;
  $subtitle = $dbh->quote($subtitle);
  my $query = "insert into bibliosubtitle set
biblionumber = $bibnum,
subtitle = $subtitle";
  my $sth   = $dbh->prepare($query);

  $sth->execute;

  $sth->finish;
  $dbh->disconnect;
}

sub neworder {
  my ($bibnum,$title,$ordnum,$basket,$quantity,$listprice,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$sub,$invoice)=@_;
  if ($budget eq 'now'){
    $budget="now()";
  } else {
    $budget="'2001-07-01'";
  }
  if ($sub eq 'yes'){
    $sub=1;
  } else {
    $sub=0;
  }
  my $dbh=C4Connect;
  my $query="insert into aqorders (biblionumber,title,basketno,
  quantity,listprice,booksellerid,entrydate,requisitionedby,authorisedby,notes,
  biblioitemnumber,rrp,ecost,gst,unitprice,subscription,booksellerinvoicenumber)

  values
  ($bibnum,'$title',$basket,$quantity,$listprice,'$supplier',now(),
  '$who','$who','$notes',$bibitemnum,'$rrp','$ecost','$gst','$cost',
  '$sub','$invoice')";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="select * from aqorders where
  biblionumber=$bibnum and basketno=$basket and ordernumber >=$ordnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $ordnum=$data->{'ordernumber'};
  $query="insert into aqorderbreakdown (ordernumber,bookfundid) values
  ($ordnum,'$bookfund')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub delorder {
  my ($bibnum,$ordnum)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set datecancellationprinted=now()
  where biblionumber='$bibnum' and
  ordernumber='$ordnum'";
  my $sth=$dbh->prepare($query);
  #print $query;
  $sth->execute;
  $sth->finish;
  my $count=itemcount($bibnum);
  if ($count == 0){
    delbiblio($bibnum);
  }
  $dbh->disconnect;
}

sub modorder {
  my ($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$invoice)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set title='$title',
  quantity='$quantity',listprice='$listprice',basketno='$basketno', 
  rrp='$rrp',ecost='$ecost',unitprice='$cost',
  booksellerinvoicenumber='$invoice'
  where
  ordernumber=$ordnum and biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newordernum {
  my $dbh=C4Connect;
  my $query="Select max(ordernumber) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $ordnum=$$data[0];
  $ordnum++;
  $sth->finish;
  $dbh->disconnect;
  return($ordnum);
}

sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set quantityreceived='$quantrec',
  datereceived=now(),booksellerinvoicenumber='$invoiceno',
  biblioitemnumber=$bibitemno,unitprice='$cost',freight='$freight',
  rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}
sub updaterecorder{
  my($biblio,$ordnum,$user,$cost,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set
  unitprice='$cost', rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}

sub curconvert {
  my ($currency,$price)=@_;
  my $dbh=C4Connect;
  my $query="Select rate from currency where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  my $cur=$data->{'rate'};
  if ($cur==0){
    $cur=1;
  }
  my $price=$price / $cur;
  return($price);
}

sub getcurrencies {
  my $dbh=C4Connect;
  my $query="Select * from currency";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
} 

sub getcurrency {
  my ($cur)=@_;
  my $dbh=C4Connect;
  my $query="Select * from currency where currency='$cur'";
  my $sth=$dbh->prepare($query);
  $sth->execute;

  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
} 

sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh=C4Connect;
  my $query="update currency set rate=$rate where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
} 

sub updatesup {
   my ($data)=@_;
   my $dbh=C4Connect;
   my $query="Update aqbooksellers set
   name='$data->{'name'}',address1='$data->{'address1'}',address2='$data->{'address2'}',
   address3='$data->{'address3'}',address4='$data->{'address4'}',postal='$data->{'postal'}',
   phone='$data->{'phone'}',fax='$data->{'fax'}',url='$data->{'url'}',
   contact='$data->{'contact'}',contpos='$data->{'contpos'}',
   contphone='$data->{'contphone'}', contfax='$data->{'contfax'}', contaltphone=
   '$data->{'contaltphone'}', contemail='$data->{'contemail'}', contnotes=
   '$data->{'contnotes'}', active=$data->{'active'},
   listprice='$data->{'listprice'}', invoiceprice='$data->{'invoiceprice'}',
   gstreg=$data->{'gstreg'}, listincgst=$data->{'listincgst'},
   invoiceincgst=$data->{'invoiceincgst'}, specialty='$data->{'specialty'}',
   discount='$data->{'discount'}',invoicedisc='$data->{'invoicedisc'}',
   nocalc='$data->{'nocalc'}'
   where id='$data->{'id'}'";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   $sth->finish;
   $dbh->disconnect;
#   print $query;
}

sub insertsup {
  my ($data)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(id) from aqbooksellers");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $data2->{'max(id)'}++;
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values ($data2->{'max(id)'})");
  $sth->execute;
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  $dbh->disconnect;
  updatesup($data);
  return($data->{'id'});
}


sub newitems {
  my ($item, @barcodes) = @_;
  my $dbh   = C4Connect;
  my $query = "Select max(itemnumber) from items";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $itemnumber;
  my $error;

  $sth->execute;
  $data       = $sth->fetchrow_hashref;
  $itemnumber = $data->{'max(itemnumber)'} + 1;
  $sth->finish;
  
  $item->{'booksellerid'}     = $dbh->quote($item->{'booksellerid'});
  $item->{'homebranch'}       = $dbh->quote($item->{'homebranch'});
  $item->{'price'}            = $dbh->quote($item->{'price'});
  $item->{'replacementprice'} = $dbh->quote($item->{'replacementprice'});
  $item->{'itemnotes'}        = $dbh->quote($item->{'itemnotes'});

  foreach my $barcode (@barcodes) {
    $barcode = uc($barcode);
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
      $query .= ",
notforloan           = $item->{'loan'}";
    } # if

    $sth = $dbh->prepare($query);
    $sth->execute;

    $error .= $sth->errstr;

    $sth->finish;
    $itemnumber++;
  } # for

  $dbh->disconnect;
  return($error);
}

sub checkitems{
  my ($count,@barcodes)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
  return($error);
}

sub moditem {
  my ($loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
  my $dbh=C4Connect;
  my $query="update items set biblioitemnumber=$bibitemnum,
  barcode='$barcode',itemnotes='$notes'
  where itemnumber=$itemnum";
  if ($barcode eq ''){
    $query="update items set biblioitemnumber=$bibitemnum,notforloan=$loan where itemnumber=$itemnum";
  }
  if ($lost ne ''){
    $query="update items set biblioitemnumber=$bibitemnum,
      barcode='$barcode',itemnotes='$notes',homebranch='$homebranch',
      itemlost='$lost',wthdrawn='$wthdrawn' where itemnumber=$itemnum";
  }
  if ($replacement ne ''){
    $query=~ s/ where/,replacementprice='$replacement' where/;
  }

  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub updatecost{
  my($price,$rrp,$itemnum)=@_;
  my $dbh=C4Connect;
  my $query="update items set price='$price',replacementprice='$rrp'
  where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
sub countitems{
  my ($bibitemnum)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from items where biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub findall {
  my ($biblionumber)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems,items,itemtypes where 
  biblioitems.biblionumber=$biblionumber 
  and biblioitems.biblioitemnumber=items.biblioitemnumber and
  itemtypes.itemtype=biblioitems.itemtype
  order by items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub needsmod{
  my ($bibitemnum,$itemtype)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems where biblioitemnumber=$bibitemnum
  and itemtype='$itemtype'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $result=0;
  if (my $data=$sth->fetchrow_hashref){
    $result=1;
  }
  $sth->finish;
  $dbh->disconnect;
  return($result);
}

sub delitem{
  my ($itemnum)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
}
sub deletebiblioitem {
    my ($biblioitemnumber) = @_;
    my $dbh   = C4Connect;
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
    
    $dbh->disconnect;
} # sub deletebiblioitem


sub delbiblio{
  my ($biblio)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
}


sub getitemtypes {
  my $dbh   = C4Connect;
  my $query = "select * from itemtypes";
  my $sth   = $dbh->prepare($query);
    # || die "Cannot prepare $query" . $dbh->errstr;
  my $count = 0;
  my @results;
  
  $sth->execute;
    # || die "Cannot execute $query\n" . $sth->errstr;
  while (my $data = $sth->fetchrow_hashref) {
    @results[$count] = $data;
    $count++;
  } # while
  
  $sth->finish;
  $dbh->disconnect;
  return($count, @results);
} # sub getitemtypes


sub getbiblio {
    my ($biblionumber) = @_;
    my $dbh   = C4Connect;
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
    $dbh->disconnect;
    return($count, @results);
} # sub getbiblio


sub getbiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4Connect;
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
    $dbh->disconnect;
    return($count, @results);
} # sub getbiblioitem


sub getbiblioitembybiblionumber {
    my ($biblionumber) = @_;
    my $dbh   = C4Connect;
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
    $dbh->disconnect;
    return($count, @results);
} # sub


sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4Connect;
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
    $dbh->disconnect;
    return($count, @results);
} # sub getitemsbybiblioitem


sub isbnsearch {
    my ($isbn) = @_;
    my $dbh   = C4Connect;
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
    $dbh->disconnect;
    return($count, @results);
} # sub isbnsearch


sub websitesearch {
    my ($keywordlist) = @_;
    my $dbh   = C4Connect;
    my $query = "Select distinct biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber and (";
    my $count = 0;
    my $sth;
    my @results;
    my @keywords = split(/ +/, $keywordlist);
    my $keyword = shift(@keywords);

    $keyword =~ s/%/\\%/g;
    $keyword =~ s/_/\\_/;
    $keyword = "%" . $keyword . "%";
    $keyword = $dbh->quote($keyword);
    $query  .= " (url like $keyword)";

    foreach $keyword (@keywords) {
        $keyword =~ s/%/\\%/;
	$keyword =~ s/_/\\_/;
	$keyword = "%" . $keyword . "%";
        $keyword = $dbh->quote($keyword);
	$query  .= " or (url like $keyword)";
    } # foreach

    $query .= ")";
    $sth    = $dbh->prepare($query);
    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub websitesearch


sub addwebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'biblionumber'} = $dbh->quote($website->{'biblionumber'});
    $website->{'title'}        = $dbh->quote($website->{'title'});
    $website->{'description'}  = $dbh->quote($website->{'description'});
    $website->{'url'}          = $dbh->quote($website->{'url'});
    
    $query = "Insert into websites set
biblionumber = $website->{'biblionumber'},
title        = $website->{'title'},
description  = $website->{'description'},
url          = $website->{'url'}";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub website


sub updatewebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'title'}      = $dbh->quote($website->{'title'});
    $website->{'description'} = $dbh->quote($website->{'description'});
    $website->{'url'}        = $dbh->quote($website->{'url'});
    
    $query = "Update websites set
title       = $website->{'title'},
description = $website->{'description'},
url         = $website->{'url'}
where websitenumber = $website->{'websitenumber'}";

    $dbh->do($query);
    
    $dbh->disconnect;
} # sub updatewebsite


sub deletewebsite {
    my ($websitenumber) = @_;
    my $dbh = C4Connect;
    my $query = "Delete from websites where websitenumber = $websitenumber";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub deletewebsite

END { }       # module clean-up code here (global destructor)
