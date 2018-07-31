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

use Test::More tests => 16;
use Test::MockModule;

use t::lib::TestBuilder;

use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Members;
use Koha::Libraries;
use Koha::Patrons;
use MARC::Record;

my $schema = Koha::Database->schema;
my $dbh = C4::Context->dbh;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM categories|);

my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};
my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $itemtype     = $builder->build( { source => 'Itemtype' } )->{itemtype};

my %item_infos = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
    itype         => $itemtype
);

my ($biblionumber1) = AddBiblio( MARC::Record->new, '' );
my $itemnumber1 =
  AddItem( { barcode => '0101', %item_infos }, $biblionumber1 );
my $itemnumber2 =
  AddItem( { barcode => '0102', %item_infos }, $biblionumber1 );

my ($biblionumber2) = AddBiblio( MARC::Record->new, '' );
my $itemnumber3 =
  AddItem( { barcode => '0203', %item_infos }, $biblionumber2 );

my $borrowernumber1 =
  Koha::Patron->new({ categorycode => $categorycode, branchcode => $branchcode })->store->borrowernumber;
my $borrowernumber2 =
  Koha::Patron->new({ categorycode => $categorycode, branchcode => $branchcode })->store->borrowernumber;
my $borrower1 = Koha::Patrons->find( $borrowernumber1 )->unblessed;
my $borrower2 = Koha::Patrons->find( $borrowernumber2 )->unblessed;

my $module = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

my $issues = C4::Members::GetAllIssues();
is( $issues, undef, 'GetAllIssues without borrower number returns undef' );

$issues = C4::Members::GetAllIssues($borrowernumber1);
is( @$issues, 0, 'GetAllIssues returns the correct number of elements' );
$issues = C4::Members::GetAllIssues($borrowernumber2);
is( @$issues, 0, 'GetAllIssues returns the correct number of elements' );

AddIssue( $borrower1, '0101' );
$issues = C4::Members::GetAllIssues($borrowernumber1);
my $issues_with_order =
  C4::Members::GetAllIssues( $borrowernumber1, 'date_due desc' );
is_deeply( $issues, $issues_with_order,
'The value by default for the argument order in GellAllIssues is date_due_desc'
);
is( @$issues, 1, 'GetAllIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber}, $itemnumber1, '' );
$issues = C4::Members::GetAllIssues($borrowernumber2);
is( @$issues, 0, 'GetAllIssues returns the correct number of elements' );

AddIssue( $borrower1, '0102' );
$issues = C4::Members::GetAllIssues($borrowernumber1);
is( @$issues, 2, 'GetAllIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber}, $itemnumber1, '' );
is( $issues->[1]->{itemnumber}, $itemnumber2, '' );
$issues = C4::Members::GetAllIssues($borrowernumber2);
is( @$issues, 0, 'GetAllIssues returns the correct number of elements' );

AddIssue( $borrower2, '0203' );
$issues = C4::Members::GetAllIssues($borrowernumber1);
is( @$issues, 2, 'GetAllIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber}, $itemnumber1, '' );
is( $issues->[1]->{itemnumber}, $itemnumber2, '' );
$issues = C4::Members::GetAllIssues($borrowernumber2);
is( @$issues, 1, 'GetAllIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber}, $itemnumber3, '' );

$schema->storage->txn_begin;

