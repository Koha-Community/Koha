#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use DBI;
use Test::More tests => 15;
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
        'imageurl', 'summary'
    ],
    [ 'BK', 'Books', 0, 0, '', '' ],
    [ 'CD', 'CDRom', 0, 0, '', '' ]
];

my $dbh = C4::Context->dbh();

my @itemtypes = C4::ItemType->all();
is( @itemtypes, 0, 'Testing all itemtypes is empty' );

# This should run exactly one query so we can test
my $history = $dbh->{mock_all_history};
is( scalar( @{$history} ), 1, 'Correct number of statements executed' );

# Now lets mock some data
$dbh->{mock_add_resultset} = $itemtypes;

@itemtypes = C4::ItemType->all();
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

is( $itemtypes[0]->imageurl, '', 'first not for loan is undef' );

is( $itemtypes[1]->imageurl, '', 'second not for loan is undef' );
