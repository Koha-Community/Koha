#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;

use Test::More tests => 67;
use MARC::Record;

use C4::Biblio;
use C4::Calendar;
use C4::Items;
use C4::Reserves;

use Koha::Biblios;
use Koha::CirculationRules;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Holds;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Libraries;
use Koha::Library::Groups;
use Koha::Patrons;

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
$dbh->do('DELETE FROM circulation_rules');
my $insert_sth = $dbh->prepare('INSERT INTO itemtypes (itemtype) VALUES (?)');
$insert_sth->execute('CAN');
$insert_sth->execute('CANNOT');
$insert_sth->execute('DUMMY');
$insert_sth->execute('ONLY1');

# Setup Test------------------------
my $biblio = $builder->build_sample_biblio({ itemtype => 'DUMMY' });

# Create item instance for testing.
my $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber })->itemnumber;

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

# Create five item level holds
foreach my $borrowernumber ( @borrowernumbers ) {
    AddReserve(
        {
            branchcode     => $branch_1,
            borrowernumber => $borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => C4::Reserves::CalculatePriority( $biblio->biblionumber ),
            itemnumber     => $itemnumber,
        }
    );
}

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
    biblionumber  => $biblio->biblionumber,
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
    biblionumber   => $biblio->biblionumber,
    suspend => 1,
    suspend_until => '2012-01-01',
);
$hold = Koha::Holds->find( $reserve_id );
is( $hold->suspend, 1, "Test SuspendAll()" );
is( $hold->suspend_until, '2012-01-01 00:00:00', "Test SuspendAll(), with date" );

SuspendAll(
    borrowernumber => $borrowernumber,
    biblionumber   => $biblio->biblionumber,
    suspend => 0,
);
$hold = Koha::Holds->find( $reserve_id );
is( $hold->suspend, 0, "Test resuming with SuspendAll()" );
is( $hold->suspend_until, undef, "Test resuming with SuspendAll(), should have no suspend until date" );

# Add a new hold for the borrower whose hold we canceled earlier, this time at the bib level
    AddReserve(
        {
            branchcode     => $branch_1,
            borrowernumber => $borrowernumbers[0],
            biblionumber   => $biblio->biblionumber,
        }
    );

$patron = Koha::Patrons->find( $borrowernumber );
$holds = $patron->holds;
my $reserveid = Koha::Holds->search({ biblionumber => $biblio->biblionumber, borrowernumber => $borrowernumbers[0] })->next->reserve_id;
ModReserveMinusPriority( $itemnumber, $reserveid );
$holds = $patron->holds;
is( $holds->search({ itemnumber => $itemnumber })->count, 1, "Test ModReserveMinusPriority()" );

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

my $foreign_biblio = $builder->build_sample_biblio({ itemtype => 'DUMMY' });
my $foreign_itemnumber = $builder->build_sample_item({ library => $branch_2, biblionumber => $foreign_biblio->biblionumber })->itemnumber;
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed  => 25,
            holds_per_record => 99,
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => 'CANNOT',
        rules        => {
            reservesallowed  => 0,
            holds_per_record => 99,
        }
    }
);

# make sure some basic sysprefs are set
t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
t::lib::Mocks::mock_preference('item-level_itypes', 1);

# if IndependentBranches is OFF, a $branch_1 patron can reserve an $branch_2 item
t::lib::Mocks::mock_preference('IndependentBranches', 0);

