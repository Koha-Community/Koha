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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;
use t::lib::Mocks;
use C4::Search;

use utf8;

subtest '_sort_facets_zebra with system preference' => sub {
    plan tests => 3;

    my $facets = _get_facets();

    # Test with explicit locale parameter
    my $sorted_facets_explicit = C4::Search::_sort_facets_zebra( $facets, 'default' );
    my $expected               = [
        { facet_label_value => 'Åberg, Erik' },
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
        { facet_label_value => 'Šostakovitš, Dmitri' },
        { facet_label_value => 'Zambidis' },
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

subtest '_sort_facets_zebra with fi_FI locale' => sub {
    plan tests => 1;
    my $locale_map = _get_locale_map();
SKIP: {
        skip( "fi_FI.utf8 locale not available on this system", 1 ) unless $locale_map->{"fi_FI.utf8"};

        my $facets = _get_facets();

        # Test with explicit locale parameter
        my $sorted_facets_explicit = C4::Search::_sort_facets_zebra( $facets, 'fi_FI' );
        my $expected               = [
            { facet_label_value => 'ari' },
            { facet_label_value => 'Ari' },
            { facet_label_value => 'étienne' },
            { facet_label_value => 'fairy' },
            { facet_label_value => 'Fairy' },
            { facet_label_value => 'harry' },
            { facet_label_value => 'Harry' },
            { facet_label_value => 'mary' },
            { facet_label_value => 'Mary' },
            { facet_label_value => 'Šostakovitš, Dmitri' },
            { facet_label_value => 'Zambidis' },
            { facet_label_value => 'Åberg, Erik' },
            { facet_label_value => 'Åuthor' },
        ];
        is_deeply( $sorted_facets_explicit, $expected, "Zebra facets sorted correctly with explicit locale" );
    }
};

sub _get_facets {
    my $facets = [
        { facet_label_value => 'Mary' },
        { facet_label_value => 'Harry' },
        { facet_label_value => 'Fairy' },
        { facet_label_value => 'Ari' },
        { facet_label_value => 'mary' },
        { facet_label_value => 'harry' },
        { facet_label_value => 'Åberg, Erik' },
        { facet_label_value => 'Åuthor' },
        { facet_label_value => 'fairy' },
        { facet_label_value => 'ari' },
        { facet_label_value => 'étienne' },
        { facet_label_value => 'Šostakovitš, Dmitri' },
        { facet_label_value => 'Zambidis' },
    ];
    return $facets;
}

sub _get_locale_map {
    my $map     = {};
    my @locales = `locale -a`;
    foreach my $locale (@locales) {
        chomp($locale);
        $map->{$locale} = 1;
    }
    return $map;
}
