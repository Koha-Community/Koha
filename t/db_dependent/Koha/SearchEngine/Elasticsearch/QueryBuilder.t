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

use C4::Context;
use Test::Exception;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::More tests => 7;

use List::Util qw( all );

use Koha::Database;
use Koha::SearchEngine::Elasticsearch::QueryBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $se = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch' );
$se->mock( 'get_elasticsearch_mappings', sub {
    my ($self) = @_;

    my %all_mappings;

    my $mappings = {
        data => {
            properties => {
                title => {
                    type => 'text'
                },
                title__sort => {
                    type => 'text'
                },
                subject => {
                    type => 'text',
                    facet => 1
                },
                'subject-heading-thesaurus' => {
                    type => 'text',
                    facet => 1
                },
                itemnumber => {
                    type => 'integer'
                },
                sortablenumber => {
                    type => 'integer'
                },
                sortablenumber__sort => {
                    type => 'integer'
                },
                heading => {
                    type => 'text'
                },
                'heading-main' => {
                    type => 'text'
                },
                heading__sort => {
                    type => 'text'
                },
                match => {
                    type => 'text'
                },
                'match-heading' => {
                    type => 'text'
                },
                'match-heading-see-from' => {
                    type => 'text'
                },
            }
        }
    };
    $all_mappings{$self->index} = $mappings;

    my $sort_fields = {
        $self->index => {
            title => 1,
            subject => 0,
            itemnumber => 0,
            sortablenumber => 1,
            mainentry => 1
        }
    };
    $self->sort_fields($sort_fields->{$self->index});

    return $all_mappings{$self->index};
});