is(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber)->{status}, 'OK',
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
    $biblio = $builder->build_sample_biblio({ itemtype => 'DUMMY' });
    $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber })->itemnumber;
    my $reserveid1 = AddReserve(
        {
            branchcode     => $branch_1,
            borrowernumber => $borrowernumbers[0],
            biblionumber   => $biblio->biblionumber,
            priority       => 1
        }
    );

    $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber })->itemnumber;
    my $reserveid2 = AddReserve(
        {
            branchcode     => $branch_1,
            borrowernumber => $borrowernumbers[1],
            biblionumber   => $biblio->biblionumber,
            priority       => 2
        }
    );

    $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber })->itemnumber;
    my $reserveid3 = AddReserve(
        {
            branchcode     => $branch_1,
            borrowernumber => $borrowernumbers[2],
            biblionumber   => $biblio->biblionumber,
            priority       => 3
        }
    );

    my $hhh = Koha::Holds->search({ biblionumber => $biblio->biblionumber });
    my $hold3 = Koha::Holds->find( $reserveid3 );
    is( $hold3->priority, 3, "The 3rd hold should have a priority set to 3" );
    ModReserve({ reserve_id => $reserveid1, rank => 'del' });
    ModReserve({ reserve_id => $reserveid2, rank => 'del' });
    is( $hold3->discard_changes->priority, 1, "After ModReserve, the 3rd reserve becomes the first on the waiting list" );
}

Koha::Items->find($itemnumber)->damaged(1)->store; # FIXME The $itemnumber is a bit confusing here
t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 1 );
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status}, 'OK', "Patron can reserve damaged item with AllowHoldsOnDamagedItems enabled" );
ok( defined( ( CheckReserves($itemnumber) )[1] ), "Hold can be trapped for damaged item with AllowHoldsOnDamagedItems enabled" );

$hold = Koha::Hold->new(
    {
        borrowernumber => $borrowernumbers[0],
        itemnumber     => $itemnumber,
        biblionumber   => $biblio->biblionumber,
    }
)->store();
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'itemAlreadyOnHold',
    "Patron cannot place a second item level hold for a given item" );
$hold->delete();

t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 0 );
ok( CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status} eq 'damaged', "Patron cannot reserve damaged item with AllowHoldsOnDamagedItems disabled" );
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for damaged item with AllowHoldsOnDamagedItems disabled" );

# Items that are not for loan, but holdable should not be trapped until they are available for loan
t::lib::Mocks::mock_preference( 'TrapHoldsOnOrder', 0 );
Koha::Items->find($itemnumber)->damaged(0)->notforloan(-1)->store;
Koha::Holds->search({ biblionumber => $biblio->id })->delete();
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber)->{status}, 'OK', "Patron can place hold on item that is not for loan but holdable ( notforloan < 0 )" );
$hold = Koha::Hold->new(
    {
        borrowernumber => $borrowernumbers[0],
        itemnumber     => $itemnumber,
        biblionumber   => $biblio->biblionumber,
        found          => undef,
        priority       => 1,
        reservedate    => dt_from_string,
        branchcode     => $branch_1,
    }
)->store();
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for item that is not for loan but holdable ( notforloan < 0 )" );
t::lib::Mocks::mock_preference( 'TrapHoldsOnOrder', 1 );
ok( defined( ( CheckReserves($itemnumber) )[1] ), "Hold is trapped for item that is not for loan but holdable ( notforloan < 0 )" );
t::lib::Mocks::mock_preference( 'SkipHoldTrapOnNotForLoanValue', '-1' );
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for item with notforloan value matching SkipHoldTrapOnNotForLoanValue" );
t::lib::Mocks::mock_preference( 'SkipHoldTrapOnNotForLoanValue', '-1|1' );
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for item with notforloan value matching SkipHoldTrapOnNotForLoanValue" );
$hold->delete();

# Regression test for bug 9532
$biblio = $builder->build_sample_biblio({ itemtype => 'CANNOT' });
$item = $builder->build_sample_item({ library => $branch_1, itype => 'CANNOT', biblionumber => $biblio->biblionumber});
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $borrowernumbers[0],
        biblionumber   => $biblio->biblionumber,
        priority       => 1,
    }
);
is(
    CanItemBeReserved( $borrowernumbers[0], $item->itemnumber)->{status}, 'tooManyReserves',
    "cannot request item if policy that matches on item-level item type forbids it"
);

$item->itype('CAN')->store;
ok(
    CanItemBeReserved( $borrowernumbers[0], $item->itemnumber)->{status} eq 'OK',
    "can request item if policy that matches on item type allows it"
);

