#!/usr/bin/perl

# Test C4::HoldsQueue::CreateQueue() for both transport cost matrix
# and StaticHoldsQueueWeight array (no RandomizeHoldsQueueWeight, no point)
# Wraps tests in transaction that's rolled back, so no data is destroyed
# MySQL WARNING: This makes sense only if your tables are InnoDB, otherwise
# transactions are not supported and mess is left behind

use Modern::Perl;

use Test::More tests => 35;
use Data::Dumper;


use C4::Branch;
use C4::Calendar;
use C4::Context;
use C4::Members;
use Koha::Database;
use Koha::DateUtils;
use Koha::ItemType;

use t::lib::TestBuilder;

use Koha::ItemTypes;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
    use_ok('C4::HoldsQueue');
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

my $TITLE = "Test Holds Queue XXX";

my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library1->{branchcode},
    }
});

my $borrowernumber = $borrower->{borrowernumber};
# Set special (for this test) branches
my $borrower_branchcode = $borrower->{branchcode};
my @branchcodes = ( $library1->{branchcode}, $library2->{branchcode}, $library3->{branchcode} );
my @other_branches = ( $library2->{branchcode}, $library3->{branchcode} );
my $least_cost_branch_code = pop @other_branches;
my $itemtype = Koha::ItemTypes->search({ notforloan => 1 })->next;
$itemtype or BAIL_OUT("No adequate itemtype"); #FIXME Should be $itemtype = $itemtype->itemtype

#Set up the stage
# Sysprefs and cost matrix
C4::Context->set_preference('HoldsQueueSkipClosed', 0);
$dbh->do("UPDATE systempreferences SET value = ? WHERE variable = 'StaticHoldsQueueWeight'", undef,
         join( ',', @other_branches, $borrower_branchcode, $least_cost_branch_code));
$dbh->do("UPDATE systempreferences SET value = '0' WHERE variable = 'RandomizeHoldsQueueWeight'");

$dbh->do("DELETE FROM transport_cost");
my $transport_cost_insert_sth = $dbh->prepare("insert into transport_cost (frombranch, tobranch, cost) values (?, ?, ?)");
# Favour $least_cost_branch_code
$transport_cost_insert_sth->execute($borrower_branchcode, $least_cost_branch_code, 0.2);
$transport_cost_insert_sth->execute($least_cost_branch_code, $borrower_branchcode, 0.2);
my @b = @other_branches;
while ( my $b1 = shift @b ) {
    foreach my $b2 ($borrower_branchcode, $least_cost_branch_code, @b) {
        $transport_cost_insert_sth->execute($b1, $b2, 0.5);
        $transport_cost_insert_sth->execute($b2, $b1, 0.5);
    }
}


# Loanable items - all possible combinations of homebranch and holdingbranch
$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated)
          VALUES             ('SER', 'Koha test', '$TITLE', '2011-02-01')");
my $biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");
$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype)
          VALUES                  ($biblionumber, '', '$itemtype')");
my $biblioitemnumber = $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

my $items_insert_sth = $dbh->prepare("INSERT INTO items (biblionumber, biblioitemnumber, barcode, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
                                      VALUES            ($biblionumber, $biblioitemnumber, ?, ?, ?, 0, 0, 0, 0, NULL, '$itemtype')"); # CURRENT_DATE - 3)");
my $first_barcode = int(rand(1000000000000)); # XXX
my $barcode = $first_barcode;
foreach ( $borrower_branchcode, $least_cost_branch_code, @other_branches ) {
    $items_insert_sth->execute($barcode++, $borrower_branchcode, $_);
    $items_insert_sth->execute($barcode++, $_, $_);
    $items_insert_sth->execute($barcode++, $_, $borrower_branchcode);
}

# Remove existing reserves, makes debugging easier
$dbh->do("DELETE FROM reserves");
my $bibitems = undef;
my $priority = 1;
# Make a reserve
AddReserve ( $borrower_branchcode, $borrowernumber, $biblionumber, $bibitems,  $priority );
#                           $resdate, $expdate, $notes, $title, $checkitem, $found
$dbh->do("UPDATE reserves SET reservedate = DATE_SUB( reservedate, INTERVAL 1 DAY )");

