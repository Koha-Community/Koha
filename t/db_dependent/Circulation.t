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

use Test::More tests => 114;

use DateTime;
use POSIX qw( floor );
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Log;
use C4::Members;
use C4::Reserves;
use C4::Overdues qw(UpdateFine CalcFine);
use Koha::DateUtils;
use Koha::Database;
use Koha::IssuingRules;
use Koha::Checkouts;
use Koha::Patrons;
use Koha::Subscriptions;
use Koha::Account::Lines;
use Koha::Account::Offsets;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{RaiseError} = 1;

# Start with a clean slate
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM borrowers');

my $library = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $itemtype = $builder->build(
    {   source => 'Itemtype',
        value  => { notforloan => undef, rentalcharge => 0, defaultreplacecost => undef, processfee => undef }
    }
)->{itemtype};
my $patron_category = $builder->build(
    {
        source => 'Category',
        value  => {
            category_type                 => 'P',
            enrolmentfee                  => 0,
            BlockExpiredPatronOpacActions => -1, # Pick the pref value
        }
    }
);

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
t::lib::Mocks::mock_preference('IndependentBranches', '0');
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

C4::Context->dbh->do("INSERT INTO borrowers ( cardnumber, surname, firstname, categorycode, branchcode ) VALUES ( '99999999999', 'Hall', 'Kyle', ?, ? )", undef, $patron_category->{categorycode}, $library2->{branchcode} );

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
    my $title = 'Silence in the library';
    my ($biblionumber, $biblioitemnumber) = add_biblio($title, 'Moffat, Steven');

    my $barcode = 'R00000342';
    my $branch = $library2->{branchcode};

    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode,
            replacementprice => 12.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $barcode2 = 'R00000343';
    my ( $item_bibnum2, $item_bibitemnum2, $itemnumber2 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode2,
            replacementprice => 23.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $barcode3 = 'R00000346';
    my ( $item_bibnum3, $item_bibitemnum3, $itemnumber3 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode3,
            replacementprice => 23.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    # Create borrowers
    my %renewing_borrower_data = (
        firstname =>  'John',
        surname => 'Renewal',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my %reserving_borrower_data = (
        firstname =>  'Katrin',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my %hold_waiting_borrower_data = (
        firstname =>  'Kyle',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my %restricted_borrower_data = (
        firstname =>  'Alice',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        debarred => '3228-01-01',
        branchcode => $branch,
    );

    my %expired_borrower_data = (
        firstname =>  'Ça',
        surname => 'Glisse',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
        dateexpiry => dt_from_string->subtract( months => 1 ),
    );

    my $renewing_borrowernumber = AddMember(%renewing_borrower_data);
    my $reserving_borrowernumber = AddMember(%reserving_borrower_data);
    my $hold_waiting_borrowernumber = AddMember(%hold_waiting_borrower_data);
    my $restricted_borrowernumber = AddMember(%restricted_borrower_data);
    my $expired_borrowernumber = AddMember(%expired_borrower_data);

    my $renewing_borrower = Koha::Patrons->find( $renewing_borrowernumber )->unblessed;
    my $restricted_borrower = Koha::Patrons->find( $restricted_borrowernumber )->unblessed;
    my $expired_borrower = Koha::Patrons->find( $expired_borrowernumber )->unblessed;

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


    my $borrowing_borrowernumber = Koha::Checkouts->find( { itemnumber => $itemnumber } )->borrowernumber;
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

    my $reserveid = Koha::Holds->search({ biblionumber => $biblionumber, borrowernumber => $reserving_borrowernumber })->next->reserve_id;
    my $reserving_borrower = Koha::Patrons->find( $reserving_borrowernumber )->unblessed;
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
    ModItem({ notforloan => 0, itype => $itemtype }, $biblionumber, $itemnumber);

    # FIXME: Add more for itemtype not for loan etc.

    # Restricted users cannot renew when RestrictionBlockRenewing is enabled
    my $barcode5 = 'R00000347';
    my ( $item_bibnum5, $item_bibitemnum5, $itemnumber5 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode5,
            replacementprice => 23.00,
            itype            => $itemtype
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
            replacementprice => 23.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $barcode7 = 'R00000349';
    my ( $item_bibnum7, $item_bibitemnum7, $itemnumber7 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode7,
            replacementprice => 23.00,
            itype            => $itemtype
        },
        $biblionumber
    );
    my $datedue6 = AddIssue( $renewing_borrower, $barcode6);
    is (defined $datedue6, 1, "Item 2 checked out, due date: ".$datedue6->date_due);

    my $now = dt_from_string();
    my $five_weeks = DateTime::Duration->new(weeks => 5);
    my $five_weeks_ago = $now - $five_weeks;
    t::lib::Mocks::mock_preference('finesMode', 'production');

    my $passeddatedue1 = AddIssue($renewing_borrower, $barcode7, $five_weeks_ago);
    is (defined $passeddatedue1, 1, "Item with passed date due checked out, due date: " . $passeddatedue1->date_due);

    my ( $fine ) = CalcFine( GetItem(undef, $barcode7), $renewing_borrower->{categorycode}, $branch, $five_weeks_ago, $now );
    C4::Overdues::UpdateFine(
        {
            issue_id       => $passeddatedue1->id(),
            itemnumber     => $itemnumber7,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => $fine,
            type           => 'FU',
            due            => Koha::DateUtils::output_pref($five_weeks_ago)
        }
    );

    t::lib::Mocks::mock_preference('RenewalLog', 0);
    my $date = output_pref( { dt => dt_from_string(), datenonly => 1, dateformat => 'iso' } );
    my $old_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddRenewal( $renewing_borrower->{borrowernumber}, $itemnumber7, $branch );
    my $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_log_size, 'renew log not added because of the syspref RenewalLog');

    t::lib::Mocks::mock_preference('RenewalLog', 1);
    $date = output_pref( { dt => dt_from_string(), datenonly => 1, dateformat => 'iso' } );
    $old_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddRenewal( $renewing_borrower->{borrowernumber}, $itemnumber7, $branch );
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_log_size + 1, 'renew log successfully added');

    my $fines = Koha::Account::Lines->search( { borrowernumber => $renewing_borrower->{borrowernumber}, itemnumber => $itemnumber7 } );
    is( $fines->count, 2 );
    is( $fines->next->accounttype, 'F', 'Fine on renewed item is closed out properly' );
    is( $fines->next->accounttype, 'F', 'Fine on renewed item is closed out properly' );
    $fines->delete();


    my $old_issue_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["ISSUE"]) } );
    my $old_renew_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddIssue( $renewing_borrower,$barcode7,Koha::DateUtils::output_pref({str=>$datedue6->date_due, dateformat =>'iso'}),0,$date, 0, undef );
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_renew_log_size + 1, 'renew log successfully added when renewed via issuing');
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["ISSUE"]) } );
    is ($new_log_size, $old_issue_log_size, 'renew not logged as issue when renewed via issuing');

    $fines = Koha::Account::Lines->search( { borrowernumber => $renewing_borrower->{borrowernumber}, itemnumber => $itemnumber7 } );
    $fines->delete();

    t::lib::Mocks::mock_preference('OverduesBlockRenewing','blockitem');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber6);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is not overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber7);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is overdue');


    $hold = Koha::Holds->search({ biblionumber => $biblionumber, borrowernumber => $reserving_borrowernumber })->next;
    $hold->cancel;

    # Bug 14101
    # Test automatic renewal before value for "norenewalbefore" in policy is set
    # In this case automatic renewal is not permitted prior to due date
    my $barcode4 = '11235813';
    my ( $item_bibnum4, $item_bibitemnum4, $itemnumber4 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode4,
            replacementprice => 16.00,
            itype            => $itemtype
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

    subtest "too_late_renewal / no_auto_renewal_after" => sub {
        plan tests => 14;
        my $item_to_auto_renew = $builder->build(
            {   source => 'Item',
                value  => {
                    biblionumber  => $biblionumber,
                    homebranch    => $branch,
                    holdingbranch => $branch,
                }
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead  = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = 9');
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = 10');
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot auto renew, too late - no_auto_renewal_after is inclusive(returned code is auto_too_late)' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = 11');
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_soon', 'Cannot auto renew, too soon - no_auto_renewal_after is defined(returned code is auto_too_soon)' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 11');
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0,            'Do not renew, renewal is automatic' );
        is( $error,     'auto_renew', 'Cannot renew, renew is automatic' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = NULL, no_auto_renewal_after_hard_limit = ?', undef, dt_from_string->add( days => -1 ) );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = 15, no_auto_renewal_after_hard_limit = ?', undef, dt_from_string->add( days => -1 ) );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = NULL, no_auto_renewal_after_hard_limit = ?', undef, dt_from_string->add( days => 1 ) );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Cannot renew, renew is automatic' );
    };

    subtest "auto_too_much_oweing | OPACFineNoRenewalsBlockAutoRenew" => sub {
        plan tests => 6;
        my $item_to_auto_renew = $builder->build({
            source => 'Item',
            value => {
                biblionumber => $biblionumber,
                homebranch       => $branch,
                holdingbranch    => $branch,
            }
        });

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 11');
        C4::Context->set_preference('OPACFineNoRenewalsBlockAutoRenew','1');
        C4::Context->set_preference('OPACFineNoRenewals','10');
        my $fines_amount = 5;
        C4::Accounts::manualinvoice( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber}, "Some fines", 'F', $fines_amount );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, OPACFineNoRenewals=10, patron has 5' );

        C4::Accounts::manualinvoice( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber}, "Some fines", 'F', $fines_amount );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, OPACFineNoRenewals=10, patron has 10' );

        C4::Accounts::manualinvoice( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber}, "Some fines", 'F', $fines_amount );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_much_oweing', 'Cannot auto renew, OPACFineNoRenewals=10, patron has 15' );

        $dbh->do('DELETE FROM accountlines WHERE borrowernumber=?', undef, $renewing_borrowernumber);
    };

    subtest "auto_account_expired | BlockExpiredPatronOpacActions" => sub {
        plan tests => 6;
        my $item_to_auto_renew = $builder->build({
            source => 'Item',
            value => {
                biblionumber => $biblionumber,
                homebranch       => $branch,
                holdingbranch    => $branch,
            }
        });

        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 11');

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead = dt_from_string->add( days => 10 );

        # Patron is expired and BlockExpiredPatronOpacActions=0
        # => auto renew is allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 0);
        my $patron = $expired_borrower;
        my $checkout = AddIssue( $patron, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, patron is expired but BlockExpiredPatronOpacActions=0' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;


        # Patron is expired and BlockExpiredPatronOpacActions=1
        # => auto renew is not allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 1);
        $patron = $expired_borrower;
        $checkout = AddIssue( $patron, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_account_expired', 'Can not auto renew, lockExpiredPatronOpacActions=1 and patron is expired' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;


        # Patron is not expired and BlockExpiredPatronOpacActions=1
        # => auto renew is allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 1);
        $patron = $renewing_borrower;
        $checkout = AddIssue( $patron, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->{itemnumber} );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, BlockExpiredPatronOpacActions=1 but patron is not expired' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;
    };

    subtest "GetLatestAutoRenewDate" => sub {
        plan tests => 5;
        my $item_to_auto_renew = $builder->build(
            {   source => 'Item',
                value  => {
                    biblionumber  => $biblionumber,
                    homebranch    => $branch,
                    holdingbranch => $branch,
                }
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead  = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->{barcode}, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        $dbh->do('UPDATE issuingrules SET norenewalbefore = 7, no_auto_renewal_after = NULL, no_auto_renewal_after_hard_limit = NULL');
        my $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $latest_auto_renew_date, undef, 'GetLatestAutoRenewDate should return undef if no_auto_renewal_after or no_auto_renewal_after_hard_limit are not defined' );
        my $five_days_before = dt_from_string->add( days => -5 );
        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 5, no_auto_renewal_after_hard_limit = NULL');
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $latest_auto_renew_date->truncate( to => 'minute' ),
            $five_days_before->truncate( to => 'minute' ),
            'GetLatestAutoRenewDate should return -5 days if no_auto_renewal_after = 5 and date_due is 10 days before'
        );
        my $five_days_ahead = dt_from_string->add( days => 5 );
        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 15, no_auto_renewal_after_hard_limit = NULL');
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $latest_auto_renew_date->truncate( to => 'minute' ),
            $five_days_ahead->truncate( to => 'minute' ),
            'GetLatestAutoRenewDate should return +5 days if no_auto_renewal_after = 15 and date_due is 10 days before'
        );
        my $two_days_ahead = dt_from_string->add( days => 2 );
        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = NULL, no_auto_renewal_after_hard_limit = ?', undef, dt_from_string->add( days => 2 ) );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $latest_auto_renew_date->truncate( to => 'day' ),
            $two_days_ahead->truncate( to => 'day' ),
            'GetLatestAutoRenewDate should return +2 days if no_auto_renewal_after_hard_limit is defined and not no_auto_renewal_after'
        );
        $dbh->do('UPDATE issuingrules SET norenewalbefore = 10, no_auto_renewal_after = 15, no_auto_renewal_after_hard_limit = ?', undef, dt_from_string->add( days => 2 ) );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->{itemnumber} );
        is( $latest_auto_renew_date->truncate( to => 'day' ),
            $two_days_ahead->truncate( to => 'day' ),
            'GetLatestAutoRenewDate should return +2 days if no_auto_renewal_after_hard_limit is < no_auto_renewal_after'
        );

    };

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

    my $line = Koha::Account::Lines->search({ borrowernumber => $renewing_borrower->{borrowernumber} })->next();
    is( $line->accounttype, 'FU', 'Account line type is FU' );
    is( $line->lastincrement, '15.000000', 'Account line last increment is 15.00' );
    is( $line->amountoutstanding, '15.000000', 'Account line amount outstanding is 15.00' );
    is( $line->amount, '15.000000', 'Account line amount is 15.00' );
    is( $line->issue_id, $issue->id, 'Account line issue id matches' );

    my $offset = Koha::Account::Offsets->search({ debit_id => $line->id })->next();
    is( $offset->type, 'Fine', 'Account offset type is Fine' );
    is( $offset->amount, '15.000000', 'Account offset amount is 15.00' );

    t::lib::Mocks::mock_preference('WhenLostForgiveFine','0');
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','0');

    LostItem( $itemnumber, 1 );

    my $item = Koha::Database->new()->schema()->resultset('Item')->find($itemnumber);
    ok( !$item->onloan(), "Lost item marked as returned has false onloan value" );

    my $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    is( $total_due, '15.000000', 'Borrower only charged replacement fee with both WhenLostForgiveFine and WhenLostChargeReplacementFee enabled' );

    C4::Context->dbh->do("DELETE FROM accountlines");

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
    my $title2 = 'Something is worng here';
    my ($biblionumber2, $biblioitemnumber2) = add_biblio($title2, 'Anonymous');

    #Create third item
    AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode3,
            itype            => $itemtype
        },
        $biblionumber2
    );

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Fridolyn',
        surname => 'SOMERS',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my $a_borrower_borrowernumber = AddMember(%a_borrower_data);
    my $a_borrower = Koha::Patrons->find( $a_borrower_borrowernumber )->unblessed;

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

    my ($biblionumber, $biblioitemnumber) = add_biblio();

    #Create third item
    my ( undef, undef, $itemnumber ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode,
            itype            => $itemtype
        },
        $biblionumber
    );

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Kyle',
        surname => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my $borrowernumber = AddMember(%a_borrower_data);

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
    my $issue = AddIssue( $borrower, $barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $borrowernumber,
            amount         => 0,
            type           => q{}
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
    my ( $biblionumber, $biblioitemnumber ) = add_biblio();

    my $barcode1 = '1234';
    my ( undef, undef, $itemnumber1 ) = AddItem(
        {
            homebranch    => $library2->{branchcode},
            holdingbranch => $library2->{branchcode},
            barcode       => $barcode1,
            itype         => $itemtype
        },
        $biblionumber
    );
    my $barcode2 = '4321';
    my ( undef, undef, $itemnumber2 ) = AddItem(
        {
            homebranch    => $library2->{branchcode},
            holdingbranch => $library2->{branchcode},
            barcode       => $barcode2,
            itype         => $itemtype
        },
        $biblionumber
    );

    my $borrowernumber1 = AddMember(
        firstname    => 'Kyle',
        surname      => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library2->{branchcode},
    );
    my $borrowernumber2 = AddMember(
        firstname    => 'Chelsea',
        surname      => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library2->{branchcode},
    );

    my $borrower1 = Koha::Patrons->find( $borrowernumber1 )->unblessed;
    my $borrower2 = Koha::Patrons->find( $borrowernumber2 )->unblessed;

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
    my ($biblionumber, $biblioitemnumber) = add_biblio('A title', 'Anonymous');

    my (undef, undef, $itemnumber) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $borrowernumber = AddMember(
        firstname =>  'fn',
        surname => 'dn',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

    my $issue = AddIssue( $borrower, $barcode, undef, undef, undef, undef, { onsite_checkout => 1 } );
    my ( $renewed, $error ) = CanBookBeRenewed( $borrowernumber, $itemnumber );
    is( $renewed, 0, 'CanBookBeRenewed should not allow to renew on-site checkout' );
    is( $error, 'onsite_checkout', 'A correct error code should be returned by CanBookBeRenewed for on-site checkout' );
}

{
    my $library = $builder->build({ source => 'Branch' });

    my ($biblionumber, $biblioitemnumber) = add_biblio();

    my $barcode = 'just a barcode';
    my ( undef, undef, $itemnumber ) = AddItem(
        {
            homebranch       => $library->{branchcode},
            holdingbranch    => $library->{branchcode},
            barcode          => $barcode,
            itype            => $itemtype
        },
        $biblionumber,
    );

    my $patron = $builder->build({ source => 'Borrower', value => { branchcode => $library->{branchcode}, categorycode => $patron_category->{categorycode} } } );

    my $issue = AddIssue( $patron, $barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 1,
            type           => q{}
        }
    );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 2,
            type           => q{}
        }
    );
    is( Koha::Account::Lines->search({ issue_id => $issue->id })->count, 1, 'UpdateFine should not create a new accountline when updating an existing fine');
}

