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

use DateTime;
use t::lib::Mocks;
use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Members;
use C4::Reserves;
use C4::Overdues qw(UpdateFine);
use Koha::DateUtils;
use Koha::Database;

use t::lib::TestBuilder;

use Test::More tests => 85;

BEGIN {
    use_ok('C4::Circulation');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{RaiseError} = 1;

# Start with a clean slate
$dbh->do('DELETE FROM issues');

my $library = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});

my $CircControl = C4::Context->preference('CircControl');
my $HomeOrHoldingBranch = C4::Context->preference('HomeOrHoldingBranch');

my $item = {
    homebranch => $library2->{branchcode},
    holdingbranch => $library2->{branchcode}
};

my $borrower = {
    branchcode => $library2->{branchcode}
};

# No userenv, PickupLibrary
t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');
is(
    C4::Context->preference('CircControl'),
    'PickupLibrary',
    'CircControl changed to PickupLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $item->{$HomeOrHoldingBranch},
    '_GetCircControlBranch returned item branch (no userenv defined)'
);

# No userenv, PatronLibrary
t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');
is(
    C4::Context->preference('CircControl'),
    'PatronLibrary',
    'CircControl changed to PatronLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $borrower->{branchcode},
    '_GetCircControlBranch returned borrower branch'
);

# No userenv, ItemHomeLibrary
t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
is(
    C4::Context->preference('CircControl'),
    'ItemHomeLibrary',
    'CircControl changed to ItemHomeLibrary'
);
is(
    $item->{$HomeOrHoldingBranch},
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    '_GetCircControlBranch returned item branch'
);

# Now, set a userenv
C4::Context->_new_userenv('xxx');
C4::Context->set_userenv(0,0,0,'firstname','surname', $library2->{branchcode}, 'Midway Public Library', '', '', '');
is(C4::Context->userenv->{branch}, $library2->{branchcode}, 'userenv set');

# Userenv set, PickupLibrary
t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');
is(
    C4::Context->preference('CircControl'),
    'PickupLibrary',
    'CircControl changed to PickupLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $library2->{branchcode},
    '_GetCircControlBranch returned current branch'
);

# Userenv set, PatronLibrary
t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');
is(
    C4::Context->preference('CircControl'),
    'PatronLibrary',
    'CircControl changed to PatronLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $borrower->{branchcode},
    '_GetCircControlBranch returned borrower branch'
);

# Userenv set, ItemHomeLibrary
t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
is(
    C4::Context->preference('CircControl'),
    'ItemHomeLibrary',
    'CircControl changed to ItemHomeLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    $item->{$HomeOrHoldingBranch},
    '_GetCircControlBranch returned item branch'
);

# Reset initial configuration
t::lib::Mocks::mock_preference('CircControl', $CircControl);
is(
    C4::Context->preference('CircControl'),
    $CircControl,
    'CircControl reset to its initial value'
);

# Set a simple circ policy
$dbh->do('DELETE FROM issuingrules');
$dbh->do(
    q{INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed,
                                maxissueqty, issuelength, lengthunit,
                                renewalsallowed, renewalperiod,
                                norenewalbefore, auto_renew,
                                fine, chargeperiod)
      VALUES (?, ?, ?, ?,
              ?, ?, ?,
              ?, ?,
              ?, ?,
              ?, ?
             )
    },
    {},
    '*', '*', '*', 25,
    20, 14, 'days',
    1, 7,
    undef, 0,
    .10, 1
);

# Test C4::Circulation::ProcessOfflinePayment
my $sth = C4::Context->dbh->prepare("SELECT COUNT(*) FROM accountlines WHERE amount = '-123.45' AND accounttype = 'Pay'");
$sth->execute();
my ( $original_count ) = $sth->fetchrow_array();

C4::Context->dbh->do("INSERT INTO borrowers ( cardnumber, surname, firstname, categorycode, branchcode ) VALUES ( '99999999999', 'Hall', 'Kyle', 'S', ? )", undef, $library2->{branchcode} );

C4::Circulation::ProcessOfflinePayment({ cardnumber => '99999999999', amount => '123.45' });

$sth->execute();
my ( $new_count ) = $sth->fetchrow_array();