# Tests
my $use_cost_matrix_sth = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'UseTransportCostMatrix'");
my $test_sth = $dbh->prepare("SELECT * FROM hold_fill_targets
                              JOIN tmp_holdsqueue USING (borrowernumber, biblionumber, itemnumber)
                              JOIN items USING (itemnumber)
                              WHERE borrowernumber = $borrowernumber");

# We have a book available homed in borrower branch, no point fiddling with AutomaticItemReturn
C4::Context->set_preference('AutomaticItemReturn', 0);
test_queue ('take from homebranch',  0, $borrower_branchcode, $borrower_branchcode);
test_queue ('take from homebranch',  1, $borrower_branchcode, $borrower_branchcode);

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode'");
# test_queue will flush
C4::Context->set_preference('AutomaticItemReturn', 1);
# Not sure how to make this test more difficult - holding branch does not matter

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode'");
C4::Context->set_preference('AutomaticItemReturn', 0);
# We have a book available held in borrower branch
test_queue ('take from holdingbranch', 0, $borrower_branchcode, $borrower_branchcode);
test_queue ('take from holdingbranch', 1, $borrower_branchcode, $borrower_branchcode);

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE holdingbranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE holdingbranch = '$borrower_branchcode'");
# No book available in borrower branch, pick according to the rules
# Frst branch from StaticHoldsQueueWeight
test_queue ('take from lowest cost branch', 0, $borrower_branchcode, $other_branches[0]);
test_queue ('take from lowest cost branch', 1, $borrower_branchcode, $least_cost_branch_code);
my $queue = C4::HoldsQueue::GetHoldsQueueItems($least_cost_branch_code) || [];
my $queue_item = $queue->[0];
ok( $queue_item
 && $queue_item->{pickbranch} eq $borrower_branchcode
 && $queue_item->{holdingbranch} eq $least_cost_branch_code, "GetHoldsQueueItems" )
  or diag( "Expected item for pick $borrower_branchcode, hold $least_cost_branch_code, got ".Dumper($queue_item) );
ok( exists($queue_item->{itype}), 'item type included in queued items list (bug 5825)' );

ok(
    C4::HoldsQueue::least_cost_branch( 'B', [ 'A', 'B', 'C' ] ) eq 'B',
    'C4::HoldsQueue::least_cost_branch returns the local branch if it is in the list of branches to pull from'
);

# XXX All this tests are for borrower branch pick-up.
# Maybe needs expanding to homebranch or holdingbranch pick-up.

$schema->txn_rollback;
$schema->txn_begin;

### Test holds queue builder does not violate holds policy ###

# Clear out existing rules relating to holdallowed
$dbh->do("DELETE FROM default_branch_circ_rules");
$dbh->do("DELETE FROM default_branch_item_rules");
$dbh->do("DELETE FROM default_circ_rules");

C4::Context->set_preference('UseTransportCostMatrix', 0);

$itemtype = Koha::ItemTypes->search->next->itemtype;

$library1 = $builder->build({
    source => 'Branch',
});
$library2 = $builder->build({
    source => 'Branch',
});
$library3 = $builder->build({
    source => 'Branch',
});
@branchcodes = ( $library1->{branchcode}, $library2->{branchcode}, $library3->{branchcode} );

my $borrower1 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[0],
    },
});
my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[1],
    },
});
my $borrower3 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[2],
    },
});

$dbh->do(qq{
    INSERT INTO biblio (
        frameworkcode, 
        author, 
        title, 
        datecreated
    ) VALUES (
        'SER', 
        'Koha test', 
        '$TITLE', 
        '2011-02-01'
    )
});
$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do(qq{
    INSERT INTO biblioitems (
        biblionumber, 
        marcxml, 
        itemtype
    ) VALUES (
        $biblionumber, 
        '', 
        '$itemtype'
    )
});
$biblioitemnumber = $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$items_insert_sth = $dbh->prepare(qq{
    INSERT INTO items (
        biblionumber, 
        biblioitemnumber,
        barcode,
        homebranch,
        holdingbranch,
        notforloan,
        damaged,
        itemlost,
        withdrawn,
        onloan,
        itype
    ) VALUES (
        $biblionumber,
        $biblioitemnumber,
        ?,
        ?,
        ?,
        0,
        0,
        0,
        0,
        NULL,
        '$itemtype'
    )
});
# Create 3 items from 2 branches ( branches are for borrowers 1 and 2 respectively )
$barcode = int( rand(1000000000000) );
$items_insert_sth->execute( $barcode + 0, $branchcodes[0], $branchcodes[0] );
$items_insert_sth->execute( $barcode + 1, $branchcodes[1], $branchcodes[1] );
$items_insert_sth->execute( $barcode + 2, $branchcodes[1], $branchcodes[1] );

