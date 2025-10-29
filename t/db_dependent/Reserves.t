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

use Test::More tests => 71;
use Test::NoWarnings;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use JSON qw( from_json );
use MARC::Record;
use DateTime::Duration;

use C4::Circulation qw( AddReturn AddIssue );
use C4::Items;
use C4::Biblio qw( GetMarcFromKohaField ModBiblio );
use C4::HoldsQueue;
use C4::Members;
use C4::Reserves
    qw( AddReserve AlterPriority CheckReserves ModReserve ModReserveAffect ReserveSlip CalculatePriority CanBookBeReserved IsAvailableForItemLevelRequest MoveReserve ChargeReserveFee CanItemBeReserved MergeHolds );
use Koha::ActionLogs;
use Koha::Biblios;
use Koha::Caches;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Holds;
use Koha::Items;
use Koha::Libraries;
use Koha::Notice::Templates;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::CirculationRules;

BEGIN {
    require_ok('C4::Reserves');
}

# Start transaction
my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM circulation_rules');

my $builder = t::lib::TestBuilder->new;

my $frameworkcode = q//;

t::lib::Mocks::mock_preference( 'ReservesNeedReturns', 1 );

# Somewhat arbitrary field chosen for age restriction unit tests. Must be added to db before the framework is cached
$dbh->do(
    "update marc_subfield_structure set kohafield='biblioitems.agerestriction' where tagfield='521' and tagsubfield='a' and frameworkcode=?",
    undef, $frameworkcode
);
my $cache = Koha::Caches->get_instance;
$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

## Setup Test
# Add branches
my $branch_1 = $builder->build( { source => 'Branch' } )->{branchcode};
my $branch_2 = $builder->build( { source => 'Branch' } )->{branchcode};
my $branch_3 = $builder->build( { source => 'Branch' } )->{branchcode};

# Add categories
my $category_1 = $builder->build( { source => 'Category' } )->{categorycode};
my $category_2 = $builder->build( { source => 'Category' } )->{categorycode};

# Add an item type
my $itemtype = $builder->build( { source => 'Itemtype', value => { notforloan => 0 } } )->{itemtype};

t::lib::Mocks::mock_userenv( { branchcode => $branch_1 } );

my $bibnum = $builder->build_sample_biblio( { frameworkcode => $frameworkcode } )->biblionumber;

# Create a helper item instance for testing
my $item = $builder->build_sample_item( { biblionumber => $bibnum, library => $branch_1, itype => $itemtype } );

my $biblio_with_no_item = $builder->build_sample_biblio;

# Modify item; setting barcode.
my $testbarcode = '97531';
$item->barcode($testbarcode)->store;    # FIXME We should not hardcode a barcode! Also, what's the purpose of this?

# Create a borrower
my %data = (
    firstname    => 'my firstname',
    surname      => 'my surname',
    categorycode => $category_1,
    branchcode   => $branch_1,
);
Koha::Patron::Categories->find($category_1)->set( { enrolmentfee => 0 } )->store;
my $borrowernumber = Koha::Patron->new( \%data )->store->borrowernumber;
my $patron         = Koha::Patrons->find($borrowernumber);
my $borrower       = $patron->unblessed;
my $biblionumber   = $bibnum;

my $branchcode = Koha::Libraries->search->next->branchcode;

AddReserve(
    {
        branchcode     => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        priority       => 1,
    }
);

my ( $status, $reserve, $all_reserves ) = CheckReserves($item);

is( $status, "Reserved", "CheckReserves Test 1" );

ok( exists( $reserve->{reserve_id} ), 'CheckReserves() include reserve_id in its response' );

( $status, $reserve, $all_reserves ) = CheckReserves($item);
is( $status, "Reserved", "CheckReserves Test 2" );

###
### Regression test for bug 10272
###
my %requesters = ();
$requesters{$branch_1} = Koha::Patron->new(
    {
        branchcode   => $branch_1,
        categorycode => $category_2,
        surname      => "borrower from $branch_1",
    }
)->store;
for my $i ( 2 .. 5 ) {
    $requesters{"CPL$i"} = Koha::Patron->new(
        {
            branchcode   => $branch_1,
            categorycode => $category_2,
            surname      => "borrower $i from $branch_1",
        }
    )->store;
}
$requesters{$branch_2} = Koha::Patron->new(
    {
        branchcode   => $branch_2,
        categorycode => $category_2,
        surname      => "borrower from $branch_2",
    }
)->store;
$requesters{$branch_3} = Koha::Patron->new(
    {
        branchcode   => $branch_3,
        categorycode => $category_2,
        surname      => "borrower from $branch_3",
    }
)->store;

# Configure rules so that $branch_1 allows only $branch_1 patrons
# to request its items, while $branch_2 will allow its items
# to fill holds from anywhere.

$dbh->do('DELETE FROM circulation_rules');
Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed  => 25,
            holds_per_record => 1,
        }
    }
);

# CPL allows only its own patrons to request its items
Koha::CirculationRules->set_rules(
    {
        branchcode => $branch_1,
        itemtype   => undef,
        rules      => {
            holdallowed  => 'from_home_library',
            returnbranch => 'homebranch',
        }
    }
);

# ... while FPL allows anybody to request its items
Koha::CirculationRules->set_rules(
    {
        branchcode => $branch_2,
        itemtype   => undef,
        rules      => {
            holdallowed  => 'from_any_library',
            returnbranch => 'homebranch',
        }
    }
);

my $bibnum2 = $builder->build_sample_biblio( { frameworkcode => $frameworkcode } )->biblionumber;

my ( $itemnum_cpl, $itemnum_fpl );
$itemnum_cpl = $builder->build_sample_item(
    {
        biblionumber => $bibnum2,
        library      => $branch_1,
        barcode      => 'bug10272_CPL',
        itype        => $itemtype
    }
)->itemnumber;
$itemnum_fpl = $builder->build_sample_item(
    {
        biblionumber => $bibnum2,
        library      => $branch_2,
        barcode      => 'bug10272_FPL',
        itype        => $itemtype
    }
)->itemnumber;

# Ensure that priorities are numbered correctly when a hold is moved to waiting
# (bug 11947)
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum2) );
AddReserve(
    {
        branchcode     => $branch_3,
        borrowernumber => $requesters{$branch_3}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 1,
    }
);
AddReserve(
    {
        branchcode     => $branch_2,
        borrowernumber => $requesters{$branch_2}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 2,
    }
);
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{$branch_1}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 3,
    }
);
ModReserveAffect( $itemnum_cpl, $requesters{$branch_3}->borrowernumber, 0 );

# Now it should have different priorities.
my $biblio = Koha::Biblios->find($bibnum2);
my $holds  = $biblio->holds( {}, { order_by => 'reserve_id' } );
is( $holds->next->priority, 0, 'Item is correctly waiting' );
is( $holds->next->priority, 1, 'Item is correctly priority 1' );
is( $holds->next->priority, 2, 'Item is correctly priority 2' );

my @reserves = Koha::Holds->search( { borrowernumber => $requesters{$branch_3}->borrowernumber } )->waiting->as_list;
is( @reserves, 1, 'GetWaiting got only the waiting reserve' );
is(
    $reserves[0]->borrowernumber(), $requesters{$branch_3}->borrowernumber,
    'GetWaiting got the reserve for the correct borrower'
);