ok( $new_count == $original_count  + 1, 'ProcessOfflinePayment makes payment correctly' );

C4::Context->dbh->do("DELETE FROM accountlines WHERE borrowernumber IN ( SELECT borrowernumber FROM borrowers WHERE cardnumber = '99999999999' )");
C4::Context->dbh->do("DELETE FROM borrowers WHERE cardnumber = '99999999999'");
C4::Context->dbh->do("DELETE FROM accountlines");
{
# CanBookBeRenewed tests

    # Generate test biblio
    my $biblio = MARC::Record->new();
    my $title = 'Silence in the library';
    $biblio->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
    );

    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    my $barcode = 'R00000342';
    my $branch = $library2->{branchcode};

    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode,
            replacementprice => 12.00
        },
        $biblionumber
    );

    my $barcode2 = 'R00000343';
    my ( $item_bibnum2, $item_bibitemnum2, $itemnumber2 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode2,
            replacementprice => 23.00
        },
        $biblionumber
    );

    my $barcode3 = 'R00000346';
    my ( $item_bibnum3, $item_bibitemnum3, $itemnumber3 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode3,
            replacementprice => 23.00
        },
        $biblionumber
    );




    # Create borrowers
    my %renewing_borrower_data = (
        firstname =>  'John',
        surname => 'Renewal',
        categorycode => 'S',
        branchcode => $branch,
    );

    my %reserving_borrower_data = (
        firstname =>  'Katrin',
        surname => 'Reservation',
        categorycode => 'S',
        branchcode => $branch,
    );

    my %hold_waiting_borrower_data = (
        firstname =>  'Kyle',
        surname => 'Reservation',
        categorycode => 'S',
        branchcode => $branch,
    );

    my %restricted_borrower_data = (
        firstname =>  'Alice',
        surname => 'Reservation',
        categorycode => 'S',
        debarred => '3228-01-01',
        branchcode => $branch,
    );

    my $renewing_borrowernumber = AddMember(%renewing_borrower_data);
    my $reserving_borrowernumber = AddMember(%reserving_borrower_data);
    my $hold_waiting_borrowernumber = AddMember(%hold_waiting_borrower_data);
    my $restricted_borrowernumber = AddMember(%restricted_borrower_data);

    my $renewing_borrower = GetMember( borrowernumber => $renewing_borrowernumber );
    my $restricted_borrower = GetMember( borrowernumber => $restricted_borrowernumber );

    my $bibitems       = '';
    my $priority       = '1';
    my $resdate        = undef;
    my $expdate        = undef;
    my $notes          = '';
    my $checkitem      = undef;
    my $found          = undef;

    my $issue = AddIssue( $renewing_borrower, $barcode);
    my $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue->date_due(), 1, "Item 1 checked out, due date: " . $issue->date_due() );

    my $issue2 = AddIssue( $renewing_borrower, $barcode2);
    $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue2, 1, "Item 2 checked out, due date: " . $issue2->date_due());


    my $borrowing_borrowernumber = GetItemIssue($itemnumber)->{borrowernumber};
    is ($borrowing_borrowernumber, $renewing_borrowernumber, "Item checked out to $renewing_borrower->{firstname} $renewing_borrower->{surname}");

    my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 1, 'Can renew, no holds for this title or item');


    # Biblio-level hold, renewal test
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    # Testing of feature to allow the renewal of reserved items if other items on the record can fill all needed holds
    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');

    # Now let's add an item level hold, we should no longer be able to renew the item
    my $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
        {
            borrowernumber => $hold_waiting_borrowernumber,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            branchcode     => $branch,
            priority       => 3,
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Bug 13919 - Renewal possible with item level hold on item');
    $hold->delete();

    # Now let's add a waiting hold on the 3rd item, it's no longer available tp check out by just anyone, so we should no longer
    # be able to renew these items
    $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
        {
            borrowernumber => $hold_waiting_borrowernumber,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber3,
            branchcode     => $branch,
            priority       => 0,
            found          => 'W'
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 0, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 0 );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    my $reserveid = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, borrowernumber => $reserving_borrowernumber});
    my $reserving_borrower = GetMember( borrowernumber => $reserving_borrowernumber );
    AddIssue($reserving_borrower, $barcode3);
    my $reserve = $dbh->selectrow_hashref(
        'SELECT * FROM old_reserves WHERE reserve_id = ?',
        { Slice => {} },
        $reserveid
    );
    is($reserve->{found}, 'F', 'hold marked completed when checking out item that fills it');

    # Item-level hold, renewal test
    AddReserve(
        $branch, $reserving_borrowernumber, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $itemnumber, $found
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2, 1);
    is( $renewokay, 1, 'Can renew item 2, item-level hold is on item 1');

    # Items can't fill hold for reasons
    ModItem({ notforloan => 1 }, $biblionumber, $itemnumber);
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber, 1);
    is( $renewokay, 1, 'Can renew, item is marked not for loan, hold does not block');
    ModItem({ notforloan => 0, itype => '' }, $biblionumber, $itemnumber,1);

    # FIXME: Add more for itemtype not for loan etc.

    # Restricted users cannot renew when RestrictionBlockRenewing is enabled
    my $barcode5 = 'R00000347';
    my ( $item_bibnum5, $item_bibitemnum5, $itemnumber5 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode5,
            replacementprice => 23.00
        },
        $biblionumber
    );
    my $datedue5 = AddIssue($restricted_borrower, $barcode5);
    is (defined $datedue5, 1, "Item with date due checked out, due date: $datedue5");

    t::lib::Mocks::mock_preference('RestrictionBlockRenewing','1');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 1, '(Bug 8236), Can renew, user is not restricted');
    ( $renewokay, $error ) = CanBookBeRenewed($restricted_borrowernumber, $itemnumber5);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, user is restricted');

    # Users cannot renew an overdue item
    my $barcode6 = 'R00000348';
    my ( $item_bibnum6, $item_bibitemnum6, $itemnumber6 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode6,
            replacementprice => 23.00
        },
        $biblionumber
    );

    my $barcode7 = 'R00000349';
    my ( $item_bibnum7, $item_bibitemnum7, $itemnumber7 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode7,
            replacementprice => 23.00
        },
        $biblionumber
    );
    my $datedue6 = AddIssue( $renewing_borrower, $barcode6);
    is (defined $datedue6, 1, "Item 2 checked out, due date: $datedue6");

    my $passeddatedue1 = AddIssue($renewing_borrower, $barcode7, DateTime->from_epoch(epoch => 1));
    is (defined $passeddatedue1, 1, "Item with passed date due checked out, due date: $passeddatedue1");


    t::lib::Mocks::mock_preference('OverduesBlockRenewing','blockitem');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber6);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is not overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber7);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is overdue');


    $reserveid = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, itemnumber => $itemnumber, borrowernumber => $reserving_borrowernumber});
    CancelReserve({ reserve_id => $reserveid });

    # Bug 14101
    # Test automatic renewal before value for "norenewalbefore" in policy is set
    # In this case automatic renewal is not permitted prior to due date
    my $barcode4 = '11235813';
    my ( $item_bibnum4, $item_bibitemnum4, $itemnumber4 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode4,
            replacementprice => 16.00
        },
        $biblionumber
    );

    $issue = AddIssue( $renewing_borrower, $barcode4, undef, undef, undef, undef, { auto_renew => 1 } );
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = undef (returned code is auto_too_soon)' );

    # Bug 7413
    # Test premature manual renewal
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 7');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Bug 7413: Cannot renew, renewal is premature');
    is( $error, 'too_soon', 'Bug 7413: Cannot renew, renewal is premature (returned code is too_soon)');

    # Bug 14395
    # Test 'exact time' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'exact_time' );
    is(
        GetSoonestRenewDate( $renewing_borrowernumber, $itemnumber ),
        $datedue->clone->add( days => -7 ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );

    # Bug 14395
    # Test 'date' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'date' );
    is(
        GetSoonestRenewDate( $renewing_borrowernumber, $itemnumber ),
        $datedue->clone->add( days => -7 )->truncate( to => 'day' ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );

    # Bug 14101
    # Test premature automatic renewal
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature (returned code is auto_too_soon)'
    );

    # Change policy so that loans can only be renewed exactly on due date (0 days prior to due date)
    # and test automatic renewal again
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 0');
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = 0 (returned code is auto_too_soon)'
    );

    # Change policy so that loans can be renewed 99 days prior to the due date
    # and test automatic renewal again
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 99');
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic' );
    is( $error, 'auto_renew',
        'Bug 14101: Cannot renew, renewal is automatic (returned code is auto_renew)'
    );

    # Too many renewals

    # set policy to forbid renewals
    $dbh->do('UPDATE issuingrules SET norenewalbefore = NULL, renewalsallowed = 0');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 renewals allowed');
    is( $error, 'too_many', 'Cannot renew, 0 renewals allowed (returned code is too_many)');

    # Test WhenLostForgiveFine and WhenLostChargeReplacementFee
    t::lib::Mocks::mock_preference('WhenLostForgiveFine','1');
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','1');

    C4::Overdues::UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => 15.00,
            type           => q{},
            due            => Koha::DateUtils::output_pref($datedue)
        }
    );

    LostItem( $itemnumber, 1 );

    my $item = Koha::Database->new()->schema()->resultset('Item')->find($itemnumber);
    ok( !$item->onloan(), "Lost item marked as returned has false onloan value" );

    my $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    ok( $total_due == 12, 'Borrower only charged replacement fee with both WhenLostForgiveFine and WhenLostChargeReplacementFee enabled' );

    C4::Context->dbh->do("DELETE FROM accountlines");

    t::lib::Mocks::mock_preference('WhenLostForgiveFine','0');
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','0');

    C4::Overdues::UpdateFine(
        {
            issue_id       => $issue2->id(),
            itemnumber     => $itemnumber2,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => 15.00,
            type           => q{},
            due            => Koha::DateUtils::output_pref($datedue)
        }
    );

    LostItem( $itemnumber2, 0 );

    my $item2 = Koha::Database->new()->schema()->resultset('Item')->find($itemnumber2);
    ok( $item2->onloan(), "Lost item *not* marked as returned has true onloan value" );

    $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    ok( $total_due == 15, 'Borrower only charged fine with both WhenLostForgiveFine and WhenLostChargeReplacementFee disabled' );

    my $now = dt_from_string();
    my $future = dt_from_string();
    $future->add( days => 7 );
    my $units = C4::Overdues::get_chargeable_units('days', $future, $now, $library2->{branchcode});
    ok( $units == 0, '_get_chargeable_units returns 0 for items not past due date (Bug 12596)' );

    # Users cannot renew any item if there is an overdue item
    t::lib::Mocks::mock_preference('OverduesBlockRenewing','block');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber6);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, one of the items is overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber7);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, one of the items is overdue');

  }

