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
use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Members;
use C4::Reserves;
use C4::Overdues qw(UpdateFine);
use Koha::DateUtils;
use Koha::Database;

use Test::More tests => 60;

BEGIN {
    use_ok('C4::Circulation');
}

my $dbh = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Start with a clean slate
$dbh->do('DELETE FROM issues');

my $CircControl = C4::Context->preference('CircControl');
my $HomeOrHoldingBranch = C4::Context->preference('HomeOrHoldingBranch');

my $item = {
    homebranch => 'MPL',
    holdingbranch => 'MPL'
};

my $borrower = {
    branchcode => 'MPL'
};

# No userenv, PickupLibrary
C4::Context->set_preference('CircControl', 'PickupLibrary');
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
C4::Context->set_preference('CircControl', 'PatronLibrary');
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
C4::Context->set_preference('CircControl', 'ItemHomeLibrary');
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
C4::Context::set_userenv(0,0,0,'firstname','surname', 'MPL', 'Midway Public Library', '', '', '');
is(C4::Context->userenv->{branch}, 'MPL', 'userenv set');

# Userenv set, PickupLibrary
C4::Context->set_preference('CircControl', 'PickupLibrary');
is(
    C4::Context->preference('CircControl'),
    'PickupLibrary',
    'CircControl changed to PickupLibrary'
);
is(
    C4::Circulation::_GetCircControlBranch($item, $borrower),
    'MPL',
    '_GetCircControlBranch returned current branch'
);

# Userenv set, PatronLibrary
C4::Context->set_preference('CircControl', 'PatronLibrary');
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
C4::Context->set_preference('CircControl', 'ItemHomeLibrary');
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
C4::Context->set_preference('CircControl', $CircControl);
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
    '', 0,
    .10, 1
);

# Test C4::Circulation::ProcessOfflinePayment
my $sth = C4::Context->dbh->prepare("SELECT COUNT(*) FROM accountlines WHERE amount = '-123.45' AND accounttype = 'Pay'");
$sth->execute();
my ( $original_count ) = $sth->fetchrow_array();

C4::Context->dbh->do("INSERT INTO borrowers ( cardnumber, surname, firstname, categorycode, branchcode ) VALUES ( '99999999999', 'Hall', 'Kyle', 'S', 'MPL' )");

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
    my $branch = 'MPL';

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

    my $renewing_borrowernumber = AddMember(%renewing_borrower_data);
    my $reserving_borrowernumber = AddMember(%reserving_borrower_data);
    my $hold_waiting_borrowernumber = AddMember(%hold_waiting_borrower_data);

    my $renewing_borrower = GetMember( borrowernumber => $renewing_borrowernumber );

    my $constraint     = 'a';
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
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    # Testing of feature to allow the renewal of reserved items if other items on the record can fill all needed holds
    C4::Context->set_preference('AllowOnShelfHolds', 1 );
    C4::Context->set_preference('AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber2);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    # Now let's add a waiting hold on the 3rd item, it's no longer available tp check out by just anyone, so we should no longer
    # be able to renew these items
    my $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
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
    C4::Context->set_preference('AllowRenewalIfOtherItemsAvailable', 0 );

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
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
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

    $reserveid = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, itemnumber => $itemnumber, borrowernumber => $reserving_borrowernumber});
    CancelReserve({ reserve_id => $reserveid });

    # Test automatic renewal before value for "norenewalbefore" in policy is set
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

    AddIssue( $renewing_borrower, $barcode4, undef, undef, undef, undef, { auto_renew => 1 } );
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Cannot renew, renewal is automatic' );
    is( $error, 'auto_renew',
        'Cannot renew, renewal is automatic (returned code is auto_renew)' );

    # set policy to require that loans cannot be
    # renewed until seven days prior to the due date
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 7');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Cannot renew, renewal is premature');
    is( $error, 'too_soon', 'Cannot renew, renewal is premature (returned code is too_soon)');
    is(
        GetSoonestRenewDate($renewing_borrowernumber, $itemnumber),
        $datedue->clone->add(days => -7),
        'renewals permitted 7 days before due date, as expected',
    );

    # Test automatic renewal again
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $itemnumber4 );
    is( $renewokay, 0, 'Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
'Cannot renew, renewal is automatic and premature (returned code is auto_too_soon)'
    );

    # Too many renewals

    # set policy to forbid renewals
    $dbh->do('UPDATE issuingrules SET norenewalbefore = NULL, renewalsallowed = 0');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 renewals allowed');
    is( $error, 'too_many', 'Cannot renew, 0 renewals allowed (returned code is too_many)');

    # Test WhenLostForgiveFine and WhenLostChargeReplacementFee
    C4::Context->set_preference('WhenLostForgiveFine','1');
    C4::Context->set_preference('WhenLostChargeReplacementFee','1');

    C4::Overdues::UpdateFine( $itemnumber, $renewing_borrower->{borrowernumber},
        15.00, q{}, Koha::DateUtils::output_pref($datedue) );

    LostItem( $itemnumber, 1 );

    my $item = $schema->resultset('Item')->find( $itemnumber );
    ok( !$item->onloan(), "Lost item marked as returned has false onloan value" );

    my $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    ok( $total_due == 12, 'Borrower only charged replacement fee with both WhenLostForgiveFine and WhenLostChargeReplacementFee enabled' );

    C4::Context->dbh->do("DELETE FROM accountlines");

    C4::Context->set_preference('WhenLostForgiveFine','0');
    C4::Context->set_preference('WhenLostChargeReplacementFee','0');

    C4::Overdues::UpdateFine( $itemnumber2, $renewing_borrower->{borrowernumber},
        15.00, q{}, Koha::DateUtils::output_pref($datedue) );

    LostItem( $itemnumber2, 0 );

    my $item2 = $schema->resultset('Item')->find( $itemnumber2 );
    ok( $item2->onloan(), "Lost item *not* marked as returned has true onloan value" );

    $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    ok( $total_due == 15, 'Borrower only charged fine with both WhenLostForgiveFine and WhenLostChargeReplacementFee disabled' );

    my $now = dt_from_string();
    my $future = dt_from_string();
    $future->add( days => 7 );
    my $units = C4::Overdues::get_chargeable_units('days', $future, $now, 'MPL');
    ok( $units == 0, '_get_chargeable_units returns 0 for items not past due date (Bug 12596)' );
}

{
    # GetUpcomingDueIssues tests
    my $barcode  = 'R00000342';
    my $barcode2 = 'R00000343';
    my $barcode3 = 'R00000344';
    my $branch   = 'MPL';

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
    my $branch   = 'MPL';

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

    UpdateFine( $itemnumber, $borrowernumber, 0 );

    my $hr = $dbh->selectrow_hashref(q{SELECT COUNT(*) AS count FROM accountlines WHERE borrowernumber = ? AND itemnumber = ?}, undef, $borrowernumber, $itemnumber );
    my $count = $hr->{count};

    is ( $count, 0, "Calling UpdateFine on non-existant fine with an amount of 0 does not result in an empty fine" );
}

$dbh->rollback;

1;