$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum2) );
AddReserve(
    {
        branchcode     => $branch_3,
        borrowernumber => $requesters{$branch_3}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 1,
    }
);
AddReserve(
    {
        branchcode     => $branch_2,
        borrowernumber => $requesters{$branch_2}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 2,
    }
);

AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{$branch_1}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => 3,
    }
);

# Ensure that the item's home library controls hold policy lookup
t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

my $messages;

# Return the CPL item at FPL.  The hold that should be triggered is
# the one placed by the CPL patron, as the other two patron's hold
# requests cannot be filled by that item per policy.
( undef, $messages, undef, undef ) = AddReturn( 'bug10272_CPL', $branch_2 );
is(
    $messages->{ResFound}->{borrowernumber},
    $requesters{$branch_1}->borrowernumber,
    'restrictive library\'s items only fill requests by own patrons (bug 10272)'
);

# Return the FPL item at FPL.  The hold that should be triggered is
# the one placed by the RPL patron, as that patron is first in line
# and RPL imposes no restrictions on whose holds its items can fill.

# Ensure that the preference 'LocalHoldsPriority' is not set (Bug 15244):
t::lib::Mocks::mock_preference( 'LocalHoldsPriority', '' );

( undef, $messages, undef, undef ) = AddReturn( 'bug10272_FPL', $branch_2 );
is(
    $messages->{ResFound}->{borrowernumber},
    $requesters{$branch_3}->borrowernumber,
    'for generous library, its items fill first hold request in line (bug 10272)'
);

$biblio = Koha::Biblios->find($biblionumber);
$holds  = $biblio->holds;
is( $holds->count, 1, "Only one reserves for this biblio" );
$holds->next->reserve_id;

# Tests for bug 9761 (ConfirmFutureHolds): new CheckReserves lookahead parameter, and corresponding change in AddReturn
# Note that CheckReserve uses its lookahead parameter and does not check ConfirmFutureHolds pref (it should be passed if needed like AddReturn does)
# Test 9761a: Add a reserve without date, CheckReserve should return it
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{$branch_1}->borrowernumber,
        biblionumber   => $bibnum,
        priority       => 1,
    }
);
($status) = CheckReserves($item);
is( $status, 'Reserved', 'CheckReserves returns reserve without lookahead' );
($status) = CheckReserves( $item, 7 );
is( $status, 'Reserved', 'CheckReserves also returns reserve with lookahead' );

# Test 9761b: Add a reserve with future date, CheckReserve should not return it
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );
t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );
my $resdate = dt_from_string();
$resdate->add_duration( DateTime::Duration->new( days => 4 ) );
my $reserve_id = AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $requesters{$branch_1}->borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);
($status) = CheckReserves($item);
is( $status, '', 'CheckReserves returns no future reserve without lookahead' );

# Test 9761c: Add a reserve with future date, CheckReserve should return it if lookahead is high enough
($status) = CheckReserves( $item, 3 );
is( $status, '', 'CheckReserves returns no future reserve with insufficient lookahead' );
($status) = CheckReserves( $item, 4 );
is( $status, 'Reserved', 'CheckReserves returns future reserve with sufficient lookahead' );

# Test 9761d: Check ResFound message of AddReturn for future hold
# Note that AddReturn is in Circulation.pm, but this test really pertains to reserves; AddReturn uses the ConfirmFutureHolds pref when calling CheckReserves
# In this test we do not need an issued item; it is just a 'checkin'
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds', 0 );
( my $doreturn, $messages ) = AddReturn( $testbarcode, $branch_1 );
is( $messages->{ResFound} // '', '', 'AddReturn does not care about future reserve when ConfirmFutureHolds is off' );
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds', 3 );
( $doreturn, $messages ) = AddReturn( $testbarcode, $branch_1 );
is( exists $messages->{ResFound} ? 1 : 0, 0, 'AddReturn ignores future reserve beyond ConfirmFutureHolds days' );
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds', 7 );
( $doreturn, $messages ) = AddReturn( $testbarcode, $branch_1 );
is( exists $messages->{ResFound} ? 1 : 0, 1, 'AddReturn considers future reserve within ConfirmFutureHolds days' );

my $now_holder = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode => $branch_1,
        }
    }
);
my $now_reserve_id = AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $requesters{$branch_1}->borrowernumber,
        biblionumber     => $bibnum,
        priority         => 2,
        reservation_date => dt_from_string(),
    }
);
my $which_highest;
( $status, $which_highest ) = CheckReserves( $item, 3 );
is(
    $which_highest->{reserve_id}, $now_reserve_id,
    'CheckReserves returns lower priority current reserve with insufficient lookahead'
);
( $status, $which_highest ) = CheckReserves( $item, 4 );
is(
    $which_highest->{reserve_id}, $reserve_id,
    'CheckReserves returns higher priority future reserve with sufficient lookahead'
);

{
    # Prevent warning 'No reserves HOLD_CANCELLATION letter transported by email'
    my $mock_letters = Test::MockModule->new('C4::Letters');
    $mock_letters->mock( 'GetPreparedLetter', sub { return } );

    ModReserve( { reserve_id => $now_reserve_id, rank => 'del', cancellation_reason => 'test reserve' } );
}

# End of tests for bug 9761 (ConfirmFutureHolds)

# test marking a hold as captured
my $hold_notice_count = count_hold_print_messages();
ModReserveAffect( $item->itemnumber, $requesters{$branch_1}->borrowernumber, 0 );
my $new_count = count_hold_print_messages();
is( $new_count, $hold_notice_count + 1, 'patron notified when item set to waiting' );

# test that duplicate notices aren't generated
ModReserveAffect( $item->itemnumber, $requesters{$branch_1}->borrowernumber, 0 );
$new_count = count_hold_print_messages();
is( $new_count, $hold_notice_count + 1, 'patron not notified a second time (bug 11445)' );

# avoiding the not_same_branch error
t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );
$item = Koha::Items->find( $item->itemnumber );
is(
    @{ $item->safe_delete->messages }[0]->message,
    'book_reserved',
    'item that is captured to fill a hold cannot be deleted',
);

my $letter = ReserveSlip( { branchcode => $branch_1, reserve_id => $reserve_id } );
ok( defined($letter), 'can successfully generate hold slip (bug 10949)' );

# Does Koha::Biblio->current_holds respect ConfirmFutureHolds for a next available hold?
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds',    2 );
t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );
$resdate = dt_from_string();
$resdate->add_duration( DateTime::Duration->new( days => 2 ) );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $requesters{$branch_1}->borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);

$holds = Koha::Biblios->find($bibnum)->current_holds;
is( $holds->count, 1, 'current_holds returns a future next available hold' );

# Does Koha::Item->current_holds respect ConfirmFutureHolds for a item level hold?
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $requesters{$branch_1}->borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
        itemnumber       => $item->itemnumber,
    }
);    #item level hold
$holds = $item->current_holds;
is( $holds->count, 1, 'current_holds returns a future item level hold' );

# Does $item->current_holds return a future wait (confirmed future hold)?
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds', 1 );
ModReserveAffect( $item->itemnumber, $requesters{$branch_1}->borrowernumber, 0 );    #confirm hold
$holds = $item->current_holds;
is( $holds->count, 1, 'current_holds returns a future wait (confirmed future hold)' );
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );

