#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 25;
use Test::Warn;
use URI::Escape;
use List::Util qw( shuffle );

use C4::Context;
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

use_ok('Koha::DateUtils');
use_ok('C4::Search::History');

my $userid = 123;
my $previous_sessionid = "PREVIOUS_SESSIONID";
my $current_sessionid = "CURRENT_SESSIONID";
my $total = 42;
my $query_cgi_b = q{idx=kw&idx=ti&idx=au%2Cwrdl&q=word1é&q=word2è&q=word3à&do=Search&sort_by=author_az};
my $query_cgi_a = q{op=do_search&type=opac&authtypecode=NP&operator=start&value=Harry&marclist=match&and_or=and&orderby=HeadingAsc};

# add
my $added = add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
is ( $added, 9, '9 searches are added' );

# get
my $searches_for_userid = C4::Search::History::get({
    userid => $userid,
});
is( scalar(@$searches_for_userid), 9, 'There are 9 searches in all' );

my $searches_for_current_session = C4::Search::History::get({
    userid => $userid,
    sessionid => $current_sessionid,
});
is( scalar(@$searches_for_current_session), 5, 'There are 5 searches for the current session' );

my $searches_for_previous_sessions = C4::Search::History::get({
    userid => $userid,
    sessionid => $current_sessionid,
    previous => 1,
});
is( scalar(@$searches_for_previous_sessions), 4, 'There are 4 searches for previous sessions' );

my $authority_searches_for_current_session = C4::Search::History::get({
    userid => $userid,
    sessionid => $current_sessionid,
    type => 'authority',
});
is( scalar(@$authority_searches_for_current_session), 3, 'There are 3 authority searches for the current session' );

my $authority_searches_for_previous_session = C4::Search::History::get({
    userid => $userid,
    sessionid => $current_sessionid,
    type => 'authority',
    previous => 1,
});
is( scalar(@$authority_searches_for_previous_session), 2, 'There are 2 authority searches for previous sessions' );

my $biblio_searches_for_userid = C4::Search::History::get({
    userid => $userid,
    type => 'biblio',
});
is( scalar(@$biblio_searches_for_userid), 4, 'There are 5 searches for the current session' );

my $authority_searches_for_userid = C4::Search::History::get({
    userid => $userid,
    type => 'authority',
});
is( scalar(@$authority_searches_for_userid), 5, 'There are 4 searches for previous sessions' );

delete_all( $userid );

# delete
add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    sessionid => $current_sessionid,
    type => 'authority',
});
my $all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 6, 'There are 6 searches in all after deleting current biblio searches' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    sessionid => $current_sessionid,
    type => 'biblio',
    previous => 1,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 7, 'There are 7 searches in all after deleting previous authority searches' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    sessionid => $current_sessionid,
    previous => 1,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 5, 'There are 5 searches in all after deleting all previous searches' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    sessionid => $current_sessionid,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 4, 'There are 5 searches in all after deleting all searches for a sessionid' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 0, 'There are 0 search after deleting all searches for a userid' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
warning_like { C4::Search::History::delete({}) }
          qr/^ERROR: userid, id or interval is required for history deletion/,
          'Calling delete without userid raises warning';
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 9, 'There are still 9 searches after calling delete without userid' );
delete_all( $userid );

