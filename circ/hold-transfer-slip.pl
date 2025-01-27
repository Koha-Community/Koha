#!/usr/bin/perl

# Copyright 2008 LibLime
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
use C4::Context;
use C4::Output   qw( output_html_with_http_headers );
use CGI          qw ( -utf8 );
use C4::Auth     qw( get_session get_template_and_user );
use C4::Reserves qw( ReserveSlip );

my $input     = CGI->new;
my $sessionID = $input->cookie("CGISESSID");
my $session   = get_session($sessionID);

my $reserve_id = $input->param('reserve_id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/printslip.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $userenv = C4::Context->userenv;
my ( $slip, $is_html, $style );
if (
    my $letter = ReserveSlip(
        {
            branchcode => $session->param('branch') || $userenv->{branch},
            reserve_id => $reserve_id,
        }
    )
    )
{
    $slip    = $letter->{content};
    $is_html = $letter->{is_html};
    $style   = $letter->{style};
}
$template->param( slip   => $slip ) if ($slip);
$template->param( caller => 'hold-transfer' );
$template->param( plain  => !$is_html );
$template->param( style  => $style );
$template->param( id     => 'reserve_slip' );

output_html_with_http_headers $input, $cookie, $template->output;

