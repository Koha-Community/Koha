#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use_ok('C4::Auth', qw/ParseSearchHistorySession SetSearchHistorySession get_session/);

my $expected_recent_searches = [
    {
        'time' => 1374978877,
        'query_cgi' => 'idx=&q=history&branch_group_limit=',
        'total' => 2,
        'query_desc' => 'kw,wrdl: history, '
    }
];

# Create new session and put its id into CGISESSID cookie
my $session = get_session("");
$session->flush;
my $input = new CookieSimulator({CGISESSID => $session->id});

my @recent_searches = ParseSearchHistorySession($input);
is_deeply(\@recent_searches, [], 'at start, there is no recent searches');

SetSearchHistorySession($input, $expected_recent_searches);
@recent_searches = ParseSearchHistorySession($input);
is_deeply(\@recent_searches, $expected_recent_searches, 'recent searches set and retrieved successfully');

SetSearchHistorySession($input, []);
@recent_searches = ParseSearchHistorySession($input);
is_deeply(\@recent_searches, [], 'recent searches emptied successfully');

# Delete session
$session->delete;
$session->flush;

package CookieSimulator;

sub new {
    my ($class, $hashref) = @_;
    my $val = $hashref;
    return bless $val, $class;
}

sub cookie {
    my ($self, $name) = @_;
    return $self->{$name};
}

1;