# Delete (with a given id)
add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
$all = C4::Search::History::get({ userid => $userid });
# Delete 5 searches
my $ids = [ shuffle map { $_->{id} } @$all ];
for my $id ( @$ids[ 0 .. 4 ] ) {
    C4::Search::History::delete({ id => $id });
}
$all = C4::Search::History::get({ userid => $userid });
is( scalar(@$all), 4, 'There are 4 searches after calling 5 times delete with id' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
$all = C4::Search::History::get({ userid => $userid });
# Delete 5 searches
$ids = [ shuffle map { $_->{id} } @$all ];
C4::Search::History::delete({ id => [ @$ids[0..4] ] });
$all = C4::Search::History::get({ userid => $userid });
is( scalar(@$all), 4, 'There are 4 searches after calling delete with 5 ids' );

delete_all( $userid );

# Test delete with interval
add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    interval => 10,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 9, 'There are still 9 searches after calling delete with an interval = 10 days' );
C4::Search::History::delete({
    userid => $userid,
    interval => 6,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 8, 'There are still 8 searches after calling delete with an interval = 6 days' );
C4::Search::History::delete({
    userid => $userid,
    interval => 2,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 2, 'There are still 2 searches after calling delete with an interval = 2 days' );
delete_all( $userid );

add( $userid, $current_sessionid, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a );
C4::Search::History::delete({
    userid => $userid,
    interval => 5,
    type => 'biblio',
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 8, 'There are still 9 searches after calling delete with an interval = 5 days for biblio' );
C4::Search::History::delete({
    userid => $userid,
    interval => 5,
    type => 'authority',
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 6, 'There are still 6 searches after calling delete with an interval = 5 days for authority' );
C4::Search::History::delete({
    userid => $userid,
    interval => -1,
});
$all = C4::Search::History::get({userid => $userid});
is( scalar(@$all), 0, 'There is no search after calling delete with an interval = -1 days' );

delete_all( $userid );

sub add {
    my ( $userid, $current_session_id, $previous_sessionid, $total, $query_cgi_b, $query_cgi_a ) = @_;

    my $days_ago_2 = dt_from_string()->add_duration( DateTime::Duration->new( days => -2 ) );
    my $days_ago_4 = dt_from_string()->add_duration( DateTime::Duration->new( days => -4 ) );
    my $days_ago_6 = dt_from_string()->add_duration( DateTime::Duration->new( days => -6 ) );
    my $days_ago_8 = dt_from_string()->add_duration( DateTime::Duration->new( days => -8 ) );

    my $query_desc_b1_p = q{first previous biblio search};
    my $first_previous_biblio_search = {
        userid => $userid,
        sessionid => $previous_sessionid,
        query_desc => $query_desc_b1_p,
        query_cgi => $query_cgi_b,
        total => $total,
        type => 'biblio',
        time => $days_ago_2,
    };

    my $query_desc_a1_p = q{first previous authority search};
    my $first_previous_authority_search = {
        userid => $userid,
        sessionid => $previous_sessionid,
        query_desc => $query_desc_a1_p,
        query_cgi => $query_cgi_a,
        total => $total,
        type => 'authority',
        time => $days_ago_2,
    };

    my $query_desc_b2_p = q{second previous biblio search};
    my $second_previous_biblio_search = {
        userid => $userid,
        sessionid => $previous_sessionid,
        query_desc => $query_desc_b2_p,
        query_cgi => $query_cgi_b,
        total => $total,
        type => 'biblio',
        time => $days_ago_4,
    };

    my $query_desc_a2_p = q{second previous authority search};
    my $second_previous_authority_search = {
        userid => $userid,
        sessionid => $previous_sessionid,
        query_desc => $query_desc_a2_p,
        query_cgi => $query_cgi_a,
        total => $total,
        type => 'authority',
        time => $days_ago_4,
    };


    my $query_desc_b1_c = q{first current biblio search};

    my $first_current_biblio_search = {
        userid => $userid,
        sessionid => $current_sessionid,
        query_desc => $query_desc_b1_c,
        query_cgi => $query_cgi_b,
        total => $total,
        type => 'biblio',
        time => $days_ago_4,
    };

    my $query_desc_a1_c = q{first current authority search};
    my $first_current_authority_search = {
        userid => $userid,
        sessionid => $current_sessionid,
        query_desc => $query_desc_a1_c,
        query_cgi => $query_cgi_a,
        total => $total,
        type => 'authority',
        time => $days_ago_4,
    };

    my $query_desc_b2_c = q{second current biblio search};
    my $second_current_biblio_search = {
        userid => $userid,
        sessionid => $current_sessionid,
        query_desc => $query_desc_b2_c,
        query_cgi => $query_cgi_b,
        total => $total,
        type => 'biblio',
        time => $days_ago_6,
    };

    my $query_desc_a2_c = q{second current authority search};
    my $second_current_authority_search = {
        userid => $userid,
        sessionid => $current_sessionid,
        query_desc => $query_desc_a2_c,
        query_cgi => $query_cgi_a,
        total => $total,
        type => 'authority',
        time => $days_ago_6,
    };

    my $query_desc_a3_c = q{third current authority search};
    my $third_current_authority_search = {
        userid => $userid,
        sessionid => $current_sessionid,
        query_desc => $query_desc_a3_c,
        query_cgi => $query_cgi_a,
        total => $total,
        type => 'authority',
        time => $days_ago_8,
    };


    my $r = 0;
    $r += C4::Search::History::add( $first_current_biblio_search );
    $r += C4::Search::History::add( $first_current_authority_search );
    $r += C4::Search::History::add( $second_current_biblio_search );
    $r += C4::Search::History::add( $second_current_authority_search );
    $r += C4::Search::History::add( $first_previous_biblio_search );
    $r += C4::Search::History::add( $first_previous_authority_search );
    $r += C4::Search::History::add( $second_previous_biblio_search );
    $r += C4::Search::History::add( $second_previous_authority_search );
    $r += C4::Search::History::add( $third_current_authority_search );
    return $r;
}

sub delete_all {
    my $userid = shift;
    C4::Search::History::delete({
        userid => $userid,
    });
}

$dbh->rollback;

done_testing;
