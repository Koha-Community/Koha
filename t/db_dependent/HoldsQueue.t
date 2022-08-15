#!/usr/bin/perl

# Test C4::HoldsQueue::CreateQueue() for both transport cost matrix
# and StaticHoldsQueueWeight array (no RandomizeHoldsQueueWeight, no point)
# Wraps tests in transaction that's rolled back, so no data is destroyed
# MySQL WARNING: This makes sense only if your tables are InnoDB, otherwise
# transactions are not supported and mess is left behind

use Modern::Perl;

use Test::More tests => 61;
use Data::Dumper;

use C4::Calendar qw( new insert_single_holiday );
use C4::Context;
use C4::Members;
use C4::Circulation qw( AddIssue AddReturn );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Holds;
use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves', qw( AddReserve ModReserve ModReserveAffect ));
    use_ok('C4::HoldsQueue', qw( TransportCostMatrix GetHoldsQueueItems CreateQueue UpdateTransportCostMatrix GetPendingHoldRequestsForBib ));
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
$dbh->do("DELETE FROM circulation_rules");

my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  '0' );
t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );

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
my $itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};

#Set up the stage
# Sysprefs and cost matrix
t::lib::Mocks::mock_preference('HoldsQueueSkipClosed', 0);
t::lib::Mocks::mock_preference('LocalHoldsPriority', 0);
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
$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype)
          VALUES                  ($biblionumber, '$itemtype')");
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
AddReserve(
    {
        branchcode     => $borrower_branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => $priority,
    }
);
#                           $resdate, $expdate, $notes, $title, $checkitem, $found
$dbh->do("UPDATE reserves SET reservedate = DATE_SUB( reservedate, INTERVAL 1 DAY )");

# Tests
my $use_cost_matrix_sth = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'UseTransportCostMatrix'");
my $test_sth = $dbh->prepare("SELECT * FROM hold_fill_targets
                              JOIN tmp_holdsqueue USING (borrowernumber, biblionumber, itemnumber)
                              JOIN items USING (itemnumber)
                              WHERE borrowernumber = $borrowernumber");

# We have a book available homed in borrower branch, no point fiddling with AutomaticItemReturn
t::lib::Mocks::mock_preference('AutomaticItemReturn', 0);
test_queue ('take from homebranch',  0, $borrower_branchcode, $borrower_branchcode);
test_queue ('take from homebranch',  1, $borrower_branchcode, $borrower_branchcode);

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode'");
# test_queue will flush
t::lib::Mocks::mock_preference('AutomaticItemReturn', 1);
# Not sure how to make this test more difficult - holding branch does not matter

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode'");
t::lib::Mocks::mock_preference('AutomaticItemReturn', 0);
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
my $queue = C4::HoldsQueue::GetHoldsQueueItems({ branchlmit => $least_cost_branch_code}) || [];
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
$dbh->do("DELETE FROM circulation_rules");

t::lib::Mocks::mock_preference('UseTransportCostMatrix', 0);

$itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};

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

my $category = $builder->build({ source => 'Category', value => {exclude_from_local_holds_priority => 0} } );

my $borrower1 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[0],
        categorycode => $category->{categorycode},
    },
});
my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[1],
        categorycode => $category->{categorycode},
    },
});
my $borrower3 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branchcodes[2],
        categorycode => $category->{categorycode},
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
        itemtype
    ) VALUES (
        $biblionumber,
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
        itype,
        exclude_from_local_holds_priority
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
        '$itemtype',
        0
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

$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rule(
    {
        rule_name    => 'holdallowed',
        rule_value   => 'from_home_library',
        branchcode   => undef,
        itemtype     => undef,
    }
);
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
t::lib::Mocks::mock_preference('HoldsQueueSkipClosed', 1);
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
t::lib::Mocks::mock_preference('HoldsQueueSkipClosed', 0);

$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rule(
    {
        rule_name    => 'holdallowed',
        rule_value   => 'from_any_library',
        branchcode   => undef,
        itemtype     => undef,
    }
);
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 3, "Holds queue filling correct number for holds for default holds policy 'from any library'" );

# Test skipping hold picks for closed libraries without transport cost matrix
# At this point in the test, we have 3 rows in the holds queue
# one of which is coming from MPL. Let's enable HoldsQueueSkipClosed
# and use our previously created holiday for MPL
# When we run it again we should only have 2 rows in the holds queue
t::lib::Mocks::mock_preference( 'HoldsQueueSkipClosed', 1 );
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( scalar( @$holds_queue ), 2, "Holds not filled with items from closed libraries" );
t::lib::Mocks::mock_preference( 'HoldsQueueSkipClosed', 0 );

## Test LocalHoldsPriority
t::lib::Mocks::mock_preference('LocalHoldsPriority', 1);