subtest 'build_authorities_query_compat() tests' => sub {

    plan tests => 65;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'authorities' }),
        'Creating new query builder object for authorities'
    );

    my $koha_to_index_name = $Koha::SearchEngine::Elasticsearch::QueryBuilder::koha_to_index_name;
    my $search_term = 'a';
    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            is( $query->{query}->{bool}->{must}[0]->{query_string}->{query},
                "a*");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{query_string}->{query},
                "a*");
        }
        is( $query->{query}->{bool}->{must}[0]->{query_string}->{analyze_wildcard}, JSON::true, 'Set analyze_wildcard true' );
        is( $query->{query}->{bool}->{must}[0]->{query_string}->{lenient}, JSON::true, 'Set lenient true' );
    }

    $search_term = 'Donald Duck';
    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
        is( $query->{query}->{bool}->{must}[0]->{query_string}->{query}, "(Donald*) AND (Duck*)" );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            isa_ok( $query->{query}->{bool}->{must}[0]->{query_string}->{fields}, 'ARRAY')
        } else {
            is( $query->{query}->{bool}->{must}[0]->{query_string}->{default_field}, $koha_to_index_name->{$koha_name} );
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['is'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            is(
                $query->{query}->{bool}->{must}[0]->{multi_match}->{query},
                "Donald Duck"
            );
            my $all_matches = all { /\.ci_raw$/ }
                @{$query->{query}->{bool}->{must}[0]->{multi_match}->{fields}};
            ok( $all_matches, 'Correct fields parameter for "is" query in "any" or "all"' );
        } else {
            is(
                $query->{query}->{bool}->{must}[0]->{term}->{$koha_to_index_name->{$koha_name} . ".ci_raw"},
                "Donald Duck"
            );
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['start'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            my $all_matches = all { (%{$_->{prefix}})[0] =~ /\.ci_raw$/ && (%{$_->{prefix}})[1] eq "Donald Duck" }
                @{$query->{query}->{bool}->{must}[0]->{bool}->{should}};
            ok( $all_matches, "Correct multiple prefix query" );
        } else {
            is( $query->{query}->{bool}->{must}[0]->{prefix}->{$koha_to_index_name->{$koha_name} . ".ci_raw"}, "Donald Duck" );
        }
    }

    # Sorting
    my $query = $qb->build_authorities_query_compat( [ 'mainentry' ],  undef, undef, ['start'], [$search_term], 'AUTH_TYPE', 'HeadingAsc' );
    is_deeply(
        $query->{sort},
        [
            {
                'heading__sort' => 'asc'
            }
        ],
        "ascending sort parameter properly formed"
    );
    $query = $qb->build_authorities_query_compat( [ 'mainentry' ],  undef, undef, ['start'], [$search_term], 'AUTH_TYPE', 'HeadingDsc' );
    is_deeply(
        $query->{sort},
        [
            {
                'heading__sort' => 'desc'
            }
        ],
        "descending sort parameter properly formed"
    );

    # Authorities type
    $query = $qb->build_authorities_query_compat( [ 'mainentry' ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
    is_deeply(
        $query->{query}->{bool}->{filter},
        { term => { 'authtype.raw' => 'AUTH_TYPE' } },
        "authorities type code is used as filter"
    );

    # Authorities marclist check
    warning_like {
        $query = $qb->build_authorities_query_compat( [ 'tomas','mainentry' ],  undef, undef, ['contains'], [$search_term,$search_term], 'AUTH_TYPE', 'asc' )
    }
    qr/Unknown search field tomas/,
    "Warning for unknown field in marclist";
    is_deeply(
        $query->{query}->{bool}->{must}[0]->{query_string}->{default_field},
        'tomas',
        "If no mapping for marclist the index is passed through as defined"
    );
    is_deeply(
        $query->{query}->{bool}->{must}[1]->{query_string}{default_field},
        'heading',
        "If mapping found for marclist the index is passed through converted"
    );

};

subtest 'build_query tests' => sub {
    plan tests => 57;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'biblios' }),
        'Creating new query builder object for biblios'
    );

    my @sort_by = 'title_asc';
    my @sort_params = $qb->_convert_sort_fields(@sort_by);
    my %options;
    $options{sort} = \@sort_params;
    my $query = $qb->build_query('test', %options);

    is_deeply(
        $query->{sort},
        [
            {
            'title__sort' => {
                    'order' => 'asc'
                }
            }
        ],
        "sort parameter properly formed"
    );

    t::lib::Mocks::mock_preference('FacetMaxCount','37');
    t::lib::Mocks::mock_preference('DisplayLibraryFacets','both');
    $query = $qb->build_query('test', %options);
    ok( defined $query->{aggregations}{ccode}{terms}{size},'we need to ask for a size or we get only 5 facet' );
    is( $query->{aggregations}{ccode}{terms}{size}, 37,'we ask for the size as defined by the syspref FacetMaxCount');
    is( $query->{aggregations}{homebranch}{terms}{size}, 37,'we ask for the size as defined by the syspref FacetMaxCount for homebranch');
    is( $query->{aggregations}{holdingbranch}{terms}{size}, 37,'we ask for the size as defined by the syspref FacetMaxCount for holdingbranch');

    t::lib::Mocks::mock_preference('DisplayLibraryFacets','both');
    $query = $qb->build_query();
    ok( defined $query->{aggregations}{homebranch},
        'homebranch added to facets if DisplayLibraryFacets=both' );
    ok( defined $query->{aggregations}{holdingbranch},
        'holdingbranch added to facets if DisplayLibraryFacets=both' );
    t::lib::Mocks::mock_preference('DisplayLibraryFacets','holding');
    $query = $qb->build_query();
    ok( !defined $query->{aggregations}{homebranch},
        'homebranch not added to facets if DisplayLibraryFacets=holding' );
    ok( defined $query->{aggregations}{holdingbranch},
        'holdingbranch added to facets if DisplayLibraryFacets=holding' );
    t::lib::Mocks::mock_preference('DisplayLibraryFacets','home');
    $query = $qb->build_query();
    ok( defined $query->{aggregations}{homebranch},
        'homebranch added to facets if DisplayLibraryFacets=home' );
    ok( !defined $query->{aggregations}{holdingbranch},
        'holdingbranch not added to facets if DisplayLibraryFacets=home' );

    t::lib::Mocks::mock_preference( 'QueryAutoTruncate', '' );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck'] );
    is(
        $query->{query}{query_string}{query},
        "(donald duck)",
        "query not altered if QueryAutoTruncate disabled"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck'], ['kw,phr'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck")',
        "keyword as phrase correctly quotes search term and strips index"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck'], ['title'] );
    is(
        $query->{query}{query_string}{query},
        '(title:(donald duck))',
        'multiple words in a query term are enclosed in parenthesis'
    );

    ( undef, $query ) = $qb->build_query_compat( ['AND'], ['donald duck', 'disney'], ['title', 'author'] );
    is(
        $query->{query}{query_string}{query},
        '(title:(donald duck)) AND (author:disney)',
        'multiple query terms are enclosed in parenthesis while a single one is not'
    );

    my ($simple_query, $query_cgi, $query_desc);
    ( undef, $query, $simple_query, $query_cgi, $query_desc ) = $qb->build_query_compat( undef, ['"donald duck"', 'walt disney'], ['ti', 'au'] );
    is($query_cgi, 'idx=ti&q=%22donald%20duck%22&idx=au&q=walt%20disney', 'query cgi ok for multiterm query');
    is($query_desc, '(title:("donald duck")) (author:(walt disney))', 'query desc ok for multiterm query');

    ( undef, $query ) = $qb->build_query_compat( undef, ['2019'], ['yr,st-year'] );
    is(
        $query->{query}{query_string}{query},
        '(date-of-publication:2019)',
        'Year in an st-year search is handled properly'
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['2018-2019'], ['yr,st-year'] );
    is(
        $query->{query}{query_string}{query},
        '(date-of-publication:[2018 TO 2019])',
        'Year range in an st-year search is handled properly'
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['-2019'], ['yr,st-year'] );
    is(
        $query->{query}{query_string}{query},
        '(date-of-publication:[* TO 2019])',
        'Open start year in year range of an st-year search is handled properly'
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['2019-'], ['yr,st-year'] );
    is(
        $query->{query}{query_string}{query},
        '(date-of-publication:[2019 TO *])',
        'Open end year in year range of an st-year search is handled properly'
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['2019-'], ['yr,st-year'], ['yr,st-numeric=-2019'] );
    is(
        $query->{query}{query_string}{query},
        '(date-of-publication:[2019 TO *]) AND date-of-publication:[* TO 2019]',
        'Open end year in year range of an st-year search is handled properly'
    );

    # Enable auto-truncation
    t::lib::Mocks::mock_preference( 'QueryAutoTruncate', '1' );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck*)",
        "simple query is auto truncated when QueryAutoTruncate enabled"
    );

    # Ensure reserved words are not truncated
    ( undef, $query ) = $qb->build_query_compat( undef,
        ['donald or duck and mickey not mouse'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* or duck* and mickey* not mouse*)",
        "reserved words are not affected by QueryAutoTruncate"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald* duck*'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck*)",
        "query with '*' is unaltered when QueryAutoTruncate is enabled"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck and the mouse'] );
    is(
        $query->{query}{query_string}{query},
        "(donald* duck* and the* mouse*)",
        "individual words are all truncated and stopwords ignored"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['*'] );
    is(
        $query->{query}{query_string}{query},
        "(*)",
        "query of just '*' is unaltered when QueryAutoTruncate is enabled"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['"donald duck"'], undef, ['available'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck") AND onloan:false',
        "query with quotes is unaltered when QueryAutoTruncate is enabled"
    );


    ( undef, $query ) = $qb->build_query_compat( undef, ['"donald duck" and "the mouse"'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck" and "the mouse")',
        "all quoted strings are unaltered if more than one in query"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['barcode:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(barcode:123456*)',
        "query of specific field is truncated"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['Local-number:"123456"'] );
    is(
        $query->{query}{query_string}{query},
        '(local-number:"123456")',
        "query of specific field including hyphen and quoted is not truncated, field name is converted to lower case"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['Local-number:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(local-number:123456*)',
        "query of specific field including hyphen and not quoted is truncated, field name is converted to lower case"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['Local-number.raw:123456'] );
    is(
        $query->{query}{query_string}{query},
        '(local-number.raw:123456*)',
        "query of specific field including period and not quoted is truncated, field name is converted to lower case"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['Local-number.raw:"123456"'] );
    is(
        $query->{query}{query_string}{query},
        '(local-number.raw:"123456")',
        "query of specific field including period and quoted is not truncated, field name is converted to lower case"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['J.R.R'] );
    is(
        $query->{query}{query_string}{query},
        '(J.R.R*)',
        "query including period is truncated but not split at periods"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'] );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck")',
        "query of specific field is not truncated when surrounded by quotes"
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['donald duck'], ['title'] );
    is(
        $query->{query}{query_string}{query},
        '(title:(donald* duck*))',
        'words of a multi-word term are properly truncated'
    );

    ( undef, $query ) = $qb->build_query_compat( ['AND'], ['donald duck', 'disney'], ['title', 'author'] );
    is(
        $query->{query}{query_string}{query},
        '(title:(donald* duck*)) AND (author:disney*)',
        'words of a multi-word term and single-word term are properly truncated'
    );

    ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef, undef, undef, undef, { suppress => 1 } );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck") AND suppress:false',
        "query of specific field is added AND suppress:false"
    );

    ( undef, $query, $simple_query, $query_cgi, $query_desc ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef, undef, undef, undef, { suppress => 0 } );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck")',
        "query of specific field is not added AND suppress:0"
    );

    ( undef, $query ) = $qb->build_query_compat( ['AND'], ['title:"donald duck"'], undef, ['author:Dillinger Escaplan'] );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck") AND author:("Dillinger Escaplan")',
        "Simple query with limit term quoted in parentheses"
    );

    ( undef, $query ) = $qb->build_query_compat( ['AND'], ['title:"donald duck"'], undef, ['author:Dillinger Escaplan', 'itype:BOOK'] );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck") AND (author:("Dillinger Escaplan")) AND (itype:("BOOK"))',
        "Simple query with each limit's term quoted in parentheses"
    );
    is($query_cgi, 'idx=&q=title%3A%22donald%20duck%22', 'query cgi');
    is($query_desc, 'title:"donald duck"', 'query desc ok');

    ( undef, $query ) = $qb->build_query_compat( ['AND'], ['title:"donald duck"'], undef, ['author:Dillinger Escaplan', 'mc-itype,phr:BOOK', 'mc-itype,phr:CD'] );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck") AND (author:("Dillinger Escaplan")) AND itype:(("BOOK") OR ("CD"))',
        "Limits quoted correctly when passed as phrase"
    );

    # Scan queries
    ( undef, $query, $simple_query, $query_cgi, $query_desc ) = $qb->build_query_compat( undef, ['new'], ['au'], undef, undef, 1 );
    is(
        $query->{query}{query_string}{query},
        '*',
        "scan query is properly formed"
    );
    is_deeply(
        $query->{aggregations}{'author'}{'terms'},
        {
            field => 'author__facet',
            order => { '_key' => 'asc' },
            include => '[nN][eE][wW].*'
        },
        "scan aggregation request is properly formed"
    );
    is($query_cgi, 'idx=au&q=new&scan=1', 'query cgi');
    is($query_desc, 'new', 'query desc ok');

    ( undef, $query, $simple_query, $query_cgi, $query_desc ) = $qb->build_query_compat( undef, ['new'], [], undef, undef, 1 );
    is(
        $query->{query}{query_string}{query},
        '*',
        "scan query is properly formed"
    );
    is_deeply(
        $query->{aggregations}{'subject'}{'terms'},
        {
            field => 'subject__facet',
            order => { '_key' => 'asc' },
            include => '[nN][eE][wW].*'
        },
        "scan aggregation request is properly formed"
    );
    is($query_cgi, 'idx=&q=new&scan=1', 'query cgi');
    is($query_desc, 'new', 'query desc ok');

    my( $limit, $limit_cgi, $limit_desc );
    ( undef, $query, $simple_query, $query_cgi, $query_desc, $limit, $limit_cgi, $limit_desc ) = $qb->build_query_compat( ['AND'], ['kw:""'], undef, ['author:Dillinger Escaplan', 'mc-itype,phr:BOOK', 'mc-itype,phr:CD'] );
    is( $limit, '(author:("Dillinger Escaplan")) AND itype:(("BOOK") OR ("CD"))', "Limit formed correctly when no search terms");
    is( $limit_cgi,'&limit=author%3ADillinger%20Escaplan&limit=mc-itype%2Cphr%3ABOOK&limit=mc-itype%2Cphr%3ACD', "Limit CGI formed correctly when no search terms");
    is( $limit_desc,'(author:("Dillinger Escaplan")) AND itype:(("BOOK") OR ("CD"))',"Limit desc formed correctly when no search terms");
};