# Tests for CalculatePriority (bug 8918)
my $p = C4::Reserves::CalculatePriority($bibnum2);
is( $p, 4, 'CalculatePriority should now return priority 4' );
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{'CPL2'}->borrowernumber,
        biblionumber   => $bibnum2,
        priority       => $p,
    }
);
$p = C4::Reserves::CalculatePriority($bibnum2);
is( $p, 5, 'CalculatePriority should now return priority 5' );

#some tests on bibnum
$dbh->do( "DELETE FROM reserves WHERE biblionumber=?", undef, ($bibnum) );
$p = C4::Reserves::CalculatePriority($bibnum);
is( $p, 1, 'CalculatePriority should now return priority 1' );

#add a new reserve and confirm it to waiting
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{$branch_1}->borrowernumber,
        biblionumber   => $bibnum,
        priority       => $p,
        itemnumber     => $item->itemnumber,
    }
);
$p = C4::Reserves::CalculatePriority($bibnum);
is( $p, 2, 'CalculatePriority should now return priority 2' );
ModReserveAffect( $item->itemnumber, $requesters{$branch_1}->borrowernumber, 0 );
$p = C4::Reserves::CalculatePriority($bibnum);
is( $p, 1, 'CalculatePriority should now return priority 1' );

#add another biblio hold, no resdate
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $requesters{'CPL2'}->borrowernumber,
        biblionumber   => $bibnum,
        priority       => $p,
    }
);
$p = C4::Reserves::CalculatePriority($bibnum);
is( $p, 2, 'CalculatePriority should now return priority 2' );

#add another future hold
t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );
$resdate = dt_from_string();
$resdate->add_duration( DateTime::Duration->new( days => 1 ) );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $requesters{'CPL2'}->borrowernumber,
        biblionumber     => $bibnum,
        priority         => $p,
        reservation_date => $resdate,
    }
);
$p = C4::Reserves::CalculatePriority($bibnum);
is( $p, 2, 'CalculatePriority should now still return priority 2' );

#calc priority with future resdate
$p = C4::Reserves::CalculatePriority( $bibnum, $resdate );
is( $p, 3, 'CalculatePriority should now return priority 3' );

# End of tests for bug 8918

# regression test for bug 12630
# Now there are 2 reserves on $bibnum
t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );
my $bor_tmp_1 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname    => 'my firstname tmp 1',
            surname      => 'my surname tmp 1',
            categorycode => 'S',
            branchcode   => 'CPL',
        }
    }
);
my $bor_tmp_2 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            firstname    => 'my firstname tmp 2',
            surname      => 'my surname tmp 2',
            categorycode => 'S',
            branchcode   => 'CPL',
        }
    }
);
my $borrowernumber_tmp_1 = $bor_tmp_1->borrowernumber;
my $borrowernumber_tmp_2 = $bor_tmp_2->borrowernumber;
my $date_in_future       = dt_from_string();
$date_in_future = $date_in_future->add_duration( DateTime::Duration->new( days => 1 ) );
AddReserve(
    {
        branchcode       => 'CPL',
        borrowernumber   => $borrowernumber_tmp_1,
        biblionumber     => $bibnum,
        priority         => 3,
        reservation_date => $date_in_future
    }
);
AddReserve(
    {
        branchcode       => 'CPL',
        borrowernumber   => $borrowernumber_tmp_2,
        biblionumber     => $bibnum,
        priority         => 4,
        reservation_date => $date_in_future
    }
);
my @r1 = Koha::Holds->search( { borrowernumber => $borrowernumber_tmp_1 } )->as_list;
my @r2 = Koha::Holds->search( { borrowernumber => $borrowernumber_tmp_2 } )->as_list;
is( $r1[0]->priority, 3, 'priority for hold in future should be correct' );
is( $r2[0]->priority, 4, 'priority for hold not in future should be correct' );

# end of tests for bug 12630

####
####### Testing Bug 13113 - Prevent juvenile/children from reserving ageRestricted material >>>
####

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

#Reserving an not-agerestricted Biblio by a Borrower with no dateofbirth is tested previously.

#Set the ageRestriction for the Biblio
$biblio = Koha::Biblios->find($bibnum);
my $record = $biblio->metadata->record;
my ( $ageres_tagid, $ageres_subfieldid ) = GetMarcFromKohaField("biblioitems.agerestriction");
$record->append_fields( MARC::Field->new( $ageres_tagid, '', '', $ageres_subfieldid => 'PEGI 16' ) );
C4::Biblio::ModBiblio( $record, $bibnum, $frameworkcode );

is(
    C4::Reserves::CanBookBeReserved( $borrowernumber, $biblionumber )->{status}, 'OK',
    "Reserving an ageRestricted Biblio without a borrower dateofbirth succeeds"
);

#Set the dateofbirth for the Borrower making them "too young".
$borrower->{dateofbirth} = DateTime->now->add( years => -15 );
Koha::Patrons->find($borrowernumber)->set( { dateofbirth => $borrower->{dateofbirth} } )->store;

is(
    C4::Reserves::CanBookBeReserved( $borrowernumber, $biblionumber )->{status}, 'ageRestricted',
    "Reserving a 'PEGI 16' Biblio by a 15 year old borrower fails"
);

#Set the dateofbirth for the Borrower making them "too old".
$borrower->{dateofbirth} = DateTime->now->add( years => -30 );
Koha::Patrons->find($borrowernumber)->set( { dateofbirth => $borrower->{dateofbirth} } )->store;

is(
    C4::Reserves::CanBookBeReserved( $borrowernumber, $biblionumber )->{status}, 'OK',
    "Reserving a 'PEGI 16' Biblio by a 30 year old borrower succeeds"
);

is(
    C4::Reserves::CanBookBeReserved( $borrowernumber, $biblio_with_no_item->biblionumber )->{status}, '',
    "Biblio with no item. Status is empty"
);
####
####### EO Bug 13113 <<<
####

ok( C4::Reserves::IsAvailableForItemLevelRequest( $item, $patron ), "Reserving a book on item level" );

my $pickup_branch = $builder->build( { source => 'Branch' } )->{branchcode};
t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  '1' );
t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );
my $limit = Koha::Item::Transfer::Limit->new(
    {
        toBranch   => $pickup_branch,
        fromBranch => $item->holdingbranch,
        itemtype   => $item->effective_itemtype,
    }
)->store();
is(
    C4::Reserves::IsAvailableForItemLevelRequest( $item, $patron, $pickup_branch ), 0,
    "Item level request not available due to transfer limit"
);
t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '0' );

my $categorycode  = $borrower->{categorycode};
my $holdingbranch = $item->{holdingbranch};
Koha::CirculationRules->set_rules(
    {
        categorycode => $categorycode,
        itemtype     => $item->effective_itemtype,
        branchcode   => $holdingbranch,
        rules        => {
            onshelfholds => 1,
        }
    }
);

# tests for MoveReserve in relation to ConfirmFutureHolds (BZ 14526)
#   hold from A pos 1, today, no fut holds: MoveReserve should fill it
$dbh->do( 'DELETE FROM reserves', undef, ($bibnum) );
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds',    0 );
t::lib::Mocks::mock_preference( 'AllowHoldDateInFuture', 1 );
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $borrowernumber,
        biblionumber   => $bibnum,
        priority       => 1,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves($item);