$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rule(
    {
        rule_name    => 'holdallowed',
        rule_value   => 'from_any_library',
        branchcode   => undef,
        itemtype     => undef,
    }
);
$dbh->do("DELETE FROM issues");

# Test homebranch = patron branch
t::lib::Mocks::mock_preference('LocalHoldsPriorityPatronControl', 'HomeLibrary');
t::lib::Mocks::mock_preference('LocalHoldsPriorityItemControl', 'homebranch');
C4::Context->clear_syspref_cache();
$dbh->do("DELETE FROM reserves");
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[0], 2 );
$sth->execute( $borrower3->{borrowernumber}, $biblionumber, $branchcodes[0], 3 );

$dbh->do("DELETE FROM items");
# barcode, homebranch, holdingbranch, itemtype
$items_insert_sth->execute( $barcode + 4, $branchcodes[2], $branchcodes[0] );

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, $borrower3->{cardnumber}, "Holds queue giving priority to patron who's home library matches item's home library");

### Test branch transfer limits ###
t::lib::Mocks::mock_preference('LocalHoldsPriorityPatronControl', 'HomeLibrary');
t::lib::Mocks::mock_preference('LocalHoldsPriorityItemControl', 'holdingbranch');
t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '1' );
C4::Context->clear_syspref_cache();
$dbh->do("DELETE FROM reserves");
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[1], 2 );

$dbh->do("DELETE FROM items");
# barcode, homebranch, holdingbranch, itemtype
$items_insert_sth->execute( $barcode, $branchcodes[2], $branchcodes[2] );
my $item = Koha::Items->find( { barcode => $barcode } );

my $limit1 = Koha::Item::Transfer::Limit->new(
    {
        toBranch   => $branchcodes[0],
        fromBranch => $branchcodes[2],
        itemtype   => $item->effective_itemtype,
    }
)->store();

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, $borrower2->{cardnumber}, "Holds queue skips hold transfer that would violate branch transfer limits");

my $limit2 = Koha::Item::Transfer::Limit->new(
    {
        toBranch   => $branchcodes[1],
        fromBranch => $branchcodes[2],
        itemtype   => $item->effective_itemtype,
    }
)->store();

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, undef, "Holds queue doesn't fill hold where all available items would violate branch transfer limits");

$limit1->delete();
$limit2->delete();
t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '0' );
### END Test branch transfer limits ###

# Test holdingbranch = patron branch
t::lib::Mocks::mock_preference('LocalHoldsPriorityPatronControl', 'HomeLibrary');
t::lib::Mocks::mock_preference('LocalHoldsPriorityItemControl', 'holdingbranch');
C4::Context->clear_syspref_cache();
$dbh->do("DELETE FROM reserves");
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[0], 2 );
$sth->execute( $borrower3->{borrowernumber}, $biblionumber, $branchcodes[0], 3 );

$dbh->do("DELETE FROM items");
# barcode, homebranch, holdingbranch, itemtype
$items_insert_sth->execute( $barcode + 4, $branchcodes[0], $branchcodes[2] );

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, $borrower3->{cardnumber}, "Holds queue giving priority to patron who's home library matches item's holding library");

# Test holdingbranch = pickup branch
t::lib::Mocks::mock_preference('LocalHoldsPriorityPatronControl', 'PickupLibrary');
t::lib::Mocks::mock_preference('LocalHoldsPriorityItemControl', 'holdingbranch');
C4::Context->clear_syspref_cache();
$dbh->do("DELETE FROM reserves");
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[0], 2 );
$sth->execute( $borrower3->{borrowernumber}, $biblionumber, $branchcodes[2], 3 );

$dbh->do("DELETE FROM items");
# barcode, homebranch, holdingbranch, itemtype
$items_insert_sth->execute( $barcode + 4, $branchcodes[0], $branchcodes[2] );

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, $borrower3->{cardnumber}, "Holds queue giving priority to patron who's home library matches item's holding library");

# Test homebranch = pickup branch
t::lib::Mocks::mock_preference('LocalHoldsPriorityPatronControl', 'PickupLibrary');
t::lib::Mocks::mock_preference('LocalHoldsPriorityItemControl', 'homebranch');
C4::Context->clear_syspref_cache();
$dbh->do("DELETE FROM reserves");
$sth->execute( $borrower1->{borrowernumber}, $biblionumber, $branchcodes[0], 1 );
$sth->execute( $borrower2->{borrowernumber}, $biblionumber, $branchcodes[0], 2 );
$sth->execute( $borrower3->{borrowernumber}, $biblionumber, $branchcodes[2], 3 );

$dbh->do("DELETE FROM items");
# barcode, homebranch, holdingbranch, itemtype
$items_insert_sth->execute( $barcode + 4, $branchcodes[2], $branchcodes[0] );

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( $holds_queue->[0]->{cardnumber}, $borrower3->{cardnumber}, "Holds queue giving priority to patron who's home library matches item's holding library");

