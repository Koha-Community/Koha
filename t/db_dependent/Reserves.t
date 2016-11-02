#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 72;
use Test::MockModule;
use Test::Warn;

use MARC::Record;
use DateTime::Duration;

use C4::Biblio;
use C4::Reserves;
use C4::Items;
use C4::Members;
use C4::Circulation;
use Koha::Holds;
use t::lib::Mocks;

use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patron::Categories;

use Data::Dumper;
BEGIN {
    require_ok('C4::Reserves');
}

# a very minimal mack of userenv for use by the test of DelItemCheck
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub {
    { }
});

my $dbh = C4::Context->dbh;

# Start transaction
my $database = Koha::Database->new();
my $schema = $database->schema();
$schema->storage->txn_begin();

# Somewhat arbitrary field chosen for age restriction unit tests. Must be added to db before the framework is cached
$dbh->do("update marc_subfield_structure set kohafield='biblioitems.agerestriction' where tagfield='521' and tagsubfield='a'");

# Setup Test------------------------

# Add branches if not existing
foreach my $addbra ('CPL', 'FPL', 'RPL') {
    $dbh->do("INSERT INTO branches (branchcode,branchname) VALUES (?,?)", undef, ($addbra,"$addbra branch")) unless Koha::Libraries->find($addbra);
}

# Add categories if not existing
foreach my $addcat ('S', 'PT') {
    $dbh->do("INSERT INTO categories (categorycode,hidelostitems,category_type) VALUES (?,?,?)",undef,($addcat, 0, $addcat eq 'S'? 'S': 'A')) unless Koha::Patron::Categories->find($addcat);
}

