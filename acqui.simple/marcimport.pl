#!/usr/bin/perl


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


my $input = new CGI;
my $dbh=C4Connect;

print $input->header;
print startpage();
print startmenu('acquisitions');
my $file=$input->param('file');

if ($input->param('z3950queue')) {
    my $query=$input->param('query');
    my $type=$input->param('type');
    my @serverlist;
    foreach ($input->param) {
	if (/S-(.*)/) {
	    my $server=$1;
	    if ($server eq 'MAN') {
		push @serverlist, "MAN/".$input->param('manualz3950server')."//";
	    } else {
		my $sth=$dbh->prepare("select host,port,db,userid,password from z3950servers where id=$server");
		$sth->execute;
		my ($host, $port, $db, $userid, $password) = $sth->fetchrow;
		push @serverlist, "$server/$host\:$port/$db/$userid/$password";
	    }
	}
    }
    my $isbnfailed=0;
    if ($type eq 'isbn') {
	my $q=$query;
	$q=~s/[^X\d]//g;
	$q=~s/X.//g;
	if (length($q)==10) {
	    my $checksum=substr($q,9,1);
	    my $isbn=substr($q,0,9);
	    my $i;
	    my $c=0;
	    for ($i=0; $i<9; $i++) {
		my $digit=substr($q,$i,1);
		$c+=$digit*(10-$i);
	    }
	    $c=int(11-($c/11-int($c/11))*11+.1);
	    ($c==10) && ($c='X');
	    if ($c eq $checksum) {
	    } else {
		print "<font color=red size=+1>$query is not a valid ISBN
		Number</font><p>\n";
		$isbnfailed=1;
	    }
	} else {
	    print "<font color=red size=+1>$query is not a valid ISBN
	    Number</font><p>\n";
	    $isbnfailed=1;
	}
    }
    unless ($isbnfailed) {
	my $q_term=$dbh->quote($query);
	my $serverlist='';
	foreach (@serverlist) {
	    $serverlist.="$_ ";
	}
	chop $serverlist;
	my $q_serverlist=$dbh->quote($serverlist);
	my $sth=$dbh->prepare("insert into z3950queue (term,type,servers) values ($q_term, '$type', $q_serverlist)");
	$sth->execute;
    }
}

if (my $data=$input->param('uploadmarc')) {
    my $name=$input->param('name');
    ($name) || ($name=$data);
    my $marcrecord='';
    if (length($data)>0) {
	while (<$data>) {
	    $marcrecord.=$_;
	}
    }
    my $q_marcrecord=$dbh->quote($marcrecord);
    my $q_name=$dbh->quote($name);
    my $sth=$dbh->prepare("insert into uploadedmarc (marc,name) values ($q_marcrecord, $q_name)");
    $sth->execute;
}


