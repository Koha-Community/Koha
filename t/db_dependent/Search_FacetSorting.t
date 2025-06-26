#!/usr/bin/perl

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

use Test::More tests => 1;
use Test::MockModule;
use t::lib::Mocks;
use C4::Search;

use utf8;

subtest '_sort_facets_zebra with system preference' => sub {
    plan tests => 3;

    my $facets = [
        { facet_label_value => 'Mary' },
        { facet_label_value => 'Harry' },
        { facet_label_value => 'Fairy' },
        { facet_label_value => 'Ari' },
        { facet_label_value => 'mary' },
        { facet_label_value => 'harry' },
        { facet_label_value => 'fairy' },
        { facet_label_value => 'ari' },
        { facet_label_value => 'étienne' },
        { facet_label_value => 'Åuthor' },
    ];

    # Test with explicit locale parameter
    my $sorted_facets_explicit = C4::Search::_sort_facets_zebra( $facets, 'default' );
    my $expected               = [
        { facet_label_value => 'ari' },
        { facet_label_value => 'Ari' },
        { facet_label_value => 'Åuthor' },
        { facet_label_value => 'étienne' },
        { facet_label_value => 'fairy' },
        { facet_label_value => 'Fairy' },
        { facet_label_value => 'harry' },
        { facet_label_value => 'Harry' },
        { facet_label_value => 'mary' },
        { facet_label_value => 'Mary' },
    ];
    is_deeply( $sorted_facets_explicit, $expected, "Zebra facets sorted correctly with explicit locale" );

    # Test with system preference
    t::lib::Mocks::mock_preference( 'FacetSortingLocale', 'default' );
    my $sorted_facets_syspref = C4::Search::_sort_facets_zebra($facets);
    is_deeply( $sorted_facets_syspref, $expected, "Zebra facets sorted correctly with system preference" );

    # Test fallback behavior
    t::lib::Mocks::mock_preference( 'FacetSortingLocale', '' );
    my $sorted_facets_fallback = C4::Search::_sort_facets_zebra($facets);
    is( ref($sorted_facets_fallback), 'ARRAY', "Zebra facets sorting fallback works" );
};