t::lib::Mocks::mock_preference('LocalHoldsPriority', 0);
## End testing of LocalHoldsPriority


# Bug 14297
$itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};
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

$dbh->do("
    INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')
");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype, exclude_from_local_holds_priority)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype', 0)
");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype, exclude_from_local_holds_priority)
    VALUES ($biblionumber, $biblioitemnumber, '$library_B', '$library_B', 0, 0, 0, 0, NULL, '$itemtype', 0)
");

Koha::CirculationRules->set_rules(
    {
        branchcode   => $library_A,
        itemtype     => $itemtype,
        rules        => {
            holdallowed  => 'from_any_library',
            returnbranch => 'homebranch',
        }
    }
);

$dbh->do( "UPDATE systempreferences SET value = ? WHERE variable = 'StaticHoldsQueueWeight'",
    undef, join( ',', $library_B, $library_A, $library_C ) );
$dbh->do( "UPDATE systempreferences SET value = 0 WHERE variable = 'RandomizeHoldsQueueWeight'" );

my $reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);
C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 1, "Bug 14297 - Holds Queue building ignoring holds where pickup & home branch don't match and item is not from le");
# End Bug 14297

# Bug 15062
$itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};
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

t::lib::Mocks::mock_preference("UseTransportCostMatrix",1);

my $tc_rs = $schema->resultset('TransportCost');
$tc_rs->create({ frombranch => $library_A, tobranch => $library_B, cost => 0, disable_transfer => 1 });
$tc_rs->create({ frombranch => $library_B, tobranch => $library_A, cost => 0, disable_transfer => 1 });

$dbh->do("
    INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')
");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype, exclude_from_local_holds_priority)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_A', 0, 0, 0, 0, NULL, '$itemtype', 0)
");

$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref("SELECT * FROM tmp_holdsqueue", { Slice => {} });
is( @$holds_queue, 0, "Bug 15062 - Holds queue with Transport Cost Matrix will transfer item even if transfers disabled");
# End Bug 15062

# Test hold_fulfillment_policy
t::lib::Mocks::mock_preference( "UseTransportCostMatrix", 0 );
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

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype, exclude_from_local_holds_priority)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_B', 0, 0, 0, 0, NULL, '$itemtype', 0)
");

# With hold_fulfillment_policy = homebranch, hold should only be picked up if pickup branch = homebranch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'homebranch',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup branch matches home branch targeted" );
my $target_rs = $schema->resultset('HoldFillTarget');
is( $target_rs->next->reserve_id, $reserve_id, "Reserve id correctly set in hold fill target for title level hold" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);


C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup eq home not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# With hold_fulfillment_policy = holdingbranch, hold should only be picked up if pickup branch = holdingbranch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'holdingbranch',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup eq home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup eq holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Hold where pickup ne home, pickup ne holding not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# With hold_fulfillment_policy = any, hold should be pikcup up reguardless of matching home or holding branch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'any',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup eq home, pickup ne holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_B,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup eq holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_C,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Hold where pickup ne home, pickup ne holding targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# End testing hold_fulfillment_policy

# Test hold itemtype limit
t::lib::Mocks::mock_preference( "UseTransportCostMatrix", 0 );
my $wrong_itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};
my $right_itemtype = $builder->build({ source => 'Itemtype', value => { notforloan => 0 } })->{itemtype};
$borrowernumber = $borrower3->{borrowernumber};
my $branchcode = $library1->{branchcode};
$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM issues");
$dbh->do("DELETE FROM items");
$dbh->do("DELETE FROM biblio");
$dbh->do("DELETE FROM biblioitems");
$dbh->do("DELETE FROM transport_cost");
$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");

$dbh->do("INSERT INTO biblio (frameworkcode, author, title, datecreated) VALUES ('', 'Koha test', '$TITLE', '2011-02-01')");

$biblionumber = $dbh->selectrow_array("SELECT biblionumber FROM biblio WHERE title = '$TITLE'")
  or BAIL_OUT("Cannot find newly created biblio record");

$dbh->do("INSERT INTO biblioitems (biblionumber, itemtype) VALUES ($biblionumber, '$itemtype')");

$biblioitemnumber =
  $dbh->selectrow_array("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber = $biblionumber")
  or BAIL_OUT("Cannot find newly created biblioitems record");

$dbh->do("
    INSERT INTO items (biblionumber, biblioitemnumber, homebranch, holdingbranch, notforloan, damaged, itemlost, withdrawn, onloan, itype, exclude_from_local_holds_priority)
    VALUES ($biblionumber, $biblioitemnumber, '$library_A', '$library_B', 0, 0, 0, 0, NULL, '$right_itemtype', 0)
");

# With hold_fulfillment_policy = homebranch, hold should only be picked up if pickup branch = homebranch
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            holdallowed             => 'from_any_library',
            hold_fulfillment_policy => 'any',
        }
    }
);