# Create a helper biblio
my $bib = MARC::Record->new();
my $title = 'Silence in the library';
if( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
    $bib->append_fields(
        MARC::Field->new('600', '', '1', a => 'Moffat, Steven'),
        MARC::Field->new('200', '', '', a => $title),
    );
}
else {
    $bib->append_fields(
        MARC::Field->new('100', '', '', a => 'Moffat, Steven'),
        MARC::Field->new('245', '', '', a => $title),
    );
}
my ($bibnum, $bibitemnum);
($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');

# Create a helper item instance for testing
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

my $bibitems       = '';
my $priority       = '1';
my $resdate        = undef;
my $expdate        = undef;
my $notes          = '';
my $checkitem      = undef;
my $found          = undef;

my $branchcode = Koha::Libraries->search->next->branchcode;

AddReserve($branchcode,    $borrowernumber, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title,      $checkitem, $found);

my ($status, $reserve, $all_reserves) = CheckReserves($itemnumber, $barcode);

is($status, "Reserved", "CheckReserves Test 1");

ok(exists($reserve->{reserve_id}), 'CheckReserves() include reserve_id in its response');

($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
is($status, "Reserved", "CheckReserves Test 2");

($status, $reserve, $all_reserves) = CheckReserves(undef, $barcode);
is($status, "Reserved", "CheckReserves Test 3");

my $ReservesControlBranch = C4::Context->preference('ReservesControlBranch');
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
ok(
    'ItemHomeLib' eq GetReservesControlBranch(
        { homebranch => 'ItemHomeLib' },
        { branchcode => 'PatronHomeLib' }
    ), "GetReservesControlBranch returns item home branch when set to ItemHomeLibrary"
);
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
ok(
    'PatronHomeLib' eq GetReservesControlBranch(
        { homebranch => 'ItemHomeLib' },
        { branchcode => 'PatronHomeLib' }
    ), "GetReservesControlBranch returns patron home branch when set to PatronLibrary"
);
t::lib::Mocks::mock_preference( 'ReservesControlBranch', $ReservesControlBranch );

###
### Regression test for bug 10272
###
my %requesters = ();
$requesters{'CPL'} = AddMember(
    branchcode   => 'CPL',
    categorycode => 'PT',
    surname      => 'borrower from CPL',
);
for my $i ( 2 .. 5 ) {
    $requesters{"CPL$i"} = AddMember(
        branchcode   => 'CPL',
        categorycode => 'PT',
        surname      => 'borrower $i from CPL',
    );
}
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

# Ensure that priorities are numbered correcly when a hold is moved to waiting
# (bug 11947)
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum2));
AddReserve('RPL',  $requesters{'RPL'}, $bibnum2,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('FPL',  $requesters{'FPL'}, $bibnum2,
           $bibitems,  2, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('CPL',  $requesters{'CPL'}, $bibnum2,
           $bibitems,  3, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
ModReserveAffect($itemnum_cpl, $requesters{'RPL'}, 0);

# Now it should have different priorities.
my $title_reserves = GetReservesFromBiblionumber({biblionumber => $bibnum2});
# Sort by reserve number in case the database gives us oddly ordered results
my @reserves = sort { $a->{reserve_id} <=> $b->{reserve_id} } @$title_reserves;
is($reserves[0]{priority}, 0, 'Item is correctly waiting');
is($reserves[1]{priority}, 1, 'Item is correctly priority 1');
is($reserves[2]{priority}, 2, 'Item is correctly priority 2');

@reserves = Koha::Holds->search({ borrowernumber => $requesters{'RPL'} })->waiting();
is( @reserves, 1, 'GetWaiting got only the waiting reserve' );
is( $reserves[0]->borrowernumber(), $requesters{'RPL'}, 'GetWaiting got the reserve for the correct borrower' );


$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum2));
AddReserve('RPL',  $requesters{'RPL'}, $bibnum2,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('FPL',  $requesters{'FPL'}, $bibnum2,
           $bibitems,  2, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
AddReserve('CPL',  $requesters{'CPL'}, $bibnum2,
           $bibitems,  3, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);

# Ensure that the item's home library controls hold policy lookup
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

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

# Ensure that the preference 'LocalHoldsPriority' is not set (Bug 15244):
t::lib::Mocks::mock_preference( 'LocalHoldsPriority', '' );

(undef, $messages, undef, undef) = AddReturn('bug10272_FPL', 'FPL');
is( $messages->{ResFound}->{borrowernumber},
    $requesters{'RPL'},
    'for generous library, its items fill first hold request in line (bug 10272)');

my $reserves = GetReservesFromBiblionumber({biblionumber => $biblionumber});
isa_ok($reserves, 'ARRAY');
is(scalar @$reserves, 1, "Only one reserves for this biblio");
my $reserve_id = $reserves->[0]->{reserve_id};

$reserve = GetReserve($reserve_id);
isa_ok($reserve, 'HASH', "GetReserve return");
is($reserve->{biblionumber}, $biblionumber);

$reserve = CancelReserve({reserve_id => $reserve_id});
isa_ok($reserve, 'HASH', "CancelReserve return");
is($reserve->{biblionumber}, $biblionumber);

$reserve = GetReserve($reserve_id);
is($reserve, undef, "GetReserve returns undef after deletion");

$reserve = CancelReserve({reserve_id => $reserve_id});
is($reserve, undef, "CancelReserve return undef if reserve does not exist");


# Tests for bug 9761 (ConfirmFutureHolds): new CheckReserves lookahead parameter, and corresponding change in AddReturn
# Note that CheckReserve uses its lookahead parameter and does not check ConfirmFutureHolds pref (it should be passed if needed like AddReturn does)
# Test 9761a: Add a reserve without date, CheckReserve should return it
$resdate= undef; #defaults to today in AddReserve
$expdate= undef; #no expdate
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
AddReserve('CPL',  $requesters{'CPL'}, $bibnum,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
($status)=CheckReserves($itemnumber,undef,undef);
is( $status, 'Reserved', 'CheckReserves returns reserve without lookahead');
($status)=CheckReserves($itemnumber,undef,7);
is( $status, 'Reserved', 'CheckReserves also returns reserve with lookahead');

# Test 9761b: Add a reserve with future date, CheckReserve should not return it
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
t::lib::Mocks::mock_preference('AllowHoldDateInFuture', 1);
$resdate= dt_from_string();
$resdate->add_duration(DateTime::Duration->new(days => 4));
$resdate=output_pref($resdate);
$expdate= undef; #no expdate
AddReserve('CPL',  $requesters{'CPL'}, $bibnum,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
($status)=CheckReserves($itemnumber,undef,undef);
is( $status, '', 'CheckReserves returns no future reserve without lookahead');

# Test 9761c: Add a reserve with future date, CheckReserve should return it if lookahead is high enough
($status)=CheckReserves($itemnumber,undef,3);
is( $status, '', 'CheckReserves returns no future reserve with insufficient lookahead');
($status)=CheckReserves($itemnumber,undef,4);
is( $status, 'Reserved', 'CheckReserves returns future reserve with sufficient lookahead');

# Test 9761d: Check ResFound message of AddReturn for future hold
# Note that AddReturn is in Circulation.pm, but this test really pertains to reserves; AddReturn uses the ConfirmFutureHolds pref when calling CheckReserves
# In this test we do not need an issued item; it is just a 'checkin'
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 0);
(my $doreturn, $messages)= AddReturn('97531','CPL');
is($messages->{ResFound}//'', '', 'AddReturn does not care about future reserve when ConfirmFutureHolds is off');
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 3);
($doreturn, $messages)= AddReturn('97531','CPL');
is(exists $messages->{ResFound}?1:0, 0, 'AddReturn ignores future reserve beyond ConfirmFutureHolds days');
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 7);
($doreturn, $messages)= AddReturn('97531','CPL');
is(exists $messages->{ResFound}?1:0, 1, 'AddReturn considers future reserve within ConfirmFutureHolds days');

# End of tests for bug 9761 (ConfirmFutureHolds)

# test marking a hold as captured
my $hold_notice_count = count_hold_print_messages();
ModReserveAffect($itemnumber, $requesters{'CPL'}, 0);
my $new_count = count_hold_print_messages();
is($new_count, $hold_notice_count + 1, 'patron notified when item set to waiting');

# test that duplicate notices aren't generated
ModReserveAffect($itemnumber, $requesters{'CPL'}, 0);
$new_count = count_hold_print_messages();
is($new_count, $hold_notice_count + 1, 'patron not notified a second time (bug 11445)');

# avoiding the not_same_branch error
t::lib::Mocks::mock_preference('IndependentBranches', 0);
is(
    DelItemCheck( $bibnum, $itemnumber),
    'book_reserved',
    'item that is captured to fill a hold cannot be deleted',
);

my $letter = ReserveSlip('CPL', $requesters{'CPL'}, $bibnum);
ok(defined($letter), 'can successfully generate hold slip (bug 10949)');

# Tests for bug 9788: Does GetReservesFromItemnumber return a future wait?
# 9788a: GetReservesFromItemnumber does not return future next available hold
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 2);
t::lib::Mocks::mock_preference('AllowHoldDateInFuture', 1);
$resdate= dt_from_string();
$resdate->add_duration(DateTime::Duration->new(days => 2));
$resdate=output_pref($resdate);
AddReserve('CPL',  $requesters{'CPL'}, $bibnum,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
my @results= GetReservesFromItemnumber($itemnumber);
is(defined $results[3]?1:0, 0, 'GetReservesFromItemnumber does not return a future next available hold');
# 9788b: GetReservesFromItemnumber does not return future item level hold
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
AddReserve('CPL',  $requesters{'CPL'}, $bibnum,
           $bibitems,  1, $resdate, $expdate, $notes,
           $title,      $itemnumber, $found); #item level hold
@results= GetReservesFromItemnumber($itemnumber);
is(defined $results[3]?1:0, 0, 'GetReservesFromItemnumber does not return a future item level hold');
# 9788c: GetReservesFromItemnumber returns future wait (confirmed future hold)
ModReserveAffect( $itemnumber,  $requesters{'CPL'} , 0); #confirm hold
@results= GetReservesFromItemnumber($itemnumber);
is(defined $results[3]?1:0, 1, 'GetReservesFromItemnumber returns a future wait (confirmed future hold)');
# End of tests for bug 9788

$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
# Tests for CalculatePriority (bug 8918)
my $p = C4::Reserves::CalculatePriority($bibnum2);
is($p, 4, 'CalculatePriority should now return priority 4');
$resdate=undef;
AddReserve('CPL',  $requesters{'CPL2'}, $bibnum2,
           $bibitems,  $p, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
$p = C4::Reserves::CalculatePriority($bibnum2);
is($p, 5, 'CalculatePriority should now return priority 5');
#some tests on bibnum
$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
$p = C4::Reserves::CalculatePriority($bibnum);
is($p, 1, 'CalculatePriority should now return priority 1');
#add a new reserve and confirm it to waiting
AddReserve('CPL',  $requesters{'CPL'}, $bibnum,
           $bibitems,  $p, $resdate, $expdate, $notes,
           $title,      $itemnumber, $found);
$p = C4::Reserves::CalculatePriority($bibnum);
is($p, 2, 'CalculatePriority should now return priority 2');
ModReserveAffect( $itemnumber,  $requesters{'CPL'} , 0);
$p = C4::Reserves::CalculatePriority($bibnum);
is($p, 1, 'CalculatePriority should now return priority 1');
#add another biblio hold, no resdate
AddReserve('CPL',  $requesters{'CPL2'}, $bibnum,
           $bibitems,  $p, $resdate, $expdate, $notes,
           $title,      $checkitem, $found);
$p = C4::Reserves::CalculatePriority($bibnum);
is($p, 2, 'CalculatePriority should now return priority 2');
#add another future hold
t::lib::Mocks::mock_preference('AllowHoldDateInFuture', 1);
$resdate= dt_from_string();
$resdate->add_duration(DateTime::Duration->new(days => 1));
AddReserve('CPL',  $requesters{'CPL3'}, $bibnum,
           $bibitems,  $p, output_pref($resdate), $expdate, $notes,
           $title,      $checkitem, $found);
$p = C4::Reserves::CalculatePriority($bibnum);
is($p, 2, 'CalculatePriority should now still return priority 2');
#calc priority with future resdate
$p = C4::Reserves::CalculatePriority($bibnum, $resdate);
is($p, 3, 'CalculatePriority should now return priority 3');
# End of tests for bug 8918

# Tests for cancel reserves by users from OPAC.
$dbh->do('DELETE FROM reserves', undef, ($bibnum));
AddReserve('CPL',  $requesters{'CPL'}, $item_bibnum,
           $bibitems,  1, undef, $expdate, $notes,
           $title,      $checkitem, '');
my (undef, $canres, undef) = CheckReserves($itemnumber);

is( CanReserveBeCanceledFromOpac(), undef,
    'CanReserveBeCanceledFromOpac should return undef if called without any parameter'
);
is(
    CanReserveBeCanceledFromOpac( $canres->{resserve_id} ),
    undef,
    'CanReserveBeCanceledFromOpac should return undef if called without the reserve_id'
);
is(
    CanReserveBeCanceledFromOpac( undef, $requesters{CPL} ),
    undef,
    'CanReserveBeCanceledFromOpac should return undef if called without borrowernumber'
);

my $cancancel = CanReserveBeCanceledFromOpac($canres->{reserve_id}, $requesters{'CPL'});
is($cancancel, 1, 'Can user cancel its own reserve');

$cancancel = CanReserveBeCanceledFromOpac($canres->{reserve_id}, $requesters{'FPL'});
is($cancancel, 0, 'Other user cant cancel reserve');

ModReserveAffect($itemnumber, $requesters{'CPL'}, 1);
$cancancel = CanReserveBeCanceledFromOpac($canres->{reserve_id}, $requesters{'CPL'});
is($cancancel, 0, 'Reserve in transfer status cant be canceled');

$dbh->do('DELETE FROM reserves', undef, ($bibnum));
AddReserve('CPL',  $requesters{'CPL'}, $item_bibnum,
           $bibitems,  1, undef, $expdate, $notes,
           $title,      $checkitem, '');
(undef, $canres, undef) = CheckReserves($itemnumber);

ModReserveAffect($itemnumber, $requesters{'CPL'}, 0);
$cancancel = CanReserveBeCanceledFromOpac($canres->{reserve_id}, $requesters{'CPL'});
is($cancancel, 0, 'Reserve in waiting status cant be canceled');

# End of tests for bug 12876

       ####
####### Testing Bug 13113 - Prevent juvenile/children from reserving ageRestricted material >>>
       ####

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

#Reserving an not-agerestricted Biblio by a Borrower with no dateofbirth is tested previously.

#Set the ageRestriction for the Biblio
my $record = GetMarcBiblio( $bibnum );
my ( $ageres_tagid, $ageres_subfieldid ) = GetMarcFromKohaField( "biblioitems.agerestriction" );
$record->append_fields(  MARC::Field->new($ageres_tagid, '', '', $ageres_subfieldid => 'PEGI 16')  );
C4::Biblio::ModBiblio( $record, $bibnum, '' );

is( C4::Reserves::CanBookBeReserved($borrowernumber, $biblionumber) , 'OK', "Reserving an ageRestricted Biblio without a borrower dateofbirth succeeds" );

#Set the dateofbirth for the Borrower making him "too young".
my $now = DateTime->now();
C4::Members::SetAge( $borrower, '0015-00-00' );
C4::Members::ModMember( borrowernumber => $borrowernumber, dateofbirth => $borrower->{dateofbirth} );

is( C4::Reserves::CanBookBeReserved($borrowernumber, $biblionumber) , 'ageRestricted', "Reserving a 'PEGI 16' Biblio by a 15 year old borrower fails");

#Set the dateofbirth for the Borrower making him "too old".
C4::Members::SetAge( $borrower, '0030-00-00' );
C4::Members::ModMember( borrowernumber => $borrowernumber, dateofbirth => $borrower->{dateofbirth} );

is( C4::Reserves::CanBookBeReserved($borrowernumber, $biblionumber) , 'OK', "Reserving a 'PEGI 16' Biblio by a 30 year old borrower succeeds");
       ####
####### EO Bug 13113 <<<
       ####

my $item = GetItem($itemnumber);

ok( C4::Reserves::IsAvailableForItemLevelRequest($item, $borrower), "Reserving a book on item level" );

my $itype = C4::Reserves::_get_itype($item);
my $categorycode = $borrower->{categorycode};
my $holdingbranch = $item->{holdingbranch};
my $rule = C4::Circulation::GetIssuingRule($categorycode, $itype, $holdingbranch);

$dbh->do(
    "UPDATE issuingrules SET onshelfholds = 1 WHERE categorycode = ? AND itemtype= ? and branchcode = ?",
    undef,
    $rule->{categorycode}, $rule->{itemtype}, $rule->{branchcode}
);
ok( C4::Reserves::OnShelfHoldsAllowed($item, $borrower), "OnShelfHoldsAllowed() allowed" );
$dbh->do(
    "UPDATE issuingrules SET onshelfholds = 0 WHERE categorycode = ? AND itemtype= ? and branchcode = ?",
    undef,
    $rule->{categorycode}, $rule->{itemtype}, $rule->{branchcode}
);
ok( !C4::Reserves::OnShelfHoldsAllowed($item, $borrower), "OnShelfHoldsAllowed() disallowed" );

# Tests for bug 14464

$dbh->do("DELETE FROM reserves WHERE biblionumber=?",undef,($bibnum));
my ( undef, undef, $bz14464_fines ) = GetMemberIssuesAndFines( $borrowernumber );
is( !$bz14464_fines || $bz14464_fines==0, 1, 'Bug 14464 - No fines at beginning' );

# First, test cancelling a reserve when there's no charge configured.
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 0);

my $bz14464_reserve = AddReserve(
    'CPL',
    $borrowernumber,
    $bibnum,
    undef,
    '1',
    undef,
    undef,
    '',
    $title,
    $itemnumber,
    'W'
);

ok( $bz14464_reserve, 'Bug 14464 - 1st reserve correctly created' );

CancelReserve({ reserve_id => $bz14464_reserve, charge_cancel_fee => 1 });

my $old_reserve = Koha::Database->new()->schema()->resultset('OldReserve')->find( $bz14464_reserve );
is($old_reserve->get_column('found'), 'W', 'Bug 14968 - Keep found column from reserve');

( undef, undef, $bz14464_fines ) = GetMemberIssuesAndFines( $borrowernumber );
is( !$bz14464_fines || $bz14464_fines==0, 1, 'Bug 14464 - No fines after cancelling reserve with no charge configured' );

# Then, test cancelling a reserve when there's no charge desired.
t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelayCharge', 42);

$bz14464_reserve = AddReserve(
    'CPL',
    $borrowernumber,
    $bibnum,
    undef,
    '1',
    undef,
    undef,
    '',
    $title,
    $itemnumber,
    'W'
);

ok( $bz14464_reserve, 'Bug 14464 - 2nd reserve correctly created' );

CancelReserve({ reserve_id => $bz14464_reserve });

( undef, undef, $bz14464_fines ) = GetMemberIssuesAndFines( $borrowernumber );
is( !$bz14464_fines || $bz14464_fines==0, 1, 'Bug 14464 - No fines after cancelling reserve with no charge desired' );

# Finally, test cancelling a reserve when there's a charge desired and configured.
$bz14464_reserve = AddReserve(
    'CPL',
    $borrowernumber,
    $bibnum,
    undef,
    '1',
    undef,
    undef,
    '',
    $title,
    $itemnumber,
    'W'
);

ok( $bz14464_reserve, 'Bug 14464 - 1st reserve correctly created' );

CancelReserve({ reserve_id => $bz14464_reserve, charge_cancel_fee => 1 });

( undef, undef, $bz14464_fines ) = GetMemberIssuesAndFines( $borrowernumber );
is( int( $bz14464_fines ), 42, 'Bug 14464 - Fine applied after cancelling reserve with charge desired and configured' );

# tests for MoveReserve in relation to ConfirmFutureHolds (BZ 14526)
#   hold from A pos 1, today, no fut holds: MoveReserve should fill it
$dbh->do('DELETE FROM reserves', undef, ($bibnum));
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 0);
t::lib::Mocks::mock_preference('AllowHoldDateInFuture', 1);
AddReserve('CPL',  $borrowernumber, $item_bibnum,
    $bibitems,  1, undef, $expdate, $notes, $title, $checkitem, '');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber );
is( $status, '', 'MoveReserve filled hold');
#   hold from A waiting, today, no fut holds: MoveReserve should fill it
AddReserve('CPL',  $borrowernumber, $item_bibnum,
   $bibitems,  1, undef, $expdate, $notes, $title, $checkitem, 'W');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber );
