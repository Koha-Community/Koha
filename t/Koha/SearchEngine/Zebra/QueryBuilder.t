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

use_ok('Koha::SearchEngine::Zebra::QueryBuilder');

subtest 'build_authorities_query' => sub {
    plan tests => 2;

    my @test_search = (
        ['mainmainentry'], ['and'], [''], ['contains'], ['any'], '',
        'HeadingAsc'
    );
    my $expected_result = {
        marclist     => ['mainmainentry'],
        and_or       => ['and'],
        excluding    => [''],
        operator     => ['contains'],
        value        => ['any'],
        authtypecode => '',
        orderby      => 'HeadingAsc',
    };
    my $built_search = Koha::SearchEngine::Zebra::QueryBuilder->build_authorities_query(@test_search);
    is_deeply(
        $built_search, $expected_result,
        "We are simply hashifying our array of refs/values, should otherwise not be altered"
    );
    $expected_result->{value} = ['"any"'];
    $test_search[4]           = ['"any"'];
    $built_search             = Koha::SearchEngine::Zebra::QueryBuilder->build_authorities_query(@test_search);
    is_deeply(
        $built_search, $expected_result,
        "The same should hold true if the search contains double quotes which will be escaped during searching by search_auth_compat subroutine"
    );
};

subtest 'build_query_compat() tests' => sub {

    plan tests => 4;

    my $search = Test::MockModule->new('C4::Search');
    $search->mock(
        'buildQuery',
        sub {
            return (
                'error', 'query', 'simple_query', 'query_cgi', 'query_desc', 'limit', 'limit_cgi', 'limit_desc',
                'query_type'
            );
        }
    );
    my $qb = Koha::SearchEngine::Zebra::QueryBuilder->new();
    my $query;

    ( undef, $query ) = $qb->build_query_compat( undef, undef, undef, undef, undef, undef, undef, { suppress => 1 } );
    is( $query, '(query) not Suppress=1', 'Suppress part of the query added correctly' );

    ( undef, $query ) = $qb->build_query_compat( undef, undef, undef, undef, undef, undef, undef, { suppress => 0 } );
    is( $query, 'query', 'Suppress part of the query not added' );

    $search->mock(
        'buildQuery',
        sub {
            return (
                'error', 'query', 'simple_query', 'query_cgi', 'query_desc', 'limit', 'limit_cgi', 'limit_desc',
                'pqf'
            );
        }
    );
    ( undef, $query ) = $qb->build_query_compat( undef, undef, undef, undef, undef, undef, undef, { suppress => 1 } );
    is( $query, '@not query @attr 14=1 @attr 1=9011 1', 'Suppress part of the query added correctly (PQF)' );

    ( undef, $query ) = $qb->build_query_compat( undef, undef, undef, undef, undef, undef, undef, { suppress => 0 } );
    is( $query, 'query', 'Suppress part of the query not added (PQF)' );
};

subtest 'clean_search_term() tests' => sub {

    plan tests => 2;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Zebra::QueryBuilder->new(),
        'Creating a new QueryBuilder object'
    );

    my $res = $qb->clean_search_term('test "query":');
    is( $res, 'test \"query\":', 'Double-quotes are escaped' );
};