subtest 'CanBookBeIssued & AllowReturnToBranch' => sub {
    plan tests => 23;

    my $homebranch    = $builder->build( { source => 'Branch' } );
    my $holdingbranch = $builder->build( { source => 'Branch' } );
    my $otherbranch   = $builder->build( { source => 'Branch' } );
    my $patron_1      = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );
    my $patron_2      = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $item = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $homebranch->{branchcode},
                holdingbranch => $holdingbranch->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                restricted    => 0,
                biblionumber  => $biblioitem->{biblionumber}
            }
        }
    );

    set_userenv($holdingbranch);

    my $issue = AddIssue( $patron_1->unblessed, $item->{barcode} );
    is( ref($issue), 'Koha::Schema::Result::Issue' );    # FIXME Should be Koha::Checkout

    my ( $error, $question, $alerts );

    # AllowReturnToBranch == anywhere
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Can be issued from another branch
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );

    # AllowReturnToBranch == holdingbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode} );
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode} );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from holdinbranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $homebranch->{branchcode} );
    ## Cannot be issued from holdinbranch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $homebranch->{branchcode} );

    # TODO t::lib::Mocks::mock_preference('AllowReturnToBranch', 'homeorholdingbranch');
};

subtest 'AddIssue & AllowReturnToBranch' => sub {
    plan tests => 9;

    my $homebranch    = $builder->build( { source => 'Branch' } );
    my $holdingbranch = $builder->build( { source => 'Branch' } );
    my $otherbranch   = $builder->build( { source => 'Branch' } );
    my $patron_1      = $builder->build( { source => 'Borrower', value => { categorycode => $patron_category->{categorycode} } } );
    my $patron_2      = $builder->build( { source => 'Borrower', value => { categorycode => $patron_category->{categorycode} } } );

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

    my $ref_issue = 'Koha::Schema::Result::Issue'; # FIXME Should be Koha::Checkout
    my $issue = AddIssue( $patron_1, $item->{barcode} );

    my ( $error, $question, $alerts );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Can be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue

    # AllowReturnToBranch == holdinbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '' );
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '' );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '' );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '' );
    # TODO t::lib::Mocks::mock_preference('AllowReturnToBranch', 'homeorholdingbranch');
};

