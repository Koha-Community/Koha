#!/usr/bin/perl
#
#Testing C4 Images

use strict;
use warnings;
use Test::More tests => 7;
use Test::MockModule;

BEGIN {
    use_ok('C4::Images');
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
my $images = [
    [ 'imagenumber', 'biblionumber', 'mimetype', 'imagefile', 'thumbnail' ],
    [ 1, 2, 'gif',  'red',  001, 000 ],
    [ 3, 2, 'jpeg', 'blue', 111, 110 ]
];
my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $images;

my $image = C4::Images::RetrieveImage();

is( $image->{'imagenumber'}, 1, 'First imagenumber is 1' );

is( $image->{'mimetype'}, 'gif', 'First mimetype is red' );

is( $image->{'thumbnail'}, 001, 'First thumbnail is 001' );

$image = C4::Images::RetrieveImage();

$image = C4::Images::RetrieveImage();

$dbh->{mock_add_resultset} = $images;

my @imagenumbers = C4::Images::ListImagesForBiblio();

is( $imagenumbers[0], 1, 'imagenumber is 1' );

is( $imagenumbers[1], 3, 'imagenumber is 3' );

$dbh->{mock_add_resultset} = $images;

is( $imagenumbers[4], undef, 'imagenumber undef' );