if ($input->param('insertnewrecord')) {
    my $isbn=$input->param('isbn');
    my $issn=$input->param('issn');
    my $lccn=$input->param('lccn');
    my $q_origisbn=$dbh->quote($input->param('origisbn'));
    my $q_origissn=$dbh->quote($input->param('origissn'));
    my $q_origlccn=$dbh->quote($input->param('origlccn'));
    my $q_origcontrolnumber=$dbh->quote($input->param('origcontrolnumber'));
    my $q_isbn=$dbh->quote((($isbn) || ('NIL')));
    my $q_issn=$dbh->quote((($issn) || ('NIL')));
    my $q_lccn=$dbh->quote((($lccn) || ('NIL')));
    $sth=$dbh->prepare("insert into marcrecorddone values ($q_origisbn, $q_origissn, $q_origlccn, $q_origcontrolnumber)");
    $sth->execute;
    my $sth=$dbh->prepare("select biblionumber,biblioitemnumber from biblioitems where issn=$q_issn or isbn=$q_isbn or lccn=$q_lccn");
    $sth->execute;
    my $biblionumber=0;
    my $biblioitemnumber=0;
    print "<center>\n";
    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file>New Record</a> | <a href=marcimport.pl>New File</a><br>\n";
    if ($sth->rows) {
	($biblionumber, $biblioitemnumber) = $sth->fetchrow;
	my $title=$input->param('title');
	print << "EOF";
	<table border=0 width=50% cellpadding=10 cellspacing=0>
	<tr><th bgcolor=black><font color=white>Record already in database</font></th></tr>
	<tr><td bgcolor=#dddddd>$title is already in the database with biblionumber $biblionumber and biblioitemnumber $biblioitemnumber</td></tr>
	</table>
	<p>
EOF
    } else {
	my $q_title=$dbh->quote($input->param('title'));
	my $q_subtitle=$dbh->quote($input->param('subtitle'));
	my $q_author=$dbh->quote($input->param('author'));
	my $q_copyrightdate=$dbh->quote($input->param('copyrightdate'));
	my $q_seriestitle=$dbh->quote($input->param('seriestitle'));
	$sth=$dbh->prepare("select biblionumber from biblio where title=$q_title and author=$q_author and copyrightdate=$q_copyrightdate and seriestitle=$q_seriestitle");
	$sth->execute;
	if ($sth->rows) {
	    ($biblionumber) = $sth->fetchrow;
	} else {
	    $sth=$dbh->prepare("select max(biblionumber) from biblio");
	    $sth->execute;
	    ($biblionumber) = $sth->fetchrow;
	    $biblionumber++;
	    $sth=$dbh->prepare("insert into biblio (biblionumber, title, author, copyrightdate, seriestitle) values ($biblionumber, $q_title, $q_author, $q_copyrightdate, $q_seriestitle)");
	    $sth->execute;
	    $sth=$dbh->prepare("insert into bibliosubtitle (biblionumber,subtitle) values ($biblionumber, $q_subtitle)");
	    $sth->execute;
	}
	$sth=$dbh->prepare("select max(biblioitemnumber) from biblioitems");
	$sth->execute;
	($biblioitemnumber) = $sth->fetchrow;
	$biblioitemnumber++;
	my $q_isbn=$dbh->quote($isbn);
	my $q_issn=$dbh->quote($issn);
	my $q_lccn=$dbh->quote($lccn);
	my $q_volume=$dbh->quote($input->param('volume'));
	my $q_number=$dbh->quote($input->param('number'));
	my $q_itemtype=$dbh->quote($input->param('itemtype'));
	my $q_dewey=$dbh->quote($input->param('dewey'));
	my $q_subclass=$dbh->quote($input->param('subclass'));
	my $q_publicationyear=$dbh->quote($input->param('publicationyear'));
	my $q_publishercode=$dbh->quote($input->param('publishercode'));
	my $q_volumedate=$dbh->quote($input->param('volumedate'));
	my $q_volumeddesc=$dbh->quote($input->param('volumeddesc'));
	my $q_illus=$dbh->quote($input->param('illustrator'));
	my $q_pages=$dbh->quote($input->param('pages'));
	my $q_notes=$dbh->quote($input->param('note'));
	my $q_size=$dbh->quote($input->param('size'));
	my $q_place=$dbh->quote($input->param('place'));
	my $q_marc=$dbh->quote($input->param('marc'));

	$sth=$dbh->prepare("insert into biblioitems (biblioitemnumber, biblionumber, volume, number, itemtype, isbn, issn, dewey, subclass, publicationyear, publishercode, volumedate, volumeddesc, illus, pages, notes, size, place, lccn, marc) values ($biblioitemnumber, $biblionumber, $q_volume, $q_number, $q_itemtype, $q_isbn, $q_issn, $q_dewey, $q_subclass, $q_publicationyear, $q_publishercode, $q_volumedate, $q_volumeddesc, $q_illus, $q_pages, $q_notes, $q_size, $q_place, $q_lccn, $q_marc)");
	$sth->execute;
	my $subjectheadings=$input->param('subject');
	my $additionalauthors=$input->param('additionalauthors');
	my @subjectheadings=split(/\n/,$subjectheadings);
	my $subjectheading;
	foreach $subjectheading (@subjectheadings) {
	    # remove any line ending characters (Ctrl-J or M)
	    $subjectheading=~s/\013//g;
	    $subjectheading=~s/\010//g;
	    # convert to upper case
	    $subjectheading=uc($subjectheading);
	    chomp ($subjectheading);
	    while (ord(substr($subjectheading, length($subjectheading)-1, 1))<14) {
		chop $subjectheading;
	    }
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

	my $title=$input->param('title');
	print << "EOF";
	<table cellpadding=10 cellspacing=0 border=0 width=50%>
	<tr><th bgcolor=black><font color=white>Record entered into database</font></th></tr>
	<tr><td bgcolor=#dddddd>$title has been entered into the database with biblionumber
	$biblionumber and biblioitemnumber $biblioitemnumber</td></tr>
	</table>
EOF
    }
    my $title=$input->param('title');
    $sth=$dbh->prepare("select max(barcode) from items");
    $sth->execute;
    my ($barcode) = $sth->fetchrow;
    $barcode++;
    if ($barcode==1) {
	$barcode=int(rand()*1000000);
    }
    print << "EOF";
    <table border=0 cellpadding=10 cellspacing=0>
    <tr><th bgcolor=black><font color=white>
Add a New Item for $title
</font>
</th></tr>
<tr><td bgcolor=#dddddd>
<form>
<input type=hidden name=newitem value=1>
<input type=hidden name=biblionumber value=$biblionumber>
<input type=hidden name=biblioitemnumber value=$biblioitemnumber>
<input type=hidden name=file value=$file>
<table border=0>
<tr><td>BARCODE</td><td><input name=barcode size=10 value=$barcode> Home Branch: <select name=homebranch><option value='STWE'>Stewart Elementary<option value='MEZ'>Meziadin Elementary</select></td></tr>
</tr><td>Replacement Price:</td><td><input name=replacementprice size=10></td></tr>
<tr><td>Notes</td><td><textarea name=notes rows=4 cols=40
wrap=physical></textarea></td></tr>
</table>
</td></tr>
</table>
<p>
<input type=submit value="Add Item">
</form>
EOF
print endmenu();
print endpage();

exit;
}

if ($input->param('newitem')) {
    my $barcode=$input->param('barcode');
    my $q_barcode=$dbh->quote($barcode);
    my $q_notes=$dbh->quote($input->param('notes'));
    my $q_homebranch=$dbh->quote($input->param('homebranch'));
    my $biblionumber=$input->param('biblionumber');
    my $biblioitemnumber=$input->param('biblioitemnumber');
    my $replacementprice=($input->param('replacementprice') || 0);
    my $sth=$dbh->prepare("select barcode from items where
    barcode=$q_barcode");
    $sth->execute;
    if ($sth->rows) {
	print "<font color=red>Barcode '$barcode' has already been assigned.</font><p>\n";
    } else {
	$sth=$dbh->prepare("select max(itemnumber) from items");
	$sth->execute;
	my ($itemnumber) = $sth->fetchrow;
	$itemnumber++;
	my @datearr=localtime(time);
	my $date=(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
	$sth=$dbh->prepare("insert into items (itemnumber, biblionumber, biblioitemnumber, barcode, itemnotes, homebranch, holdingbranch, dateaccessioned, replacementprice) values ($itemnumber, $biblionumber, $biblioitemnumber, $q_barcode, $q_notes, $q_homebranch, 'STWE', '$date', $replacementprice)");
	$sth->execute;
    }
}


my $menu = $input->param('menu');
if ($file) {
    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    my $qisbn=$input->param('isbn');
    my $qissn=$input->param('issn');
    my $qlccn=$input->param('lccn');
    my $qcontrolnumber=$input->param('controlnumber');
    if ($qisbn || $qissn || $qlccn || $qcontrolnumber) {
	print "<a href=$ENV{'SCRIPT_NAME'}>New File</a><hr>\n";
	#open (F, "$file");
	#my $data=<F>;
	my $data;
	if ($file=~/Z-(\d+)/) {
	    my $id=$1;
	    my $resultsid=$input->param('resultsid');
	    my $sth=$dbh->prepare("select results from z3950results where id=$resultsid");
	    $sth->execute;
	    ($data) = $sth->fetchrow;
	} else {
	    my $sth=$dbh->prepare("select marc from uploadedmarc where id=$file");
	    $sth->execute;
	    ($data) = $sth->fetchrow;
	}

	$splitchar=chr(29);
	my @records;
	foreach $record (split(/$splitchar/, $data)) {
	    my $marctext="<table border=0 cellspacing=0>\n";
	    $marctext.="<tr><th colspan=3 bgcolor=black><font color=white>MARC RECORD</font></th></tr>\n";
	    $leader=substr($record,0,24);
	    $marctext.="<tr><td>Leader:</td><td colspan=2>$leader</td></tr>\n";
	    $record=substr($record,24);
	    $splitchar2=chr(30);
	    my $directory=0;
	    my $tagcounter=0;
	    my %tag;
	    my @record;
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
		$splitchar3=chr(31);
		my @subfields=split(/$splitchar3/, $field);
		$indicator=$subfields[0];
		$field{'indicator'}=$indicator;
		my $firstline=1;
		if ($#subfields==0) {
		    $marctext.="<td bgcolor=$color valign=top>$indicator</td></tr>";
		} else {
		    my %subfields;
		    $marctext.="<td bgcolor=$color valign=top><table border=0 cellspacing=0>\n";
		    my $color2=$color;
		    for ($i=1; $i<=$#subfields; $i++) {
			($color2 eq $lc1) ? ($color2=$lc2) : ($color2=$lc1);
			my $text=$subfields[$i];
			my $subfieldcode=substr($text,0,1);
			my $subfield=substr($text,1);
			$marctext.="<tr><td colour=$color2><table border=0 cellpadding=0 cellspacing=0><tr><td>$subfieldcode </td></tr></table></td><td colour=$color2>$subfield</td></tr>\n";
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
		push (@record, \%field);
	    }
	    $marctext.="</table>\n";
	    $marctext{\@record}=$marctext;
	    $marc{\@record}=$record;
	    push (@records, \@record);
	    $counter++;
	}
RECORD:
	foreach $record (@records) {
	    my ($lccn, $isbn, $issn, $dewey, $author, $title, $place, $publisher, $publicationyear, $volume, $number, @subjects, $note, $additionalauthors, $illustrator, $copyrightdate, $seriestitle);
	    my $marctext=$marctext{$record};
	    my $marc=$marc{$record};
	    foreach $field (@$record) {
		if ($field->{'tag'} eq '001') {
		    $controlnumber=$field->{'indicator'};
		}
		if ($field->{'tag'} eq '010') {
		    $lccn=$field->{'subfields'}->{'a'};
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
		    ($isbn=~/^ARRAY/) && ($isbn=$$isbn[0]);
		    $isbn=~s/[^\d]*//g;
		}
		if ($field->{'tag'} eq '022') {
		    $issn=$field->{'subfields'}->{'a'};
		    $issn=~s/^\s*//;
		    ($issn) = (split(/\s+/, $issn))[0];
		}
		if ($field->{'tag'} eq '082') {
		    $dewey=$field->{'subfields'}->{'a'};
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
		if ($field->{'tag'} eq '700') {
		    my $name=$field->{'subfields'}->{'a'};
		    if ($field->{'subfields'}->{'c'}=~/ill/) {
			$additionalauthors.="$name\n";
		    } else {
			$illustrator=$name;
		    }
		}
		if ($field->{'tag'} =~/^5/) {
		    $note.="$field->{'subfields'}->{'a'}\n";
		}
		if ($field->{'tag'} =~/65\d/) {
		    my $subject=$field->{'subfields'}->{'a'};
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
	    $titleinput=$input->textfield(-name=>'title', -default=>$title, -size=>40);
	    $marcinput=$input->hidden(-name=>'marc', -default=>$marc);
	    $subtitleinput=$input->textfield(-name=>'subtitle', -default=>$subtitle, -size=>40);
	    $authorinput=$input->textfield(-name=>'author', -default=>$author);
	    $illustratorinput=$input->textfield(-name=>'illustrator', -default=>$illustrator);
	    $additionalauthorsinput=$input->textarea(-name=>'additionalauthors', -default=>$additionalauthors, -rows=>4, -cols=>20);
	    my $subject='';
	    foreach (@subjects) {
		$subject.="$_\n";
	    }
	    $subjectinput=$input->textarea(-name=>'subject', -default=>$subject, -rows=>4, -cols=>40);
	    $noteinput=$input->textarea(-name=>'note', -default=>$note, -rows=>4, -cols=>40, -wrap=>'physical');
	    $copyrightinput=$input->textfield(-name=>'copyrightdate', -default=>$copyrightdate);
	    $seriestitleinput=$input->textfield(-name=>'seriestitle', -default=>$seriestitle);
	    $volumeinput=$input->textfield(-name=>'volume', -default=>$volume);
	    $volumedateinput=$input->textfield(-name=>'volumedate', -default=>$volumedate);
	    $volumeddescinput=$input->textfield(-name=>'volumeddesc', -default=>$volumeddesc);
	    $numberinput=$input->textfield(-name=>'number', -default=>$number);
	    $isbninput=$input->textfield(-name=>'isbn', -default=>$isbn);
	    $issninput=$input->textfield(-name=>'issn', -default=>$issn);
	    $lccninput=$input->textfield(-name=>'lccn', -default=>$lccn);
	    $isbninput=$input->textfield(-name=>'isbn', -default=>$isbn);
	    $deweyinput=$input->textfield(-name=>'dewey', -default=>$dewey);
	    $cleanauthor=$author;
	    $cleanauthor=~s/[^A-Za-z]//g;
	    $subclassinput=$input->textfield(-name=>'subclass', -default=>uc(substr($cleanauthor,0,3)));
	    $publisherinput=$input->textfield(-name=>'publishercode', -default=>$publisher);
	    $pubyearinput=$input->textfield(-name=>'publicationyear', -default=>$publicationyear);
	    $placeinput=$input->textfield(-name=>'place', -default=>$place);
	    $pagesinput=$input->textfield(-name=>'pages', -default=>$pages);
	    $sizeinput=$input->textfield(-name=>'size', -default=>$size);
	    $fileinput=$input->hidden(-name=>'file', -default=>$file);
	    $origisbn=$input->hidden(-name=>'origisbn', -default=>$isbn);
	    $origissn=$input->hidden(-name=>'origissn', -default=>$issn);
	    $origlccn=$input->hidden(-name=>'origlccn', -default=>$lccn);
	    $origcontrolnumber=$input->hidden(-name=>'origcontrolnumber', -default=>$controlnumber);

	    my $itemtypeselect='';
	    $sth=$dbh->prepare("select itemtype,description from itemtypes");
	    $sth->execute;
	    while (my ($itemtype, $description) = $sth->fetchrow) {
		$itemtypeselect.="<option value=$itemtype>$itemtype - $description\n";
	    }
	    ($qissn) || ($qissn='NIL');
	    ($qlccn) || ($qlccn='NIL');
	    ($qisbn) || ($qisbn='NIL');
	    ($qcontrolnumber) || ($qcontrolnumber='NIL');
	    $controlnumber=~s/\s+//g;
	    unless (($isbn eq $qisbn) || ($issn eq $qissn) || ($lccn eq $qlccn) || ($controlnumber eq $qcontrolnumber)) {
		next RECORD;
	    }

	    print << "EOF";
	    <center>
	    <h1>New Record</h1>
	    Full MARC Record available at bottom
	    <form method=post>
	    <table border=1>
	    <tr><td>Title</td><td>$titleinput</td></tr>
	    <tr><td>Subtitle</td><td>$subtitleinput</td></tr>
	    <tr><td>Author</td><td>$authorinput</td></tr>
	    <tr><td>Additional Authors</td><td>$additionalauthorsinput</td></tr>
	    <tr><td>Illustrator</td><td>$illustratorinput</td></tr>
	    <tr><td>Copyright</td><td>$copyrightinput</td></tr>
	    <tr><td>Series Title</td><td>$seriestitleinput</td></tr>
	    <tr><td>Volume</td><td>$volumeinput</td></tr>
	    <tr><td>Number</td><td>$numberinput</td></tr>
	    <tr><td>Volume Date</td><td>$volumedateinput</td></tr>
	    <tr><td>Volume Description</td><td>$volumeddescinput</td></tr>
	    <tr><td>Subject</td><td>$subjectinput</td></tr>
	    <tr><td>Notes</td><td>$noteinput</td></tr>
	    <tr><td>Item Type</td><td><select name=itemtype>$itemtypeselect</select></td></tr>
	    <tr><td>ISBN</td><td>$isbninput</td></tr>
	    <tr><td>ISSN</td><td>$issninput</td></tr>
	    <tr><td>LCCN</td><td>$lccninput</td></tr>
	    <tr><td>Dewey</td><td>$deweyinput</td></tr>
	    <tr><td>Subclass</td><td>$subclassinput</td></tr>
	    <tr><td>Publication Year</td><td>$pubyearinput</td></tr>
	    <tr><td>Publisher</td><td>$publisherinput</td></tr>
	    <tr><td>Place</td><td>$placeinput</td></tr>
	    <tr><td>Pages</td><td>$pagesinput</td></tr>
	    <tr><td>Size</td><td>$sizeinput</td></tr>
	    </table>
	    <input type=submit>
	    <input type=hidden name=insertnewrecord value=1>
	    $fileinput
	    $marcinput
	    $origisbn
	    $origissn
	    $origlccn
	    $origcontrolnumber
	    </form>
	    $marctext
EOF
	}
    } else {
	#open (F, "$file");
	#my $data=<F>;
	my $data;
	my $name;
	my $z3950=0;
	if ($file=~/Z-(\d+)/) {
	    print << "EOF";
<center>
<p>
<a href=$ENV{'SCRIPT_NAME'}?menu=$menu>Select a New File</a>
<p>
<table border=0 cellpadding=10 cellspacing=0>
<tr><th bgcolor=black><font color=white>Select a Record to Import</font></th></tr>
<tr><td bgcolor=#dddddd>
EOF
	    my $id=$1;
	    my $sth=$dbh->prepare("select servers from z3950queue where id=$id");
	    $sth->execute;
	    my ($servers) = $sth->fetchrow;
	    my $serverstring;
	    foreach $serverstring (split(/\s+/, $servers)) {
		my ($name, $server, $database, $auth) = split(/\//, $serverstring, 4);
		if ($name eq 'MAN') {
		    print "$server/$database<br>\n";
		} elsif ($name eq 'LOC') {
		    print "Library of Congress<br>\n";
		} elsif ($name eq 'NLC') {
		    print "National Library of Canada<br>\n";
		} else {
		    my $sti=$dbh->prepare("select name from
		    z3950servers where id=$name");
		    $sti->execute;
		    my ($longname)=$sti->fetchrow;
		    print "$longname<br>\n";
		}
		print "<ul>\n";
		my $q_server=$dbh->quote($serverstring);
		my $sti=$dbh->prepare("select numrecords,id,results,startdate,enddate from z3950results where queryid=$id and server=$q_server");
		$sti->execute;
		($numrecords,$resultsid,$data,$startdate,$enddate) = $sti->fetchrow;
		if ($sti->rows == 0) {
		    print "pending...";
		} elsif ($enddate == 0) {
		    my $now=time();
		    my $elapsed=$now-$startdate;
		    my $elapsedtime='';
		    if ($elapsed>60) {
			$elapsedtime=sprintf "%d minutes",($elapsed/60);
		    } else {
			$elapsedtime=sprintf "%d seconds",$elapsed;
		    }
		    print "<font color=red>processing... ($elapsedtime)</font>";
		} elsif ($numrecords) {
		    my @records=parsemarcdata($data);
		    foreach $record (@records) {
			my ($lccn, $isbn, $issn, $dewey, $author, $title, $place, $publisher, $publicationyear, $volume, $number, @subjects, $note, $controlnumber);
			foreach $field (@$record) {
			    if ($field->{'tag'} eq '001') {
				$controlnumber=$field->{'indicator'};
			    }
			    if ($field->{'tag'} eq '010') {
				$lccn=$field->{'subfields'}->{'a'};
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
				($isbn=~/ARRAY/) && ($isbn=$$isbn[0]);
				$isbn=~s/[^\d]*//g;
			    }
			    if ($field->{'tag'} eq '022') {
				$issn=$field->{'subfields'}->{'a'};
				$issn=~s/^\s*//;
				($issn) = (split(/\s+/, $issn))[0];
			    }
			    if ($field->{'tag'} eq '100') {
				$author=$field->{'subfields'}->{'a'};
			    }
			    if ($field->{'tag'} eq '245') {
				$title=$field->{'subfields'}->{'a'};
				$title=~s/ \/$//;
				$subtitle=$field->{'subfields'}->{'b'};
				$subtitle=~s/ \/$//;
			    }
			}
			my $q_isbn=$dbh->quote((($isbn) || ('NIL')));
			my $q_issn=$dbh->quote((($issn) || ('NIL')));
			my $q_lccn=$dbh->quote((($lccn) || ('NIL')));
			my $q_controlnumber=$dbh->quote((($controlnumber) || ('NIL')));
			my $sth=$dbh->prepare("select * from marcrecorddone where isbn=$q_isbn or issn=$q_issn or lccn=$q_lccn or controlnumber=$q_controlnumber");
			$sth->execute;
			my $donetext='';
			if ($sth->rows) {
			    $donetext="DONE";
			}
			$sth=$dbh->prepare("select * from biblioitems where isbn=$q_isbn or issn=$q_issn or lccn=$q_lccn");
			$sth->execute;
			if ($sth->rows) {
			    $donetext="DONE";
			}
			($author) && ($author="by $author");
			if ($isbn) {
			    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$file&resultsid=$resultsid&isbn=$isbn>$title$subtitle $author</a> $donetext<br>\n";
			} elsif ($lccn) {
			    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$file&resultsid=$resultsid&lccn=$lccn>$title$subtitle $author</a> $donetext<br>\n";
			} elsif ($issn) {
			    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$file&resultsid=$resultsid&issn=$issn>$title$subtitle $author</a><br> $donetext\n";
			} elsif ($controlnumber) {
			    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$file&resultsid=$resultsid&controlnumber=$controlnumber>$title $author</a><br> $donetext\n";
			} else {
			    print "Error: Contact steve regarding $title by $author<br>\n";
			}
		    }
		    print "<p>\n";
		} else {
		    print "No records returned.<p>\n";
		}
		print "</ul>\n";
	    }
	} else {
	    my $sth=$dbh->prepare("select marc,name from uploadedmarc where id=$file");
	    $sth->execute;
	    ($data, $name) = $sth->fetchrow;
	    print << "EOF";
<center>
<p>
<a href=$ENV{'SCRIPT_NAME'}?menu=$menu>Select a New File</a>
<p>
<table border=0 cellpadding=10 cellspacing=0>
<tr><th bgcolor=black><font color=white>Select a Record to Import<br>from $name</font></th></tr>
<tr><td bgcolor=#dddddd>
EOF
	    
	    my @records=parsemarcdata($data);
	    foreach $record (@records) {
		my ($lccn, $isbn, $issn, $dewey, $author, $title, $place, $publisher, $publicationyear, $volume, $number, @subjects, $note, $controlnumber);
		foreach $field (@$record) {
		    if ($field->{'tag'} eq '001') {
			$controlnumber=$field->{'indicator'};
		    }
		    if ($field->{'tag'} eq '010') {
			$lccn=$field->{'subfields'}->{'a'};
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
			($isbn=~/ARRAY/) && ($isbn=$$isbn[0]);
			$isbn=~s/[^\d]*//g;
		    }
		    if ($field->{'tag'} eq '022') {
			$issn=$field->{'subfields'}->{'a'};
			$issn=~s/^\s*//;
			($issn) = (split(/\s+/, $issn))[0];
		    }
		    if ($field->{'tag'} eq '100') {
			$author=$field->{'subfields'}->{'a'};
		    }
		    if ($field->{'tag'} eq '245') {
			$title=$field->{'subfields'}->{'a'};
			$title=~s/ \/$//;
			$subtitle=$field->{'subfields'}->{'b'};
			$subtitle=~s/ \/$//;
		    }
		}
		my $q_isbn=$dbh->quote((($isbn) || ('NIL')));
		my $q_issn=$dbh->quote((($issn) || ('NIL')));
		my $q_lccn=$dbh->quote((($lccn) || ('NIL')));
		my $q_controlnumber=$dbh->quote((($controlnumber) || ('NIL')));
		my $sth=$dbh->prepare("select * from marcrecorddone where isbn=$q_isbn or issn=$q_issn or lccn=$q_lccn or controlnumber=$q_controlnumber");
		$sth->execute;
		my $donetext='';
		if ($sth->rows) {
		    $donetext="DONE";
		}
		$sth=$dbh->prepare("select * from biblioitems where isbn=$q_isbn or issn=$q_issn or lccn=$q_lccn");
		$sth->execute;
		if ($sth->rows) {
		    $donetext="DONE";
		}
		($author) && ($author="by $author");
		if ($isbn) {
		    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file&isbn=$isbn>$title$subtitle $author</a> $donetext<br>\n";
		} elsif ($lccn) {
		    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file&lccn=$lccn>$title$subtitle $author</a> $donetext<br>\n";
		} elsif ($issn) {
		    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file&issn=$issn>$title$subtitle $author</a><br> $donetext\n";
		} elsif ($controlnumber) {
		    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file&controlnumber=$controlnumber>$title by $author</a><br> $donetext\n";
		} else {
		    print "Error: Contact steve regarding $title by $author<br>\n";
		}
	    }
	}
	print "</td></tr></table>\n";
    }
} else {

SWITCH:
    {
	if ($menu eq 'z3950') { z3950(); last SWITCH; }
	if ($menu eq 'uploadmarc') { uploadmarc(); last SWITCH; }
	if ($menu eq 'manual') { manual(); last SWITCH; }
	mainmenu();
    }

}


sub z3950 {
    $sth=$dbh->prepare("select id,term,type,done,numrecords,length(results),startdate,enddate,servers from z3950queue order by id desc limit 20");
    $sth->execute;
    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    print "<table border=0><tr><td valign=top>\n";
    print "<h2>Results of Z39.50 searches</h2>\n";
    print "<a href=$ENV{'SCRIPT_NAME'}?menu=z3950>Refresh</a><br>\n<ul>\n";
    while (my ($id, $term, $type, $done, $numrecords, $length, $startdate, $enddate, $servers) = $sth->fetchrow) {
	$type=uc($type);
	$term=~s/</&lt;/g;
	$term=~s/>/&gt;/g;
	if ($done == 1) {
	    my $elapsed=$enddate-$startdate;
	    my $elapsedtime='';
	    if ($elapsed>60) {
		$elapsedtime=sprintf "%d minutes",($elapsed/60);
	    } else {
		$elapsedtime=sprintf "%d seconds",$elapsed;
	    }
	    if ($numrecords) {
		print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>$type=$term</a> <font size=-1>Done. $numrecords records found in $elapsedtime.</font><br>\n";
	    } else {
		print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>$type=$term</a> <font size=-1>Done.  No records found.  Search took $elapsedtime.</font><br>\n";
	    }
	} elsif ($done == -1) {
	    my $elapsed=time()-$startdate;
	    my $elapsedtime='';
	    if ($elapsed>60) {
		$elapsedtime=sprintf "%d minutes",($elapsed/60);
	    } else {
		$elapsedtime=sprintf "%d seconds",$elapsed;
	    }
	    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>$type=$term</a> <font color=red size=-1>Processing ($elapsedtime)</font><br>\n";
	} else {
	    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>$type=$term</a> $done <font size=-1>Pending</font><br>\n";
	}
    }
    print "</ul>\n";
    print "</td><td valign=top width=30%>\n";
    my $sth=$dbh->prepare("select id,name,checked from z3950servers order by rank");
    $sth->execute;
    my $serverlist='';
    while (my ($id, $name, $checked) = $sth->fetchrow) {
	($checked) ? ($checked='checked') : ($checked='');
	$serverlist.="<input type=checkbox name=S-$id $checked> $name<br>\n";
    }
    $serverlist.="<input type=checkbox name=S-MAN> <input name=manualz3950server size=25 value=otherserver:210/DATABASE>\n";
    
print << "EOF";
    <form action=$ENV{'SCRIPT_NAME'} method=GET>
    <input type=hidden name=z3950queue value=1>
    <input type=hidden name=menu value=$menu>
    <p>
    <input type=hidden name=test value=testvalue>
    <table border=1 bgcolor=#dddddd><tr><th bgcolor=#bbbbbb colspan=2>Search for MARC records</th></tr>
    <tr><td>Query Term</td><td><input name=query></td></tr>
    <tr><td colspan=2 align=center><input type=radio name=type value=isbn checked> ISBN <input type=radio name=type value=lccn> LCCN <input type=radio name=type value=title> Title</td></tr>
    <tr><td colspan=2>
    $serverlist
    </td></tr>
    <tr><td colspan=2 align=center>
    <input type=submit>
    </td></tr>
    </table>

    </form>
EOF
print "</td></tr></table>\n";
}

sub uploadmarc {
    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    my $sth=$dbh->prepare("select id,name from uploadedmarc");
    $sth->execute;
    print "<h2>Select a set of MARC records</h2>\n<ul>";
    while (my ($id, $name) = $sth->fetchrow) {
	print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$id&menu=$menu>$name</a><br>\n";
    }
    print "</ul>\n";
    print "<p>\n";
    print "<table border=1 bgcolor=#dddddd><tr><th bgcolor=#bbbbbb
    colspan=2>Upload a set of MARC records</th></tr>\n";
    print "<tr><td>Upload a set of MARC records:</td><td>";
    print $input->start_multipart_form();
    print $input->filefield('uploadmarc');
    print << "EOF";
    </td></tr>
    <tr><td>
    <input type=hidden name=menu value=$menu>
    Name this set of MARC records:</td><td><input type=text
    name=name></td></tr>
    <tr><td colspan=2 align=center>
    <input type=submit>
    </td></tr>
    </table>
    </form>
EOF
}

sub manual {
}


sub mainmenu {
    print << "EOF";
<h1>Main Menu</h1>
<ul>
<li><a href=$ENV{'SCRIPT_NAME'}?menu=z3950>Z39.50 Search</a>
<li><a href=$ENV{'SCRIPT_NAME'}?menu=uploadmarc>Upload MARC Records</a>
</ul>
EOF
}

sub skip {

    #opendir(D, "/home/$userid/");
    #my @dirlist=readdir D;
    #foreach $file (@dirlist) {
#	(next) if ($file=~/^\./);
#	(next) if ($file=~/^nsmail$/);
#	(next) if ($file=~/^public_html$/);
#	($file=~/\.mrc/) || ($filelist.="$file<br>\n");
#	(next) unless ($file=~/\.mrc$/);
#	$file=~s/ /\%20/g;
#	print "<a href=$ENV{'SCRIPT_NAME'}?file=/home/$userid/$file>$file</a><br>\n";
#    }


    #<form action=$ENV{'SCRIPT_NAME'} method=POST enctype=multipart/form-data>

}
print endmenu();
print endpage();

sub parsemarcdata {
    my $data=shift;
    my $splitchar=chr(29);
    my @records;
    my $record;
    foreach $record (split(/$splitchar/, $data)) {
	my $leader=substr($record,0,24);
	#print "<tr><td>Leader:</td><td>$leader</td></tr>\n";
	$record=substr($record,24);
	my $splitchar2=chr(30);
	my $directory=0;
	my $tagcounter=0;
	my %tag;
	my @record;
	my $field;
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
	    $splitchar3=chr(31);
	    my @subfields=split(/$splitchar3/, $field);
	    $indicator=$subfields[0];
	    $field{'indicator'}=$indicator;
	    my $firstline=1;
	    unless ($#subfields==0) {
		my %subfields;
		for ($i=1; $i<=$#subfields; $i++) {
		    my $text=$subfields[$i];
		    my $subfieldcode=substr($text,0,1);
		    my $subfield=substr($text,1);
		    if ($subfields{$subfieldcode}) {
			my $subfieldlist=$subfields{$subfieldcode};
			my @subfieldlist=@$subfieldlist;
			if ($#subfieldlist>=0) {
#			print "$tag Adding to array $subfieldcode -- $subfield<br>\n";
			    push (@subfieldlist, $subfield);
			} else {
#			print "$tag Arraying $subfieldcode -- $subfield<br>\n";
			    @subfieldlist=($subfields{$subfieldcode}, $subfield);
			}
			$subfields{$subfieldcode}=\@subfieldlist;
		    } else {
			$subfields{$subfieldcode}=$subfield;
		    }
		}
		$field{'subfields'}=\%subfields;
	    }
	    push (@record, \%field);
	}
	push (@records, \@record);
	$counter++;
    }
    return @records;
}
