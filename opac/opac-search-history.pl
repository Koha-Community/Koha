#!/usr/bin/perl

# Copyright 2013 BibLibre SARL
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

use C4::Auth qw(:DEFAULT get_session);
use CGI;
use C4::Context;
use C4::Output;
use C4::Log;
use C4::Items;
use C4::Debug;
use C4::Dates;
use C4::Search::History;
use URI::Escape;
use POSIX qw(strftime);


my $cgi = new CGI;

# Getting the template and auth
my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name => "opac-search-history.tt",
        query => $cgi,
        type => "opac",
        authnotrequired => 1,
        flagsrequired => {borrowers => 1},
        debug => 1,
    }
);

my $type = $cgi->param('type');
my $action = $cgi->param('action') || q{};
my $previous = $cgi->param('previous');

# If the user is not logged in, we deal with the session
unless ( $loggedinuser ) {
    # Deleting search history
    if ($cgi->param('action') && $cgi->param('action') eq 'delete') {
        # Deleting session's search history
        my $type = $cgi->param('type');
        my @searches = ();
        if ( $type ) {
            @searches = C4::Search::History::get_from_session({ cgi => $cgi });
            @searches = map { $_->{type} ne $type ? $_ : () } @searches;
        }
        C4::Search::History::set_to_session({ cgi => $cgi, search_history => \@searches });

        # Redirecting to this same url so the user won't see the search history link in the header
        my $uri = $cgi->url();
        print $cgi->redirect(-uri => $uri);
    # Showing search history
    } else {
        # Getting the searches from session
        my @current_searches = C4::Search::History::get_from_session({
            cgi => $cgi,
        });

        my @current_biblio_searches = map {
            $_->{type} eq 'biblio' ? $_ : ()
        } @current_searches;

        my @current_authority_searches = map {
            $_->{type} eq 'authority' ? $_ : ()
        } @current_searches;

        $template->param(
            current_biblio_searches => \@current_biblio_searches,
            current_authority_searches => \@current_authority_searches,
        );
    }
} else {
    # And if the user is logged in, we deal with the database
    my $dbh = C4::Context->dbh;

    # Deleting search history
    if ( $action eq 'delete' ) {
        my $sessionid = defined $previous
            ? $cgi->cookie("CGISESSID")
            : q{};
        C4::Search::History::delete(
            {
                userid => $loggedinuser,
                sessionid => $sessionid,
                type => $type,
                previous => $previous
            }
        );
        # Redirecting to this same url so the user won't see the search history link in the header
        my $uri = $cgi->url();
        print $cgi->redirect($uri);

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
}

$template->param(searchhistoryview => 1);

output_html_with_http_headers $cgi, $cookie, $template->output;
