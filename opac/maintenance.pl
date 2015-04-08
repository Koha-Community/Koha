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

use Modern::Perl;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Templates qw/gettemplate/;

my $query = new CGI;
my $template = C4::Templates::gettemplate( 'maintenance.tt', 'opac', $query, 0 );

my $koha_db_version = C4::Context->preference('Version');
my $kohaversion     = C4::Context::KOHAVERSION;
# Strip dots from version
$kohaversion     =~ s/\.//g if defined $kohaversion;
$koha_db_version =~ s/\.//g if defined $koha_db_version;

if ( !defined $koha_db_version || # DB not populated
     $kohaversion > $koha_db_version || # Update needed
     C4::Context->preference('OpacMaintenance') ) { # Maintenance mode enabled
    output_html_with_http_headers $query, '', $template->output;
}
else {
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
}

1;