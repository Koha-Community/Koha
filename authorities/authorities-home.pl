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

use strict;
use warnings;

use CGI qw ( -utf8 );
use URI::Escape;
use C4::Auth;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Acquisition;
use C4::Koha;
use C4::Biblio;
use C4::Search::History;

use Koha::Authority::Types;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Token;

my $query = new CGI;
my $dbh   = C4::Context->dbh;
my $op           = $query->param('op')           || '';
my $authtypecode = $query->param('authtypecode') || '';
my $authid       = $query->param('authid')       || '';

my ( $template, $loggedinuser, $cookie );

my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypetext'] } );

if ( $op eq "delete" ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/authorities-home.tt",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    die "Wrong CSRF token" unless Koha::Token->new->check_csrf({
        session_id => scalar $query->cookie('CGISESSID'),
        token  => scalar $query->param('csrf_token'),
    });

    DelAuthority({ authid => $authid });

    if ( $query->param('operator') ) {
        # query contains search params so perform search
        $op = "do_search";
    }
    else {
        $op = '';
    }
}
if ( $op eq "do_search" ) {
    my $marclist  = $query->param('marclist')  || '';
    my $and_or    = $query->param('and_or')    || '';
    my $excluding = $query->param('excluding') || '';
    my $operator  = $query->param('operator')  || '';
    my $orderby   = $query->param('orderby')   || '';
    my $value     = $query->param('value')     || '';

    my $startfrom      = $query->param('startfrom')      || 1;
    my $resultsperpage = $query->param('resultsperpage') || 20;

    my $builder = Koha::SearchEngine::QueryBuilder->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $search_query = $builder->build_authorities_query_compat(
        [$marclist], [$and_or], [$excluding], [$operator],
        [$value], $authtypecode, $orderby
    );
    my $offset = ( $startfrom - 1 ) * $resultsperpage + 1;
    my ( $results, $total ) =
      $searcher->search_auth_compat( $search_query, $offset,
        $resultsperpage );
    #my ( $results, $total ) = SearchAuthorities(
    #    [$marclist],  [$and_or],
    #    [$excluding], [$operator],
    #    [$value], ( $startfrom - 1 ) * $resultsperpage,
    #    $resultsperpage, $authtypecode,
    #    $orderby
    #);


    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/searchresultlist.tt",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    $template->param(
        csrf_token => Koha::Token->new->generate_csrf({
            session_id => scalar $query->cookie('CGISESSID'),
        }),
    );

    # search history
    if (C4::Context->preference('EnableSearchHistory')) {
        if ( $startfrom == 1) {
            my $path_info = $query->url(-path_info=>1);
            my $query_cgi_history = $query->url(-query=>1);
            $query_cgi_history =~ s/^$path_info\?//;
            $query_cgi_history =~ s/;/&/g;

            C4::Search::History::add({
                userid => $loggedinuser,
                sessionid => $query->cookie("CGISESSID"),
                query_desc => $value,
                query_cgi => $query_cgi_history,
                total => $total,
                type => "authority",
            });
        }
    }

    $template->param(
        marclist       => $marclist,
        and_or         => $and_or,
        excluding      => $excluding,
        operator       => $operator,
        orderby        => $orderby,
        value          => $value,
        authtypecode   => $authtypecode,
        startfrom      => $startfrom,
        resultsperpage => $resultsperpage,
    );

    # we must get parameters once again. Because if there is a mainentry, it
    # has been replaced by something else during the search, thus the links
    # next/previous would not work anymore

    # construction of the url of each page
    my $value_url = uri_escape_utf8($value);
    my $base_url = "authorities-home.pl?"
      ."marclist=$marclist"
      ."&amp;and_or=$and_or"
      ."&amp;excluding=$excluding"
      ."&amp;operator=$operator"
      ."&amp;value=$value_url"
      ."&amp;resultsperpage=$resultsperpage"
      ."&amp;type=intranet"
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

    $template->param( result => $results ) if $results;

    $template->param(
        pagination_bar => pagination_bar(
            $base_url,  int( $total / $resultsperpage ) + 1,
            $startfrom, 'startfrom'
        ),
        total     => $total,
        from      => $from,
        to        => $to,
        isEDITORS => $authtypecode eq 'EDITORS',
    );

}
if ( $op eq '' ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "authorities/authorities-home.tt",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

}

my $schema = Koha::Database->new()->schema();
my $servers = $schema->resultset('Z3950server')->search(
        {
            recordtype => 'authority',
            servertype => ['zed', 'sru'],
        },
        {   result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            order_by     => ['rank', 'servername'],
        },
);

$template->param(
    servers => $servers,
    authority_types => $authority_types,
    op            => $op,
);

$template->{VARS}->{marcflavour} = C4::Context->preference("marcflavour");

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
