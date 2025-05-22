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

#use Data::Dumper qw(Dumper);
use Test::NoWarnings;
use Test::More tests => 5;

use t::lib::Mocks;

use C4::Context;
use Koha::CookieManager;

subtest 'new' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_config( Koha::CookieManager::KEEP_COOKIE_CONF_VAR, 'just_one' );
    my $cmgr = Koha::CookieManager->new;
    is( scalar @{ $cmgr->{_keep_list} }, 1, 'one entry to keep' );
    is( exists $cmgr->{_secure},         1, 'secure key found' );

    t::lib::Mocks::mock_config( Koha::CookieManager::KEEP_COOKIE_CONF_VAR,   [ 'two', 'entries' ] );
    t::lib::Mocks::mock_config( Koha::CookieManager::REMOVE_COOKIE_CONF_VAR, ['test'] );
    $cmgr = Koha::CookieManager->new;
    is( scalar @{ $cmgr->{_keep_list} },   2, 'two entries to keep' );
    is( scalar @{ $cmgr->{_remove_list} }, 1, 'one entry to remove' );
};

subtest 'clear_unless' => sub {
    plan tests => 14;

    t::lib::Mocks::mock_config( Koha::CookieManager::KEEP_COOKIE_CONF_VAR,   [ 'aap', 'noot' ] );
    t::lib::Mocks::mock_config( Koha::CookieManager::REMOVE_COOKIE_CONF_VAR, ['mies'] );

    my $q    = CGI->new;
    my $cmgr = Koha::CookieManager->new;

    my $cookie1 = $q->cookie( -name => 'aap',  -value => 'aap', -expires => '+1d' );
    my $cookie2 = $q->cookie( -name => 'noot', -value => 'noot' );
    my $cookie3 = $q->cookie( -name => 'wim',  -value => q{wim},  -HttpOnly => 0 );
    my $cookie4 = $q->cookie( -name => 'aap',  -value => q{aap2}, -HttpOnly => 1 );
    my $list    = [ $cookie1, $cookie2, $cookie3, $cookie4, 'mies', 'zus' ];    # 4 cookies, 2 names

    # No results expected
    is( @{ $cmgr->clear_unless },                                 0, 'Empty list' );
    is( @{ $cmgr->clear_unless( { hash => 1 }, ['array'], $q ) }, 0, 'Empty list for invalid arguments' );

    # Pass list, expecting 4 cookies (2 kept, 1 untouched, 1 cleared); duplicate aap and zus discarded
    my @rv = @{ $cmgr->clear_unless(@$list) };
    is( @rv,              4,       '4 expected' );
    is( $rv[0]->name,     'noot',  '1st cookie' );
    is( $rv[1]->name,     'wim',   '2nd cookie' );
    is( $rv[2]->name,     'aap',   '3rd cookie' );
    is( $rv[3]->name,     'mies',  '4th cookie' );
    is( $rv[0]->value,    q{noot}, 'noot kept' );
    is( $rv[1]->value,    q{wim},  'wim untouched' );
    is( $rv[2]->value,    q{aap2}, 'aap kept, last entry' );
    is( $rv[3]->value,    q{},     'mies cleared' );
    is( $rv[1]->httponly, undef,   'wim still not httponly' );
    is( $rv[2]->httponly, 1,       'aap httponly' );

    # Test with prefix (note trailing underscore)
    t::lib::Mocks::mock_config( Koha::CookieManager::KEEP_COOKIE_CONF_VAR,   'catalogue_editor_' );
    t::lib::Mocks::mock_config( Koha::CookieManager::REMOVE_COOKIE_CONF_VAR, 'catalogue_editor' );
    $cmgr    = Koha::CookieManager->new;
    $cookie1 = $q->cookie( -name => 'catalogue_editor',   -value => '1' );
    $cookie2 = $q->cookie( -name => 'catalogue_editor2',  -value => '2' );
    $cookie3 = $q->cookie( -name => 'catalogue_editor_3', -value => '3' );

    $list = [ $cookie1, $cookie2, $cookie3, 'catalogue_editor4' ];
    my $result = [ map { defined( $_->max_age ) ? () : $_->name } @{ $cmgr->clear_unless(@$list) } ];
    is_deeply( $result, ['catalogue_editor_3'], 'Only cookie3 is kept (not expired)' );
};

subtest 'path exception' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_config( Koha::CookieManager::REMOVE_COOKIE_CONF_VAR, ['always_show_holds'] );
    my $q       = CGI->new;
    my $cmgr    = Koha::CookieManager->new;
    my $cookie1 = $q->cookie( -name => 'always_show_holds', -value => 'DO', path => '/cgi-bin/koha/reserve' );
    my @rv      = @{ $cmgr->clear_unless($cookie1) };
    is( $rv[0]->name,    'always_show_holds',     'Check name' );
    is( $rv[0]->path,    '/cgi-bin/koha/reserve', 'Check path' );
    is( $rv[0]->max_age, 0,                       'Check max_age' );
    my $cookie2 = $q->cookie( -name => 'always_show_holds', -value => 'DONT' );    # default path
    @rv = @{ $cmgr->clear_unless($cookie2) };
    is( $rv[0]->path, '/cgi-bin/koha/reserve', 'Check path cookie2, corrected here' );
};

subtest 'replace_in_list' => sub {
    plan tests => 13;

    my $q    = CGI->new;
    my $cmgr = Koha::CookieManager->new;

    my $cookie1 = $q->cookie( -name => 'c1', -value => q{c1} );
    my $cookie2 = $q->cookie( -name => 'c2', -value => q{c2} );
    my $cookie3 = $q->cookie( -name => 'c3', -value => q{c3} );
    my $cookie4 = $q->cookie( -name => 'c2', -value => q{c4} );    # name c2 !

    # Unusual arguments (show that $cmgr handles the cookie mocks in Auth.t)
    my $res = $cmgr->replace_in_list( [ 1, 2, 3 ], 4 );
    is( @$res, 0, 'No cookies' );
    $res = $cmgr->replace_in_list( [ 1, 2, 3 ], $cookie1 );
    is( @$res,           1,    'One cookie added' );
    is( $res->[0]->name, 'c1', '1st cookie' );
    $res = $cmgr->replace_in_list( [ $cookie2, 2, 3 ], 4 );        # filter 2,3 and ignore 4
    is( @$res,           1,    'One cookie found' );
    is( $res->[0]->name, 'c2', 'c2 found' );

    # Pass c1 c2, add c3
    $res = $cmgr->replace_in_list( [ $cookie1, $cookie2 ], $cookie3 );
    is( @$res,            3,    'Returns three' );
    is( $res->[2]->name,  'c3', '3rd cookie' );
    is( $res->[2]->value, 'c3', 'value c3' );

    # Pass c1 c2 c3 and replace c2
    $res = $cmgr->replace_in_list( [ $cookie1, $cookie2, $cookie3 ], $cookie4 );
    is( @$res,            3,    'Returns three' );
    is( $res->[0]->name,  'c1', '1st cookie' );
    is( $res->[1]->name,  'c3', '2nd cookie' );
    is( $res->[2]->name,  'c2', '3rd cookie' );
    is( $res->[2]->value, 'c4', 'value replaced' );
};
