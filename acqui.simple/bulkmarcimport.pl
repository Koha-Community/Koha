#!/usr/bin/perl
#
# Tool for importing bulk marc records
#
# WARNING!!
#
# Do not use this script on a production system, it is still in development
#
#




$file=$ARGV[0];

unless ($file) {
    print "USAGE: ./bulkmarcimport.pl filename\n";
    exit;
}




my $lc1='#dddddd';
my $lc2='#ddaaaa';


use C4::Database;
use CGI;
use DBI;
#use strict;
use C4::Acquisitions;
use C4::Output;
my $dbh=C4Connect;
my $userid=$ENV{'REMOTE_USER'};
%tagtext = (
    '001' => 'Control number',
    '003' => 'Control number identifier',
    '005' => 'Date and time of latest transaction',
    '006' => 'Fixed-length data elements -- additional material characteristics',
    '007' => 'Physical description fixed field',
    '008' => 'Fixed length data elements',
    '010' => 'LCCN',
    '015' => 'LCCN Cdn',
    '020' => 'ISBN',
    '022' => 'ISSN',
    '037' => 'Source of acquisition',
    '040' => 'Cataloging source',
    '041' => 'Language code',
    '043' => 'Geographic area code',
    '050' => 'Library of Congress call number',
    '060' => 'National Library of Medicine call number',
    '082' => 'Dewey decimal call number',
    '100' => 'Main entry -- Personal name',
    '110' => 'Main entry -- Corporate name',
    '130' => 'Main entry -- Uniform title',
    '240' => 'Uniform title',
    '245' => 'Title statement',
    '246' => 'Varying form of title',
    '250' => 'Edition statement',
    '256' => 'Computer file characteristics',
    '260' => 'Publication, distribution, etc.',
    '263' => 'Projected publication date',
    '300' => 'Physical description',
    '306' => 'Playing time',
    '440' => 'Series statement / Added entry -- Title',
    '490' => 'Series statement',
    '500' => 'General note',
    '504' => 'Bibliography, etc. note',
    '505' => 'Formatted contents note',
    '508' => 'Creation/production credits note',
    '510' => 'Citation/references note',
    '511' => 'Participant or performer note',
    '520' => 'Summary, etc. note',
    '521' => 'Target audience note (ie age)',
    '530' => 'Additional physical form available note',
    '538' => 'System details note',
    '586' => 'Awards note',
    '600' => 'Subject added entry -- Personal name',
    '610' => 'Subject added entry -- Corporate name',
    '650' => 'Subject added entry -- Topical term',
    '651' => 'Subject added entry -- Geographic name',
    '656' => 'Index term -- Occupation',
    '700' => 'Added entry -- Personal name',
    '710' => 'Added entry -- Corporate name',
    '730' => 'Added entry -- Uniform title',
    '740' => 'Added entry -- Uncontrolled related/analytical title',
    '800' => 'Series added entry -- Personal name',
    '830' => 'Series added entry -- Uniform title',
    '852' => 'Location',
    '856' => 'Electronic location and access',
);


