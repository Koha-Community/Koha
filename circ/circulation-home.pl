#!/usr/bin/perl

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
# 

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Context;
use Koha::BiblioFrameworks;
use Koha::Checkouts;

my $query = new CGI;
my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user(
    {
        template_name   => "circ/circulation-home.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

$template->{'VARS'}->{'AllowOfflineCirculation'} = C4::Context->preference('AllowOfflineCirculation');

output_html_with_http_headers $query, $cookie, $template->output;
