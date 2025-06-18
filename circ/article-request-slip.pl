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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw( -utf8 );

use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use C4::Letters;
use Koha::ArticleRequests;
use Koha::Patrons;

my $cgi = CGI->new;

my @ids = split( ',', scalar $cgi->param('id') );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/printslip.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $ars         = Koha::ArticleRequests->search( { id => { '-in' => \@ids } } );
my $slipContent = '';
my $first       = 1;
my $style;
while ( my $ar = $ars->next ) {
    if ( !$first ) {
        $slipContent .= "<hr/>";
    }
    $first = 0;
    $template->param( article_request => $ar );
    my $patron = Koha::Patrons->find( $ar->borrowernumber );

    my $slip = C4::Letters::GetPreparedLetter(
        module                 => 'circulation',
        letter_code            => 'AR_SLIP',
        message_transport_type => 'print',
        lang                   => $patron->lang,
        tables                 => {
            article_requests => $ar->id,
            borrowers        => $ar->borrowernumber,
            biblio           => $ar->biblionumber,
            biblioitems      => $ar->biblionumber,
            items            => $ar->itemnumber,
            branches         => $ar->branchcode,
        },
    );

    $slipContent .=
          $slip->{is_html}
        ? $slip->{content}
        : '<pre>' . $slip->{content} . '</pre>';

    $style = $slip->{style};
}

$template->param(
    slip   => $slipContent,
    caller => 'article-request',
    plain  => 0,
    style  => $style,
    id     => 'ar_slip',
);

output_html_with_http_headers $cgi, $cookie, $template->output;