is( $status, '', 'MoveReserve filled hold' );

#   hold from A waiting, today, no fut holds: MoveReserve should fill it
my $other_item = $builder->build_sample_item( { biblionumber => $biblio->id } );
AddReserve(
    {
        branchcode     => $branch_1,
        borrowernumber => $borrowernumber,
        biblionumber   => $bibnum,
        priority       => 1,
        found          => 'W',
        itemnumber     => $other_item->id,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves($item);
is( $status, '', 'MoveReserve filled waiting hold' );

#   hold from A pos 1, tomorrow, no fut holds: not filled
$resdate = dt_from_string();
$resdate->add_duration( DateTime::Duration->new( days => 1 ) );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves( $item, 1 );
is( $status, 'Reserved', 'MoveReserve did not fill future hold' );
$dbh->do( 'DELETE FROM reserves', undef, ($bibnum) );

#   hold from A pos 1, tomorrow, fut holds=2: MoveReserve should fill it
t::lib::Mocks::mock_preference( 'ConfirmFutureHolds', 2 );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves( $item, undef, 2 );
is( $status, '', 'MoveReserve filled future hold now' );

#   hold from A waiting, tomorrow, fut holds=2: MoveReserve should fill it
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves( $item, undef, 2 );
is( $status, '', 'MoveReserve filled future waiting hold now' );

#   hold from A pos 1, today+3, fut holds=2: MoveReserve should not fill it
$resdate = dt_from_string();
$resdate->add_duration( DateTime::Duration->new( days => 3 ) );
AddReserve(
    {
        branchcode       => $branch_1,
        borrowernumber   => $borrowernumber,
        biblionumber     => $bibnum,
        priority         => 1,
        reservation_date => $resdate,
    }
);
MoveReserve( $item, $patron );
($status) = CheckReserves( $item, 3 );
is( $status, 'Reserved', 'MoveReserve did not fill future hold of 3 days' );
$dbh->do( 'DELETE FROM reserves', undef, ($bibnum) );

$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

subtest '_koha_notify_reserve() tests' => sub {

    plan tests => 4;

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => {
                branchemail     => 'branch@e.mail',
                branchreplyto   => 'branch@reply.to',
                pickup_location => 1
            }
        }
    );
    my $item = $builder->build_sample_item(
        {
            homebranch    => $branch->branchcode,
            holdingbranch => $branch->branchcode
        }
    );

    my $wants_hold_and_email = {
        wants_digest => '0',
        transports   => {
            sms   => 'HOLD',
            email => 'HOLD',
        },
        letter_code => 'HOLD'
    };

    my $mp = Test::MockModule->new('C4::Members::Messaging');

    $mp->mock( "GetMessagingPreferences", $wants_hold_and_email );

    $dbh->do('DELETE FROM letter');

    my $email_hold_notice = $builder->build(
        {
            source => 'Letter',
            value  => {
                message_transport_type => 'email',
                branchcode             => '',
                code                   => 'HOLD',
                module                 => 'reserves',
                lang                   => 'default',
            }
        }
    );

    my $sms_hold_notice = $builder->build(
        {
            source => 'Letter',
            value  => {
                message_transport_type => 'sms',
                branchcode             => '',
                code                   => 'HOLD',
                module                 => 'reserves',
                lang                   => 'default',
            }
        }
    );

    my $hold_borrower = $builder->build(
        {
            source => 'Borrower',
            value  => {
                smsalertnumber => '5555555555',
                email          => 'a@b.com',
            }
        }
    )->{borrowernumber};

    C4::Reserves::AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $hold_borrower,
            biblionumber   => $item->biblionumber,
        }
    );

    ModReserveAffect( $item->itemnumber, $hold_borrower, 0 );
    my $sms_message_address = $schema->resultset('MessageQueue')->search(
        {
            letter_code            => 'HOLD',
            message_transport_type => 'sms',
            borrowernumber         => $hold_borrower,
        }
    )->next()->to_address();
    is( $sms_message_address, undef, "We should not populate the sms message with the sms number, sending will do so" );

    my $email = $schema->resultset('MessageQueue')->search(
        {
            letter_code            => 'HOLD',
            message_transport_type => 'email',
            borrowernumber         => $hold_borrower,
        }
    )->next();
    my $email_to_address = $email->to_address();
    is(
        $email_to_address, undef,
        "We should not populate the hold message with the email address, sending will do so"
    );
    my $email_from_address = $email->from_address();
    is( $email_from_address, 'branch@e.mail', "Library's from address is used for sending" );
    my $email_reply_address = $email->reply_address();
    is( $email_reply_address, 'branch@reply.to', "Library's reply address is used for reply" );

};

subtest 'ReservesNeedReturns' => sub {
    plan tests => 18;

    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item_info = {
        homebranch    => $library->branchcode,
        holdingbranch => $library->branchcode,
    };
    my $item   = $builder->build_sample_item($item_info);
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, }
        }
    );

    my $priority = 1;

    t::lib::Mocks::mock_preference( 'ReservesNeedReturns', 1 );    # Test with feature disabled
    my $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->priority, $priority, 'If ReservesNeedReturns is 1, priority must not have been set to changed' );
    is( $hold->found,    undef,     'If ReservesNeedReturns is 1, found must not have been set waiting' );
    $hold->delete;

    t::lib::Mocks::mock_preference( 'ReservesNeedReturns', 0 )
        ;    # '0' means 'Automatically mark a hold as found and waiting'
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->priority, 0,   'If ReservesNeedReturns is 0 and no other status, priority must have been set to 0' );
    is( $hold->found,    'W', 'If ReservesNeedReturns is 0 and no other status, found must have been set waiting' );
    $hold->delete;

    $item->onloan('2010-01-01')->store;
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->priority, 1, 'If ReservesNeedReturns is 0 but item onloan priority must be set to 1' );
    $hold->delete;

    t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 0 );    # '0' means damaged holds not allowed
    $item->onloan(undef)->damaged(1)->store;
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is(
        $hold->priority, 1,
        'If ReservesNeedReturns is 0 but item damaged and not allowed holds on damaged items priority must be set to 1'
    );
    $hold->delete;
    t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 1 );    # '0' means damaged holds not allowed
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->priority, 0, 'If ReservesNeedReturns is 0 and damaged holds allowed, priority must have been set to 0' );
    is( $hold->found, 'W',  'If ReservesNeedReturns is 0 and damaged holds allowed, found must have been set waiting' );
    $hold->delete;

    my $hold_1 = place_item_hold( $patron, $item, $library, $priority );
    is( $hold_1->found,    'W', 'First hold on item is set to waiting with ReservesNeedReturns set to 0' );
    is( $hold_1->priority, 0,   'First hold on item is set to waiting with ReservesNeedReturns set to 0' );
    $hold = place_item_hold( $patron_2, $item, $library, $priority );
    is( $hold->priority, 1, 'If ReservesNeedReturns is 0 but item already on hold priority must be set to 1' );
    $hold->delete;
    $hold_1->delete;

    my $transfer = $builder->build_object(
        {
            class => "Koha::Item::Transfers",
            value => {
                itemnumber    => $item->itemnumber,
                datearrived   => undef,
                datecancelled => undef
            }
        }
    );
    $item->damaged(0)->store;
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->found,    undef, 'If ReservesNeedReturns is 0 but item in transit the hold must not be set to waiting' );
    is( $hold->priority, 1,     'If ReservesNeedReturns is 0 but item in transit the hold must not be set to waiting' );
    $hold->delete;
    $transfer->delete;

    $hold = place_item_hold( $patron, $item, $library, $priority );
    is( $hold->priority, 0,   'If ReservesNeedReturns is 0 and no other status, priority must have been set to 0' );
    is( $hold->found,    'W', 'If ReservesNeedReturns is 0 and no other status, found must have been set waiting' );
    $hold_1 = place_item_hold( $patron, $item, $library, $priority );
    is( $hold_1->priority, 1, 'If ReservesNeedReturns is 0 but item has a hold priority is 1' );
    $hold_1->suspend(1)->store;    # We suspend the hold
    $hold->delete;                 # Delete the waiting hold
    $hold = place_item_hold( $patron, $item, $library, $priority );
    is(
        $hold->priority, 0,
        'If ReservesNeedReturns is 0 and other hold(s) suspended, priority must have been set to 0'
    );
    is(
        $hold->found, 'W',
        'If ReservesNeedReturns is 0 and other  hold(s) suspended, found must have been set waiting'
    );

    t::lib::Mocks::mock_preference( 'ReservesNeedReturns', 1 );    # Don't affect other tests
};