{
    # GetUpcomingDueIssues tests
    my $barcode  = 'R00000342';
    my $barcode2 = 'R00000343';
    my $barcode3 = 'R00000344';
    my $branch   = $library2->{branchcode};

    #Create another record
    my $biblio2 = MARC::Record->new();
    my $title2 = 'Something is worng here';
    $biblio2->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Anonymous'),
        MARC::Field->new('245', ' ', ' ', a => $title2),
    );
    my ($biblionumber2, $biblioitemnumber2) = AddBiblio($biblio2, '');

    #Create third item
    AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode3
        },
        $biblionumber2
    );

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Fridolyn',
        surname => 'SOMERS',
        categorycode => 'S',
        branchcode => $branch,
    );

    my $a_borrower_borrowernumber = AddMember(%a_borrower_data);
    my $a_borrower = GetMember( borrowernumber => $a_borrower_borrowernumber );

    my $yesterday = DateTime->today(time_zone => C4::Context->tz())->add( days => -1 );
    my $two_days_ahead = DateTime->today(time_zone => C4::Context->tz())->add( days => 2 );
    my $today = DateTime->today(time_zone => C4::Context->tz());

    my $issue = AddIssue( $a_borrower, $barcode, $yesterday );
    my $datedue = dt_from_string( $issue->date_due() );
    my $issue2 = AddIssue( $a_borrower, $barcode2, $two_days_ahead );
    my $datedue2 = dt_from_string( $issue->date_due() );

    my $upcoming_dues;

    # GetUpcomingDueIssues tests
    for my $i(0..1) {
        $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => $i } );
        is ( scalar( @$upcoming_dues ), 0, "No items due in less than one day ($i days in advance)" );
    }

    #days_in_advance needs to be inclusive, so 1 matches items due tomorrow, 0 items due today etc.
    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => 2 } );
    is ( scalar ( @$upcoming_dues), 1, "Only one item due in 2 days or less" );

    for my $i(3..5) {
        $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => $i } );
        is ( scalar( @$upcoming_dues ), 1,
            "Bug 9362: Only one item due in more than 2 days ($i days in advance)" );
    }

    # Bug 11218 - Due notices not generated - GetUpcomingDueIssues needs to select due today items as well

    my $issue3 = AddIssue( $a_borrower, $barcode3, $today );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => -1 } );
    is ( scalar ( @$upcoming_dues), 0, "Overdues can not be selected" );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => 0 } );
    is ( scalar ( @$upcoming_dues), 1, "1 item is due today" );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => 1 } );
    is ( scalar ( @$upcoming_dues), 1, "1 item is due today, none tomorrow" );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => 2 }  );
    is ( scalar ( @$upcoming_dues), 2, "2 items are due withing 2 days" );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( { days_in_advance => 3 } );
    is ( scalar ( @$upcoming_dues), 2, "2 items are due withing 2 days" );

    $upcoming_dues = C4::Circulation::GetUpcomingDueIssues();
    is ( scalar ( @$upcoming_dues), 2, "days_in_advance is 7 in GetUpcomingDueIssues if not provided" );

}

