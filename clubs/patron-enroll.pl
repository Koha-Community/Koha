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

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Clubs;
use Koha::Club::Enrollment::Fields;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "clubs/patron-enroll.tt",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => { clubs => '*' },
    }
);

my $id             = $cgi->param('id');
my $borrowernumber = $cgi->param('borrowernumber');
my $enrollent_id   = scalar $cgi->param('enrollent_id');

my $club = Koha::Clubs->find($id);
my @club_enrollment_fields = Koha::Club::Enrollment::Fields->search({'club_enrollment_id'=> $enrollent_id})->as_list;

$template->param(
    club                   => $club,
    borrowernumber         => $borrowernumber,
    enrollent_id           => $enrollent_id || 0,
    club_enrollment_fields => \@club_enrollment_fields,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );
