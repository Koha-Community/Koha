#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2011 BibLibre
# Parts copyright 2012 Athens County Public Libraries
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

=head1 ysearch.pl

This script allows ajax call for dynamic authorities search
(used in auth_finder.pl)

=cut

use CGI qw ( -utf8 );
use Modern::Perl;
use JSON;

use C4::Context;
use C4::Charset;
use C4::Auth qw/check_cookie_auth/;
use C4::Output;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

my $query = new CGI;

my ( $auth_status, $sessionID ) = check_cookie_auth( $query->cookie('CGISESSID'), { catalogue => 1 } );

if ( $auth_status ne "ok" ) {
    # send empty response
    my $reply = CGI->new("");
    print $reply->header(-type => 'text/html');
    exit 0;
}

    my @value      = $query->multi_param('term');
    my $searchtype = $query->param('querytype');
    my @marclist  = ($searchtype);
    my $authtypecode = $query->param('authtypecode');
    my @and_or    = $query->multi_param('and_or');
    my @excluding = $query->multi_param('excluding');
    my @operator  = $query->multi_param('operator');
    my $orderby   = $query->param('orderby');

    my $resultsperpage = 50;
    my $startfrom = 0;

    my $builder = Koha::SearchEngine::QueryBuilder->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $search_query = $builder->build_authorities_query_compat(
        \@marclist, \@and_or, \@excluding, \@operator,
        \@value, $authtypecode, $orderby
    );
    my $offset = $startfrom * $resultsperpage;
    my ( $results, $total ) =
        $searcher->search_auth_compat( $search_query, $offset,
        $resultsperpage );

    my %used_summaries; # hash to avoid duplicates
    my @summaries;
    foreach my $result (@$results) {
        my $authorized = $result->{'summary'}->{'authorized'};
        my $summary    = join(
            ' ',
            map {
                ( $searchtype eq 'mainmainentry' )
                  ? $_->{'hemain'}
                  : $_->{'heading'}
              } @$authorized
        );
        $summary =~ s/^\s+//;
        $summary =~ s/\s+$//;
        $summary = nsb_clean($summary);
        # test if already added ignoring case
        unless ( exists $used_summaries{ lc($summary) } ) {
            push @summaries, { 'summary' => $summary };
            $used_summaries{ lc($summary) } = 1;
        }
    }

output_with_http_headers $query, undef, to_json(\@summaries, { utf8 => 1 }), 'json';
