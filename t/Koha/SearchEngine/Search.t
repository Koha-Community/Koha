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

use Test::More tests => 5;
use Test::Exception;

use t::lib::Mocks;

use Test::MockModule;

use MARC::Record;
use Try::Tiny;

use Koha::SearchEngine::Search;

subtest "pagination_bar tests" => sub {
    plan tests => 14;

    my @sort_by = ('relevance_dsc');

    my ( $PAGE_NUMBERS, $hits_to_paginate, $pages, $current_page_number,
        $previous_page_offset, $next_page_offset, $last_page_offset )
      = Koha::SearchEngine::Search->pagination_bar(
        {
            hits              => 500,
            max_result_window => 1000,
            results_per_page  => 20,
            offset            => 160,
            sort_by           => \@sort_by
        }
      );
    is( $hits_to_paginate, 500,
        "We paginate all hits if less than max_result_window" );
    is( $pages, 25, "We have hits/hits_to_paginate pages" );
    is( $current_page_number, 9,
        "We calculate current page by offset/results_per_page plus 1" );
    is( $previous_page_offset, 140,
        "Previous page is current offset minus reults per page" );
    is( $next_page_offset, 180,
        "Next page is current offset plus reults per page" );
    is( $last_page_offset, 480,
        "Last page is pages minus 1 times reults per page" );
    is( @$PAGE_NUMBERS, 10, "If on first ten pages we only show 10 pages" );

    (
        $PAGE_NUMBERS, $hits_to_paginate, $pages, $current_page_number,
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
    is( $hits_to_paginate, 480,
        "We paginate all hits if less than max_result_window" );
    is( $pages, 24, "We have hits/hits_to_paginate pages" );
    is( $current_page_number, 13,
        "We calculate current page by offset/results_per_page plus 1" );
    is( $previous_page_offset, 220,
        "Previous page is current offset minus reults per page" );
    is( $next_page_offset, 260,
        "Next page is current offset plus reults per page" );
    is( $last_page_offset, 460,
        "Last page is pages minus 1 times reults per page" );
    is( @$PAGE_NUMBERS, 20, "If past first ten pages we show 20 pages" );

};