{
    my $barcode  = '1234567890';
    my $branch   = $library2->{branchcode};

    my $biblio = MARC::Record->new();
    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    #Create third item
    my ( undef, undef, $itemnumber ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode
        },
        $biblionumber
    );

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Kyle',
        surname => 'Hall',
        categorycode => 'S',
        branchcode => $branch,
    );

    my $borrowernumber = AddMember(%a_borrower_data);

    my $issue = AddIssue( GetMember( borrowernumber => $borrowernumber ), $barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $borrowernumber,
            amount         => 0
        }
    );

    my $hr = $dbh->selectrow_hashref(q{SELECT COUNT(*) AS count FROM accountlines WHERE borrowernumber = ? AND itemnumber = ?}, undef, $borrowernumber, $itemnumber );
    my $count = $hr->{count};

    is ( $count, 0, "Calling UpdateFine on non-existant fine with an amount of 0 does not result in an empty fine" );
}

{
    $dbh->do('DELETE FROM issues');
    $dbh->do('DELETE FROM items');
    $dbh->do('DELETE FROM issuingrules');
    $dbh->do(
        q{
        INSERT INTO issuingrules ( categorycode, branchcode, itemtype, reservesallowed, maxissueqty, issuelength, lengthunit, renewalsallowed, renewalperiod,
                    norenewalbefore, auto_renew, fine, chargeperiod ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
        },
        {},
        '*', '*', '*', 25,
        20,  14,  'days',
        1,   7,
        undef,  0,
        .10, 1
    );
    my $biblio = MARC::Record->new();
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $biblio, '' );

    my $barcode1 = '1234';
    my ( undef, undef, $itemnumber1 ) = AddItem(
        {
            homebranch    => $library2->{branchcode},
            holdingbranch => $library2->{branchcode},
            barcode       => $barcode1,
        },
        $biblionumber
    );
    my $barcode2 = '4321';
    my ( undef, undef, $itemnumber2 ) = AddItem(
        {
            homebranch    => $library2->{branchcode},
            holdingbranch => $library2->{branchcode},
            barcode       => $barcode2,
        },
        $biblionumber
    );

    my $borrowernumber1 = AddMember(
        firstname    => 'Kyle',
        surname      => 'Hall',
        categorycode => 'S',
        branchcode   => $library2->{branchcode},
    );
    my $borrowernumber2 = AddMember(
        firstname    => 'Chelsea',
        surname      => 'Hall',
        categorycode => 'S',
        branchcode   => $library2->{branchcode},
    );

    my $borrower1 = GetMember( borrowernumber => $borrowernumber1 );
    my $borrower2 = GetMember( borrowernumber => $borrowernumber2 );

    my $issue = AddIssue( $borrower1, $barcode1 );

    my ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with no hold on the record' );

    AddReserve(
        $library2->{branchcode}, $borrowernumber2, $biblionumber,
        '',  1, undef, undef, '',
        undef, undef, undef
    );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 0");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfholds are disabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 0");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled and onshelfholds is disabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is disabled and onshelfhold is enabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled' );

    # Setting item not checked out to be not for loan but holdable
    ModItem({ notforloan => -1 }, $biblionumber, $itemnumber2);

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $itemnumber1 );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower can not renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled but the only available item is notforloan' );
}

