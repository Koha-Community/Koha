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

use strict;
use warnings;

use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use Date::Calc qw/Today Add_Delta_YM/;

my $input = new CGI;
my $order     = $input->param('order') || '';
my $startdate = $input->param('from');
my $enddate   = $input->param('to');
my $ratio     = $input->param('ratio');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/reserveratios.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my ( $year, $month, $day ) = Today();
my $todaysdate     = sprintf("%-04.4d-%-02.2d-%02.2d", $year, $month, $day);
# Find yesterday for the default shelf pull start and end dates
#    A default of the prior years's holds is a reasonable way to pull holds 
my $datelastyear = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YM($year, $month, $day, -1, 0));

#		Predefine the start and end dates if they are not already defined
#		Check if null, should string match, if so set start and end date to yesterday
if (!defined($startdate) or $startdate !~ s/^\s*(\S+)\s*$/$1/) {   # strip spaces, remove Taint
	$startdate = format_date($datelastyear);
}
if (!defined($enddate)   or $enddate   !~ s/^\s*(\S+)\s*$/$1/) {   # strip spaces, remove Taint
	$enddate   = format_date($todaysdate);
}
if (!defined($ratio)     or $ratio     !~ s/^\s*(0?\.?\d+)(\.0*)?\s*$/$1/) {   # strip spaces, remove Taint
	$ratio = 3;
}
if ($ratio == 0) {
    $ratio = 1; # prevent division by zero
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
	$sqlorderby = " ORDER BY biblio.title, holdingbranch, listcall, l_location ";
} elsif ($order eq "callnumber") {
    $sqlorderby = " ORDER BY listcall, holdingbranch, l_location ";
} elsif ($order eq "itemcount") {
    $sqlorderby = " ORDER BY itemcount, reservecount ";
} elsif ($order eq "itype") {
    $sqlorderby = " ORDER BY l_itype, holdingbranch, listcall ";
} elsif ($order eq "location") {
    $sqlorderby = " ORDER BY l_location, holdingbranch, listcall ";
} elsif ($order eq "reservecount") {
    $sqlorderby = " ORDER BY reservecount DESC ";
} elsif ($order eq "branch") {
    $sqlorderby = " ORDER BY holdingbranch, l_location, listcall ";
} else {
	$sqlorderby = " ORDER BY reservecount DESC ";
}
my $strsth =
"SELECT reservedate,
        reserves.borrowernumber as borrowernumber,
        reserves.biblionumber,
        reserves.branchcode as branch,
        items.holdingbranch,
        items.itemcallnumber,
        items.itemnumber,
        GROUP_CONCAT(DISTINCT items.itemcallnumber 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') as listcall,
        GROUP_CONCAT(DISTINCT holdingbranch 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') as listbranch,
        GROUP_CONCAT(DISTINCT items.location 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') as l_location,
        GROUP_CONCAT(DISTINCT items.itype 
        		ORDER BY items.itemnumber SEPARATOR '<br/>') as l_itype,
        notes,
        reserves.found,
        biblio.title,
        biblio.author,
        count(DISTINCT reserves.borrowernumber) as reservecount, 
        count(DISTINCT items.itemnumber) as itemcount 
 FROM  reserves
 LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
 LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
 WHERE 
notforloan = 0 AND damaged = 0 AND itemlost = 0 AND wthdrawn = 0
 $sqldatewhere
";

if (C4::Context->preference('IndependantBranches')){
	$strsth .= " AND items.holdingbranch=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}

$strsth .= " GROUP BY reserves.biblionumber " . $sqlorderby;

$template->param(sql => $strsth);
my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

my $ratio_atleast1 = ($ratio >= 1) ? 1 : 0;
my @reservedata;
while ( my $data = $sth->fetchrow_hashref ) {
    my $thisratio = $data->{reservecount} / $data->{itemcount};
    my $ratiocalc = ($thisratio / $ratio);
    ($thisratio / $ratio) >= 1 or next;  # TODO: tighter targeting -- get ratio limit into SQL using HAVING clause
    push(
        @reservedata,
        {
            reservedate      => format_date( $data->{reservedate} ),
            priority         => $data->{priority},
            name             => $data->{borrower},
            title            => $data->{title},
            author           => $data->{author},
            notes            => $data->{notes},
            itemnum          => $data->{itemnumber},
            biblionumber     => $data->{biblionumber},
            holdingbranch    => $data->{holdingbranch},
            listbranch       => $data->{listbranch},
            branch           => $data->{branch},
            itemcallnumber   => $data->{itemcallnumber},
            location         => $data->{l_location},
            itype            => $data->{l_itype},
            reservecount     => $data->{reservecount},
            itemcount        => $data->{itemcount},
            ratiocalc        => sprintf("%.0d", $ratio_atleast1 ? ($thisratio / $ratio) : $thisratio),
            thisratio        => sprintf("%.2f", $thisratio),
            thisratio_atleast1 => ($thisratio >= 1) ? 1 : 0,
            listcall         => $data->{listcall}    
        }
    );
}

$template->param(
    ratio_atleast1  => $ratio_atleast1,
    todaysdate      => format_date($todaysdate),
    from            => $startdate,
    to              => $enddate,
    ratio           => $ratio,
    reserveloop     => \@reservedata,
    DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
);

output_html_with_http_headers $input, $cookie, $template->output;
