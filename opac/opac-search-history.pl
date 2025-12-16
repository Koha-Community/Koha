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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use CGI      qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Search::History;

my $cgi = CGI->new;

# Getting the template and auth
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-search-history.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

unless ( C4::Context->preference("EnableOpacSearchHistory") ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");    # escape early
    exit;
}

my $type     = $cgi->param('type');
my $op       = $cgi->param('op') || q{};
my $previous = $cgi->param('previous');

# If the user is not logged in, we deal with the session
unless ($loggedinuser) {

    # Deleting search history
    if ( $op eq 'cud-delete' ) {

        # Deleting session's search history
        my @id  = $cgi->multi_param('id');
        my $all = not scalar(@id);

        my $type     = $cgi->param('type');
        my @searches = ();
        unless ($all) {
            @searches = C4::Search::History::get_from_session( { cgi => $cgi } );
            if ($type) {
                @searches = map { $_->{type} ne $type ? $_ : () } @searches;
            }
            if (@id) {
                @searches = map {
                    my $search = $_;
                    ( grep { $_ eq $search->{id} } @id ) ? () : $_
                } @searches;
            }
        }
        C4::Search::History::set_to_session( { cgi => $cgi, search_history => \@searches } );

        # Redirecting to this same url so the user won't see the search history link in the header
        print $cgi->redirect( -uri => '/cgi-bin/koha/opac-search-history.pl' );

        # Showing search history
    } else {

        # Getting the searches from session
        my @current_searches = C4::Search::History::get_from_session(
            {
                cgi => $cgi,
            }
        );

        my @current_biblio_searches = map { $_->{type} eq 'biblio' ? $_ : () } @current_searches;

        my @current_authority_searches = map { $_->{type} eq 'authority' ? $_ : () } @current_searches;

        $template->param(
            current_biblio_searches    => \@current_biblio_searches,
            current_authority_searches => \@current_authority_searches,
        );
    }
} else {

    # And if the user is logged in, we deal with the database

    # Deleting search history
    if ( $op eq 'cud-delete' ) {
        my @id = $cgi->multi_param('id');
        if (@id) {
            C4::Search::History::delete(
                {
                    userid => $loggedinuser,
                    id     => [@id],
                }
            );
        } else {
            C4::Search::History::delete(
                {
                    userid => $loggedinuser,
                }
            );
        }

        # Redirecting to this same url so the user won't see the search history link in the header
        print $cgi->redirect( -uri => '/cgi-bin/koha/opac-search-history.pl' );

        # Showing search history
    } else {
        my $current_searches = C4::Search::History::get(
            {
                userid    => $loggedinuser,
                sessionid => $cgi->cookie("CGISESSID")
            }
        );
        my @current_biblio_searches = map { $_->{type} eq 'biblio' ? $_ : () } @$current_searches;

        my @current_authority_searches = map { $_->{type} eq 'authority' ? $_ : () } @$current_searches;

        my $previous_searches = C4::Search::History::get(
            {
                userid    => $loggedinuser,
                sessionid => $cgi->cookie("CGISESSID"),
                previous  => 1
            }
        );

        my @previous_biblio_searches = map { $_->{type} eq 'biblio' ? $_ : () } @$previous_searches;

        my @previous_authority_searches = map { $_->{type} eq 'authority' ? $_ : () } @$previous_searches;

        $template->param(
            current_biblio_searches     => \@current_biblio_searches,
            current_authority_searches  => \@current_authority_searches,
            previous_biblio_searches    => \@previous_biblio_searches,
            previous_authority_searches => \@previous_authority_searches,

        );
    }
}

$template->param( searchhistoryview => 1 );

output_html_with_http_headers $cgi, $cookie, $template->output, undef, { force_no_caching => 1 };
