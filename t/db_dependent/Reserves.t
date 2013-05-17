#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 6;
use MARC::Record;

use C4::Branch;
use C4::Biblio;
use C4::Items;
use C4::Members;

BEGIN {
    use_ok('C4::Reserves');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Setup Test------------------------
# Helper biblio.
diag("\nCreating biblio instance for testing.");
my $bib = MARC::Record->new();
my $title = 'Silence in the library';
$bib->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
    MARC::Field->new('245', ' ', ' ', a => $title),
);
my ($bibnum, $bibitemnum);
($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
# Helper item for that biblio.
diag("Creating item instance for testing.");
my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);

# Modify item; setting barcode.
my $testbarcode = '97531';
ModItem({ barcode => $testbarcode }, $bibnum, $itemnumber);

# Create a borrower
my %data = (
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'S',
    branchcode => 'CPL',
);
my $borrowernumber = AddMember(%data);
my $borrower = GetMember( borrowernumber => $borrowernumber );
my $biblionumber   = $bibnum;
my $barcode        = $testbarcode;

my $constraint     = 'a';
my $bibitems       = '';
my $priority       = '1';
my $resdate        = undef;
my $expdate        = undef;
my $notes          = '';
my $checkitem      = undef;
my $found          = undef;

my @branches = GetBranchesLoop();
my $branch = $branches[0][0]{value};

AddReserve($branch,    $borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title,      $checkitem, $found);

my ($status, $reserve, $all_reserves) = CheckReserves($itemnumber, $barcode);

is($status, "Reserved", "CheckReserves Test 1");

($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
is($status, "Reserved", "CheckReserves Test 2");

($status, $reserve, $all_reserves) = CheckReserves(undef, $barcode);
is($status, "Reserved", "CheckReserves Test 3");

my $ReservesControlBranch = C4::Context->preference('ReservesControlBranch');
C4::Context->set_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
ok(
    'ItemHomeLib' eq GetReservesControlBranch(
        { homebranch => 'ItemHomeLib' },
        { branchcode => 'PatronHomeLib' }
    ), "GetReservesControlBranch returns item home branch when set to ItemHomeLibrary"
);
C4::Context->set_preference( 'ReservesControlBranch', 'PatronLibrary' );
ok(
    'PatronHomeLib' eq GetReservesControlBranch(
        { homebranch => 'ItemHomeLib' },
        { branchcode => 'PatronHomeLib' }
    ), "GetReservesControlBranch returns patron home branch when set to PatronLibrary"
);
C4::Context->set_preference( 'ReservesControlBranch', $ReservesControlBranch );
