#!/usr/bin/perl

use strict;
use warnings;
use C4::Branch;

use Test::More tests => 19;
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


my ($count, $reserves) = GetReservesFromBiblionumber($biblionumber);
is( $count, $borrowers_count, "Test GetReserves()" );


my ( $reservedate, $borrowernumber, $branchcode, $reserve_id ) = GetReservesFromItemnumber($itemnumber);
ok($reserve_id, "Test GetReservesFromItemnumber()");


my ( $reserve ) = GetReservesFromBorrowernumber($borrowernumbers[0]);
ok( $reserve->{'borrowernumber'} eq $borrowernumbers[0], "Test GetReservesFromBorrowernumber()");


ok( GetReserveCount( $borrowernumbers[0] ), "Test GetReserveCount()" );


CancelReserve({ 'reserve_id' => $reserve_id });
($count, $reserves) = GetReservesFromBiblionumber($biblionumber);
ok( $count == $borrowers_count - 1, "Test CancelReserve()" );


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


($count, $reserves) = GetReservesFromBiblionumber($biblionumber,1);
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
