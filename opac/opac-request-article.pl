#!/usr/bin/perl

# Copyright ByWater Solutions 2015
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

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Biblios;
use Koha::Logger;
use Koha::Patrons;

use Scalar::Util qw( blessed );
use Try::Tiny;

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-request-article.tt",
        query         => $cgi,
        type          => "opac",
    }
);

my $op           = $cgi->param('op') || q{};
my $biblionumber = $cgi->param('biblionumber');
my $biblio       = Koha::Biblios->find($biblionumber);
if ( !$biblio ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ( $op eq 'cud-create' ) {
    my $branchcode = $cgi->param('branchcode');

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

    my $success;

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
        $success = 1;
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::ArticleRequest::LimitReached') ) {
            $template->param( error_message => 'article_request_limit_reached' );
        } else {
            Koha::Logger->get->debug("Unhandled exception when placing an article request ($_)");
            $template->param( error_message => 'article_request_unhandled_exception' );
        }
    };

    if ($success) {
        print $cgi->redirect("/cgi-bin/koha/opac-user.pl?opac-user-article-requests=1");
        exit;
    }

    # Should we redirect?
} elsif ( !$op && C4::Context->preference('ArticleRequestsOpacHostRedirection') ) {

    # Conditions: no items, host item entry (MARC21 773)
    my ( $host, $pageinfo ) = $biblio->get_marc_host( { no_items => 1 } );
    if ($host) {
        $template->param(
            pageinfo => $pageinfo,
            title    => $biblio->title,
            author   => $biblio->author
        );
        $biblio = $host;
    }
}

my $patron = Koha::Patrons->find($borrowernumber);

if ( !$patron->can_request_article ) {
    $template->param( error_message => 'article_request_limit_reached' );
}

$template->param( article_request_fee => $patron->article_request_fee )
    if $op ne 'cud-create';

$template->param(
    biblio   => $biblio,
    patron   => $patron,
    op       => $op,
    accepted => scalar $cgi->param('accepted'),
);

output_html_with_http_headers $cgi, $cookie, $template->output, undef, { force_no_caching => 1 };
