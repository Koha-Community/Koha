#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;
use C4::Branch;

use Test::More tests => 6;
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
my ( $bibnum, $title, $bibitemnum ) = create_helper_biblio();

# Helper item for that biblio.
diag("Creating item instance for testing.");
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) =
  AddItem( { homebranch => 'MPL', holdingbranch => 'CPL' }, $bibnum );

my @branchcodes = qw{XXX RPL CPL MPL CPL MPL};

# Create some borrowers
diag("Creating borrowers.");
my @borrowernumbers;
foreach ( 1 .. $borrowers_count ) {
    my $borrowernumber = AddMember(
        firstname    => 'my firstname',
        surname      => 'my surname ' . $_,
        categorycode => 'S',
        branchcode   => $branchcodes[$_],
    );
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber = $bibnum;

my @branches = GetBranchesLoop();
my $branch   = $branches[0][0]{value};

# Create five item level holds
diag("Creating holds.");
my $i = 1;
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        $branchcodes[$i],
        $borrowernumber,
        $biblionumber,
        my $constraint = 'a',
        my $bibitems   = q{},
        my $priority = $i,
        my $resdate,
        my $expdate,
        my $notes = q{},
        $title,
        my $checkitem,
        my $found,
    );

    $i++;
}

my ($status, $reserve, $all_reserves);

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 0 );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[0], "Received expected results with LocalHoldsPriority disabled" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriority', 1 );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with PickupLibrary/homebranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'PickupLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[1], "Received expected results with PickupLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'holdingbranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[1], "Received expected results with HomeLibrary/holdingbranch" );

t::lib::Mocks::mock_preference( 'LocalHoldsPriorityPatronControl', 'HomeLibrary' );
t::lib::Mocks::mock_preference( 'LocalHoldsPriorityItemControl', 'homebranch' );
($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok( $reserve->{borrowernumber} eq $borrowernumbers[2], "Received expected results with HomeLibrary/homebranch" );

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib   = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
        MARC::Field->new( '245', ' ', ' ', a => $title ),
    );
    return ( $bibnum, $title, $bibitemnum ) = AddBiblio( $bib, '' );
}