is( $status, '', 'MoveReserve filled waiting hold');
#   hold from A pos 1, tomorrow, no fut holds: not filled
$resdate= dt_from_string();
$resdate->add_duration(DateTime::Duration->new(days => 1));
$resdate=output_pref($resdate);
AddReserve('CPL',  $borrowernumber, $item_bibnum,
    $bibitems,  1, $resdate, $expdate, $notes, $title, $checkitem, '');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber, undef, 1 );
is( $status, 'Reserved', 'MoveReserve did not fill future hold');
$dbh->do('DELETE FROM reserves', undef, ($bibnum));
#   hold from A pos 1, tomorrow, fut holds=2: MoveReserve should fill it
t::lib::Mocks::mock_preference('ConfirmFutureHolds', 2);
AddReserve('CPL',  $borrowernumber, $item_bibnum,
    $bibitems,  1, $resdate, $expdate, $notes, $title, $checkitem, '');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber, undef, 2 );
is( $status, '', 'MoveReserve filled future hold now');
#   hold from A waiting, tomorrow, fut holds=2: MoveReserve should fill it
AddReserve('CPL',  $borrowernumber, $item_bibnum,
    $bibitems,  1, $resdate, $expdate, $notes, $title, $checkitem, 'W');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber, undef, 2 );
is( $status, '', 'MoveReserve filled future waiting hold now');
#   hold from A pos 1, today+3, fut holds=2: MoveReserve should not fill it
$resdate= dt_from_string();
$resdate->add_duration(DateTime::Duration->new(days => 3));
$resdate=output_pref($resdate);
AddReserve('CPL',  $borrowernumber, $item_bibnum,
    $bibitems,  1, $resdate, $expdate, $notes, $title, $checkitem, '');
MoveReserve( $itemnumber, $borrowernumber );
($status)=CheckReserves( $itemnumber, undef, 3 );
is( $status, 'Reserved', 'MoveReserve did not fill future hold of 3 days');
$dbh->do('DELETE FROM reserves', undef, ($bibnum));

# we reached the finish
$schema->storage->txn_rollback();

sub count_hold_print_messages {
    my $message_count = $dbh->selectall_arrayref(q{
        SELECT COUNT(*)
        FROM message_queue
        WHERE letter_code = 'HOLD' 
        AND   message_transport_type = 'print'
    });
    return $message_count->[0]->[0];
}