t::lib::Mocks::mock_preference('item-level_itypes', 0);
$item->itype(undef)->store;
ok(
    CanItemBeReserved( $borrowernumbers[0], $item->itemnumber)->{status} eq 'tooManyReserves',
    "cannot request item if policy that matches on bib-level item type forbids it (bug 9532)"
);


# Test branch item rules

$dbh->do('DELETE FROM circulation_rules');
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed  => 25,
            holds_per_record => 99,
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => $branch_1,
        itemtype   => 'CANNOT',
        rules => {
            holdallowed => 0,
            returnbranch => 'homebranch',
        }
    }
);
Koha::CirculationRules->set_rules(
    {
        branchcode => $branch_1,
        itemtype   => 'CAN',
        rules => {
            holdallowed => 1,
            returnbranch => 'homebranch',
        }
    }
);
$biblio = $builder->build_sample_biblio({ itemtype => 'CANNOT' });
$itemnumber = $builder->build_sample_item({ library => $branch_1, itype => 'CANNOT', biblionumber => $biblio->biblionumber})->itemnumber;
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status}, 'notReservable',
    "CanItemBeReserved should return 'notReservable'");

t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
$itemnumber = $builder->build_sample_item({ library => $branch_2, itype => 'CAN', biblionumber => $biblio->biblionumber})->itemnumber;
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status},
    'cannotReserveFromOtherBranches',
    "CanItemBeReserved should use PatronLibrary rule when ReservesControlBranch set to 'PatronLibrary'");
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status},
    'OK',
    "CanItemBeReserved should use item home library rule when ReservesControlBranch set to 'ItemsHomeLibrary'");

$itemnumber = $builder->build_sample_item({ library => $branch_1, itype => 'CAN', biblionumber => $biblio->biblionumber})->itemnumber;
is(CanItemBeReserved($borrowernumbers[0], $itemnumber)->{status}, 'OK',
    "CanItemBeReserved should return 'OK'");

# Bug 12632
t::lib::Mocks::mock_preference( 'item-level_itypes',     1 );
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

$dbh->do('DELETE FROM reserves');
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM items');
$dbh->do('DELETE FROM biblio');

$biblio = $builder->build_sample_biblio({ itemtype => 'ONLY1' });
$itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber})->itemnumber;

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => 'ONLY1',
        rules        => {
            reservesallowed  => 1,
            holds_per_record => 99,
        }
    }
);
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'OK', 'Patron can reserve item with hold limit of 1, no holds placed' );

my $res_id = AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $borrowernumbers[0],
        biblionumber   => $biblio->biblionumber,
        priority       => 1,
    }
);

is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'tooManyReserves', 'Patron cannot reserve item with hold limit of 1, 1 bib level hold placed' );

    #results should be the same for both ReservesControlBranch settings
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber )->{status},
    'tooManyReserves', 'Patron cannot reserve item with hold limit of 1, 1 bib level hold placed' );
#reset for further tests
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

