# Copyright 2015 Catalyst IT
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

use Test::More tests => 15;
use t::lib::Mocks;

use Koha::SearchEngine::Elasticsearch::QueryBuilder;
use Koha::SearchEngine::Elasticsearch::Indexer;


my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'mydb' } );

use_ok('Koha::SearchEngine::Elasticsearch::Search');

ok(
    my $searcher = Koha::SearchEngine::Elasticsearch::Search->new(
        { 'nodes' => ['localhost:9200'], 'index' => 'mydb' }
    ),
    'Creating a Koha::SearchEngine::Elasticsearch::Search object'
);

is( $searcher->index, 'mydb', 'Testing basic accessor' );

ok( my $query = $builder->build_query('easy'), 'Build a search query');

SKIP: {

    eval { $builder->get_elasticsearch_params; };

    skip 'ElasticSeatch configuration not available', 8
        if $@;

    Koha::SearchEngine::Elasticsearch::Indexer->new({ index => 'mydb' })->drop_index;

    ok( my $results = $searcher->search( $query) , 'Do a search ' );

    ok( my $marc = $searcher->json2marc( $results->first ), 'Convert JSON to MARC');

    is (my $count = $searcher->count( $query ), 0 , 'Get a count of the results, without returning results ');

    ok ($results = $searcher->search_compat( $query ), 'Test search_compat' );

    ok (($results,$count) = $searcher->search_auth_compat ( $query ), 'Test search_auth_compat' );

    is ( $count = $searcher->count_auth_use($searcher,1), 0, 'Testing count_auth_use');

    is ($searcher->max_result_window, 10000, 'By default, max_result_window is 10000');
    $searcher->store->es->indices->put_settings(index => $searcher->store->index_name, body => {
        'index' => {
            'max_result_window' => 12000,
        },
    });
    is ($searcher->max_result_window, 12000, 'max_result_window returns the correct value');
}

subtest 'json2marc' => sub {
    plan tests => 4;
    my $leader = '00626nam a2200193   4500';
    my $_001 = 42;
    my $_010a = '123456789';
    my $_010d = 145;
    my $_200a = 'a title';
    my $json = [ # It's not a JSON, see the POD of json2marc
        [ 'LDR', undef, undef, '_', $leader ],
        [ '001', undef, undef, '_', $_001 ],
        [ '010', ' ', ' ', 'a', $_010a, 'd', $_010d ],
        [ '200', '1', ' ', 'a', $_200a, ], # Yes UNIMARC but we don't mind here
    ];

    my $marc = $searcher->json2marc( $json );
    is( $marc->leader, $leader, );
    is( $marc->field('001')->data, $_001, );
    is( $marc->subfield('010', 'a'), $_010a, );
    is( $marc->subfield('200', 'a'), $_200a, );

};