$dbh->do("DELETE FROM reserves");
my $sth = $dbh->prepare(q{
    INSERT INTO reserves ( 
        borrowernumber,
        biblionumber,
        branchcode,
        priority,
        reservedate
    ) VALUES ( ?,?,?,?, CURRENT_DATE() )
});
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[0], 2 );
$sth->execute( $borrower3->{borrowernumber}, $biblionumber, $branchcodes[0], 3 );

my $holds_queue;

$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed ) VALUES ( 1 )");
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 2, "Holds queue filling correct number for default holds policy 'from home library'" );
is( $holds_queue->[0]->{cardnumber}, $borrower1->{cardnumber}, "Holds queue filling 1st correct hold for default holds policy 'from home library'");
is( $holds_queue->[1]->{cardnumber}, $borrower2->{cardnumber}, "Holds queue filling 2nd correct hold for default holds policy 'from home library'");

# Test skipping hold picks for closed libraries.
# At this point in the test, we have 2 rows in the holds queue
# 1 of which is coming from MPL. Let's enable HoldsQueueSkipClosed
# and make today a holiday for MPL. When we run it again we should only
# have 1 row in the holds queue
C4::Context->set_preference('HoldsQueueSkipClosed', 1);
my $today = dt_from_string();
C4::Calendar->new( branchcode => $branchcodes[0] )->insert_single_holiday(
    day         => $today->day(),
    month       => $today->month(),
    year        => $today->year(),
    title       => "$today",
    description => "$today",
);
# If the test below is removed, aother tests using the holiday will fail. For some reason if we call is_holiday now
# the holiday will get set in cache correctly, but not if we let C4::HoldsQueue call is_holiday instead.
is( Koha::Calendar->new( branchcode => $branchcodes[0] )->is_holiday( $today ), 1, 'Is today a holiday for pickup branch' );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( scalar( @$holds_queue ), 1, "Holds not filled with items from closed libraries" );
C4::Context->set_preference('HoldsQueueSkipClosed', 0);

$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed ) VALUES ( 2 )");
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 3, "Holds queue filling correct number for holds for default holds policy 'from any library'" );

