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

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Clubs;
use Koha::Club::Templates;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "clubs/clubs.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { clubs => '*' },
    }
);

my $stored           = $cgi->param('stored');
my $club_template_id = $cgi->param('club_template_id');
my $club_id          = $cgi->param('club_id');

my $club_template = $club_template_id ? Koha::Club::Templates->find($club_template_id) : undef;
my $club          = $club_id          ? Koha::Clubs->find($club_id)                    : undef;

$template->param(
    stored         => $stored,
    club_template  => $club_template,
    club           => $club,
    club_templates => Koha::Club::Templates->search,
    clubs          => Koha::Clubs->search,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );
