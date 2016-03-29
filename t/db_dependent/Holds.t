#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use C4::Branch;

use Test::More tests => 60;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Calendar;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Holds;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $dbh     = C4::Context->dbh;

# Create two random branches
my $branch_1 = $builder->build({ source => 'Branch' })->{ branchcode };
my $branch_2 = $builder->build({ source => 'Branch' })->{ branchcode };

# This test assumes we have a category S. This statement helps.
$builder->build({
    source => 'Category',
    value  => { categorycode => 'S', category_type => 'S' },
});

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
    my $borrowernumber = AddMember(
        firstname =>  'my firstname',
        surname => 'my surname ' . $_,
        categorycode => 'S',
        branchcode => $branch_1,
    );
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

my $reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber });
is( scalar(@$reserves), $borrowers_count, "Test GetReserves()" );

is( $reserves->[0]->{priority}, 1, "Reserve 1 has a priority of 1" );
is( $reserves->[1]->{priority}, 2, "Reserve 2 has a priority of 2" );
is( $reserves->[2]->{priority}, 3, "Reserve 3 has a priority of 3" );
is( $reserves->[3]->{priority}, 4, "Reserve 4 has a priority of 4" );
is( $reserves->[4]->{priority}, 5, "Reserve 5 has a priority of 5" );

my ( $reservedate, $borrowernumber, $branch_1code, $reserve_id ) = GetReservesFromItemnumber($itemnumber);
is( $reservedate, output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 }), "GetReservesFromItemnumber should return a valid reserve date");
is( $borrowernumber, $borrowernumbers[0], "GetReservesFromItemnumber should return a valid borrowernumber");
is( $branch_1code, $branch_1, "GetReservesFromItemnumber should return a valid branchcode");
ok($reserve_id, "Test GetReservesFromItemnumber()");

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

my ( $reserve ) = GetReservesFromBorrowernumber($borrowernumbers[0]);
ok( $reserve->{'borrowernumber'} eq $borrowernumbers[0], "Test GetReservesFromBorrowernumber()");


ok( GetReserveCount( $borrowernumbers[0] ), "Test GetReserveCount()" );


CancelReserve({ 'reserve_id' => $reserve_id });
$reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber });
is( scalar(@$reserves), $borrowers_count - 1, "Test CancelReserve()" );


( $reservedate, $borrowernumber, $branch_1code, $reserve_id ) = GetReservesFromItemnumber($itemnumber);
ModReserve({
    reserve_id    => $reserve_id,
    rank          => '4',
    branchcode    => $branch_1,
    itemnumber    => $itemnumber,
    suspend_until => output_pref( { dt => dt_from_string( "2013-01-01", "iso" ), dateonly => 1 } ),
});

$reserve = GetReserve( $reserve_id );
ok( $reserve->{'priority'} eq '4', "Test GetReserve(), priority changed correctly" );
ok( $reserve->{'suspend'}, "Test GetReserve(), suspend hold" );
is( $reserve->{'suspend_until'}, '2013-01-01 00:00:00', "Test GetReserve(), suspend until date" );

ToggleSuspend( $reserve_id );
$reserve = GetReserve( $reserve_id );
ok( !$reserve->{'suspend'}, "Test ToggleSuspend(), no date" );

ToggleSuspend( $reserve_id, '2012-01-01' );
$reserve = GetReserve( $reserve_id );
is( $reserve->{'suspend_until'}, '2012-01-01 00:00:00', "Test ToggleSuspend(), with date" );

AutoUnsuspendReserves();
$reserve = GetReserve( $reserve_id );
ok( !$reserve->{'suspend'}, "Test AutoUnsuspendReserves()" );

SuspendAll(
    borrowernumber => $borrowernumber,
    biblionumber   => $biblionumber,
    suspend => 1,
    suspend_until => '2012-01-01',
);
$reserve = GetReserve( $reserve_id );
is( $reserve->{'suspend'}, 1, "Test SuspendAll()" );
is( $reserve->{'suspend_until'}, '2012-01-01 00:00:00', "Test SuspendAll(), with date" );

