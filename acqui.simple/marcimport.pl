#!/usr/bin/perl

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL

use strict;

# standard or CPAN modules used
use CGI;
use DBI;

# Koha modules used
use C4::Database;
use C4::Acquisitions;
use C4::Output;

#------------------
# Constants

# HTML colors for alternating lines
my $lc1='#dddddd';
my $lc2='#ddaaaa';

my %tagtext = (
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

# tag, subfield, field name, repeats, stripchars
my @tagmaplist=(
	['010', 'a', 'lccn',			0 	],
	['015', 'a', 'lccn',			0	],
	['020', 'a', 'isbn',			0	],
	['022', 'a', 'issn',			0	],
	['082', 'a', 'dewey',			0	],
	['100', 'a', 'author',			0	],
	['245', 'a', 'title',			0, ':;'	],
	['245', 'b', 'subtitle',		0	],
	['260', 'a', 'place',			0, ':'	],
	['260', 'b', 'publisher',		0, ':'	],
	['260', 'c', 'year' ,			0	],
	['300', 'a', 'pages',			0, ':;'	],
	['300', 'c', 'size',			0	],
	['362', 'a', 'volume-number',		0	],
	['440', 'a', 'seriestitle',		0	],
	['440', 'v', 'series-volume-number',	0	],
	['700', 'a', 'addtional-author-illus',	1	],
	['5xx', 'a', 'notes',			1	],
	['65x', 'a', 'subject',			1, '.'	],
);
my (
    $tagmap,	# hash ref of mappings
);

#-------------
#-------------
# Initialize

my $userid=$ENV{'REMOTE_USER'};

my $input = new CGI;
my $dbh=C4Connect;

$tagmap=BuildTagMap(@tagmaplist);

#-------------
# Display output
print $input->header;
print startpage();
print startmenu('acquisitions');

#-------------
# Process input parameters

my $file=$input->param('file');
my $menu = $input->param('menu');

if ($input->param('z3950queue')) {
	AcceptZ3950Queue($dbh,$input);
} 

if ($input->param('uploadmarc')) {
	AcceptMarcUpload($dbh,$input)
}

if ($input->param('insertnewrecord')) {
    # Add biblio item, and set up menu for adding item copies
    my ($biblionumber,$biblioitemnumber)=AcceptBiblioitem($dbh,$input);
    ItemCopyForm($dbh,$input,$biblionumber,$biblioitemnumber);
    print endmenu();
    print endpage();
    exit;
}


if ($input->param('newitem')) {
    # Add item copy
    &AcceptItemCopy($dbh,$input);
} # if newitem


if ($file) {
    ProcessFile($dbh,$input);
} else {

SWITCH:
    {
	if ($menu eq 'z3950') { z3950menu($dbh,$input); last SWITCH; }
	if ($menu eq 'uploadmarc') { uploadmarc(); last SWITCH; }
	if ($menu eq 'manual') { manual(); last SWITCH; }
	mainmenu();
    }

}
print endmenu();
print endpage();


sub ProcessFile {
    # A MARC file has been specified; process it for review form
    use strict;

    # Input params
    my (
	$dbh,
	$input,
    )=@_;

    # local vars
    my (
	$sth,
	$record,
    );

    my $debug=0;
    my $splitchar=chr(29);

    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    my $qisbn=$input->param('isbn');
    my $qissn=$input->param('issn');
    my $qlccn=$input->param('lccn');
    my $qcontrolnumber=$input->param('controlnumber');

    # See if a particular result record was specified
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

	my @records;

RECORD:
	foreach $record (split(/$splitchar/, $data)) {

	    my (
		$bib,		# hash ref to named fields
		$fieldlist,	# list ref
		$lccn, $isbn, $issn, $dewey, 
		$publisher, $publicationyear, $volume, 
		$number, @subjects, $notes, $additionalauthors, 
		$copyrightdate, $seriestitle,
		$origisbn, $origissn, $origlccn, $origcontrolnumber,
		$subtitle,
		$controlnumber,
		$cleanauthor,
		$subject,
                $volumedate,
                $volumeddesc,
		$itemtypeselect,
	    );
	    my ($lccninput, $isbninput, $issninput, $deweyinput, $authorinput, $titleinput, 
		$placeinput, $publisherinput, $publicationyearinput, $volumeinput, 
		$numberinput, $notesinput, $additionalauthorsinput, 
		$illustratorinput, $copyrightdateinput, $seriestitleinput,
                $subtitleinput,
                $copyrightinput,
                $volumedateinput,
                $volumeddescinput,
                $subjectinput,
                $noteinput,
                $subclassinput,
                $pubyearinput,
                $pagesinput,
                $sizeinput,
		$marcinput,
		$fileinput,
	    );


	    my $marctext;

	    my $marc=$record;

	    ($fieldlist)=parsemarcfileformat($record );

	    $bib=extractmarcfields($fieldlist );

	    print "Title=$bib->{title}\n" if $debug;

	    $marctext=FormatMarcText($fieldlist);

		$controlnumber		=$bib->{controlnumber};
		$lccn			=$bib->{lccn};
		$isbn			=$bib->{isbn};
		$issn			=$bib->{issn};
		$publisher		=$bib->{publisher};
		$publicationyear	=$bib->{publicationyear};
		$copyrightdate		=$bib->{copyrightdate};
		
		$volume			=$bib->{volume};
		$number			=$bib->{number};
		$seriestitle		=$bib->{seriestitle};
		$additionalauthors	=$bib->{additionalauthors};
		$notes			=$bib->{notes};

	    $titleinput=$input->textfield(-name=>'title', -default=>$bib->{title}, -size=>40);
	    $marcinput=$input->hidden(-name=>'marc', -default=>$marc);
	    $subtitleinput=$input->textfield(-name=>'subtitle', -default=>$bib->{subtitle}, -size=>40);
	    $authorinput=$input->textfield(-name=>'author', -default=>$bib->{author});
	    $illustratorinput=$input->textfield(-name=>'illustrator', 
		-default=>$bib->{illustrator});
	    $additionalauthorsinput=$input->textarea(-name=>'additionalauthors', -default=>$additionalauthors, -rows=>4, -cols=>20);

	    my $subject='';
	    foreach ( @{$bib->{subject} } ) {
		$subject.="$_\n";
	    	print "<PRE>form subject=$subject</PRE>\n" if $debug;
	    }
	    $subjectinput=$input->textarea(-name=>'subject', 
			-default=>$subject, -rows=>4, -cols=>40);

	    $noteinput=$input->textarea(-name=>'notes', 
			-default=>$notes, -rows=>4, -cols=>40, -wrap=>'physical');
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
	    $deweyinput=$input->textfield(-name=>'dewey', -default=>$bib->{dewey});
	    $cleanauthor=$bib->{author};
	    $cleanauthor=~s/[^A-Za-z]//g;
	    $subclassinput=$input->textfield(-name=>'subclass', -default=>uc(substr($cleanauthor,0,3)));
	    $publisherinput=$input->textfield(-name=>'publishercode', -default=>$publisher);
	    $pubyearinput=$input->textfield(-name=>'publicationyear', -default=>$publicationyear);
	    $placeinput=$input->textfield(-name=>'place', -default=>$bib->{place});
	    $pagesinput=$input->textfield(-name=>'pages', -default=>$bib->{pages});
	    $sizeinput=$input->textfield(-name=>'size', -default=>$bib->{size});
	    $fileinput=$input->hidden(-name=>'file', -default=>$file);
	    $origisbn=$input->hidden(-name=>'origisbn', -default=>$isbn);
	    $origissn=$input->hidden(-name=>'origissn', -default=>$issn);
	    $origlccn=$input->hidden(-name=>'origlccn', -default=>$lccn);
	    $origcontrolnumber=$input->hidden(-name=>'origcontrolnumber', -default=>$controlnumber);

	    #print "<PRE>getting itemtypeselect</PRE>\n";
	    $itemtypeselect=&getkeytableselectoptions(
		$dbh, 'itemtypes', 'itemtype', 'description', 1);
	    #print "<PRE>it=$itemtypeselect</PRE>\n";

	    ($qissn) || ($qissn='NIL');
	    ($qlccn) || ($qlccn='NIL');
	    ($qisbn) || ($qisbn='NIL');
	    ($qcontrolnumber) || ($qcontrolnumber='NIL');
	    $controlnumber=~s/\s+//g;

	    unless (($isbn eq $qisbn) || ($issn eq $qissn) || ($lccn eq $qlccn) || ($controlnumber eq $qcontrolnumber)) {
	        #print "<PRE>Skip record $isbn $issn $lccn </PRE>\n";
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
	} # foreach record
    } else {
        # No result file specified, list results
	ListSearchResults($dbh,$input);
    } # if
} # sub ProcessFile

sub ListSearchResults {
    use strict;

    # Input parameters
    my (
	$dbh,
	$input,
    )=@_;

    my (
	$field,
    );

	my $data;
	my $name;
	my $z3950=0;
	my $recordsource;
	my $record;
	my ($numrecords,$resultsid,$data,$startdate,$enddate);

	# File can be results of z3950 search or uploaded MARC data

	# if z3950 results
	if ($file=~/Z-(\d+)/) {
	    # This is a z3950 search 
	    $recordsource='';
	} else {
	    # This is a Marc upload
	    my $sth=$dbh->prepare("select marc,name from uploadedmarc where id=$file");
	    $sth->execute;
	    ($data, $name) = $sth->fetchrow;
	    $recordsource="from $name";
	}

	print << "EOF";
	  <center>
	  <p>
	  <a href=$ENV{'SCRIPT_NAME'}?menu=$menu>Select a New File</a>
	  <p>
	  <table border=0 cellpadding=10 cellspacing=0>
	  <tr><th bgcolor=black>
	    <font color=white>Select a Record to Import $recordsource</font>
	  </th></tr>
	  <tr><td bgcolor=#dddddd>
EOF

	if ($file=~/Z-(\d+)/) {
	    # This is a z3950 search 

	    my $id=$1;		# search results id number
	    my $sth=$dbh->prepare("select servers from z3950queue where id=$id");
	    $sth->execute;
	    my ($servers) = $sth->fetchrow;
	    my $serverstring;
	    my $starttimer=time();

	    # loop through all servers in search request
	    foreach $serverstring (split(/\s+/, $servers)) {
		my ($name, $server, $database, $auth) = split(/\//, $serverstring, 4);
		if ($name eq 'MAN') {
		    print "$server/$database<br>\n";
		} else {
		    my $sti=$dbh->prepare("select name from
		    z3950servers where id=$name");
		    $sti->execute;
		    my ($longname)=$sti->fetchrow;
		    print "<a name=SERVER-$name></a>\n";
		    if ($longname) {
			print "$longname \n";
		    } else {
			print "$server/$database \n";
		    }
		}
		my $q_server=$dbh->quote($serverstring);
		my $startrecord=$input->param("ST-$name");
		($startrecord) || ($startrecord='0');
		my $sti=$dbh->prepare("
		    select numrecords,id,results,startdate,enddate 
			from z3950results 
			where queryid=$id and server=$q_server");
		$sti->execute;
		($numrecords,$resultsid,$data,$startdate,$enddate) = $sti->fetchrow;
		my $serverplaceholder='';
		foreach ($input->param) {
		    (next) unless (/ST-(.+)/);
		    my $serverid=$1;
		    (next) if ($serverid eq $name);
		    my $place=$input->param("ST-$serverid");
		    $serverplaceholder.="\&ST-$serverid=$place";
		}
		if ($numrecords) {
		    my $previous='';
		    my $next='';
		    if ($startrecord>0) {
			$previous="<a href=".$ENV{'SCRIPT_NAME'}."?file=Z-$id&menu=z3950$serverplaceholder\&ST-$name=".($startrecord-10)."#SERVER-$name>Previous</a>";
		    }
		    my $highest;
		    $highest=$startrecord+10;
		    ($highest>$numrecords) && ($highest=$numrecords);
		    if ($numrecords>$startrecord+10) {
			$next="<a href=".$ENV{'SCRIPT_NAME'}."?file=Z-$id&menu=z3950$serverplaceholder\&ST-$name=$highest#SERVER-$name>Next</a>";
		    }
		    print "<font size=-1>[Viewing ".($startrecord+1)." to ".$highest." of $numrecords records]  $previous | $next </font><br>\n";
		} else {
		    print "<br>\n";
		}
		print "<ul>\n";
		my $stj=$dbh->prepare("update z3950results 
			set highestseen=? where id=?");
		$stj->execute($startrecord+10,$resultsid);

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
		    my $splitchar=chr(29);
		    my @records=split(/$splitchar/, $data);
		    $data='';
		    my $i;
		    for ($i=$startrecord; $i<$startrecord+10; $i++) {
			$data.=$records[$i].$splitchar;
		    }
		    @records=parsemarcfileformat($data);
		    my $counter=0;
		    foreach $record (@records) {

			&PrintResultRecordLink($record,$resultsid);
			
		    } # foreach record
		    print "<p>\n";
		} else {
		    print "No records returned.<p>\n";
		}
		print "</ul>\n";
	    }
	    my $elapsed=time()-$starttimer;
	    print "<hr>It took $elapsed seconds to process this page.\n";
	} else {
	    # This is an uploaded Marc record   

	    my @records=parsemarcfileformat($data);
	    foreach $record (@records) {

		&PrintResultRecordLink($record,'');

	    } # foreach record
	} # if z3950 or marc upload
	print "</td></tr></table>\n";
} # sub ListSearchResults

sub PrintResultRecordLink {
    use strict;
    my ($record,$resultsid)=@_; 	# input

    my (
	$sth,
	$bib,	# hash ref to named fields
	$searchfield, $searchvalue,
	$donetext,
	$fieldname,
    );
	

	$bib=extractmarcfields($record);

	$sth=$dbh->prepare("select * 
	  from biblioitems 
	  where isbn=?  or issn=?  or lccn=? ");
	$sth->execute($bib->{isbn},$bib->{issn},$bib->{lccn});
	if ($sth->rows) {
	    $donetext="DONE";
	} else {
	    $donetext="";
	}
	($bib->{author}) && ($bib->{author}="by $bib->{author}");

	$searchfield="";
	foreach $fieldname ( "controlnumber", "lccn", "issn", "isbn") {
	    if ( defined $bib->{$fieldname} ) {
		$searchfield=$fieldname;
		$searchvalue=$bib->{$fieldname};
	    } # if defined fieldname
	} # foreach

	if ( $searchfield ) {
	    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file" . 
		"&resultsid=$resultsid" .
		"&$searchfield=$searchvalue" .
		"&searchfield=$searchfield" .
		"&searchvalue=$searchvalue" .
		">$bib->{title} $bib->{author}</a>" .
		" $donetext <BR>\n";
	} else {
	    print "Error: Problem with $bib->{title} $bib->{author}<br>\n";
	} # if searchfield
} # sub PrintResultRecordLink

#------------------
sub extractmarcfields {
    use strict;
    # input
    my (
	$record,	# pointer to list of MARC field hashes.
			# Example: $record->[0]->{'tag'} = '100' # Author
			# 	$record->[0]->{'subfields'}->{'a'} = subfieldvalue
    )=@_;

    # return 
    my $bib;		# pointer to hash of named output fields
			# Example: $bib->{'author'} = "Twain, Mark";

    my $debug=0;

    my (
	$field, $value,
    );
    my ($lccn, $isbn, $issn, $dewey, $author, $title, $place, 
	$publisher, $publicationyear, $volume, $number, @subjects, $subject,
	$size, $pages, $controlnumber, $subtitle,
	$notes, $additionalauthors, $illustrator, $copyrightdate, 
	$s, $subdivision, $subjectsubfield,
	$seriestitle);

    print "<PRE>\n" if $debug;

    if ( ref($record) eq "ARRAY" ) {
        foreach $field (@$record) {
	    if ($field->{'tag'} eq '001') {
		$bib->{controlnumber}=$field->{'indicator'};
	    }
	    if ($field->{'tag'} eq '010') {
		$bib->{lccn}=$field->{'subfields'}->{'a'};
		$bib->{lccn}=~s/^\s*//;
		($bib->{lccn}) = (split(/\s+/, $bib->{lccn}))[0];
	    }
	    if ($field->{'tag'} eq '015') {
		$bib->{lccn}=$field->{'subfields'}->{'a'};
		$bib->{lccn}=~s/^\s*//;
		$bib->{lccn}=~s/^C//;
		($bib->{lccn}) = (split(/\s+/, $bib->{lccn}))[0];
	    }
	    if ($field->{'tag'} eq '020') {
		$bib->{isbn}=$field->{'subfields'}->{'a'};
		if (ref($bib->{isbn}) eq 'ARRAY') {$bib->{isbn}=$$bib->{isbn}[0]};
		$bib->{isbn}=~s/[^\d]*//g;
	    }
	    if ($field->{'tag'} eq '022') {
		$bib->{issn}=$field->{'subfields'}->{'a'};
		$bib->{issn}=~s/^\s*//;
		($bib->{issn}) = (split(/\s+/, $bib->{issn}))[0];
	    }
	    if ($field->{'tag'} eq '100') {
		$bib->{author}=$field->{'subfields'}->{'a'};
	    }
	    if ($field->{'tag'} eq '245') {
		$bib->{title}=$field->{'subfields'}->{'a'};
		$bib->{title}=~s/ \/$//;
		$bib->{subtitle}=$field->{'subfields'}->{'b'};
		$bib->{subtitle}=~s/ \/$//;
	    }


		if ($field->{'tag'} eq '082') {
		    $dewey=$field->{'subfields'}->{'a'};
		    if (ref($dewey) eq 'ARRAY') { $dewey=$$dewey[0]; }
		    $dewey=~s/\///g;
		}
		if ($field->{'tag'} eq '260') {
		    $place=$field->{'subfields'}->{'a'};
		    if (ref($place) eq 'ARRAY') { $place=$$place[0]; }
		    $place=~s/\s*:$//g;

		    $publisher=$field->{'subfields'}->{'b'};
		    if (ref($publisher) eq 'ARRAY') { $publisher=$$publisher[0]; }
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
		    if ($field->{'subfields'}->{'e'}!~/ill/) {
			$additionalauthors.="$name\n";
		    } else {
			$illustrator=$name;
		    }
		}
		if ($field->{'tag'} =~/^5/) {
		    $notes.="$field->{'subfields'}->{'a'}\n";
		}
		if ($field->{'tag'} =~/65\d/) {
		    my $sub;
		    my $subject=$field->{'subfields'}->{'a'};
		    $subject=~s/\.$//;
		    print "Subject=$subject\n" if $debug;
		    foreach $subjectsubfield ( 'x','y','z' ) {
		      if ($subdivision=$field->{'subfields'}->{$subjectsubfield}) {
			if ( ref($subdivision) eq 'ARRAY' ) {
			    foreach $s (@$subdivision) {
				$s=~s/\.$//;
				$subject.=" -- $s";
			    } # foreach subdivision
			} else {
			    $subdivision=~s/\.$//;
			    $subject.=" -- $subdivision";
			} # if array
		      } # if subfield exists
		    } # foreach subfield
		    print "Subject=$subject\n" if $debug;
		    push @subjects, $subject;
		}

		($dewey			) && ($bib->{dewey}=$dewey );
		($place			) && ($bib->{place}=$place  );
		($publisher		) && ($bib->{publisher}=$publisher  );
		($publicationyear	) && ($bib->{publicationyear}=$publicationyear  );
		($copyrightdate		) && ($bib->{copyrightdate}=$copyrightdate  );
		($pages			) && ($bib->{pages}=$pages  );
		($size			) && ($bib->{size}=$size  );
		($volume		) && ($bib->{volume}=$volume  );
		($number		) && ($bib->{number}=$number  );
		($seriestitle		) && ($bib->{seriestitle}=$seriestitle  );
		($additionalauthors	) && ($bib->{additionalauthors}=$additionalauthors  );
		($illustrator		) && ($bib->{illustrator}=$illustrator  );
		($notes			) && ($bib->{notes}=$notes  );
		($#subjects		) && ($bib->{subject}=\@subjects  );


        } # foreach field
    } else {
	print "Error: extractmarcfields: input ref $record is " .
		ref($record) . " not ARRAY. Contact sysadmin.\n";
    }
    print "</PRE>\n" if $debug;

    return $bib;

} # sub extractmarcfields
#---------------------------------

sub z3950menu {
    use strict;
    my (
	$dbh,
	$input,
    )=@_;

    my (
	$sth, $sti,
	$processing,
	$realenddate,
	$totalrecords,
    	$elapsed,
    	$elapsedtime,
	$resultstatus, $statuscolor,
	$id, $term, $type, $done, $numrecords, $length, 
	$startdate, $enddate, $servers,
	$record,$bib,$title,
    );

    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    print "<table border=0><tr><td valign=top>\n";
    print "<h2>Results of Z39.50 searches</h2>\n";
    print "<a href=$ENV{'SCRIPT_NAME'}?menu=z3950>Refresh</a><br>\n" .
 	  "<ul>\n";

    # Check queued queries
    $sth=$dbh->prepare("select id,term,type,done,
		numrecords,length(results),startdate,enddate,servers 
	from z3950queue 
	order by id desc 
	limit 20 ");
    $sth->execute;
    while ( ($id, $term, $type, $done, $numrecords, $length, 
		$startdate, $enddate, $servers) = $sth->fetchrow) {
	$type=uc($type);
	$term=~s/</&lt;/g;
	$term=~s/>/&gt;/g;

	$title="";
	# See if query produced results
	$sti=$dbh->prepare("select id,server,startdate,enddate,numrecords,results
		from z3950results 
		where queryid=?");
	$sti->execute($id);
	if ($sti->rows) {
	    $processing=0;
	    $realenddate=0;
	    $totalrecords=0;
	    while (my ($r_id,$r_server,$r_startdate,$r_enddate,$r_numrecords,$r_marcdata) 
		= $sti->fetchrow) {
		if ($r_enddate==0) {
		    # It hasn't finished yet
		    $processing=1;
		} else {
		    # It finished, see how long it took.
		    if ($r_enddate>$realenddate) {
			$realenddate=$r_enddate;
		    }
		    # Snag any title from the results if there were any
		    if ( ! $title && $r_marcdata ) {
	    	        ($record)=parsemarcfileformat($r_marcdata);
		        $bib=extractmarcfields($record);
		        if ( $bib->{title} ) { $title=$bib->{title} };
		    } # if no title yet
		} # if finished

		$totalrecords+=$r_numrecords;
	    } # while results

	    if ($processing) {
		$elapsed=time()-$startdate;
		$resultstatus="Processing...";
		$statuscolor="red";
	    } else {
		$elapsed=$realenddate-$startdate;
		$resultstatus="Done.";
		$statuscolor="black";
		}

		if ($elapsed>60) {
		    $elapsedtime=sprintf "%d minutes",($elapsed/60);
		} else {
		    $elapsedtime=sprintf "%d seconds",$elapsed;
		}
		if ($totalrecords) {
		    $totalrecords="$totalrecords found.";
		} else {
		    $totalrecords='';
		}
		print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>".
		"$type=$term</a>" .
		"<font size=-1 color=$statuscolor>$resultstatus $totalrecords " .
		"($elapsedtime) $title </font><br>\n";
	} else {
	    print "<li><a href=$ENV{'SCRIPT_NAME'}?file=Z-$id&menu=$menu>
		$type=$term</a> <font size=-1>Pending</font><br>\n";
	} # if results done
    } # while queries
    print "</ul> </td>\n";
    # End of query listing

    #------------------------------
    # Search input form
    print "<td valign=top width=30%>\n";

    my $sth=$dbh->prepare("select id,name,checked 
	from z3950servers 
	order by rank");
    $sth->execute;
    my $serverlist='';
    while (my ($id, $name, $checked) = $sth->fetchrow) {
	($checked) ? ($checked='checked') : ($checked='');
	$serverlist.="<input type=checkbox name=S-$id $checked> $name<br>\n";
    }
    $serverlist.="<input type=checkbox name=S-MAN> <input name=manualz3950server size=25 value=otherserver:210/DATABASE>\n";
    
    my $rand=rand(1000000000);
print << "EOF";
    <form action=$ENV{'SCRIPT_NAME'} method=GET>
    <input type=hidden name=z3950queue value=1>
    <input type=hidden name=menu value=$menu>
    <p>
    <input type=hidden name=test value=testvalue>
    <input type=hidden name=rand value=$rand>
        <table border=1 bgcolor=#dddddd>
	    <tr><th bgcolor=#bbbbbb colspan=2>Search for MARC records</th></tr>
    <tr><td>Query Term</td><td><input name=query></td></tr>
    <tr><td colspan=2 align=center>
		<input type=radio name=type value=isbn checked>&nbsp;ISBN 
		<input type=radio name=type value=lccn        >&nbsp;LCCN<br>
		<input type=radio name=type value=author      >&nbsp;Author 
		<input type=radio name=type value=title       >&nbsp;Title 
		<input type=radio name=type value=keyword     >&nbsp;Keyword</td></tr>
            <tr><td colspan=2> $serverlist </td></tr>
            <tr><td colspan=2 align=center> <input type=submit> </td></tr>
    </table>

    </form>
EOF
    print "</td></tr></table>\n";
} # sub z3950menu
#---------------------------------

sub uploadmarc {
    use strict;
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
} # sub mainmenu


#--------------------------
# Parse MARC data in file format with control-character separators
#   May be multiple records.
sub parsemarcfileformat {
    use strict;
    # Input is one big text string
    my $data=shift;
    # Output is list of records.  Each record is list of field hashes
    my @records;

    my $splitchar=chr(29);
    my $splitchar2=chr(30);
    my $splitchar3=chr(31);
    my $debug=0;
    my $record;
    foreach $record (split(/$splitchar/, $data)) {
	my @record;
	my $directory=0;
	my $tagcounter=0;
	my %tag;
	my $field;

	my $leader=substr($record,0,24);
	print "<tr><td>Leader:</td><td>$leader</td></tr>\n" if $debug;
	push (@record, {
		'tag' => 'Leader',
		'indicator' => $leader ,
	} );

	$record=substr($record,24);
	foreach $field (split(/$splitchar2/, $record)) {
	    my %field;
	    my $tag;
	    my $indicator;
	    unless ($directory) {
		$directory=$field;
		my $itemcounter=1;
		my $counter2=0;
		my $item;
		my $length;
		my $start;
		while ($item=substr($directory,0,12)) {
		    $tag=substr($directory,0,3);
		    $length=substr($directory,3,4);
		    $start=substr($directory,7,6);
		    $directory=substr($directory,12);
		    $tag{$counter2}=$tag;
		    $counter2++;
		}
		$directory=1;
		next;
	    }
	    $tag=$tag{$tagcounter};
	    $tagcounter++;
	    $field{'tag'}=$tag;
	    my @subfields=split(/$splitchar3/, $field);
	    $indicator=$subfields[0];
	    $field{'indicator'}=$indicator;
	    my $firstline=1;
	    unless ($#subfields==0) {
		my %subfields;
		my @subfieldlist;
		my $i;
		for ($i=1; $i<=$#subfields; $i++) {
		    my $text=$subfields[$i];
		    my $subfieldcode=substr($text,0,1);
		    my $subfield=substr($text,1);
		    # if this subfield already exists, do array
		    if ($subfields{$subfieldcode}) {
			my $subfieldlist=$subfields{$subfieldcode};
			if ( ref($subfieldlist) eq 'ARRAY' ) {
                            # Already an array, add on to it
			    print "$tag Adding to array $subfieldcode -- $subfield<br>\n" if $debug;
			    @subfieldlist=@$subfieldlist;
			    push (@subfieldlist, $subfield);
			} else {
                            # Change simple value to array
			    print "$tag Arraying $subfieldcode -- $subfield<br>\n" if $debug;
			    @subfieldlist=($subfields{$subfieldcode}, $subfield);
			}
			# keep new array
			$subfields{$subfieldcode}=\@subfieldlist;
		    } else {
			# subfield doesn't exist yet, keep simple value
			$subfields{$subfieldcode}=$subfield;
		    }
		}
		$field{'subfields'}=\%subfields;
	    }
	    push (@record, \%field);
	} # foreach field in record
	push (@records, \@record);
	# $counter++;
    }
    print "</pre>" if $debug;
    return @records;
} # sub parsemarcfileformat

#----------------------------
# Accept form results to add query to z3950 queue
sub AcceptZ3950Queue {
    use strict;

    # input parameters
    my (
	$dbh, 		# DBI handle
	$input,		# CGI parms
    )=@_;

    my @serverlist;

    my $query=$input->param('query');

    my $isbngood=1;
    if ($input->param('type') eq 'isbn') {
	$isbngood=checkvalidisbn($query);
    }
    if ($isbngood) {
    foreach ($input->param) {
	if (/S-(.*)/) {
	    my $server=$1;
	    if ($server eq 'MAN') {
                push @serverlist, "MAN/".$input->param('manualz3950server')."//"
;
	    } else {
                push @serverlist, $server;
            }
          }
        }

	addz3950queue($dbh,$input->param('query'), $input->param('type'), 
		$input->param('rand'), @serverlist);
    } else {
	print "<font color=red size=+1>$query is not a valid ISBN
	Number</font><p>\n";
    }
} # sub AcceptZ3950Queue

#---------------------------------------------
sub AcceptMarcUpload {
    use strict;
    my (
	$dbh,		# DBI handle
	$input,		# CGI parms
    )=@_;

    my $name=$input->param('name');
    my $data=$input->param('uploadmarc');
    my $marcrecord='';

    ($name) || ($name=$data);
    if (length($data)>0) {
	while (<$data>) {
	    $marcrecord.=$_;
	}
    }
    my $q_marcrecord=$dbh->quote($marcrecord);
    my $q_name=$dbh->quote($name);
    my $sth=$dbh->prepare("insert into uploadedmarc 
		(marc,name) 
	values ($q_marcrecord, $q_name)");
    $sth->execute;
} # sub AcceptMarcUpload

#-------------------------------------------
sub AcceptBiblioitem {
    use strict;
    my (
	$dbh,
	$input,
    )=@_;

    my $biblionumber=0;
    my $biblioitemnumber=0;

    my $sth;
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
    my $file=$input->param('file');

    #my $sth=$dbh->prepare("insert into marcrecorddone values ($q_origisbn, $q_origissn, $q_origlccn, $q_origcontrolnumber)");
    #$sth->execute;

    print "<center>\n";
    print "<a href=$ENV{'SCRIPT_NAME'}?file=$file>New Record</a> | <a href=marcimport.pl>New File</a><br>\n";

    # See if it already exists
    my $sth=$dbh->prepare("select biblionumber,biblioitemnumber 
	from biblioitems 
	where issn=$q_issn or isbn=$q_isbn or lccn=$q_lccn");
    $sth->execute;
    if ($sth->rows) {
	# Already exists
	($biblionumber, $biblioitemnumber) = $sth->fetchrow;
	my $title=$input->param('title');
	print << "EOF";
	<table border=0 width=50% cellpadding=10 cellspacing=0>
	  <tr><th bgcolor=black><font color=white>Record already in database</font>
	  </th></tr>
	  <tr><td bgcolor=#dddddd>$title is already in the database with 
		biblionumber $biblionumber and biblioitemnumber $biblioitemnumber
	  </td></tr>
	</table>
	<p>
EOF
    } else {

	# It doesn't exist; add it.

  	my $error;
  	my %biblio;
  	my %biblioitem;
  
  	# convert to upper case and split on lines
  	my $subjectheadings=$input->param('subject');
  	my @subjectheadings=split(/[\r\n]+/,$subjectheadings);
  
  	my $additionalauthors=$input->param('additionalauthors');
  	my @additionalauthors=split(/[\r\n]+/,uc($additionalauthors));
  
  	# Use individual assignments to hash buckets, in case
  	#  any of the input parameters are empty or don't exist
  	$biblio{title}		=$input->param('title');
  	$biblio{author}		=$input->param('author');
  	$biblio{copyright}	=$input->param('copyrightdate');
  	$biblio{seriestitle}	=$input->param('seriestitle');
  	$biblio{notes}		=$input->param('notes');
  	$biblio{abstract}	=$input->param('abstract');
  	$biblio{subtitle}	=$input->param('subtitle');
  
 	$biblioitem{volume}		=$input->param('volume');
  	$biblioitem{number}		=$input->param('number');
 	$biblioitem{itemtype}		=$input->param('itemtype');
 	$biblioitem{isbn}		=$input->param('isbn');
 	$biblioitem{issn}		=$input->param('issn');
 	$biblioitem{dewey}		=$input->param('dewey');
 	$biblioitem{subclass}		=$input->param('subclass');
 	$biblioitem{publicationyear}	=$input->param('publicationyear');
 	$biblioitem{publishercode}	=$input->param('publishercode');
 	$biblioitem{volumedate}		=$input->param('volumedate');
 	$biblioitem{volumeddesc}	=$input->param('volumeddesc');
 	$biblioitem{illus}		=$input->param('illustrator');
 	$biblioitem{pages}		=$input->param('pages');
 	$biblioitem{notes}		=$input->param('notes');
	$biblioitem{size}		=$input->param('size');
	$biblioitem{place}		=$input->param('place');
	$biblioitem{lccn}		=$input->param('lccn');
 	$biblioitem{marc}	 	=$input->param('marc');
 
 	#print "<PRE>subjects=@subjectheadings</PRE>\n";
 	#print "<PRE>auth=@additionalauthors</PRE>\n";
 		
 	($biblionumber, $biblioitemnumber, $error)=
  	  newcompletebiblioitem($dbh,
 		\%biblio,
 		\%biblioitem,
 		\@subjectheadings,
 		\@additionalauthors
 	);
  
 	if ( $error ) {
	    print "<H2>Error adding biblio item</H2> $error\n";
	} else { 

	  my $title=$input->param('title');
	  print << "EOF";
	    <table cellpadding=10 cellspacing=0 border=0 width=50%>
	    <tr><th bgcolor=black><font color=white>Record entered into database</font></th></tr>
	    <tr><td bgcolor=#dddddd>$title has been entered into the database with biblionumber
	    $biblionumber and biblioitemnumber $biblioitemnumber</td></tr>
	  </table>
EOF
	} # if error
    } # if new record

    return $biblionumber,$biblioitemnumber;
} # sub AcceptBiblioitem

sub ItemCopyForm {
    use strict;
    my (
	$dbh,
	$input,		# CGI input object
	$biblionumber,
	$biblioitemnumber,
    )=@_;

    my $sth;
    my $barcode;

    my $title=$input->param('title');
    my $file=$input->param('file');

    # Get next barcode, or pick random one if none exist yet
    $sth=$dbh->prepare("select max(barcode) from items");
    $sth->execute;
    ($barcode) = $sth->fetchrow;
    $barcode++;
    if ($barcode==1) {
	$barcode=int(rand()*1000000);
    }

    my $branchselect=getkeytableselectoptions(
		$dbh, 'branches', 'branchcode', 'branchname', 0);

    print << "EOF";
    <table border=0 cellpadding=10 cellspacing=0>
      <tr><th bgcolor=black>
	<font color=white> Add a New Item for $title </font>
      </th></tr>
      <tr><td bgcolor=#dddddd>
      <form>
        <input type=hidden name=newitem value=1>
        <input type=hidden name=biblionumber value=$biblionumber>
        <input type=hidden name=biblioitemnumber value=$biblioitemnumber>
        <input type=hidden name=file value=$file>
        <table border=0>
          <tr><td>BARCODE</td><td><input name=barcode size=10 value=$barcode>
          Home Branch: <select name=homebranch> $branchselect </select>
	  </td></tr>
          <tr><td>Replacement Price:</td>
	  <td><input name=replacementprice size=10></td></tr>
          <tr><td>Notes</td>
	  <td><textarea name=notes rows=4 cols=40 wrap=physical></textarea>
	  </td></tr>
        </table>
        <p>
        <input type=submit value="Add Item">
      </form>
      </td></tr>
    </table>
EOF

} # sub ItemCopyForm

#---------------------------------------
# Accept form data to add an item copy
sub AcceptItemCopy {
    use strict;
    my ( $dbh, $input )=@_;

    my $error;
    my $barcode=$input->param('barcode');
    my $replacementprice=($input->param('replacementprice') || 0);

    my $sth=$dbh->prepare("select barcode 
	from items 
	where barcode=?");
    $sth->execute($barcode);
    if ($sth->rows) {
	print "<font color=red>Barcode '$barcode' has already been assigned.</font><p>\n";
    } else {
	   # Insert new item into database
           $error=&newitems(
                { biblionumber=> $input->param('biblionumber'),
                  biblioitemnumber=> $input->param('biblioitemnumber'),
                  itemnotes=> $input->param('notes'),
                  homebranch=> $input->param('homebranch'),
                  replacementprice=> $replacementprice,
                },
                $barcode
            );
            if ( $error ) {
		print "<font color=red>Error: $error </font><p>\n";
	    } else {

		print "<table border=1 align=center cellpadding=10>
			<tr><td bgcolor=yellow>
			Item added with barcode $barcode
			</td></tr></table>\n";
            } # if error
    } # if barcode exists
} # sub AcceptItemCopy

#---------------
# Create an HTML option list for a <SELECT> form tag by using
#    values from a DB file
sub getkeytableselectoptions {
	use strict;
	# inputs
	my (
		$dbh,		# DBI handle
		$tablename,	# name of table containing list of choices
		$keyfieldname,	# column name of code to use in option list
		$descfieldname,	# column name of descriptive field
		$showkey,	# flag to show key in description
	)=@_;
	my $selectclause;	# return value

	my (
		$sth, $query, 
		$key, $desc, $orderfieldname,
	);
	my $debug=0;

	if ( $showkey ) {
		$orderfieldname=$keyfieldname;
	} else {
		$orderfieldname=$descfieldname;
	}
	$query= "select $keyfieldname,$descfieldname
		from $tablename
		order by $orderfieldname ";
	print "<PRE>Query=$query </PRE>\n" if $debug; 
	$sth=$dbh->prepare($query);
	$sth->execute;
	while ( ($key, $desc) = $sth->fetchrow) {
	    if ($showkey) { $desc="$key - $desc"; }
	    $selectclause.="<option value='$key'>$desc\n";
	    print "<PRE>Sel=$selectclause </PRE>\n" if $debug; 
	}
	return $selectclause;
} # sub getkeytableselectoptions

#---------------------------------
# Add a biblioitem and related data
sub newcompletebiblioitem {
	use strict;

	my ( $dbh,		# DBI handle
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

	print "<PRE>Trying to add biblio item Title=$biblio->{title} " .
		"ISBN=$biblioitem->{isbn} </PRE>\n" if $debug;

	# Make sure master biblio entry exists
	($biblionumber,$error)=getoraddbiblio($dbh, $biblio);

        if ( ! $error ) { 

	  $biblioitem->{biblionumber}=$biblionumber;
	  $biblioitemnumber=newbiblioitem($biblioitem);

	  $sth=$dbh->prepare("insert into bibliosubject 
		(biblionumber,subject)
		values (?, ? )" );
	  foreach $subjectheading (@{$subjects} ) {
	      $sth->execute($biblionumber, $subjectheading) 
			or $error.=$sth->errstr ;
	
	  } # foreach subject

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
#---------------------------------------
# Find a biblio entry, or create a new one if it doesn't exist.
sub getoraddbiblio {
	use strict;		# in here until rest cleaned up
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
#---------------------------------------
sub addz3950queue {
    use strict;
    # input
    my (
	$dbh,		# DBI handle
	$query,		# value to look up
	$type,		# type of value ("isbn", "lccn", etc).
	$requestid,
	@z3950list,	# list of z3950 servers to query
    )=@_;

    my (
	@serverlist,
	$server,
	$failed,
    );

	# list of servers: entry can be a fully qualified URL-type entry
        #   or simply just a server ID number.

        my $sth=$dbh->prepare("select host,port,db,userid,password 
	  from z3950servers 
	  where id=? ");
        foreach $server (@z3950list) {
	    if ($server =~ /:/ ) {
		push @serverlist, $server;
	    } else {
		$sth->execute($server);
		my ($host, $port, $db, $userid, $password) = $sth->fetchrow;
		push @serverlist, "$server/$host\:$port/$db/$userid/$password";
	    }
	}

	my $serverlist='';
	foreach (@serverlist) {
	    $serverlist.="$_ ";
    	} # foreach
	chop $serverlist;

	# Don't allow reinsertion of the same request number.
	my $sth=$dbh->prepare("select identifier from z3950queue 
		where identifier=?");
	$sth->execute($requestid);
	unless ($sth->rows) {
	    $sth=$dbh->prepare("insert into z3950queue 
		(term,type,servers, identifier) 
		values (?, ?, ?, ?)");
	    $sth->execute($query, $type, $serverlist, $requestid);
	}
} # sub addz3950queue

#--------------------------------------
sub checkvalidisbn {
	use strict;
	my ($q)=@_ ;

	my $isbngood = 0;

	$q=~s/x$/X/g;		# upshift lower case X
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
		$isbngood=1;
	    } else {
		$isbngood=0;
	    }
	} else {
	    $isbngood=0;
	} # if length good

	return $isbngood;

} # sub checkvalidisbn

#-------------------------
sub BuildTagMap {
    use strict;

    my (@tagmaplist)=@_;	# input
    my ($tagmap);		#return

    my (
	$row,
    	$tagnum, $subfield, $fieldname, $repeat, $stripchars,
    );

    foreach $row (@tagmaplist) {
    	($tagnum, $subfield, $fieldname, $repeat, $stripchars)= @$row;
	#print "tagnum=$tagnum name=$fieldname\n";
	$tagmap->{$tagnum}{$subfield}{fieldname}=$fieldname;
	$tagmap->{$tagnum}{$subfield}{repeat}=$repeat;
	$tagmap->{$tagnum}{$subfield}{stripchars}=$stripchars;
    } # foreach row
    return $tagmap;
} # sub BuildTagMap
#-------------------------
sub FormatMarcText {
    use strict;

    # Input
    my (
	$fields,	# list ref to MARC fields
    )=@_;
    # Return

    my (
        $marctext,
	$color,
	$field,
	$tag,
	$label,
	$subfieldcode,$subfieldvalue,
    );

	#return "MARC text here";

    $marctext="<table border=0 cellspacing=0>
    	<tr><th colspan=3 bgcolor=black>
		<font color=white>MARC RECORD</font>
	</th></tr>\n";

    foreach $field ( @$fields ) {
	($color eq $lc1) ? ($color=$lc2) : ($color=$lc1);
	$tag=$field->{'tag'};
	$label=$tagtext{$tag};
	if ( $tag eq 'Leader' ) {
		$tag='';
		$label="Leader:";
	}
	$marctext.="<tr><td bgcolor=$color valign=top>$label</td> \n" .
		"<td bgcolor=$color valign=top>$tag</td> \n";
	if ( ! $field->{'subfields'} )  {
	    $marctext.="<td bgcolor=$color valign=top>$field->{'indicator'}</td>";
	} else {
	    # start another table for subfields
	    $marctext.="<td bgcolor=$color valign=top>\n " .
		"  <table border=0 cellspacing=0>\n";
	    foreach $subfieldcode ( sort( keys %{ $field->{'subfields'} }   )) {
	        $subfieldvalue=$field->{'subfields'}->{$subfieldcode};
	        $marctext.="<tr><td>$subfieldcode </td>" .
		    "<td>$subfieldvalue</td></tr>\n";
	    } # foreach subfield
	    $marctext.="</table></td>\n";
	} # if subfields
	$marctext.="</tr>\n";

    } # foreach field

    $marctext.="</table>\n";

    return $marctext;

} # sub FormatMarcText