# Test skipping hold picks for closed libraries without transport cost matrix
# At this point in the test, we have 3 rows in the holds queue
# one of which is coming from MPL. Let's enable HoldsQueueSkipClosed
# and use our previously created holiday for MPL
# When we run it again we should only have 2 rows in the holds queue
C4::Context->set_preference( 'HoldsQueueSkipClosed', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( scalar( @$holds_queue ), 2, "Holds not filled with items from closed libraries" );
C4::Context->set_preference( 'HoldsQueueSkipClosed', 0 );

# Bug 14297
$itemtype = Koha::ItemTypes->search->next->itemtype;
$borrowernumber = $borrower3->{borrowernumber};
my $library_A = $library1->{branchcode};
my $library_B = $library2->{branchcode};
my $library_C = $borrower3->{branchcode};
$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM items");
$dbh->do("DELETE FROM biblio");
$dbh->do("DELETE FROM biblioitems");
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM default_branch_circ_rules");
$dbh->do("DELETE FROM default_branch_item_rules");
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("DELETE FROM branch_item_rules");

$dbh->do("
    INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')
");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype) VALUES ($biblionumber, '', '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype')
");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_B', '$library_B', 0, 0, 0, 0, NULL, '$itemtype')
");

$dbh->do("
    INSERT INTO branch_item_rules ( branchcode, itemtype, holdallowed, returnbranch ) VALUES
    ( '$library_A', '$itemtype', 2, 'homebranch' ), ( '$library_B', '$itemtype', 1, 'homebranch' );
");

$dbh->do( "UPDATE systempreferences SET value = ? WHERE variable = 'StaticHoldsQueueWeight'",
    undef, join( ',', $library_B, $library_A, $library_C ) );
$dbh->do( "UPDATE systempreferences SET value = 0 WHERE variable = 'RandomizeHoldsQueueWeight'" );

my $reserve_id = AddReserve ( $library_C, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 1, "Bug 14297 - Holds Queue building ignoring holds where pickup & home branch don't match and item is not from le");
# End Bug 14297

# Bug 15062
$itemtype = Koha::ItemTypes->search->next->itemtype;
$borrowernumber = $borrower2->{borrowernumber};
$library_A = $library1->{branchcode};
$library_B = $library2->{branchcode};
$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM items");
$dbh->do("DELETE FROM biblio");
$dbh->do("DELETE FROM biblioitems");
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM default_branch_circ_rules");
$dbh->do("DELETE FROM default_branch_item_rules");
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("DELETE FROM branch_item_rules");

C4::Context->set_preference("UseTransportCostMatrix",1);

my $tc_rs = $schema->resultset('TransportCost');
$tc_rs->create({ frombranch => $library_A, tobranch => $library_B, cost => 0, disable_transfer => 1 });
$tc_rs->create({ frombranch => $library_B, tobranch => $library_A, cost => 0, disable_transfer => 1 });

$dbh->do("
    INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')
");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype) VALUES ($biblionumber, '', '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype')
");

$reserve_id = AddReserve ( $library_B, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 0, "Bug 15062 - Holds queue with Transport Cost Matrix will transfer item even if transfers disabled");
# End Bug 15062

# Test hold_fulfillment_policy
C4::Context->set_preference( "UseTransportCostMatrix", 0 );
$borrowernumber = $borrower3->{borrowernumber};
$library_A = $library1->{branchcode};
$library_B = $library2->{branchcode};
$library_C = $library3->{branchcode};
$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM items");
$dbh->do("DELETE FROM biblio");
$dbh->do("DELETE FROM biblioitems");
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM default_branch_circ_rules");
$dbh->do("DELETE FROM default_branch_item_rules");
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("DELETE FROM branch_item_rules");

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, marcxml, itemtype) VALUES ($biblionumber, '', '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_B', 0, 0, 0, 0, NULL, '$itemtype')
");

# With hold_fulfillment_policy = homebranch, hold should only be picked up if pickup branch = homebranch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'homebranch' )");

# Home branch matches pickup branch
$reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup branch matches home branch targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup eq home not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# With hold_fulfillment_policy = holdingbranch, hold should only be picked up if pickup branch = holdingbranch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'holdingbranch' )");

# Home branch matches pickup branch
$reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup eq home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup eq holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup ne holding not targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# With hold_fulfillment_policy = any, hold should be pikcup up reguardless of matching home or holding branch
$dbh->do("DELETE FROM default_circ_rules");
$dbh->do("INSERT INTO default_circ_rules ( holdallowed, hold_fulfillment_policy ) VALUES ( 2, 'any' )");

# Home branch matches pickup branch
$reserve_id = AddReserve( $library_A, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup eq home, pickup ne holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Holding branch matches pickup branch
$reserve_id = AddReserve( $library_B, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup eq holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# Neither branch matches pickup branch
$reserve_id = AddReserve( $library_C, $borrowernumber, $biblionumber, '', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup ne holding targeted" );
CancelReserve( { reserve_id => $reserve_id } );

# End testing hold_fulfillment_policy

# Cleanup
$schema->storage->txn_rollback;

### END Test holds queue builder does not violate holds policy ###

sub test_queue {
    my ($test_name, $use_cost_matrix, $pick_branch, $hold_branch) = @_;

    $test_name = "$test_name (".($use_cost_matrix ? "" : "don't ")."use cost matrix)";

    $use_cost_matrix_sth->execute($use_cost_matrix);
    C4::Context->clear_syspref_cache();
    C4::HoldsQueue::CreateQueue();

    my $results = $dbh->selectall_arrayref($test_sth, { Slice => {} }); # should be only one
    my $r = $results->[0];

    my $ok = is( $r->{pickbranch}, $pick_branch, "$test_name pick up branch");
    $ok &&=  is( $r->{holdingbranch}, $hold_branch, "$test_name holding branch")
      if $hold_branch;

    diag( "Wrong pick-up/hold for first target (pick_branch, hold_branch, reserves, hold_fill_targets, tmp_holdsqueue): "
        . Dumper ($pick_branch, $hold_branch, map dump_records($_), qw(reserves hold_fill_targets tmp_holdsqueue)) )
      unless $ok;
}

sub dump_records {
    my ($tablename) = @_;
    return $dbh->selectall_arrayref("SELECT * from $tablename where borrowernumber = ?", { Slice => {} }, $borrowernumber);
}