{
    # Don't allow renewing onsite checkout
    my $barcode  = 'R00000XXX';
    my $branch   = $library->{branchcode};

    #Create another record
    my $biblio = MARC::Record->new();
    $biblio->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Anonymous'),
        MARC::Field->new('245', ' ', ' ', a => 'A title'),
    );
    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    my (undef, undef, $itemnumber) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode,
        },
        $biblionumber
    );

    my $borrowernumber = AddMember(
        firstname =>  'fn',
        surname => 'dn',
        categorycode => 'S',
        branchcode => $branch,
    );

    my $borrower = GetMember( borrowernumber => $borrowernumber );
    my $issue = AddIssue( $borrower, $barcode, undef, undef, undef, undef, { onsite_checkout => 1 } );
    my ( $renewed, $error ) = CanBookBeRenewed( $borrowernumber, $itemnumber );
    is( $renewed, 0, 'CanBookBeRenewed should not allow to renew on-site checkout' );
    is( $error, 'onsite_checkout', 'A correct error code should be returned by CanBookBeRenewed for on-site checkout' );
}

{
    my $library = $builder->build({ source => 'Branch' });

    my $biblio = MARC::Record->new();
    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

    my $barcode = 'just a barcode';
    my ( undef, undef, $itemnumber ) = AddItem(
        {
            homebranch       => $library->{branchcode},
            holdingbranch    => $library->{branchcode},
            barcode          => $barcode,
        },
        $biblionumber,
    );

    my $patron = $builder->build({ source => 'Borrower', value => { branchcode => $library->{branchcode} } } );

    my $issue = AddIssue( GetMember( borrowernumber => $patron->{borrowernumber} ), $barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 1,
        }
    );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 2,
        }
    );
    is( Koha::Account::Lines->search({ issue_id => $issue->id })->count, 1, 'UpdateFine should not create a new accountline when updating an existing fine');
}

