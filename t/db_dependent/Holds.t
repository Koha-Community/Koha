#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;

use Test::More tests => 56;
use MARC::Record;
use Koha::Patrons;
use C4::Items;
use C4::Biblio;
use C4::Reserves;
use C4::Calendar;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Holds;
use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;
use Koha::CirculationRules;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $dbh     = C4::Context->dbh;

# Create two random branches
my $branch_1 = $builder->build({ source => 'Branch' })->{ branchcode };
my $branch_2 = $builder->build({ source => 'Branch' })->{ branchcode };

my $category = $builder->build({ source => 'Category' });

my $borrowers_count = 5;

$dbh->do('DELETE FROM itemtypes');
$dbh->do('DELETE FROM reserves');
my $insert_sth = $dbh->prepare('INSERT INTO itemtypes (itemtype) VALUES (?)');
$insert_sth->execute('CAN');
$insert_sth->execute('CANNOT');
$insert_sth->execute('DUMMY');
$insert_sth->execute('ONLY1');

# Setup Test------------------------
# Create a biblio instance for testing
my ($bibnum, $title, $bibitemnum) = create_helper_biblio('DUMMY');

# Create item instance for testing.
my ($item_bibnum, $item_bibitemnum, $itemnumber)
    = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);

# Create some borrowers
my @borrowernumbers;
foreach (1..$borrowers_count) {
    my $borrowernumber = Koha::Patron->new({
        firstname =>  'my firstname',
        surname => 'my surname ' . $_,
        categorycode => $category->{categorycode},
        branchcode => $branch_1,
    })->store->borrowernumber;
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber = $bibnum;

# Create five item level holds
foreach my $borrowernumber ( @borrowernumbers ) {
    AddReserve(
        $branch_1,
        $borrowernumber,
        $biblionumber,
        my $bibitems = q{},
        my $priority = C4::Reserves::CalculatePriority( $biblionumber ),
        my $resdate,
        my $expdate,
        my $notes = q{},
        $title,
        my $checkitem = $itemnumber,
        my $found,
    );
}

my $biblio = Koha::Biblios->find( $biblionumber );
my $holds = $biblio->holds;
is( $holds->count, $borrowers_count, 'Test GetReserves()' );
is( $holds->next->priority, 1, "Reserve 1 has a priority of 1" );
is( $holds->next->priority, 2, "Reserve 2 has a priority of 2" );
is( $holds->next->priority, 3, "Reserve 3 has a priority of 3" );
is( $holds->next->priority, 4, "Reserve 4 has a priority of 4" );
is( $holds->next->priority, 5, "Reserve 5 has a priority of 5" );

my $item = Koha::Items->find( $itemnumber );
$holds = $item->current_holds;
my $first_hold = $holds->next;
my $reservedate = $first_hold->reservedate;
my $borrowernumber = $first_hold->borrowernumber;
my $branch_1code = $first_hold->branchcode;
my $reserve_id = $first_hold->reserve_id;
is( $reservedate, output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 }), "holds_placed_today should return a valid reserve date");
is( $borrowernumber, $borrowernumbers[0], "holds_placed_today should return a valid borrowernumber");
is( $branch_1code, $branch_1, "holds_placed_today should return a valid branchcode");
ok($reserve_id, "Test holds_placed_today()");

my $hold = Koha::Holds->find( $reserve_id );
ok( $hold, "Koha::Holds found the hold" );
my $hold_biblio = $hold->biblio();
ok( $hold_biblio, "Got biblio using biblio() method" );
ok( $hold_biblio == $hold->biblio(), "biblio method returns stashed biblio" );
my $hold_item = $hold->item();
ok( $hold_item, "Got item using item() method" );
ok( $hold_item == $hold->item(), "item method returns stashed item" );
my $hold_branch = $hold->branch();
ok( $hold_branch, "Got branch using branch() method" );
ok( $hold_branch == $hold->branch(), "branch method returns stashed branch" );
my $hold_found = $hold->found();
$hold->set({ found => 'W'})->store();
is( Koha::Holds->waiting()->count(), 1, "Koha::Holds->waiting returns waiting holds" );
is( Koha::Holds->unfilled()->count(), 4, "Koha::Holds->unfilled returns unfilled holds" );

