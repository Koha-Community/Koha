#!/usr/bin/perl

# $Id$

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
use C4::Input;
use C4::Biblio;
use C4::SimpleMarc;
use C4::Z3950;
use C4::Auth;

my $input = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input);

#------------------
# Constants

# HTML colors for alternating lines
my $lc1='#dddddd';
my $lc2='#ddaaaa';

#-------------
#-------------
# Initialize

my $userid=$ENV{'REMOTE_USER'};

my $dbh=C4Connect;

#-------------
# Display output
print $input->header(-cookie => $cookie);
print startpage();
print startmenu('acquisitions');


print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";

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
	if ($menu eq 'uploadmarc') { uploadmarc($dbh); last SWITCH; }
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

    requireDBI($dbh,"ProcessFile");

    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    my $qisbn=$input->param('isbn');
    my $qissn=$input->param('issn');
    my $qlccn=$input->param('lccn');
    my $qcontrolnumber=$input->param('controlnumber');

    # See if a particular result item was specified
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

	    print "<PRE>lccn=$lccn</PRE>\n" if $debug;

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

	    my $defaultitemtype;

	    if ($bib->{dewey}) {
		$defaultitemtype = 'NF';
	    } else {
		$defaultitemtype = 'F';
	    }

	    #print "<PRE>getting itemtypeselect</PRE>\n";
	    $itemtypeselect=&getkeytableselectoptions(
		$dbh, 'itemtypes', 'itemtype', 'description', 1, $defaultitemtype);
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
        # No result item specified, list results
	ListFileRecords($dbh,$input);
    } # if
} # sub ProcessFile

sub ListFileRecords {
    use strict;

    # Input parameters
    my (
	$dbh,
	$input,
    )=@_;

    my (
	$sth, $sti,
	$field,
	$data,		# records in MARC file format
	$name,
	$srvid,
	%servernames,
	$serverdb,
    );

	my $z3950=0;
	my $recordsource;
	my $record;
	my ($numrecords,$resultsid,$data,$startdate,$enddate);

    requireDBI($dbh,"ListFileRecords");

	# File can be z3950 search query or uploaded MARC data

	# if z3950 results
	if ($file=~/Z-(\d+)/) {
	    # This is a z3950 search 
	    $recordsource='';
	} else {
	    # This is a Marc upload
	    $sth=$dbh->prepare("select marc,name from uploadedmarc where id=$file");
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
	  <tr><th background=/images/background-acq.gif>
	    Select a Record to Import $recordsource
	  </th></tr>
	  <tr><td bgcolor=#dddddd>
EOF

	if ($file=~/Z-(\d+)/) {
	    # This is a z3950 search 

	    my $id=$1;		# search query id number
	    my $serverstring;
	    my $starttimer=time();

	    $sth=$dbh->prepare("
		select z3950results.numrecords,z3950results.id,z3950results.results,
			z3950results.startdate,z3950results.enddate,server 
		from z3950queue left outer join z3950results 
		     on z3950queue.id=z3950results.queryid 
		where z3950queue.id=?
		order by server  
	    ");
	    $sth->execute($id);
	    if ( $sth->rows ) {
	      # loop through all servers in search results
	      while ( ($numrecords,$resultsid,$data,
			$startdate,$enddate,$serverstring) = $sth->fetchrow ) {
		my ($srvid, $server, $database, $auth) = split(/\//, $serverstring, 4);
		#print "server=$serverstring\n";
		if ( $server ) {
	            print "<a name=SERVER-$srvid></a> " .
			&z3950servername($dbh,$srvid,"$server/$database") . "\n";
		} # if $server
		my $startrecord=$input->param("ST-$srvid");
		($startrecord) || ($startrecord='0');
		my $serverplaceholder='';
		foreach ($input->param) {
		    (next) unless (/ST-(.+)/);
		    my $serverid=$1;
		    (next) if ($serverid eq $srvid);
		    my $place=$input->param("ST-$serverid");
		    $serverplaceholder.="\&ST-$serverid=$place";
		}
		if ($numrecords) {
		    my $previous='';
		    my $next='';
		    if ($startrecord>0) {
			$previous="<a href=".$ENV{'SCRIPT_NAME'}."?file=Z-$id&menu=z3950$serverplaceholder\&ST-$srvid=".($startrecord-10)."#SERVER-$srvid>Previous</a>";
		    }
		    my $highest;
		    $highest=$startrecord+10;
		    ($highest>$numrecords) && ($highest=$numrecords);
		    if ($numrecords>$startrecord+10) {
			$next="<a href=".$ENV{'SCRIPT_NAME'}."?file=Z-$id&menu=z3950$serverplaceholder\&ST-$srvid=$highest#SERVER-$srvid>Next</a>";
		    }
		    print "<font size=-1>[Viewing ".($startrecord+1)." to ".$highest." of $numrecords records]  $previous | $next </font><br>\n";
		    my $stj=$dbh->prepare("update z3950results 
			set highestseen=? where id=?");
		    $stj->execute($startrecord+10,$resultsid);
		} else {
		    print "<br>\n";
		}
		print "<ul>\n";

		if (! $server ) {
		    print "<font color=red>Search still pending...</font>";
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
		    my @records=parsemarcfileformat($data);
		    my $i;
		    for ($i=$startrecord; $i<$startrecord+10; $i++) {
			if ( $records[$i] ) {
			  &PrintResultRecordLink($dbh,$records[$i],$resultsid);
			} # if record
		    } # for records
		    print "<p>\n";
		} else {
		    print "No records returned.<p>\n";
		}
		print "</ul>\n";
	    } # foreach server
	    my $elapsed=time()-$starttimer;
	    print "<hr>It took $elapsed seconds to process this page.\n";
	    } else {
		print "<b>No results found for query $id</b>\n";
	    } # if rows
	} else {
	    # This is an uploaded Marc record   

	    my @records=parsemarcfileformat($data);
	    foreach $record (@records) {

		&PrintResultRecordLink($dbh,$record,'');

	    } # foreach record
	} # if z3950 or marc upload
	print "</td></tr></table>\n";
} # sub ListFileRecords

#--------------

sub PrintResultRecordLink {
    use strict;
    my ($dbh,$record,$resultsid)=@_; 	# input

    my (
	$sth,
	$bib,	# hash ref to named fields
	$searchfield, $searchvalue,
	$donetext,
	$fieldname,
    );
	
    requireDBI($dbh,"PrintResultRecordLink");

	$bib=extractmarcfields($record);

	$sth=$dbh->prepare("select * 
	  from biblioitems 
	  where (isbn=? and isbn!='')  or (issn=? and issn!='')  or (lccn=? and lccn!='') ");
	$sth->execute($bib->{isbn},$bib->{issn},$bib->{lccn});
	if ($sth->rows) {
	    $donetext="DONE";
	} else {
	    $donetext="";
	}
	($bib->{author}) && ($bib->{author}="by $bib->{author}");

	$searchfield="";
	foreach $fieldname ( "controlnumber", "lccn", "issn", "isbn") {
	    if ( defined $bib->{$fieldname} && $bib->{$fieldname} ) {
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
	$id, $term, $type, $done, 
	$startdate, $enddate, $servers,
	$record,$bib,$title,
    );

    requireDBI($dbh,"z3950menu");

    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    print "<table border=0><tr><td valign=top>\n";
    print "<h2>Results of Z39.50 searches</h2>\n";
    print "<a href=$ENV{'SCRIPT_NAME'}?menu=z3950>Refresh</a><br>\n" .
 	  "<ul>\n";

    # Check queued queries
    $sth=$dbh->prepare("select id,term,type,done,
		startdate,enddate,servers 
	from z3950queue 
	order by id desc 
	limit 20 ");
    $sth->execute;
    while ( ($id, $term, $type, $done, 
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
    my ($dbh)=@_;

    requireDBI($dbh,"uploadmarc");

    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    if (my $deleterecord=$input->param('deleterecord')) {
	my $sth=$dbh->prepare("delete from uploadedmarc where id=$deleterecord");
	$sth->execute;
    }
    my $sth=$dbh->prepare("select id,name from uploadedmarc");
    $sth->execute;
    print "<h2>Select a set of MARC records</h2>\n<ul>";
    while (my ($id, $name) = $sth->fetchrow) {
	print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$id&menu=$menu>$name</a> (<a href=marcimport.pl?menu=uploadmarc&deleterecord=$id>Delete</a>)<br>\n";
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
    my $error;

    requireDBI($dbh,"AcceptZ3950Queue");

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

	$error=addz3950queue($dbh,$input->param('query'), $input->param('type'), 
		$input->param('rand'), @serverlist);
	if ( $error ) {
	    print qq|
<table border=1 cellpadding=5 cellspacing=0 align=center>
<tr><td bgcolor=#99cc33 background=/images/background-acq.gif colspan=2><font color=red><b>Error</b></font></td></tr>
<tr><td colspan=2>
<b>$error</b><p>
|;
	    if ( $error =~ /daemon/i ) {
	        print qq|
There is a launcher for the Z39.50 client daemon in your intranet installation<br>
directory under <b>./scripts/z3950daemon/z3950-daemon-launch.sh</b>.  This<br>
script should be run as root, and it will start up the program running with the<br>
privileges of your apache user.  Ideally, this script should be started from a<br>
system init directory so that is running after the machine starts up.
|;
	
	    } # if daemon
	    print qq|
</td></tr>
</table>

<table border

|;
	} # if error
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

    requireDBI($dbh,"AcceptMarcUpload");

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

    requireDBI($dbh,"AcceptBiblioitem");

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
	  <tr><th background=/images/background-acq.gif>Record already in database
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
	    <tr><th background=/images/background-acq.gif>Record entered into database</th></tr>
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
    requireDBI($dbh,"ItemCopyForm");

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
      <tr><th background=/images/background-acq.gif>
	Add a New Item for $title
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

    requireDBI($dbh,"AcceptItemCopy");

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

#---------------------------------------
sub FormatMarcText {
    use strict;

    # Input
    my (
	$fields,	# list ref to MARC fields
    )=@_;
    # Return
    my $marctext;

    my (
	$color,
	$field,
	$tag,
	$label,
	$indicator,
	$subfieldcode,$subfieldvalue,
	@values, $value
    );
    my $debug=0;

    #-----------------------------------------

    $marctext="<table border=0 cellspacing=1>
    	<tr><th colspan=4 background=/images/background-acq.gif>
		MARC RECORD
	</th></tr>\n";

    foreach $field ( @$fields ) {

	# Swap colors on alternating lines
	($color eq $lc1) ? ($color=$lc2) : ($color=$lc1);

	$tag=$field->{'tag'};
	$label=taglabel($tag);

	if ( $tag eq 'LDR' ) {
		$tag='';
		$label="Leader:";
	}
	print "<pre>Format tag=$tag label=$label</pre>\n" if $debug;

	$marctext.="<tr><td bgcolor=$color valign=top>$label</td> \n" .
		"<td bgcolor=$color valign=top>$tag</td> \n";

	$indicator=$field->{'indicator'};
	$indicator=~s/ +$//;	# drop trailing blanks

	# Third table column has indicator if it is short.
	# Fourth column has embedded table of subfields, and indicator
	#  if it is long (leader or fixed-position fields)

	print "<pre>Format indicator=$indicator" .
		" length=" . length( $indicator ) .  "</pre>\n" if $debug;
	if ( length( $indicator <= 3 ) ) {
	    $marctext.="<td bgcolor=$color valign=top><pre>" .
		"$indicator</pre></td>" .
		"<td bgcolor=$color valign=top>" ;
	} else {
	    $marctext.="<td bgcolor=$color valign=top></td>" .
	    	"<td bgcolor=$color valign=top>" .
		"$indicator ";
	} # if length

	# Subfields
	if ( $field->{'subfields'} )  {
	    # start another table for subfields
	    $marctext.= "<table border=0 cellspacing=2>\n";
	    foreach $subfieldcode ( sort( keys %{ $field->{'subfields'} }   )) {
	        $subfieldvalue=$field->{'subfields'}->{$subfieldcode};
		if (ref($subfieldvalue) eq 'ARRAY' ) {
		    # if it's a pointer to array, get all the values
		    @values=@{$subfieldvalue};
		} else {
		    # otherwise get the one value
		    @values=( $subfieldvalue );
		} # if subfield array
		foreach $value ( @values ) {
	          $marctext.="<tr><td><strong>$subfieldcode</strong></td>" .
		    "<td>$value</td></tr>\n";
		} # foreach value
	    } # foreach subfield
	    $marctext.="</table>\n";
	} # if subfields
	# End of indicator and subfields column
	$marctext.="</td>\n";

	# End of columns
	$marctext.="</tr>\n";

    } # foreach field

    $marctext.="</table>\n";

    return $marctext;

} # sub FormatMarcText


#---------------
# $Log$
# Revision 1.6.2.36  2002/12/04 17:21:04  tonnesen
# Added a link to delete uploaded marc records.
#
# Revision 1.6.2.35  2002/07/11 18:05:29  tonnesen
# Committing changes to add authentication and opac templating to rel-1-2 branch
#
# Revision 1.6.2.34  2002/07/05 19:30:14  amillar
# Second arg of requireDBI is calling subroutine name
#
# Revision 1.6.2.33  2002/07/05 16:04:04  tonnesen
# Fixing some bugs in marcimport.pl that broke uploading marc records.
#
# Revision 1.6.2.32  2002/06/29 17:33:47  amillar
# Allow DEFAULT as input to addz3950search.
# Check for existence of pid file (cat crashed otherwise).
# Return error messages in addz3950search.
#
# Revision 1.6.2.31  2002/06/28 18:50:46  tonnesen
# Got rid of white text on black, replaced with black on background-acq.gif
#
# Revision 1.6.2.30  2002/06/28 18:07:27  tonnesen
# marcimport.pl will print an error message if it can not signal the
# processz3950queue program.  The message contains instructions for starting the
# daemon.
#
# Revision 1.6.2.29  2002/06/27 18:35:01  tonnesen
# $deweyinput was always defined (it's an HTML input field).  Check against
# $bib->{dewey} instead.
#
# Revision 1.6.2.28  2002/06/27 17:41:26  tonnesen
# Applying patch from Matt Kraai to pick F or NF based on presense of a dewey
# number when adding a book via marcimport.pl
#
# Revision 1.6.2.27  2002/06/26 15:52:55  amillar
# Fix display of marc tag labels and indicators
#
# Revision 1.6.2.26  2002/06/26 14:28:35  amillar
# Removed subroutines now existing in modules: extractmarcfields,
#  parsemarcfileformat, addz3950queue, getkeytableselectoptions
#
