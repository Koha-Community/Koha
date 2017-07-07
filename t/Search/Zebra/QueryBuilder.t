#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 2;
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
    my $built_search =
      Koha::SearchEngine::Zebra::QueryBuilder->build_authorities_query( @test_search );
    is_deeply(
        $built_search, $expected_result,
        "We are simply hashifying our array of refs/values, should otherwise not be altered"
    );
    $expected_result->{value} = ['"any"'];
    $test_search[4] = ['"any"'];
    $built_search =
      Koha::SearchEngine::Zebra::QueryBuilder->build_authorities_query( @test_search );
    is_deeply(
        $built_search, $expected_result,
        "The same should hold true if the search contains double quotes which will be escaped during searching by search_auth_compat subroutine"
    );
};
