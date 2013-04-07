#!/usr/bin/perl

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

# FIXME - Generates a warning from C4/Context.pm (uninitilized value).

use CGI;
use C4::Auth;
use C4::Output;

my $input = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "maintenance.tmpl",
        type            => "opac",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $koha_db_version = C4::Context->preference('Version');
my $kohaversion     = C4::Context::KOHAVERSION;
$kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;

#warn "db: $koha_db_version, koha: $kohaversion";

if ( $kohaversion > $koha_db_version or C4::Context->preference('OpacMaintenance') ) {
    output_html_with_http_headers $input, '', $template->output;
}
else {
    print $input->redirect("/cgi-bin/koha/opac-main.pl");
}
