#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 8;
use MARC::Record;

use C4::Branch;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Circulation;

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

###
### Regression test for bug 10272
###
my %requesters = ();
$requesters{'CPL'} = AddMember(
    branchcode   => 'CPL',
    categorycode => 'PT',
    surname      => 'borrower from CPL',
);
$requesters{'FPL'} = AddMember(
    branchcode   => 'FPL',
    categorycode => 'PT',
    surname      => 'borrower from FPL',
);
$requesters{'RPL'} = AddMember(
    branchcode   => 'RPL',
    categorycode => 'PT',
    surname      => 'borrower from RPL',
);

# Configure rules so that CPL allows only CPL patrons
# to request its items, while FPL will allow its items
# to fill holds from anywhere.

$dbh->do('DELETE FROM issuingrules');
$dbh->do('DELETE FROM branch_item_rules');
$dbh->do('DELETE FROM branch_borrower_circ_rules');
$dbh->do('DELETE FROM default_borrower_circ_rules');
$dbh->do('DELETE FROM default_branch_item_rules');
$dbh->do('DELETE FROM default_branch_circ_rules');
$dbh->do('DELETE FROM default_circ_rules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
      VALUES (?, ?, ?, ?)},
    {},
    '*', '*', '*', 25
);

# CPL allows only its own patrons to request its items
$dbh->do(
    q{INSERT INTO default_branch_circ_rules (branchcode, maxissueqty, holdallowed, returnbranch)
      VALUES (?, ?, ?, ?)},
    {},
    'CPL', 10, 1, 'homebranch',
);

# ... while FPL allows anybody to request its items
$dbh->do(
    q{INSERT INTO default_branch_circ_rules (branchcode, maxissueqty, holdallowed, returnbranch)
      VALUES (?, ?, ?, ?)},
    {},
    'FPL', 10, 2, 'homebranch',
);

# helper biblio for the bug 10272 regression test
my $bib2 = MARC::Record->new();
$bib2->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
    MARC::Field->new('245', ' ', ' ', a => $title),
);

# create one item belonging to FPL and one belonging to CPL
my ($bibnum2, $bibitemnum2) = AddBiblio($bib, '');
my ($itemnum_cpl, $itemnum_fpl);
(undef, undef, $itemnum_cpl) = AddItem({
        homebranch => 'CPL',
        holdingbranch => 'CPL',
        barcode => 'bug10272_CPL'
    } , $bibnum2);
(undef, undef, $itemnum_fpl) = AddItem({
        homebranch => 'FPL',
        holdingbranch => 'FPL',
        barcode => 'bug10272_FPL'
    } , $bibnum2);

AddReserve('RPL',  $requesters{'RPL'}, $bibnum2,
           $constraint, $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('FPL',  $requesters{'FPL'}, $bibnum2,
           $constraint, $bibitems,  2, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('CPL',  $requesters{'CPL'}, $bibnum2,
           $constraint, $bibitems,  3, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);

# Ensure that the item's home library controls hold policy lookup
C4::Context->set_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

my $messages;
# Return the CPL item at FPL.  The hold that should be triggered is
# the one placed by the CPL patron, as the other two patron's hold
# requests cannot be filled by that item per policy.
(undef, $messages, undef, undef) = AddReturn('bug10272_CPL', 'FPL');
is( $messages->{ResFound}->{borrowernumber},
    $requesters{'CPL'},
    'restrictive library\'s items only fill requests by own patrons (bug 10272)');

# Return the FPL item at FPL.  The hold that should be triggered is
# the one placed by the RPL patron, as that patron is first in line
# and RPL imposes no restrictions on whose holds its items can fill.
(undef, $messages, undef, undef) = AddReturn('bug10272_FPL', 'FPL');
is( $messages->{ResFound}->{borrowernumber},
    $requesters{'RPL'},
    'for generous library, its items fill first hold request in line (bug 10272)');
