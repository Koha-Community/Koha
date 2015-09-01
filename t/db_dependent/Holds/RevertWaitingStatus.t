#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;
use C4::Branch;

use Test::More tests => 3;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Reserves;

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM old_reserves");

local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
*C4::Context::userenv = \&Mock_userenv;

sub Mock_userenv {
    my $userenv = { flags => 1, id => '1', branch => 'CPL' };
    return $userenv;
}

my $borrowers_count = 3;

# Setup Test------------------------
# Helper biblio.
diag("Creating biblio instance for testing.");
my ( $bibnum, $title, $bibitemnum ) = create_helper_biblio();

# Helper item for that biblio.
diag("Creating item instance for testing.");
my $item_barcode = 'my_barcode';
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
    { homebranch => 'CPL', holdingbranch => 'CPL', barcode => $item_barcode },
    $bibnum );

# Create some borrowers
my @borrowernumbers;
foreach my $i ( 1 .. $borrowers_count ) {
    my $borrowernumber = AddMember(
        firstname    => 'my firstname',
        surname      => 'my surname ' . $i,
        categorycode => 'S',
        branchcode   => 'CPL',
    );
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber = $bibnum;

my @branches = GetBranchesLoop();
my $branch   = $branches[0][0]{value};

# Create five item level holds
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        $branch,
        $borrowernumber,
        $biblionumber,
        my $bibitems   = q{},
        my $priority,
        my $resdate,
        my $expdate,
        my $notes = q{},
        $title,
        my $checkitem,
        my $found,
    );
}

ModReserveAffect( $itemnumber, $borrowernumbers[0] );
C4::Circulation::AddIssue( GetMember( borrowernumber => $borrowernumbers[1] ),
    $item_barcode, my $datedue, my $cancelreserve = 'revert' );

my $priorities = $dbh->selectall_arrayref(
    "SELECT priority FROM reserves ORDER BY priority ASC");
ok( scalar @$priorities == 2,   'Only 2 holds remain in the reserves table' );
ok( $priorities->[0]->[0] == 1, 'First hold has a priority of 1' );
ok( $priorities->[1]->[0] == 2, 'Second hold has a priority of 2' );

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
