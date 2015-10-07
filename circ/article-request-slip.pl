#!/usr/bin/perl

# Copyright 2015 ByWater Solutions
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

use CGI qw( -utf8 );

use C4::Context;
use C4::Output;
use C4::Auth;
use Koha::ArticleRequests;

my $cgi = new CGI;

my $id = $cgi->param('id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/printslip.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

my $ar = Koha::ArticleRequests->find($id);

$template->param( article_request => $ar );

my $slip = C4::Letters::GetPreparedLetter(
    module                 => 'circulation',
    letter_code            => 'AR_SLIP',
    message_transport_type => 'print',
    tables                 => {
        article_requests => $ar->id,
        borrowers        => $ar->borrowernumber,
        biblio           => $ar->biblionumber,
        biblioitems      => $ar->biblionumber,
        items            => $ar->itemnumber,
        branches         => $ar->branchcode,
    },
);

$template->param(
    slip   => $slip->{content},
    caller => 'article-request',
    plain  => !$slip->{is_html},
);

output_html_with_http_headers $cgi, $cookie, $template->output;
