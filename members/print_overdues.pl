#!/usr/bin/perl

# Copyright 2014 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Overdues qw(parse_overdues_letter);

use Koha::Patrons;

my $input = new CGI;

my $flagsrequired = { circulate => "circulate_remaining_permissions" };

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/printslip.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => $flagsrequired,
        debug           => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $branchcode     = C4::Context->userenv->{'branch'};

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

my $overdues = [
    map { $_->unblessed_all_relateds } $patron->get_overdues
];

my $letter = parse_overdues_letter(
    {
        letter_code            => 'OVERDUES_SLIP',
        borrowernumber         => $borrowernumber,
        branchcode             => $branchcode,
        items                  => $overdues,
        message_transport_type => 'print',
    }
);

$template->param(
    slip           => $letter->{content},
    title          => $letter->{name},
    plain          => !$letter->{is_html},
    borrowernumber => $borrowernumber,
);

output_html_with_http_headers $input, $cookie, $template->output;
