#!/usr/bin/perl

# $Id$

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL


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

# standard or CPAN modules used
use CGI;
use DBI;

# Koha modules used
use C4::Context;
use C4::Database;
use C4::Acquisitions;
use C4::Output;
use C4::Input;
use C4::Biblio;
use C4::SimpleMarc;
use C4::Z3950;
use MARC::File::USMARC;
use HTML::Template;

#------------------
# Constants

my $includes = C4::Context->config('includes') ||
	"/usr/local/www/hdl/htdocs/includes";

# HTML colors for alternating lines
my $lc1='#dddddd';
my $lc2='#ddaaaa';

#-------------
#-------------
# Initialize

my $userid=$ENV{'REMOTE_USER'};

my $input = new CGI;
my $dbh = C4::Context->dbh;

#-------------
# Display output
#print $input->header;
#print startpage();
#print startmenu('acquisitions');

#-------------
# Process input parameters

my $file=$input->param('file');
my $menu = $input->param('menu');

#
#
# TODO : parameter decoding and function call is quite dirty.
# should be rewritten...
#
#
if ($input->param('z3950queue')) {
	AcceptZ3950Queue($dbh,$input);
}

if ($input->param('uploadmarc')) {
	AcceptMarcUpload($dbh,$input)
}

if ($input->param('insertnewrecord')) {
    # Add biblio item, and set up menu for adding item copies
    my ($biblionumber,$biblioitemnumber)=AcceptBiblioitem($dbh,$input);
    exit;
}