subtest 'ChargeReserveFee tests' => sub {

    plan tests => 8;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    my $fee   = 20;
    my $title = 'A title';

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( userenv => { branch => $library->id } );

    my $line = C4::Reserves::ChargeReserveFee( $patron->id, $fee, $title );

    is( ref($line), 'Koha::Account::Line', 'Returns a Koha::Account::Line object' );
    ok( $line->is_debit, 'Generates a debit line' );
    is( $line->debit_type_code,   'RESERVE',    'generates RESERVE debit_type' );
    is( $line->borrowernumber,    $patron->id,  'generated line belongs to the passed patron' );
    is( $line->amount,            $fee,         'amount set correctly' );
    is( $line->amountoutstanding, $fee,         'amountoutstanding set correctly' );
    is( $line->description,       "$title",     'description is title of reserved item' );
    is( $line->branchcode,        $library->id, "Library id is picked from userenv and stored correctly" );
};

subtest 'MoveReserve additional test' => sub {

    plan tests => 8;

    # Create the items and patrons we need
    my $biblio = $builder->build_sample_biblio();
    my $itype  = $builder->build_object( { class => "Koha::ItemTypes", value => { notforloan => 0 } } );
    my $item_1 = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, notforloan => 0, itype => $itype->itemtype } );
    my $item_2 = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, notforloan => 0, itype => $itype->itemtype } );
    my $patron_1 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron_2 = $builder->build_object( { class => "Koha::Patrons" } );

    # Place a hold on the title for both patrons
    my $reserve_1 = AddReserve(
        {
            branchcode     => $item_1->homebranch,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            itemnumber     => $item_1->itemnumber,
        }
    );
    my $reserve_2 = AddReserve(
        {
            branchcode     => $item_2->homebranch,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            itemnumber     => $item_1->itemnumber,
        }
    );
    is( $patron_1->holds->next()->reserve_id, $reserve_1, "The 1st patron has a hold" );
    is( $patron_2->holds->next()->reserve_id, $reserve_2, "The 2nd patron has a hold" );

    # Fake the holds queue
    $dbh->do(
        q{INSERT INTO hold_fill_targets VALUES (?, ?, ?, ?, ?,?)}, undef,
        ( $patron_1->borrowernumber, $biblio->biblionumber, $item_1->itemnumber, $item_1->homebranch, 0, $reserve_1 )
    );

    # The 2nd hold should be filled even if the item is preselected for the first hold
    MoveReserve( $item_1, $patron_2 );
    is( $patron_2->holds->count, 0, "The 2nd patrons no longer has a hold" );
    is(
        $patron_2->old_holds->next()->reserve_id, $reserve_2,
        "The 2nd patrons hold was filled and moved to old holds"
    );

    my $reserve_3 = AddReserve(
        {
            branchcode     => $item_2->homebranch,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            itemnumber     => $item_2->itemnumber,
        }
    );

    # The 3rd hold should not be filled as it is an item level hold on a different item
    MoveReserve( $item_1, $patron_2 );
    is( $patron_2->holds->count,     1, "The 2nd patron still has a hold" );
    is( $patron_2->old_holds->count, 1, "The 2nd patron has only 1 old holds" );

    my $hold_3 = Koha::Holds->find($reserve_3);
    $hold_3->item_level_hold(0)->store();

    # The 3rd hold should now be filled as it is a title level hold, even though associated with a different item
    MoveReserve( $item_1, $patron_2 );
    is( $patron_2->holds->count,       0, "The 2nd patron no longer has a hold" );
    is( $patron_2->old_holds->count(), 2, "The 2nd patron's hold was filled and moved to old holds" );

};

# FIXME: Should be in Circulation.t
subtest 'AddIssue calls $hold->revert_found()' => sub {

    plan tests => 2;

    # Create the items and patrons we need
    my $biblio  = $builder->build_sample_biblio();
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itype   = $builder->build_object( { class => "Koha::ItemTypes", value => { notforloan => 0 } } );
    my $item_1  = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itype        => $itype->itemtype,
            library      => $library->branchcode
        }
    );
    my $patron_1 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron_2 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron_3 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron_4 = $builder->build_object( { class => "Koha::Patrons" } );

    # Place a hold on the title for both patrons
    my $priority = 1;
    my $hold_1   = place_item_hold( $patron_1, $item_1, $library, $priority );
    my $hold_2   = place_item_hold( $patron_2, $item_1, $library, $priority );
    my $hold_3   = place_item_hold( $patron_3, $item_1, $library, $priority );
    my $hold_4   = place_item_hold( $patron_4, $item_1, $library, $priority );

    $hold_1->set_waiting;
    AddIssue( $patron_3, $item_1->barcode, undef, 'revert' );

    my $holds = $biblio->holds;
    is( $holds->count, 3, 'One hold has been deleted' );
    is_deeply(
        [
            $holds->next->priority, $holds->next->priority,
            $holds->next->priority
        ],
        [ 1, 2, 3 ],
        'priorities have been reordered'
    );
};

