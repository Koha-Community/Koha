#!/usr/bin/perl
#
# Copyright 2022 Rijksmuseum, Koha Development Team
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
use CGI;
use Data::Dumper qw(Dumper);
use Test::More tests => 3;

use t::lib::Mocks;

use C4::Context;
use Koha::CookieManager;

subtest 'new' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_config( Koha::CookieManager::ALLOW_LIST_VAR, 'just_one' );
    my $cmgr = Koha::CookieManager->new;
    is( scalar keys %{$cmgr->{_remove_allowed}}, 1, 'one entry' );
    is( exists $cmgr->{_secure}, 1, 'secure key found' );

    t::lib::Mocks::mock_config( Koha::CookieManager::ALLOW_LIST_VAR, [ 'two', 'entries' ] );
    $cmgr = Koha::CookieManager->new;
    is( scalar keys %{$cmgr->{_remove_allowed}}, 2, 'two entries' );
};

subtest 'clear_if_allowed' => sub {
    plan tests => 13;

    t::lib::Mocks::mock_config( Koha::CookieManager::ALLOW_LIST_VAR, [ 'aap', 'noot', 'mies' ] );

    my $q = CGI->new;
    my $cmgr = Koha::CookieManager->new;

    my $cookie1 = $q->cookie(
        -name => 'aap',
        -value => 'aap',
        -expires => '+1d',
        -HttpOnly => 1,
        -secure => 1,
    );
    my $cookie2 = $q->cookie(
        -name => 'noot',
        -value => 'noot',
        -expires => '+1d',
        -HttpOnly => 1,
        -secure => 1,
    );
    my $cookie3 = $q->cookie( -name => 'wim', -value => q{wim}, -HttpOnly => 1 );
    my $cookie4 = $q->cookie( -name => 'aap', -value => q{aap2} );
    my $list = [ $cookie1, $cookie2, $cookie3, $cookie4, 'mies', 'zus' ]; # 4 cookies, 2 names

    # No results expected
    is( @{$cmgr->clear_if_allowed}, 0, 'Empty list' );
    is( @{$cmgr->clear_if_allowed( 'scalar', [], $q )}, 0, 'Empty list for invalid arguments' );

    # Pass list, expect 4 cookies (3 cleared)
    my @rv = @{$cmgr->clear_if_allowed( @$list )};
    is( @rv, 4, 'Four expected' );
    is( $rv[0]->name, 'aap', 'First cookie' );
    is( $rv[1]->name, 'noot', '2nd cookie' );
    is( $rv[2]->name, 'wim', '3rd cookie' );
    is( $rv[3]->name, 'mies', '4th cookie' );
    is( $rv[0]->value, q{}, 'aap should be empty' );
    is( $rv[1]->value, q{}, 'noot should be empty' );
    is( $rv[2]->value, 'wim', 'wim not empty' );
    is( $rv[3]->value, q{}, 'mies empty' );
    is( $rv[0]->httponly, 0, 'cleared aap isnt httponly' );
    is( $rv[2]->httponly, 1, 'wim still httponly' );
};

subtest 'replace_in_list' => sub {
    plan tests => 13;

    my $q = CGI->new;
    my $cmgr = Koha::CookieManager->new;

    my $cookie1 = $q->cookie( -name => 'c1', -value => q{c1} );
    my $cookie2 = $q->cookie( -name => 'c2', -value => q{c2} );
    my $cookie3 = $q->cookie( -name => 'c3', -value => q{c3} );
    my $cookie4 = $q->cookie( -name => 'c2', -value => q{c4} ); # name c2 !

    # Unusual arguments (show that $cmgr handles the cookie mocks in Auth.t)
    my $res = $cmgr->replace_in_list( [ 1, 2, 3 ], 4 );
    is( @$res, 0, 'No cookies' );
    $res = $cmgr->replace_in_list( [ 1, 2, 3 ], $cookie1 );
    is( @$res, 1, 'One cookie added' );
    is( $res->[0]->name, 'c1', '1st cookie' );
    $res = $cmgr->replace_in_list( [ $cookie2, 2, 3 ], 4 ); # filter 2,3 and ignore 4
    is( @$res, 1, 'One cookie found' );
    is( $res->[0]->name, 'c2', 'c2 found' );

    # Pass c1 c2, add c3
    $res = $cmgr->replace_in_list( [ $cookie1, $cookie2 ], $cookie3 );
    is( @$res, 3, 'Returns three' );
    is( $res->[2]->name, 'c3', '3rd cookie' );
    is( $res->[2]->value, 'c3', 'value c3' );

    # Pass c1 c2 c3 and replace c2
    $res = $cmgr->replace_in_list( [ $cookie1, $cookie2, $cookie3 ], $cookie4 );
    is( @$res, 3, 'Returns three' );
    is( $res->[0]->name, 'c1', '1st cookie' );
    is( $res->[1]->name, 'c3', '2nd cookie' );
    is( $res->[2]->name, 'c2', '3rd cookie' );
    is( $res->[2]->value, 'c4', 'value replaced' );
};
