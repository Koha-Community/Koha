#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 3;
use Test::MockModule;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Category;
use C4::Circulation;
use Koha::Libraries;
use MARC::Record;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM categories|);

my $branchcode = 'B';
Koha::Library->new( { branchcode => $branchcode, branchname => 'Branch' } )->store;

my $categorycode = 'C';
$dbh->do( "INSERT INTO categories(categorycode) VALUES(?)",
    undef, $categorycode );

my %item_branch_infos = (
    homebranch    => $branchcode,
    holdingbranch => $branchcode,
);

my ($biblionumber1) = AddBiblio( MARC::Record->new, '' );
my $itemnumber1 =
  AddItem( { barcode => '0101', %item_branch_infos }, $biblionumber1 );
my $itemnumber2 =
  AddItem( { barcode => '0102', %item_branch_infos }, $biblionumber1 );

my ($biblionumber2) = AddBiblio( MARC::Record->new, '' );
my $itemnumber3 =
  AddItem( { barcode => '0103', %item_branch_infos }, $biblionumber2 );

my $borrowernumber =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrower = GetMember( borrowernumber => $borrowernumber );

my $module = new Test::MockModule('C4::Context');
$module->mock( 'userenv', sub { { branch => $branchcode } } );

AddIssue( $borrower, '0101', DateTime->now->subtract( days =>  1 ) );
AddIssue( $borrower, '0102', DateTime->now->subtract( days =>  5 ) );
AddIssue( $borrower, '0103' );

my $overdues = C4::Members::GetOverduesForPatron( $borrowernumber );
is( @$overdues, 2, 'GetOverduesForPatron returns the correct number of elements' );
is( $overdues->[0]->{itemnumber}, $itemnumber1, 'First overdue is correct' );
is( $overdues->[1]->{itemnumber}, $itemnumber2, 'Second overdue is correct' );
