#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Test::MockModule;
use Test::More tests => 2;

BEGIN {
    use_ok('C4::Letters');
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
my $mock_letters = [
    [ 'module', 'code', 'branchcode', 'name', 'is_html', 'title', 'content' ],
    [ 'blah',   'ISBN', 'NBSI',       'book', 1,         'green', 'blahblah' ],
    [ 'bleh',   'ISSN', 'NSSI',       'page', 0,         'blue',  'blehbleh' ]
];

my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $mock_letters;

my $letters = C4::Letters::GetLetters();

is( $letters->{ISBN}, 'book', 'HASH ref of ISBN is book' );
