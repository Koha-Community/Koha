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
use utf8;

use Test::More tests => 41;
use Test::MockModule;

use Data::Dumper;
use DateTime;
use POSIX qw( floor );
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Accounts;
use C4::Calendar;
use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Log;
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

sub set_userenv {
    my ( $library ) = @_;
    t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });
}

sub str {
    my ( $error, $question, $alert ) = @_;
    my $s;
    $s  = %$error    ? ' (error: '    . join( ' ', keys %$error    ) . ')' : '';
    $s .= %$question ? ' (question: ' . join( ' ', keys %$question ) . ')' : '';
    $s .= %$alert    ? ' (alert: '    . join( ' ', keys %$alert    ) . ')' : '';
    return $s;
}

sub test_debarment_on_checkout {
    my ($params) = @_;
    my $item     = $params->{item};
    my $library  = $params->{library};
    my $patron   = $params->{patron};
    my $due_date = $params->{due_date} || dt_from_string;
    my $return_date = $params->{return_date} || dt_from_string;
    my $expected_expiration_date = $params->{expiration_date};

    $expected_expiration_date = output_pref(
        {
            dt         => $expected_expiration_date,
            dateformat => 'sql',
            dateonly   => 1,
        }
    );
    my @caller      = caller;
    my $line_number = $caller[2];
    AddIssue( $patron, $item->{barcode}, $due_date );

    my ( undef, $message ) = AddReturn( $item->{barcode}, $library->{branchcode}, undef, undef, $return_date );
    is( $message->{WasReturned} && exists $message->{Debarred}, 1, 'AddReturn must have debarred the patron' )
        or diag('AddReturn returned message ' . Dumper $message );
    my $debarments = Koha::Patron::Debarments::GetDebarments(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
    is( scalar(@$debarments), 1, 'Test at line ' . $line_number );

    is( $debarments->[0]->{expiration},
        $expected_expiration_date, 'Test at line ' . $line_number );
    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->{borrowernumber}, type => 'SUSPENSION' } );
};

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

# Prevent random failures by mocking ->now
my $now_value       = DateTime->now();
my $mocked_datetime = Test::MockModule->new('DateTime');
$mocked_datetime->mock( 'now', sub { return $now_value->clone; } );

# Start transaction
$dbh->{RaiseError} = 1;

my $cache = Koha::Caches->get_instance();
$dbh->do(q|DELETE FROM special_holidays|);
$dbh->do(q|DELETE FROM repeatable_holidays|);
$cache->clear_from_cache('single_holidays');

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
t::lib::Mocks::mock_userenv({ branchcode => $library2->{branchcode} });
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