subtest 'build query from form subtests' => sub {
    plan tests => 5;

    my $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'authorities' }),
    #when searching for authorities from a record the form returns marclist with blanks for unentered terms
    my @marclist = ('mainmainentry','mainentry','match', 'all');
    my @values   = ( undef,         'Hamilton',  undef,   undef);
    my @operator = ( 'contains', 'contains', 'contains', 'contains');

    my $query = $qb->build_authorities_query_compat( \@marclist, undef,
                    undef, \@operator , \@values, 'AUTH_TYPE', 'asc' );
    is($query->{query}->{bool}->{must}[0]->{query_string}->{query}, "Hamilton*","Expected search is populated");
    is( scalar @{ $query->{query}->{bool}->{must} }, 1,"Only defined search is populated");

    @values[2] = 'Jefferson';
    $query = $qb->build_authorities_query_compat( \@marclist, undef,
                    undef, \@operator , \@values, 'AUTH_TYPE', 'asc' );
    is($query->{query}->{bool}->{must}[0]->{query_string}->{query}, "Hamilton*","First index searched as expected");
    is($query->{query}->{bool}->{must}[1]->{query_string}->{query}, "Jefferson*","Second index searched when populated");
    is( scalar @{ $query->{query}->{bool}->{must} }, 2,"Only defined searches are populated");


};

