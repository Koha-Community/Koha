#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/printslip.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $recallid = $input->param('recall_id');
my $recall   = Koha::Recalls->find($recallid);

my $itemnumber;
if ( $recall->item_id ) {
    $itemnumber = $recall->item_id;
} else {
    $itemnumber = $recall->checkout->itemnumber;
}

# Print slip to inform library staff of details of recall requester, so the item can be put aside for requester
my $letter = C4::Letters::GetPreparedLetter(
    module                 => 'circulation',
    letter_code            => 'RECALL_REQUESTER_DET',
    message_transport_type => 'print',
    tables                 => {
        'branches'  => $recall->pickup_library_id,
        'borrowers' => $recall->patron_id,
        'biblio'    => $recall->biblio_id,
        'items'     => $itemnumber,
        'recalls'   => $recall->id,
    }
);

my ( $slip, $is_html, $style );
if ($letter) {
    $slip    = $letter->{content};
    $is_html = $letter->{is_html};
    $style   = $letter->{style};
}

$template->param(
    slip   => $slip,
    plain  => !$is_html,
    caller => 'recall',
    style  => $style,
    id     => 'recall_request_det',
);

output_html_with_http_headers $input, $cookie, $template->output;
