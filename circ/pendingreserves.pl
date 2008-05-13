#!/usr/bin/perl


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

# Modification by D.Ulm, actually works (as long as indep. branches not turned on)
#		Someone let me know what indep. branches is supposed to do and I'll make that part work too
#
# 		The reserve pull lists *works* as long as not for indepencdant branches, I can fix!

use strict;
use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use Date::Calc qw/Today Add_Delta_YMD/;

my $input = new CGI;
my $order = $input->param('order');
my $startdate=$input->param('from');
my $enddate=$input->param('to');

my $theme = $input->param('theme');    # only used if allowthemeoverride is set

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/pendingreserves.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
        debug           => 1,
    }
);

my $duedate;
my $borrowernumber;
my $itemnum;
my $data1;
my $data2;
my $data3;
my $name;
my $phone;
my $email;
my $biblionumber;
my $title;
my $author;

my ( $year, $month, $day ) = Today();
my $todaysdate     = sprintf("%-04.4d-%-02.2d-%02.2d", $year, $month, $day);
my $yesterdaysdate = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day,   0, 0, -1));
# Find 10 years ago for the default shelf pull start and end dates
#    A default of the prior day's holds is a reasonable way to pull holds 
my $pastdate       = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day, -10, 0,  0));

#		Predefine the start and end dates if they are not already defined
$startdate =~ s/^\s+//;
$startdate =~ s/\s+$//;
$enddate =~ s/^\s+//;
$enddate =~ s/\s+$//;
#		Check if null, should string match, if so set start and end date to yesterday
if (!defined($startdate) or $startdate eq "") {
	$startdate = format_date($pastdate);
}
if (!defined($enddate) or $enddate eq "") {
	$enddate = format_date($yesterdaysdate);
}


my $dbh    = C4::Context->dbh;
my ($sqlorderby, $sqldatewhere) = ("","");
$debug and warn format_date_in_iso($startdate) . "\n" . format_date_in_iso($enddate);
my @query_params = ();
if ($startdate) {
    $sqldatewhere .= " AND reservedate >= ?";
    push @query_params, format_date_in_iso($startdate);
}
if ($enddate) {
    $sqldatewhere .= " AND reservedate <= ?";
    push @query_params, format_date_in_iso($enddate);
}

