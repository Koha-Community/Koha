#!/usr/bin/perl


# Copyright 2012 Koha
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

use C4::Context;
use C4::Output;
use CGI;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Circulation;

use vars qw($debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

my $input = new CGI;
my $sessionID = $input->cookie("CGISESSID");
my $session = get_session($sessionID);

my $itemnumber = $input->param('transferitem');
my $branchcode = $input->param('branchcode');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/printslip.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => $debug,
    }
);


my $userenv = C4::Context->userenv;
my ($slip, $is_html);
if ( my $letter = TransferSlip ($session->param('branch') || $userenv->{branch}, $itemnumber, $branchcode) ) {
    $slip = $letter->{content};
    $is_html = $letter->{is_html};
}
else {
    $slip = "Item not found";
}
$template->param(
    slip => $slip,
    plain => !$is_html,
    caller => 'transfer',
    stylesheet => C4::Context->preference("SlipCSS"),
);

output_html_with_http_headers $input, $cookie, $template->output;