subtest 'CanBookBeIssued + Koha::Patron->is_debarred|has_overdues' => sub {
    plan tests => 8;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblioitem_1 = $builder->build( { source => 'Biblioitem' } );
    my $item_1 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                restricted    => 0,
                biblionumber  => $biblioitem_1->{biblionumber}
            }
        }
    );
    my $biblioitem_2 = $builder->build( { source => 'Biblioitem' } );
    my $item_2 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                restricted    => 0,
                biblionumber  => $biblioitem_2->{biblionumber}
            }
        }
    );

    my ( $error, $question, $alerts );

    # Patron cannot issue item_1, they have overdues
    my $yesterday = DateTime->today( time_zone => C4::Context->tz() )->add( days => -1 );
    my $issue = AddIssue( $patron->unblessed, $item_1->{barcode}, $yesterday );    # Add an overdue

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'confirmation' );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$error) + keys(%$alerts),  0, 'No key for error and alert' . str($error, $question, $alerts) );
    is( $question->{USERBLOCKEDOVERDUE}, 1, 'OverduesBlockCirc=confirmation, USERBLOCKEDOVERDUE should be set for question' );

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'block' );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDOVERDUE},      1, 'OverduesBlockCirc=block, USERBLOCKEDOVERDUE should be set for error' );

    # Patron cannot issue item_1, they are debarred
    my $tomorrow = DateTime->today( time_zone => C4::Context->tz() )->add( days => 1 );
    Koha::Patron::Debarments::AddDebarment( { borrowernumber => $patron->borrowernumber, expiration => $tomorrow } );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDWITHENDDATE}, output_pref( { dt => $tomorrow, dateformat => 'sql', dateonly => 1 } ), 'USERBLOCKEDWITHENDDATE should be tomorrow' );

    Koha::Patron::Debarments::AddDebarment( { borrowernumber => $patron->borrowernumber } );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDNOENDDATE},    '9999-12-31', 'USERBLOCKEDNOENDDATE should be 9999-12-31 for unlimited debarments' );
};