SuspendAll(
    borrowernumber => $borrowernumber,
    biblionumber   => $biblionumber,
    suspend => 0,
);
$reserve = GetReserve( $reserve_id );
is( $reserve->{'suspend'}, 0, "Test resuming with SuspendAll()" );
is( $reserve->{'suspend_until'}, undef, "Test resuming with SuspendAll(), should have no suspend until date" );

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
( $reserve ) = GetReservesFromBorrowernumber($borrowernumber);
my $reserveid = C4::Reserves::GetReserveId(
    {
        biblionumber => $biblionumber,
        borrowernumber => $borrowernumber
    }
);
is( $reserveid, $reserve->{reserve_id}, "Test GetReserveId" );
ModReserveMinusPriority( $itemnumber, $reserve->{'reserve_id'} );
( $reserve ) = GetReservesFromBorrowernumber($borrowernumber);
ok( $reserve->{'itemnumber'} eq $itemnumber, "Test ModReserveMinusPriority()" );


my $reserve2 = GetReserveInfo( $reserve->{'reserve_id'} );
ok( $reserve->{'reserve_id'} eq $reserve2->{'reserve_id'}, "Test GetReserveInfo()" );


$reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber, all_dates => 1 });
$reserve = $reserves->[1];
AlterPriority( 'top', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
is( $reserve->{'priority'}, '1', "Test AlterPriority(), move to top" );

AlterPriority( 'down', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
is( $reserve->{'priority'}, '2', "Test AlterPriority(), move down" );

AlterPriority( 'up', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
is( $reserve->{'priority'}, '1', "Test AlterPriority(), move up" );

AlterPriority( 'bottom', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
is( $reserve->{'priority'}, '5', "Test AlterPriority(), move to bottom" );

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
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)},
    {},
    '*', '*', '*', 25
);
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)},
    {},
    '*', '*', 'CANNOT', 0
);

# make sure some basic sysprefs are set
t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
t::lib::Mocks::mock_preference('item-level_itypes', 1);

# if IndependentBranches is OFF, a $branch_1 patron can reserve an $branch_2 item
t::lib::Mocks::mock_preference('IndependentBranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber) eq 'OK',
    '$branch_1 patron allowed to reserve $branch_2 item with IndependentBranches OFF (bug 2394)'
);

# if IndependentBranches is OFF, a $branch_1 patron cannot reserve an $branch_2 item
t::lib::Mocks::mock_preference('IndependentBranches', 1);
t::lib::Mocks::mock_preference('canreservefromotherbranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber) eq 'cannotReserveFromOtherBranches',
    '$branch_1 patron NOT allowed to reserve $branch_2 item with IndependentBranches ON ... (bug 2394)'
);

# ... unless canreservefromotherbranches is ON
t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber) eq 'OK',
    '... unless canreservefromotherbranches is ON (bug 2394)'
);

# Regression test for bug 11336
($bibnum, $title, $bibitemnum) = create_helper_biblio('DUMMY');
($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
AddReserve(
    $branch_1,
    $borrowernumbers[0],
    $bibnum,
    '',
    1,
);

my $reserveid1 = C4::Reserves::GetReserveId(
    {
        biblionumber => $bibnum,
        borrowernumber => $borrowernumbers[0]
    }
);

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
AddReserve(
    $branch_1,
    $borrowernumbers[1],
    $bibnum,
    '',
    2,
);
my $reserveid2 = C4::Reserves::GetReserveId(
    {
        biblionumber => $bibnum,
        borrowernumber => $borrowernumbers[1]
    }
);

CancelReserve({ reserve_id => $reserveid1 });

$reserve2 = GetReserve( $reserveid2 );
is( $reserve2->{priority}, 1, "After cancelreserve, the 2nd reserve becomes the first on the waiting list" );

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $branch_1, holdingbranch => $branch_1 } , $bibnum);
AddReserve(
    $branch_1,
    $borrowernumbers[0],
    $bibnum,
    '',
    2,
);
my $reserveid3 = C4::Reserves::GetReserveId(
    {
        biblionumber => $bibnum,
        borrowernumber => $borrowernumbers[0]
    }
);

my $reserve3 = GetReserve( $reserveid3 );
is( $reserve3->{priority}, 2, "New reserve for patron 0, the reserve has a priority = 2" );

ModReserve({ reserve_id => $reserveid2, rank => 'del' });
$reserve3 = GetReserve( $reserveid3 );
is( $reserve3->{priority}, 1, "After ModReserve, the 3rd reserve becomes the first on the waiting list" );

