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
#use C4::Database;
#use C4::Acquisitions;
use C4::Output;
use C4::Input;
use C4::Biblio;
#use C4::SimpleMarc;
#use C4::Z3950;
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

my $uploadmarc=$input->param('uploadmarc');
my $overwrite_biblio = $input->param('overwrite_biblio');
my $filename = $input->param('filename');

my $template = gettemplate("acqui.simple/marcimport.tmpl");
$template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'},
						uploadmarc => $uploadmarc);
if ($uploadmarc && length($uploadmarc)>0) {
	my $marcrecord='';
	while (<$uploadmarc>) {
		$marcrecord.=$_;
	}
	my @marcarray = split /\x1D/, $marcrecord;
	my $dbh = C4::Context->dbh;
	my $searchisbn = $dbh->prepare("select biblioitemnumber from biblioitems where isbn=?");
	my $searchissn = $dbh->prepare("select biblioitemnumber from biblioitems where issn=?");
	my $searchbreeding = $dbh->prepare("select isbn from marc_breeding where isbn=?");
	my $insertsql = $dbh->prepare("replace into marc_breeding (file,isbn,marc) values(?,?,?)");
	# fields used for import results
	my $imported=0;
	my $alreadyindb = 0;
	my $alreadyinfarm = 0;
	my $notmarcrecord = 0;
	for (my $i=0;$i<=$#marcarray;$i++) {
		my $marcrecord = MARC::File::USMARC::decode($marcarray[$i]."\x1D");
		if (ref($marcrecord) eq undef) {
			$notmarcrecord++;
		} else {
			my $oldbiblio = MARCmarc2koha($dbh,$marcrecord);
			# if isbn found and biblio does not exist, add it. If isbn found and biblio exists, overwrite or ignore depending on user choice
			if ($oldbiblio->{isbn} || $oldbiblio->{issn}) {
				# drop every "special" char : spaces, - ...
				$oldbiblio->{isbn} =~ s/ |-|\.//g,
				# search if biblio exists
				my $biblioitemnumber;
				if ($oldbiblio->{isbn}) {
					$searchisbn->execute($oldbiblio->{isbn});
					($biblioitemnumber) = $searchisbn->fetchrow;
				} else {
					$searchissn->execute($oldbiblio->{issn});
					($biblioitemnumber) = $searchissn->fetchrow;
				}
				if ($biblioitemnumber) {
					$alreadyindb++;
				} else {
				# search in breeding farm
				my $breedingresult;
					if ($oldbiblio->{isbn}) {
						$searchbreeding->execute($oldbiblio->{isbn});
						($breedingresult) = $searchbreeding->fetchrow;
					} else {
						$searchbreeding->execute($oldbiblio->{issn});
						($breedingresult) = $searchbreeding->fetchrow;
					}
					if (!$breedingresult || $overwrite_biblio) {
						my $recoded;
#						warn "IMPORT => $marcarray[$i]\x1D')";
						$recoded = $marcrecord->as_usmarc(); #MARC::File::USMARC::encode($marcrecord);
#						warn "RECODED : $recoded";
						$insertsql ->execute($filename,$oldbiblio->{isbn}.$oldbiblio->{issn},$recoded);
						$imported++;
					} else {
						$alreadyinfarm++;
					}
				}
			} else {
				$notmarcrecord++;
			}
		}
	}
	$template->param(imported => $imported,
							alreadyindb => $alreadyindb,
							alreadyinfarm => $alreadyinfarm,
							notmarcrecord => $notmarcrecord,
							total => $imported+$alreadyindb+$alreadyinfarm+$notmarcrecord,
							);

}

print "Content-Type: text/html\n\n",$template->output;
my $menu;
my $file;

# Process a MARC file : show list of records, of 1 record detail, if numrecord exists
sub ProcessFile {
    # A MARC file has been specified; process it for review form
    use strict;
    # Input params
    my (
	$input,
    )=@_;

    # local vars
    my (
	$sth,
	$record,
    );

    my $debug=0;

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
    for (my $i=1;$i<$numrecord;$i++) {
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
			my $srvname=&z3950servername($dbh,$srvid,"$server/$database");
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
			# FIXME - WTF are the additional authors
			# converted to upper case?

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
# log cleared, as marcimport is (almost) rewritten from scratch.
# $Log$
# Revision 1.23  2003/01/06 13:06:28  tipaul
# removing trailing #
#
# Revision 1.22  2002/11/12 15:58:43  tipaul
# road to 1.3.2 :
# * many bugfixes
# * adding value_builder : you can map a subfield in the marc_subfield_structure to a sub stored in "value_builder" directory. In this directory you can create screen used to build values with any method. In this commit is a 1st draft of the builder for 100$a unimarc french subfield, which is composed of 35 digits, with 12 differents values (only the 4th first are provided for instance)
#
# Revision 1.21  2002/10/22 15:50:23  tipaul
# road to 1.3.2 : adding a biblio in MARC format.
# seems to work a few.
# still to do :
# * manage html checks (mandatory subfields...)
# * add list of acceptable values (authorities)
# * manage ## in MARC format
# * manage correctly repeatable fields
# and probably a LOT of bugfixes
#
# Revision 1.20  2002/10/16 12:46:19  arensb
# Added a FIXME comment.
#
# Revision 1.19  2002/10/15 10:14:44  tipaul
# road to 1.3.2. Full rewrite of marcimport.pl.
# The acquisition system in MARC version will work like this :
# * marcimport will put marc records into a "breeding farm" table.
# * when the user want to add a biblio, he enters first the ISBN/ISSN of the biblio. koha searches into breeding farm and if the record exists, it is shown to the user to help him adding the biblio. When the biblio is added, it's deleted from the breeding farm.
#
# This commit :
# * modify acqui.simple home page  (addbooks.pl)
# * adds import into breeding farm
#
# Please note that :
# * z3950 functionnality is dropped from "marcimport" will be added somewhere else.
# * templates are in a new acqui.simple sub directory, and the marcimport template directory will become obsolete soon.I think this is more logic
#