subtest 'CanBookBeIssued + Statistic patrons "X"' => sub {
    plan tests => 1;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category_x = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'X' }
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode  => $patron_category_x->categorycode,
                gonenoaddress => undef,
                lost          => undef,
                debarred      => undef,
                borrowernotes => ""
            }
        }
    );
    my $biblioitem_1 = $builder->build( { source => 'Biblioitem' } );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                restricted    => 0,
                biblionumber  => $biblioitem_1->{biblionumber}
            }
        }
    );

    my ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_1->{barcode} );
    is( $error->{STATS}, 1, '"Error" flag "STATS" must be set if CanBookBeIssued is called with a statistic patron (category_type=X)' );

    # TODO There are other tests to provide here
};

subtest 'MultipleReserves' => sub {
    plan tests => 3;

    my $title = 'Silence in the library';
    my ($biblionumber, $biblioitemnumber) = add_biblio($title, 'Moffat, Steven');

    my $branch = $library2->{branchcode};

    my $barcode1 = 'R00110001';
    my ( $item_bibnum1, $item_bibitemnum1, $itemnumber1 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode1,
            replacementprice => 12.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $barcode2 = 'R00110002';
    my ( $item_bibnum2, $item_bibitemnum2, $itemnumber2 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode2,
            replacementprice => 12.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $bibitems       = '';
    my $priority       = '1';
    my $resdate        = undef;
    my $expdate        = undef;
    my $notes          = '';
    my $checkitem      = undef;
    my $found          = undef;

    my %renewing_borrower_data = (
        firstname =>  'John',
        surname => 'Renewal',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $renewing_borrowernumber = AddMember(%renewing_borrower_data);
    my $renewing_borrower = Koha::Patrons->find( $renewing_borrowernumber )->unblessed;
    my $issue = AddIssue( $renewing_borrower, $barcode1);
    my $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue->date_due(), 1, "item 1 checked out");
    my $borrowing_borrowernumber = Koha::Checkouts->find({ itemnumber => $itemnumber1 })->borrowernumber;

    my %reserving_borrower_data1 = (
        firstname =>  'Katrin',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $reserving_borrowernumber1 = AddMember(%reserving_borrower_data1);
    AddReserve(
        $branch, $reserving_borrowernumber1, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    my %reserving_borrower_data2 = (
        firstname =>  'Kirk',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $reserving_borrowernumber2 = AddMember(%reserving_borrower_data2);
    AddReserve(
        $branch, $reserving_borrowernumber2, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title, $checkitem, $found
    );

    {
        my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber1, 1);
        is($renewokay, 0, 'Bug 17941 - should cover the case where 2 books are both reserved, so failing');
    }

    my $barcode3 = 'R00110003';
    my ( $item_bibnum3, $item_bibitemnum3, $itemnumber3 ) = AddItem(
        {
            homebranch       => $branch,
            holdingbranch    => $branch,
            barcode          => $barcode3,
            replacementprice => 12.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    {
        my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $itemnumber1, 1);
        is($renewokay, 1, 'Bug 17941 - should cover the case where 2 books are reserved, but a third one is available');
    }
};

subtest 'CanBookBeIssued + AllowMultipleIssuesOnABiblio' => sub {
    plan tests => 5;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $biblionumber = $biblioitem->{biblionumber};
    my $item_1 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblionumber,
            }
        }
    );
    my $item_2 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblionumber,
            }
        }
    );

    my ( $error, $question, $alerts );
    my $issue = AddIssue( $patron->unblessed, $item_1->{barcode}, dt_from_string->add( days => 1 ) );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 0);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$error) + keys(%$alerts),  0, 'No error or alert should be raised' . str($error, $question, $alerts) );
    is( $question->{BIBLIO_ALREADY_ISSUED}, 1, 'BIBLIO_ALREADY_ISSUED question flag should be set if AllowMultipleIssuesOnABiblio=0 and issue already exists' . str($error, $question, $alerts) );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 1);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$error) + keys(%$question) + keys(%$alerts),  0, 'No BIBLIO_ALREADY_ISSUED flag should be set if AllowMultipleIssuesOnABiblio=1' . str($error, $question, $alerts) );

    # Add a subscription
    Koha::Subscription->new({ biblionumber => $biblionumber })->store;

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 0);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$error) + keys(%$question) + keys(%$alerts),  0, 'No BIBLIO_ALREADY_ISSUED flag should be set if it is a subscription' . str($error, $question, $alerts) );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 1);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->{barcode} );
    is( keys(%$error) + keys(%$question) + keys(%$alerts),  0, 'No BIBLIO_ALREADY_ISSUED flag should be set if it is a subscription' . str($error, $question, $alerts) );
};