subtest 'build_query with weighted fields tests' => sub {
    plan tests => 6;

    $se->mock( '_load_elasticsearch_mappings', sub {
        return {
            authorities => {
                Heading => {
                    label => 'heading',
                    type => 'string',
                    opac => 0,
                    staff_client => 1,
                    mappings => [{
                        marc_field => '150',
                        marc_type => 'marc21',
                    }]
                },
                Headingmain => {
                    label => 'headingmain',
                    type => 'string',
                    opac => 1,
                    staff_client => 1,
                    mappings => [{
                        marc_field => '150',
                        marc_type => 'marc21',
                    }]
                }
            },
            biblios => {
                abstract => {
                    label => 'abstract',
                    type => 'string',
                    opac => 1,
                    staff_client => 0,
                    mappings => [{
                        marc_field => '520',
                        marc_type => 'marc21',
                    }]
                },
                acqdate => {
                    label => 'acqdate',
                    type => 'string',
                    opac => 0,
                    staff_client => 1,
                    mappings => [{
                        marc_field => '952d',
                        marc_type => 'marc21',
                        search => 0,
                    }, {
                        marc_field => '9955',
                        marc_type => 'marc21',
                        search => 0,
                    }]
                },
                title => {
                    label => 'title',
                    type => 'string',
                    opac => 0,
                    staff_client => 1,
                    mappings => [{
                        marc_field => '130',
                        marc_type => 'marc21'
                    }]
                },
                subject => {
                    label => 'subject',
                    type => 'string',
                    opac => 0,
                    staff_client => 1,
                    mappings => [{
                        marc_field => '600a',
                        marc_type => 'marc21'
                    }]
                }
            }
        };
    });

    my $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'biblios' } );
    Koha::SearchFields->search({})->delete;
    Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings();

    my $search_field;
    $search_field = Koha::SearchFields->find({ name => 'title' });
    $search_field->update({ weight => 25.0 });
    $search_field = Koha::SearchFields->find({ name => 'subject' });
    $search_field->update({ weight => 15.5 });
    Koha::SearchEngine::Elasticsearch->clear_search_fields_cache();

    my ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1 });

    my $fields = $query->{query}{query_string}{fields};

    is(@{$fields}, 2, 'Search field with no searchable mappings has been excluded');

    my @found = grep { $_ eq 'title^25.00' } @{$fields};
    is(@found, 1, 'Search field title has correct weight');

    @found = grep { $_ eq 'subject^15.50' } @{$fields};
    is(@found, 1, 'Search field subject has correct weight');

    ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1, is_opac => 1 });

    $fields = $query->{query}{query_string}{fields};

    is_deeply(
        $fields,
        ['abstract'],
        'Only OPAC search fields are used when opac search is performed'
    );

    $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'authorities' } );
    ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1 });
    $fields = $query->{query}{query_string}{fields};
    is_deeply( [sort @$fields], ['heading','headingmain'],'Authorities fields retrieve for authorities index');

    ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1, is_opac => 1 });
    $fields = $query->{query}{query_string}{fields};
    is_deeply($fields,['headingmain'],'Only opac authorities fields retrieved for authorities index is is_opac');

};

