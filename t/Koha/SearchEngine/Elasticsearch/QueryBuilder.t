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

use Test::More tests => 6;
use t::lib::Mocks;

use_ok('Koha::SearchEngine::Elasticsearch::QueryBuilder');

subtest 'query_regex_escape_options' => sub {
    plan tests => 12;

    t::lib::Mocks::mock_preference('QueryRegexEscapeOptions', 'dont_escape');

    my $query_with_regexp = "query /with regexp/";

    my $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_regexp);
    is(
        $processed_query,
        $query_with_regexp,
        "Unescaped query regexp has not been escaped when escaping is disabled"
    );

    t::lib::Mocks::mock_preference('QueryRegexEscapeOptions', 'escape');

    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_regexp);
    is(
        $processed_query,
        "query \\/with regexp\\/",
        "Unescaped query regexp has been escaped when escaping is enabled"
    );

    my $query_with_escaped_regex = "query \\/with regexp\\/";
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_escaped_regex);
    is(
        $processed_query,
        $query_with_escaped_regex,
        "Escaped query regexp has been left unmodified when escaping is enabled"
    );

    my $query_with_even_preceding_escapes_regex = "query \\\\/with regexp\\\\/";
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_even_preceding_escapes_regex);
    is(
        $processed_query,
        "query \\\\\\/with regexp\\\\\\/",
        "Query regexp with even preceding escapes, thus unescaped, has been escaped when escaping is enabled"
    );

    my $query_with_odd_preceding_escapes_regex = 'query \\\\\\/with regexp\\\\\\/';
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_odd_preceding_escapes_regex);
    is(
        $processed_query,
        $query_with_odd_preceding_escapes_regex,
        "Query regexp with odd preceding escapes, thus escaped, has been left unmodified when escaping is enabled"
    );

    my $query_with_quoted_slash = "query with / and \"/ within quotes\"";
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_quoted_slash);
    is(
        $processed_query,
        "query with \\/ and \"/ within quotes\"",
        "Unescaped slash outside of quotes has been escaped while unescaped slash within quotes is left as is when escaping is enabled."
    );

    t::lib::Mocks::mock_preference('QueryRegexEscapeOptions', 'unescape_escaped');

    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_regexp);
    is(
        $processed_query,
        "query \\/with regexp\\/",
        "Unescaped query regexp has been escaped when unescape escaping is enabled"
    );

    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_escaped_regex);
    is(
        $processed_query,
        "query /with regexp/",
        "Escaped query regexp has been unescaped when unescape escaping is enabled"
    );

    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_even_preceding_escapes_regex);
    is(
        $processed_query,
        "query \\\\\\/with regexp\\\\\\/",
        "Query regexp with even preceding escapes, thus unescaped, has been escaped when unescape escaping is enabled"
    );

    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_odd_preceding_escapes_regex);
    is(
        $processed_query,
        "query \\\\/with regexp\\\\/",
        "Query regexp with odd preceding escapes, thus escaped, has been unescaped when unescape escaping is enabled"
    );

    my $regexp_at_start_of_string_with_odd_preceding_escapes_regex = '\\\\\\/regexp\\\\\\/';
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($regexp_at_start_of_string_with_odd_preceding_escapes_regex);
    is(
        $processed_query,
        "\\\\/regexp\\\\/",
        "Regexp at start of string with odd preceding escapes, thus escaped, has been unescaped when unescape escaping is enabled"
    );

    my $query_with_quoted_escaped_slash = "query with \\/ and \"\\/ within quotes\"";
    $processed_query = Koha::SearchEngine::Elasticsearch::QueryBuilder->_query_regex_escape_process($query_with_quoted_escaped_slash);
    is(
        $processed_query,
        "query with / and \"\\/ within quotes\"",
        "Escaped slash outside of quotes has been unescaped while escaped slash within quotes is left as is when unescape escaping is enabled."
    );
};

