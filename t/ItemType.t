#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Test::More tests => 27;
use Test::MockModule;

BEGIN {
    use_ok('C4::ItemType');
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

# Mock data
my $itemtypes = [
    [
        'itemtype', 'description', 'rentalcharge', 'notforloan',
        'imageurl', 'summary', 'checkinmsg'
    ],
    [ 'BK', 'Books', 0, 0, '', '', 'foo' ],
    [ 'CD', 'CDRom', 0, 0, '', '', 'bar' ]
];

my $itemtypes_empty = [
    [
        'itemtype', 'description', 'rentalcharge', 'notforloan',
        'imageurl', 'summary', 'checkinmsg'
    ],
];

my $dbh = C4::Context->dbh();
$dbh->{mock_add_resultset} = $itemtypes_empty;

my @itemtypes = C4::ItemType->all();
is( @itemtypes, 0, 'Testing all itemtypes is empty' );

# This should run exactly one query so we can test
my $history = $dbh->{mock_all_history};
is( scalar( @{$history} ), 1, 'Correct number of statements executed' );

# Now lets mock some data
$dbh->{mock_add_resultset} = $itemtypes;

@itemtypes = C4::ItemType->all();

$history = $dbh->{mock_all_history};
is( scalar( @{$history} ), 2, 'Correct number of statements executed' );

is( @itemtypes, 2, 'ItemType->all should return an array with 2 elements' );

is( $itemtypes[0]->fish, undef, 'Calling a bad descriptor gives undef' );

is( $itemtypes[0]->itemtype, 'BK', 'First itemtype is bk' );

is( $itemtypes[1]->itemtype, 'CD', 'second itemtype is cd' );

is( $itemtypes[0]->description, 'Books', 'First description is books' );

is( $itemtypes[1]->description, 'CDRom', 'second description is CDRom' );

is( $itemtypes[0]->rentalcharge, '0', 'first rental charge is 0' );

is( $itemtypes[1]->rentalcharge, '0', 'second rental charge is 0' );

is( $itemtypes[0]->notforloan, '0', 'first not for loan is 0' );

is( $itemtypes[1]->notforloan, '0', 'second not for loan is 0' );

is( $itemtypes[0]->imageurl, '', 'first imageurl is undef' );

is( $itemtypes[1]->imageurl, '', 'second imageurl is undef' );

is( $itemtypes[0]->checkinmsg, 'foo', 'first checkinmsg is foo' );

is( $itemtypes[1]->checkinmsg, 'bar', 'second checkinmsg is bar' );

# Mock the data again
$dbh->{mock_add_resultset} = $itemtypes;

# Test get(), which should return one itemtype
my $itemtype = C4::ItemType->get( 'BK' );

$history = $dbh->{mock_all_history};
is( scalar( @{$history} ), 3, 'Correct number of statements executed' );

is( $itemtype->fish, undef, 'Calling a bad descriptor gives undef' );

is( $itemtype->itemtype, 'BK', 'itemtype is bk' );

is( $itemtype->description, 'Books', 'description is books' );

is( $itemtype->rentalcharge, '0', 'rental charge is 0' );

is( $itemtype->notforloan, '0', 'not for loan is 0' );

is( $itemtype->imageurl, '', ' not for loan is undef' );

is( $itemtype->checkinmsg, 'foo', 'checkinmsg is foo' );

$itemtype = C4::ItemType->get;
is( $itemtype, undef, 'C4::ItemType->get should return unless if no parameter is given' );
