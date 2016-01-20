#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 16;
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
  AddItem( { barcode => '0203', %item_branch_infos }, $biblionumber2 );

my $borrowernumber1 =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrowernumber2 =
  AddMember( categorycode => $categorycode, branchcode => $branchcode );
my $borrower1 = GetMember( borrowernumber => $borrowernumber1 );
my $borrower2 = GetMember( borrowernumber => $borrowernumber2 );

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

$dbh->rollback();
