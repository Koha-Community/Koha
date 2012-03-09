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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


=head1 NAME

serials-home.pl

=head1 DESCRIPTION

this script is the main page for serials/

=cut

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Branch;
use C4::Context;
use C4::Output;
use C4::Serials;

my $query   = new CGI;
my $routing = $query->param('routing') || C4::Context->preference("RoutingSerials");

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/serials-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => '*' },
        debug           => 1,
    }
);

$template->param(
    routing       => $routing,
    (uc(C4::Context->preference("marcflavour"))) => 1
);

output_html_with_http_headers $query, $cookie, $template->output;
