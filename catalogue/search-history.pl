#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <http://www.gnu.org/licenses>

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth;
use C4::Search::History;
use C4::Output;

my $cgi = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => 'catalogue/search-history.tt',
    query           => $cgi,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => {catalogue => 1},
});

my $type = $cgi->param('type');
my $action = $cgi->param('action') || q{list};
my $previous = $cgi->param('previous');

# Deleting search history
if ( $action eq 'delete' ) {
    my $sessionid = defined $previous
        ? $cgi->cookie("CGISESSID")
        : q{};
    C4::Search::History::delete(
        {
            userid => $loggedinuser,
            id     => [ $cgi->param('id') ],
        }
    );
    # Redirecting to this same url so the user won't see the search history link in the header
    print $cgi->redirect('/cgi-bin/koha/catalogue/search-history.pl');

# Showing search history
} else {
    my $current_searches = C4::Search::History::get({
        userid => $loggedinuser,
        sessionid => $cgi->cookie("CGISESSID")
    });
    my @current_biblio_searches = map {
        $_->{type} eq 'biblio' ? $_ : ()
    } @$current_searches;

    my @current_authority_searches = map {
        $_->{type} eq 'authority' ? $_ : ()
    } @$current_searches;

    my $previous_searches = C4::Search::History::get({
        userid => $loggedinuser,
        sessionid => $cgi->cookie("CGISESSID"),
        previous => 1
    });

    my @previous_biblio_searches = map {
        $_->{type} eq 'biblio' ? $_ : ()
    } @$previous_searches;

    my @previous_authority_searches = map {
        $_->{type} eq 'authority' ? $_ : ()
    } @$previous_searches;

    $template->param(
        current_biblio_searches => \@current_biblio_searches,
        current_authority_searches => \@current_authority_searches,
        previous_biblio_searches => \@previous_biblio_searches,
        previous_authority_searches => \@previous_authority_searches,

    );
}


$template->param(
);

output_html_with_http_headers $cgi, $cookie, $template->output;