if ($order eq "biblio") {
	$sqlorderby = " ORDER BY biblio.title ";
} elsif ($order eq "itype") {
	$sqlorderby = " ORDER BY l_itype, location, l_itemcallnumber ";
} elsif ($order eq "location") {
	$sqlorderby = " ORDER BY location, l_itemcallnumber, holdingbranch ";
} elsif ($order eq "date") {
    $sqlorderby = " ORDER BY l_reservedate, location, l_itemcallnumber ";
} elsif ($order eq "library") {
    $sqlorderby = " ORDER BY holdingbranch, l_itemcallnumber, location ";
} elsif ($order eq "call") {
    $sqlorderby = " ORDER BY l_itemcallnumber, holdingbranch, location ";    
} else {
	$sqlorderby = " ORDER BY biblio.title ";
}
my $strsth =
"SELECT min(reservedate) as l_reservedate,
        reserves.borrowernumber as borrowernumber,
        GROUP_CONCAT(DISTINCT items.holdingbranch 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') l_holdingbranch,
        reserves.biblionumber,
        reserves.branchcode,
        GROUP_CONCAT(DISTINCT reserves.branchcode 
        		ORDER BY items.itemnumber SEPARATOR ', ') l_branch,
        items.holdingbranch as branch,
        items.itemcallnumber,
        GROUP_CONCAT(DISTINCT items.itype 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') l_itype,
        GROUP_CONCAT(DISTINCT items.location 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') l_location,
        GROUP_CONCAT(DISTINCT items.itemcallnumber 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') l_itemcallnumber,
        items.itemnumber,
        notes,
        notificationdate,
        reminderdate,
        max(priority) as priority,
        reserves.found,
        biblio.title,
        biblio.author,
        count(DISTINCT items.itemnumber) as icount,
        count(DISTINCT reserves.borrowernumber) as rcount
 FROM  reserves
	LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
	LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
	LEFT JOIN branchtransfers ON items.itemnumber=branchtransfers.itemnumber
 WHERE
reserves.found IS NULL
 $sqldatewhere
AND items.itemnumber NOT IN (SELECT itemnumber FROM branchtransfers where datearrived IS NULL)
AND items.itemnumber NOT IN (SELECT itemnumber FROM issues)
AND reserves.priority <> 0 
AND notforloan = 0 AND damaged = 0 AND itemlost = 0 AND wthdrawn = 0
";
# GROUP BY reserves.biblionumber allows only items that are not checked out, else multiples occur when 
#    multiple patrons have a hold on an item


if (C4::Context->preference('IndependantBranches')){
	$strsth .= " AND items.holdingbranch=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}
$strsth .= " GROUP BY reserves.biblionumber " . $sqlorderby;

my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

my @reservedata;
my $previous;
my $this;
while ( my $data = $sth->fetchrow_hashref ) {
    $this=$data->{biblionumber}.":".$data->{borrowernumber};
    my @itemlist;
    push(
        @reservedata,
        {
            reservedate      => format_date( $data->{l_reservedate} ),
            priority         => $data->{priority},
            name             => $data->{l_patron},
            title            => $data->{title},
            author           => $data->{author},
            borrowernumber   => $data->{borrowernumber},
            itemnum          => $data->{itemnumber},
            phone            => $data->{phone},
            email            => $data->{email},
            biblionumber     => $data->{biblionumber},
            statusw          => ( $data->{found} eq "W" ),
            statusf          => ( $data->{found} eq "F" ),
            holdingbranch    => $data->{l_holdingbranch},
            branch           => $data->{l_branch},
            itemcallnumber   => $data->{l_itemcallnumber},
            notes            => $data->{notes},
            notificationdate => $data->{notificationdate},
            reminderdate     => $data->{reminderdate},
            count				  => $data->{icount},
            rcount			  => $data->{rcount},
            pullcount		  => $data->{icount} <= $data->{rcount} ? $data->{icount} : $data->{rcount},
            itype				  => $data->{l_itype},
            location			  => $data->{l_location}
        }
    );
    $previous=$this;
}

$sth->finish;

# *** I doubt any of this is needed now with the above fixes *** -d.u.

#$strsth=~ s/AND reserves.itemnumber is NULL/AND reserves.itemnumber is NOT NULL/;
#$strsth=~ s/LEFT JOIN items ON items.biblionumber=reserves.biblionumber/LEFT JOIN items ON items.biblionumber=reserves.itemnumber/;
#$sth = $dbh->prepare($strsth);
#if (C4::Context->preference('IndependantBranches')){
#       $sth->execute(C4::Context->userenv->{'branch'});
#}
#else {
#       $sth->execute();
#}
#while ( my $data = $sth->fetchrow_hashref ) {
#    $this=$data->{biblionumber}.":".$data->{borrowernumber};
#    my @itemlist;
#    push(
#        @reservedata,
#        {
#            reservedate      => format_date( $data->{l_reservedate} ),
#            priority         => $data->{priority},
#            name             => $data->{l_patron},
#            title            => $data->{title},
#            author           => $data->{author},
#            borrowernumber   => $data->{borrowernumber},
#            itemnum          => $data->{itemnumber},
#            phone            => $data->{phone},
#            email            => $data->{email},
#            biblionumber     => $data->{biblionumber},
#            statusw          => ( $data->{found} eq "W" ),
#            statusf          => ( $data->{found} eq "F" ),
#            holdingbranch    => $data->{l_holdingbranch},
#            branch           => $data->{l_branch},
#            itemcallnumber   => $data->{l_itemcallnumber},
#            notes            => $data->{notes},
#            notificationdate => $data->{notificationdate},
#            reminderdate     => $data->{reminderdate},
#            count				  => $data->{icount},
#            rcount			  => $data->{rcount},
#            pullcount		  => $data->{icount} <= $data->{rcount} ? $data->{icount} : $data->{rcount},
#            itype				  => $data->{l_itype},
#            location			  => $data->{l_location},
#            thisitemonly     => 1,
# 
#        }
#    );
#    $previous=$this;
#}
#$sth->finish;

$template->param(
    todaysdate      	=> format_date($todaysdate),
    from             => $startdate,
    to              	=> $enddate,
    reserveloop     	=> \@reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
	dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;