# Home branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
        itemtype       => $wrong_itemtype,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 0, "Item with incorrect itemtype not targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Holding branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
        itemtype       => $right_itemtype,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Item with matching itemtype is targeted" );
Koha::Holds->find( $reserve_id )->cancel;

# Neither branch matches pickup branch
$reserve_id = AddReserve(
    {
        branchcode     => $library_A,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

C4::HoldsQueue::CreateQueue();
$holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );
is( @$holds_queue, 1, "Item targeted when hold itemtype is not set" );
Koha::Holds->find( $reserve_id )->cancel;

# End testing hold itemtype limit


subtest "Test Local Holds Priority - Bib level" => sub {
    plan tests => 3;

    Koha::Biblios->delete();
    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $local_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode
            }
        }
    );
    my $other_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch2->branchcode,
                categorycode => $category->categorycode
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $reserve_id = AddReserve(
        {
            branchcode     => $branch2->branchcode,
            borrowernumber => $other_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );
    my $reserve_id2 = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $local_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 2,
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');
    my $target_rs = $schema->resultset('HoldFillTarget');
    is( $queue_rs->count(), 1,
        "Hold queue contains one hold" );
    is(
        $queue_rs->next->borrowernumber->borrowernumber,
        $local_patron->borrowernumber,
        "We should pick the local hold over the next available"
    );
    is( $target_rs->next->reserve_id, $reserve_id2, "Reserve id correctly set in hold fill target" );
};

subtest "Test Local Holds Priority - Item level" => sub {
    plan tests => 2;

    Koha::Biblios->delete();
    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $local_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode
            }
        }
    );
    my $other_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch2->branchcode,
                categorycode => $category->categorycode
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $reserve_id = AddReserve(
        {
            branchcode     => $branch2->branchcode,
            borrowernumber => $other_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            itemnumber     => $item->id,
        }
    );
    my $reserve_id2 = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $local_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 2,
            itemnumber     => $item->id,
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');
    my $q = $queue_rs->next;
    is( $queue_rs->count(), 1,
        "Hold queue contains one hold" );
    is(
        $q->borrowernumber->borrowernumber,
        $local_patron->borrowernumber,
        "We should pick the local hold over the next available"
    );
};

