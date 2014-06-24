#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 22;
use Test::MockModule;

use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Branch;
use C4::Category;
use MARC::Record;

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
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM categories|);


my $branchcode = 'B';
ModBranch({ add => 1, branchcode => $branchcode, branchname => 'Branch' });

my $categorycode = 'C';
$dbh->do("INSERT INTO categories(categorycode) VALUES(?)", undef, $categorycode);

my %item_branch_infos = (
    homebranch => $branchcode,
    holdingbranch => $branchcode,
);

my ($biblionumber1) = AddBiblio(MARC::Record->new, '');
my $barcode1 = '0101';
AddItem({ barcode => $barcode1, %item_branch_infos }, $biblionumber1);
my ($biblionumber2) = AddBiblio(MARC::Record->new, '');
my $barcode2 = '0202';
AddItem({ barcode => $barcode2, %item_branch_infos }, $biblionumber2);

my $borrowernumber1 = AddMember(categorycode => $categorycode, branchcode => $branchcode);
my $borrowernumber2 = AddMember(categorycode => $categorycode, branchcode => $branchcode);
my $borrower1 = GetMember(borrowernumber => $borrowernumber1);
my $borrower2 = GetMember(borrowernumber => $borrowernumber2);

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