subtest 'Test max_holds per library/patron category' => sub {
    plan tests => 6;

    $dbh->do('DELETE FROM reserves');

    $biblio = $builder->build_sample_biblio;
    $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber})->itemnumber;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => $biblio->itemtype,
            rules        => {
                reservesallowed  => 99,
                holds_per_record => 99,
            }
        }
    );

    for ( 1 .. 3 ) {
        AddReserve(
            {
                branchcode     => $branch_1,
                borrowernumber => $borrowernumbers[0],
                biblionumber   => $biblio->biblionumber,
                priority       => 1,
            }
        );
    }

    my $count =
      Koha::Holds->search( { borrowernumber => $borrowernumbers[0] } )->count();
    is( $count, 3, 'Patron now has 3 holds' );

    my $ret = CanItemBeReserved( $borrowernumbers[0], $itemnumber );
    is( $ret->{status}, 'OK', 'Patron can place hold with no borrower circ rules' );

    my $rule_all = Koha::CirculationRules->set_rule(
        {
            categorycode => $category->{categorycode},
            branchcode   => undef,
            rule_name    => 'max_holds',
            rule_value   => 3,
        }
    );

    my $rule_branch = Koha::CirculationRules->set_rule(
        {
            branchcode   => $branch_1,
            categorycode => $category->{categorycode},
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
    plan tests => 4;

    $biblio = $builder->build_sample_biblio({ itemtype => 'ONLY1' });
    $itemnumber = $builder->build_sample_item({ library => $branch_1, biblionumber => $biblio->biblionumber})->itemnumber;
    #Add a default rule to allow some holds

    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                reservesallowed  => 25,
                holds_per_record => 99,
            }
        }
    );
    my $item = Koha::Items->find($itemnumber);
    my $branch_to = $builder->build({ source => 'Branch' })->{ branchcode };
    my $library = Koha::Libraries->find($branch_to);
    $library->pickup_location('1')->store;
    my $patron = $builder->build({ source => 'Borrower' })->{ borrowernumber };

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    $library->pickup_location('1')->store;
    is(CanItemBeReserved($patron, $item->itemnumber, $branch_to)->{status},
       'OK', 'Library is a pickup location');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $item->holdingbranch,
        toBranch => $branch_to,
        itemtype => $item->effective_itemtype,
    })->store;
    is(CanItemBeReserved($patron, $item->itemnumber, $branch_to)->{status},
       'cannotBeTransferred', 'Item cannot be transferred');
    $limit->delete;

    $library->pickup_location('0')->store;
    is(CanItemBeReserved($patron, $item->itemnumber, $branch_to)->{status},
       'libraryNotPickupLocation', 'Library is not a pickup location');
    is(CanItemBeReserved($patron, $item->itemnumber, 'nonexistent')->{status},
       'libraryNotFound', 'Cannot set unknown library as pickup location');
};

$schema->storage->txn_rollback;

subtest 'CanItemBeReserved / holds_per_day tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    Koha::Holds->search->delete;
    $dbh->do('DELETE FROM issues');
    Koha::Items->search->delete;
    Koha::Biblios->search->delete;

    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );

    # Create 3 biblios with items
    my $biblio_1 = $builder->build_sample_biblio({ itemtype => $itemtype->itemtype });
    my $itemnumber_1 = $builder->build_sample_item({ library => $library->branchcode, biblionumber => $biblio_1->biblionumber})->itemnumber;
    my $biblio_2 = $builder->build_sample_biblio({ itemtype => $itemtype->itemtype });
    my $itemnumber_2 = $builder->build_sample_item({ library => $library->branchcode, biblionumber => $biblio_2->biblionumber})->itemnumber;
    my $biblio_3 = $builder->build_sample_biblio({ itemtype => $itemtype->itemtype });
    my $itemnumber_3 = $builder->build_sample_item({ library => $library->branchcode, biblionumber => $biblio_3->biblionumber})->itemnumber;

    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => '*',
            branchcode   => '*',
            itemtype     => $itemtype->itemtype,
            rules        => {
                reservesallowed  => 1,
                holds_per_record => 99,
                holds_per_day    => 2
            }
        }
    );

    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_1 ),
        { status => 'OK' },
        'Patron can reserve item with hold limit of 1, no holds placed'
    );

    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_1->biblionumber,
            priority       => 1,
        }
    );

    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_1 ),
        { status => 'tooManyReserves', limit => 1 },
        'Patron cannot reserve item with hold limit of 1, 1 bib level hold placed'
    );

    # Raise reservesallowed to avoid tooManyReserves from it
    Koha::CirculationRules->set_rule(
        {

            categorycode => '*',
            branchcode   => '*',
            itemtype     => $itemtype->itemtype,
            rule_name  => 'reservesallowed',
            rule_value => 3,
        }
    );

    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can reserve item with 2 reserves daily cap'
    );

    # Add a second reserve
    my $res_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_2->biblionumber,
            priority       => 1,
        }
    );
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_2 ),
        { status => 'tooManyReservesToday', limit => 2 },
        'Patron cannot a third item with 2 reserves daily cap'
    );

    # Update last hold so reservedate is in the past, so 2 holds, but different day
    $hold = Koha::Holds->find($res_id);
    my $yesterday = dt_from_string() - DateTime::Duration->new( days => 1 );
    $hold->reservedate($yesterday)->store;

    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can reserve item with 2 bib level hold placed on different days, 2 reserves daily cap'
    );

    # Set holds_per_day to 0
    Koha::CirculationRules->set_rule(
        {

            categorycode => '*',
            branchcode   => '*',
            itemtype     => $itemtype->itemtype,
            rule_name  => 'holds_per_day',
            rule_value => 0,
        }
    );


    # Delete existing holds
    Koha::Holds->search->delete;
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_2 ),
        { status => 'tooManyReservesToday', limit => 0 },
        'Patron cannot reserve if holds_per_day is 0 (i.e. 0 is 0)'
    );

    Koha::CirculationRules->set_rule(
        {

            categorycode => '*',
            branchcode   => '*',
            itemtype     => $itemtype->itemtype,
            rule_name  => 'holds_per_day',
            rule_value => undef,
        }
    );

    Koha::Holds->search->delete;
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can reserve if holds_per_day is undef (i.e. undef is unlimited daily cap)'
    );
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_1->biblionumber,
            priority       => 1,
        }
    );
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_2->biblionumber,
            priority       => 1,
        }
    );

    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_3 ),
        { status => 'OK' },
        'Patron can reserve if holds_per_day is undef (i.e. undef is unlimited daily cap)'
    );
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio_3->biblionumber,
            priority       => 1,
        }
    );
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_3 ),
        { status => 'tooManyReserves', limit => 3 },
        'Unlimited daily holds, but reached reservesallowed'
    );
    #results should be the same for both ReservesControlBranch settings
    t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $itemnumber_3 ),
        { status => 'tooManyReserves', limit => 3 },
        'Unlimited daily holds, but reached reservesallowed'
    );

    $schema->storage->txn_rollback;
};

subtest 'CanItemBeReserved / branch_not_in_hold_group' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    # Cleanup database
    Koha::Holds->search->delete;
    $dbh->do('DELETE FROM issues');
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'reservesallowed',
            rule_value   => 25,
        }
    );

    Koha::Items->search->delete;
    Koha::Biblios->search->delete;

    # Create item types
    my $itemtype1 = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $itemtype2 = $builder->build_object( { class => 'Koha::ItemTypes' } );

    # Create libraries
    my $library1  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library3  = $builder->build_object( { class => 'Koha::Libraries' } );

    # Create library groups hierarchy
    my $rootgroup  = $builder->build_object( { class => 'Koha::Library::Groups', value => {ft_local_hold_group => 1} } );
    my $group1  = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library1->branchcode}} );
    my $group2  = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library2->branchcode} } );

    # Create 2 patrons
    my $patron1   = $builder->build_object( { class => 'Koha::Patrons', value => {branchcode => $library1->branchcode} } );
    my $patron3   = $builder->build_object( { class => 'Koha::Patrons', value => {branchcode => $library3->branchcode} } );

    # Create 3 biblios with items
    my $biblio_1 = $builder->build_sample_biblio({ itemtype => $itemtype1->itemtype });
    my $item_1   = $builder->build_sample_item(
        {
            biblionumber => $biblio_1->biblionumber,
            library      => $library1->branchcode
        }
    );
    my $biblio_2 = $builder->build_sample_biblio({ itemtype => $itemtype2->itemtype });
    my $item_2   = $builder->build_sample_item(
        {
            biblionumber => $biblio_2->biblionumber,
            library      => $library2->branchcode
        }
    );
    my $itemnumber_2 = $item_2->itemnumber;
    my $biblio_3 = $builder->build_sample_biblio({ itemtype => $itemtype1->itemtype });
    my $item_3   = $builder->build_sample_item(
        {
            biblionumber => $biblio_3->biblionumber,
            library      => $library1->branchcode
        }
    );

    # Test 1: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can place hold if no circ_rules where defined'
    );

    # Insert default circ rule of holds allowed only from local hold group for all libraries
    Koha::CirculationRules->set_rules(
        {
            branchcode => undef,
            itemtype   => undef,
            rules => {
                holdallowed => 3,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 2: Patron 1 can place hold
    is_deeply(
        CanItemBeReserved( $patron1->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can place hold because patron\'s home library is part of hold group'
    );

    # Test 3: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'branchNotInHoldGroup' },
        'Patron cannot place hold because patron\'s home library is not part of hold group'
    );

    # Insert default circ rule to "any" for library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 4: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can place hold if holdallowed is set to "any" for library 2'
    );

    # Update default circ rule to "hold group" for library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 3,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 5: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'branchNotInHoldGroup' },
        'Patron cannot place hold if holdallowed is set to "hold group" for library 2'
    );

    # Insert default item rule to "any" for itemtype 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 6: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can place hold if holdallowed is set to "any" for itemtype 2'
    );

    # Update default item rule to "hold group" for itemtype 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 3,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 7: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'branchNotInHoldGroup' },
        'Patron cannot place hold if holdallowed is set to "hold group" for itemtype 2'
    );

    # Insert branch item rule to "any" for itemtype 2 and library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 8: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'OK' },
        'Patron can place hold if holdallowed is set to "any" for itemtype 2 and library 2'
    );

    # Update branch item rule to "hold group" for itemtype 2 and library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 3,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 9: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2 ),
        { status => 'branchNotInHoldGroup' },
        'Patron cannot place hold if holdallowed is set to "hold group" for itemtype 2 and library 2'
    );

    $schema->storage->txn_rollback;

};