if ($input->param('newitem')) {
    # Add item copy
    &AcceptItemCopy($dbh,$input);
    exit;
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
#print endmenu();
#print endpage();


# Process a MARC file : show list of records, of 1 record detail, if numrecord exists
sub ProcessFile {
    # A MARC file has been specified; process it for review form
    use strict;
    # Input params
    my (
	$dbh,		# FIXME - Unused argument
	$input,
    )=@_;

    # local vars
    my (
	$sth,
	$record,
    );

    my $debug=0;

    $dbh = C4::Context->dbh;

    # See if a particular result item was specified
    my $numrecord = $input->param('numrecord');
    if ($numrecord) {
	ProcessRecord($dbh,$input,$numrecord);
    } else {
	# No result item specified, list results
	ListFileRecords($dbh,$input);
    } # if
} # sub ProcessFile

# show 1 record from the MARC file
sub ProcessRecord {
    my ($dbh, $input,$numrecord) = @_;
    # local vars
    my (
	$sth,
	$record,
	$data,
    );

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

    my $file=MARC::File::USMARC->indata ($data);
    my $oldkoha;
    # FIXME - This "==" should be "=", right?
    for (my $i==1;$i<$numrecord;$i++) {
	$record = $file->next;
    }
    if ($record) {
	$oldkoha=MARCmarc2koha($dbh,$record);
    }
    my $template=gettemplate('marcimport/marcimportdetail.tmpl');
    $oldkoha->{additionalauthors} =~ s/ \| /\n/g;
    $oldkoha =~ s/\|/\n/g;
    $template->param($oldkoha);
#---- build MARC array for template
    my @loop = ();
    my $tagmeaning = &MARCgettagslib($dbh,1);
    my @fields = $record->fields();
    my $color=0;
    my $lasttag="";
    foreach my $field (@fields) {
	my @subfields=$field->subfields();
	foreach my $subfieldcount (0..$#subfields) {
	    my %row_data;
	    if ($lasttag== $field->tag()) {
		$row_data{tagid}   = "";
	    } else {
		$row_data{tagid}   = $field->tag();
	    }
	    $row_data{subfield} = $subfields[$subfieldcount][0];
	    $row_data{tagmean} = $tagmeaning->{$field->tag()}->{$subfields[$subfieldcount][0]};
	    $row_data{tagvalue}= $subfields[$subfieldcount][1];
	    if ($color ==0) {
		$color=1;
		$row_data{color} = $lc1;
	    } else {
		$color=0;
		$row_data{color} = $lc2;
	    }
	    push(@loop,\%row_data);
	    $lasttag=$field->tag();
	}
    }
    $template->param(MARC => \@loop);
    $template->param(numrecord => $numrecord);
    $template->param(file => $data);
    print "Content-Type: text/html\n\n", $template->output;
}

# lists all records from the MARC file
sub ListFileRecords {
    use strict;

    # Input parameters
    my (
	$dbh,		# FIXME - Unused argument
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
		# FIXME - there's already a $data a few lines above.

    $dbh = C4::Context->dbh;

    my $template=gettemplate('marcimport/ListFileRecords.tmpl');
    # File can be z3950 search query or uploaded MARC data

    # if z3950 results
    if (not $file=~/Z-(\d+)/) {
	# This is a Marc upload
	$sth=$dbh->prepare("select marc,name from uploadedmarc where id=$file");
	$sth->execute;
	($data, $name) = $sth->fetchrow;
	$template->param(IS_MARC => 1);
	$template->param(recordsource => $name);
    }

    if ($file=~/Z-(\d+)/) {
	# This is a z3950 search
	$template->param(IS_Z3950 =>1);
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
		if ( $server ) {
			my $srvname=&z3950servername($srvid,"$server/$database");
			$template->param(srvid => $srvid);
			$template->param(srvname => $srvname);
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
		    $template->param(HAS_NUMRECORDS => 1);
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
		    $template->param(startrecord => $startrecord+1);
		    $template->param(highest => $highest);
		    $template->param(numrecords => $numrecords);
		    $template->param(previous => $previous);
		    $template->param(next => $next);
		    my $stj=$dbh->prepare("update z3950results
			set highestseen=? where id=?");
		    $stj->execute($startrecord+10,$resultsid);
		}

		if (! $server ) {
		    $template->param(PENDING => 1);
		} elsif ($enddate == 0) {
		    my $now=time();
		    my $elapsed=$now-$startdate;
		    my $elapsedtime='';
		    if ($elapsed>60) {
			$elapsedtime=sprintf "%d minutes",($elapsed/60);
		    } else {
			$elapsedtime=sprintf "%d seconds",$elapsed;
		    }
		    $template->param(elapsedtime => $elapsedtime);
		} elsif ($numrecords) {
		    my @loop = ();
		    my $z3950file=MARC::File::USMARC->indata ($data);
		    while (my $record=$z3950file->next) {
			my $oldkoha = MARCmarc2koha($dbh,$record);
			my %row = ResultRecordLink($dbh,$oldkoha,$resultsid);
			push(@loop,\%row);
		    }
		    $template->param(LINES => \@loop);
		} else {
		}
#		print "</ul>\n";
	    } # foreach server
	    my $elapsed=time()-$starttimer;
#	    print "<hr>It took $elapsed seconds to process this page.\n";
	    } else {
		$template->param(NO_RECORDS =>1);
		$template->param(id => $id);
	    } # if rows

	} else {
#
# This is an uploaded Marc record
#
	    my @loop = ();
	    my $MARCfile = MARC::File::USMARC->indata($data);
	    my $num = 0;
	    while (my $record=$MARCfile->next) {
		$num++;
		my $oldkoha = MARCmarc2koha($dbh,$record);
		my %row = ResultRecordLink($dbh,$oldkoha,'',$num);
		push(@loop,\%row);
	    }
	    $template->param(LINES => \@loop);
	} # if z3950 or marc upload
	print "Content-Type: text/html\n\n", $template->output;
} # sub ListFileRecords

#--------------

sub ResultRecordLink {
    use strict;
    my ($dbh,$oldkoha,$resultsid, $num)=@_; 	# input
		# FIXME - $dbh as argument is no longer used
    my (
	$sth,
	$bib,	# hash ref to named fields
	$searchfield, $searchvalue,
	$donetext,
	$fieldname,
	);
    my %row = ();

    $dbh = C4::Context->dbh;

#    $bib=extractmarcfields($record);

    $sth=$dbh->prepare("select *
	  from biblioitems
	  where (isbn=? and isbn!='')  or (issn=? and issn!='')  or (lccn=? and lccn!='') ");
    $sth->execute($oldkoha->{isbn},$oldkoha->{issn},$oldkoha->{lccn});
    if ($sth->rows) {
	$donetext="DONE";
    } else {
	$donetext="";
    }
    ($oldkoha->{author}) && ($oldkoha->{author}="by $oldkoha->{author}");

    $searchfield="";
    foreach $fieldname ( "controlnumber", "lccn", "issn", "isbn") {
	if ( defined $oldkoha->{$fieldname} && $oldkoha->{$fieldname} ) {
	    $searchfield=$fieldname;
	    $searchvalue=$oldkoha->{$fieldname};
	} # if defined fieldname
    } # foreach
    if ( $searchfield ) {
	$row{SCRIPT_NAME} = $ENV{'SCRIPT_NAME'};
	$row{donetext}    = $donetext;
	$row{file}        = $file;
#	$row{resultsid}   = $resultsid;
#	$row{searchfield} = $searchfield;
#	$row{searchvalue} = $searchvalue;
	$row{numrecord}   = $num;
	$row{title}       = $oldkoha->{title};
	$row{author}      = $oldkoha->{author};
    } else {
	$row{title} = "Error: Problem with <br>$bib->{title} $bib->{author}<br>";
    } # if searchfield
    return %row;
} # sub PrintResultRecordLink

#---------------------------------

sub z3950menu {
    use strict;
    my (
	$dbh,			# FIXME - Unused argument
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

    $dbh = C4::Context->dbh;

    # FIXME - This print statement doesn't belong here. It's just here
    # so the script will display SOMEthing. But this section really
    # ought to be properly templated.
    print <<EOT;
Content-Type: text/html;

<HTML>
<BODY>
EOT

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
		# FIXME - There's already a $sth in this function.
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
    my ($dbh)=@_;		# FIXME - Unused argument

    $dbh = C4::Context->dbh;

    my $template=gettemplate('marcimport/uploadmarc.tmpl');
    $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
#    print "<a href=$ENV{'SCRIPT_NAME'}>Main Menu</a><hr>\n";
    my $sth=$dbh->prepare("select id,name from uploadedmarc");
    $sth->execute;
#    print "<h2>Select a set of MARC records</h2>\n<ul>";
    my @marc_loop = ();
    while (my ($id, $name) = $sth->fetchrow) {
	my %row;
	$row{id} = $id;
	$row{name} = $name;
	push(@marc_loop, \%row);
#	print "<li><a href=$ENV{'SCRIPT_NAME'}?file=$id&menu=$menu>$name</a><br>\n";
    }
    $template->param(marc => \@marc_loop);
    print "Content-Type: text/html\n\n", $template->output;

}

sub manual {
}


sub mainmenu {
	my $template=gettemplate('marcimport/mainmenu.tmpl');
	$template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
	print "Content-Type: text/html\n\n", $template->output;
} # sub mainmenu

#----------------------------
# Accept form results to add query to z3950 queue
sub AcceptZ3950Queue {
    use strict;

    # input parameters
    my (
	$dbh, 		# DBI handle
			# FIXME - Unused argument
	$input,		# CGI parms
    )=@_;

    my @serverlist;
    my $error;

    $dbh = C4::Context->dbh;

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

	$error=addz3950queue($input->param('query'), $input->param('type'),
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
			# FIXME - Unused argument
	$input,		# CGI parms
    )=@_;

    $dbh = C4::Context->dbh;

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
	$dbh,			# FIXME - Unused argument
	$input,
    )=@_;

    my $biblionumber=0;
    my $biblioitemnumber=0;
    my $sth;
    my $record;

    $dbh = C4::Context->dbh;

#    my $isbn=$input->param('isbn');
#    my $issn=$input->param('issn');
#    my $lccn=$input->param('lccn');
#    my $q_origisbn=$dbh->quote($input->param('origisbn'));
#    my $q_origissn=$dbh->quote($input->param('origissn'));
#    my $q_origlccn=$dbh->quote($input->param('origlccn'));
#    my $q_origcontrolnumber=$dbh->quote($input->param('origcontrolnumber'));
    my $title=$input->param('title');

#    my $q_isbn=$dbh->quote((($isbn) || ('NIL')));
#    my $q_issn=$dbh->quote((($issn) || ('NIL')));
#    my $q_lccn=$dbh->quote((($lccn) || ('NIL')));
    my $file= MARC::File::USMARC->indata($input->param('file'));
    my $numrecord = $input->param('numrecord');
    if ($numrecord) {
	for (my $i=1;$i<$numrecord;$i++) {
	    $record=$file->next;
	}
    } else {
	print STDERR "Error in marcimport.pl/Acceptbiblioitem : numrecord not defined\n";
	print "Error in marcimport.pl/Acceptbiblioitem : numrecord not defined : contact administrator\n";
    }
    my $template=gettemplate('marcimport/AcceptBiblioitem.tmpl');

    my $oldkoha = MARCmarc2koha($dbh,$record);
    # See if it already exists
    # FIXME - There's already a $sth in this context.
    my $sth=$dbh->prepare("select biblionumber,biblioitemnumber
	from biblioitems
	where isbn=? or issn=? or lccn=?");
    $sth->execute($oldkoha->{isbn},$oldkoha->{issn},$oldkoha->{lccn});
    if ($sth->rows) {
	# Already exists

	($biblionumber, $biblioitemnumber) = $sth->fetchrow;
	$template->param(title => $title);
	$template->param(biblionumber => $biblionumber);
	$template->param(biblioitemnumber => $biblioitemnumber);
	$template->param(BIBLIO_EXISTS => 1);

    } else {
	# It doesn't exist; add it.

  	my $error;
  	my %biblio;
  	my %biblioitem;

  	# convert to upper case and split on lines
  	my $subjectheadings=$input->param('subject');
  	my @subjectheadings=split(/[\r\n]+/,$subjectheadings);

  	my $additionalauthors=$input->param('additionalauthors');
  	my @additionalauthors=split(/[\r\n]+|\|/,uc($additionalauthors));

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
#	print STDERR $record->as_formatted();
#	die;
 	($biblionumber, $biblioitemnumber, $error)=
	    ALLnewbiblio($dbh,$record,\%biblio,\%biblioitem);
#	    (1,2,0);
#  	  newcompletebiblioitem($dbh,
# 		\%biblio,
# 		\%biblioitem,
# 		\@subjectheadings,
# 		\@additionalauthors
# 	);

 	if ( $error ) {
	    print "<H2>Error adding biblio item</H2> $error\n";
	} else {
	    $template->param(title => $title);
	    $template->param(biblionumber => $biblionumber);
	    $template->param(biblioitemnumber => $biblioitemnumber);
	    $template->param(BIBLIO_CREATE => 1);
	} # if error
    } # if new record
    my $barcode;

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
    $template->param(barcode => $barcode);
    $template->param(branchselect => $branchselect);
    print "Content-Type: text/html\n\n", $template->output;

} # sub ItemCopyForm

#---------------------------------------
# Accept form data to add an item copy
sub AcceptItemCopy {
    use strict;
    my ( $dbh, $input )=@_;
			# FIXME - $dbh argument unused

    my $template=gettemplate('marcimport/AcceptItemCopy.tmpl');

    my $error;

    $dbh = C4::Context->dbh;

    my $barcode=$input->param('barcode');
    my $replacementprice=($input->param('replacementprice') || 0);

    my $sth=$dbh->prepare("select barcode
	from items
	where barcode=?");
    $sth->execute($barcode);
    if ($sth->rows) {
	$template->param(BARCODE_EXISTS => 1);
	$template->param(barcode => $barcode);
    } else {
	   # Insert new item into database
           $error=&ALLnewitem($dbh,
			       { biblionumber=> $input->param('biblionumber'),
				 biblioitemnumber=> $input->param('biblioitemnumber'),
				 itemnotes=> $input->param('notes'),
				 homebranch=> $input->param('homebranch'),
				 replacementprice=> $replacementprice,
				 barcode => $barcode
				 }
			       );
            if ( $error ) {
		$template->param(ITEM_ERROR => 1);
		$template->param(error => $error);
	    } else {
		$template->param(ITEM_CREATED => 1);
		$template->param(barcode => $barcode);
            } # if error
    } # if barcode exists
    print "Content-Type: text/html\n\n", $template->output;
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
# Revision 1.2  2003/02/19 01:01:11  wolfpac444
# Removed the unecessary $dbh argument from being passed.
# Resolved a few minor FIXMEs.
#
# Revision 1.1  2002/11/22 10:15:22  tipaul
# moving z3950 related scripts to specific dir
#
# Revision 1.18  2002/10/14 07:41:04  tipaul
# merging arens + my modifs/bugfixes
#
# Revision 1.17  2002/10/13 07:39:26  arensb
# Added magic RCS comment.
# Removed trailing whitespace.
#
# Revision 1.16  2002/10/11 12:45:10  arensb
# Replaced &requireDBI with C4::Context->dbh, thus making the "use
# Fixed muffed quotes in &gettemplate calls.
# Added a temporary print statement in &z3950menu, so it'll print
# something instead of giving a browser error.
#
# Revision 1.15  2002/10/09 18:09:16  tonnesen
# switched from picktemplate() to gettemplate()
#
# Revision 1.14  2002/10/05 09:56:14  arensb
# Merged with arensb-context branch: use C4::Context->dbh instead of
# &C4Connect, and generally prefer C4::Context over C4::Database.
#
# Revision 1.13.2.1  2002/10/04 02:52:50  arensb
# Use C4::Connect instead of C4::Database, C4::Connect->dbh instead
# C4Connect.
# Removed old code for reading /etc/koha.conf.
#
# Revision 1.13  2002/08/14 18:12:52  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.12  2002/07/24 16:24:20  tipaul
# Now, the acqui.simple system...
# marcimport.pl has been almost completly rewritten, so LOT OF BUGS TO COME !!! You've been warned. It seems to work, but...
#
# As with my former messages, nothing seems to have been changed... but ...
# * marcimport now uses HTML::Template.
# * marcimport now uses MARC::Record. that means that when you import a record, the old-DB is populated with the data as in version 1.2, but the MARC-DB part is filled with full MARC::Record.
#
# <IMPORTANT NOTE>
# to get correct response times, you MUST add an index on isbn, issn and lccn rows in biblioitem table. Note this should be done in 1.2 too...
# </IMPORTANT NOTE>
#
# <IMPORTANT NOTE2>
# acqui.simple manage biblio, biblioitems and items tables quite properly. Normal acquisition system manages biblio, biblioitems BUT NOT items. That will be done in the near future...
# </IMPORTANT NOTE2>
#
# what's next now ?
# * bug tracking, of course... Surely a dozen of dozens...
# * LOT of developpments, i'll surely write a mail to koha-devel tomorrow (as it's time for dinner in France, and i plan to play NeverwinterNights after dinner ;-) ...
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