subtest 'CheckReserves additional tests' => sub {

    plan tests => 8;

    my $item     = $builder->build_sample_item;
    my $reserve1 = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                found            => undef,
                priority         => 1,
                itemnumber       => undef,
                biblionumber     => $item->biblionumber,
                waitingdate      => undef,
                cancellationdate => undef,
                item_level_hold  => 0,
                lowestPriority   => 0,
                expirationdate   => undef,
                suspend_until    => undef,
                suspend          => 0,
                itemtype         => undef,
            }
        }
    );
    my $reserve2 = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                found            => undef,
                priority         => 2,
                biblionumber     => $item->biblionumber,
                borrowernumber   => $reserve1->borrowernumber,
                itemnumber       => undef,
                waitingdate      => undef,
                cancellationdate => undef,
                item_level_hold  => 0,
                lowestPriority   => 0,
                expirationdate   => undef,
                suspend_until    => undef,
                suspend          => 0,
                itemtype         => undef,
            }
        }
    );

    my $tmp_holdsqueue = $builder->build(
        {
            source => 'TmpHoldsqueue',
            value  => {
                borrowernumber => $reserve1->borrowernumber,
                biblionumber   => $reserve1->biblionumber,
            }
        }
    );
    my $fill_target = $builder->build(
        {
            source => 'HoldFillTarget',
            value  => {
                borrowernumber     => $reserve1->borrowernumber,
                biblionumber       => $reserve1->biblionumber,
                itemnumber         => $item->itemnumber,
                item_level_request => 0,
            }
        }
    );

    ModReserveAffect(
        $item->itemnumber, $reserve1->borrowernumber, 1,
        $reserve1->reserve_id
    );
    my ( $status, $matched_reserve, $possible_reserves ) = CheckReserves($item);

    is( $status, 'Transferred', "We found a reserve" );
    is(
        $matched_reserve->{reserve_id},
        $reserve1->reserve_id, "We got the Transit reserve"
    );
    is( scalar @$possible_reserves, 2, 'We do get both reserves' );

    my $patron_B = $builder->build_object( { class => "Koha::Patrons" } );
    my $item_A   = $builder->build_sample_item;
    my $item_B   = $builder->build_sample_item(
        {
            homebranch   => $patron_B->branchcode,
            biblionumber => $item_A->biblionumber,
            itype        => $item_A->itype
        }
    );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => $item_A->itype,
            rules        => {
                reservesallowed  => 25,
                holds_per_record => 1,
            }
        }
    );
    Koha::CirculationRules->set_rule(
        {
            branchcode => undef,
            itemtype   => $item_A->itype,
            rule_name  => 'holdallowed',
            rule_value => 'from_home_library'
        }
    );
    my $reserve_id = AddReserve(
        {
            branchcode     => $patron_B->branchcode,
            borrowernumber => $patron_B->borrowernumber,
            biblionumber   => $item_A->biblionumber,
            priority       => 1,
            itemnumber     => undef,
        }
    );

    ok( $reserve_id, "We can place a record level hold because one item is owned by patron's home library" );
    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
    ( $status, $matched_reserve, $possible_reserves ) = CheckReserves($item_A);
    is( $status, "", "We do not fill the hold with item A because it is not from the patron's homebranch" );
    Koha::CirculationRules->set_rule(
        {
            branchcode => $item_A->homebranch,
            itemtype   => $item_A->itype,
            rule_name  => 'holdallowed',
            rule_value => 'from_any_library'
        }
    );
    ( $status, $matched_reserve, $possible_reserves ) = CheckReserves($item_A);
    is( $status, "Reserved", "We fill the hold with item A because item's branch rule says allow any" );

    # Changing the control branch should change only the rule we get
    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
    ( $status, $matched_reserve, $possible_reserves ) = CheckReserves($item_A);
    is( $status, "", "We do not fill the hold with item A because it is not from the patron's homebranch" );
    Koha::CirculationRules->set_rule(
        {
            branchcode => $patron_B->branchcode,
            itemtype   => $item_A->itype,
            rule_name  => 'holdallowed',
            rule_value => 'from_any_library'
        }
    );
    ( $status, $matched_reserve, $possible_reserves ) = CheckReserves($item_A);
    is( $status, "Reserved", "We fill the hold with item A because patron's branch rule says allow any" );

};

subtest 'AllowHoldOnPatronPossession test' => sub {

    plan tests => 4;

    # Create the items and patrons we need
    my $biblio = $builder->build_sample_biblio();
    my $itype  = $builder->build_object( { class => "Koha::ItemTypes", value => { notforloan => 0 } } );
    my $item   = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, notforloan => 0, itype => $itype->itemtype } );
    my $patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => { branchcode => $item->homebranch }
        }
    );

    C4::Circulation::AddIssue(
        $patron,
        $item->barcode
    );
    t::lib::Mocks::mock_preference( 'AllowHoldsOnPatronsPossessions', 0 );

    is(
        C4::Reserves::CanBookBeReserved(
            $patron->borrowernumber,
            $item->biblionumber
        )->{status},
        'alreadypossession',
        'Patron cannot place hold on a book loaned to itself'
    );

    is(
        C4::Reserves::CanItemBeReserved( $patron, $item )->{status},
        'alreadypossession',
        'Patron cannot place hold on an item loaned to itself'
    );

    t::lib::Mocks::mock_preference( 'AllowHoldsOnPatronsPossessions', 1 );

    is(
        C4::Reserves::CanBookBeReserved(
            $patron->borrowernumber,
            $item->biblionumber
        )->{status},
        'OK',
        'Patron can place hold on a book loaned to itself'
    );

    is(
        C4::Reserves::CanItemBeReserved( $patron, $item )->{status},
        'OK',
        'Patron can place hold on an item loaned to itself'
    );
};

subtest 'MergeHolds' => sub {

    plan tests => 1;

    my $biblio_1 = $builder->build_sample_biblio();
    my $biblio_2 = $builder->build_sample_biblio();
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itype    = $builder->build_object( { class => "Koha::ItemTypes", value => { notforloan => 0 } } );
    my $item_1   = $builder->build_sample_item(
        {
            biblionumber => $biblio_1->biblionumber,
            itype        => $itype->itemtype,
            library      => $library->branchcode
        }
    );
    my $patron_1 = $builder->build_object( { class => "Koha::Patrons" } );

    # Place a hold on $biblio_1
    my $priority = 1;
    place_item_hold( $patron_1, $item_1, $library, $priority );

    # Move and make sure hold is now on $biblio_2
    C4::Reserves::MergeHolds( $dbh, $biblio_2->biblionumber, $biblio_1->biblionumber );
    is( $biblio_2->holds->count, 1, 'Hold has been transferred' );
};

subtest 'ModReserveAffect logging' => sub {

    plan tests => 4;

    my $item   = $builder->build_sample_item;
    my $patron = $builder->build_object(
        {
            class => "Koha::Patrons",
            value => { branchcode => $item->homebranch }
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $patron } );
    t::lib::Mocks::mock_preference( 'HoldsLog', 1 );

    my $reserve_id = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );

    my $hold               = Koha::Holds->find($reserve_id);
    my $previous_timestamp = '1970-01-01 12:34:56';
    $hold->timestamp($previous_timestamp)->store;

    $hold = Koha::Holds->find($reserve_id);
    is( $hold->timestamp, $previous_timestamp, 'Make sure the previous timestamp has been used' );

    # Avoid warnings
    my $reserve_mock = Test::MockModule->new('C4::Reserves');
    $reserve_mock->mock( '_koha_notify_reserve', undef );

    # Mark it waiting
    ModReserveAffect( $item->itemnumber, $patron->borrowernumber );

    $hold->discard_changes;
    ok( $hold->is_waiting, 'Hold has been set waiting' );
    isnt( $hold->timestamp, $previous_timestamp, 'The timestamp has been modified' );

    my $log = Koha::ActionLogs->search( { module => 'HOLDS', action => 'MODIFY', object => $hold->reserve_id } )->next;
    my $expected = sprintf q{'timestamp' => '%s'}, $hold->timestamp;
    like( $log->info, qr{$expected}, 'Timestamp logged is the current one' );
};