my ( $reused_itemnumber_1, $reused_itemnumber_2 );
subtest "CanBookBeRenewed tests" => sub {
    plan tests => 68;

    C4::Context->set_preference('ItemsDeniedRenewal','');
    # Generate test biblio
    my $biblio = $builder->build_sample_biblio();

    my $branch = $library2->{branchcode};

    my $item_1 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 12.00,
            itype            => $itemtype
        }
    );
    $reused_itemnumber_1 = $item_1->itemnumber;

    my $item_2 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 23.00,
            itype            => $itemtype
        }
    );
    $reused_itemnumber_2 = $item_2->itemnumber;

    my $item_3 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 23.00,
            itype            => $itemtype
        }
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

    my $renewing_borrowernumber = Koha::Patron->new(\%renewing_borrower_data)->store->borrowernumber;
    my $reserving_borrowernumber = Koha::Patron->new(\%reserving_borrower_data)->store->borrowernumber;
    my $hold_waiting_borrowernumber = Koha::Patron->new(\%hold_waiting_borrower_data)->store->borrowernumber;
    my $restricted_borrowernumber = Koha::Patron->new(\%restricted_borrower_data)->store->borrowernumber;
    my $expired_borrowernumber = Koha::Patron->new(\%expired_borrower_data)->store->borrowernumber;

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

    my $issue = AddIssue( $renewing_borrower, $item_1->barcode);
    my $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue->date_due(), 1, "Item 1 checked out, due date: " . $issue->date_due() );

    my $issue2 = AddIssue( $renewing_borrower, $item_2->barcode);
    $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue2, 1, "Item 2 checked out, due date: " . $issue2->date_due());


    my $borrowing_borrowernumber = Koha::Checkouts->find( { itemnumber => $item_1->itemnumber } )->borrowernumber;
    is ($borrowing_borrowernumber, $renewing_borrowernumber, "Item checked out to $renewing_borrower->{firstname} $renewing_borrower->{surname}");

    my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
    is( $renewokay, 1, 'Can renew, no holds for this title or item');


    # Biblio-level hold, renewal test
    AddReserve(
        $branch, $reserving_borrowernumber, $biblio->biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        'a title', $checkitem, $found
    );

    # Testing of feature to allow the renewal of reserved items if other items on the record can fill all needed holds
    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');

    # Now let's add an item level hold, we should no longer be able to renew the item
    my $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
        {
            borrowernumber => $hold_waiting_borrowernumber,
            biblionumber   => $biblio->biblionumber,
            itemnumber     => $item_1->itemnumber,
            branchcode     => $branch,
            priority       => 3,
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Bug 13919 - Renewal possible with item level hold on item');
    $hold->delete();

    # Now let's add a waiting hold on the 3rd item, it's no longer available tp check out by just anyone, so we should no longer
    # be able to renew these items
    $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
        {
            borrowernumber => $hold_waiting_borrowernumber,
            biblionumber   => $biblio->biblionumber,
            itemnumber     => $item_3->itemnumber,
            branchcode     => $branch,
            priority       => 0,
            found          => 'W'
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber);
    is( $renewokay, 0, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 0 );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, reserved (returned error is on_reserve)');

    my $reserveid = Koha::Holds->search({ biblionumber => $biblio->biblionumber, borrowernumber => $reserving_borrowernumber })->next->reserve_id;
    my $reserving_borrower = Koha::Patrons->find( $reserving_borrowernumber )->unblessed;
    AddIssue($reserving_borrower, $item_3->barcode);
    my $reserve = $dbh->selectrow_hashref(
        'SELECT * FROM old_reserves WHERE reserve_id = ?',
        { Slice => {} },
        $reserveid
    );
    is($reserve->{found}, 'F', 'hold marked completed when checking out item that fills it');

    # Item-level hold, renewal test
    AddReserve(
        $branch, $reserving_borrowernumber, $biblio->biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        'a title', $item_1->itemnumber, $found
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber, 1);
    is( $renewokay, 1, 'Can renew item 2, item-level hold is on item 1');

    # Items can't fill hold for reasons
    ModItem({ notforloan => 1 }, $biblio->biblionumber, $item_1->itemnumber);
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
    is( $renewokay, 1, 'Can renew, item is marked not for loan, hold does not block');
    ModItem({ notforloan => 0, itype => $itemtype }, $biblio->biblionumber, $item_1->itemnumber);

    # FIXME: Add more for itemtype not for loan etc.

    # Restricted users cannot renew when RestrictionBlockRenewing is enabled
    my $item_5 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 23.00,
            itype            => $itemtype,
        }
    );
    my $datedue5 = AddIssue($restricted_borrower, $item_5->barcode);
    is (defined $datedue5, 1, "Item with date due checked out, due date: $datedue5");

    t::lib::Mocks::mock_preference('RestrictionBlockRenewing','1');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber);
    is( $renewokay, 1, '(Bug 8236), Can renew, user is not restricted');
    ( $renewokay, $error ) = CanBookBeRenewed($restricted_borrowernumber, $item_5->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, user is restricted');

    # Users cannot renew an overdue item
    my $item_6 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 23.00,
            itype            => $itemtype,
        }
    );

    my $item_7 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 23.00,
            itype            => $itemtype,
        }
    );

    my $datedue6 = AddIssue( $renewing_borrower, $item_6->barcode);
    is (defined $datedue6, 1, "Item 2 checked out, due date: ".$datedue6->date_due);

    my $now = dt_from_string();
    my $five_weeks = DateTime::Duration->new(weeks => 5);
    my $five_weeks_ago = $now - $five_weeks;
    t::lib::Mocks::mock_preference('finesMode', 'production');

    my $passeddatedue1 = AddIssue($renewing_borrower, $item_7->barcode, $five_weeks_ago);
    is (defined $passeddatedue1, 1, "Item with passed date due checked out, due date: " . $passeddatedue1->date_due);

    my ( $fine ) = CalcFine( GetItem(undef, $item_7->barcode), $renewing_borrower->{categorycode}, $branch, $five_weeks_ago, $now );
    C4::Overdues::UpdateFine(
        {
            issue_id       => $passeddatedue1->id(),
            itemnumber     => $item_7->itemnumber,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => $fine,
            type           => 'FU',
            due            => Koha::DateUtils::output_pref($five_weeks_ago)
        }
    );

    t::lib::Mocks::mock_preference('RenewalLog', 0);
    my $date = output_pref( { dt => dt_from_string(), datenonly => 1, dateformat => 'iso' } );
    my $old_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddRenewal( $renewing_borrower->{borrowernumber}, $item_7->itemnumber, $branch );
    my $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_log_size, 'renew log not added because of the syspref RenewalLog');

    t::lib::Mocks::mock_preference('RenewalLog', 1);
    $date = output_pref( { dt => dt_from_string(), datenonly => 1, dateformat => 'iso' } );
    $old_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddRenewal( $renewing_borrower->{borrowernumber}, $item_7->itemnumber, $branch );
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_log_size + 1, 'renew log successfully added');

    my $fines = Koha::Account::Lines->search( { borrowernumber => $renewing_borrower->{borrowernumber}, itemnumber => $item_7->itemnumber } );
    is( $fines->count, 2, 'AddRenewal left both fines' );
    is( $fines->next->accounttype, 'F', 'Fine on renewed item is closed out properly' );
    is( $fines->next->accounttype, 'F', 'Fine on renewed item is closed out properly' );
    $fines->delete();


    my $old_issue_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["ISSUE"]) } );
    my $old_renew_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    AddIssue( $renewing_borrower,$item_7->barcode,Koha::DateUtils::output_pref({str=>$datedue6->date_due, dateformat =>'iso'}),0,$date, 0, undef );
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["RENEWAL"]) } );
    is ($new_log_size, $old_renew_log_size + 1, 'renew log successfully added when renewed via issuing');
    $new_log_size =  scalar(@{GetLogs( $date, $date, undef,["CIRCULATION"], ["ISSUE"]) } );
    is ($new_log_size, $old_issue_log_size, 'renew not logged as issue when renewed via issuing');

    $fines = Koha::Account::Lines->search( { borrowernumber => $renewing_borrower->{borrowernumber}, itemnumber => $item_7->itemnumber } );
    $fines->delete();

    t::lib::Mocks::mock_preference('OverduesBlockRenewing','blockitem');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_6->itemnumber);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is not overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_7->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is overdue');


    $hold = Koha::Holds->search({ biblionumber => $biblio->biblionumber, borrowernumber => $reserving_borrowernumber })->next;
    $hold->cancel;

    # Bug 14101
    # Test automatic renewal before value for "norenewalbefore" in policy is set
    # In this case automatic renewal is not permitted prior to due date
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 16.00,
            itype            => $itemtype,
        }
    );

    $issue = AddIssue( $renewing_borrower, $item_4->barcode, undef, undef, undef, undef, { auto_renew => 1 } );
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = undef (returned code is auto_too_soon)' );

    # Bug 7413
    # Test premature manual renewal
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 7');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Bug 7413: Cannot renew, renewal is premature');
    is( $error, 'too_soon', 'Bug 7413: Cannot renew, renewal is premature (returned code is too_soon)');

    # Bug 14395
    # Test 'exact time' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'exact_time' );
    is(
        GetSoonestRenewDate( $renewing_borrowernumber, $item_1->itemnumber ),
        $datedue->clone->add( days => -7 ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );

    # Bug 14395
    # Test 'date' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'date' );
    is(
        GetSoonestRenewDate( $renewing_borrowernumber, $item_1->itemnumber ),
        $datedue->clone->add( days => -7 )->truncate( to => 'day' ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );

    # Bug 14101
    # Test premature automatic renewal
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature (returned code is auto_too_soon)'
    );

    # Change policy so that loans can only be renewed exactly on due date (0 days prior to due date)
    # and test automatic renewal again
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 0');
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = 0 (returned code is auto_too_soon)'
    );

    # Change policy so that loans can be renewed 99 days prior to the due date
    # and test automatic renewal again
    $dbh->do('UPDATE issuingrules SET norenewalbefore = 99');
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic' );
    is( $error, 'auto_renew',
        'Bug 14101: Cannot renew, renewal is automatic (returned code is auto_renew)'
    );

    subtest "too_late_renewal / no_auto_renewal_after" => sub {
        plan tests => 14;
        my $item_to_auto_renew = $builder->build(
            {   source => 'Item',
                value  => {
                    biblionumber  => $biblio->biblionumber,
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
                biblionumber => $biblio->biblionumber,
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
                biblionumber => $biblio->biblionumber,
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
                    biblionumber  => $biblio->biblionumber,
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

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 renewals allowed');
    is( $error, 'too_many', 'Cannot renew, 0 renewals allowed (returned code is too_many)');

    # Test WhenLostForgiveFine and WhenLostChargeReplacementFee
    t::lib::Mocks::mock_preference('WhenLostForgiveFine','1');
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','1');

    C4::Overdues::UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $item_1->itemnumber,
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

    LostItem( $item_1->itemnumber, 'test', 1 );

    $line = Koha::Account::Lines->find($line->id);
    is( $line->accounttype, 'F', 'Account type correctly changed from FU to F' );

    my $item = Koha::Items->find($item_1->itemnumber);
    ok( !$item->onloan(), "Lost item marked as returned has false onloan value" );
    my $checkout = Koha::Checkouts->find({ itemnumber => $item_1->itemnumber });
    is( $checkout, undef, 'LostItem called with forced return has checked in the item' );

    my $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    is( $total_due, '15.000000', 'Borrower only charged replacement fee with both WhenLostForgiveFine and WhenLostChargeReplacementFee enabled' );

    C4::Context->dbh->do("DELETE FROM accountlines");

    C4::Overdues::UpdateFine(
        {
            issue_id       => $issue2->id(),
            itemnumber     => $item_2->itemnumber,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => 15.00,
            type           => q{},
            due            => Koha::DateUtils::output_pref($datedue)
        }
    );

    LostItem( $item_2->itemnumber, 'test', 0 );

    my $item2 = Koha::Items->find($item_2->itemnumber);
    ok( $item2->onloan(), "Lost item *not* marked as returned has true onloan value" );
    ok( Koha::Checkouts->find({ itemnumber => $item_2->itemnumber }), 'LostItem called without forced return has checked in the item' );

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
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_6->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, one of the items is overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_7->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, one of the items is overdue');

    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','1');
    $checkout = Koha::Checkouts->find( { itemnumber => $item_3->itemnumber } );
    LostItem( $item_3->itemnumber, 'test', 0 );
    my $accountline = Koha::Account::Lines->find( { itemnumber => $item_3->itemnumber } );
    is( $accountline->issue_id, $checkout->id, "Issue id added for lost replacement fee charge" );
};

subtest "GetUpcomingDueIssues" => sub {
    plan tests => 12;

    my $branch   = $library2->{branchcode};

    #Create another record
    my $biblio2 = $builder->build_sample_biblio();

    #Create third item
    my $item_1 = Koha::Items->find($reused_itemnumber_1);
    my $item_2 = Koha::Items->find($reused_itemnumber_2);
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber     => $biblio2->biblionumber,
            library          => $branch,
            itype            => $itemtype,
        }
    );


    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Fridolyn',
        surname => 'SOMERS',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my $a_borrower_borrowernumber = Koha::Patron->new(\%a_borrower_data)->store->borrowernumber;
    my $a_borrower = Koha::Patrons->find( $a_borrower_borrowernumber )->unblessed;

    my $yesterday = DateTime->today(time_zone => C4::Context->tz())->add( days => -1 );
    my $two_days_ahead = DateTime->today(time_zone => C4::Context->tz())->add( days => 2 );
    my $today = DateTime->today(time_zone => C4::Context->tz());

    my $issue = AddIssue( $a_borrower, $item_1->barcode, $yesterday );
    my $datedue = dt_from_string( $issue->date_due() );
    my $issue2 = AddIssue( $a_borrower, $item_2->barcode, $two_days_ahead );
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

    my $issue3 = AddIssue( $a_borrower, $item_3->barcode, $today );

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

};

subtest "Bug 13841 - Do not create new 0 amount fines" => sub {
    my $branch   = $library2->{branchcode};

    my $biblio = $builder->build_sample_biblio();

    #Create third item
    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            itype            => $itemtype,
        }
    );

    # Create a borrower
    my %a_borrower_data = (
        firstname =>  'Kyle',
        surname => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );

    my $borrowernumber = Koha::Patron->new(\%a_borrower_data)->store->borrowernumber;

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
    my $issue = AddIssue( $borrower, $item->barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $item->itemnumber,
            borrowernumber => $borrowernumber,
            amount         => 0,
            type           => q{}
        }
    );

    my $hr = $dbh->selectrow_hashref(q{SELECT COUNT(*) AS count FROM accountlines WHERE borrowernumber = ? AND itemnumber = ?}, undef, $borrowernumber, $item->itemnumber );
    my $count = $hr->{count};

    is ( $count, 0, "Calling UpdateFine on non-existant fine with an amount of 0 does not result in an empty fine" );
};

