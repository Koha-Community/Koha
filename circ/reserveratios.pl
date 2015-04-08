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

use strict;
use warnings;

use CGI;
use Date::Calc qw/Today Add_Delta_YM/;

use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use C4::Biblio qw/GetMarcBiblio GetRecordValue GetFrameworkCode/;
use C4::Acquisition qw/GetOrdersByBiblionumber/;

my $input = new CGI;
my $startdate       = $input->param('from');
my $enddate         = $input->param('to');
my $ratio           = $input->param('ratio');
my $include_ordered = $input->param('include_ordered');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/reserveratios.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $booksellerid = $input->param('booksellerid') // '';
my $basketno = $input->param('basketno') // '';
if ($booksellerid && $basketno) {
     $template->param( booksellerid => $booksellerid, basketno => $basketno );
}

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
if (!defined($ratio)) {
	$ratio = 3;
}
# Force to be a number
$ratio += 0;
if ($ratio <= 0) {
    $ratio = 1; # prevent division by zero
}

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

my $nfl_comparison = $include_ordered ? '<=' : '=';
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

        reserves.found,
        biblio.title,
        biblio.author,
        count(DISTINCT reserves.borrowernumber) as reservecount, 
        count(DISTINCT items.itemnumber) as itemcount 
 FROM  reserves
 LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
 LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
 WHERE
 notforloan $nfl_comparison 0 AND damaged = 0 AND itemlost = 0 AND withdrawn = 0
 $sqldatewhere
";

if (C4::Context->preference('IndependentBranches')){
    $strsth .= " AND items.holdingbranch=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}

$strsth .= " GROUP BY reserves.biblionumber ORDER BY reservecount DESC";

$template->param(sql => $strsth);
my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

my $ratio_atleast1 = ($ratio >= 1) ? 1 : 0;
my @reservedata;
while ( my $data = $sth->fetchrow_hashref ) {
    my $thisratio = $data->{reservecount} / $data->{itemcount};
    my $ratiocalc = ($thisratio / $ratio);
    ($thisratio / $ratio) >= 1 or next;  # TODO: tighter targeting -- get ratio limit into SQL using HAVING clause
    my $record = GetMarcBiblio($data->{biblionumber});
    $data->{subtitle} = GetRecordValue('subtitle', $record, GetFrameworkCode($data->{biblionumber}));
    push(
        @reservedata,
        {
            reservedate      => format_date( $data->{reservedate} ),
            priority         => $data->{priority},
            name             => $data->{borrower},
            title            => $data->{title},
            subtitle            => $data->{subtitle},
            author           => $data->{author},
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

for my $rd ( @reservedata ) {
    next unless $rd->{biblionumber};
    $rd->{pendingorders} = CountPendingOrdersByBiblionumber( $rd->{biblionumber} );
}

$template->param(
    ratio_atleast1  => $ratio_atleast1,
    todaysdate      => format_date($todaysdate),
    from            => $startdate,
    to              => $enddate,
    ratio           => $ratio,
    include_ordered => $include_ordered,
    reserveloop     => \@reservedata,
);

output_html_with_http_headers $input, $cookie, $template->output;

sub CountPendingOrdersByBiblionumber {
    my $biblionumber = shift;
    my @orders = GetOrdersByBiblionumber( $biblionumber );
    my $cnt = 0;
    if (scalar(@orders)) {
        for my $order ( @orders ) {
            next if $order->{datecancellationprinted};
            my $onum = $order->{quantity} // 0;
            my $rnum = $order->{quantityreceived} // 0;
            next if $rnum >= $onum;
            $cnt += ($onum - $rnum);
        }
    }
    return $cnt;
}
