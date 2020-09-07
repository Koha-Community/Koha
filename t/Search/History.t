#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 6;
use URI::Escape;
use JSON qw( decode_json );

use_ok('Koha::DateUtils');
use_ok('C4::Search::History');
use_ok('C4::Auth', qw/get_session/ );

# Test session
my $expected_recent_searches = [
    {
        'time' => 1374978877,
        'query_cgi' => 'idx=&q=history&branch_group_limit=',
        'total' => 2,
        'query_desc' => 'kw,wrdl: history, '
    }
];

# Create new session and put its id into CGISESSID cookie
my $session = C4::Auth::get_session("");
$session->flush;
my $input = new CookieSimulator({CGISESSID => $session->id});

my @recent_searches = C4::Search::History::get_from_session({ cgi => $input });
is_deeply(\@recent_searches, [], 'at start, there is no recent searches');

C4::Search::History::set_to_session({ cgi => $input, search_history => $expected_recent_searches });
@recent_searches = C4::Search::History::get_from_session({ cgi => $input });
is_deeply(\@recent_searches, $expected_recent_searches, 'recent searches set and retrieved successfully');

C4::Search::History::set_to_session({ cgi => $input, search_history => [] });
@recent_searches = C4::Search::History::get_from_session({ cgi => $input });
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