subtest "AllowRenewalIfOtherItemsAvailable tests" => sub {
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
    my $biblio = $builder->build_sample_biblio();

    my $item_1 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
            itype            => $itemtype,
        }
    );

    my $item_2= $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
            itype            => $itemtype,
        }
    );

    my $borrowernumber1 = Koha::Patron->new({
        firstname    => 'Kyle',
        surname      => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library2->{branchcode},
    })->store->borrowernumber;
    my $borrowernumber2 = Koha::Patron->new({
        firstname    => 'Chelsea',
        surname      => 'Hall',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library2->{branchcode},
    })->store->borrowernumber;

    my $borrower1 = Koha::Patrons->find( $borrowernumber1 )->unblessed;
    my $borrower2 = Koha::Patrons->find( $borrowernumber2 )->unblessed;

    my $issue = AddIssue( $borrower1, $item_1->barcode );

    my ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with no hold on the record' );

    AddReserve(
        $library2->{branchcode}, $borrowernumber2, $biblio->biblionumber,
        '',  1, undef, undef, '',
        undef, undef, undef
    );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 0");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfholds are disabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 0");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled and onshelfholds is disabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is disabled and onshelfhold is enabled' );

    C4::Context->dbh->do("UPDATE issuingrules SET onshelfholds = 1");
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled' );

    # Setting item not checked out to be not for loan but holdable
    ModItem({ notforloan => -1 }, $biblio->biblionumber, $item_2->itemnumber);

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower can not renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled but the only available item is notforloan' );
};

{
    # Don't allow renewing onsite checkout
    my $branch   = $library->{branchcode};

    #Create another record
    my $biblio = $builder->build_sample_biblio();

    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            itype            => $itemtype,
        }
    );

    my $borrowernumber = Koha::Patron->new({
        firstname =>  'fn',
        surname => 'dn',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    })->store->borrowernumber;

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;

    my $issue = AddIssue( $borrower, $item->barcode, undef, undef, undef, undef, { onsite_checkout => 1 } );
    my ( $renewed, $error ) = CanBookBeRenewed( $borrowernumber, $item->itemnumber );
    is( $renewed, 0, 'CanBookBeRenewed should not allow to renew on-site checkout' );
    is( $error, 'onsite_checkout', 'A correct error code should be returned by CanBookBeRenewed for on-site checkout' );
}

{
    my $library = $builder->build({ source => 'Branch' });

    my $biblio = $builder->build_sample_biblio();

    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library->{branchcode},
            itype            => $itemtype,
        }
    );

    my $patron = $builder->build({ source => 'Borrower', value => { branchcode => $library->{branchcode}, categorycode => $patron_category->{categorycode} } } );

    my $issue = AddIssue( $patron, $item->barcode );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $item->itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 1,
            type           => q{}
        }
    );
    UpdateFine(
        {
            issue_id       => $issue->id(),
            itemnumber     => $item->itemnumber,
            borrowernumber => $patron->{borrowernumber},
            amount         => 2,
            type           => q{}
        }
    );
    is( Koha::Account::Lines->search({ issue_id => $issue->id })->count, 1, 'UpdateFine should not create a new accountline when updating an existing fine');
}