subtest 'build_query_compat() SearchLimitLibrary tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $branch_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $branch_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $group    = $builder->build_object({ class => 'Koha::Library::Groups', value => {
            ft_search_groups_opac => 1,
            ft_search_groups_staff => 1,
            parent_id => undef,
            branchcode => undef
        }
    });
    my $group_1  = $builder->build_object({ class => 'Koha::Library::Groups', value => {
            parent_id => $group->id,
            branchcode => $branch_1->id
        }
    });
    my $group_2  = $builder->build_object({ class => 'Koha::Library::Groups', value => {
            parent_id => $group->id,
            branchcode => $branch_2->id
        }
    });
    my $groupid = $group->id;
    my @branchcodes = sort { $a cmp $b } ( $branch_1->id, $branch_2->id );


    my $query_builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
    t::lib::Mocks::mock_preference('SearchLimitLibrary', 'both');
    my ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "branch:CPL" ], undef, undef, undef, undef );
    is( $limit, '(homebranch: "CPL" OR holdingbranch: "CPL")', "Branch limit expanded to home/holding branch");
    is( $limit_desc, '(homebranch: "CPL" OR holdingbranch: "CPL")', "Limit description correctly expanded");
    is( $limit_cgi, '&limit=branch%3ACPL', "Limit cgi does not get expanded");
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "multibranchlimit:$groupid" ], undef, undef, undef, undef );
    is( $limit, "(homebranch: \"$branchcodes[0]\" OR homebranch: \"$branchcodes[1]\" OR holdingbranch: \"$branchcodes[0]\" OR holdingbranch: \"$branchcodes[1]\")", "Multibranch limit expanded to home/holding branches");
    is( $limit_desc, "(homebranch: \"$branchcodes[0]\" OR homebranch: \"$branchcodes[1]\" OR holdingbranch: \"$branchcodes[0]\" OR holdingbranch: \"$branchcodes[1]\")", "Multibranch limit description correctly expanded");
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Multibranch limit cgi does not get expanded");

    t::lib::Mocks::mock_preference('SearchLimitLibrary', 'homebranch');
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "branch:CPL" ], undef, undef, undef, undef );
    is( $limit, "(homebranch: \"CPL\")", "branch limit expanded to home branch");
    is( $limit_desc, "(homebranch: \"CPL\")", "limit description correctly expanded");
    is( $limit_cgi, "&limit=branch%3ACPL", "limit cgi does not get expanded");
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "multibranchlimit:$groupid" ], undef, undef, undef, undef );
    is( $limit, "(homebranch: \"$branchcodes[0]\" OR homebranch: \"$branchcodes[1]\")", "branch limit expanded to home branch");
    is( $limit_desc, "(homebranch: \"$branchcodes[0]\" OR homebranch: \"$branchcodes[1]\")", "limit description correctly expanded");
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Limit cgi does not get expanded");

    t::lib::Mocks::mock_preference('SearchLimitLibrary', 'holdingbranch');
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "branch:CPL" ], undef, undef, undef, undef );
    is( $limit, "(holdingbranch: \"CPL\")", "branch limit expanded to holding branch");
    is( $limit_desc, "(holdingbranch: \"CPL\")", "Limit description correctly expanded");
    is( $limit_cgi, "&limit=branch%3ACPL", "Limit cgi does not get expanded");
    ( undef, undef, undef, undef, undef, $limit, $limit_cgi, $limit_desc, undef ) =
        $query_builder->build_query_compat( undef, undef, undef, [ "multibranchlimit:$groupid" ], undef, undef, undef, undef );
    is( $limit, "(holdingbranch: \"$branchcodes[0]\" OR holdingbranch: \"$branchcodes[1]\")", "branch limit expanded to holding branch");
    is( $limit_desc, "(holdingbranch: \"$branchcodes[0]\" OR holdingbranch: \"$branchcodes[1]\")", "Limit description correctly expanded");
    is( $limit_cgi, "&limit=multibranchlimit%3A$groupid", "Limit cgi does not get expanded");

};