subtest 'AddReturn + CumulativeRestrictionPeriods' => sub {
    plan tests => 8;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build( { source => 'Borrower', value => { categorycode => $patron_category->{categorycode} } } );

    # Add 2 items
    my $biblioitem_1 = $builder->build( { source => 'Biblioitem' } );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem_1->{biblionumber}
            }
        }
    );
    my $biblioitem_2 = $builder->build( { source => 'Biblioitem' } );
    my $item_2 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem_2->{biblionumber}
            }
        }
    );

    # And the issuing rule
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            maxissueqty  => 99,
            issuelength  => 1,
            firstremind  => 1,        # 1 day of grace
            finedays     => 2,        # 2 days of fine per day of overdue
            lengthunit   => 'days',
        }
    );
    $rule->store();

    # Patron cannot issue item_1, they have overdues
    my $five_days_ago = dt_from_string->subtract( days => 5 );
    my $ten_days_ago  = dt_from_string->subtract( days => 10 );
    AddIssue( $patron, $item_1->{barcode}, $five_days_ago );    # Add an overdue
    AddIssue( $patron, $item_2->{barcode}, $ten_days_ago )
      ;    # Add another overdue

    t::lib::Mocks::mock_preference( 'CumulativeRestrictionPeriods', '0' );
    AddReturn( $item_1->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    my $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );

    # FIXME Is it right? I'd have expected 5 * 2 - 1 instead
    # Same for the others
    my $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => ( 5 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );

    AddReturn( $item_2->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );
    $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => ( 10 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );

    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );

    t::lib::Mocks::mock_preference( 'CumulativeRestrictionPeriods', '1' );
    AddIssue( $patron, $item_1->{barcode}, $five_days_ago );    # Add an overdue
    AddIssue( $patron, $item_2->{barcode}, $ten_days_ago )
      ;    # Add another overdue
    AddReturn( $item_1->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );
    $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => ( 5 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );

    AddReturn( $item_2->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );
    $expected_expiration = output_pref(
        {
            dt => dt_from_string->add( days => ( 5 - 1 ) * 2 + ( 10 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );
};

subtest 'AddReturn + suspension_chargeperiod' => sub {
    plan tests => 6;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build( { source => 'Borrower', value => { categorycode => $patron_category->{categorycode} } } );

    # Add 2 items
    my $biblioitem_1 = $builder->build( { source => 'Biblioitem' } );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem_1->{biblionumber}
            }
        }
    );

    # And the issuing rule
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            maxissueqty  => 99,
            issuelength  => 1,
            firstremind  => 0,        # 0 day of grace
            finedays     => 2,        # 2 days of fine per day of overdue
            suspension_chargeperiod => 1,
            lengthunit   => 'days',
        }
    );
    $rule->store();

    my $five_days_ago = dt_from_string->subtract( days => 5 );
    AddIssue( $patron, $item_1->{barcode}, $five_days_ago );    # Add an overdue

    # We want to charge 2 days every day, without grace
    # With 5 days of overdue: 5 * Z
    AddReturn( $item_1->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    my $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );

    my $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => ( 5 * 2 ) / 1 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );
    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );

    # We want to charge 2 days every 2 days, without grace
    # With 5 days of overdue: (5 * 2) / 2
    $rule->suspension_chargeperiod(2)->store;
    AddIssue( $patron, $item_1->{barcode}, $five_days_ago );    # Add an overdue

    AddReturn( $item_1->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );

    $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => floor( 5 * 2 ) / 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );
    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );

    # We want to charge 2 days every 3 days, with 1 day of grace
    # With 5 days of overdue: ((5-1) / 3 ) * 2
    $rule->suspension_chargeperiod(3)->store;
    $rule->firstremind(1)->store;
    AddIssue( $patron, $item_1->{barcode}, $five_days_ago );    # Add an overdue

    AddReturn( $item_1->{barcode}, $library->{branchcode},
        undef, undef, dt_from_string );
    $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1 );

    $expected_expiration = output_pref(
        {
            dt         => dt_from_string->add( days => floor( ( ( 5 - 1 ) / 3 ) * 2 ) ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $debarments->[0]->{expiration}, $expected_expiration );
    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );

};