ModItem({ damaged => 1 }, $item_bibnum, $itemnumber);
t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 1 );
ok( CanItemBeReserved( $borrowernumbers[0], $itemnumber) eq 'OK', "Patron can reserve damaged item with AllowHoldsOnDamagedItems enabled" );
ok( defined( ( CheckReserves($itemnumber) )[1] ), "Hold can be trapped for damaged item with AllowHoldsOnDamagedItems enabled" );
t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 0 );
ok( CanItemBeReserved( $borrowernumbers[0], $itemnumber) eq 'damaged', "Patron cannot reserve damaged item with AllowHoldsOnDamagedItems disabled" );
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
ok(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber) eq 'tooManyReserves',
    "cannot request item if policy that matches on item-level item type forbids it"
);
ModItem({ itype => 'CAN' }, $item_bibnum, $itemnumber);
ok(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber) eq 'OK',
    "can request item if policy that matches on item type allows it"
);

t::lib::Mocks::mock_preference('item-level_itypes', 0);
ModItem({ itype => undef }, $item_bibnum, $itemnumber);
ok(
    CanItemBeReserved( $borrowernumbers[0], $itemnumber) eq 'tooManyReserves',
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
is(CanItemBeReserved($borrowernumbers[0], $itemnumber), 'notReservable',
    "CanItemBeReserved should returns 'notReservable'");

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem(
    { homebranch => $branch_2, holdingbranch => $branch_1, itype => 'CAN' } , $bibnum);
is(CanItemBeReserved($borrowernumbers[0], $itemnumber),
    'cannotReserveFromOtherBranches',
    "CanItemBeReserved should returns 'cannotReserveFromOtherBranches'");

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem(
    { homebranch => $branch_1, holdingbranch => $branch_1, itype => 'CAN' } , $bibnum);
is(CanItemBeReserved($borrowernumbers[0], $itemnumber), 'OK',
    "CanItemBeReserved should returns 'OK'");


# Test CancelExpiredReserves
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelay', 1);
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', 1);

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
$year += 1900;
$mon += 1;
$reserves = $dbh->selectall_arrayref('SELECT * FROM reserves', { Slice => {} });
$reserve = $reserves->[0];
my $calendar = C4::Calendar->new(branchcode => $reserve->{branchcode});
$calendar->insert_single_holiday(
    day         => $mday,
    month       => $mon,
    year        => $year,
    title       => 'Test',
    description => 'Test',
);
$reserve_id = $reserve->{reserve_id};
$dbh->do("UPDATE reserves SET waitingdate = DATE_SUB( NOW(), INTERVAL 5 DAY ), found = 'W', priority = 0 WHERE reserve_id = ?", undef, $reserve_id );
t::lib::Mocks::mock_preference('ExpireReservesOnHolidays', 0);
CancelExpiredReserves();
my $count = $dbh->selectrow_array("SELECT COUNT(*) FROM reserves WHERE reserve_id = ?", undef, $reserve_id );
is( $count, 1, "Waiting reserve beyond max pickup delay *not* canceled on holiday" );
t::lib::Mocks::mock_preference('ExpireReservesOnHolidays', 1);
CancelExpiredReserves();
$count = $dbh->selectrow_array("SELECT COUNT(*) FROM reserves WHERE reserve_id = ?", undef, $reserve_id );
is( $count, 0, "Waiting reserve beyond max pickup delay canceled on holiday" );

# Test expirationdate
$reserve = $reserves->[1];
$reserve_id = $reserve->{reserve_id};
$dbh->do("UPDATE reserves SET expirationdate = DATE_SUB( NOW(), INTERVAL 1 DAY ) WHERE reserve_id = ?", undef, $reserve_id );
CancelExpiredReserves();
$count = $dbh->selectrow_array("SELECT COUNT(*) FROM reserves WHERE reserve_id = ?", undef, $reserve_id );
is( $count, 0, "Reserve with manual expiration date canceled correctly" );

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
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)},
    {},
    '*', '*', 'ONLY1', 1
);
is( CanItemBeReserved( $borrowernumbers[0], $itemnumber ),
    'OK', 'Patron can reserve item with hold limit of 1, no holds placed' );

my $res_id = AddReserve( $branch_1, $borrowernumbers[0], $bibnum, '', 1, );

is( CanItemBeReserved( $borrowernumbers[0], $itemnumber ),
    'tooManyReserves', 'Patron cannot reserve item with hold limit of 1, 1 bib level hold placed' );


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
