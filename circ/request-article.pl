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

use C4::Output  qw( output_and_exit output_html_with_http_headers );
use C4::Auth    qw( get_template_and_user );
use C4::Search  qw( enabled_staff_search_views );
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use Koha::Biblios;
use Koha::Logger;
use Koha::Patrons;
use Koha::ArticleRequests;

use Scalar::Util qw( blessed );
use Try::Tiny;

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/request-article.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { circulate => 'circulate_remaining_permissions' },
    }
);

my $op                = $cgi->param('op') || q{};
my $biblionumber      = $cgi->param('biblionumber');
my $patron_cardnumber = $cgi->param('patron_cardnumber');
my $patron_id         = $cgi->param('borrowernumber');

my $biblio = Koha::Biblios->find($biblionumber);
output_and_exit( $cgi, $cookie, $template, 'unknown_biblio' )
    unless $biblio;

my $patron =
      $patron_id         ? Koha::Patrons->find($patron_id)
    : $patron_cardnumber ? Koha::Patrons->find( { cardnumber => $patron_cardnumber } )
    :                      undef;

if ( $op eq 'cud-create' ) {
    my $borrowernumber = $cgi->param('borrowernumber');
    my $branchcode     = $cgi->param('branchcode');

    my $itemnumber   = $cgi->param('itemnumber')   || undef;
    my $title        = $cgi->param('title')        || undef;
    my $author       = $cgi->param('author')       || undef;
    my $volume       = $cgi->param('volume')       || undef;
    my $issue        = $cgi->param('issue')        || undef;
    my $date         = $cgi->param('date')         || undef;
    my $pages        = $cgi->param('pages')        || undef;
    my $chapters     = $cgi->param('chapters')     || undef;
    my $patron_notes = $cgi->param('patron_notes') || undef;
    my $format       = $cgi->param('format')       || undef;
    my $toc_request  = $cgi->param('toc_request');

    try {
        my $ar = Koha::ArticleRequest->new(
            {
                borrowernumber => $borrowernumber,
                biblionumber   => $biblionumber,
                branchcode     => $branchcode,
                itemnumber     => $itemnumber,
                title          => $title,
                author         => $author,
                volume         => $volume,
                issue          => $issue,
                date           => $date,
                pages          => $pages,
                chapters       => $chapters,
                patron_notes   => $patron_notes,
                format         => $format,
                toc_request    => $toc_request ? 1 : 0,
            }
        )->request;
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::ArticleRequest::LimitReached') ) {
            $template->param( error_message => 'article_request_limit_reached' );
        } else {
            Koha::Logger->get->debug("Unhandled exception when placing an article request ($_)");
            $template->param( error_message => 'article_request_unhandled_exception' );
        }
    };
    undef $patron;
}

if ( $patron && !$patron->can_request_article ) {
    $patron = undef;
    $template->param( error_message => 'article_request_limit_reached' );
}

if ($patron) {
    $template->param( article_request_fee => $patron->article_request_fee );
}

$template->param(
    biblio              => $biblio,
    patron              => $patron,
    subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumber),
    C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