subtest "Test Local Holds Priority - Item level hold over Record level hold (Bug 23934)" => sub {
    plan tests => 2;

    Koha::Biblios->delete();
    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $local_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $other_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch2->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $reserve_id = AddReserve(
        {
            branchcode     => $branch2->branchcode,
            borrowernumber => $other_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );
    my $reserve_id2 = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $local_patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 2,
            itemnumber     => $item->id,
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');
    my $q = $queue_rs->next;
    is( $queue_rs->count(), 1,
        "Hold queue contains one hold" );
    is(
        $q->borrowernumber->borrowernumber,
        $local_patron->borrowernumber,
        "We should pick the local hold over the next available"
    );
};

subtest "Test Local Holds Priority - Get correct item for item level hold" => sub {
    plan tests => 3;

    Koha::Biblios->delete();
    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $local_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $other_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch2->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();

    my $item1 = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item2 = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item3 = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $reserve_id2 =
        AddReserve(
            {
                branchcode     => $item2->homebranch,
                borrowernumber => $local_patron->borrowernumber,
                biblionumber   => $biblio->biblionumber,
                priority       => 2,
                itemnumber     => $item2->id,
            }
        );


    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');
    my $q = $queue_rs->next;
    is( $queue_rs->count(), 1,
        "Hold queue contains one hold" );
    is(
        $q->borrowernumber->borrowernumber,
        $local_patron->borrowernumber,
        "We should pick the local hold over the next available"
    );
    is( $q->itemnumber->id, $item2->id, "Got the correct item for item level local holds priority" );
};

subtest "Test Local Holds Priority - Ensure no duplicate requests in holds queue (Bug 18001)" => sub {
    plan tests => 1;

    $dbh->do("DELETE FROM tmp_holdsqueue");
    $dbh->do("DELETE FROM hold_fill_targets");
    $dbh->do("DELETE FROM reserves");
    $dbh->do("DELETE FROM circulation_rules");
    Koha::Biblios->delete();

    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $patron  = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item1  = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $item3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    $reserve_id = AddReserve(
        {
            branchcode     => $item1->homebranch,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 1
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');

    is( $queue_rs->count(), 1,
        "Hold queue contains one hold from chosen from three possible items" );
};


subtest "Item level holds info is preserved (Bug 25738)" => sub {

    plan tests => 4;

    $dbh->do("DELETE FROM tmp_holdsqueue");
    $dbh->do("DELETE FROM hold_fill_targets");
    $dbh->do("DELETE FROM reserves");
    $dbh->do("DELETE FROM circulation_rules");

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $patron_1 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $patron_2 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    # Add item-level hold for patron_1
    my $reserve_id_1 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $biblio->id,
            itemnumber     => $item_1->itemnumber,
            priority       => 1
        }
    );

    my $reserve_id_2 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 2
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');

    is( $queue_rs->count(), 2, "Hold queue contains two holds" );

    my $queue_line_1 = $queue_rs->next;
    is( $queue_line_1->item_level_request, 1, 'Request is correctly advertised as item-level' );
    my $target_rs = $schema->resultset('HoldFillTarget')->search({borrowernumber=>$patron_1->borrowernumber});;
    is( $target_rs->next->reserve_id, $reserve_id_1, "Reserve id correctly set in hold fill target for item level hold" );

    my $queue_line_2 = $queue_rs->next;
    is( $queue_line_2->item_level_request, 0, 'Request is correctly advertised as biblio-level' );

};

subtest 'Trivial test for UpdateTransportCostMatrix' => sub {
    plan tests => 1;
    my $recs = [
        { frombranch => $library1->{branchcode}, tobranch => $library2->{branchcode}, cost => 1, disable_transfer => 0 },
        { frombranch => $library2->{branchcode}, tobranch => $library3->{branchcode}, cost => 0, disable_transfer => 1 },
    ];
    C4::HoldsQueue::UpdateTransportCostMatrix( $recs );
    is( $schema->resultset('TransportCost')->count, 2, 'UpdateTransportCostMatrix added two records' );
};

subtest 'Excludes from local holds priority' => sub {
    plan tests => 8;

    Koha::Holds->delete;

    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
    t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );

    my $branch  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $excluded_category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 1} });
    my $local_patron_excluded = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $excluded_category->categorycode
            }
        }
    );

    my $local_patron_not_excluded = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $other_patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch2->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $item1  = $builder->build_sample_item(
        {
            library      => $branch->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    AddReserve(
        {
            branchcode     => $other_patron->branchcode,
            borrowernumber => $other_patron->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 1,
            itemtype       => $item1->effective_itemtype
        }
    );

    AddReserve(
        {
            branchcode     => $local_patron_excluded->branchcode,
            borrowernumber => $local_patron_excluded->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 2,
            itemtype       => $item1->effective_itemtype
        }
    );

    AddReserve(
        {
            branchcode     => $local_patron_not_excluded->branchcode,
            borrowernumber => $local_patron_not_excluded->borrowernumber,
            biblionumber   => $item1->biblionumber,
            priority       => 3,
            itemtype       => $item1->effective_itemtype
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');
    my $next = $queue_rs->next;
    is($queue_rs->count, 1, 'Only 1 patron queueud' );
    is($next->borrowernumber->borrowernumber, $local_patron_not_excluded->borrowernumber, 'Not excluded local patron is queued');

    my $item2  = $builder->build_sample_item(
        {
            biblionumber => $item1->biblionumber,
            library      => $branch->branchcode,
            exclude_from_local_holds_priority => 1,
        }
    );
    C4::HoldsQueue::CreateQueue();

    $queue_rs = $schema->resultset('TmpHoldsqueue');
    is( $queue_rs->count, 2, '2 patrons queued' );
    $next = $queue_rs->next;
    is($next->borrowernumber->borrowernumber, $local_patron_not_excluded->borrowernumber, 'Not excluded local patron is queued');
    $next = $queue_rs->next;
    is($next->borrowernumber->borrowernumber, $other_patron->borrowernumber, 'Other patron is queued');

    $item1->exclude_from_local_holds_priority(1)->store;

    C4::HoldsQueue::CreateQueue();

    $queue_rs = $schema->resultset('TmpHoldsqueue');
    is( $queue_rs->count, 2, '2 patrons queued' );
    $next = $queue_rs->next;
    is($next->borrowernumber->borrowernumber, $other_patron->borrowernumber, 'Other patron is queued');
    $next = $queue_rs->next;
    is($next->borrowernumber->borrowernumber, $local_patron_excluded->borrowernumber, 'Excluded local patron is queued');
};

subtest "Test item group holds" => sub {

    plan tests => 4;

    $dbh->do("DELETE FROM tmp_holdsqueue");
    $dbh->do("DELETE FROM hold_fill_targets");
    $dbh->do("DELETE FROM reserves");
    $dbh->do("DELETE FROM circulation_rules");

    t::lib::Mocks::mock_preference('HoldsQueueSkipClosed', 0);
    t::lib::Mocks::mock_preference('LocalHoldsPriority', 0);

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $patron_1 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $patron_2 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $patron_3 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $patron_4 = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $biblio = $builder->build_sample_biblio();

    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    my $item_group_1 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();
    my $item_group_2 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    $item_group_1->add_item({ item_id => $item_1->id });
    $item_group_1->add_item({ item_id => $item_2->id });

    # Add item-level hold for patron_1
    my $reserve_id_1 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $biblio->id,
            itemnumber     => $item_1->itemnumber,
            priority       => 1,
            item_group_id  => $item_group_1->id
        }
    );

    my $reserve_id_2 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 2,
            item_group_id  => $item_group_2->id
        }
    );

    my $reserve_id_3 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_3->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 3,
            item_group_id  => $item_group_1->id
        }
    );

    my $reserve_id_4 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_4->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 4,
            item_group_id  => undef
        }
    );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue');

    is( $queue_rs->count(), 3, "Hold queue contains two holds" );

    my $queue_line_1 = $queue_rs->next;
    is( $queue_line_1->borrowernumber->id, $patron_1->id, "Correct Hold was filled for the correct patron, item group 1, priority 1" );

    my $queue_line_2 = $queue_rs->next;
    is( $queue_line_2->borrowernumber->id, $patron_3->id, "Correct Hold was filled for the correct patron, item group 1, priority 2" );

    my $queue_line_3 = $queue_rs->next;
    is( $queue_line_3->borrowernumber->id, $patron_4->id, "Correct Hold was filled for the correct patron, no item group" );
};

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

    # Test enforcement of branch transfer limit
    if ( $r->{pickbranch} ne $r->{holdingbranch} ) {
        t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '1' );
        my $limit = Koha::Item::Transfer::Limit->new(
            {
                toBranch   => $r->{pickbranch},
                fromBranch => $r->{holdingbranch},
                itemtype   => $r->{itype},
            }
        )->store();
        C4::Context->clear_syspref_cache();
        C4::HoldsQueue::CreateQueue();
        $results = $dbh->selectall_arrayref( $test_sth, { Slice => {} } )
          ;    # should be only one
        my $s = $results->[0];
        isnt( $r->{holdingbranch}, $s->{holdingbranch}, 'Hold is not trapped for pickup at a branch that cannot be transferred to');

        $limit->delete();
        t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '0' );
        C4::Context->clear_syspref_cache();
        C4::HoldsQueue::CreateQueue();
    }

}

