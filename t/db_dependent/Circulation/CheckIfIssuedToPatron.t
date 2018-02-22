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

use Test::More tests => 22;
use Test::MockModule;
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Items;
use Koha::Library;
use Koha::Patrons;
use MARC::Record;

BEGIN {
    use_ok('C4::Circulation');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM categories|);


## Create sample data
# Add a branch
my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};

# Add a category
my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};

# Add an itemtype
my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

my %item_info = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
    itype         => $itemtype
);

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
my $barcode1 = '0101';
AddItem({ barcode => $barcode1, %item_info }, $biblionumber1);
my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
my $barcode2 = '0202';
AddItem({ barcode => $barcode2, %item_info }, $biblionumber2);

my $borrowernumber1 = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode})->store->borrowernumber;
my $borrowernumber2 = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode})->store->borrowernumber;
# FIXME following code must be simplified to use the Koha::Patron objects
my $borrower1 = Koha::Patrons->find( $borrowernumber1 )->unblessed;
my $borrower2 = Koha::Patrons->find( $borrowernumber2 )->unblessed;

my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });


my $check_if_issued = C4::Circulation::CheckIfIssuedToPatron();
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without argument returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron(undef, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the borrower number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, undef);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the biblio number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns unef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber2);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber2);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );

AddIssue($borrower1, '0101');
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron();
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without argument returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron(undef, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the borrower number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, undef);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the biblio number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber1);
is( $check_if_issued, 1, 'CheckIfIssuedToPatron returns true' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber2);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber2);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );

AddIssue($borrower2, '0202');
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron();
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without argument returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron(undef, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the borrower number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, undef);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron without the biblio number returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber1);
is( $check_if_issued, 1, 'CheckIfIssuedToPatron returns true' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber1, $biblionumber2);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber1);
is( $check_if_issued, undef, 'CheckIfIssuedToPatron returns undef' );
$check_if_issued = C4::Circulation::CheckIfIssuedToPatron($borrowernumber2, $biblionumber2);
is( $check_if_issued, 1, 'CheckIfIssuedToPatron returns true' );

$dbh->rollback();

