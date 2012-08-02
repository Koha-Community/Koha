#!/usr/bin/perl
#
#testing C4 matcher

use strict;
use warnings;
use Test::More tests => 10;
use Test::MockModule;

BEGIN {
    use_ok('C4::Matcher');
}

my $module = new Test::MockModule('C4::Context');
$module->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);
my $matcher = [
    [ 'matcher_id', 'code', 'description', 'record_type', 'threshold' ],
    [ 1,            'ISBN', 'ISBN',        'red',         1 ],
    [ 2,            'ISSN', 'ISSN',        'blue',        0 ]
];
my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $matcher;

my @matchers = C4::Matcher::GetMatcherList();

is( $matchers[0]->{'matcher_id'}, 1, 'First matcher_id value is 1' );

is( $matchers[1]->{'matcher_id'}, 2, 'Second matcher_id value is 2' );

$dbh->{mock_add_resultset} = $matcher;

my $matcher_id = C4::Matcher::GetMatcherId('ISBN');

is( $matcher_id, 1, 'testing getmatcherid' );

my $testmatcher;

ok( $testmatcher = C4::Matcher->new( 'red', 1 ), 'testing matcher new' );

ok( $testmatcher = C4::Matcher->new( 'blue', 0 ), 'testing matcher new' );

$testmatcher->threshold(1000);

is( $testmatcher->threshold(), 1000, 'testing threshhold accessor method' );

$testmatcher->_id(53);

is( $testmatcher->_id(), 53, 'testing _id accessor' );

$testmatcher->code('match on ISBN');

is( $testmatcher->code(), 'match on ISBN', 'testing code accessor' );

$testmatcher->description('match on ISSN');

is( $testmatcher->description(), 'match on ISSN', 'testing code accessor' );