my $patron = Koha::Patrons->find( $borrowernumbers[0] );
$holds = $patron->holds;
is( $holds->next->borrowernumber, $borrowernumbers[0], "Test Koha::Patron->holds");


$holds = $item->current_holds;
$first_hold = $holds->next;
$borrowernumber = $first_hold->borrowernumber;
$branch_1code = $first_hold->branchcode;
$reserve_id = $first_hold->reserve_id;

ModReserve({
    reserve_id    => $reserve_id,
    rank          => '4',
    branchcode    => $branch_1,
    itemnumber    => $itemnumber,
    suspend_until => output_pref( { dt => dt_from_string( "2013-01-01", "iso" ), dateonly => 1 } ),
});

$hold = Koha::Holds->find( $reserve_id );
ok( $hold->priority eq '4', "Test ModReserve, priority changed correctly" );
ok( $hold->suspend, "Test ModReserve, suspend hold" );
is( $hold->suspend_until, '2013-01-01 00:00:00', "Test ModReserve, suspend until date" );

ModReserve({ # call without reserve_id
    rank          => '3',
    biblionumber  => $item_bibnum,
    itemnumber    => $itemnumber,
    borrowernumber => $borrowernumber,
});
$hold = Koha::Holds->find( $reserve_id );
ok( $hold->priority eq '3', "Test ModReserve, priority changed correctly" );

ToggleSuspend( $reserve_id );
$hold = Koha::Holds->find( $reserve_id );
ok( ! $hold->suspend, "Test ToggleSuspend(), no date" );

ToggleSuspend( $reserve_id, '2012-01-01' );
$hold = Koha::Holds->find( $reserve_id );
is( $hold->suspend_until, '2012-01-01 00:00:00', "Test ToggleSuspend(), with date" );

AutoUnsuspendReserves();
$hold = Koha::Holds->find( $reserve_id );
ok( ! $hold->suspend, "Test AutoUnsuspendReserves()" );

SuspendAll(
    borrowernumber => $borrowernumber,
    biblionumber   => $biblionumber,
    suspend => 1,
    suspend_until => '2012-01-01',
);
$hold = Koha::Holds->find( $reserve_id );
is( $hold->suspend, 1, "Test SuspendAll()" );
is( $hold->suspend_until, '2012-01-01 00:00:00', "Test SuspendAll(), with date" );

SuspendAll(
    borrowernumber => $borrowernumber,
    biblionumber   => $biblionumber,
    suspend => 0,
);
$hold = Koha::Holds->find( $reserve_id );
is( $hold->suspend, 0, "Test resuming with SuspendAll()" );
is( $hold->suspend_until, undef, "Test resuming with SuspendAll(), should have no suspend until date" );

# Add a new hold for the borrower whose hold we canceled earlier, this time at the bib level
AddReserve(
    $branch_1,
    $borrowernumbers[0],
    $biblionumber,
    my $bibitems = q{},
    my $priority,
    my $resdate,
    my $expdate,
    my $notes = q{},
    $title,
    my $checkitem,
    my $found,
);
$patron = Koha::Patrons->find( $borrowernumber );
$holds = $patron->holds;
my $reserveid = Koha::Holds->search({ biblionumber => $bibnum, borrowernumber => $borrowernumbers[0] })->next->reserve_id;
ModReserveMinusPriority( $itemnumber, $reserveid );
$holds = $patron->holds;
is( $holds->next->itemnumber, $itemnumber, "Test ModReserveMinusPriority()" );

