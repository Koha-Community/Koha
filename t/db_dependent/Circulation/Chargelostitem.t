#!/usr/bin/perl

use Modern::Perl;

use Test::MockModule;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Branch;
use C4::Category;
use C4::Circulation;
use MARC::Record;
use Test::More tests => 7;

BEGIN {
    use_ok('C4::Accounts');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;
$dbh->do(q|DELETE FROM accountlines|);

my $branchcode;
my $branch_created;
my @branches = keys %{ GetBranches() };
if (@branches) {
    $branchcode = $branches[0];
} else {
    $branchcode = 'B';
    ModBranch({ add => 1, branchcode => $branchcode, branchname => 'Branch' });
    $branch_created = 1;
}

my %item_branch_infos = (
    homebranch => $branchcode,
    holdingbranch => $branchcode,
);

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
my $itemnumber1 = AddItem({ barcode => '0101', %item_branch_infos }, $biblionumber1);
my $itemnumber2 = AddItem({ barcode => '0102', %item_branch_infos }, $biblionumber1);

my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
my $itemnumber3 = AddItem({ barcode => '0203', %item_branch_infos }, $biblionumber2);

my $categorycode;
my $category_created;
my @categories = C4::Category->all;
if (@categories) {
    $categorycode = $categories[0]->{categorycode}
} else {
    $categorycode = 'C';
    $dbh->do(
        "INSERT INTO categories(categorycode) VALUES(?)", undef, $categorycode);
    $category_created = 1;
}

my $borrowernumber = AddMember(categorycode => $categorycode, branchcode => $branchcode);
my $borrower = GetMember(borrowernumber => $borrowernumber);

# Need to mock userenv for AddIssue
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });
AddIssue($borrower, '0101');
AddIssue($borrower, '0203');

# Begin tests...
my $processfee = 10;
my $issues;
$issues = C4::Circulation::GetIssues({biblionumber => $biblionumber1});
my $issue=$issues->[0];
$issue->{'processfee'} = $processfee;
C4::Accounts::chargelostitem($issue, 'test');

my @accountline = C4::Accounts::getcharges($borrowernumber);

is( scalar(@accountline), 1, 'accountline should have 1 row' );
is( int($accountline[0]->{amount}), $processfee, "The accountline amount should be precessfee value " );
is( $accountline[0]->{accounttype}, 'PF', "The accountline accounttype should be PF " );
is( $accountline[0]->{borrowernumber}, $borrowernumber, "The accountline borrowernumber should be the example borrowernumber" );
my $itemnumber = C4::Items::GetItemnumberFromBarcode('0101');
is( $accountline[0]->{itemnumber}, $itemnumber, "The accountline itemnumber should the linked with barcode '0101'" );
is( $accountline[0]->{description}, 'test ' . $issue->{itemnumber}, "The accountline description should be 'test'" );