subtest "Test _checkHoldPolicy" => sub {

    plan tests => 25;

    $schema->storage->txn_begin;

    my $library1  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_nongroup = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => {exclude_from_local_holds_priority => 0} });
    my $patron  = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $library1->branchcode,
                categorycode => $category->categorycode,
            }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item1  = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library1->branchcode,
            exclude_from_local_holds_priority => 0,
        }
    );

    $reserve_id = AddReserve(
        {
            branchcode     => $item1->homebranch,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->id,
            priority       => 1
        }
    );
    ok( $reserve_id, "Hold was created");
    my $requests = C4::HoldsQueue::GetPendingHoldRequestsForBib($biblio->biblionumber);
    is( @$requests, 1, "Got correct number of holds");

    my $request = $requests->[0];
    is( $request->{biblionumber}, $biblio->id, "Hold has correct biblio");
    is( $request->{borrowernumber}, $patron->id, "Hold has correct borrower");
    is( $request->{borrowerbranch}, $patron->branchcode, "Hold has correct borrowerbranch");

    my $hold = Koha::Holds->find( $reserve_id );
    ok( $hold, "Found hold" );

    my $item = {
        holdallowed              => 'from_home_library',
        homebranch               => $request->{borrowerbranch}, # library1
        hold_fulfillment_policy  => 'any'
    };

    # Base case should work
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true" );

    # Test holdallowed = 'not_allowed'
    $item->{holdallowed} = 'not_allowed';
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if holdallowed = not_allowed" );

    # Test holdallowed = 'from_home_library'
    $item->{holdallowed} = 'from_home_library';
    $item->{homebranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if holdallowed = from_home_library and branches do not match" );

    $item->{homebranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if holdallowed = from_home_library and branches do match" );

    # Test holdallowed = 3
    $item->{holdallowed} = 'from_local_hold_group';
    $item->{homebranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if branchode doesn't match, holdallowed = from_local_hold_group and no group branches exist" );
    $item->{homebranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if branchode matches, holdallowed = from_local_hold_group and no group branches exist" );

    # Create library groups hierarchy
    my $rootgroup = $builder->build_object( { class => 'Koha::Library::Groups', value => {ft_local_hold_group => 1} } );
    my $group1 = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library1->branchcode}} );
    my $group2 = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library2->branchcode}} );

    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if holdallowed = from_local_hold_group and no group branches exist" );

    $group1->delete;

    # Test hold_fulfillment_policy = holdgroup
    $item->{hold_fulfillment_policy} = 'holdgroup';
    $item->{homebranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns true if library is not part of hold group, branches don't match and hfp = holdgroup" );
    $item->{homebranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if library is not part of hold group, branches match and hfp = holdgroup" );

    $group1 = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library1->branchcode}} );
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if library is part of hold group with hfp = holdgroup" );

    $item->{homebranch} = $library2->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if library is part of hold group with hfp = holdgroup" );
    $item->{homebranch} = $library1->id;

    $group1->delete;

    # Test hold_fulfillment_policy = homebranch
    $item->{hold_fulfillment_policy} = 'homebranch';
    $item->{homebranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if hfp = homebranch and pickup branch != item homebranch" );

    $item->{homebranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if hfp = homebranch and pickup branch = item homebranch" );

    # Test hold_fulfillment_policy = holdingbranch
    $item->{hold_fulfillment_policy} = 'holdingbranch';
    $item->{holdingbranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if hfp = holdingbranch and pickup branch != item holdingbranch" );

    $item->{holdingbranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if hfp = holdingbranch and pickup branch = item holdingbranch" );

    # Test hold_fulfillment_policy = patrongroup
    $item->{hold_fulfillment_policy} = 'patrongroup';
    $item->{borrowerbranch} = $library1->id;

    $item->{homebranch} = $library_nongroup->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 0, "_checkHoldPolicy returns false if library is not part of hold group, branches don't match, hfp = patrongroup" );
    $item->{homebranch} = $request->{borrowerbranch};
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns false if library is not part of hold group, branches match, hfp = patrongroup" );

    $group1 = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library1->branchcode}} );
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if library is part of hold group with hfp = holdgroup" );

    $item->{borrowerbranch} = $library2->id;
    is( C4::HoldsQueue::_checkHoldPolicy( $item, $request ), 1, "_checkHoldPolicy returns true if library is part of hold group with hfp = holdgroup" );
    $item->{borrowerbranch} = $library1->id;

    $schema->storage->txn_rollback;
};