subtest 'CanBookBeIssued & AllowReturnToBranch' => sub {
    plan tests => 24;

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
    ## Test that unknown barcodes don't generate internal server errors
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, 'KohaIsAwesome' );
    ok( $error->{UNKNOWN_BARCODE}, '"KohaIsAwesome" is not a valid barcode as expected.' );
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
    is( $error->{branch_to_return},         $holdingbranch->{branchcode}, 'branch_to_return matched holdingbranch' );
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
    is( $error->{branch_to_return},         $holdingbranch->{branchcode}, 'branch_to_return matches holdingbranch' );

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
    is( $error->{branch_to_return},         $homebranch->{branchcode}, 'branch_to_return matches homebranch' );
    ## Cannot be issued from holdinbranch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->{barcode} );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $homebranch->{branchcode}, 'branch_to_return matches homebranch' );

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
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from homebranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from holdingbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Can be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from otherbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue

    # AllowReturnToBranch == holdinbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '', 'AllowReturnToBranch - holdingbranch | Cannot be issued from homebranch');
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue, 'AllowReturnToBranch - holdingbranch | Can be issued from holdingbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '', 'AllowReturnToBranch - holdingbranch | Cannot be issued from otherbranch');

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), $ref_issue, 'AllowReturnToBranch - homebranch | Can be issued from homebranch' );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->{barcode} ); # Reinsert the original issue
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '', 'AllowReturnToBranch - homebranch | Cannot be issued from holdingbranch' );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->{barcode} ) ), '', 'AllowReturnToBranch - homebranch | Cannot be issued from otherbranch' );
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

    my $biblio = $builder->build_sample_biblio();

    my $branch = $library2->{branchcode};

    my $item_1 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 12.00,
            itype            => $itemtype,
        }
    );

    my $item_2 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 12.00,
            itype            => $itemtype,
        }
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
    my $renewing_borrowernumber = Koha::Patron->new(\%renewing_borrower_data)->store->borrowernumber;
    my $renewing_borrower = Koha::Patrons->find( $renewing_borrowernumber )->unblessed;
    my $issue = AddIssue( $renewing_borrower, $item_1->barcode);
    my $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue->date_due(), 1, "item 1 checked out");
    my $borrowing_borrowernumber = Koha::Checkouts->find({ itemnumber => $item_1->itemnumber })->borrowernumber;

    my %reserving_borrower_data1 = (
        firstname =>  'Katrin',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $reserving_borrowernumber1 = Koha::Patron->new(\%reserving_borrower_data1)->store->borrowernumber;
    AddReserve(
        $branch, $reserving_borrowernumber1, $biblio->biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        'a title', $checkitem, $found
    );

    my %reserving_borrower_data2 = (
        firstname =>  'Kirk',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $reserving_borrowernumber2 = Koha::Patron->new(\%reserving_borrower_data2)->store->borrowernumber;
    AddReserve(
        $branch, $reserving_borrowernumber2, $biblio->biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        'a title', $checkitem, $found
    );

    {
        my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
        is($renewokay, 0, 'Bug 17941 - should cover the case where 2 books are both reserved, so failing');
    }

    my $item_3 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branch,
            replacementprice => 12.00,
            itype            => $itemtype,
        }
    );

    {
        my ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
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
                biblionumber  => $biblionumber,
            }
        }
    );
    my $item_2 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
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
    plan tests => 21;

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
    # We want to charge 2 days every day, without grace
    # With 5 days of overdue: 5 * Z
    my $expected_expiration = dt_from_string->add( days => ( 5 * 2 ) / 1 );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # We want to charge 2 days every 2 days, without grace
    # With 5 days of overdue: (5 * 2) / 2
    $rule->suspension_chargeperiod(2)->store;
    $expected_expiration = dt_from_string->add( days => floor( 5 * 2 ) / 2 );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # We want to charge 2 days every 3 days, with 1 day of grace
    # With 5 days of overdue: ((5-1) / 3 ) * 2
    $rule->suspension_chargeperiod(3)->store;
    $rule->firstremind(1)->store;
    $expected_expiration = dt_from_string->add( days => floor( ( ( 5 - 1 ) / 3 ) * 2 ) );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # Use finesCalendar to know if holiday must be skipped to calculate the due date
    # We want to charge 2 days every days, with 0 day of grace (to not burn brains)
    $rule->finedays(2)->store;
    $rule->suspension_chargeperiod(1)->store;
    $rule->firstremind(0)->store;
    t::lib::Mocks::mock_preference('finesCalendar', 'noFinesWhenClosed');

    # Adding a holiday 2 days ago
    my $calendar = C4::Calendar->new(branchcode => $library->{branchcode});
    my $two_days_ago = dt_from_string->subtract( days => 2 );
    $calendar->insert_single_holiday(
        day             => $two_days_ago->day,
        month           => $two_days_ago->month,
        year            => $two_days_ago->year,
        title           => 'holidayTest-2d',
        description     => 'holidayDesc 2 days ago'
    );
    # With 5 days of overdue, only 4 (x finedays=2) days must charged (one was an holiday)
    $expected_expiration = dt_from_string->add( days => floor( ( ( 5 - 0 - 1 ) / 1 ) * 2 ) );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # Adding a holiday 2 days ahead, with finesCalendar=noFinesWhenClosed it should be skipped
    my $two_days_ahead = dt_from_string->add( days => 2 );
    $calendar->insert_single_holiday(
        day             => $two_days_ahead->day,
        month           => $two_days_ahead->month,
        year            => $two_days_ahead->year,
        title           => 'holidayTest+2d',
        description     => 'holidayDesc 2 days ahead'
    );

    # Same as above, but we should skip D+2
    $expected_expiration = dt_from_string->add( days => floor( ( ( 5 - 0 - 1 ) / 1 ) * 2 ) + 1 );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # Adding another holiday, day of expiration date
    my $expected_expiration_dt = dt_from_string($expected_expiration);
    $calendar->insert_single_holiday(
        day             => $expected_expiration_dt->day,
        month           => $expected_expiration_dt->month,
        year            => $expected_expiration_dt->year,
        title           => 'holidayTest_exp',
        description     => 'holidayDesc on expiration date'
    );
    # Expiration date will be the day after
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration_dt->clone->add( days => 1 ),
        }
    );

    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            return_date     => dt_from_string->add(days => 5),
            expiration_date => dt_from_string->add(days => 5 + (5 * 2 - 1) ),
        }
    );
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

    plan tests => 5;

    t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee', 1 );
    t::lib::Mocks::mock_preference( 'WhenLostForgiveFine',          0 );

    my $processfee_amount  = 20;
    my $replacement_amount = 99.00;
    my $item_type          = $builder->build_object(
        {   class => 'Koha::ItemTypes',
            value => {
                notforloan         => undef,
                rentalcharge       => 0,
                defaultreplacecost => undef,
                processfee         => $processfee_amount
            }
        }
    );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $biblio = $builder->build_sample_biblio({ author => 'Hall, Daria' });

    subtest 'Full write-off tests' => sub {

        plan tests => 10;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblio->biblionumber,
                library          => $library->branchcode,
                replacementprice => $replacement_amount,
                itype            => $item_type->itemtype,
            }
        );

        AddIssue( $patron->unblessed, $item->barcode );

        # Simulate item marked as lost
        ModItem( { itemlost => 3 }, $biblio->biblionumber, $item->itemnumber );
        LostItem( $item->itemnumber, 1 );

        my $processing_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'PF' } );
        is( $processing_fee_lines->count, 1, 'Only one processing fee produced' );
        my $processing_fee_line = $processing_fee_lines->next;
        is( $processing_fee_line->amount + 0,
            $processfee_amount, 'The right PF amount is generated' );
        is( $processing_fee_line->amountoutstanding + 0,
            $processfee_amount, 'The right PF amountoutstanding is generated' );

        my $lost_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'L' } );
        is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
        my $lost_fee_line = $lost_fee_lines->next;
        is( $lost_fee_line->amount + 0, $replacement_amount, 'The right L amount is generated' );
        is( $lost_fee_line->amountoutstanding + 0,
            $replacement_amount, 'The right L amountoutstanding is generated' );

        my $account = $patron->account;
        my $debts   = $account->outstanding_debits;

        # Write off the debt
        my $credit = $account->add_credit(
            {   amount => $account->balance,
                type   => 'writeoff'
            }
        );
        $credit->apply( { debits => $debts, offset_type => 'Writeoff' } );

        my $credit_return_id = C4::Circulation::_FixAccountForLostAndReturned( $item->itemnumber, $patron->id );
        is( $credit_return_id, undef, 'No CR account line added' );

        $lost_fee_line->discard_changes; # reload from DB
        is( $lost_fee_line->amountoutstanding + 0, 0, 'Lost fee has no outstanding amount' );
        is( $lost_fee_line->accounttype,
            'LR', 'Lost fee now has account type of LR ( Lost Returned )' );

        is( $patron->account->balance, -0, 'The patron balance is 0, everything was written off' );
    };

    subtest 'Full payment tests' => sub {

        plan tests => 12;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblio->biblionumber,
                library          => $library->branchcode,
                replacementprice => $replacement_amount,
                itype            => $item_type->itemtype
            }
        );

        AddIssue( $patron->unblessed, $item->barcode );

        # Simulate item marked as lost
        ModItem( { itemlost => 1 }, $biblio->biblionumber, $item->itemnumber );
        LostItem( $item->itemnumber, 1 );

        my $processing_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'PF' } );
        is( $processing_fee_lines->count, 1, 'Only one processing fee produced' );
        my $processing_fee_line = $processing_fee_lines->next;
        is( $processing_fee_line->amount + 0,
            $processfee_amount, 'The right PF amount is generated' );
        is( $processing_fee_line->amountoutstanding + 0,
            $processfee_amount, 'The right PF amountoutstanding is generated' );

        my $lost_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'L' } );
        is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
        my $lost_fee_line = $lost_fee_lines->next;
        is( $lost_fee_line->amount + 0, $replacement_amount, 'The right L amount is generated' );
        is( $lost_fee_line->amountoutstanding + 0,
            $replacement_amount, 'The right L amountountstanding is generated' );

        my $account = $patron->account;
        my $debts   = $account->outstanding_debits;

        # Write off the debt
        my $credit = $account->add_credit(
            {   amount => $account->balance,
                type   => 'payment'
            }
        );
        $credit->apply( { debits => $debts, offset_type => 'Payment' } );

        my $credit_return_id = C4::Circulation::_FixAccountForLostAndReturned( $item->itemnumber, $patron->id );
        my $credit_return = Koha::Account::Lines->find($credit_return_id);

        is( $credit_return->accounttype, 'CR', 'An account line of type CR is added' );
        is( $credit_return->amount + 0,
            -99.00, 'The account line of type CR has an amount of -99' );
        is( $credit_return->amountoutstanding + 0,
            -99.00, 'The account line of type CR has an amountoutstanding of -99' );

        $lost_fee_line->discard_changes;
        is( $lost_fee_line->amountoutstanding + 0, 0, 'Lost fee has no outstanding amount' );
        is( $lost_fee_line->accounttype,
            'LR', 'Lost fee now has account type of LR ( Lost Returned )' );

        is( $patron->account->balance,
            -99, 'The patron balance is -99, a credit that equals the lost fee payment' );
    };

    subtest 'Test without payment or write off' => sub {

        plan tests => 12;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblio->biblionumber,
                library          => $library->branchcode,
                replacementprice => 23.00,
                replacementprice => $replacement_amount,
                itype            => $item_type->itemtype
            }
        );

        AddIssue( $patron->unblessed, $item->barcode );

        # Simulate item marked as lost
        ModItem( { itemlost => 3 }, $biblio->biblionumber, $item->itemnumber );
        LostItem( $item->itemnumber, 1 );

        my $processing_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'PF' } );
        is( $processing_fee_lines->count, 1, 'Only one processing fee produced' );
        my $processing_fee_line = $processing_fee_lines->next;
        is( $processing_fee_line->amount + 0,
            $processfee_amount, 'The right PF amount is generated' );
        is( $processing_fee_line->amountoutstanding + 0,
            $processfee_amount, 'The right PF amountoutstanding is generated' );

        my $lost_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'L' } );
        is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
        my $lost_fee_line = $lost_fee_lines->next;
        is( $lost_fee_line->amount + 0, $replacement_amount, 'The right L amount is generated' );
        is( $lost_fee_line->amountoutstanding + 0,
            $replacement_amount, 'The right L amountountstanding is generated' );

        my $credit_return_id = C4::Circulation::_FixAccountForLostAndReturned( $item->itemnumber, $patron->id );
        my $credit_return = Koha::Account::Lines->find($credit_return_id);

        is( $credit_return->accounttype, 'CR', 'An account line of type CR is added' );
        is( $credit_return->amount + 0, -99.00, 'The account line of type CR has an amount of -99' );
        is( $credit_return->amountoutstanding + 0, 0, 'The account line of type CR has an amountoutstanding of 0' );

        $lost_fee_line->discard_changes;
        is( $lost_fee_line->amountoutstanding + 0, 0, 'Lost fee has no outstanding amount' );
        is( $lost_fee_line->accounttype, 'LR', 'Lost fee now has account type of LR ( Lost Returned )' );

        is( $patron->account->balance, 20, 'The patron balance is 20, still owes the processing fee' );
    };

    subtest 'Test with partial payement and write off, and remaining debt' => sub {

        plan tests => 15;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblio->biblionumber,
                library          => $library->branchcode,
                replacementprice => $replacement_amount,
                itype            => $item_type->itemtype
            }
        );

        AddIssue( $patron->unblessed, $item->barcode );

        # Simulate item marked as lost
        ModItem( { itemlost => 1 }, $biblio->biblionumber, $item->itemnumber );
        LostItem( $item->itemnumber, 1 );

        my $processing_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'PF' } );
        is( $processing_fee_lines->count, 1, 'Only one processing fee produced' );
        my $processing_fee_line = $processing_fee_lines->next;
        is( $processing_fee_line->amount + 0,
            $processfee_amount, 'The right PF amount is generated' );
        is( $processing_fee_line->amountoutstanding + 0,
            $processfee_amount, 'The right PF amountoutstanding is generated' );

        my $lost_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item->itemnumber, accounttype => 'L' } );
        is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
        my $lost_fee_line = $lost_fee_lines->next;
        is( $lost_fee_line->amount + 0, $replacement_amount, 'The right L amount is generated' );
        is( $lost_fee_line->amountoutstanding + 0,
            $replacement_amount, 'The right L amountountstanding is generated' );

        my $account = $patron->account;
        is( $account->balance, $processfee_amount + $replacement_amount, 'Balance is PF + L' );

        # Partially pay fee
        my $payment_amount = 27;
        my $payment        = $account->add_credit(
            {   amount => $payment_amount,
                type   => 'payment'
            }
        );

        $payment->apply( { debits => $lost_fee_lines->reset, offset_type => 'Payment' } );

        # Partially write off fee
        my $write_off_amount = 25;
        my $write_off        = $account->add_credit(
            {   amount => $write_off_amount,
                type   => 'writeoff'
            }
        );
        $write_off->apply( { debits => $lost_fee_lines->reset, offset_type => 'Writeoff' } );

        is( $account->balance,
            $processfee_amount + $replacement_amount - $payment_amount - $write_off_amount,
            'Payment and write off applied'
        );

        # Store the amountoutstanding value
        $lost_fee_line->discard_changes;
        my $outstanding = $lost_fee_line->amountoutstanding;

        my $credit_return_id = C4::Circulation::_FixAccountForLostAndReturned( $item->itemnumber, $patron->id );
        my $credit_return = Koha::Account::Lines->find($credit_return_id);

        is( $account->balance, $processfee_amount - $payment_amount, 'Balance is PF - payment (CR)' );

        $lost_fee_line->discard_changes;
        is( $lost_fee_line->amountoutstanding + 0, 0, 'Lost fee has no outstanding amount' );
        is( $lost_fee_line->accounttype,
            'LR', 'Lost fee now has account type of LR ( Lost Returned )' );

        is( $credit_return->accounttype, 'CR', 'An account line of type CR is added' );
        is( $credit_return->amount + 0,
            ($payment_amount + $outstanding ) * -1,
            'The account line of type CR has an amount equal to the payment + outstanding'
        );
        is( $credit_return->amountoutstanding + 0,
            $payment_amount * -1,
            'The account line of type CR has an amountoutstanding equal to the payment'
        );

        is( $account->balance,
            $processfee_amount - $payment_amount,
            'The patron balance is the difference between the PF and the credit'
        );
    };

    subtest 'Partial payement, existing debits and AccountAutoReconcile' => sub {

        plan tests => 8;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
        my $barcode = 'KD123456793';
        my $replacement_amount = 100;
        my $processfee_amount  = 20;

        my $item_type          = $builder->build_object(
            {   class => 'Koha::ItemTypes',
                value => {
                    notforloan         => undef,
                    rentalcharge       => 0,
                    defaultreplacecost => undef,
                    processfee         => 0
                }
            }
        );
        my ( undef, undef, $item_id ) = AddItem(
            {   homebranch       => $library->branchcode,
                holdingbranch    => $library->branchcode,
                barcode          => $barcode,
                replacementprice => $replacement_amount,
                itype            => $item_type->itemtype
            },
            $biblio->biblionumber
        );

        AddIssue( $patron->unblessed, $barcode );

        # Simulate item marked as lost
        ModItem( { itemlost => 1 }, $biblio->biblionumber, $item_id );
        LostItem( $item_id, 1 );

        my $lost_fee_lines = Koha::Account::Lines->search(
            { borrowernumber => $patron->id, itemnumber => $item_id, accounttype => 'L' } );
        is( $lost_fee_lines->count, 1, 'Only one lost item fee produced' );
        my $lost_fee_line = $lost_fee_lines->next;
        is( $lost_fee_line->amount + 0, $replacement_amount, 'The right L amount is generated' );
        is( $lost_fee_line->amountoutstanding + 0,
            $replacement_amount, 'The right L amountountstanding is generated' );

        my $account = $patron->account;
        is( $account->balance, $replacement_amount, 'Balance is L' );

        # Partially pay fee
        my $payment_amount = 27;
        my $payment        = $account->add_credit(
            {   amount => $payment_amount,
                type   => 'payment'
            }
        );
        $payment->apply({ debits => $lost_fee_lines->reset, offset_type => 'Payment' });

        is( $account->balance,
            $replacement_amount - $payment_amount,
            'Payment applied'
        );

        # TODO use add_debit when time comes
        my $manual_debit_amount = 80;
        C4::Accounts::manualinvoice( $patron->id, undef, undef, 'FU', $manual_debit_amount );

        is( $account->balance, $manual_debit_amount + $replacement_amount - $payment_amount, 'Manual debit applied' );

        t::lib::Mocks::mock_preference( 'AccountAutoReconcile', 1 );

        my $credit_return_id = C4::Circulation::_FixAccountForLostAndReturned( $item_id, $patron->id );
        my $credit_return = Koha::Account::Lines->find($credit_return_id);

        is( $account->balance, $manual_debit_amount - $payment_amount, 'Balance is PF - payment (CR)' );

        my $manual_debit = Koha::Account::Lines->search({ borrowernumber => $patron->id, accounttype => 'FU' })->next;
        is( $manual_debit->amountoutstanding + 0, $manual_debit_amount - $payment_amount, 'reconcile_balance was called' );
    };
};