$holds = $biblio->holds;
$hold = $holds->next;
AlterPriority( 'top', $hold->reserve_id, undef, 2, 1, 6 );
$hold = Koha::Holds->find( $reserveid );
is( $hold->priority, '1', "Test AlterPriority(), move to top" );

AlterPriority( 'down', $hold->reserve_id, undef, 2, 1, 6 );
$hold = Koha::Holds->find( $reserveid );
is( $hold->priority, '2', "Test AlterPriority(), move down" );

AlterPriority( 'up', $hold->reserve_id, 1, 3, 1, 6 );
$hold = Koha::Holds->find( $reserveid );
is( $hold->priority, '1', "Test AlterPriority(), move up" );

AlterPriority( 'bottom', $hold->reserve_id, undef, 2, 1, 6 );
$hold = Koha::Holds->find( $reserveid );
is( $hold->priority, '6', "Test AlterPriority(), move to bottom" );

# Regression test for bug 2394
#
# If IndependentBranches is ON and canreservefromotherbranches is OFF,
# a patron is not permittedo to request an item whose homebranch (i.e.,
# owner of the item) is different from the patron's own library.
# However, if canreservefromotherbranches is turned ON, the patron can
# create such hold requests.
#
# Note that canreservefromotherbranches has no effect if
# IndependentBranches is OFF.

my ($foreign_bibnum, $foreign_title, $foreign_bibitemnum) = create_helper_biblio('DUMMY');
my ($foreign_item_bibnum, $foreign_item_bibitemnum, $foreign_itemnumber)
  = AddItem({ homebranch => $branch_2, holdingbranch => $branch_2 } , $foreign_bibnum);
$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed, holds_per_record)
      VALUES (?, ?, ?, ?, ?)},
    {},
    '*', '*', '*', 25, 99
);
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed, holds_per_record)
      VALUES (?, ?, ?, ?, ?)},
    {},
    '*', '*', 'CANNOT', 0, 99
);

# make sure some basic sysprefs are set
t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
t::lib::Mocks::mock_preference('item-level_itypes', 1);

# if IndependentBranches is OFF, a $branch_1 patron can reserve an $branch_2 item
t::lib::Mocks::mock_preference('IndependentBranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber)->{status} eq 'OK',
    '$branch_1 patron allowed to reserve $branch_2 item with IndependentBranches OFF (bug 2394)'
);

# if IndependentBranches is OFF, a $branch_1 patron cannot reserve an $branch_2 item
t::lib::Mocks::mock_preference('IndependentBranches', 1);
t::lib::Mocks::mock_preference('canreservefromotherbranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber)->{status} eq 'cannotReserveFromOtherBranches',
    '$branch_1 patron NOT allowed to reserve $branch_2 item with IndependentBranches ON ... (bug 2394)'
);

# ... unless canreservefromotherbranches is ON
t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber)->{status} eq 'OK',
    '... unless canreservefromotherbranches is ON (bug 2394)'
);

{
    # Regression test for bug 11336 # Test if ModReserve correctly recalculate the priorities
    ($bibnum, $title, $bibitemnum) = create_helper_biblio('DUMMY');
    ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
    my $reserveid1 = AddReserve($branch_1, $borrowernumbers[0], $bibnum, '', 1);
    ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
    my $reserveid2 = AddReserve($branch_1, $borrowernumbers[1], $bibnum, '', 2);
    ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
    my $reserveid3 = AddReserve($branch_1, $borrowernumbers[2], $bibnum, '', 3);
    my $hhh = Koha::Holds->search({ biblionumber => $bibnum });
    my $hold3 = Koha::Holds->find( $reserveid3 );
    is( $hold3->priority, 3, "The 3rd hold should have a priority set to 3" );
    ModReserve({ reserve_id => $reserveid1, rank => 'del' });
    ModReserve({ reserve_id => $reserveid2, rank => 'del' });
    is( $hold3->discard_changes->priority, 1, "After ModReserve, the 3rd reserve becomes the first on the waiting list" );
}