sub count_hold_print_messages {
    my $message_count = $dbh->selectall_arrayref(
        q{
        SELECT COUNT(*)
        FROM message_queue
        WHERE letter_code = 'HOLD' 
        AND   message_transport_type = 'print'
    }
    );
    return $message_count->[0]->[0];
}

sub place_item_hold {
    my ( $patron, $item, $library, $priority ) = @_;

    my $hold_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => $priority,
            title          => "title for fee",
            itemnumber     => $item->itemnumber,
        }
    );

    my $hold = Koha::Holds->find($hold_id);
    return $hold;
}

# we reached the finish
$schema->storage->txn_rollback();

subtest 'IsAvailableForItemLevelRequest() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $item_type = undef;

    my $item_mock = Test::MockModule->new('Koha::Item');
    $item_mock->mock( 'effective_itemtype', sub { return $item_type; } );

    my $item = $builder->build_sample_item;

    ok(
        !C4::Reserves::IsAvailableForItemLevelRequest( $item, $patron ),
        "Item not available for item-level hold because no effective item type"
    );

    # Weird use case to highlight issue
    $item_type = '0';
    Koha::ItemTypes->search( { itemtype => $item_type } )->delete;
    my $itemtype = $builder->build_object(
        {
            class => 'Koha::ItemTypes',
            value => { itemtype => $item_type }
        }
    );
    ok(
        C4::Reserves::IsAvailableForItemLevelRequest( $item, $patron ),
        "Item not available for item-level hold because no effective item type"
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            rules        => {
                onshelfholds => 0,
            }
        }
    );
    my $item_1 = $builder->build_sample_item( { notforloan => -1 } );
    ok(
        C4::Reserves::IsAvailableForItemLevelRequest( $item_1, $patron ),
        "We can placing hold on item with negative not for loan values when 'On shelf holds allowed' is set to 'If any unavailable'"
    );
    $schema->storage->txn_rollback;
};

subtest 'AddReserve() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivityTriggers', 'hold' );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { lastseen => undef } } );
    my $biblio  = $builder->build_sample_biblio;

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                "AddReserve triggers a holds queue update for the related biblio"
            );
        }
    );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
        }
    );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
        }
    );

    $patron->discard_changes;
    isnt( $patron->lastseen, undef, "Patron activity tracked when hold is a valid trigger" );

    $schema->storage->txn_rollback;
};

subtest 'AlterPriorty() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio   = $builder->build_sample_biblio;

    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->id,
            biblionumber   => $biblio->id,
        }
    );
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_2->id,
            biblionumber   => $biblio->id,
        }
    );
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_3->id,
            biblionumber   => $biblio->id,
        }
    );

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                "AlterPriority triggers a holds queue update for the related biblio"
            );
        }
    );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    AlterPriority( "bottom", $reserve_id, 1, 2, 1, 3 );

    my $hold = Koha::Holds->find($reserve_id);

    is( $hold->priority, 3, 'Successfully altered priority to bottom' );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    AlterPriority( "bottom", $reserve_id, 1, 2, 1, 3 );

    $schema->storage->txn_rollback;
};

subtest 'CanBookBeReserved() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $itype   = $builder->build_object( { class => 'Koha::ItemTypes' } );

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->id, itype => $itype->id } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->id, itype => $itype->id } );

    Koha::CirculationRules->delete;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                holds_per_record => 100,
            }
        }
    );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => $itype->id,
            rules        => {
                reservesallowed => 2,
            }
        }
    );

    C4::Reserves::AddReserve(
        {
            branchcode     => $library->id,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            title          => $biblio->title,
            itemnumber     => $item_1->id
        }
    );

    ## Limit on item type is 2, only one hold, success tests

    my $res = CanBookBeReserved(
        $patron->id, $biblio->id, $library->id,
        { itemtype => $itype->id }
    );
    is_deeply(
        $res, { status => 'OK' },
        'Holds on itemtype limit not reached'
    );

    # Add a second hold, biblio-level and item type-constrained
    C4::Reserves::AddReserve(
        {
            branchcode     => $library->id,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            title          => $biblio->title,
            itemtype       => $itype->id,
        }
    );

    ## Limit on item type is 2, two holds, one of them biblio-level/item type-constrained

    $res = CanBookBeReserved(
        $patron->id, $biblio->id, $library->id,
        { itemtype => $itype->id }
    );
    is_deeply( $res, { status => '' }, 'Holds on itemtype limit reached' );

    $schema->storage->txn_rollback;
};

subtest 'CanItemBeReserved() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $itype   = $builder->build_object( { class => 'Koha::ItemTypes' } );

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->id, itype => $itype->id } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->id, itype => $itype->id } );

    Koha::CirculationRules->delete;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                holds_per_record => 100,
            }
        }
    );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => $itype->id,
            rules        => {
                reservesallowed => 2,
            }
        }
    );

    C4::Reserves::AddReserve(
        {
            branchcode     => $library->id,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            title          => $biblio->title,
            itemnumber     => $item_1->id
        }
    );

    ## Limit on item type is 2, only one hold, success tests

    my $res = CanItemBeReserved( $patron, $item_2, $library->id );
    is_deeply( $res, { status => 'OK' }, 'Holds on itemtype limit not reached' );

    # Add a second hold, biblio-level and item type-constrained
    C4::Reserves::AddReserve(
        {
            branchcode     => $library->id,
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            title          => $biblio->title,
            itemtype       => $itype->id,
        }
    );

    ## Limit on item type is 2, two holds, one of them biblio-level/item type-constrained

    $res = CanItemBeReserved( $patron, $item_2, $library->id );
    is_deeply( $res, { status => 'tooManyReserves', limit => 2 }, 'Holds on itemtype limit reached' );

    $schema->storage->txn_rollback;
};

subtest 'DefaultHoldExpiration tests' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'DefaultHoldExpirationdate',           1 );
    t::lib::Mocks::mock_preference( 'DefaultHoldExpirationdatePeriod',     365 );
    t::lib::Mocks::mock_preference( 'DefaultHoldExpirationdateUnitOfTime', 'days' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item();

    my $reserve_id = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $patron->id,
            biblionumber   => $item->biblionumber,
        }
    );

    my $today = dt_from_string();
    my $hold  = Koha::Holds->find($reserve_id);

    is( $hold->reservedate,    $today->ymd,                     "Hold created today" );
    is( $hold->expirationdate, $today->add( days => 365 )->ymd, "Reserve date set 1 year from today" );

    $schema->txn_rollback;
};