subtest "_convert_sort_fields() tests" => sub {
    plan tests => 3;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'biblios' }),
        'Creating new query builder object for biblios'
    );

    my @sort_by = $qb->_convert_sort_fields(qw( call_number_asc author_dsc ));
    is_deeply(
        \@sort_by,
        [
            { field => 'cn-sort', direction => 'asc' },
            { field => 'author',  direction => 'desc' }
        ],
        'sort fields should have been split correctly'
    );

    # We could expect this to pass, but direction is undef instead of 'desc'
    @sort_by = $qb->_convert_sort_fields(qw( call_number_asc author_desc ));
    is_deeply(
        \@sort_by,
        [
            { field => 'cn-sort', direction => 'asc' },
            { field => 'author',  direction => 'desc' }
        ],
        'sort fields should have been split correctly'
    );
};

subtest "_sort_field() tests" => sub {
    plan tests => 5;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'biblios' }),
        'Creating new query builder object for biblios'
    );

    my $f = $qb->_sort_field('title');
    is(
        $f,
        'title__sort',
        'title sort mapped correctly'
    );

    $f = $qb->_sort_field('subject');
    is(
        $f,
        'subject.raw',
        'subject sort mapped correctly'
    );

    $f = $qb->_sort_field('itemnumber');
    is(
        $f,
        'itemnumber',
        'itemnumber sort mapped correctly'
    );

    $f = $qb->_sort_field('sortablenumber');
    is(
        $f,
        'sortablenumber__sort',
        'sortablenumber sort mapped correctly'
    );
};

$schema->storage->txn_rollback;