subtest 'AddReturn | is_overdue' => sub {
    plan tests => 5;

    t::lib::Mocks::mock_preference('CalculateFinesOnReturn', 1);
    t::lib::Mocks::mock_preference('finesMode', 'production');
    t::lib::Mocks::mock_preference('MaxFine', '100');

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build( { source => 'Borrower', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->{biblionumber},
            }
        }
    );

    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            maxissueqty  => 99,
            issuelength  => 6,
            lengthunit   => 'days',
            fine         => 1, # Charge 1 every day of overdue
            chargeperiod => 1,
        }
    );
    $rule->store();

    my $one_day_ago   = dt_from_string->subtract( days => 1 );
    my $five_days_ago = dt_from_string->subtract( days => 5 );
    my $ten_days_ago  = dt_from_string->subtract( days => 10 );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    # No date specify, today will be used
    AddIssue( $patron->unblessed, $item->{barcode}, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->{barcode}, $library->{branchcode} );
    is( int($patron->account->balance()), 10, 'Patron should have a charge of 10 (10 days x 1)' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify return date 5 days before => no overdue
    AddIssue( $patron->unblessed, $item->{barcode}, $five_days_ago ); # date due was 5d ago
    AddReturn( $item->{barcode}, $library->{branchcode}, undef, undef, $ten_days_ago );
    is( int($patron->account->balance()), 0, 'AddReturn: pass return_date => no overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify return date 5 days later => overdue
    AddIssue( $patron->unblessed, $item->{barcode}, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->{barcode}, $library->{branchcode}, undef, undef, $five_days_ago );
    is( int($patron->account->balance()), 5, 'AddReturn: pass return_date => overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify dropbox date 5 days before => no overdue
    AddIssue( $patron->unblessed, $item->{barcode}, $five_days_ago ); # date due was 5d ago
    AddReturn( $item->{barcode}, $library->{branchcode}, undef, 1, undef, $ten_days_ago );
    is( int($patron->account->balance()), 0, 'AddReturn: pass return_date => no overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify dropbox date 5 days later => overdue, or... not
    AddIssue( $patron->unblessed, $item->{barcode}, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->{barcode}, $library->{branchcode}, undef, 1, undef, $five_days_ago );
    is( int($patron->account->balance()), 0, 'AddReturn: pass return_date => no overdue in dropbox mode' ); # FIXME? This is weird, the FU fine is created ( _CalculateAndUpdateFine > C4::Overdues::UpdateFine ) then remove later (in _FixOverduesOnReturn). Looks like it is a feature
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;
};

subtest '_FixAccountForLostAndReturned' => sub {
    plan tests => 2;

    # Generate test biblio
    my $title  = 'Koha for Dummies';
    my ( $biblionumber, $biblioitemnumber ) = add_biblio($title, 'Hall, Daria');

    my $barcode = 'KD123456789';
    my $branchcode  = $library2->{branchcode};

    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch       => $branchcode,
            holdingbranch    => $branchcode,
            barcode          => $barcode,
            replacementprice => 99.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $patron = $builder->build( { source => 'Borrower' } );

    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber => $patron->{borrowernumber},
            accounttype    => 'L',
            itemnumber     => $itemnumber,
            amount => 99.00,
            amountoutstanding => 99.00,
        }
    )->store();

    C4::Circulation::_FixAccountForLostAndReturned( $itemnumber, $patron->{borrowernumber} );

    $accountline->_result()->discard_changes();

    is( $accountline->amountoutstanding, '0.000000', 'Lost fee has no outstanding amount' );
    is( $accountline->accounttype, 'LR', 'Lost fee now has account type of LR ( Lost Returned )');
};

subtest '_FixOverduesOnReturn' => sub {
    plan tests => 6;

    # Generate test biblio
    my $title  = 'Koha for Dummies';
    my ( $biblionumber, $biblioitemnumber ) = add_biblio($title, 'Hall, Kylie');

    my $barcode = 'KD987654321';
    my $branchcode  = $library2->{branchcode};

    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch       => $branchcode,
            holdingbranch    => $branchcode,
            barcode          => $barcode,
            replacementprice => 99.00,
            itype            => $itemtype
        },
        $biblionumber
    );

    my $patron = $builder->build( { source => 'Borrower' } );

    ## Start with basic call, should just close out the open fine
    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber => $patron->{borrowernumber},
            accounttype    => 'FU',
            itemnumber     => $itemnumber,
            amount => 99.00,
            amountoutstanding => 99.00,
            lastincrement => 9.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $itemnumber );

    $accountline->_result()->discard_changes();

    is( $accountline->amountoutstanding, '99.000000', 'Fine has the same amount outstanding as previously' );
    is( $accountline->accounttype, 'F', 'Open fine ( account type FU ) has been closed out ( account type F )');


    ## Run again, with exemptfine enabled
    $accountline->set(
        {
            accounttype    => 'FU',
            amountoutstanding => 99.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $itemnumber, 1 );

    $accountline->_result()->discard_changes();

    is( $accountline->amountoutstanding, '0.000000', 'Fine has been reduced to 0' );
    is( $accountline->accounttype, 'FFOR', 'Open fine ( account type FU ) has been set to fine forgiven ( account type FFOR )');

    ## Run again, with dropbox mode enabled
    $accountline->set(
        {
            accounttype    => 'FU',
            amountoutstanding => 99.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $itemnumber, 0, 1 );

    $accountline->_result()->discard_changes();

    is( $accountline->amountoutstanding, '90.000000', 'Fine has been reduced to 90' );
    is( $accountline->accounttype, 'F', 'Open fine ( account type FU ) has been closed out ( account type F )');
};

subtest 'Set waiting flag' => sub {
    plan tests => 4;

    my $library_1 = $builder->build( { source => 'Branch' } );
    my $patron_1  = $builder->build( { source => 'Borrower', value => { branchcode => $library_1->{branchcode}, categorycode => $patron_category->{categorycode} } } );
    my $library_2 = $builder->build( { source => 'Branch' } );
    my $patron_2  = $builder->build( { source => 'Borrower', value => { branchcode => $library_2->{branchcode}, categorycode => $patron_category->{categorycode} } } );

    my $biblio = $builder->build( { source => 'Biblio' } );
    my $biblioitem = $builder->build( { source => 'Biblioitem', value => { biblionumber => $biblio->{biblionumber} } } );

    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library_1->{branchcode},
                holdingbranch => $library_1->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->{biblionumber},
            }
        }
    );

    set_userenv( $library_2 );
    my $reserve_id = AddReserve(
        $library_2->{branchcode}, $patron_2->{borrowernumber}, $biblioitem->{biblionumber},
        '', 1, undef, undef, '', undef, $item->{itemnumber},
    );

    set_userenv( $library_1 );
    my $do_transfer = 1;
    my ( $res, $rr ) = AddReturn( $item->{barcode}, $library_1->{branchcode} );
    ModReserveAffect( $item->{itemnumber}, undef, $do_transfer, $reserve_id );
    my $hold = Koha::Holds->find( $reserve_id );
    is( $hold->found, 'T', 'Hold is in transit' );

    my ( $status ) = CheckReserves($item->{itemnumber});
    is( $status, 'Reserved', 'Hold is not waiting yet');

    set_userenv( $library_2 );
    $do_transfer = 0;
    AddReturn( $item->{barcode}, $library_2->{branchcode} );
    ModReserveAffect( $item->{itemnumber}, undef, $do_transfer, $reserve_id );
    $hold = Koha::Holds->find( $reserve_id );
    is( $hold->found, 'W', 'Hold is waiting' );
    ( $status ) = CheckReserves($item->{itemnumber});
    is( $status, 'Waiting', 'Now the hold is waiting');
};