sub dump_records {
    my ($tablename) = @_;
    return $dbh->selectall_arrayref("SELECT * from $tablename where borrowernumber = ?", { Slice => {} }, $borrowernumber);
}

subtest 'Remove holds on check-in match' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $lib = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $lib->branchcode }
        }
    );
    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $lib->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        { homebranch => $lib->branchcode, holdingbranch => $lib->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $lib->branchcode } );

    AddIssue( $patron1->unblessed, $item->barcode, dt_from_string );

    my $hold_id = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $patron2->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => undef,
            priority       => 1
        }
    );

    my $hold = Koha::Holds->find($hold_id);

    AddReturn( $item->barcode, $item->homebranch );

    C4::HoldsQueue::CreateQueue();

    my $sth = $dbh->prepare(q{
        SELECT  COUNT(*)
        FROM    tmp_holdsqueue q
        INNER JOIN hold_fill_targets t
        ON  q.borrowernumber = t.borrowernumber
            AND q.biblionumber = t.biblionumber
            AND q.itemnumber = t.itemnumber
            AND q.item_level_request = t.item_level_request
            AND q.holdingbranch = t.source_branchcode
        WHERE t.reserve_id = ?
    });
    $sth->execute($hold->reserve_id);
    my ($count_1) = $sth->fetchrow_array;

    is( $count_1, 1, "Holds queue has one element" );

    AddReturn( $item->barcode, $item->homebranch, undef, dt_from_string );

    ModReserveAffect( $item->itemnumber, $hold->borrowernumber, 0,
        $hold->reserve_id );

    $sth->execute($hold->reserve_id);
    my ($count_2) = $sth->fetchrow_array;

    is( $count_2, 0,
        "Holds queue has no elements, even when queue was not rebuilt" );

    $schema->storage->txn_rollback;
};

subtest "GetHoldsQueueItems" => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $ccode = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category => 'CCODE'
            }
        }
    );
    my $location = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category => 'LOC'
            }
        }
    );
    my $item_1 = $builder->build_sample_item();
    my $item_2 = $builder->build_sample_item(
        {
            itype => $item_1->itype,
            ccode => $ccode->authorised_value
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            itype    => $item_1->itype,
            ccode    => $item_2->ccode,
            location => $location->authorised_value
        }
    );

    my $itemnumber_1 = $item_1->itemnumber;
    my $itemnumber_2 = $item_2->itemnumber;
    my $itemnumber_3 = $item_3->itemnumber;

    my $biblionumber_1 = $item_1->biblionumber;
    my $biblionumber_2 = $item_2->biblionumber;
    my $biblionumber_3 = $item_3->biblionumber;

    my $sth = $dbh->prepare(q{ SELECT  COUNT(*) FROM tmp_holdsqueue });
    $sth->execute();
    my ($count) = $sth->fetchrow_array;

    $dbh->do( "
        INSERT INTO tmp_holdsqueue (itemnumber,biblionumber,surname,firstname,phone,borrowernumber,title,notes) VALUES
        ($itemnumber_1,$biblionumber_1,'','','',22,'',''),
        ($itemnumber_2,$biblionumber_2,'','','',32,'',''),
        ($itemnumber_3,$biblionumber_3,'','','',42,'','')
     " );

    my $queue_items = GetHoldsQueueItems();
    is( scalar @$queue_items, $count + 3, 'Three items added to queue' );

    $queue_items = GetHoldsQueueItems( { itemtypeslimit => $item_1->itype } );
    is( scalar @$queue_items,
        3, 'Three items of same itemtype found when itemtypeslimit passed' );

    $queue_items = GetHoldsQueueItems(
        { itemtypeslimit => $item_1->itype, ccodeslimit => $item_2->ccode } );
    is( scalar @$queue_items,
        2, 'Two items of same collection found when ccodeslimit passed' );

    @$queue_items = GetHoldsQueueItems(
        {
            itemtypeslimit => $item_1->itype,
            ccodeslimit    => $item_2->ccode,
            locationslimit => $item_3->location
        }
    );
    is( scalar @$queue_items,
        1, 'One item of shleving location found when locationslimit passed' );

    $schema->storage->txn_rollback;
};

