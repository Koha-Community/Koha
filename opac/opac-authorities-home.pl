#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use CGI qw ( -utf8 );
use URI::Escape qw( uri_escape_utf8 );
use C4::Auth qw( get_template_and_user );

use C4::Context;
use C4::Output qw( pagination_bar output_html_with_http_headers );
use C4::Koha;
use C4::Search::History;
use C4::Languages;
use Koha::XSLT::Base;

use Koha::Authority::Types;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

my $query        = CGI->new;
my $op           = $query->param('op') || '';
my $authtypecode = $query->param('authtypecode') || '';
my $dbh          = C4::Context->dbh;

my $startfrom = $query->param('startfrom') || 1;
my $resultsperpage = $query->param('resultsperpage') || 20;
my $authid    = $query->param('authid');
my ( $template, $loggedinuser, $cookie );

my $authority_types = Koha::Authority::Types->search({}, { order_by => ['authtypetext']});

if ( $op eq "do_search" ) {
    my @marclist = $query->multi_param('marclist');
    my @and_or = $query->multi_param('and_or');
    my @excluding = $query->multi_param('excluding');
    my @operator = $query->multi_param('operator');
    my $orderby = $query->param('orderby');
    my @value = $query->multi_param('value');
    $value[0] ||= q||;

    my $builder = Koha::SearchEngine::QueryBuilder->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $search_query = $builder->build_authorities_query_compat( \@marclist, \@and_or,
        \@excluding, \@operator, \@value, $authtypecode, $orderby );
    my $offset = ( $startfrom - 1 ) * $resultsperpage + 1;
    my ( $results, $total ) =
      $searcher->search_auth_compat( $search_query, $offset, $resultsperpage );
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-authoritiessearchresultlist.tt",
            query           => $query,
            type            => 'opac',
            authnotrequired => 1,
        }
    );
    $template->param( search_query => $search_query ) if C4::Context->preference('DumpSearchQueryTemplate');

    # multi page display gestion
    my $value_url = uri_escape_utf8($value[0]);
    my $base_url = "opac-authorities-home.pl?"
      ."marclist=$marclist[0]"
      ."&amp;and_or=$and_or[0]"
      ."&amp;excluding=$excluding[0]"
      ."&amp;operator=$operator[0]"
      ."&amp;value=$value_url"
      ."&amp;resultsperpage=$resultsperpage"
      ."&amp;type=opac"
      ."&amp;op=do_search"
      ."&amp;authtypecode=$authtypecode"
      ."&amp;orderby=$orderby";

    my $from = ( $startfrom - 1 ) * $resultsperpage + 1;
    my $to;
    if ( !defined $total ) {
        $total = 0;
    }

    if ( $total < $startfrom * $resultsperpage ) {
        $to = $total;
    }
    else {
        $to = $startfrom * $resultsperpage;
    }

    my $AuthorityXSLTOpacResultsDisplay = C4::Context->preference('AuthorityXSLTOpacResultsDisplay');
    if ($results && $AuthorityXSLTOpacResultsDisplay) {
        my $lang = C4::Languages::getlanguage();
        foreach my $result (@$results) {
            my $authority = Koha::Authorities->find($result->{authid});
            next unless $authority;
            my $authtypecode = $authority->authtypecode;
            my $xsl = $AuthorityXSLTOpacResultsDisplay;

            $xsl =~ s/\{langcode\}/$lang/g;
            $xsl =~ s/\{authtypecode\}/$authtypecode/g;
            my $xslt_engine = Koha::XSLT::Base->new;
            my $output = $xslt_engine->transform({ xml => $authority->marcxml, file => $xsl });
            if ($xslt_engine->err) {
                warn "XSL transformation failed ($xsl): " . $xslt_engine->err;
                next;
            }
            $result->{html} = $output;
        }
    }

    $template->param( result => $results ) if $results;

    $template->param(
        pagination_bar => pagination_bar(
            $base_url,  int( $total / $resultsperpage ) + 1,
            $startfrom, 'startfrom'
        ),
        total     => $total,
        from      => $from,
        to        => $to,
    );

    unless (C4::Context->preference('OPACShowUnusedAuthorities')) {
#        TODO implement usage counts
#        my @usedauths = grep { $_->{used} > 0 } @$results;
#        $results = \@usedauths;
    }

    # Opac search history
    if (C4::Context->preference('EnableOpacSearchHistory')) {
        if ( $startfrom == 1) {
            my $path_info = $query->url(-path_info=>1);
            my $query_cgi_history = $query->url(-query=>1);
            $query_cgi_history =~ s/^$path_info\?//;
            $query_cgi_history =~ s/;/&/g;

            unless ( $loggedinuser ) {
                my $new_search = C4::Search::History::add_to_session({
                        cgi => $query,
                        query_desc => $value[0],
                        query_cgi => $query_cgi_history,
                        total => $total,
                        type => "authority",
                });
            } else {
                # To the session (the user is logged in)
                C4::Search::History::add({
                    userid => $loggedinuser,
                    sessionid => $query->cookie("CGISESSID"),
                    query_desc => $value[0],
                    query_cgi => $query_cgi_history,
                    total => $total,
                    type => "authority",
                });
            }
        }
    }

    $template->param( orderby => $orderby );
    $template->param(
        startfrom      => $startfrom,
        resultsperpage => $resultsperpage,
        countfuzzy     => !(C4::Context->preference('OPACShowUnusedAuthorities')),
        resultcount    => scalar @$results,
        authtypecode   => $authtypecode,
        authtypetext   => $authority_types->find($authtypecode)->authtypetext,
        isEDITORS      => $authtypecode eq 'EDITORS',
    );

}
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-authorities-home.tt",
            query           => $query,
            type            => 'opac',
            authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        }
    );

}

$template->param(
    authority_types => $authority_types,
    authtypecode    => $authtypecode,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
