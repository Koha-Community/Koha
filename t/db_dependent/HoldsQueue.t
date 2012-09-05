#!/usr/bin/perl

# Test C4::HoldsQueue::CreateQueue() for both transport cost matrix
# and StaticHoldsQueueWeight array (no RandomizeHoldsQueueWeight, no point)
# Wraps tests in transaction that's rolled back, so no data is destroyed
# MySQL WARNING: This makes sense only if your tables are InnoDB, otherwise
# transactions are not supported and mess is left behind

use strict;
use warnings;
use C4::Context;

use Data::Dumper;

use Test::More tests => 18;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
    use_ok('C4::HoldsQueue');
}

my $TITLE = "Test Holds Queue XXX";
# Pick a plausible borrower. Easier than creating one.
my $BORROWER_QRY = <<EOQ;
select *
from borrowers
where borrowernumber = (select max(borrowernumber) from issues)
EOQ
my $dbh = C4::Context->dbh;
my $borrower = $dbh->selectrow_hashref($BORROWER_QRY);
my $borrowernumber = $borrower->{borrowernumber};
# Set special (for this test) branches
my $borrower_branchcode = $borrower->{branchcode};
my @other_branches = grep { $_ ne $borrower_branchcode } @{ $dbh->selectcol_arrayref("SELECT branchcode FROM branches") };
my $least_cost_branch_code = pop @other_branches
  or BAIL_OUT("No point testing only one branch...");
my $itemtype = $dbh->selectrow_array("SELECT min(itemtype) FROM itemtypes WHERE notforloan = 0")
  or BAIL_OUT("No adequate itemtype");

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

#Set up the stage
# Sysprefs and cost matrix
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

my $items_insert_sth = $dbh->prepare("INSERT INTO items (biblionumber, biblioitemnumber, barcode, homebranch, holdingbranch, notforloan, damaged, itemlost, wthdrawn, onloan, itype)
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
my $constraint = undef;
my $bibitems = undef;
my $priority = 1;
# Make a reserve
AddReserve ( $borrower_branchcode, $borrowernumber, $biblionumber, $constraint, $bibitems,  $priority );
#                           $resdate, $expdate, $notes, $title, $checkitem, $found
$dbh->do("UPDATE reserves SET reservedate = reservedate - 1");

# Tests
my $use_cost_matrix_sth = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'UseTransportCostMatrix'");
my $test_sth = $dbh->prepare("SELECT * FROM hold_fill_targets
                              JOIN tmp_holdsqueue USING (borrowernumber, biblionumber, itemnumber)
                              JOIN items USING (itemnumber)
                              WHERE borrowernumber = $borrowernumber");

# We have a book available homed in borrower branch, no point fiddling with AutomaticItemReturn
test_queue ('take from homebranch',  0, $borrower_branchcode, $borrower_branchcode);
test_queue ('take from homebranch',  1, $borrower_branchcode, $borrower_branchcode);

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode' AND holdingbranch = '$borrower_branchcode'");
# test_queue will flush
$dbh->do("UPDATE systempreferences SET value = 1 WHERE variable = 'AutomaticItemReturn'");
# Not sure how to make this test more difficult - holding branch does not matter
test_queue ('take from holdingbranch AutomaticItemReturn on', 0, $borrower_branchcode, undef);
test_queue ('take from holdingbranch AutomaticItemReturn on', 1, $borrower_branchcode, $least_cost_branch_code);

$dbh->do("DELETE FROM tmp_holdsqueue");
$dbh->do("DELETE FROM hold_fill_targets");
$dbh->do("DELETE FROM issues WHERE itemnumber IN (SELECT itemnumber FROM items WHERE homebranch = '$borrower_branchcode')");
$dbh->do("DELETE FROM items WHERE homebranch = '$borrower_branchcode'");
$dbh->do("UPDATE systempreferences SET value = 0 WHERE variable = 'AutomaticItemReturn'");
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

# XXX All this tests are for borrower branch pick-up.
# Maybe needs expanding to homebranch or holdingbranch pick-up.

# Cleanup
$dbh->rollback;

exit;

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
