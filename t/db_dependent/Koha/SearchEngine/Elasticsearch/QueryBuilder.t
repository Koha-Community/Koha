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
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::More tests => 6;

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
                    type => 'text'
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
                Heading => {
                    type => 'text'
                },
                Heading__sort => {
                    type => 'text'
                }
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
    plan tests => 36;

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
    }

    $search_term = 'Donald Duck';
    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            is( $query->{query}->{bool}->{must}[0]->{query_string}->{query},
                "(Donald*) AND (Duck*)");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{query_string}->{query},
                "(Donald*) AND (Duck*)");
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['is'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            is( $query->{query}->{bool}->{must}[0]->{match_phrase}->{"_all.phrase"},
                "donald duck");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{match_phrase}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "donald duck");
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['start'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' || $koha_name eq 'any' ) {
            is( $query->{query}->{bool}->{must}[0]->{match_phrase_prefix}->{"_all.phrase"},
                "donald duck");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{match_phrase_prefix}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "donald duck");
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

    # Failing case
    throws_ok {
        $qb->build_authorities_query_compat( [ 'tomas' ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
    }
    'Koha::Exceptions::WrongParameter',
        'Exception thrown on invalid value in the marclist param';
};

subtest 'build_query tests' => sub {
    plan tests => 33;

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
            'title__sort.phrase' => {
                    'order' => 'asc'
                }
            }
        ],
        "sort parameter properly formed"
    );

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

    ( undef, $query ) = $qb->build_query_compat( undef, ['"donald duck"'] );
    is(
        $query->{query}{query_string}{query},
        '("donald duck")',
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
        '(title:"donald duck") AND suppress:0',
        "query of specific field is added AND suppress:0"
    );

    ( undef, $query, $simple_query, $query_cgi, $query_desc ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef, undef, undef, undef, { suppress => 0 } );
    is(
        $query->{query}{query_string}{query},
        '(title:"donald duck")',
        "query of specific field is not added AND suppress:0"
    );
    is($query_cgi, 'idx=&q=title%3A%22donald%20duck%22', 'query cgi');
    is($query_desc, 'title:"donald duck"', 'query desc ok');
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
    plan tests => 4;

    my $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'mydb' } );
    my $db_builder = t::lib::TestBuilder->new();

    Koha::SearchFields->search({})->delete;

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'acqdate',
            label   => 'acqdate',
            weight  => undef
        }
    });

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'title',
            label   => 'title',
            weight  => 25
        }
    });

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'subject',
            label   => 'subject',
            weight  => 15
        }
    });

    my ( undef, $query ) = $qb->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1 });

    my $fields = $query->{query}{query_string}{fields};
    is(scalar(@$fields), 3, 'Search is done on 3 fields');
    is($fields->[0], '_all', 'First search field is _all');
    is($fields->[1], 'title^25.00', 'Second search field is title');
    is($fields->[2], 'subject^15.00', 'Third search field is subject');
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
            { field => 'local-classification', direction => 'asc' },
            { field => 'author',  direction => 'desc' }
        ],
        'sort fields should have been split correctly'
    );

    # We could expect this to pass, but direction is undef instead of 'desc'
    @sort_by = $qb->_convert_sort_fields(qw( call_number_asc author_desc ));
    is_deeply(
        \@sort_by,
        [
            { field => 'local-classification', direction => 'asc' },
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
        'title__sort.phrase',
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
