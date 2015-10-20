#!/usr/bin/perl
#
#testing C4 matcher

use strict;
use warnings;
use Test::More tests => 11;
use Test::MockModule;

BEGIN {
    use_ok('C4::Matcher');
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'MarcMatcher' ;

fixtures_ok [
    MarcMatcher => [
        [ 'matcher_id', 'code', 'description', 'record_type', 'threshold' ],
        [ 1,            'ISBN', 'ISBN',        'red',         1 ],
        [ 2,            'ISSN', 'ISSN',        'blue',        0 ]
    ],
], 'add fixtures';

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

my @matchers = C4::Matcher::GetMatcherList();

is( $matchers[0]->{'matcher_id'}, 1, 'First matcher_id value is 1' );

is( $matchers[1]->{'matcher_id'}, 2, 'Second matcher_id value is 2' );

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
