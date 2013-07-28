#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use_ok('C4::Auth', qw/ParseSearchHistoryCookie/);

my $valid_cookie = "%5B%7B%22time%22%3A1374978877%2C%22query_cgi%22%3A%22idx%3D%26q%3Dhistory%26branch_group_limit%3D%22%2C%22total%22%3A2%2C%22query_desc%22%3A%22kw%2Cwrdl%3A%20history%2C%20%22%7D%5D";
my $expected_recent_searches = [
    {
        'time' => 1374978877,
        'query_cgi' => 'idx=&q=history&branch_group_limit=',
        'total' => 2,
        'query_desc' => 'kw,wrdl: history, '
    }
];

my $input = CookieSimulator->new($valid_cookie);
my @recent_searches = ParseSearchHistoryCookie($input);
is_deeply(\@recent_searches, $expected_recent_searches, 'parsed valid search history cookie value');

# simulate bit of a Storable-based search history cookie
my $invalid_cookie = "%04%08%0812345";
$input = CookieSimulator->new($invalid_cookie);
@recent_searches = ParseSearchHistoryCookie($input);
is_deeply(\@recent_searches, [], 'got back empty search history list if given invalid cookie');

package CookieSimulator;

sub new {
    my ($class, $str) = @_;
    my $val = [ $str ];
    return bless $val, $class;
}

sub cookie {
    my $self = shift;
    return $self->[0];
}

1;
