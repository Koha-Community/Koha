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

use Test::More tests => 3;
use Test::MockModule;

use t::lib::TestBuilder;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Circulation;
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
  AddItem( { barcode => '0103', %item_infos }, $biblionumber2 );

my $borrowernumber =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

my $module = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

AddIssue( $borrower, '0101', DateTime->now->subtract( days =>  1 ) );
AddIssue( $borrower, '0102', DateTime->now->subtract( days =>  5 ) );
AddIssue( $borrower, '0103' );

my $overdues = C4::Members::GetOverduesForPatron( $borrowernumber );
is( @$overdues, 2, 'GetOverduesForPatron returns the correct number of elements' );
is( $overdues->[0]->{itemnumber}, $itemnumber1, 'First overdue is correct' );
is( $overdues->[1]->{itemnumber}, $itemnumber2, 'Second overdue is correct' );