subtest '_Findgroupreserves' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item     = $builder->build_sample_item();
    my $item_2   = $builder->build_sample_item( { biblionumber => $item->biblionumber } );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
    my $reserve_id_1 = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $patron_1->id,
            biblionumber   => $item->biblionumber,
        }
    );
    my $reserve_id_2 = AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $patron_2->id,
            biblionumber   => $item->biblionumber,
        }
    );

    C4::HoldsQueue::AddToHoldTargetMap(
        {
            $item->id => {
                borrowernumber => $patron_1->id, biblionumber => $item->biblionumber,
                holdingbranch  => $item->holdingbranch, item_level => 0, reserve_id => $reserve_id_1
            }
        }
    );

    # When the hold is title level and in the hold fill targets we expect this to be the only hold returned
    my @reserves = C4::Reserves::_Findgroupreserve( $item->biblionumber, $item->id, 0, [] );
    is( scalar @reserves,           1,             "We should only get the hold that is in the map" );
    is( $reserves[0]->{reserve_id}, $reserve_id_1, "We got the expected reserve" );

    C4::HoldsQueue::AddToHoldTargetMap(
        {
            $item_2->id => {
                borrowernumber => $patron_2->id, biblionumber => $item->biblionumber,
                holdingbranch  => $item->holdingbranch, item_level => 1, reserve_id => $reserve_id_2
            }
        }
    );

    # When the hold is title level and in the hold fill targets we expect this to be the only hold returned
    @reserves = C4::Reserves::_Findgroupreserve( $item->biblionumber, $item_2->id, 0, [] );
    is( scalar @reserves,           1,             "We should only get the item level hold that is in the map" );
    is( $reserves[0]->{reserve_id}, $reserve_id_2, "We got the expected reserve" );

    C4::HoldsQueue::AddToHoldTargetMap(
        {
            $item_2->id => {
                borrowernumber => $patron_2->id, biblionumber => $item->biblionumber,
                holdingbranch  => $item->holdingbranch, item_level => 1, reserve_id => $reserve_id_1
            }
        }
    );

    # When the hold is title level and in the hold fill targets we expect this to be the only hold returned
    @reserves = C4::Reserves::_Findgroupreserve( $item->biblionumber, $item_2->id, 0, [] );
    is( scalar @reserves,           1,             "We should still only get the item level hold that is in the map" );
    is( $reserves[0]->{reserve_id}, $reserve_id_1, "We got the expected reserve which has been updated" );

    $schema->txn_rollback;
};

subtest 'HOLDDGST tests' => sub {

    plan tests => 2;
    $schema->storage->txn_begin;

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => {
                branchemail     => 'branch@e.mail',
                branchreplyto   => 'branch@reply.to',
                pickup_location => 1
            }
        }
    );
    my $item = $builder->build_sample_item(
        {
            homebranch    => $branch->branchcode,
            holdingbranch => $branch->branchcode
        }
    );
    my $item2 = $builder->build_sample_item(
        {
            homebranch    => $branch->branchcode,
            holdingbranch => $branch->branchcode
        }
    );

    my $wants_hold_and_email = {
        wants_digest => '1',
        transports   => {
            sms   => 'HOLDDGST',
            email => 'HOLDDGST',
        },
        letter_code => 'HOLDDGST'
    };

    my $mp = Test::MockModule->new('C4::Members::Messaging');

    $mp->mock( "GetMessagingPreferences", $wants_hold_and_email );

    $dbh->do('DELETE FROM letter');

    my $email_hold_notice = $builder->build(
        {
            source => 'Letter',
            value  => {
                message_transport_type => 'email',
                branchcode             => '',
                code                   => 'HOLDDGST',
                module                 => 'reserves',
                lang                   => 'default',
            }
        }
    );

    my $sms_hold_notice = $builder->build(
        {
            source => 'Letter',
            value  => {
                message_transport_type => 'sms',
                branchcode             => '',
                code                   => 'HOLDDGST',
                module                 => 'reserves',
                lang                   => 'default',
            }
        }
    );

    my $hold_borrower = $builder->build(
        {
            source => 'Borrower',
            value  => {
                smsalertnumber => '5555555551',
                email          => 'a@c.com',
            }
        }
    )->{borrowernumber};

    C4::Reserves::AddReserve(
        {
            branchcode     => $item->homebranch,
            borrowernumber => $hold_borrower,
            biblionumber   => $item->biblionumber,
        }
    );

    C4::Reserves::AddReserve(
        {
            branchcode     => $item2->homebranch,
            borrowernumber => $hold_borrower,
            biblionumber   => $item2->biblionumber,
        }
    );

    ModReserveAffect( $item->itemnumber,  $hold_borrower, 0 );
    ModReserveAffect( $item2->itemnumber, $hold_borrower, 0 );

    my $sms_count = $schema->resultset('MessageQueue')->search(
        {
            letter_code            => 'HOLDDGST',
            message_transport_type => 'sms',
            borrowernumber         => $hold_borrower,
        }
    )->count;
    is( $sms_count, 1, "Only one sms hold digest message created for two holds" );

    my $email_count = $schema->resultset('MessageQueue')->search(
        {
            letter_code            => 'HOLDDGST',
            message_transport_type => 'email',
            borrowernumber         => $hold_borrower,
        }
    )->count;
    is( $email_count, 1, "Only one email hold digest message created for two holds" );

    $schema->txn_rollback;
};

# FIXME: This shouldn't be needed if the item type was a FK constraint for items
subtest 'CheckReserves() item type tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $item_type_to_delete = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $non_existent_itype  = $item_type_to_delete->itemtype;
    $item_type_to_delete->delete;

    t::lib::Mocks::mock_preference( 'TrapHoldsOnOrder', 0 );

    my $item = $builder->build_sample_item( { itype => $non_existent_itype, notforloan => 0, damaged => 0 } );

    my ($res) = CheckReserves($item);
    is( $res, '', 'No holds on new item' );

    $schema->storage->txn_rollback;
};

subtest 'Bug 40866: AddReserve override JSON logging' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode }
        }
    );
    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item(
        {
            library      => $library->branchcode,
            biblionumber => $biblio->biblionumber
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $patron, branchcode => $library->branchcode } );
    t::lib::Mocks::mock_preference( 'HoldsLog', 1 );

    # Clear any existing logs
    Koha::ActionLogs->search( { module => 'HOLDS', action => 'CREATE' } )->delete;

    # Test 1: Normal hold without overrides - should log hold ID only
    my $hold_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );
    ok( $hold_id, 'Hold created successfully' );

    my $logs = Koha::ActionLogs->search(
        {
            module => 'HOLDS',
            action => 'CREATE',
            object => $hold_id
        },
        { order_by => { -desc => 'timestamp' } }
    );
    is( $logs->count, 1, 'One log entry created for normal hold' );
    my $log = $logs->next;
    is( $log->info, $hold_id, 'Normal hold logs hold ID only' );

    # Cancel the hold for next test
    my $hold = Koha::Holds->find($hold_id);
    $hold->cancel;

    # Test 2: Hold with override confirmation - should log JSON with confirmations
    my $hold_id2 = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
            confirmations  => ['HOLD_POLICY_OVERRIDE'],
            forced         => []
        }
    );
    ok( $hold_id2, 'Hold with override created successfully' );

    $logs = Koha::ActionLogs->search(
        {
            module => 'HOLDS',
            action => 'CREATE',
            object => $hold_id2
        },
        { order_by => { -desc => 'timestamp' } }
    );
    is( $logs->count, 1, 'One log entry created for override hold' );
    $log = $logs->next;

    my $log_data = eval { from_json( $log->info ) };
    ok( !$@,                               'Log info is valid JSON' );
    ok( exists $log_data->{confirmations}, 'JSON contains confirmations array' );
    is_deeply(
        $log_data->{confirmations},
        ['HOLD_POLICY_OVERRIDE'],
        'Confirmations logged correctly'
    );

    $schema->storage->txn_rollback;
};