subtest 'CanItemBeReserved / pickup_not_in_hold_group' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    # Cleanup database
    Koha::Holds->search->delete;
    $dbh->do('DELETE FROM issues');
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'reservesallowed',
            rule_value   => 25,
        }
    );

    Koha::Items->search->delete;
    Koha::Biblios->search->delete;

    # Create item types
    my $itemtype1 = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $itemtype2 = $builder->build_object( { class => 'Koha::ItemTypes' } );

    # Create libraries
    my $library1  = $builder->build_object( { class => 'Koha::Libraries', value => {pickup_location => 1} } );
    my $library2  = $builder->build_object( { class => 'Koha::Libraries', value => {pickup_location => 1} } );
    my $library3  = $builder->build_object( { class => 'Koha::Libraries', value => {pickup_location => 1} } );

    # Create library groups hierarchy
    my $rootgroup  = $builder->build_object( { class => 'Koha::Library::Groups', value => {ft_local_hold_group => 1} } );
    my $group1  = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library1->branchcode}} );
    my $group2  = $builder->build_object( { class => 'Koha::Library::Groups', value => {parent_id => $rootgroup->id, branchcode => $library2->branchcode} } );

    # Create 2 patrons
    my $patron1   = $builder->build_object( { class => 'Koha::Patrons', value => {branchcode => $library1->branchcode} } );
    my $patron3   = $builder->build_object( { class => 'Koha::Patrons', value => {branchcode => $library3->branchcode} } );

    # Create 3 biblios with items
    my $biblio_1 = $builder->build_sample_biblio({ itemtype => $itemtype1->itemtype });
    my $item_1   = $builder->build_sample_item(
        {
            biblionumber => $biblio_1->biblionumber,
            library      => $library1->branchcode
        }
    );
    my $biblio_2 = $builder->build_sample_biblio({ itemtype => $itemtype2->itemtype });
    my $item_2   = $builder->build_sample_item(
        {
            biblionumber => $biblio_2->biblionumber,
            library      => $library2->branchcode
        }
    );
    my $itemnumber_2 = $item_2->itemnumber;
    my $biblio_3 = $builder->build_sample_biblio({ itemtype => $itemtype1->itemtype });
    my $item_3   = $builder->build_sample_item(
        {
            biblionumber => $biblio_3->biblionumber,
            library      => $library1->branchcode
        }
    );

    # Test 1: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'OK' },
        'Patron can place hold if no circ_rules where defined'
    );

    # Insert default circ rule of holds allowed only from local hold group for all libraries
    Koha::CirculationRules->set_rules(
        {
            branchcode => undef,
            itemtype   => undef,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    # Test 2: Patron 1 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library1->branchcode ),
        { status => 'OK' },
        'Patron can place hold because pickup location is part of hold group'
    );

    # Test 3: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'pickupNotInHoldGroup' },
        'Patron cannot place hold because pickup location is not part of hold group'
    );

    # Insert default circ rule to "any" for library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 4: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'OK' },
        'Patron can place hold if default_branch_circ_rules is set to "any" for library 2'
    );

    # Update default circ rule to "hold group" for library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    # Test 5: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'pickupNotInHoldGroup' },
        'Patron cannot place hold if hold_fulfillment_policy is set to "hold group" for library 2'
    );

    # Insert default item rule to "any" for itemtype 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 6: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'OK' },
        'Patron can place hold if hold_fulfillment_policy is set to "any" for itemtype 2'
    );

    # Update default item rule to "hold group" for itemtype 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    # Test 7: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'pickupNotInHoldGroup' },
        'Patron cannot place hold if hold_fulfillment_policy is set to "hold group" for itemtype 2'
    );

    # Insert branch item rule to "any" for itemtype 2 and library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    # Test 8: Patron 3 can place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'OK' },
        'Patron can place hold if hold_fulfillment_policy is set to "any" for itemtype 2 and library 2'
    );

    # Update branch item rule to "hold group" for itemtype 2 and library 2
    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => $itemtype2->itemtype,
            rules => {
                holdallowed => 2,
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    # Test 9: Patron 3 cannot place hold
    is_deeply(
        CanItemBeReserved( $patron3->borrowernumber, $itemnumber_2, $library3->branchcode ),
        { status => 'pickupNotInHoldGroup' },
        'Patron cannot place hold if hold_fulfillment_policy is set to "hold group" for itemtype 2 and library 2'
    );

    $schema->storage->txn_rollback;
};

