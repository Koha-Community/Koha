#!/usr/bin/perl

# Copyright 2012 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::SearchEngine::FacetsBuilder;

my $cgi = new CGI;

my $template_name;
my $template_type = "basic";
if ( $cgi->param("idx") or $cgi->param("q") ) {
    $template_name = 'search/results.tt';
} else {
    $template_name = 'search/advsearch.tt';
    $template_type = 'advsearch';
}

# load the template
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => $template_name,
        query           => $cgi,
        type            => "opac",
        authnotrequired => 1,
    }
);

my $format = $cgi->param("format") || 'html';




# load the Type stuff
my $itemtypes = GetItemTypes;

my $page = $cgi->param("page") || 1;
my $count = $cgi->param('count') || C4::Context->preference('OPACnumSearchResults') || 20;
$count = 5;
my $q = $cgi->param("q");
my $builder = Koha::SearchEngine::QueryBuilder->new;
$q = $builder->build_query( $q );
my $search_service = Koha::SearchEngine::Search->new;

# load the sorting stuff
my $sort_by = $cgi->param('sort_by')
        || C4::Context->preference('OPACdefaultSortField') . ' ' . C4::Context->preference('OPACdefaultSortOrder');

my $search_engine_config = Koha::SearchEngine->new->config;
my $sortable_indexes = $search_engine_config->sortable_indexes;
my ( $sort_indexname, $sort_order );
( $sort_indexname, $sort_order ) = ($1, $2) if ( $sort_by =~ m/^(.*) (asc|desc)$/ );
my $sort_by_indexname = eval {
    [
        map {
            $_->{code} eq $sort_indexname
                ? 'srt_' . $_->{type} . '_' . $_->{code} . ' ' . $sort_order
                : ()
        } @$sortable_indexes
    ]->[0]
};

# This array is used to build facets GUI
my %filters;
my @tplfilters;
for my $filter ( $cgi->param('filters') ) {
    next if not $filter;
    my ($k, @v) = $filter =~ /(?: \\. | [^:] )+/xg;
    my $v = join ':', @v;
    push @{$filters{$k}}, $v;
    $v =~ s/^"(.*)"$/$1/; # Remove quotes around
    push @tplfilters, {
        'var' => $k,
        'val' => $v,
    };
}
push @{$filters{recordtype}}, 'biblio';

my $results = $search_service->search(
    $q,
    \%filters,
    {
        page => $page,
        count => $count,
        sort => $sort_by_indexname,
        facets => 1,
        fl => ["ste_title", "str_author", 'int_biblionumber'],
    }
);

if ($results->{error}){
    $template->param(query_error => $results->{error});
    output_with_http_headers $cgi, $cookie, $template->output, 'html';
    exit;
}


# populate results with records
my @r;
for my $searchresult ( @{ $results->items } ) {
    my $biblionumber = $searchresult->{values}->{recordid};

    my $nr;
    while ( my ($k, $v) = each %{$searchresult->{values}} ) {
        my $nk = $k;
        $nk =~ s/^[^_]*_(.*)$/$1/;
        $nr->{$nk} = ref $v ? shift @{$v} : $v;
    }
    push( @r, $nr );
}

# build facets
my $facets_builder = Koha::SearchEngine::FacetsBuilder->new;
my @facets_loop = $facets_builder->build_facets( $results, $search_engine_config->facetable_indexes, \%filters );

my $total = $results->{pager}->{total_entries};
my $pager = Data::Pagination->new(
    $total,
    $count,
    20,
    $page,
);

# params we want to pass for all actions require another query (pagination, sort, facets)
my @follower_params = map { {
    var => 'filters',
    val => $_->{var}.':"'.$_->{val}.'"'
} } @tplfilters;
push @follower_params, { var => 'q', val => $q};
push @follower_params, { var => 'sort_by', val => $sort_by};

# Pager template params
$template->param(
    previous_page    => $pager->{'prev_page'},
    next_page        => $pager->{'next_page'},
    PAGE_NUMBERS     => [ map { { page => $_, current => $_ == $page } } @{ $pager->{'numbers_of_set'} } ],
    current_page     => $page,
    follower_params  => \@follower_params,
    total            => $total,
    SEARCH_RESULTS   => \@r,
    query            => $q,
    count            => $count,
    sort_by          => $sort_by,
    sortable_indexes => $sortable_indexes,
    facets_loop      => \@facets_loop,
    filters          => \@tplfilters,
);

my $content_type = ( $format eq 'rss' or $format eq 'atom' ) ? $format : 'html';
output_with_http_headers $cgi, $cookie, $template->output, $content_type;
