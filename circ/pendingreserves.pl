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

use Modern::Perl;

use constant PULL_INTERVAL => 2;

use C4::Context;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Auth;
use Koha::Biblios;
use C4::Debug;
use Koha::DateUtils;
use DateTime::Duration;

my $input = new CGI;
my $startdate = $input->param('from');
my $enddate = $input->param('to');

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

my $today = dt_from_string;

if ( $startdate ) {
    $startdate =~ s/^\s+//;
    $startdate =~ s/\s+$//;
    $startdate = eval{dt_from_string( $startdate )};
}
unless ( $startdate ){
    # changed from delivered range of 10 years-yesterday to 2 days ago-today
    # Find two days ago for the default shelf pull start date, unless HoldsToPullStartDate sys pref is set.
    $startdate = $today - DateTime::Duration->new( days => C4::Context->preference('HoldsToPullStartDate') || PULL_INTERVAL );
}

if ( $enddate ) {
    $enddate =~ s/^\s+//;
    $enddate =~ s/\s+$//;
    $enddate = eval{dt_from_string( $enddate )};
}
unless ( $enddate ) {
    #similarly: calculate end date with ConfirmFutureHolds (days)
    $enddate = $today + DateTime::Duration->new( days => C4::Context->preference('ConfirmFutureHolds') || 0 );
}

my @reservedata;
my $dbh = C4::Context->dbh;
my $sqldatewhere = "";
my $startdate_iso = output_pref({ dt => $startdate, dateformat => 'iso', dateonly => 1 });
my $enddate_iso   = output_pref({ dt => $enddate, dateformat => 'iso', dateonly => 1 });

$debug and warn $startdate_iso. "\n" . $enddate_iso;

my @query_params = ();

if ($startdate_iso) {
    $sqldatewhere .= " AND reservedate >= ?";
    push @query_params, $startdate_iso;
}
if ($enddate_iso) {
    $sqldatewhere .= " AND reservedate <= ?";
    push @query_params, $enddate_iso;
}

my $item_type = C4::Context->preference('item-level_itypes') ? "items.itype" : "biblioitems.itemtype";

# Bug 21320
if ( ! C4::Context->preference('AllowHoldsOnDamagedItems') ) {
    $sqldatewhere .= " AND damaged = 0";
}

my $strsth =
    "SELECT min(reservedate) as l_reservedate,
            reserves.borrowernumber as borrowernumber,
            GROUP_CONCAT(DISTINCT items.holdingbranch 
                    ORDER BY items.itemnumber SEPARATOR '|') l_holdingbranch,
            reserves.biblionumber,
            reserves.branchcode as l_branch,
            GROUP_CONCAT(DISTINCT $item_type
                    ORDER BY items.itemnumber SEPARATOR '|') l_item_type,
            GROUP_CONCAT(DISTINCT items.location 
                    ORDER BY items.itemnumber SEPARATOR '|') l_location,
            GROUP_CONCAT(DISTINCT items.itemcallnumber 
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_itemcallnumber,
            GROUP_CONCAT(DISTINCT items.enumchron
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_enumchron,
            GROUP_CONCAT(DISTINCT items.copynumber
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_copynumber,
            biblio.title,
            biblio.author,
            count(DISTINCT items.itemnumber) as icount,
            count(DISTINCT reserves.borrowernumber) as rcount,
            borrowers.firstname,
            borrowers.surname
    FROM  reserves
        LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
        LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
        LEFT JOIN biblioitems ON biblio.biblionumber=biblioitems.biblionumber
        LEFT JOIN branchtransfers ON items.itemnumber=branchtransfers.itemnumber
        LEFT JOIN issues ON items.itemnumber=issues.itemnumber
        LEFT JOIN borrowers ON reserves.borrowernumber=borrowers.borrowernumber
    WHERE
    reserves.found IS NULL
    $sqldatewhere
    AND (reserves.itemnumber IS NULL OR reserves.itemnumber = items.itemnumber)
    AND items.itemnumber NOT IN (SELECT itemnumber FROM branchtransfers where datearrived IS NULL)
    AND items.itemnumber NOT IN (select itemnumber FROM reserves where found IS NOT NULL)
    AND issues.itemnumber IS NULL
    AND reserves.priority <> 0 
    AND reserves.suspend = 0
    AND notforloan = 0 AND itemlost = 0 AND withdrawn = 0
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
    my $record = Koha::Biblios->find($data->{biblionumber});
    if ($record){
        $data->{subtitle} = [ $record->subtitles ];
    }
    push(
        @reservedata, {
            reservedate     => $data->{l_reservedate},
            firstname       => $data->{firstname} || '',
            surname         => $data->{surname},
            title           => $data->{title},
            subtitle        => $data->{subtitle},
            author          => $data->{author},
            borrowernumber  => $data->{borrowernumber},
            biblionumber    => $data->{biblionumber},
            holdingbranches => [split('\|', $data->{l_holdingbranch})],
            branch          => $data->{l_branch},
            itemcallnumber  => $data->{l_itemcallnumber},
            enumchron       => $data->{l_enumchron},
            copyno          => $data->{l_copynumber},
            count           => $data->{icount},
            rcount          => $data->{rcount},
            pullcount       => $data->{icount} <= $data->{rcount} ? $data->{icount} : $data->{rcount},
            itemTypes       => [split('\|', $data->{l_item_type})],
            locations       => [split('\|', $data->{l_location})],
        }
    );
}
$sth->finish;

$template->param(
    todaysdate          => $today,
    from                => $startdate,
    to                  => $enddate,
    reserveloop         => \@reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    HoldsToPullStartDate => C4::Context->preference('HoldsToPullStartDate') || PULL_INTERVAL,
    HoldsToPullEndDate  => C4::Context->preference('ConfirmFutureHolds') || 0,
);

output_html_with_http_headers $input, $cookie, $template->output;
