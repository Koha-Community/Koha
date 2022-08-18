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

    t::lib::Mocks::mock_config( Koha::CookieManager::DENY_LIST_VAR, 'just_one' );
    my $cmgr = Koha::CookieManager->new;
    is( scalar keys %{$cmgr->{_remove_unless}}, 1, 'one entry' );
    is( exists $cmgr->{_secure}, 1, 'secure key found' );

    t::lib::Mocks::mock_config( Koha::CookieManager::DENY_LIST_VAR, [ 'two', 'entries' ] );
    $cmgr = Koha::CookieManager->new;
    is( scalar keys %{$cmgr->{_remove_unless}}, 2, 'two entries' );
};

subtest 'clear_unless' => sub {
    plan tests => 17;

    t::lib::Mocks::mock_config( Koha::CookieManager::DENY_LIST_VAR, [ 'aap', 'noot' ] );

    my $q = CGI->new;
    my $cmgr = Koha::CookieManager->new;

    my $cookie1 = $q->cookie( -name => 'aap', -value => 'aap', -expires => '+1d' );
    my $cookie2 = $q->cookie( -name => 'noot', -value => 'noot' );
    my $cookie3 = $q->cookie( -name => 'wim', -value => q{wim}, -HttpOnly => 1 );
    my $cookie4 = $q->cookie( -name => 'aap', -value => q{aap2}, -HttpOnly => 1 );
    my $list = [ $cookie1, $cookie2, $cookie3, $cookie4, 'mies', 'zus' ]; # 4 cookies, 2 names

    # No results expected
    is( @{$cmgr->clear_unless}, 0, 'Empty list' );
    is( @{$cmgr->clear_unless( { hash => 1 }, [ 'array' ], $q )}, 0, 'Empty list for invalid arguments' );

    # Pass list, expect 5 cookies (3 cleared, last aap kept)
    my @rv = @{$cmgr->clear_unless( @$list )};
    is( @rv, 5, '5 expected' );
    is( $rv[0]->name, 'noot', '1st cookie' );
    is( $rv[1]->name, 'wim', '2nd cookie' );
    is( $rv[2]->name, 'aap', '3rd cookie' );
    is( $rv[3]->name, 'mies', '4th cookie' );
    is( $rv[4]->name, 'zus', '5th cookie' );
    is( $rv[0]->value, q{noot}, 'noot not empty' );
    is( $rv[1]->value, q{}, 'wim empty' );
    is( $rv[2]->value, q{aap2}, 'aap not empty' );
    is( $rv[3]->value, q{}, 'mies empty' );
    is( $rv[4]->value, q{}, 'zus empty' );
    is( $rv[1]->httponly, 0, 'cleared wim is not httponly' );
    is( $rv[2]->httponly, 1, 'aap httponly' );

    # Test with numeric suffix (via regex)
    t::lib::Mocks::mock_config( Koha::CookieManager::DENY_LIST_VAR, [ 'catalogue_editor_\d+' ] );
    $cmgr = Koha::CookieManager->new;
    $cookie1 = $q->cookie( -name => 'catalogue_editor_abc', -value => '1', -expires => '+1y' );
    $cookie2 = $q->cookie( -name => 'catalogue_editor_345', -value => '1', -expires => '+1y' );
    $cookie3 = $q->cookie( -name => 'catalogue_editor_', -value => '1', -expires => '+1y' );
    $cookie4 = $q->cookie( -name => 'catalogue_editor_123x', -value => '1', -expires => '+1y' );

    $list = [ $cookie1, $cookie2, $cookie3, $cookie4 ];
    @rv = @{$cmgr->clear_unless( @$list )};
    is_deeply( [ map { $_->value ? $_->name : () } @rv ],
        [ 'catalogue_editor_345' ],
        'Cookie2 should be found only' );

    # Test with another regex (yes, highly realistic examples :)
    t::lib::Mocks::mock_config( Koha::CookieManager::DENY_LIST_VAR, [ 'next_\w+_number\d{2}_(now|never)' ] );
    $cmgr = Koha::CookieManager->new;
    my $cookie5;
    $cookie1 = $q->cookie( -name => 'next_mynewword_number99_never', -value => '1', -expires => '+1y' ); #fine
    $cookie2 = $q->cookie( -name => 'prefixed_next_mynewword_number99_never', -value => '1', -expires => '+1y' ); # wrong prefix
    $cookie3 = $q->cookie( -name => 'next_mynew-word_number99_never', -value => '1', -expires => '+1y' ); # wrong: hyphen in word
    $cookie4 = $q->cookie( -name => 'mynewword_number999_never', -value => '1', -expires => '+1y' ); # wrong: three digits
    $cookie5 = $q->cookie( -name => 'next_mynewword_number99_always', -value => '1', -expires => '+1y' ); # wrong: always
    @rv = @{$cmgr->clear_unless( $cookie1, $cookie2, $cookie3, $cookie4, $cookie5 )};
    is_deeply( [ map { $_->value ? $_->name : () } @rv ], [ 'next_mynewword_number99_never' ], 'Only cookie1 matched' );

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