ModItem({ damaged => 1 }, $item_bibnum, $itemnumber);
t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 1 );
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status}, 'OK', "Patron can reserve damaged item with AllowHoldsOnDamagedItems enabled" );
ok( defined( ( CheckReserves($itemnumber) )[1] ), "Hold can be trapped for damaged item with AllowHoldsOnDamagedItems enabled" );

$hold = Koha::Hold->new(
    {
        borrowernumber => $borrowernumbers[0],
        itemnumber     => $itemnumber,
        biblionumber   => $item_bibnum,
    }
)->store();
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'itemAlreadyOnHold',
    "Patron cannot place a second item level hold for a given item" );
$hold->delete();

t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 0 );
ok( CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status} eq 'damaged', "Patron cannot reserve damaged item with AllowHoldsOnDamagedItems disabled" );
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for damaged item with AllowHoldsOnDamagedItems disabled" );

# Regression test for bug 9532
($bibnum, $title, $bibitemnum) = create_helper_biblio('CANNOT');
($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1, itype => 'CANNOT' } , $bibnum);
AddReserve(
    $branch_1,
    $borrowernumbers[0],
    $bibnum,
    '',
    1,
);
is(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status}, 'tooManyReserves',
    "cannot request item if policy that matches on item-level item type forbids it"
);
ModItem({ itype => 'CAN' }, $item_bibnum, $itemnumber);
ok(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status} eq 'OK',
    "can request item if policy that matches on item type allows it"
);

t::lib::Mocks::mock_preference('item-level_itypes', 0);
ModItem({ itype => undef }, $item_bibnum, $itemnumber);
ok(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status} eq 'tooManyReserves',
    "cannot request item if policy that matches on bib-level item type forbids it (bug 9532)"
);


# Test branch item rules

$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)},
    {},
    '*', '*', '*', 25
);
$dbh->do('DELETE FROM branch_item_rules');
$dbh->do('DELETE FROM default_branch_circ_rules');
$dbh->do('DELETE FROM default_branch_item_rules');
$dbh->do('DELETE FROM default_circ_rules');
$dbh->do(q{
    INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
    VALUES (?, ?, ?, ?)
}, {}, $branch_1, 'CANNOT', 0, 'homebranch');
$dbh->do(q{
    INSERT INTO branch_item_rules (branchcode, itemtype, holdallowed, returnbranch)
    VALUES (?, ?, ?, ?)
}, {}, $branch_1, 'CAN', 1, 'homebranch');
($bibnum, $title, $bibitemnum) = create_helper_biblio('CANNOT');
($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem(
    { homebranch => $branch_1, holdingbranch => $branch_1, itype => 'CANNOT' } , $bibnum);
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status}, 'notReservable',
    "CanItemBeReserved should return 'notReservable'");

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem(
    { homebranch => $branch_2, holdingbranch => $branch_1, itype => 'CAN' } , $bibnum);
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status},
    'cannotReserveFromOtherBranches',
    "CanItemBeReserved should return 'cannotReserveFromOtherBranches'");

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem(
    { homebranch => $branch_1, holdingbranch => $branch_1, itype => 'CAN' } , $bibnum);
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status}, 'OK',
    "CanItemBeReserved should return 'OK'");

# Bug 12632
t::lib::Mocks::mock_preference( 'item-level_itypes',     1 );
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

$dbh->do('DELETE FROM reserves');
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM items');
$dbh->do('DELETE FROM biblio');

( $bibnum, $title, $bibitemnum ) = create_helper_biblio('ONLY1');
( $item_bibnum, $item_bibitemnum, $itemnumber )
    = AddItem( { homebranch => $branch_1, holdingbranch => $branch_1 }, $bibnum );

$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed, holds_per_record)
      VALUES (?, ?, ?, ?, ?)},
    {},
    '*', '*', 'ONLY1', 1, 99
);
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'OK', 'Patron can reserve item with hold limit of 1, no holds placed' );

