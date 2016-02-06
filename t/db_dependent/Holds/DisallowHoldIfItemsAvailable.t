#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Items;
use C4::Circulation;
use Koha::IssuingRule;

use Test::More tests => 4;

use t::lib::TestBuilder;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({
    source => 'Branch',
});

# Now, set a userenv
C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0,0,0,'firstname','surname', $library1->{branchcode}, 'Midway Public Library', '', '', '');

my $bib_title = "Test Title";

my $borrower1 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
        dateexpiry => '3000-01-01',
    }
});

my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
        dateexpiry => '3000-01-01',
    }
});

# Test hold_fulfillment_policy
my ( $itemtype ) = @{ $dbh->selectrow_arrayref("SELECT itemtype FROM itemtypes LIMIT 1") };
my $borrowernumber1 = $borrower1->{borrowernumber};
my $borrowernumber2 = $borrower2->{borrowernumber};
my $library_A = $library1->{branchcode};

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$bib_title', '2011-02-01')");

my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$bib_title'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype) VALUES ($biblionumber, '', '$itemtype')");

my $biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (barcode, biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ('AllowHoldIf1', $biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype')
");

my $itemnumber1 =
  $dbh->selectrow_array("SELECT itemnumber FROM items WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created item");

my $item1 = GetItem( $itemnumber1 );

$dbh->do("
    INSERT INTO items (barcode, biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ('AllowHoldIf2', $biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype')
");

my $itemnumber2 =
  $dbh->selectrow_array("SELECT itemnumber FROM items WHERE biblionumber = $biblionumber ORDER BY itemnumber DESC")
  or BAIL_OUT("Cannot find newly created item");

my $item2 = GetItem( $itemnumber2 );

$dbh->do("DELETE FROM issuingrules");
my $rule = Koha::IssuingRule->new(
    {
        categorycode => '*',
        itemtype     => '*',
        branchcode   => '*',
        maxissueqty  => 99,
        issuelength  => 7,
        lengthunit   => 8,
        reservesallowed => 99,
        onshelfholds => 2,
    }
);
$rule->store();

my $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
is( $is, 0, "Item cannot be held, 2 items available" );

AddIssue( $borrower2, $item1->{barcode} );

$is = IsAvailableForItemLevelRequest( $item1, $borrower1);
is( $is, 0, "Item cannot be held, 1 item available" );

AddIssue( $borrower2, $item2->{barcode} );

$is = IsAvailableForItemLevelRequest( $item1, $borrower1);
is( $is, 1, "Item can be held, no items available" );

# Cleanup
$schema->storage->txn_rollback;
