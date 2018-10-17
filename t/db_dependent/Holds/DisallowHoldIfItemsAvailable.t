#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Circulation;
use C4::Items;
use Koha::IssuingRule;

use Test::More tests => 6;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
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
my $library_B = $library2->{branchcode};

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$bib_title', '2011-02-01')");

my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$bib_title'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

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

my $issue1 = AddIssue( $borrower2, $item1->{barcode} );

$is = IsAvailableForItemLevelRequest( $item1, $borrower1);
is( $is, 0, "Item cannot be held, 1 item available" );

AddIssue( $borrower2, $item2->{barcode} );

$is = IsAvailableForItemLevelRequest( $item1, $borrower1);
is( $is, 1, "Item can be held, no items available" );

AddReturn( $item1->{barcode} );

{ # Remove the issue for the first patron, and modify the branch for item1
    subtest 'IsAvailableForItemLevelRequest behaviours depending on ReservesControlBranch + holdallowed' => sub {
        plan tests => 2;

        my $hold_allowed_from_home_library = 1;
        my $hold_allowed_from_any_libraries = 2;
        my $sth_delete_rules = $dbh->prepare(q|DELETE FROM default_circ_rules|);
        my $sth_insert_rule = $dbh->prepare(q|INSERT INTO default_circ_rules(singleton, maxissueqty, maxonsiteissueqty, holdallowed, hold_fulfillment_policy, returnbranch) VALUES ('singleton', NULL, NULL, ?, 'any', 'homebranch');|);

        subtest 'Item is available at a different library' => sub {
            plan tests => 4;

            Koha::Items->find( $item1->{itemnumber} )->set({homebranch => $library_B, holdingbranch => $library_B })->store;
            $item1 = GetItem( $itemnumber1 );
            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library B is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A
            #CircControl has no effect - same rule for all branches as set at line 96
            #FIXME: ReservesControlBranch is not checked in these subs we are testing

            {
                $sth_delete_rules->execute;
                $sth_insert_rule->execute( $hold_allowed_from_home_library );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 1, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at different library, not holdable = none available => the hold is allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 1, "Hold allowed from home library + ReservesControlBranch=PatronLibrary, One item is available at different library, not holdable = none available => the hold is allowed at item level" );
            }

            {
                $sth_delete_rules->execute;
                $sth_insert_rule->execute( $hold_allowed_from_any_libraries );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=PatronLibrary, One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level" );
            }
        };

        subtest 'Item is available at the same library' => sub {
            plan tests => 4;

            Koha::Items->find( $item1->{itemnumber} )->set({homebranch => $library_A, holdingbranch => $library_A })->store;
            $item1 = GetItem( $itemnumber1 );
            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library A is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A
            #CircControl has no effect - same rule for all branches as set at line 96
            #ReservesControlBranch is not checked in these subs we are testing?

            {
                $sth_delete_rules->execute;
                $sth_insert_rule->execute( $hold_allowed_from_home_library );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=PatronLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );
            }

            {
                $sth_delete_rules->execute;
                $sth_insert_rule->execute( $hold_allowed_from_any_libraries );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, One item is available at the same library, holdable = 1 available => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $borrower1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=PatronLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );
            }
        };
    };
}

my $biblio = $builder->build({
    source => 'Biblio',
});

my $item3 = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblio->{biblionumber},
        itemlost     => 0,
        notforloan   => 0,
        withdrawn    => 0,
        damaged      => 0,
        onloan       => undef,
    }
});

my $hold = $builder->build({
    source => 'Reserve',
    value =>{
        itemnumber => $item3->{itemnumber},
        found => 'T'
    }
});

$dbh->do("DELETE FROM issuingrules");
$rule = Koha::IssuingRule->new(
    {
        categorycode => '*',
        itemtype     => '*',
        branchcode   => '*',
        maxissueqty  => 99,
        issuelength  => 7,
        lengthunit   => 8,
        reservesallowed => 99,
        onshelfholds => 0,
    }
);
$rule->store();

$is = IsAvailableForItemLevelRequest( $item3, $borrower1);
is( $is, 1, "Item can be held, items in transit are not available" );

# Cleanup
$schema->storage->txn_rollback;
