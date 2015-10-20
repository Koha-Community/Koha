#!/usr/bin/perl
#
#Testing C4 Images

use Modern::Perl;
use Test::More tests => 8;
use Test::MockModule;

use_ok('C4::Images');

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Biblioimage' ;

# Make the code in the module use our mocked Koha::Schema/Koha::Database
my $db = Test::MockModule->new('Koha::Database');
$db->mock(
    # Schema() gives us the DB connection set up by Test::DBIx::Class
    _new_schema => sub { return Schema(); }
);

my $biblionumber = 2;
my $images = [
    [ 1, $biblionumber, 'gif',  'imagefile1', 'thumbnail1' ],
    [ 3, $biblionumber, 'jpeg', 'imagefile3', 'thumbnail3' ],
];
fixtures_ok [
    Biblioimage => [
        [ 'imagenumber', 'biblionumber', 'mimetype', 'imagefile', 'thumbnail' ],
        @$images,
    ],
], 'add fixtures';

my $image = C4::Images::RetrieveImage(1);

is( $image->{'imagenumber'}, 1, 'First imagenumber is 1' );

is( $image->{'mimetype'}, 'gif', 'First mimetype is gif' );

is( $image->{'thumbnail'}, 'thumbnail1', 'First thumbnail is correct' );

my @imagenumbers = C4::Images::ListImagesForBiblio($biblionumber);

is( $imagenumbers[0], 1, 'imagenumber is 1' );

is( $imagenumbers[1], 3, 'imagenumber is 3' );

is( $imagenumbers[4], undef, 'imagenumber undef' );
