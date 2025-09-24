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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use t::lib::Mocks;
use Encode       qw( encode );
use MIME::Base64 qw( encode_base64 );

use utf8;

use_ok('Koha::SearchEngine::Elasticsearch::Search');

subtest '_sort_facets' => sub {
    plan tests => 3;
    t::lib::Mocks::mock_preference( 'SearchEngine', 'Elasticsearch' );

    my $facets = _get_facets();

    my @normal_sort_facets     = sort { $a->{facet_label_value} cmp $b->{facet_label_value} } @$facets;
    my @normal_expected_facets = (
        { facet_label_value => 'Ari' },
        { facet_label_value => 'Fairy' },
        { facet_label_value => 'Harry' },
        { facet_label_value => 'Mary' },
        { facet_label_value => 'Zambidis' },
        { facet_label_value => 'ari' },
        { facet_label_value => 'fairy' },
        { facet_label_value => 'harry' },
        { facet_label_value => 'mary' },
        { facet_label_value => 'Åberg, Erik' },
        { facet_label_value => 'Åuthor' },
        { facet_label_value => 'étienne' },
        { facet_label_value => 'Šostakovitš, Dmitri' },
    );

    #NOTE: stringwise/bytewise is not UTF-8 friendly
    is_deeply( \@normal_sort_facets, \@normal_expected_facets, "Perl's built-in sort is stringwise/bytewise." );

    my $search = Koha::SearchEngine::Elasticsearch::Search->new(
        { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX } );

    #NOTE: The 'default' locale uses the Default Unicode Collation Element Table, which
    #is used for the locales of English (en) and French (fr).
    my $sorted_facets = $search->_sort_facets( { facets => $facets, locale => 'default' } );
    my $expected      = [
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
    is_deeply( $sorted_facets, $expected, "Facets sorted correctly with default locale" );

    # Test system preference integration
    t::lib::Mocks::mock_preference( 'FacetSortingLocale', 'en_US.utf8' );
    my $sorted_facets_syspref = $search->_sort_facets( { facets => $facets } );

    # Should return sorted facets (exact order may vary by system locale availability)
    is( ref($sorted_facets_syspref), 'ARRAY', "System preference integration works" );

    #NOTE: If "locale" is not provided to _sort_facets, it will look up the LC_COLLATE
    #for the local system. This is what allows this function to work well in production.
    #However, since LC_COLLATE could vary from system to system running these unit tests,
    #we can't test it reliably here.
};

subtest '_sort_facets_zebra with fi_FI locale' => sub {
    plan tests => 1;
    my $locale_map = _get_locale_map();
SKIP: {
        skip( "fi_FI.utf8 locale not available on this system", 1 ) unless $locale_map->{"fi_FI.utf8"};

        my $facets = _get_facets();

        my $search = Koha::SearchEngine::Elasticsearch::Search->new(
            { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX } );

        # Test with explicit locale parameter
        my $sorted_facets_explicit = $search->_sort_facets( { facets => $facets, locale => 'fi_FI' } );
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

subtest 'search_auth_compat' => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference( 'QueryRegexEscapeOptions', 'dont_escape' );
    t::lib::Mocks::mock_preference( 'SearchEngine',            'Elasticsearch' );

    my $search;
    ok(
        $search = Koha::SearchEngine::Elasticsearch::Search->new(
            { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX }
        ),
        'Creating a new Search object'
    );

    my $builder;
    ok(
        $builder =
            Koha::SearchEngine::QueryBuilder->new( { index => $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX } ),
        'Creating a new Builder object'
    );

    my $search_query = $builder->build_authorities_query_compat(
        ['mainmainentry'],         ['and'], [''], ['contains'],
        ['Donald - ^ \ ~ + Duck'], '',      'HeadingAsc'
    );

    is(
        $search_query->{query}->{bool}->{must}->[0]->{query_string}->{query}, '(Donald*) AND (Duck*)',
        "Reserved characters -, ^, \\, ~, + have been removed from search query"
    );

    my $module = Test::MockModule->new('Koha::SearchEngine::Elasticsearch::Search');
    $module->mock( 'count_auth_use', sub { return 1 } );
    $module->mock(
        'search',
        sub {
            # While the 001 and the authid should be the same, it is not always the case
            # The _id is always the authid and so should be our source of trutch
            my $marc_record = MARC::Record->new();
            $marc_record->append_fields(
                MARC::Field->new( '001', 'Wrong001Number' ),
            );
            $marc_record->append_fields(
                MARC::Field->new( '008', '100803n||a| nnaban          |a aaa    |d' ),
            );
            my $marc_data = encode_base64( encode( 'UTF-8', $marc_record->as_usmarc() ) );
            return {
                hits => {
                    hits => [
                        {
                            '_id'     => 8675309,
                            '_source' => {
                                'local-number' => ['Wrong001Number'],
                                'marc_data'    => $marc_data,
                                'marc_format'  => 'base64ISO2709',
                            },
                        }
                    ]
                }
            };
        }
    );

    t::lib::Mocks::mock_preference( 'ShowHeadingUse', 1 );
    my ( $results, undef ) = $search->search_auth_compat('faked');

    is( @$results[0]->{authid}, '8675309', 'We get the expected record _id and not the 001' );

    is( @$results[0]->{main}, 1, 'Valid main heading with ShowHeadingUse' );
    is(
        @$results[0]->{subject},
        undef, 'Valid main heading with ShowHeadingUse'
    );
    is( @$results[0]->{series}, 1, 'Valid main heading with ShowHeadingUse' );
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

1;