subtest 'CanItemBeReserved rule precedence tests' => sub {

    plan tests => 3;

    t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
    $schema->storage->txn_begin;
    my $library  = $builder->build_object( { class => 'Koha::Libraries', value => {
        pickup_location => 1,
    }});
    my $item = $builder->build_sample_item({
        homebranch    => $library->branchcode,
        holdingbranch => $library->branchcode
    });
    my $item2 = $builder->build_sample_item({
        homebranch    => $library->branchcode,
        holdingbranch => $library->branchcode,
        itype         => $item->itype
    });
    my $patron   = $builder->build_object({ class => 'Koha::Patrons', value => {
        branchcode => $library->branchcode
    }});
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            rules        => {
                reservesallowed  => 1,
            }
        }
    );
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $item->itemnumber, $library->branchcode ),
        { status => 'OK' },
        'Patron of specified category can place 1 hold on specified itemtype'
    );
    my $hold = $builder->build_object({ class => 'Koha::Holds', value => {
        biblionumber   => $item2->biblionumber,
        itemnumber     => $item2->itemnumber,
        found          => undef,
        priority       => 1,
        branchcode     => $library->branchcode,
        borrowernumber => $patron->borrowernumber,
    }});
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $item->itemnumber, $library->branchcode ),
        { status => 'tooManyReserves', limit => 1 },
        'Patron of specified category can place 1 hold on specified itemtype, cannot place a second'
    );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $library->branchcode,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                reservesallowed  => 2,
            }
        }
    );
    is_deeply(
        CanItemBeReserved( $patron->borrowernumber, $item->itemnumber, $library->branchcode ),
        { status => 'OK' },
        'Patron of specified category can place 1 hold on specified itemtype if library rule for all types and categories set to 2'
    );

    $schema->storage->txn_rollback;

};
