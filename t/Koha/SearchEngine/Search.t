#!/usr/bin/perl
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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use t::lib::Mocks;

use Test::MockModule;

use MARC::Record;
use Try::Tiny;

use Koha::SearchEngine::Search;

subtest "pagination_bar tests" => sub {
    plan tests => 14;

    my @sort_by = ('relevance_dsc');

    my (
        $PAGE_NUMBERS,         $hits_to_paginate, $pages, $current_page_number,
        $previous_page_offset, $next_page_offset, $last_page_offset
        )
        = Koha::SearchEngine::Search->pagination_bar(
        {
            hits              => 500,
            max_result_window => 1000,
            results_per_page  => 20,
            offset            => 160,
            sort_by           => \@sort_by
        }
        );
    is(
        $hits_to_paginate, 500,
        "We paginate all hits if less than max_result_window"
    );
    is( $pages, 25, "We have hits/hits_to_paginate pages" );
    is(
        $current_page_number, 9,
        "We calculate current page by offset/results_per_page plus 1"
    );
    is(
        $previous_page_offset, 140,
        "Previous page is current offset minus reults per page"
    );
    is(
        $next_page_offset, 180,
        "Next page is current offset plus reults per page"
    );
    is(
        $last_page_offset, 480,
        "Last page is pages minus 1 times reults per page"
    );
    is( @$PAGE_NUMBERS, 10, "If on first ten pages we only show 10 pages" );

    (
        $PAGE_NUMBERS,         $hits_to_paginate, $pages, $current_page_number,
        $previous_page_offset, $next_page_offset, $last_page_offset
        )
        = Koha::SearchEngine::Search->pagination_bar(
        {
            hits              => 500,
            max_result_window => 480,
            results_per_page  => 20,
            offset            => 240,
            sort_by           => \@sort_by
        }
        );
    is(
        $hits_to_paginate, 480,
        "We paginate all hits if less than max_result_window"
    );
    is( $pages, 24, "We have hits/hits_to_paginate pages" );
    is(
        $current_page_number, 13,
        "We calculate current page by offset/results_per_page plus 1"
    );
    is(
        $previous_page_offset, 220,
        "Previous page is current offset minus reults per page"
    );
    is(
        $next_page_offset, 260,
        "Next page is current offset plus reults per page"
    );
    is(
        $last_page_offset, 460,
        "Last page is pages minus 1 times reults per page"
    );
    is( @$PAGE_NUMBERS, 20, "If past first ten pages we show 20 pages" );

};

subtest "post_filter_opac_facets" => sub {
    plan tests => 4;

    my $facets = _get_mock_facet_data();
    my $rules  = { 'itype' => ['MP'] };

    my $filtered_facets = Koha::SearchEngine::Search->post_filter_opac_facets( { facets => $facets, rules => $rules } );
    is( scalar @$filtered_facets,                                 2,    'Facet type length the same' );
    is( scalar @{ $filtered_facets->[0]->{facets} },              3,    'author facet length the same' );
    is( scalar @{ $filtered_facets->[1]->{facets} },              1,    'itype facet has been filtered' );
    is( $filtered_facets->[1]->{facets}->[0]->{facet_link_value}, 'BK', 'correct itype facet has been filtered' );
};

sub _get_mock_facet_data {
    my $facets = [
        {
            'type_label_Authors' => 1,
            'facets'             => [
                {
                    'facet_link_value'  => 'Farley, David',
                    'type_link_value'   => 'author',
                    'facet_title_value' => 'Farley, David',
                    'facet_count'       => 1,
                    'facet_label_value' => 'Farley, David'
                },
                {
                    'facet_label_value' => 'Humble, Jez',
                    'facet_count'       => 1,
                    'facet_title_value' => 'Humble, Jez',
                    'type_link_value'   => 'author',
                    'facet_link_value'  => 'Humble, Jez'
                },
                {
                    'facet_count'       => 1,
                    'facet_title_value' => 'Martin, Robert C.',
                    'facet_label_value' => 'Martin, Robert C.',
                    'type_link_value'   => 'author',
                    'facet_link_value'  => 'Martin, Robert C.'
                }
            ],
            'av_cat'          => '',
            'order'           => 1,
            'label'           => 'Authors',
            'type_id'         => 'author_id',
            'type_link_value' => 'author'
        },
        {
            'type_label_Item types' => 1,
            'facets'                => [
                {
                    'type_link_value'   => 'itype',
                    'facet_link_value'  => 'BK',
                    'facet_count'       => 4,
                    'facet_title_value' => 'BK',
                    'facet_label_value' => 'Books'
                },
                {
                    'facet_title_value' => 'MP',
                    'facet_count'       => 1,
                    'facet_label_value' => 'Maps',
                    'type_link_value'   => 'itype',
                    'facet_link_value'  => 'MP'
                }
            ],
            'order'           => 2,
            'av_cat'          => undef,
            'type_id'         => 'itype_id',
            'type_link_value' => 'itype',
            'label'           => 'Item types'
        }
    ];
}
