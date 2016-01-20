#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 10;

use C4::Circulation;
use C4::Biblio;
use C4::Items;
use Koha::Library;


BEGIN {
    use_ok('C4::Circulation');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM categories|);


my $branchcode = 'B';
Koha::Library->new({ branchcode => $branchcode, branchname => 'Branch' })->store;

my $categorycode = 'C';
$dbh->do("INSERT INTO categories(categorycode) VALUES(?)", undef, $categorycode);

my %item_branch_infos = (
    homebranch => $branchcode,
    holdingbranch => $branchcode,
);

my $barcode1 = '0101';
my $barcode2 = '0102';
my $barcode3 = '0203';

my $check_valid_barcode = C4::Circulation::CheckValidBarcode();
is( $check_valid_barcode, 0, 'CheckValidBarcode without barcode returns false' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode1);
is( $check_valid_barcode, 0, 'CheckValidBarcode with an invalid barcode returns true' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode2);
is( $check_valid_barcode, 0, 'CheckValidBarcode with an invalid barcode returns true' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode3);
is( $check_valid_barcode, 0, 'CheckValidBarcode with an invalid barcode returns true' );

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
AddItem({ barcode => $barcode1, %item_branch_infos }, $biblionumber1);
AddItem({ barcode => $barcode2, %item_branch_infos }, $biblionumber1);
my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
AddItem({ barcode => $barcode3, %item_branch_infos }, $biblionumber2);

$check_valid_barcode = C4::Circulation::CheckValidBarcode();
is( $check_valid_barcode, 0, 'CheckValidBarcode without barcode returns false' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode1);
is( $check_valid_barcode, 1, 'CheckValidBarcode returns true' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode2);
is( $check_valid_barcode, 1, 'CheckValidBarcode returns true' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode($barcode3);
is( $check_valid_barcode, 1, 'CheckValidBarcode returns true' );
$check_valid_barcode = C4::Circulation::CheckValidBarcode('wrong barcode');
is( $check_valid_barcode, 0, 'CheckValidBarcode with an invalid barcode returns false' );

$dbh->rollback();

1;
