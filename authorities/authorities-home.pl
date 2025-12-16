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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI         qw ( -utf8 );
use URI::Escape qw( uri_escape_utf8 );
use POSIX       qw( ceil );

use C4::Context;
use C4::Auth            qw( get_template_and_user );
use C4::Output          qw( output_and_exit pagination_bar output_html_with_http_headers );
use C4::AuthoritiesMarc qw( DelAuthority );
use C4::Search::History;
use C4::Languages;

use Koha::Authority::Types;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::XSLT::Base;
use Koha::Z3950Servers;

my $query        = CGI->new;
my $op           = $query->param('op')           || '';
my $authtypecode = $query->param('authtypecode') || '';
my $authid       = $query->param('authid')       || '';

my ( $template, $loggedinuser, $cookie );

my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypetext'] } );
my $pending_deletion_authid;

if ( $op eq "cud-delete" ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "authorities/authorities-home.tt",
            query         => $query,
            type          => 'intranet',
            flagsrequired => { catalogue => 1 },
        }
    );

    DelAuthority( { authid => $authid } );

    # FIXME No error handling here, DelAuthority needs adjustments
    $pending_deletion_authid = $authid;

    if ( $query->param('operator') ) {

        # query contains search params so perform search
        $op = "do_search";
    } else {
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
    my $offset         = ( $startfrom - 1 ) * $resultsperpage + 1;

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "authorities/searchresultlist.tt",
            query         => $query,
            type          => 'intranet',
            flagsrequired => { catalogue => 1 },
        }
    );

    my $builder  = Koha::SearchEngine::QueryBuilder->new( { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new( { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );

    my $search_query = $builder->build_authorities_query_compat(
        [$marclist], [$and_or],     [$excluding], [$operator],
        [$value],    $authtypecode, $orderby
    );
    my ( $results, $total );
    eval { ( $results, $total ) = $searcher->search_auth_compat( $search_query, $offset, $resultsperpage ); };
    if ($@) {
        my $query_error = q{};
        $query_error .= $@ if $@;
        $template->param( query_error => $query_error );
    }

    $template->param( search_query => $search_query ) if C4::Context->preference('DumpSearchQueryTemplate');

    # search history
    if ( C4::Context->preference('EnableSearchHistory') ) {
        if ( $startfrom == 1 ) {
            my $path_info         = $query->url( -path_info => 1 );
            my $query_cgi_history = $query->url( -query     => 1 );
            $query_cgi_history =~ s/^$path_info\?//;
            $query_cgi_history =~ s/;/&/g;

            C4::Search::History::add(
                {
                    userid     => $loggedinuser,
                    sessionid  => $query->cookie("CGISESSID"),
                    query_desc => $value,
                    query_cgi  => $query_cgi_history,
                    total      => $total,
                    type       => "authority",
                }
            );
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
    my $base_url =
          "authorities-home.pl?"
        . "marclist=$marclist"
        . "&amp;and_or=$and_or"
        . "&amp;excluding=$excluding"
        . "&amp;operator=$operator"
        . "&amp;value=$value_url"
        . "&amp;resultsperpage=$resultsperpage"
        . "&amp;type=intranet"
        . "&amp;op=do_search"
        . "&amp;authtypecode=$authtypecode"
        . "&amp;orderby=$orderby";

    my $from = ( $startfrom - 1 ) * $resultsperpage + 1;
    my $to;
    if ( !defined $total ) {
        $total = 0;
    }

    if ( $total < $startfrom * $resultsperpage ) {
        $to = $total;
    } else {
        $to = $startfrom * $resultsperpage;
    }

    my $AuthorityXSLTResultsDisplay = C4::Context->preference('AuthorityXSLTResultsDisplay');
    if ( $results && $AuthorityXSLTResultsDisplay ) {
        my $lang = C4::Languages::getlanguage();
        foreach my $result (@$results) {
            my $authority = Koha::Authorities->find( $result->{authid} );
            next unless $authority;

            my $authtypecode = $authority->authtypecode;
            my $xsl          = $AuthorityXSLTResultsDisplay;
            $xsl =~ s/\{langcode\}/$lang/g;
            $xsl =~ s/\{authtypecode\}/$authtypecode/g;

            my $xslt_engine = Koha::XSLT::Base->new;
            my $output      = $xslt_engine->transform( { xml => $authority->marcxml, file => $xsl } );
            if ( $xslt_engine->err ) {
                warn "XSL transformation failed ($xsl): " . $xslt_engine->err;
                next;
            }

            $result->{html} = $output;
        }
    }

    if ( $pending_deletion_authid && $results ) {
        $results = [ grep { $_->{authid} != $pending_deletion_authid } @$results ];
    }

    $template->param( result => $results ) if $results;

    my $max_result_window = $searcher->max_result_window;
    my $hits_to_paginate  = ( $max_result_window && $max_result_window < $total ) ? $max_result_window : $total;

    $template->param(
        pagination_bar => pagination_bar(
            $base_url,  ceil( $hits_to_paginate / $resultsperpage ),
            $startfrom, 'startfrom'
        ),
        total            => $total,
        hits_to_paginate => $hits_to_paginate,
        from             => $from,
        to               => $to,
        isEDITORS        => $authtypecode eq 'EDITORS',
    );

}
if ( $op eq '' ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "authorities/authorities-home.tt",
            query         => $query,
            type          => 'intranet',
            flagsrequired => { catalogue => 1 },
        }
    );

}

my $servers = Koha::Z3950Servers->search(
    {
        recordtype => 'authority',
        servertype => [ 'zed', 'sru' ],
    },
);

$template->param(
    servers         => $servers,
    authority_types => $authority_types,
    op              => $op,
);

$template->{VARS}->{marcflavour} = C4::Context->preference("marcflavour");

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
