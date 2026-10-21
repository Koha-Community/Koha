#!/usr/bin/perl

# Copyright 2026 ByWater Solutions
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
use Test::More tests => 7;

use t::lib::Mocks;

use_ok("Koha::Middleware::ComplexityScore");

my $app = sub { return [ 200, [], [] ] };

subtest "score_for_path() default weights" => sub {
    plan tests => 15;

    my $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;

    # Heavier OPAC endpoints, dev proxy path shape ( /cgi-bin/koha/... )
    is( $mw->score_for_path('/cgi-bin/koha/opac-search.pl'),            25, 'opac-search.pl scores 25' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-detail.pl'),            20, 'opac-detail.pl scores 20' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-browse.pl'),            15, 'opac-browse.pl scores 15' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-shelves.pl'),           12, 'opac-shelves.pl scores 12' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-MARCdetail.pl'),        10, 'opac-MARCdetail.pl scores 10' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-ISBDdetail.pl'),        7,  'opac-ISBDdetail.pl scores 7' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-authoritiesdetail.pl'), 6,  'opac-authoritiesdetail.pl scores 6' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-export.pl'),            4,  'opac-export.pl scores 4' );

    # Packaged proxy path shape ( /opac/... ) scores the same
    is(
        $mw->score_for_path('/opac/opac-search.pl'), 25,
        'packaged /opac/ path shape scores the same as the dev shape'
    );

    # A svc subpath - the script name is the final path segment
    is( $mw->score_for_path('/cgi-bin/koha/svc/shelfbrowser.pl'), 2, 'svc/shelfbrowser.pl scores 2' );

    # The cheap classification browser must not be confused with the heavy browse endpoint
    is(
        $mw->score_for_path('/cgi-bin/koha/opac-browser.pl'), 2,
        'opac-browser.pl (classification browser) stays light at 2'
    );

    # Anything not in the map gets the baseline weight of 1
    is( $mw->score_for_path('/cgi-bin/koha/opac-main.pl'),    1, 'unmapped opac-main.pl gets baseline 1' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-reserve.pl'), 1, 'unmapped script gets baseline 1' );
    is( $mw->score_for_path(''),                              1, 'empty path gets baseline 1' );
    is( $mw->score_for_path(undef),                           1, 'undef path gets baseline 1' );
};

subtest "extra path info after the script doesn't change the score" => sub {
    plan tests => 6;

    my $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;

    is( $mw->score_for_path('/cgi-bin/koha/opac-search.pl/'), 25, 'a trailing slash still scores the script' );
    is(
        $mw->score_for_path('/cgi-bin/koha/opac-search.pl/foo'), 25,
        'a trailing path segment still scores the script'
    );
    is(
        $mw->score_for_path('/cgi-bin/koha/opac-search.pl/opac-main.pl'), 25,
        'a cheaper script name in the path info does not replace the script that runs'
    );
    is( $mw->score_for_path('/cgi-bin/koha/opac-search.pl\\foo'), 25, 'a backslash separator still scores the script' );
    is( $mw->score_for_path('/opac/opac-detail.pl/'), 20, 'packaged /opac/ path shape with a trailing slash' );
    is( $mw->score_for_path('/cgi-bin/koha/svc/shelfbrowser.pl/'), 2, 'svc script with a trailing slash' );
};

subtest "koha-conf.xml weights override and extend the defaults" => sub {
    plan tests => 4;

    t::lib::Mocks::mock_config( 'complexity_score_weights', { 'opac-search.pl' => 40, 'opac-reserve.pl' => 9 } );

    my $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;

    is( $mw->score_for_path('/cgi-bin/koha/opac-search.pl'),  40, 'a configured weight overrides the default' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-reserve.pl'), 9,  'a new script can be added via config' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-detail.pl'),  20, 'an unoverridden default is left untouched' );
    is( $mw->score_for_path('/cgi-bin/koha/opac-main.pl'),    1,  'an unlisted script still gets baseline 1' );
};

subtest "prepare_app() honors configuration" => sub {
    plan tests => 6;

    t::lib::Mocks::mock_config( 'complexity_score_header',      1 );
    t::lib::Mocks::mock_config( 'complexity_score_header_name', 'x-foo-score' );
    my $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;
    is( $mw->enabled,     1,             'enabled when complexity_score_header is set' );
    is( $mw->header_name, 'x-foo-score', 'header_name honors complexity_score_header_name' );

    t::lib::Mocks::mock_config( 'complexity_score_header', 0 );
    $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;
    is( $mw->enabled, 0, 'disabled when complexity_score_header is 0' );

    t::lib::Mocks::mock_config( 'complexity_score_header',      1 );
    t::lib::Mocks::mock_config( 'complexity_score_header_name', undef );
    $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;
    is( $mw->enabled,     1,                    'still enabled' );
    is( $mw->header_name, 'x-complexity-score', 'header_name defaults to x-complexity-score when unset' );

    t::lib::Mocks::mock_config( 'complexity_score_header', undef );
    $mw = Koha::Middleware::ComplexityScore->new( app => $app );
    $mw->prepare_app;
    is( $mw->enabled, 0, 'disabled by default when no config is present' );
};

subtest "call() sets the header only when enabled" => sub {
    plan tests => 4;

    # Use the built-in default weights
    t::lib::Mocks::mock_config( 'complexity_score_weights', undef );

    my $inner = sub { return [ 200, [ 'Content-Type' => 'text/html' ], ['ok'] ] };

    # Disabled: the middleware is a pass-through and adds no header
    t::lib::Mocks::mock_config( 'complexity_score_header', 0 );
    my $mw = Koha::Middleware::ComplexityScore->new( app => $inner );
    $mw->prepare_app;
    my %headers = @{ $mw->call( { PATH_INFO => '/cgi-bin/koha/opac-search.pl' } )->[1] };
    ok( !exists $headers{'x-complexity-score'}, 'no header is added when the feature is disabled' );

    # Enabled: the header carries the endpoint weight
    t::lib::Mocks::mock_config( 'complexity_score_header',      1 );
    t::lib::Mocks::mock_config( 'complexity_score_header_name', 'x-complexity-score' );
    $mw = Koha::Middleware::ComplexityScore->new( app => $inner );
    $mw->prepare_app;
    %headers = @{ $mw->call( { PATH_INFO => '/cgi-bin/koha/opac-search.pl' } )->[1] };
    is( $headers{'x-complexity-score'}, 25, 'header is set to the endpoint weight when enabled' );

    # An unmapped endpoint gets the baseline weight
    %headers = @{ $mw->call( { PATH_INFO => '/cgi-bin/koha/opac-main.pl' } )->[1] };
    is( $headers{'x-complexity-score'}, 1, 'an unmapped endpoint gets the baseline weight' );

    # The configured header name is used
    t::lib::Mocks::mock_config( 'complexity_score_header_name', 'x-foo' );
    $mw = Koha::Middleware::ComplexityScore->new( app => $inner );
    $mw->prepare_app;
    %headers = @{ $mw->call( { PATH_INFO => '/cgi-bin/koha/opac-detail.pl' } )->[1] };
    is( $headers{'x-foo'}, 20, 'the configured header name carries the weight' );
};