subtest '_FixOverduesOnReturn' => sub {
    plan tests => 10;

    my $biblio = $builder->build_sample_biblio({ author => 'Hall, Kylie' });

    my $branchcode  = $library2->{branchcode};

    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branchcode,
            replacementprice => 99.00,
            itype            => $itemtype,
        }
    );

    my $patron = $builder->build( { source => 'Borrower' } );

    ## Start with basic call, should just close out the open fine
    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber => $patron->{borrowernumber},
            accounttype    => 'FU',
            itemnumber     => $item->itemnumber,
            amount => 99.00,
            amountoutstanding => 99.00,
            lastincrement => 9.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber );

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

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber, 1 );

    $accountline->_result()->discard_changes();
    my $offset = Koha::Account::Offsets->search({ debit_id => $accountline->id, type => 'Forgiven' })->next();

    is( $accountline->amountoutstanding + 0, 0, 'Fine has been reduced to 0' );
    is( $accountline->accounttype, 'FFOR', 'Open fine ( account type FU ) has been set to fine forgiven ( account type FFOR )');
    is( ref $offset, "Koha::Account::Offset", "Found matching offset for fine reduction via forgiveness" );
    is( $offset->amount, '-99.000000', "Amount of offset is correct" );

    ## Run again, with dropbox mode enabled
    $accountline->set(
        {
            accounttype    => 'FU',
            amountoutstanding => 99.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber, 0, 1 );

    $accountline->_result()->discard_changes();
    $offset = Koha::Account::Offsets->search({ debit_id => $accountline->id, type => 'Dropbox' })->next();

    is( $accountline->amountoutstanding + 0, 90, 'Fine has been reduced to 90' );
    is( $accountline->accounttype, 'F', 'Open fine ( account type FU ) has been closed out ( account type F )');
    is( ref $offset, "Koha::Account::Offset", "Found matching offset for fine reduction via dropbox" );
    is( $offset->amount, '-9.000000', "Amount of offset is correct" );
};