subtest 'CanBookBeIssued | is_overdue' => sub {
    plan tests => 3;

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
        '*',   '*', '*', 25,
        1,     14,  'days',
        1,     7,
        undef, 0,
        .10,   1
    );

    my $five_days_go = output_pref({ dt => dt_from_string->add( days => 5 ), dateonly => 1});
    my $ten_days_go  = output_pref({ dt => dt_from_string->add( days => 10), dateonly => 1 });
    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->{biblionumber},
            }
        }
    );

    my $issue = AddIssue( $patron->unblessed, $item->{barcode}, $five_days_go ); # date due was 10d ago
    my $actualissue = Koha::Checkouts->find( { itemnumber => $item->{itemnumber} } );
    is( output_pref({ str => $actualissue->date_due, dateonly => 1}), $five_days_go, "First issue works");
    my ($issuingimpossible, $needsconfirmation) = CanBookBeIssued($patron,$item->{barcode},$ten_days_go, undef, undef, undef);
    is( $needsconfirmation->{RENEW_ISSUE}, 1, "This is a renewal");
    is( $needsconfirmation->{TOO_MANY}, undef, "Not too many, is a renewal");

};

sub set_userenv {
    my ( $library ) = @_;
    C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, $library->{branchname}, '', '', '');
}

sub str {
    my ( $error, $question, $alert ) = @_;
    my $s;
    $s  = %$error    ? ' (error: '    . join( ' ', keys %$error    ) . ')' : '';
    $s .= %$question ? ' (question: ' . join( ' ', keys %$question ) . ')' : '';
    $s .= %$alert    ? ' (alert: '    . join( ' ', keys %$alert    ) . ')' : '';
    return $s;
}

sub add_biblio {
    my ($title, $author) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');

    my $biblio = MARC::Record->new();
    if ($title) {
        my $tag = $marcflavour eq 'UNIMARC' ? '200' : '245';
        $biblio->append_fields(
            MARC::Field->new($tag, ' ', ' ', a => $title),
        );
    }

    if ($author) {
        my ($tag, $code) = $marcflavour eq 'UNIMARC' ? (200, 'f') : (100, 'a');
        $biblio->append_fields(
            MARC::Field->new($tag, ' ', ' ', $code => $author),
        );
    }

    return AddBiblio($biblio, '');
}
