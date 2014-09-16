#!/usr/bin/perl

# Copyright 2013 Catalyst
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use C4::Context;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Output;

# TODO this should use the moose thing that auto-picks.
use Koha::SearchEngine::Elasticsearch::QueryBuilder;
use Koha::ElasticSearch::Search;

my $cgi = new CGI;

my $template_name;
my $template_type = "basic";
if ( $cgi->param("idx") or $cgi->param("q") ) {
    $template_name = 'search/results.tt';
}
else {
    $template_name = 'search/advsearch.tt';
    $template_type = 'advsearch';
}

# load the template
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => $template_name,
        query           => $cgi,
        type            => "opac",
        authnotrequired => 1,
    }
);
my %template_params;
my $format = $cgi->param("format") || 'html';

# load the Type stuff
my $itemtypes = GetItemTypes;

my $page = $cgi->param("page") || 1;
my $count =
     $cgi->param('count')
  || C4::Context->preference('OPACnumSearchResults')
  || 20;
my $q = $cgi->param("q");

my $searcher = Koha::ElasticSearch::Search->new();
my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new();
my $query;
if ($cgi->param('type') eq 'browse') {
    $query = $builder->build_browse_query($cgi->param('browse_field') || undef, $q );
    $template_params{browse} = 1;
} else {
    $query = $builder->build_query($q);
}
my $results = $searcher->search( $query, $page, $count );
#my $results = $searcher->search( { "match_phrase_prefix" => { "title" => "the" } } );

# This is temporary, but will do the job for now.
my @hits;
$results->each(sub {
        push @hits, { _source => @_[0] };
    });
# Make a list of the page numbers
my @pages = map { { page => $_, current => ($_ == ( $page || 1)) } } 1 .. int($results->total / $count);
my $max_page = int($results->total / $count);
# Pager template params
$template->param(
    SEARCH_RESULTS  => \@hits,
    PAGE_NUMBERS    => \@pages,
    total           => $results->total,
    previous_page   => ( $page > 1 ? $page - 1 : undef ),
    next_page       => ( $page < $max_page ? $page + 1 : undef ),
    follower_params => [
        { var => 'type',  val => $cgi->param('type') },
        { var => 'q',     val => $q },
        { var => 'count', val => $count },
    ],
    %template_params,
);

my $content_type = ( $format eq 'rss' or $format eq 'atom' ) ? $format : 'html';
output_with_http_headers $cgi, $cookie, $template->output, $content_type;