subtest "Test HoldsQueuePrioritizeBranch" => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 0 );
    t::lib::Mocks::mock_preference( 'UseTransportCostMatrix', 0 );

    my $branch1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories' });
    my $patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => {
                branchcode => $branch1->branchcode,
                categorycode => $category->categorycode
            }
        }
    );

    my $biblio = $builder->build_sample_biblio();
    my $item1   = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch1->branchcode,
        }
    )->holdingbranch( $branch2->id )->store();

    my $item2   = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            library    => $branch1->branchcode,
        }
    )->homebranch( $branch2->id )->store();

    my $reserve_id = AddReserve(
        {
            branchcode     => $branch1->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );

    t::lib::Mocks::mock_preference( 'HoldsQueuePrioritizeBranch', 'homebranch' );

    C4::HoldsQueue::CreateQueue();

    my $queue_rs = $schema->resultset('TmpHoldsqueue')->search({ biblionumber => $biblio->biblionumber });
    is(
        $queue_rs->next->itemnumber->itemnumber,
        $item1->itemnumber,
        "Picked the item whose homebranch matches the pickup branch"
    );

    t::lib::Mocks::mock_preference( 'HoldsQueuePrioritizeBranch', 'holdingbranch' );

    C4::HoldsQueue::CreateQueue();

    $queue_rs = $schema->resultset('TmpHoldsqueue')->search({ biblionumber => $biblio->biblionumber });
    is(
        $queue_rs->next->itemnumber->itemnumber,
        $item2->itemnumber,
        "Picked the item whose holdingbranch matches the pickup branch"
    );

    t::lib::Mocks::mock_preference( 'HoldsQueuePrioritizeBranch', 'homebranch' );

    C4::HoldsQueue::CreateQueue();

    $queue_rs = $schema->resultset('TmpHoldsqueue')->search({ biblionumber => $biblio->biblionumber });
    is(
        $queue_rs->next->itemnumber->itemnumber,
        $item1->itemnumber,
        "Picked the item whose homebranch matches the pickup branch"
    );

    t::lib::Mocks::mock_preference( 'HoldsQueuePrioritizeBranch', 'holdingbranch' );

    C4::HoldsQueue::CreateQueue();

    $queue_rs = $schema->resultset('TmpHoldsqueue')->search({ biblionumber => $biblio->biblionumber });
    is(
        $queue_rs->next->itemnumber->itemnumber,
        $item2->itemnumber,
        "Picked the item whose holdingbranch matches the pickup branch"
    );

    $schema->storage->txn_rollback;
};

subtest "GetItemsAvailableToFillHoldsRequestsForBib" => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $item_1 = $builder->build_sample_item();
    my $item_2 = $builder->build_sample_item({ biblionumber => $item_1->biblionumber });
    my $item_3 = $builder->build_sample_item({ biblionumber => $item_1->biblionumber });

    my $transfer_1 = $builder->build_object({ class => 'Koha::Item::Transfers', value => {
        itemnumber => $item_1->itemnumber,
        datearrived => undef,
        datecancelled => undef
    }});
    my $transfer_2 = $builder->build_object({ class => 'Koha::Item::Transfers', value => {
        itemnumber => $item_2->itemnumber,
        datearrived => dt_from_string,
        datecancelled => undef
    }});
    my $transfer_3 = $builder->build_object({ class => 'Koha::Item::Transfers', value => {
        itemnumber => $item_3->itemnumber,
        datearrived => undef,
        datecancelled => dt_from_string
    }});

    my $items = C4::HoldsQueue::GetItemsAvailableToFillHoldRequestsForBib( $item_1->biblionumber );
    is( scalar @$items, 2, "Two items without active transfers correctly retrieved");
    is_deeply( [$items->[0]->{itemnumber},$items->[1]->{itemnumber}],[$item_2->itemnumber,$item_3->itemnumber],"Correct two items retrieved");

};
