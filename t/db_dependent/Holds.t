#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;
use C4::Branch;

use Test::More tests => 29;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Members;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $borrowers_count = 5;

# Setup Test------------------------
# Helper biblio.
diag("Creating biblio instance for testing.");
my ($bibnum, $title, $bibitemnum) = create_helper_biblio();

# Helper item for that biblio.
diag("Creating item instance for testing.");
my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);

# Create some borrowers
my @borrowernumbers;
foreach (1..$borrowers_count) {
    my $borrowernumber = AddMember(
        firstname =>  'my firstname',
        surname => 'my surname ' . $_,
        categorycode => 'S',
        branchcode => 'CPL',
    );
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber   = $bibnum;

my @branches = GetBranchesLoop();
my $branch = $branches[0][0]{value};

# Create five item level holds
foreach my $borrowernumber ( @borrowernumbers ) {
    AddReserve(
        $branch,
        $borrowernumber,
        $biblionumber,
        my $constraint = 'a',
        my $bibitems = q{},
        my $priority,
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


my ( $reservedate, $borrowernumber, $branchcode, $reserve_id ) = GetReservesFromItemnumber($itemnumber);
ok($reserve_id, "Test GetReservesFromItemnumber()");


my ( $reserve ) = GetReservesFromBorrowernumber($borrowernumbers[0]);
ok( $reserve->{'borrowernumber'} eq $borrowernumbers[0], "Test GetReservesFromBorrowernumber()");


ok( GetReserveCount( $borrowernumbers[0] ), "Test GetReserveCount()" );


CancelReserve({ 'reserve_id' => $reserve_id });
$reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber });
is( scalar(@$reserves), $borrowers_count - 1, "Test CancelReserve()" );


( $reservedate, $borrowernumber, $branchcode, $reserve_id ) = GetReservesFromItemnumber($itemnumber);
ModReserve({
    reserve_id    => $reserve_id,
    rank          => '4',
    branchcode    => $branch,
    itemnumber    => $itemnumber,
    suspend_until => C4::Dates->new("2013-01-01","iso")->output(),
});
$reserve = GetReserve( $reserve_id );
ok( $reserve->{'priority'} eq '4', "Test GetReserve(), priority changed correctly" );
ok( $reserve->{'suspend'}, "Test GetReserve(), suspend hold" );
ok( $reserve->{'suspend_until'} eq '2013-01-01 00:00:00', "Test GetReserve(), suspend until date" );

ToggleSuspend( $reserve_id );
$reserve = GetReserve( $reserve_id );
ok( !$reserve->{'suspend'}, "Test ToggleSuspend(), no date" );

ToggleSuspend( $reserve_id, '2012-01-01' );
$reserve = GetReserve( $reserve_id );
ok( $reserve->{'suspend_until'} eq '2012-01-01 00:00:00', "Test ToggleSuspend(), with date" );

AutoUnsuspendReserves();
$reserve = GetReserve( $reserve_id );
ok( !$reserve->{'suspend'}, "Test AutoUnsuspendReserves()" );

# Add a new hold for the borrower whose hold we canceled earlier, this time at the bib level
AddReserve(
    $branch,
    $borrowernumber,
    $biblionumber,
    my $constraint = 'a',
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
ok( $reserve->{'priority'} eq '1', "Test AlterPriority(), move to top" );

AlterPriority( 'down', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
ok( $reserve->{'priority'} eq '2', "Test AlterPriority(), move down" );

AlterPriority( 'up', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
ok( $reserve->{'priority'} eq '1', "Test AlterPriority(), move up" );

AlterPriority( 'bottom', $reserve->{'reserve_id'} );
$reserve = GetReserve( $reserve->{'reserve_id'} );
ok( $reserve->{'priority'} eq '5', "Test AlterPriority(), move to bottom" );

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

my ($foreign_bibnum, $foreign_title, $foreign_bibitemnum) = create_helper_biblio();
my ($foreign_item_bibnum, $foreign_item_bibitemnum, $foreign_itemnumber)
  = AddItem({ homebranch => 'MPL', holdingbranch => 'MPL' } , $foreign_bibnum);
$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)}, 
    {},
    '*', '*', '*', 25
);

# make sure some basic sysprefs are set
t::lib::Mocks::mock_preference('ReservesControlBranch', 'homebranch');
t::lib::Mocks::mock_preference('item-level_itypes', 1);

# if IndependentBranches is OFF, a CPL patron can reserve an MPL item
t::lib::Mocks::mock_preference('IndependentBranches', 0);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    'CPL patron allowed to reserve MPL item with IndependentBranches OFF (bug 2394)'
);

# if IndependentBranches is OFF, a CPL patron cannot reserve an MPL item
t::lib::Mocks::mock_preference('IndependentBranches', 1);
t::lib::Mocks::mock_preference('canreservefromotherbranches', 0);
ok(
    ! CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    'CPL patron NOT allowed to reserve MPL item with IndependentBranches ON ... (bug 2394)'
);

# ... unless canreservefromotherbranches is ON
t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
ok(
    CanItemBeReserved($borrowernumbers[0], $foreign_itemnumber),
    '... unless canreservefromotherbranches is ON (bug 2394)'
);

# Regression test for bug 11336
($bibnum, $title, $bibitemnum) = create_helper_biblio();
my ( $hold1, $hold2 );
($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
AddReserve(
    $branch,
    $borrowernumbers[0],
    $bibnum,
    'a',
    '',
    1,
);

my $reserveid1 = C4::Reserves::GetReserveId(
    {
        biblionumber => $bibnum,
        borrowernumber => $borrowernumbers[0]
    }
);

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
AddReserve(
    $branch,
    $borrowernumbers[1],
    $bibnum,
    'a',
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

($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
AddReserve(
    $branch,
    $borrowernumbers[0],
    $bibnum,
    'a',
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
C4::Context->set_preference( 'AllowHoldsOnDamagedItems', 1 );
ok( CanItemBeReserved( $borrowernumbers[0], $itemnumber), "Patron can reserve damaged item with AllowHoldsOnDamagedItems enabled" );
ok( defined( ( CheckReserves($itemnumber) )[1] ), "Hold can be trapped for damaged item with AllowHoldsOnDamagedItems enabled" );
C4::Context->set_preference( 'AllowHoldsOnDamagedItems', 0 );
ok( !CanItemBeReserved( $borrowernumbers[0], $itemnumber), "Patron cannot reserve damaged item with AllowHoldsOnDamagedItems disabled" );
ok( !defined( ( CheckReserves($itemnumber) )[1] ), "Hold cannot be trapped for damaged item with AllowHoldsOnDamagedItems disabled" );


# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
