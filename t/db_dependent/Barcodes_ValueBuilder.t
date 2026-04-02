#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 14;
use Test::Warn;
use Test::MockModule;
use t::lib::TestBuilder;

use Koha::Database;
use C4::Barcodes::ValueBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
my $item_1 = $builder->build_sample_item( { barcode => '33333074344563' } );
my $item_2 = $builder->build_sample_item( { barcode => 'hb12070890' } );
my $item_3 = $builder->build_sample_item( { barcode => '201200345' } );
my $item_4 = $builder->build_sample_item( { barcode => '2012-0034' } );

my %args = (
    year     => '2012',
    mon      => '07',
    day      => '30',
    tag      => '952',
    subfield => 'p',
);

my ( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::incremental::get_barcode( \%args );
is( $nextnum, 33333074344564, 'incremental barcode' );
is( $scr,     undef,          'incremental javascript' );

( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode( \%args );
is( $nextnum, '12070891', 'hbyymmincr barcode' );
ok( length($scr) > 0, 'hbyymmincr javascript' );

( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::annual::get_barcode( \%args );
is( $nextnum, '2012-0035', 'annual barcode' );
is( $scr,     undef,       'annual javascript' );

$dbh->do(q|DELETE FROM items|);
my $item_5 = $builder->build_sample_item( { barcode => '978e0143019375' } );
( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::incremental::get_barcode( \%args );
is( $nextnum, '979', 'incremental barcode' );
is( $scr,     undef, 'incremental javascript' );

# EAN-13 tests
$dbh->do(q|DELETE FROM items|);
$builder->build_sample_item( { barcode => '3999900001927' } );    # valid 13-digit EAN-13
( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::EAN13::get_barcode( \%args );
is( $nextnum, '3999900001934', 'EAN-13 increments correctly from valid EAN-13' );
is( $scr,     undef,           'EAN-13 javascript' );

$dbh->do(q|DELETE FROM items|);
$builder->build_sample_item( { barcode => '39999000019193' } );    # 14-digit, should be ignored
warning_like(
    sub { ( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::EAN13::get_barcode( \%args ) },
    qr/ERROR: invalid EAN-13/,
    'EAN-13 warns when no valid 13-digit barcode found'
);
is( $nextnum, 1, 'EAN-13 not confused by 14-digit barcode (falls back to increment)' );

$dbh->do(q|DELETE FROM items|);
$builder->build_sample_item( { barcode => '39999000019193' } );    # 14-digit
$builder->build_sample_item( { barcode => '3999900001927' } );     # 13-digit EAN-13
( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::EAN13::get_barcode( \%args );
is( $nextnum, '3999900001934', 'EAN-13 picks max among 13-digit barcodes, ignores 14-digit' );

$schema->storage->txn_rollback;
