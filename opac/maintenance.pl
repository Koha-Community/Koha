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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "maintenance.tt",
        type            => "opac",
        query           => $query,
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $koha_db_version = C4::Context->preference('Version');
my $kohaversion     = Koha::version();

# Strip dots from version
$kohaversion     =~ s/\.//g if defined $kohaversion;
$koha_db_version =~ s/\.//g if defined $koha_db_version;

if (
    !defined $koha_db_version ||          # DB not populated
    $kohaversion > $koha_db_version ||    # Update needed
    C4::Context->preference('OpacMaintenance')
    )
{    # Maintenance mode enabled
    output_html_with_http_headers $query, '', $template->output;
} else {
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
}

1;