my $dbh=C4Connect;
if ($file) {
    open (F, "$file");
    my $data=<F>;
    close F;
    $splitchar=chr(29);
RECORD:
    foreach $record (split(/$splitchar/, $data)) {
	my $marctext="<table border=0 cellspacing=0>\n";
	$marctext.="<tr><th colspan=3 bgcolor=black><font color=white>MARC RECORD</font></th></tr>\n";
	$leader=substr($record,0,24);
	$marctext.="<tr><td>Leader:</td><td colspan=2>$leader</td></tr>\n";
	print "\n\n---------------------------------------------------------------------------\n";
	print "Leader: $leader\n";
	$record=substr($record,24);
	$splitchar2=chr(30);
	my $directory=0;
	my $tagcounter=0;
	my %tag;
	my @record;
	my %record;
	foreach $field (split(/$splitchar2/, $record)) {
	    my %field;
	    ($color eq $lc1) ? ($color=$lc2) : ($color=$lc1);
	    unless ($directory) {
		$directory=$field;
		my $itemcounter=1;
		$counter=0;
		while ($item=substr($directory,0,12)) {
		    $tag=substr($directory,0,3);
		    $length=substr($directory,3,4);
		    $start=substr($directory,7,6);
		    $directory=substr($directory,12);
		    $tag{$counter}=$tag;
		    $counter++;
		}
		$directory=1;
		next;
	    }
	    $tag=$tag{$tagcounter};
	    $tagcounter++;
	    $field{'tag'}=$tag;
	    $marctext.="<tr><td bgcolor=$color valign=top>$tagtext{$tag}</td><td bgcolor=$color valign=top>$tag</td>";
	    printf "%4s %-40s ",$tag, $tagtext{$tag};
	    $splitchar3=chr(31);
	    my @subfields=split(/$splitchar3/, $field);
	    $indicator=$subfields[0];
	    $field{'indicator'}=$indicator;
	    my $firstline=1;
	    if ($#subfields==0) {
		$marctext.="<td bgcolor=$color valign=top>$indicator</td></tr>";
		print "$indicator\n";
	    } else {
		print "\n";
		my %subfields;
		$marctext.="<td bgcolor=$color valign=top><table border=0 cellspacing=0>\n";
		my $color2=$color;
		for ($i=1; $i<=$#subfields; $i++) {
		    ($color2 eq $lc1) ? ($color2=$lc2) : ($color2=$lc1);
		    my $text=$subfields[$i];
		    my $subfieldcode=substr($text,0,1);
		    my $subfield=substr($text,1);
		    $marctext.="<tr><td colour=$color2><table border=0 cellpadding=0 cellspacing=0><tr><td>$subfieldcode </td></tr></table></td><td colour=$color2>$subfield</td></tr>\n";
		    print "   $subfieldcode $subfield\n";
		    if ($subfields{$subfieldcode}) {
			my $subfieldlist=$subfields{$subfieldcode};
			my @subfieldlist=@$subfieldlist;
			if ($#subfieldlist>=0) {
			    push (@subfieldlist, $subfield);
			} else {
			    @subfieldlist=($subfields{$subfieldcode}, $subfield);
			}
			$subfields{$subfieldcode}=\@subfieldlist;
		    } else {
			$subfields{$subfieldcode}=$subfield;
		    }
		}
		$marctext.="</table></td></tr>\n";
		$field{'subfields'}=\%subfields;
	    }
	    if ($record{$tag}) {
		my $fieldlist=$record{$tag};
		if ($fieldlist->{'tag'}) {
		    @fieldlist=($fieldlist, \%field);
		    $fieldlist=\@fieldlist;
		} else {
		    push (@$fieldlist,\%field);
		}
		$record{$tag}=$fieldlist;
	    } else {
		$record{$tag}=[\%field];
	    }
	    push (@record, \%field);
	}
	$marctext.="</table>\n";
	$rec=\@record;
	$counter++;
	my ($lccn, $isbn, $issn, $dewey, $author, $title, $place, $publisher, $publicationyear, $volume, $number, @subjects, $note, $additionalauthors, $illustrator, $copyrightdate, $barcode, $itemtype, $seriestitle, @barcodes);
	my $marc=$record;
	foreach $field (sort {$a->{'tag'} cmp $b->{'tag'}} @$rec) {
	    #print $field->{'tag'}." ".$field->{'subfields'}->{'a'}."\n";
	    if ($field->{'tag'} eq '010') {
		$lccn=$field->{'subfields'}->{'a'};
		$lccn=~s/^\s*//;
		$lccn=~s/cn //;
		$lccn=~s/^\s*//;
		($lccn) = (split(/\s+/, $lccn))[0];
	    }
	    if ($field->{'tag'} eq '015') {
		$lccn=$field->{'subfields'}->{'a'};
		$lccn=~s/^\s*//;
		$lccn=~s/^C//;
		($lccn) = (split(/\s+/, $lccn))[0];
	    }
	    if ($field->{'tag'} eq '020') {
		$isbn=$field->{'subfields'}->{'a'};
		$isbn=~s/^\s*//;
		($isbn) = (split(/\s+/, $isbn))[0];
	    }
	    if ($field->{'tag'} eq '022') {
		$issn=$field->{'subfields'}->{'a'};
		$issn=~s/^\s*//;
		($issn) = (split(/\s+/, $issn))[0];
	    }
	    if ($field->{'tag'} eq '082') {
		$dewey=$field->{'subfields'}->{'a'};
		print "DEWEY: $dewey\n";
		$dewey=~s/\///g;
		if (@$dewey) {
		    $dewey=$$dewey[0];
		}
		#$dewey=~s/\///g;
	    }
	    if ($field->{'tag'} eq '100') {
		$author=$field->{'subfields'}->{'a'};
	    }
	    if ($field->{'tag'} eq '245') {
		$title=$field->{'subfields'}->{'a'};
		$title=~s/ \/$//;
		$subtitle=$field->{'subfields'}->{'b'};
		$subtitle=~s/ \/$//;
		my $name=$field->{'subfields'}->{'c'};
		if ($name=~/illustrated by]*\s+(.*)/) {
		    $illustrator=$1;
		}
	    }
	    if ($field->{'tag'} eq '260') {
		$place=$field->{'subfields'}->{'a'};
		if (@$place) {
		    $place=$$place[0];
		}
		$place=~s/\s*:$//g;
		$publisher=$field->{'subfields'}->{'b'};
		if (@$publisher) {
		    $publisher=$$publisher[0];
		}
		$publisher=~s/\s*:$//g;
		$publicationyear=$field->{'subfields'}->{'c'};
		if ($publicationyear=~/c(\d\d\d\d)/) {
		    $copyrightdate=$1;
		}
		if ($publicationyear=~/[^c](\d\d\d\d)/) {
		    $publicationyear=$1;
		} elsif ($copyrightdate) {
		    $publicationyear=$copyrightdate;
		} else {
		    $publicationyear=~/(\d\d\d\d)/;
		    $publicationyear=$1;
		}
	    }
	    if ($field->{'tag'} eq '300') {
		$pages=$field->{'subfields'}->{'a'};
		$pages=~s/ \;$//;
		$size=$field->{'subfields'}->{'c'};
		$pages=~s/\s*:$//g;
		$size=~s/\s*:$//g;
	    }
	    if ($field->{'tag'} eq '362') {
		if ($field->{'subfields'}->{'a'}=~/(\d+).*(\d+)/) {
		    $volume=$1;
		    $number=$2;
		}
	    }
	    if ($field->{'tag'} eq '440') {
		$seriestitle=$field->{'subfields'}->{'a'};
		if ($field->{'subfields'}->{'v'}=~/(\d+).*(\d+)/) {
		    $volume=$1;
		    $number=$2;
		}
	    }
	    if ($field->{'tag'} eq '852') {
		$barcode=$field->{'subfields'}->{'p'};
		push (@barcodes, $barcode);
		print "BARCODE: $barcode\n";
		my $q_barcode=$dbh->quote($barcode);
		my $deweyfield=$field->{'subfields'}->{'h'};
		$deweyfield=~/^([\d\.]*)/;
		$dewey=$1;
		if (($deweyfield=~/pbk/) || ($deweyfield=~/pb$/)) {
		    $itemtype='PBK';
		} elsif ($dewey) {
		    $itemtype='JNF';
		} else {
		    $itemtype='JF';
		}

		$replacementprice=$field->{'subfields'}->{'9'};
		#print "BC: $barcode, $title, $author\n";
	    }
	    if ($field->{'tag'} eq '700') {
		my $name=$field->{'subfields'}->{'a'};
		if ($field->{'subfields'}->{'c'}=~/ill/) {
		    $illustrator=$name;
		} else {
		    $additionalauthors.="$name\n";
		}
	    }
	    if ($field->{'tag'} =~/^5/) {
		$note.="$field->{'subfields'}->{'a'}\n";
	    }
	    if ($field->{'tag'} =~/6\d\d/) {
		(next) if ($field->{'tag'} eq '691');
		my $subject=$field->{'subfields'}->{'a'};
		print "SUBJECT: $subject\n";
		$subject=~s/\.$//;
		if ($gensubdivision=$field->{'subfields'}->{'x'}) {
		    my @sub=@$gensubdivision;
		    if ($#sub>=0) {
			foreach $s (@sub) {
			    $s=~s/\.$//;
			    $subject.=" -- $s";
			}
		    } else {
			$gensubdivision=~s/\.$//;
			$subject.=" -- $gensubdivision";
		    }
		}
		if ($chronsubdivision=$field->{'subfields'}->{'y'}) {
		    my @sub=@$chronsubdivision;
		    if ($#sub>=0) {
			foreach $s (@sub) {
			    $s=~s/\.$//;
			    $subject.=" -- $s";
			}
		    } else {
			$chronsubdivision=~s/\.$//;
			$subject.=" -- $chronsubdivision";
		    }
		}
		if ($geosubdivision=$field->{'subfields'}->{'z'}) {
		    my @sub=@$geosubdivision;
		    if ($#sub>=0) {
			foreach $s (@sub) {
			    $s=~s/\.$//;
			    $subject.=" -- $s";
			}
		    } else {
			$geosubdivision=~s/\.$//;
			$subject.=" -- $geosubdivision";
		    }
		}
		push @subjects, $subject;
	    }
	}

	my $q_isbn=$dbh->quote($isbn);
	my $q_issn=$dbh->quote($issn);
	my $q_lccn=$dbh->quote($lccn);
	my $sth=$dbh->prepare("select biblionumber,biblioitemnumber from biblioitems where issn=$q_issn or isbn=$q_isbn or lccn=$q_lccn");
	$sth->execute;
	my $biblionumber=0;
	my $biblioitemnumber=0;
	if ($sth->rows) {
	    ($biblionumber, $biblioitemnumber) = $sth->fetchrow;
	    my $title=$title;
#title already in the database
	} else {
	    my $q_title=$dbh->quote("$title");
	    my $q_subtitle=$dbh->quote("$subtitle");
	    my $q_author=$dbh->quote($author);
	    my $q_copyrightdate=$dbh->quote($copyrightdate);
	    my $q_seriestitle=$dbh->quote($seriestitle);
	    $sth=$dbh->prepare("select biblionumber from biblio where title=$q_title and author=$q_author and copyrightdate=$q_copyrightdate and seriestitle=$q_seriestitle");
	    $sth->execute;
	    if ($sth->rows) {
		($biblionumber) = $sth->fetchrow;
#title already in the database
	    } else {
		$sth=$dbh->prepare("select max(biblionumber) from biblio");
		$sth->execute;
		($biblionumber) = $sth->fetchrow;
		$biblionumber++;
		my $q_notes=$dbh->quote($note);
		$sth=$dbh->prepare("insert into biblio (biblionumber, title, author, copyrightdate, seriestitle, notes) values ($biblionumber, $q_title, $q_author, $q_copyrightdate, $q_seriestitle, $q_notes)");
		$sth->execute;
		$sth=$dbh->prepare("insert into bibliosubtitle values ($q_subtitle, $biblionumber)");
		$sth->execute;
	    }
	    $sth=$dbh->prepare("select max(biblioitemnumber) from biblioitems");
	    $sth->execute;
	    ($biblioitemnumber) = $sth->fetchrow;
	    $biblioitemnumber++;
	    my $q_isbn=$dbh->quote($isbn);
	    my $q_issn=$dbh->quote($issn);
	    my $q_lccn=$dbh->quote($lccn);
	    my $q_volume=$dbh->quote($volume);
	    my $q_number=$dbh->quote($number);
	    my $q_itemtype=$dbh->quote($itemtype);
	    my $q_dewey=$dbh->quote($dewey);
	    $cleanauthor=$author;
	    $cleanauthor=~s/[^A-Za-z]//g;
	    $subclass=uc(substr($cleanauthor,0,3));
	    my $q_subclass=$dbh->quote($subclass);
	    my $q_publicationyear=$dbh->quote($publicationyear);
	    my $q_publishercode=$dbh->quote($publishercode);
	    my $q_volumedate=$dbh->quote($volumedate);
	    my $q_volumeddesc=$dbh->quote($volumeddesc);
	    my $q_illus=$dbh->quote($illustrator);
	    my $q_pages=$dbh->quote($pages);
	    my $q_notes=$dbh->quote($note);
	    ($q_notes) || ($q_notes="''");
	    my $q_size=$dbh->quote($size);
	    my $q_place=$dbh->quote($place);
	    my $q_marc=$dbh->quote($marc);

	    $sth=$dbh->prepare("insert into biblioitems (biblioitemnumber, biblionumber, volume, number, itemtype, isbn, issn, dewey, subclass, publicationyear, publishercode, volumedate, volumeddesc, illus, pages, size, place, lccn, marc) values ($biblioitemnumber, $biblionumber, $q_volume, $q_number, $q_itemtype, $q_isbn, $q_issn, $q_dewey, $q_subclass, $q_publicationyear, $q_publishercode, $q_volumedate, $q_volumeddesc, $q_illus, $q_pages, $q_size, $q_place, $q_lccn, $q_marc)");
	    $sth->execute;
	    my $subjectheading;
	    foreach $subjectheading (@subjects) {
		# convert to upper case
		$subjectheading=uc($subjectheading);
		# quote value
		my $q_subjectheading=$dbh->quote($subjectheading);
		$sth=$dbh->prepare("insert into bibliosubject (biblionumber,subject)
		    values ($biblionumber, $q_subjectheading)");
		$sth->execute;
	    }
	    my @additionalauthors=split(/\n/,$additionalauthors);
	    my $additionalauthor;
	    foreach $additionalauthor (@additionalauthors) {
		# remove any line ending characters (Ctrl-L or Ctrl-M)
		$additionalauthor=~s/\013//g;
		$additionalauthor=~s/\010//g;
		# convert to upper case
		$additionalauthor=uc($additionalauthor);
		# quote value
		my $q_additionalauthor=$dbh->quote($additionalauthor);
		$sth=$dbh->prepare("insert into additionalauthors (biblionumber,author) values ($biblionumber, $q_additionalauthor)");
		$sth->execute;
	    }
	}
	my $q_barcode=$dbh->quote($barcode);
	my $q_homebranch="'MAIN'";
	my $q_notes="''";
	#my $replacementprice=0;
	my $sth=$dbh->prepare("select max(itemnumber) from items");
	$sth->execute;
	my ($itemnumber) = $sth->fetchrow;
	$itemnumber++;
	my @datearr=localtime(time);
	my $date=(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
BARCODE:
	foreach $barcode (@barcodes) {
	    my $q_barcode=$dbh->quote($barcode);
	    my $sti=$dbh->prepare("select barcode from items where barcode=$q_barcode");
	    $sti->execute;
	    if ($sti->rows) {
		print "Skipping $barcode\n";
		next BARCODE;
	    }
	    $replacementprice=~s/^p//;
	    ($replacementprice) || ($replacementprice=0);
	    $replacementprice=~s/\$//;
	    $task="insert into items (itemnumber, biblionumber, biblioitemnumber, barcode, itemnotes, homebranch, holdingbranch, dateaccessioned, replacementprice) values ($itemnumber, $biblionumber, $biblioitemnumber, $q_barcode, $q_notes, $q_homebranch, 'MAIN', '$date', $replacementprice)";
	    $sth=$dbh->prepare($task);
	    print "$task\n";
	    $sth->execute;
	}
    }
}
$dbh->disconnect;