subtest '_FixAccountForLostAndReturned returns undef if patron is deleted' => sub {
    plan tests => 1;

    my $manager = $builder->build_object({ class => "Koha::Patrons" });
    t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $manager->branchcode });

    my $biblio = $builder->build_sample_biblio({ author => 'Hall, Kylie' });

    my $branchcode  = $library2->{branchcode};

    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $branchcode,
            replacementprice => 99.00,
            itype            => $itemtype,
        }
    );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    ## Start with basic call, should just close out the open fine
    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber => $patron->id,
            accounttype    => 'L',
            status         => undef,
            itemnumber     => $item->itemnumber,
            amount => 99.00,
            amountoutstanding => 99.00,
        }
    )->store();

    $patron->delete();

    my $return_value = C4::Circulation::_FixAccountForLostAndReturned( $patron->id, $item->itemnumber );

    is( $return_value, undef, "_FixAccountForLostAndReturned returns undef if patron is deleted" );

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

subtest 'ItemsDeniedRenewal preference' => sub {
    plan tests => 18;

    C4::Context->set_preference('ItemsDeniedRenewal','');

    my $idr_lib = $builder->build_object({ class => 'Koha::Libraries'});
    $dbh->do(
        q{
        INSERT INTO issuingrules ( categorycode, branchcode, itemtype, reservesallowed, maxissueqty, issuelength, lengthunit, renewalsallowed, renewalperiod,
                    norenewalbefore, auto_renew, fine, chargeperiod ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
        },
        {},
        '*', $idr_lib->branchcode, '*', 25,
        20,  14,  'days',
        10,   7,
        undef,  0,
        .10, 1
    );

    my $deny_book = $builder->build_object({ class => 'Koha::Items', value => {
        homebranch => $idr_lib->branchcode,
        withdrawn => 1,
        itype => 'HIDE',
        location => 'PROC',
        itemcallnumber => undef,
        itemnotes => "",
        }
    });
    my $allow_book = $builder->build_object({ class => 'Koha::Items', value => {
        homebranch => $idr_lib->branchcode,
        withdrawn => 0,
        itype => 'NOHIDE',
        location => 'NOPROC'
        }
    });

    my $idr_borrower = $builder->build_object({ class => 'Koha::Patrons', value=> {
        branchcode => $idr_lib->branchcode,
        }
    });
    my $future = dt_from_string->add( days => 1 );
    my $deny_issue = $builder->build_object({ class => 'Koha::Checkouts', value => {
        returndate => undef,
        renewals => 0,
        auto_renew => 0,
        borrowernumber => $idr_borrower->borrowernumber,
        itemnumber => $deny_book->itemnumber,
        onsite_checkout => 0,
        date_due => $future,
        }
    });
    my $allow_issue = $builder->build_object({ class => 'Koha::Checkouts', value => {
        returndate => undef,
        renewals => 0,
        auto_renew => 0,
        borrowernumber => $idr_borrower->borrowernumber,
        itemnumber => $allow_book->itemnumber,
        onsite_checkout => 0,
        date_due => $future,
        }
    });

    my $idr_rules;

    my ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal allowed when no rules' );
    is( $idr_error, undef, 'Renewal allowed when no rules' );

    $idr_rules="withdrawn: [1]";

    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 0, 'Renewal blocked when 1 rules (withdrawn)' );
    is( $idr_error, 'item_denied_renewal', 'Renewal blocked when 1 rule (withdrawn)' );
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $allow_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal allowed when 1 rules not matched (withdrawn)' );
    is( $idr_error, undef, 'Renewal allowed when 1 rules not matched (withdrawn)' );

    $idr_rules="withdrawn: [1]\nitype: [HIDE,INVISIBLE]";

    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 0, 'Renewal blocked when 2 rules matched (withdrawn, itype)' );
    is( $idr_error, 'item_denied_renewal', 'Renewal blocked when 2 rules matched (withdrawn,itype)' );
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $allow_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal allowed when 2 rules not matched (withdrawn, itype)' );
    is( $idr_error, undef, 'Renewal allowed when 2 rules not matched (withdrawn, itype)' );

    $idr_rules="withdrawn: [1]\nitype: [HIDE,INVISIBLE]\nlocation: [PROC]";

    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 0, 'Renewal blocked when 3 rules matched (withdrawn, itype, location)' );
    is( $idr_error, 'item_denied_renewal', 'Renewal blocked when 3 rules matched (withdrawn,itype, location)' );
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $allow_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal allowed when 3 rules not matched (withdrawn, itype, location)' );
    is( $idr_error, undef, 'Renewal allowed when 3 rules not matched (withdrawn, itype, location)' );

    $idr_rules="itemcallnumber: [NULL]";
    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 0, 'Renewal blocked for undef when NULL in pref' );
    $idr_rules="itemcallnumber: ['']";
    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal not blocked for undef when "" in pref' );

    $idr_rules="itemnotes: [NULL]";
    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 1, 'Renewal not blocked for "" when NULL in pref' );
    $idr_rules="itemnotes: ['']";
    C4::Context->set_preference('ItemsDeniedRenewal',$idr_rules);
    ( $idr_mayrenew, $idr_error ) =
    CanBookBeRenewed( $idr_borrower->borrowernumber, $deny_issue->itemnumber );
    is( $idr_mayrenew, 0, 'Renewal blocked for empty string when "" in pref' );
};