subtest 'CanBookBeIssued & AllowReturnToBranch' => sub {
    plan tests => 23;

    my $homebranch    = $builder->build( { source => 'Branch' } );
    my $holdingbranch = $builder->build( { source => 'Branch' } );
    my $otherbranch   = $builder->build( { source => 'Branch' } );
    my $patron_1      = $builder->build( { source => 'Borrower' } );
    my $patron_2      = $builder->build( { source => 'Borrower' } );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $item = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $homebranch->{branchcode},
                holdingbranch => $holdingbranch->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->{biblionumber}
            }
        }
    );

    set_userenv($holdingbranch);

    my $issue = AddIssue( $patron_1, $item->{barcode} );
    is( ref($issue), 'Koha::Schema::Result::Issue' );    # FIXME Should be Koha::Issue

    my ( $error, $question, $alerts );

    # AllowReturnToBranch == anywhere
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts),        0 );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1 );
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts),        0 );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1 );
    ## Can be issued from another branch
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts),        0 );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1 );

    # AllowReturnToBranch == holdingbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0 );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1 );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode} );
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts),        0 );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1 );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0 );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1 );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode} );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from holdinbranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts),        0 );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1 );
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0 );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1 );
    is( $error->{branch_to_return},         $homebranch->{branchcode} );
    ## Cannot be issued from holdinbranch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0 );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1 );
    is( $error->{branch_to_return},         $homebranch->{branchcode} );

    # TODO t::lib::Mocks::mock_preference('AllowReturnToBranch', 'homeorholdingbranch');
};

sub set_userenv {
    my ( $library ) = @_;
    C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, $library->{branchname}, '', '', '');
}

1;
