#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 20;
use Test::MockModule;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Category;
use C4::Circulation;
use Koha::Library;
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

my $issues =
  C4::Members::GetPendingIssues( $borrowernumber1, $borrowernumber2 );
is( @$issues, 0, 'GetPendingIssues returns the correct number of elements' );

AddIssue( $borrower1, '0101' );
$issues = C4::Members::GetPendingIssues($borrowernumber1);
is( @$issues, 1, 'GetPendingIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber},
    $itemnumber1, 'GetPendingIssues returns the itemnumber correctly' );
my $issues_bis =
  C4::Members::GetPendingIssues( $borrowernumber1, $borrowernumber2 );
is_deeply( $issues, $issues_bis, 'GetPendingIssues functions correctly' );
$issues = C4::Members::GetPendingIssues($borrowernumber2);
is( @$issues, 0, 'GetPendingIssues returns the correct number of elements' );

AddIssue( $borrower1, '0102' );
$issues = C4::Members::GetPendingIssues($borrowernumber1);
is( @$issues, 2, 'GetPendingIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber},
    $itemnumber1, 'GetPendingIssues returns the itemnumber correctly' );
is( $issues->[1]->{itemnumber},
    $itemnumber2, 'GetPendingIssues returns the itemnumber correctly' );
$issues_bis =
  C4::Members::GetPendingIssues( $borrowernumber1, $borrowernumber2 );
is_deeply( $issues, $issues_bis, 'GetPendingIssues functions correctly' );
$issues = C4::Members::GetPendingIssues($borrowernumber2);
is( @$issues, 0, 'GetPendingIssues returns the correct number of elements' );

AddIssue( $borrower2, '0203' );
$issues = C4::Members::GetPendingIssues($borrowernumber2);
is( @$issues, 1, 'GetAllIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber},
    $itemnumber3, 'GetPendingIssues returns the itemnumber correctly' );
$issues = C4::Members::GetPendingIssues($borrowernumber1);
is( @$issues, 2, 'GetPendingIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber},
    $itemnumber1, 'GetPendingIssues returns the itemnumber correctly' );
is( $issues->[1]->{itemnumber},
    $itemnumber2, 'GetPendingIssues returns the itemnumber correctly' );
$issues = C4::Members::GetPendingIssues( $borrowernumber1, $borrowernumber2 );
is( @$issues, 3, 'GetPendingIssues returns the correct number of elements' );
is( $issues->[0]->{itemnumber},
    $itemnumber1, 'GetPendingIssues returns the itemnumber correctly' );
is( $issues->[1]->{itemnumber},
    $itemnumber2, 'GetPendingIssues returns the itemnumber correctly' );
is( $issues->[2]->{itemnumber},
    $itemnumber3, 'GetPendingIssues returns the itemnumber correctly' );

$issues = C4::Members::GetPendingIssues();
is( @$issues, 0,
    'GetPendingIssues without borrower numbers returns an empty array' );

$dbh->rollback();