subtest '_truncate_terms() tests' => sub {
    plan tests => 7;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my $res = $qb->_truncate_terms('donald');
    is_deeply($res, 'donald*', 'single search term returned correctly');

    $res = $qb->_truncate_terms('donald duck');
    is_deeply($res, 'donald* duck*', 'two search terms returned correctly');

    $res = $qb->_truncate_terms(' donald   duck ');
    is_deeply($res, 'donald* duck*', 'two search terms surrounded by spaces returned correctly');

    $res = $qb->_truncate_terms('"donald duck"');
    is_deeply($res, '"donald duck"', 'quoted search term returned correctly');

    $res = $qb->_truncate_terms('"donald, duck"');
    is_deeply($res, '"donald, duck"', 'quoted search term with comma returned correctly');

    $res = $qb->_truncate_terms(' "donald   duck" ');
    is_deeply($res, '"donald   duck"', 'quoted search terms surrounded by spaces correctly');
};

subtest '_split_query() tests' => sub {
    plan tests => 7;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my @res = $qb->_split_query('donald');
    my @exp = 'donald';
    is_deeply(\@res, \@exp, 'single search term returned correctly');

    @res = $qb->_split_query('donald duck');
    @exp = ('donald', 'duck');
    is_deeply(\@res, \@exp, 'two search terms returned correctly');

    @res = $qb->_split_query(' donald   duck ');
    @exp = ('donald', 'duck');
    is_deeply(\@res, \@exp, 'two search terms surrounded by spaces returned correctly');

    @res = $qb->_split_query('"donald duck"');
    @exp = ( '"donald duck"' );
    is_deeply(\@res, \@exp, 'quoted search term returned correctly');

    @res = $qb->_split_query('"donald, duck"');
    @exp = ( '"donald, duck"' );
    is_deeply(\@res, \@exp, 'quoted search term with comma returned correctly');

    @res = $qb->_split_query(' "donald   duck" ');
    @exp = ( '"donald   duck"' );
    is_deeply(\@res, \@exp, 'quoted search terms surrounded by spaces correctly');
};

subtest '_clean_search_term() tests' => sub {
    plan tests => 11;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my $res = $qb->_clean_search_term('an=123');
    is($res, 'koha-auth-number:123', 'equals sign replaced with colon');

    $res = $qb->_clean_search_term('"balanced quotes"');
    is($res, '"balanced quotes"', 'balanced quotes returned correctly');

    $res = $qb->_clean_search_term('unbalanced quotes"');
    is($res, 'unbalanced quotes ', 'unbalanced quotes removed');

    $res = $qb->_clean_search_term('"unbalanced "quotes"');
    is($res, ' unbalanced  quotes ', 'unbalanced quotes removed');

    $res = $qb->_clean_search_term('test : query');
    is($res, 'test  query', 'dangling colon removed');

    $res = $qb->_clean_search_term('test :: query');
    is($res, 'test  query', 'dangling double colon removed');

    $res = $qb->_clean_search_term('test "another : query"');
    is($res, 'test "another : query"', 'quoted dangling colon not removed');

    $res = $qb->_clean_search_term('test {another part}');
    is($res, 'test "another part"', 'curly brackets replaced correctly');

    $res = $qb->_clean_search_term('test {another part');
    is($res, 'test  another part', 'unbalanced curly brackets replaced correctly');

    $res = $qb->_clean_search_term('ti:test AND kw:test');
    is($res, 'title:test AND test', 'ti converted to title, kw converted to empty string, dangling colon removed with space preserved');
};

subtest '_join_queries' => sub {
    plan tests => 6;

    my $params = {
        index => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX,
    };
    my $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new($params);

    my $query;

    $query = $qb->_join_queries('foo');
    is($query, 'foo', 'should work with a single param');

    $query = $qb->_join_queries(undef, '', 'foo', '', undef);
    is($query, 'foo', 'should ignore undef or empty queries');

    $query = $qb->_join_queries('foo', 'bar');
    is($query, '(foo) AND (bar)', 'should join queries with an AND');

    $query = $qb->_join_queries('homebranch:foo', 'onloan:false');
    is($query, '(homebranch:foo) AND (onloan:false)', 'should also work when field is specified');

    $query = $qb->_join_queries('homebranch:foo', 'mc-itype:BOOK', 'mc-itype:EBOOK');
    is($query, '(homebranch:foo) AND itype:(BOOK OR EBOOK)', 'should join with OR when using an "mc-" field');

    $query = $qb->_join_queries('homebranch:foo', 'mc-itype:BOOK', 'mc-itype:EBOOK', 'mc-location:SHELF');
    is($query, '(homebranch:foo) AND itype:(BOOK OR EBOOK) AND location:(SHELF)', 'should join "mc-" parts with AND if not the same field');
};

1;
