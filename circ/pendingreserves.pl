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
my $yesterdaysdate = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day,   0, 0, -1));
#changed from delivered range of 10 years-yesterday to 2 days ago-today
# Find two days ago for the default shelf pull start and end dates
my $pastdate       = sprintf("%-04.4d-%-02.2d-%02.2d", Add_Delta_YMD($year, $month, $day, 0, 0, -2));

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
	$enddate = format_date($todaysdate);
}

my $reservedata = C4::Reserves::GetPendingReserves();

$template->param(
    todaysdate      	=> format_date($todaysdate),
    from             => $startdate,
    to              	=> $enddate,
    reserveloop     	=> $reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    DHTMLcalendar_dateformat =>  C4::Dates->DHTMLcalendar(),
	dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;
