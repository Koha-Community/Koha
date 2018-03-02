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

use Test::More tests => 2;
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