my $res_id = AddReserve( $branch_1, $borrowernumbers[0], $bibnum, '', 1, );

is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'tooManyReserves', 'Patron cannot reserve item with hold limit of 1, 1 bib level hold placed' );

subtest 'Test max_holds per library/patron category' => sub {
    plan tests => 6;

    $dbh->do('DELETE FROM reserves');
    $dbh->do('DELETE FROM issuingrules');
    $dbh->do('DELETE FROM circulation_rules');

    ( $bibnum, $title, $bibitemnum ) = create_helper_biblio('TEST');
    ( $item_bibnum, $item_bibitemnum, $itemnumber ) =
      AddItem( { homebranch => $branch_1, holdingbranch => $branch_1 },
        $bibnum );
    $dbh->do(
        q{
            INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed, holds_per_record)
            VALUES (?, ?, ?, ?, ?)
        },
        {},
        '*', '*', 'TEST', 99, 99
    );
    AddReserve( $branch_1, $borrowernumbers[0], $bibnum, '', 1, );
    AddReserve( $branch_1, $borrowernumbers[0], $bibnum, '', 1, );
    AddReserve( $branch_1, $borrowernumbers[0], $bibnum, '', 1, );

    my $count =
      Koha::Holds->search( { borrowernumber => $borrowernumbers[0] } )->count();
    is( $count, 3, 'Patron now has 3 holds' );

    my $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'OK', 'Patron can place hold with no borrower circ rules' );

    my $rule_all = Koha::CirculationRules->set_rule(
        {
            categorycode => $category->{categorycode},
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'max_holds',
            rule_value   => 3,
        }
    );

    my $rule_branch = Koha::CirculationRules->set_rule(
        {
            branchcode   => $branch_1,
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rule_name    => 'max_holds',
            rule_value   => 5,
        }
    );

    $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'OK', 'Patron can place hold with branch/category rule of 5, category rule of 3' );

    $rule_branch->delete();

    $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'tooManyReserves', 'Patron cannot place hold with only a category rule of 3' );

    $rule_all->delete();
    $rule_branch->rule_value(3);
    $rule_branch->store();

    $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'tooManyReserves', 'Patron cannot place hold with only a branch/category rule of 3' );

    $rule_branch->rule_value(5);
    $rule_branch->update();
    $rule_branch->rule_value(5);
    $rule_branch->store();

    $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'OK', 'Patron can place hold with branch/category rule of 5, category rule of 5' );
};

subtest 'Pickup location availability tests' => sub {
    plan tests => 3;

    my ( $bibnum, $title, $bibitemnum ) = create_helper_biblio('ONLY1');
    my ( $item_bibnum, $item_bibitemnum, $itemnumber )
    = AddItem( { homebranch => $branch_1, holdingbranch => $branch_1 }, $bibnum );
    #Add a default rule to allow some holds
    $dbh->do(
        q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed, holds_per_record)
          VALUES (?, ?, ?, ?, ?)},
        {},
        '*', '*', '*', 25, 99
    );
    my $item = Koha::Items->find($itemnumber);
    my $branch_to = $builder->build({ source => 'Branch' })->{ branchcode };
    my $library = Koha::Libraries->find($branch_to);
    my $patron = $builder->build({ source => 'Borrower' })->{ borrowernumber };

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    $library->pickup_location('1')->store;
    is(CanItemBeReserved($patron, $item->itemnumber, $branch_to)->{status},
       'OK', 'Library is a pickup location');
    $library->pickup_location('0')->store;
    is(CanItemBeReserved($patron, $item->itemnumber, $branch_to)->{status},
       'libraryNotPickupLocation', 'Library is not a pickup location');
    is(CanItemBeReserved($patron, $item->itemnumber, 'nonexistent')->{status},
       'libraryNotFound', 'Cannot set unknown library as pickup location');
};

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $itemtype = shift;
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
        MARC::Field->new('942', ' ', ' ', c => $itemtype),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