subtest 'CanBookBeIssued | item-level_itypes=biblio' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('item-level_itypes', 0); # biblio
    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } )->store;

    my $itemtype = $builder->build(
        {
            source => 'Itemtype',
            value  => { notforloan => undef, }
        }
    );

    my $biblioitem = $builder->build( { source => 'Biblioitem', value => { itemtype => $itemtype->{itemtype} } } );
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->{biblionumber},
                biblioitemnumber => $biblioitem->{biblioitemnumber},
            }
        }
    )->store;

    my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
    is_deeply( $needsconfirmation, {}, 'Item can be issued to this patron' );
    is_deeply( $issuingimpossible, {}, 'Item can be issued to this patron' );
};

subtest 'CanBookBeIssued | notforloan' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('AllowNotForLoanOverride', 0);

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } )->store;

    my $itemtype = $builder->build(
        {
            source => 'Itemtype',
            value  => { notforloan => undef, }
        }
    );

    my $biblioitem = $builder->build( { source => 'Biblioitem' } );
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                itype         => $itemtype->{itemtype},
                biblionumber  => $biblioitem->{biblionumber},
                biblioitemnumber => $biblioitem->{biblioitemnumber},
            }
        }
    )->store;

    my ( $issuingimpossible, $needsconfirmation );


    subtest 'item-level_itypes = 1' => sub {
        plan tests => 6;

        t::lib::Mocks::mock_preference('item-level_itypes', 1); # item
        # Is for loan at item type and item level
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'Item can be issued to this patron' );
        is_deeply( $issuingimpossible, {}, 'Item can be issued to this patron' );

        # not for loan at item type level
        Koha::ItemTypes->find( $itemtype->{itemtype} )->notforloan(1)->store;
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'No confirmation needed, AllowNotForLoanOverride=0' );
        is_deeply(
            $issuingimpossible,
            { NOT_FOR_LOAN => 1, itemtype_notforloan => $itemtype->{itemtype} },
            'Item can not be issued, not for loan at item type level'
        );

        # not for loan at item level
        Koha::ItemTypes->find( $itemtype->{itemtype} )->notforloan(undef)->store;
        $item->notforloan( 1 )->store;
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'No confirmation needed, AllowNotForLoanOverride=0' );
        is_deeply(
            $issuingimpossible,
            { NOT_FOR_LOAN => 1, item_notforloan => 1 },
            'Item can not be issued, not for loan at item type level'
        );
    };

    subtest 'item-level_itypes = 0' => sub {
        plan tests => 6;

        t::lib::Mocks::mock_preference('item-level_itypes', 0); # biblio

        # We set another itemtype for biblioitem
        my $itemtype = $builder->build(
            {
                source => 'Itemtype',
                value  => { notforloan => undef, }
            }
        );

        # for loan at item type and item level
        $item->notforloan(0)->store;
        $item->biblioitem->itemtype($itemtype->{itemtype})->store;
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'Item can be issued to this patron' );
        is_deeply( $issuingimpossible, {}, 'Item can be issued to this patron' );

        # not for loan at item type level
        Koha::ItemTypes->find( $itemtype->{itemtype} )->notforloan(1)->store;
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'No confirmation needed, AllowNotForLoanOverride=0' );
        is_deeply(
            $issuingimpossible,
            { NOT_FOR_LOAN => 1, itemtype_notforloan => $itemtype->{itemtype} },
            'Item can not be issued, not for loan at item type level'
        );

        # not for loan at item level
        Koha::ItemTypes->find( $itemtype->{itemtype} )->notforloan(undef)->store;
        $item->notforloan( 1 )->store;
        ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, undef );
        is_deeply( $needsconfirmation, {}, 'No confirmation needed, AllowNotForLoanOverride=0' );
        is_deeply(
            $issuingimpossible,
            { NOT_FOR_LOAN => 1, item_notforloan => 1 },
            'Item can not be issued, not for loan at item type level'
        );
    };

    # TODO test with AllowNotForLoanOverride = 1
};

