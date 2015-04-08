#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

# Modification by D.Ulm, actually works (as long as indep. branches not turned on)
#		Someone let me know what indep. branches is supposed to do and I'll make that part work too
#
# 		The reserve pull lists *works* as long as not for indepencdant branches, I can fix!

use strict;
#use warnings; FIXME - Bug 2505

use constant TWO_DAYS => 2;
use constant TWO_DAYS_AGO => -2;

use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use Date::Calc qw/Today Add_Delta_YMD/;

my $input = new CGI;
my $startdate=$input->param('from');
my $enddate=$input->param('to');
my $run_report = ( not defined $input->param('run_report') ) ? 1 : $input->param('run_report');

my $theme = $input->param('theme');    # only used if allowthemeoverride is set

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/pendingreserves.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
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
$startdate =~ s/^\s+//;
$startdate =~ s/\s+$//;
$enddate =~ s/^\s+//;
$enddate =~ s/\s+$//;

if (!defined($startdate) or $startdate eq "") {
    # changed from delivered range of 10 years-yesterday to 2 days ago-today
    # Find two days ago for the default shelf pull start date, unless HoldsToPullStartDate sys pref is set.
    my $pastdate= sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day, 0, 0, -C4::Context->preference('HoldsToPullStartDate')||TWO_DAYS_AGO ));
    $startdate = format_date($pastdate);
}

if (!defined($enddate) or $enddate eq "") {
    #similarly: calculate end date with ConfirmFutureHolds (days)
    my $d=sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day, 0, 0, C4::Context->preference('ConfirmFutureHolds')||0 ));
    $enddate = format_date($d);
}

my @reservedata;
if ( $run_report ) {
    my $dbh    = C4::Context->dbh;
    my $sqldatewhere = "";
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
            GROUP_CONCAT(DISTINCT items.itype 
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_itype,
            GROUP_CONCAT(DISTINCT items.location 
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_location,
            GROUP_CONCAT(DISTINCT items.itemcallnumber 
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_itemcallnumber,
            GROUP_CONCAT(DISTINCT items.enumchron
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_enumchron,
            GROUP_CONCAT(DISTINCT items.copynumber
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_copynumber,
            items.itemnumber,
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
        LEFT JOIN issues ON items.itemnumber=issues.itemnumber
    WHERE
    reserves.found IS NULL
    $sqldatewhere
    AND (reserves.itemnumber IS NULL OR reserves.itemnumber = items.itemnumber)
    AND items.itemnumber NOT IN (SELECT itemnumber FROM branchtransfers where datearrived IS NULL)
    AND items.itemnumber NOT IN (select itemnumber FROM reserves where found='W')
    AND issues.itemnumber IS NULL
    AND reserves.priority <> 0 
    AND reserves.suspend = 0
    AND notforloan = 0 AND damaged = 0 AND itemlost = 0 AND withdrawn = 0
    ";
    # GROUP BY reserves.biblionumber allows only items that are not checked out, else multiples occur when 
    #    multiple patrons have a hold on an item


    if (C4::Context->preference('IndependentBranches')){
        $strsth .= " AND items.holdingbranch=? ";
        push @query_params, C4::Context->userenv->{'branch'};
    }
    $strsth .= " GROUP BY reserves.biblionumber ORDER BY biblio.title ";

    my $sth = $dbh->prepare($strsth);
    $sth->execute(@query_params);

    while ( my $data = $sth->fetchrow_hashref ) {
        push(
            @reservedata,
            {
                reservedate     => $data->{l_reservedate},
                priority        => $data->{priority},
                name            => $data->{l_patron},
                title           => $data->{title},
                author          => $data->{author},
                borrowernumber  => $data->{borrowernumber},
                itemnum         => $data->{itemnumber},
                phone           => $data->{phone},
                email           => $data->{email},
                biblionumber    => $data->{biblionumber},
                statusw         => ( $data->{found} eq "W" ),
                statusf         => ( $data->{found} eq "F" ),
                holdingbranch   => $data->{l_holdingbranch},
                branch          => $data->{l_branch},
                itemcallnumber  => $data->{l_itemcallnumber},
                enumchron       => $data->{l_enumchron},
                copyno          => $data->{l_copynumber},
                notificationdate=> $data->{notificationdate},
                reminderdate    => $data->{reminderdate},
                count           => $data->{icount},
                rcount          => $data->{rcount},
                pullcount       => $data->{icount} <= $data->{rcount} ? $data->{icount} : $data->{rcount},
                itype           => $data->{l_itype},
                location        => $data->{l_location},
            }
        );
    }
    $sth->finish;
}

$template->param(
    todaysdate          => $todaysdate,
    from                => $startdate,
    to                  => $enddate,
    run_report          => $run_report,
    reserveloop         => \@reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    HoldsToPullStartDate=> C4::Context->preference('HoldsToPullStartDate')||TWO_DAYS,
    HoldsToPullEndDate  => C4::Context->preference('ConfirmFutureHolds')||0,
);

output_html_with_http_headers $input, $cookie, $template->output;