subtest 'build_query tests' => sub {
    plan tests => 24;

    t::lib::Mocks::mock_preference('DisplayLibraryFacets','both');
    my $query = $builder->build_query();
    ok( defined $query->{aggregations}{homebranch},
        'homebranch added to facets if DisplayLibraryFacets=both' );
    ok( defined $query->{aggregations}{holdingbranch},
        'holdingbranch added to facets if DisplayLibraryFacets=both' );
    t::lib::Mocks::mock_preference('DisplayLibraryFacets','holding');
    $query = $builder->build_query();
    ok( !defined $query->{aggregations}{homebranch},
        'homebranch not added to facets if DisplayLibraryFacets=holding' );
    ok( defined $query->{aggregations}{holdingbranch},
        'holdingbranch added to facets if DisplayLibraryFacets=holding' );
    t::lib::Mocks::mock_preference('DisplayLibraryFacets','home');
    $query = $builder->build_query();
    ok( defined $query->{aggregations}{homebranch},
        'homebranch added to facets if DisplayLibraryFacets=home' );
    ok( !defined $query->{aggregations}{holdingbranch},
        'holdingbranch not added to facets if DisplayLibraryFacets=home' );

    t::lib::Mocks::mock_preference( 'QueryAutoTruncate', '' );

    ( undef, $query ) = $builder->build_query_compat( undef, ['donald duck'] );
    is(
        $query->{query}{query_string}{query},
        "(donald duck)",
        "query not altered if QueryAutoTruncate disabled"
    );

    t::lib::Mocks::mock_preference( 'QueryAutoTruncate', '1' );

    ( undef, $query ) = $builder->build_query_compat( undef, ['donald duck'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck*)",
        "simple query is auto truncated when QueryAutoTruncate enabled"
    );

    # Ensure reserved words are not truncated
    ( undef, $query ) = $builder->build_query_compat( undef,
        ['donald or duck and mickey not mouse'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* or duck* and mickey* not mouse*)",
        "reserved words are not affected by QueryAutoTruncate"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['donald* duck*'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck*)",
        "query with '*' is unaltered when QueryAutoTruncate is enabled"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['donald duck and the mouse'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck* and the* mouse*)",
        "individual words are all truncated and stopwords ignored"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['*'] );
    is(
        $query->{query}{query_string}{query},
        "(*)",
        "query of just '*' is unaltered when QueryAutoTruncate is enabled"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['"donald duck"'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck")',
        "query with quotes is unaltered when QueryAutoTruncate is enabled"
    );


    ( undef, $query ) = $builder->build_query_compat( undef, ['"donald duck" and "the mouse"'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck" and "the mouse")',
        "all quoted strings are unaltered if more than one in query"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['barcode:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(barcode:123456*)',
        "query of specific field is truncated"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['Local-number:"123456"'] );
    is(
        $query->{query}{query_string}{query},
        '(Local-number:"123456")',
        "query of specific field including hyphen and quoted is not truncated"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['Local-number:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(Local-number:123456*)',
        "query of specific field including hyphen and not quoted is truncated"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['Local-number.raw:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(Local-number.raw:123456*)',
        "query of specific field including period and not quoted is truncated"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['Local-number.raw:"123456"'] );
    is(
        $query->{query}{query_string}{query},
        '(Local-number.raw:"123456")',
        "query of specific field including period and quoted is not truncated"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['J.R.R'] );
    is(
        $query->{query}{query_string}{query},
        '(J.R.R*)',
        "query including period is truncated but not split at periods"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['title:"donald duck"'] );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck")',
        "query of specific field is not truncated when surrouned by quotes"
    );

    ( undef, $query ) = $builder->build_query_compat( undef, ['title:"donald duck"'], undef, undef, undef, undef, undef, { suppress => 1 } );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck") AND suppress:0',
        "query of specific field is added AND suppress:0"
    );

    my ($simple_query, $query_cgi);
    ( undef, $query, $simple_query, $query_cgi ) = $builder->build_query_compat( undef, ['title:"donald duck"'], undef, undef, undef, undef, undef, { suppress => 0 } );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck")',
        "query of specific field is not added AND suppress:0"
    );
    is($query_cgi, 'q=title%3A%22donald%20duck%22', 'query cgi');
};

subtest "_convert_sort_fields" => sub {
    plan tests => 2;
    my @sort_by = $builder->_convert_sort_fields(qw( call_number_asc author_dsc ));
    is_deeply(
        \@sort_by,
        [
            { field => 'callnum', direction => 'asc' },
            { field => 'author',  direction => 'desc' }
        ],
        'sort fields should have been split correctly'
    );

    # We could expect this to pass, but direction is undef instead of 'desc'
    @sort_by = $builder->_convert_sort_fields(qw( call_number_asc author_desc ));
    is_deeply(
        \@sort_by,
        [
            { field => 'callnum', direction => 'asc' },
            { field => 'author',  direction => 'desc' }
        ],
        'sort fields should have been split correctly'
    );
};
