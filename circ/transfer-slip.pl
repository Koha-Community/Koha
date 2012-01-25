#!/usr/bin/perl


# Copyright 2012 Koha
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Context;
use C4::Output;
use CGI;
use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Branch;
use C4::Dates qw/format_date format_date_in_iso/;

use vars qw($debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

my $input = new CGI;
my $itemnumber = $input->param('transferitem');
my $branchcode = $input->param('branchcode');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/transfer-slip.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => $debug,
    }
);

my $pulldate = C4::Dates->new();
my $item =  GetItem( $itemnumber );
my ( undef, $biblio ) = GetBiblio($item->{biblionumber});

$template->param(
    pulldate => $pulldate->output(),
    branchname => GetBranchName($branchcode),
    biblio => $biblio,
    item => $item,
);

output_html_with_http_headers $input, $cookie, $template->output;
