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

use C4::Output;
use C4::Auth;
use C4::Utils::DataTables::Members;
use C4::Search;
use Koha::Biblios;
use Koha::Patrons;
use Koha::ArticleRequests;

my $cgi = new CGI;

my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/request-article.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
    }
);

my $action            = $cgi->param('action') || q{};
my $biblionumber      = $cgi->param('biblionumber');
my $patron_cardnumber = $cgi->param('patron_cardnumber');
my $patron_id         = $cgi->param('patron_id');

my $biblio = Koha::Biblios->find($biblionumber);
output_and_exit( $cgi, $cookie, $template, 'unknown_biblio')
    unless $biblio;

my $patron =
    $patron_id         ? Koha::Patrons->find($patron_id)
  : $patron_cardnumber ? Koha::Patrons->find( { cardnumber => $patron_cardnumber } )
  : undef;

if ( $action eq 'create' ) {
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
        }
    )->store();

}

if ( !$patron && $patron_cardnumber ) {
    my $results = C4::Utils::DataTables::Members::search(
        {
            searchmember => $patron_cardnumber,
            dt_params    => { iDisplayLength => -1 },
        }
    );

    my $patrons = $results->{patrons};

    if ( scalar @$patrons == 1 ) {
        $patron = Koha::Patrons->find( $patrons->[0]->{borrowernumber} );
    }
    elsif (@$patrons) {
        $template->param( patrons => $patrons );
    }
    else {
        $template->param( no_patrons_found => $patron_cardnumber );
    }
}

$template->param(
    biblio => $biblio,
    patron => $patron,
    C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
