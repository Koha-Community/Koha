#!/usr/bin/perl
# This file is part of Koha.
#
# Copyright (C) 2013 BibLibre
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

use C4::Auth;
use C4::Circulation qw( GetPendingOnSiteCheckouts );
use C4::Output;
use C4::Koha;
use Koha::BiblioFrameworks;
use Koha::Checkouts;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/on-site_checkouts.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired => {circulate => "circulate_remaining_permissions"},
    }
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

my $pending_checkout_notes = Koha::Checkouts->search({ noteseen => 0 })->count;
my $pending_onsite_checkouts = C4::Circulation::GetPendingOnSiteCheckouts();

$template->param(
    pending_onsite_checkouts => $pending_onsite_checkouts,
    pending_checkout_notes   => $pending_checkout_notes,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
