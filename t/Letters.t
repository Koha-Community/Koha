#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use DBI;
use Test::MockModule;
use Test::More tests => 4;
use t::lib::Mocks;
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

use_ok('C4::Letters');

my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $mock_letters;

my $letters = C4::Letters::GetLetters();

my ( $ISBN_letter ) = grep {$_->{code} eq 'ISBN'} @$letters;
is( $ISBN_letter->{name}, 'book', 'letter name for "ISBN" letter is book' );
is( scalar( @$letters ), 2, 'GetLetters returns the 2 inserted letters' );

# Regression test for bug 10843
# $dt->add takes a scalar, not undef
my $letter;
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', undef);
$letter = C4::Letters::_parseletter( undef, 'reserves', {waitingdate => "2013-01-01"} );
is( ref($letter), 'HASH');
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', 1);
$letter = C4::Letters::_parseletter( undef, 'reserves', {waitingdate => "2013-01-01"} );
is( ref($letter), 'HASH');
