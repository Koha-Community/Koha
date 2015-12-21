#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 10;
use Test::MockModule;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use Koha::Library;
use Koha::Patron::Categories;
use MARC::Record;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);

my $branchcode;
my $branch_created;
my @branches = keys %{ GetBranches() };
if (@branches) {
    $branchcode = $branches[0];
} else {
    $branchcode = 'B';
    Koha::Library->new({ branchcode => $branchcode, branchname => 'Branch' })->store;
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
my @categories = Koha::Patron::Categories->search_limited;
if (@categories) {
    $categorycode = $categories[0]->categorycode
} else {
    $categorycode = 'C';
    C4::Context->dbh->do(
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
my $issues;
$issues = C4::Circulation::GetIssues({biblionumber => $biblionumber1});
is(scalar @$issues, 1, "Biblio $biblionumber1 has 1 item issued");
is($issues->[0]->{itemnumber}, $itemnumber1, "First item of biblio $biblionumber1 is issued");

$issues = C4::Circulation::GetIssues({biblionumber => $biblionumber2});
is(scalar @$issues, 1, "Biblio $biblionumber2 has 1 item issued");
is($issues->[0]->{itemnumber}, $itemnumber3, "First item of biblio $biblionumber2 is issued");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber});
is(scalar @$issues, 2, "Borrower $borrowernumber checked out 2 items");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber, biblionumber => $biblionumber1});
is(scalar @$issues, 1, "One of those is an item from biblio $biblionumber1");

$issues = C4::Circulation::GetIssues({borrowernumber => $borrowernumber, biblionumber => $biblionumber2});
is(scalar @$issues, 1, "The other is an item from biblio $biblionumber2");

$issues = C4::Circulation::GetIssues({itemnumber => $itemnumber2});
is(scalar @$issues, 0, "No one has issued the second item of biblio $biblionumber2");

my $onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 0, "No pending on-site checkouts" );

my $itemnumber4 = AddItem({ barcode => '0104', %item_branch_infos }, $biblionumber1);
AddIssue( $borrower, '0104', undef, undef, undef, undef, { onsite_checkout => 1 } );
$onsite_checkouts = GetPendingOnSiteCheckouts;
is( scalar @$onsite_checkouts, 1, "There is 1 pending on-site checkout" );
