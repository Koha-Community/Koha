#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::More tests => 10;

use t::lib::TestBuilder;

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
my $library3 = $builder->build({
    source => 'Branch',
});

my $bib_title = "Test Title";

my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        categorycode => 'S',
        branchcode => $library1->{branchcode},
    }
});

# Test hold_fulfillment_policy
my ( $itemtype ) = @{ $dbh->selectrow_arrayref("SELECT itemtype FROM itemtypes LIMIT 1") };
my $borrowernumber = $borrower->{borrowernumber};
my $library_A = $library1->{branchcode};
my $library_B = $library2->{branchcode};
my $library_C = $library3->{branchcode};
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM default_branch_circ_rules");
$dbh->do("DELETE FROM default_branch_item_rules");
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("DELETE FROM branch_item_rules");

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$bib_title', '2011-02-01')");

my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$bib_title'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype) VALUES ($biblionumber, '', '$itemtype')");

my $biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_B', 0, 0, 0, 0, NULL, '$itemtype')
");

my $itemnumber =
  $dbh->selectrow_array("SELECT itemnumber FROM items WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created item");

# With hold_fulfillment_policy = homebranch, hold should only be picked up if pickup branch = homebranch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'homebranch' )");

my $holds_queue;
# Home branch matches pickup branch
my $reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
my ( $status ) = CheckReserves($itemnumber);
is( $status, 'Reserved', "Hold where pickup branch matches home branch targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is($status, q{}, "Hold where pickup ne home, pickup eq home not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, q{}, "Hold where pickup ne home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# With hold_fulfillment_policy = holdingbranch, hold should only be picked up if pickup branch = holdingbranch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'holdingbranch' )");

# Home branch matches pickup branch
$reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, q{}, "Hold where pickup eq home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, 'Reserved', "Hold where pickup ne home, pickup eq holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, q{}, "Hold where pickup ne home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# With hold_fulfillment_policy = any, hold should be pikcup up reguardless of matching home or holding branch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'any' )");

# Home branch matches pickup branch
$reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, 'Reserved', "Hold where pickup eq home, pickup ne holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, 'Reserved', "Hold where pickup ne home, pickup eq holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
( $status ) = CheckReserves($itemnumber);
is( $status, 'Reserved', "Hold where pickup ne home, pickup ne holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );
