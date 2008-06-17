#!/usr/bin/perl


# Copyright 2008 LibLime
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
use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Reserves;
use C4::Branch;
use C4::Dates qw/format_date format_date_in_iso/;

use vars qw($debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $borrowernumber = $input->param('borrowernumber');
my $transfer = $input->param('transfer');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   
        template_name   => "circ/hold-transfer-slip.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
        debug           => $debug,
    }
);

my $reserveinfo = GetReserveInfo($borrowernumber,$biblionumber );
my $pulldate = C4::Dates->new();
$reserveinfo->{'pulldate'} = $pulldate->output();
$reserveinfo->{'branchname'} = GetBranchName($reserveinfo->{'branchcode'});
$reserveinfo->{'transferrequired'} = $transfer;

$template->param( reservedata => [ $reserveinfo ] ,
				);

output_html_with_http_headers $input, $cookie, $template->output;