subtest 'AddReturn should clear items.onloan for unissued items' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference( "AllowReturnToBranch", 'anywhere' );
    my $item = $builder->build_object({ class => 'Koha::Items', value  => { onloan => '2018-01-01' }});
    AddReturn( $item->barcode, $item->homebranch );
    $item->discard_changes; # refresh
    is( $item->onloan, undef, 'AddReturn did clear items.onloan' );
};


subtest 'AddRenewal and AddIssuingCharge tests' => sub {

    plan tests => 10;


    my $issuing_charges = 15;
    my $title   = 'A title';
    my $author  = 'Author, An';
    my $barcode = 'WHATARETHEODDS';

    my $circ = Test::MockModule->new('C4::Circulation');
    $circ->mock(
        'GetIssuingCharges',
        sub {
            return $issuing_charges;
        }
    );

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $patron   = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $library->id }
    });

    my $biblio = $builder->build_sample_biblio({ title=> $title, author => $author });
    my ( undef, undef, $item_id ) = AddItem(
        {
            homebranch       => $library->id,
            holdingbranch    => $library->id,
            barcode          => $barcode,
            replacementprice => 23.00,
            itype            => $itemtype->id
        },
        $biblio->biblionumber
    );
    my $item = Koha::Items->find( $item_id );

    my $items = Test::MockModule->new('C4::Items');
    $items->mock( GetItem => $item->unblessed );
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( userenv => { branch => $library->id } );

    # Check the item out
    AddIssue( $patron->unblessed, $item->barcode );

    t::lib::Mocks::mock_preference( 'RenewalLog', 0 );
    my $date = output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } );
    my $old_log_size = scalar( @{ GetLogs( $date, $date, undef, ["CIRCULATION"], ["RENEWAL"] ) } );
    AddRenewal( $patron->id, $item->id, $library->id );
    my $new_log_size = scalar( @{ GetLogs( $date, $date, undef, ["CIRCULATION"], ["RENEWAL"] ) } );
    is( $new_log_size, $old_log_size, 'renew log not added because of the syspref RenewalLog' );

    my $checkouts = $patron->checkouts;
    # The following will fail if run on 00:00:00
    unlike ( $checkouts->next->lastreneweddate, qr/00:00:00/, 'AddRenewal should set the renewal date with the time part');

    t::lib::Mocks::mock_preference( 'RenewalLog', 1 );
    $date = output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } );
    $old_log_size = scalar( @{ GetLogs( $date, $date, undef, ["CIRCULATION"], ["RENEWAL"] ) } );
    AddRenewal( $patron->id, $item->id, $library->id );
    $new_log_size = scalar( @{ GetLogs( $date, $date, undef, ["CIRCULATION"], ["RENEWAL"] ) } );
    is( $new_log_size, $old_log_size + 1, 'renew log successfully added' );

    my $lines = Koha::Account::Lines->search({
        borrowernumber => $patron->id,
        itemnumber     => $item->id
    });

    is( $lines->count, 3 );

    my $line = $lines->next;
    is( $line->accounttype, 'Rent',       'The issuing charge generates an accountline' );
    is( $line->description, 'Rental',     'AddIssuingCharge set a hardcoded description for the accountline' );

    $line = $lines->next;
    is( $line->accounttype, 'Rent', 'Fine on renewed item is closed out properly' );
    is( $line->description, "Renewal of Rental Item $title $barcode", 'AddRenewal set a hardcoded description for the accountline' );

    $line = $lines->next;
    is( $line->accounttype, 'Rent', 'Fine on renewed item is closed out properly' );
    is( $line->description, "Renewal of Rental Item $title $barcode", 'AddRenewal set a hardcoded description for the accountline' );

};

subtest 'ProcessOfflinePayment() tests' => sub {

    plan tests => 3;


    my $amount = 123;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $result  = C4::Circulation::ProcessOfflinePayment({ cardnumber => $patron->cardnumber, amount => $amount, branchcode => $library->id });

    is( $result, 'Success.', 'The right string is returned' );

    my $lines = $patron->account->lines;
    is( $lines->count, 1, 'line created correctly');

    my $line = $lines->next;
    is( $line->amount+0, $amount * -1, 'amount picked from params' );

};


$schema->storage->txn_rollback;
C4::Context->clear_syspref_cache();
$cache->clear_from_cache('single_holidays');
