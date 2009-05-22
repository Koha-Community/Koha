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
my $startdate = $input->param('from')  || '';
my $enddate   = $input->param('to')    || '';
my $max_bill  = $input->param('ratio') || C4::Context->preference('noissuescharge') || 20.00;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/billing.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my ( $year, $month, $day ) = Today();
my $todaysdate   = sprintf("%-04.4d-%-02.2d-%02.2d", $year, $month, $day);
# Find yesterday for the default shelf pull start and end dates
#    A default of the prior years's holds is a reasonable way to pull holds 
my $datelastyear = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YM($year, $month, $day, -1, 0));

$startdate =~ s/^\s+//;
$startdate =~ s/\s+$//;
$enddate   =~ s/^\s+//;
$enddate   =~ s/\s+$//;
# Predefine the start and end dates if they are not already defined
$startdate = format_date($datelastyear) unless $startdate;
$enddate   = format_date($todaysdate  ) unless   $enddate;

my $dbh = C4::Context->dbh;
my ($sqlorderby, $sqldatewhere, $presqldatewhere) = ("","","");
$debug and warn "start: " . format_date_in_iso($startdate) . "\nend: " . format_date_in_iso($enddate);
my @query_params = ();
# the dates below is to check for compliance of the current date range
if ($enddate) {
    $sqldatewhere .= " AND date <= ?";
    push @query_params, format_date_in_iso($enddate);
}
push @query_params, $max_bill;
# the date below is to check for compliance of all fees prior
if ($startdate) {
    $presqldatewhere .= " AND date < ?";
    push @query_params, format_date_in_iso($startdate);
}
push @query_params, $max_bill;

if ($order eq "patron") {
	$sqlorderby = " ORDER BY surname, firstname ";
} elsif ($order eq "fee") {
    $sqlorderby = " ORDER BY l_amountoutstanding DESC ";
} elsif ($order eq "desc") {
    $sqlorderby = " ORDER BY l_description ";
} elsif ($order eq "type") {
    $sqlorderby = " ORDER BY l_accounttype ";
} elsif ($order eq "date") {
    $sqlorderby = " ORDER BY l_date DESC ";
} elsif ($order eq "total") {
    $sqlorderby = " ORDER BY sum_amount DESC ";
} else {
	$sqlorderby = " ORDER BY surname, firstname ";
}
my $strsth =
	"SELECT 
		GROUP_CONCAT(accountlines.accounttype   ORDER BY accountlines.date DESC SEPARATOR '<br/>') as l_accounttype,
		GROUP_CONCAT(description                ORDER BY accountlines.date DESC SEPARATOR '<br/>') as l_description,
		GROUP_CONCAT(round(amountoutstanding,2) ORDER BY accountlines.date DESC SEPARATOR '<br/>') as l_amountoutstanding, 
		GROUP_CONCAT(accountlines.date          ORDER BY accountlines.date DESC SEPARATOR '<br/>') as l_date,
		GROUP_CONCAT(accountlines.itemnumber    ORDER BY accountlines.date DESC SEPARATOR '<br/>') as l_itemnumber,
		count(*)                        as cnt,
		max(accountlines.date)          as maxdate,
		round(sum(amountoutstanding),2) as sum_amount, 
		borrowers.borrowernumber        as borrowernumber,
		borrowers.surname               as surname,
		borrowers.firstname             as firstname,
		borrowers.email                 as email,
		borrowers.phone                 as phone,
		accountlines.itemnumber,
		description, 
		accountlines.date               as accountdate
		FROM 
			borrowers, accountlines
		WHERE 
			accountlines.borrowernumber = borrowers.borrowernumber
		AND accountlines.amountoutstanding <> 0 
		AND accountlines.borrowernumber 
			IN (SELECT borrowernumber FROM accountlines 
				where borrowernumber >= 0
				$sqldatewhere 
				GROUP BY accountlines.borrowernumber HAVING sum(amountoutstanding) >= ? ) 
		AND accountlines.borrowernumber 
			NOT IN (SELECT borrowernumber FROM accountlines 
				where borrowernumber >= 0
				$presqldatewhere 
				GROUP BY accountlines.borrowernumber HAVING sum(amountoutstanding) >= ? ) 
";

if (C4::Context->preference('IndependantBranches')){
	$strsth .= " AND borrowers.branchcode=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}
$strsth .= " GROUP BY accountlines.borrowernumber HAVING sum(amountoutstanding) >= ? " . $sqlorderby;
push @query_params, $max_bill;

my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

my @billingdata;
while ( my $data = $sth->fetchrow_hashref ) {   
    push @billingdata, {
        l_accountype        => $data->{l_accounttype},
        l_description       => $data->{l_description},
        l_amountoutstanding => $data->{l_amountoutstanding},
        l_date              => $data->{l_date},
        l_itemnumber        => $data->{l_itemnumber},
        l_accounttype       => $data->{l_accounttype},
        l_title             => $data->{l_title},
        cnt                 => $data->{cnt},
        maxdate             => $data->{maxdate},
        sum_amount          => $data->{sum_amount},
        borrowernumber      => $data->{borrowernumber},
        surname             => $data->{surname},
        firstname           => $data->{firstname},
        phone               => $data->{phone},
        email               => $data->{email},
        patronname          => $data->{surname} . ", " . $data->{firstname},
        description         => $data->{description},
        amountoutstanding   => $data->{amountoutstanding},
        accountdata         => $data->{accountdata}
    };
}

$template->param(
    todaysdate      => format_date($todaysdate),
    from            => $startdate,
    to              => $enddate,
    ratio           => $max_bill,
    billingloop     => \@billingdata,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

output_html_with_http_headers $input, $cookie, $template->output;
