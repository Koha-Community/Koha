#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
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

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;

use Koha::Patrons;
use Koha::Club::Enrollments;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "clubs/patron-clubs-tab.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { clubs => '*' },
    }
);

my $patronnumber = $cgi->param('borrowernumber');

my $patron = Koha::Patrons->find($patronnumber);

my @enrollments = $patron->get_club_enrollments();
my @clubs       = $patron->get_enrollable_clubs();

$template->param(
    enrollments    => \@enrollments,
    clubs          => \@clubs,
    borrowernumber => $patronnumber
);

output_html_with_http_headers( $cgi, $cookie, $template->output );
