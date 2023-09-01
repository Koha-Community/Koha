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

use Test::More tests => 67;
use Test::Exception;
use Test::MockModule;
use Test::Deep qw( cmp_deeply );
use Test::Warn;

use Data::Dumper;
use DateTime;
use Time::Fake;
use POSIX qw( floor );
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Accounts;
use C4::Calendar qw( new insert_single_holiday insert_week_day_holiday delete_holiday );
use C4::Circulation qw( AddIssue AddReturn CanBookBeRenewed GetIssuingCharges AddRenewal GetSoonestRenewDate GetLatestAutoRenewDate LostItem GetUpcomingDueIssues CanBookBeIssued AddIssuingCharge MarkIssueReturned ProcessOfflinePayment transferbook updateWrongTransfer );
use C4::Biblio;
use C4::Items qw( ModItemTransfer );
use C4::Log;
use C4::Reserves qw( AddReserve ModReserve ModReserveCancelAll ModReserveAffect CheckReserves GetOtherReserves );
use C4::Overdues qw( CalcFine UpdateFine get_chargeable_units );
use C4::Members::Messaging qw( SetMessagingPreference );
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Database;
use Koha::Items;
use Koha::Item::Transfers;
use Koha::Checkouts;
use Koha::Patrons;
use Koha::Patron::Debarments qw( AddDebarment DelUniqueDebarment );
use Koha::Holds;
use Koha::CirculationRules;
use Koha::Subscriptions;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::ActionLogs;
use Koha::Notice::Messages;
use Koha::Cache::Memory::Lite;

my $builder = t::lib::TestBuilder->new;
sub set_userenv {
    my ( $library ) = @_;
    my $staff = $builder->build_object({ class => "Koha::Patrons" });
    t::lib::Mocks::mock_userenv({ patron => $staff, branchcode => $library->{branchcode} });
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
    AddIssue( $patron->unblessed, $item->barcode, $due_date );

    my ( undef, $message ) = AddReturn( $item->barcode, $library->{branchcode}, undef, $return_date );
    is( $message->{WasReturned} && exists $message->{Debarred}, 1, 'AddReturn must have debarred the patron' )
        or diag('AddReturn returned message ' . Dumper $message );
    my $suspensions = $patron->restrictions->search({ type => 'SUSPENSION' } );
    is( $suspensions->count, 1, 'Test at line ' . $line_number );

    my $THE_suspension = $suspensions->next;
    is( $THE_suspension->expiration,
        $expected_expiration_date, 'Test at line ' . $line_number );
    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->borrowernumber, type => 'SUSPENSION' } );
};

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Prevent random failures by mocking ->now
my $now_value       = dt_from_string;
my $mocked_datetime = Test::MockModule->new('DateTime');
$mocked_datetime->mock( 'now', sub { return $now_value->clone; } );

my $cache = Koha::Caches->get_instance();
$dbh->do(q|DELETE FROM special_holidays|);
$dbh->do(q|DELETE FROM repeatable_holidays|);
my $branches = Koha::Libraries->search();
for my $branch ( $branches->next ) {
    my $key = $branch->branchcode . "_holidays";
    $cache->clear_from_cache($key);
}

# Start with a clean slate
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM borrowers');

# Disable recording of the staff who checked out an item until we're ready for it
t::lib::Mocks::mock_preference('RecordStaffUserOnCheckout', 0);

my $module = Test::MockModule->new('C4::Context');

my $library = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $itemtype = $builder->build(
    {
        source => 'Itemtype',
        value  => {
            notforloan          => undef,
            rentalcharge        => 0,
            rentalcharge_daily => 0,
            defaultreplacecost  => undef,
            processfee          => undef
        }
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

t::lib::Mocks::mock_preference('AutoReturnCheckedOutItems', 0);

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
$dbh->do('DELETE FROM circulation_rules');
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            reservesallowed => 25,
            issuelength     => 14,
            lengthunit      => 'days',
            renewalsallowed => 1,
            renewalperiod   => 7,
            norenewalbefore => undef,
            auto_renew      => 0,
            fine            => .10,
            chargeperiod    => 1,
        }
    }
);

subtest "CanBookBeRenewed AllowRenewalIfOtherItemsAvailable multiple borrowers and items tests" => sub {
    plan tests => 7;

    #Can only reserve from home branch
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'holdallowed',
            rule_value   => 1
        }
    );
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            categorycode   => undef,
            itemtype     => undef,
            rule_name    => 'onshelfholds',
            rule_value   => 1
        }
    );

    # Patrons from three different branches
    my $patron_borrower = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_hold_1   = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_hold_2   = $builder->build_object({ class => 'Koha::Patrons' });
    my $biblio = $builder->build_sample_biblio();

    # Item at each patron branch
    my $item_1 = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
        homebranch   => $patron_borrower->branchcode
    });
    my $item_2 = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
        homebranch   => $patron_hold_2->branchcode
    });
    my $item_3 = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
        homebranch   => $patron_hold_1->branchcode
    });

    my $issue = AddIssue( $patron_borrower->unblessed, $item_1->barcode);
    my $datedue = dt_from_string( $issue->date_due() );
    is (defined $issue->date_due(), 1, "Item 1 checked out, due date: " . $issue->date_due() );

    # Biblio-level holds
    my $reserve_1 = AddReserve(
        {
            branchcode       => $patron_hold_1->branchcode,
            borrowernumber   => $patron_hold_1->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            priority         => 1,
            reservation_date => dt_from_string(),
            expiration_date  => undef,
            itemnumber       => undef,
            found            => undef,
        }
    );
    AddReserve(
        {
            branchcode       => $patron_hold_2->branchcode,
            borrowernumber   => $patron_hold_2->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            priority         => 2,
            reservation_date => dt_from_string(),
            expiration_date  => undef,
            itemnumber       => undef,
            found            => undef,
        }
    );
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 0 );

    my ( $renewokay, $error ) = CanBookBeRenewed($patron_borrower->borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Cannot renew, reserved');
    is( $error, 'on_reserve', 'Cannot renew, reserved (returned error is on_reserve)');

    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 1 );

    ( $renewokay, $error ) = CanBookBeRenewed($patron_borrower->borrowernumber, $item_1->itemnumber);
    is( $renewokay, 1, 'Can renew, two items available for two holds');
    is( $error, undef, 'Can renew, each reserve has an item');

    # Item level hold
    my $hold = Koha::Holds->find( $reserve_1 );
    $hold->itemnumber( $item_1->itemnumber )->store;

    ( $renewokay, $error ) = CanBookBeRenewed($patron_borrower->borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Cannot renew when there is an item specific hold');
    is( $error, 'on_reserve', 'Cannot renew, only this item can fill the reserve');

};

subtest "GetIssuingCharges tests" => sub {
    plan tests => 4;
    my $branch_discount = $builder->build_object({ class => 'Koha::Libraries' });
    my $branch_no_discount = $builder->build_object({ class => 'Koha::Libraries' });
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => $branch_discount->branchcode,
            itemtype     => undef,
            rule_name    => 'rentaldiscount',
            rule_value   => 15
        }
    );
    my $itype_charge = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            rentalcharge => 10
        }
    });
    my $itype_no_charge = $builder->build_object({
        class => 'Koha::ItemTypes',
        value => {
            rentalcharge => 0
        }
    });
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $item_1 = $builder->build_sample_item({ itype => $itype_charge->itemtype });
    my $item_2 = $builder->build_sample_item({ itype => $itype_no_charge->itemtype });

    t::lib::Mocks::mock_userenv({ branchcode => $branch_no_discount->branchcode });
    # For now the sub always uses the env branch, this should follow CircControl instead
    my ($charge, $itemtype) = GetIssuingCharges( $item_1->itemnumber, $patron->borrowernumber);
    is( $charge + 0, 10.00, "Charge fetched correctly when no discount exists");
    ($charge, $itemtype) = GetIssuingCharges( $item_2->itemnumber, $patron->borrowernumber);
    is( $charge + 0, 0.00, "Charge fetched correctly when no discount exists and no charge");

    t::lib::Mocks::mock_userenv({ branchcode => $branch_discount->branchcode });
    # For now the sub always uses the env branch, this should follow CircControl instead
    ($charge, $itemtype) = GetIssuingCharges( $item_1->itemnumber, $patron->borrowernumber);
    is( $charge + 0, 8.50, "Charge fetched correctly when discount exists");
    ($charge, $itemtype) = GetIssuingCharges( $item_2->itemnumber, $patron->borrowernumber);
    is( $charge + 0, 0.00, "Charge fetched correctly when discount exists and no charge");

};

my ( $reused_itemnumber_1, $reused_itemnumber_2 );
subtest "CanBookBeRenewed tests" => sub {
    plan tests => 104;

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

    my $renewing_borrower_obj = Koha::Patrons->find( $renewing_borrowernumber );
    my $renewing_borrower = $renewing_borrower_obj->unblessed;
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
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber,
            biblionumber     => $biblio->biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            itemnumber       => $checkitem,
            found            => $found,
        }
    );

    # Testing of feature to allow the renewal of reserved items if other items on the record can fill all needed holds
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'onshelfholds',
            rule_value   => '1',
        }
    );
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'renewalsallowed',
            rule_value   => '5',
        }
    );
    t::lib::Mocks::mock_preference('AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber);
    is( $renewokay, 1, 'Bug 11634 - Allow renewal of item with unfilled holds if other available items can fill those holds');


    # Second biblio-level hold
    my $reserve_id = AddReserve(
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber,
            biblionumber     => $biblio->biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            itemnumber       => $checkitem,
            found            => $found,
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Renewal not possible when single patron\'s holds exceed the number of available items');
    Koha::Holds->find($reserve_id)->delete;

    # Now let's add an item level hold, we should no longer be able to renew the item
    my $hold = Koha::Database->new()->schema()->resultset('Reserve')->create(
        {
            borrowernumber => $hold_waiting_borrowernumber,
            biblionumber   => $biblio->biblionumber,
            itemnumber     => $item_1->itemnumber,
            branchcode     => $branch,
            priority       => 3,
            reservedate    => '1999-01-01',
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
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber,
            biblionumber     => $biblio->biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            itemnumber       => $item_1->itemnumber,
            found            => $found,
        }
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
    is( $renewokay, 0, '(Bug 10663) Cannot renew, item reserved');
    is( $error, 'on_reserve', '(Bug 10663) Cannot renew, item reserved (returned error is on_reserve)');

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_2->itemnumber, 1);
    is( $renewokay, 1, 'Can renew item 2, item-level hold is on item 1');

    # Items can't fill hold for reasons
    $item_1->notforloan(1)->store;
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber, 1);
    is( $renewokay, 0, 'Cannot renew, item is marked not for loan, but an item specific hold always blocks');
    $item_1->set({notforloan => 0, itype => $itemtype })->store;

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
    is( $error, 'restriction', "Correct error returned");

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

    t::lib::Mocks::mock_preference('OverduesBlockRenewing','allow');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_6->itemnumber);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is not overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_7->itemnumber);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is overdue but not pref does not block');

    t::lib::Mocks::mock_preference('OverduesBlockRenewing','block');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_6->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is not overdue but patron has overdues');
    is( $error, 'overdue', "Correct error returned");
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_7->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is overdue so patron has overdues');
    is( $error, 'overdue', "Correct error returned");

    t::lib::Mocks::mock_preference('OverduesBlockRenewing','blockitem');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_6->itemnumber);
    is( $renewokay, 1, '(Bug 8236), Can renew, this item is not overdue');
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_7->itemnumber);
    is( $renewokay, 0, '(Bug 8236), Cannot renew, this item is overdue');
    is( $error, 'overdue', "Correct error returned");

    my ( $fine ) = CalcFine( $item_7->unblessed, $renewing_borrower->{categorycode}, $branch, $five_weeks_ago, $now );
    C4::Overdues::UpdateFine(
        {
            issue_id       => $passeddatedue1->id(),
            itemnumber     => $item_7->itemnumber,
            borrowernumber => $renewing_borrower->{borrowernumber},
            amount         => $fine,
            due            => Koha::DateUtils::output_pref($five_weeks_ago)
        }
    );

    # Make sure fine calculation isn't skipped when adding renewal
    t::lib::Mocks::mock_preference('CalculateFinesOnReturn', 1);

    # Calculate new due-date based on the present date not to incur
    # multiple fees
    t::lib::Mocks::mock_preference('RenewalPeriodBase', 'now');

    my $staff = $builder->build_object({ class => "Koha::Patrons" });
    t::lib::Mocks::mock_userenv({ patron => $staff });

    t::lib::Mocks::mock_preference('RenewalLog', 0);
    my $date = output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } );
    my %params_renewal = (
        timestamp => { -like => $date . "%" },
        module => "CIRCULATION",
        action => "RENEWAL",
    );
    my %params_issue = (
        timestamp => { -like => $date . "%" },
        module => "CIRCULATION",
        action => "ISSUE"
    );
    my $old_log_size = Koha::ActionLogs->count( \%params_renewal );
    my $dt = dt_from_string();
    Time::Fake->offset( $dt->epoch );
    my $datedue1 = AddRenewal( $renewing_borrower->{borrowernumber}, $item_7->itemnumber, $branch );
    my $new_log_size = Koha::ActionLogs->count( \%params_renewal );
    is ($new_log_size, $old_log_size, 'renew log not added because of the syspref RenewalLog');
    isnt (DateTime->compare($datedue1, $dt), 0, "AddRenewal returned a good duedate");
    Time::Fake->reset;

    t::lib::Mocks::mock_preference('RenewalLog', 1);
    $date = output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } );
    $old_log_size = Koha::ActionLogs->count( \%params_renewal );
    AddRenewal( $renewing_borrower->{borrowernumber}, $item_7->itemnumber, $branch );
    $new_log_size = Koha::ActionLogs->count( \%params_renewal );
    is ($new_log_size, $old_log_size + 1, 'renew log successfully added');

    my $fines = Koha::Account::Lines->search( { borrowernumber => $renewing_borrower->{borrowernumber}, itemnumber => $item_7->itemnumber } );
    is( $fines->count, 1, 'AddRenewal left fine' );
    is( $fines->next->status, 'RENEWED', 'Fine on renewed item is closed out properly' );
    $fines->delete();

    my $old_issue_log_size = Koha::ActionLogs->count( \%params_issue );
    my $old_renew_log_size = Koha::ActionLogs->count( \%params_renewal );
    AddIssue( $renewing_borrower,$item_7->barcode,Koha::DateUtils::output_pref({str=>$datedue6->date_due, dateformat =>'iso'}),0,$date, 0, undef );
    $new_log_size = Koha::ActionLogs->count( \%params_renewal );
    is ($new_log_size, $old_renew_log_size + 1, 'renew log successfully added when renewed via issuing');
    $new_log_size = Koha::ActionLogs->count( \%params_issue );
    is ($new_log_size, $old_issue_log_size, 'renew not logged as issue when renewed via issuing');

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
    my $info;
    ( $renewokay, $error, $info ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = undef (returned code is auto_too_soon)' );
    is( $info->{soonest_renew_date} , dt_from_string($issue->date_due), "Due date is returned as earliest renewal date when error is 'auto_too_soon'" );
    AddReserve(
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber,
            biblionumber     => $biblio->biblionumber,
            itemnumber       => $bibitems,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            title            => 'a title',
            itemnumber       => $item_4->itemnumber,
            found            => $found
        }
    );
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Still should not be able to renew' );
    is( $error, 'on_reserve', 'returned code is on_reserve, reserve checked when not checking for cron' );
    ( $renewokay, $error, $info ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber, undef, 1 );
    is( $renewokay, 0, 'Still should not be able to renew' );
    is( $error, 'auto_too_soon', 'returned code is auto_too_soon, reserve not checked when checking for cron' );
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due), "Due date is returned as earliest renewal date when error is 'auto_too_soon'" );
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber, 1 );
    is( $renewokay, 0, 'Still should not be able to renew' );
    is( $error, 'on_reserve', 'returned code is on_reserve, auto_too_soon limit is overridden' );
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber, 1, 1 );
    is( $renewokay, 0, 'Still should not be able to renew' );
    is( $error, 'on_reserve', 'returned code is on_reserve, auto_too_soon limit is overridden' );
    $dbh->do('UPDATE circulation_rules SET rule_value = 0 where rule_name = "norenewalbefore"');
    Koha::Cache::Memory::Lite->flush();
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber, 1 );
    is( $renewokay, 0, 'Still should not be able to renew' );
    is( $error, 'on_reserve', 'returned code is on_reserve, auto_renew only happens if not on reserve' );
    ModReserveCancelAll($item_4->itemnumber, $reserving_borrowernumber);



    $renewing_borrower_obj->autorenew_checkouts(0)->store;
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 1, 'No renewal before is undef, but patron opted out of auto_renewal' );
    $renewing_borrower_obj->autorenew_checkouts(1)->store;


    # Bug 7413
    # Test premature manual renewal
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'norenewalbefore',
            rule_value   => '7',
        }
    );

    ( $renewokay, $error, $info ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Bug 7413: Cannot renew, renewal is premature');
    is( $error, 'too_soon', 'Bug 7413: Cannot renew, renewal is premature (returned code is too_soon)');
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due)->subtract( days => 7 ), "Soonest renew date returned when error is 'too_soon'");

    # Bug 14101
    # Test premature automatic renewal
    ( $renewokay, $error, $info ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature (returned code is auto_too_soon)'
    );
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due)->subtract( days => 7 ), "Soonest renew date returned when error is 'auto_too_soon'");

    $renewing_borrower_obj->autorenew_checkouts(0)->store;
    ( $renewokay, $error, $info ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'No renewal before is 7, patron opted out of auto_renewal still cannot renew early' );
    is( $error, 'too_soon', 'Error is too_soon, no auto' );
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due)->subtract( days => 7 ), "Soonest renew date returned when error is 'too_soon'");
    $renewing_borrower_obj->autorenew_checkouts(1)->store;

    # Change policy so that loans can only be renewed exactly on due date (0 days prior to due date)
    # and test automatic renewal again
    $dbh->do(q{UPDATE circulation_rules SET rule_value = '0' WHERE rule_name = 'norenewalbefore'});
    Koha::Cache::Memory::Lite->flush();
    ( $renewokay, $error, $info ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic and premature' );
    is( $error, 'auto_too_soon',
        'Bug 14101: Cannot renew, renewal is automatic and premature, "No renewal before" = 0 (returned code is auto_too_soon)'
    );
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due), "Soonest renew date returned when error is 'auto_too_soon'");

    $renewing_borrower_obj->autorenew_checkouts(0)->store;
    ( $renewokay, $error, $info ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'No renewal before is 0, patron opted out of auto_renewal still cannot renew early' );
    is( $error, 'too_soon', 'Error is too_soon, no auto' );
    is( $info->{soonest_renew_date}, dt_from_string($issue->date_due), "Soonest renew date returned when error is 'auto_too_soon'");
    $renewing_borrower_obj->autorenew_checkouts(1)->store;

    # Change policy so that loans can be renewed 99 days prior to the due date
    # and test automatic renewal again
    $dbh->do(q{UPDATE circulation_rules SET rule_value = '99' WHERE rule_name = 'norenewalbefore'});
    Koha::Cache::Memory::Lite->flush();
    ( $renewokay, $error ) =
      CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 0, 'Bug 14101: Cannot renew, renewal is automatic' );
    is( $error, 'auto_renew',
        'Bug 14101: Cannot renew, renewal is automatic (returned code is auto_renew)'
    );

    $renewing_borrower_obj->autorenew_checkouts(0)->store;
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $item_4->itemnumber );
    is( $renewokay, 1, 'No renewal before is 99, patron opted out of auto_renewal so can renew' );
    $renewing_borrower_obj->autorenew_checkouts(1)->store;

    subtest "too_late_renewal / no_auto_renewal_after" => sub {
        plan tests => 14;
        my $item_to_auto_renew = $builder->build_sample_item(
            {
                biblionumber => $biblio->biblionumber,
                library      => $branch,
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead  = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '7',
                    no_auto_renewal_after => '9',
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '7',
                    no_auto_renewal_after => '10',
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot auto renew, too late - no_auto_renewal_after is inclusive(returned code is auto_too_late)' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '7',
                    no_auto_renewal_after => '11',
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_soon', 'Cannot auto renew, too soon - no_auto_renewal_after is defined(returned code is auto_too_soon)' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '11',
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0,            'Do not renew, renewal is automatic' );
        is( $error,     'auto_renew', 'Cannot renew, renew is automatic' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => undef,
                    no_auto_renewal_after_hard_limit => dt_from_string->add( days => -1 ),
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '7',
                    no_auto_renewal_after => '15',
                    no_auto_renewal_after_hard_limit => dt_from_string->add( days => -1 ),
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_late', 'Cannot renew, too late(returned code is auto_too_late)' );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => undef,
                    no_auto_renewal_after_hard_limit => dt_from_string->add( days => 1 ),
                }
            }
        );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Cannot renew, renew is automatic' );
    };

    subtest "auto_too_much_oweing | OPACFineNoRenewalsBlockAutoRenew & OPACFineNoRenewalsIncludeCredit" => sub {
        plan tests => 10;
        my $item_to_auto_renew = $builder->build_sample_item(
            {
                biblionumber => $biblio->biblionumber,
                library      => $branch,
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '11',
                }
            }
        );
        C4::Context->set_preference('OPACFineNoRenewalsBlockAutoRenew','1');
        C4::Context->set_preference('OPACFineNoRenewals','10');
        C4::Context->set_preference('OPACFineNoRenewalsIncludeCredit','1');
        my $fines_amount = 5;
        my $account = Koha::Account->new({patron_id => $renewing_borrowernumber});
        $account->add_debit(
            {
                amount      => $fines_amount,
                interface   => 'test',
                type        => 'OVERDUE',
                item_id     => $item_to_auto_renew->itemnumber,
                description => "Some fines"
            }
        )->status('RETURNED')->store;
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, OPACFineNoRenewals=10, patron has 5' );

        $account->add_debit(
            {
                amount      => $fines_amount,
                interface   => 'test',
                type        => 'OVERDUE',
                item_id     => $item_to_auto_renew->itemnumber,
                description => "Some fines"
            }
        )->status('RETURNED')->store;
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, OPACFineNoRenewals=10, patron has 10' );

        $account->add_debit(
            {
                amount      => $fines_amount,
                interface   => 'test',
                type        => 'OVERDUE',
                item_id     => $item_to_auto_renew->itemnumber,
                description => "Some fines"
            }
        )->status('RETURNED')->store;
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_much_oweing', 'Cannot auto renew, OPACFineNoRenewals=10, patron has 15' );

        $account->add_credit(
            {
                amount      => $fines_amount,
                interface   => 'test',
                type        => 'PAYMENT',
                description => "Some payment"
            }
        )->store;
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, OPACFineNoRenewals=10, OPACFineNoRenewalsIncludeCredit=1, patron has 15 debt, 5 credit'  );

        C4::Context->set_preference('OPACFineNoRenewalsIncludeCredit','0');
        ( $renewokay, $error ) =
          CanBookBeRenewed( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_too_much_oweing', 'Cannot auto renew, OPACFineNoRenewals=10, OPACFineNoRenewalsIncludeCredit=1, patron has 15 debt, 5 credit'  );

        $dbh->do('DELETE FROM accountlines WHERE borrowernumber=?', undef, $renewing_borrowernumber);
        C4::Context->set_preference('OPACFineNoRenewalsIncludeCredit','1');
    };

    subtest "auto_account_expired | BlockExpiredPatronOpacActions" => sub {
        plan tests => 6;
        my $item_to_auto_renew = $builder->build_sample_item(
            {
                biblionumber => $biblio->biblionumber,
                library      => $branch,
            }
        );

        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => 10,
                    no_auto_renewal_after => 11,
                }
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead = dt_from_string->add( days => 10 );

        # Patron is expired and BlockExpiredPatronOpacActions=0
        # => auto renew is allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 0);
        my $patron = $expired_borrower;
        my $checkout = AddIssue( $patron, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, patron is expired but BlockExpiredPatronOpacActions=0' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;


        # Patron is expired and BlockExpiredPatronOpacActions=1
        # => auto renew is not allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 1);
        $patron = $expired_borrower;
        $checkout = AddIssue( $patron, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_account_expired', 'Can not auto renew, lockExpiredPatronOpacActions=1 and patron is expired' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;


        # Patron is not expired and BlockExpiredPatronOpacActions=1
        # => auto renew is allowed
        t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 1);
        $patron = $renewing_borrower;
        $checkout = AddIssue( $patron, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        ( $renewokay, $error ) =
          CanBookBeRenewed( $patron->{borrowernumber}, $item_to_auto_renew->itemnumber );
        is( $renewokay, 0, 'Do not renew, renewal is automatic' );
        is( $error, 'auto_renew', 'Can auto renew, BlockExpiredPatronOpacActions=1 but patron is not expired' );
        Koha::Checkouts->find( $checkout->issue_id )->delete;
    };

    subtest "GetLatestAutoRenewDate" => sub {
        plan tests => 5;
        my $item_to_auto_renew = $builder->build_sample_item(
            {
                biblionumber => $biblio->biblionumber,
                library      => $branch,
            }
        );

        my $ten_days_before = dt_from_string->add( days => -10 );
        my $ten_days_ahead  = dt_from_string->add( days => 10 );
        AddIssue( $renewing_borrower, $item_to_auto_renew->barcode, $ten_days_ahead, undef, $ten_days_before, undef, { auto_renew => 1 } );
        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '7',
                    no_auto_renewal_after => '',
                    no_auto_renewal_after_hard_limit => undef,
                }
            }
        );
        my $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $latest_auto_renew_date, undef, 'GetLatestAutoRenewDate should return undef if no_auto_renewal_after or no_auto_renewal_after_hard_limit are not defined' );
        my $five_days_before = dt_from_string->add( days => -5 );
        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '5',
                    no_auto_renewal_after_hard_limit => undef,
                }
            }
        );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $latest_auto_renew_date->truncate( to => 'minute' ),
            $five_days_before->truncate( to => 'minute' ),
            'GetLatestAutoRenewDate should return -5 days if no_auto_renewal_after = 5 and date_due is 10 days before'
        );
        my $five_days_ahead = dt_from_string->add( days => 5 );
        $dbh->do(q{UPDATE circulation_rules SET rule_value = '10' WHERE rule_name = 'norenewalbefore'});
        $dbh->do(q{UPDATE circulation_rules SET rule_value = '15' WHERE rule_name = 'no_auto_renewal_after'});
        $dbh->do(q{UPDATE circulation_rules SET rule_value = NULL WHERE rule_name = 'no_auto_renewal_after_hard_limit'});
        Koha::Cache::Memory::Lite->flush();
        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '15',
                    no_auto_renewal_after_hard_limit => undef,
                }
            }
        );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $latest_auto_renew_date->truncate( to => 'minute' ),
            $five_days_ahead->truncate( to => 'minute' ),
            'GetLatestAutoRenewDate should return +5 days if no_auto_renewal_after = 15 and date_due is 10 days before'
        );
        my $two_days_ahead = dt_from_string->add( days => 2 );
        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '',
                    no_auto_renewal_after_hard_limit => dt_from_string->add( days => 2 ),
                }
            }
        );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $latest_auto_renew_date->truncate( to => 'day' ),
            $two_days_ahead->truncate( to => 'day' ),
            'GetLatestAutoRenewDate should return +2 days if no_auto_renewal_after_hard_limit is defined and not no_auto_renewal_after'
        );
        Koha::CirculationRules->set_rules(
            {
                categorycode => undef,
                branchcode   => undef,
                itemtype     => undef,
                rules        => {
                    norenewalbefore       => '10',
                    no_auto_renewal_after => '15',
                    no_auto_renewal_after_hard_limit => dt_from_string->add( days => 2 ),
                }
            }
        );
        $latest_auto_renew_date = GetLatestAutoRenewDate( $renewing_borrowernumber, $item_to_auto_renew->itemnumber );
        is( $latest_auto_renew_date->truncate( to => 'day' ),
            $two_days_ahead->truncate( to => 'day' ),
            'GetLatestAutoRenewDate should return +2 days if no_auto_renewal_after_hard_limit is < no_auto_renewal_after'
        );

    };
    # Too many renewals

    # set policy to forbid renewals
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                norenewalbefore => undef,
                renewalsallowed => 0,
            }
        }
    );

    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 renewals allowed');
    is( $error, 'too_many', 'Cannot renew, 0 renewals allowed (returned code is too_many)');

    # Too many unseen renewals
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                unseen_renewals_allowed => 2,
                renewalsallowed => 10,
            }
        }
    );
    t::lib::Mocks::mock_preference('UnseenRenewals', 1);
    $dbh->do('UPDATE issues SET unseen_renewals = 2 where borrowernumber = ? AND itemnumber = ?', undef, ($renewing_borrowernumber, $item_1->itemnumber));
    ( $renewokay, $error ) = CanBookBeRenewed($renewing_borrowernumber, $item_1->itemnumber);
    is( $renewokay, 0, 'Cannot renew, 0 unseen renewals allowed');
    is( $error, 'too_unseen', 'Cannot renew, returned code is too_unseen');
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                norenewalbefore => undef,
                renewalsallowed => 0,
            }
        }
    );
    t::lib::Mocks::mock_preference('UnseenRenewals', 0);

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
    is( $line->debit_type_code, 'OVERDUE', 'Account line type is OVERDUE' );
    is( $line->status, 'UNRETURNED', 'Account line status is UNRETURNED' );
    is( $line->amountoutstanding+0, 15, 'Account line amount outstanding is 15.00' );
    is( $line->amount+0, 15, 'Account line amount is 15.00' );
    is( $line->issue_id, $issue->id, 'Account line issue id matches' );

    my $offset = Koha::Account::Offsets->search({ debit_id => $line->id })->next();
    is( $offset->type, 'CREATE', 'Account offset type is CREATE' );
    is( $offset->amount+0, 15, 'Account offset amount is 15.00' );

    t::lib::Mocks::mock_preference('WhenLostForgiveFine','0');
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','0');

    LostItem( $item_1->itemnumber, 'test', 1 );

    $line = Koha::Account::Lines->find($line->id);
    is( $line->debit_type_code, 'OVERDUE', 'Account type remains as OVERDUE' );
    isnt( $line->status, 'UNRETURNED', 'Account status correctly changed from UNRETURNED to RETURNED' );

    my $item = Koha::Items->find($item_1->itemnumber);
    ok( !$item->onloan(), "Lost item marked as returned has false onloan value" );
    my $checkout = Koha::Checkouts->find({ itemnumber => $item_1->itemnumber });
    is( $checkout, undef, 'LostItem called with forced return has checked in the item' );

    my $total_due = $dbh->selectrow_array(
        'SELECT SUM( amountoutstanding ) FROM accountlines WHERE borrowernumber = ?',
        undef, $renewing_borrower->{borrowernumber}
    );

    is( $total_due+0, 15, 'Borrower only charged replacement fee with both WhenLostForgiveFine and WhenLostChargeReplacementFee enabled' );

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

    my $manager = $builder->build_object({ class => "Koha::Patrons" });
    t::lib::Mocks::mock_userenv({ patron => $manager,branchcode => $manager->branchcode });
    t::lib::Mocks::mock_preference('WhenLostChargeReplacementFee','1');
    $checkout = Koha::Checkouts->find( { itemnumber => $item_3->itemnumber } );
    LostItem( $item_3->itemnumber, 'test', 0 );
    my $accountline = Koha::Account::Lines->find( { itemnumber => $item_3->itemnumber } );
    is( $accountline->issue_id, $checkout->id, "Issue id added for lost replacement fee charge" );
    is(
        $accountline->description,
        sprintf( "%s %s %s",
            $item_3->biblio->title  || '',
            $item_3->barcode        || '',
            $item_3->itemcallnumber || '' ),
        "Account line description must not contain 'Lost Items ', but be title, barcode, itemcallnumber"
    );

    # Recalls
    t::lib::Mocks::mock_preference('UseRecalls', 1);
    Koha::CirculationRules->set_rules({
        categorycode => undef,
        branchcode => undef,
        itemtype => undef,
        rules => {
            recalls_allowed => 10,
            renewalsallowed => 5,
        },
    });
    my $recall_borrower = $builder->build_object({ class => 'Koha::Patrons' });
    my $recall_biblio = $builder->build_object({ class => 'Koha::Biblios' });
    my $recall_item1 = $builder->build_object({ class => 'Koha::Items' }, { value => { biblionumber => $recall_biblio->biblionumber } });
    my $recall_item2 = $builder->build_object({ class => 'Koha::Items' }, { value => { biblionumber => $recall_biblio->biblionumber } });

    AddIssue( $renewing_borrower, $recall_item1->barcode );

    # item-level and this item: renewal not allowed
    my $recall = Koha::Recall->new({
        biblio_id => $recall_item1->biblionumber,
        item_id => $recall_item1->itemnumber,
        patron_id => $recall_borrower->borrowernumber,
        pickup_library_id => $recall_borrower->branchcode,
        item_level => 1,
    })->store;
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $recall_item1->itemnumber );
    is( $error, 'recalled', 'Cannot renew item that has been recalled' );
    $recall->set_cancelled;

    # biblio-level requested recall: renewal not allowed
    $recall = Koha::Recall->new({
        biblio_id => $recall_item1->biblionumber,
        item_id => undef,
        patron_id => $recall_borrower->borrowernumber,
        pickup_library_id => $recall_borrower->branchcode,
        item_level => 0,
    })->store;
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $recall_item1->itemnumber );
    is( $error, 'recalled', 'Cannot renew item if biblio is recalled and has no item allocated' );
    $recall->set_cancelled;

    # item-level and not this item: renewal allowed
    $recall = Koha::Recall->new({
        biblio_id => $recall_item2->biblionumber,
        item_id => $recall_item2->itemnumber,
        patron_id => $recall_borrower->borrowernumber,
        pickup_library_id => $recall_borrower->branchcode,
        item_level => 1,
    })->store;
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $recall_item1->itemnumber );
    is( $renewokay, 1, 'Can renew item if item-level recall on biblio is not on this item' );
    $recall->set_cancelled;

    # biblio-level waiting recall: renewal allowed
    $recall = Koha::Recall->new({
        biblio_id => $recall_item1->biblionumber,
        item_id => undef,
        patron_id => $recall_borrower->borrowernumber,
        pickup_library_id => $recall_borrower->branchcode,
        item_level => 0,
    })->store;
    $recall->set_waiting({ item => $recall_item1 });
    ( $renewokay, $error ) = CanBookBeRenewed( $renewing_borrowernumber, $recall_item1->itemnumber );
    is( $renewokay, 1, 'Can renew item if biblio-level recall has already been allocated an item' );
    $recall->set_cancelled;
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
    plan tests => 13;
    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
        }
    );
    my $item_2= $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
            itype            => $item_1->effective_itemtype,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 25,
                holds_per_record => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 1,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
                maxissueqty     => 20
            }
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
    my $patron_category_2 = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type                 => 'P',
                enrolmentfee                  => 0,
                BlockExpiredPatronOpacActions => -1, # Pick the pref value
            }
        }
    );
    my $borrowernumber3 = Koha::Patron->new({
        firstname    => 'Carnegie',
        surname      => 'Hall',
        categorycode => $patron_category_2->{categorycode},
        branchcode   => $library2->{branchcode},
    })->store->borrowernumber;

    my $borrower1 = Koha::Patrons->find( $borrowernumber1 )->unblessed;
    my $borrower2 = Koha::Patrons->find( $borrowernumber2 )->unblessed;

    my $issue = AddIssue( $borrower1, $item_1->barcode );

    my ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with no hold on the record' );

    AddReserve(
        {
            branchcode     => $library2->{branchcode},
            borrowernumber => $borrowernumber2,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                onshelfholds => 0,
            }
        }
    );
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfholds are disabled' );

    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled and onshelfholds is disabled' );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                onshelfholds => 1,
            }
        }
    );
    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 0 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower cannot renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is disabled and onshelfhold is enabled' );

    t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable', 1 );
    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 1, 'Bug 14337 - Verify the borrower can renew with a hold on the record if AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled' );

    AddReserve(
        {
            branchcode     => $library2->{branchcode},
            borrowernumber => $borrowernumber3,
            biblionumber   => $biblio->biblionumber,
            priority       => 1,
        }
    );

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Verify the borrower cannot renew with 2 holds on the record if AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled and one other item on record' );

    my $item_3= $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
            itype            => $item_1->effective_itemtype,
        }
    );

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 1, 'Verify the borrower cannot renew with 2 holds on the record if AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled and two other items on record' );

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron_category_2->{categorycode},
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 0,
            }
        }
    );

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Verify the borrower cannot renew with 2 holds on the record, but only one of those holds can be filled when AllowRenewalIfOtherItemsAvailable and onshelfhold are enabled and two other items on record' );

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron_category_2->{categorycode},
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 25,
            }
        }
    );

    # Setting item not checked out to be not for loan but holdable
    $item_2->notforloan(-1)->store;

    ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    is( $renewokay, 0, 'Bug 14337 - Verify the borrower can not renew with a hold on the record if AllowRenewalIfOtherItemsAvailable is enabled but the only available item is notforloan' );

    my $mock_circ = Test::MockModule->new("C4::Circulation");
    $mock_circ->mock( CanItemBeReserved => sub {
        warn "Checked";
        return { status => 'no' }
    } );

    $item_2->notforloan(0)->store;
    $item_3->delete();
    # Two items total, one item available, one issued, two holds on record

    warnings_are{
       ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    } [], "CanItemBeReserved not called when there are more possible holds than available items";
    is( $renewokay, 0, 'Borrower cannot renew when there are more holds than available items' );

    $item_3 = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library2->{branchcode},
            itype            => $item_1->effective_itemtype,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item_1->effective_itemtype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 0,
            }
        }
    );

    warnings_are{
       ( $renewokay, $error ) = CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
    } ["Checked","Checked"], "CanItemBeReserved only called once per available item if it returns a negative result for all items for a borrower";
    is( $renewokay, 0, 'Borrower cannot renew when there are more holds than available items' );

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

    my $item = $builder->build_sample_item(
        {
            homebranch    => $homebranch->{branchcode},
            holdingbranch => $holdingbranch->{branchcode},
        }
    );
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item->effective_itemtype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 1,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
                maxissueqty     => 20
            }
        }
    );

    set_userenv($holdingbranch);

    my $issue = AddIssue( $patron_1->unblessed, $item->barcode );
    is( ref($issue), 'Koha::Checkout', 'AddIssue should return a Koha::Checkout object' );

    my ( $error, $question, $alerts );

    # AllowReturnToBranch == anywhere
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    ## Test that unknown barcodes don't generate internal server errors
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, 'KohaIsAwesome' );
    ok( $error->{UNKNOWN_BARCODE}, '"KohaIsAwesome" is not a valid barcode as expected.' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Can be issued from another branch
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );

    # AllowReturnToBranch == holdingbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode}, 'branch_to_return matched holdingbranch' );
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $holdingbranch->{branchcode}, 'branch_to_return matches holdingbranch' );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from holdinbranch
    set_userenv($homebranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$error) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER must be set' );
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
    is( keys(%$question) + keys(%$alerts), 0, 'There should not be any errors or alerts (impossible)' . str($error, $question, $alerts) );
    is( exists $error->{RETURN_IMPOSSIBLE}, 1, 'RETURN_IMPOSSIBLE must be set' );
    is( $error->{branch_to_return},         $homebranch->{branchcode}, 'branch_to_return matches homebranch' );
    ## Cannot be issued from holdinbranch
    set_userenv($otherbranch);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron_2, $item->barcode );
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

    my $item = $builder->build_sample_item(
        {
            homebranch    => $homebranch->{branchcode},
            holdingbranch => $holdingbranch->{branchcode},
        }
    );

    set_userenv($holdingbranch);

    my $ref_issue = 'Koha::Checkout';
    my $issue = AddIssue( $patron_1, $item->barcode );

    my ( $error, $question, $alerts );

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from homebranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->barcode ); # Reinsert the original issue
    ## Can be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from holdingbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->barcode ); # Reinsert the original issue
    ## Can be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), $ref_issue, 'AllowReturnToBranch - anywhere | Can be issued from otherbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->barcode ); # Reinsert the original issue

    # AllowReturnToBranch == holdinbranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'holdingbranch' );
    ## Cannot be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), '', 'AllowReturnToBranch - holdingbranch | Cannot be issued from homebranch');
    ## Can be issued from holdingbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), $ref_issue, 'AllowReturnToBranch - holdingbranch | Can be issued from holdingbranch');
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->barcode ); # Reinsert the original issue
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), '', 'AllowReturnToBranch - holdingbranch | Cannot be issued from otherbranch');

    # AllowReturnToBranch == homebranch
    t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'homebranch' );
    ## Can be issued from homebranch
    set_userenv($homebranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), $ref_issue, 'AllowReturnToBranch - homebranch | Can be issued from homebranch' );
    set_userenv($holdingbranch); AddIssue( $patron_1, $item->barcode ); # Reinsert the original issue
    ## Cannot be issued from holdinbranch
    set_userenv($holdingbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), '', 'AllowReturnToBranch - homebranch | Cannot be issued from holdingbranch' );
    ## Cannot be issued from another branch
    set_userenv($otherbranch);
    is ( ref( AddIssue( $patron_2, $item->barcode ) ), '', 'AllowReturnToBranch - homebranch | Cannot be issued from otherbranch' );
    # TODO t::lib::Mocks::mock_preference('AllowReturnToBranch', 'homeorholdingbranch');
};

subtest 'AddIssue | recalls' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference("UseRecalls", 1);
    t::lib::Mocks::mock_preference("item-level_itypes", 1);
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $item = $builder->build_sample_item;
    Koha::CirculationRules->set_rules({
        branchcode => undef,
        itemtype => undef,
        categorycode => undef,
        rules => {
            recalls_allowed => 10,
        },
    });

    # checking out item that they have recalled
    my $recall1 = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => $item->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron1->branchcode,
        }
    )->store;
    AddIssue( $patron1->unblessed, $item->barcode, undef, undef, undef, undef, { recall_id => $recall1->id } );
    $recall1 = Koha::Recalls->find( $recall1->id );
    is( $recall1->fulfilled, 1, 'Recall was fulfilled when patron checked out item' );
    AddReturn( $item->barcode, $item->homebranch );

    # this item is has a recall request. cancel recall
    my $recall2 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => $item->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron2->branchcode,
        }
    )->store;
    AddIssue( $patron1->unblessed, $item->barcode, undef, undef, undef, undef, { recall_id => $recall2->id, cancel_recall => 'cancel' } );
    $recall2 = Koha::Recalls->find( $recall2->id );
    is( $recall2->cancelled, 1, 'Recall was cancelled when patron checked out item' );
    AddReturn( $item->barcode, $item->homebranch );

    # this item is waiting to fulfill a recall. revert recall
    my $recall3 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => $item->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron2->branchcode,
        }
    )->store;
    $recall3->set_waiting;
    AddIssue( $patron1->unblessed, $item->barcode, undef, undef, undef, undef, { recall_id => $recall3->id, cancel_recall => 'revert' } );
    $recall3 = Koha::Recalls->find( $recall3->id );
    is( $recall3->requested, 1, 'Recall was reverted from waiting when patron checked out item' );
    AddReturn( $item->barcode, $item->homebranch );
};

subtest 'AddIssue & illrequests.due_date' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'ILLModule', 1 );
    my $library = $builder->build( { source => 'Branch' } );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item = $builder->build_sample_item();

    set_userenv($library);

    my $custom_date_due = '9999-12-18 12:34:56';
    my $expected_date_due = '9999-12-18 23:59:00';
    my $illrequest = Koha::Illrequest->new({
        borrowernumber => $patron->borrowernumber,
        biblio_id => $item->biblionumber,
        branchcode => $library->{'branchcode'},
        due_date => $custom_date_due,
    })->store;

    my $issue = AddIssue( $patron->unblessed, $item->barcode );
    is( $issue->date_due, $expected_date_due, 'Custom illrequest date due has been set for this issue');

    $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $item = $builder->build_sample_item();
    $custom_date_due = '9999-12-19';
    $expected_date_due = '9999-12-19 23:59:00';
    $illrequest = Koha::Illrequest->new({
        borrowernumber => $patron->borrowernumber,
        biblio_id => $item->biblionumber,
        branchcode => $library->{'branchcode'},
        due_date => $custom_date_due,
    })->store;

    $issue = AddIssue( $patron->unblessed, $item->barcode );
    is( $issue->date_due, $expected_date_due, 'Custom illrequest date due has been set for this issue');
};

subtest 'CanBookBeIssued + Koha::Patron->is_debarred|has_overdues' => sub {
    plan tests => 8;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );
    my $item_1 = $builder->build_sample_item(
        {
            library => $library->{branchcode},
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            library => $library->{branchcode},
        }
    );
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => $library->{branchcode},
            rules        => {
                reservesallowed => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 1,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
                maxissueqty     => 20
            }
        }
    );

    my ( $error, $question, $alerts );

    # Patron cannot issue item_1, they have overdues
    my $yesterday = DateTime->today( time_zone => C4::Context->tz() )->add( days => -1 );
    my $issue = AddIssue( $patron->unblessed, $item_1->barcode, $yesterday );    # Add an overdue

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'confirmation' );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    is( keys(%$error) + keys(%$alerts),  0, 'No key for error and alert' . str($error, $question, $alerts) );
    is( $question->{USERBLOCKEDOVERDUE}, 1, 'OverduesBlockCirc=confirmation, USERBLOCKEDOVERDUE should be set for question' );

    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'block' );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDOVERDUE},      1, 'OverduesBlockCirc=block, USERBLOCKEDOVERDUE should be set for error' );

    # Patron cannot issue item_1, they are debarred
    my $tomorrow = DateTime->today( time_zone => C4::Context->tz() )->add( days => 1 );
    Koha::Patron::Debarments::AddDebarment( { borrowernumber => $patron->borrowernumber, expiration => $tomorrow } );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDWITHENDDATE}, output_pref( { dt => $tomorrow, dateformat => 'sql', dateonly => 1 } ), 'USERBLOCKEDWITHENDDATE should be tomorrow' );

    Koha::Patron::Debarments::AddDebarment( { borrowernumber => $patron->borrowernumber } );
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    is( keys(%$question) + keys(%$alerts),  0, 'No key for question and alert ' . str($error, $question, $alerts) );
    is( $error->{USERBLOCKEDNOENDDATE},    '9999-12-31', 'USERBLOCKEDNOENDDATE should be 9999-12-31 for unlimited debarments' );
};

subtest 'CanBookBeIssued + Statistic patrons "X"' => sub {
    plan tests => 9;

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
    my $item_1 = $builder->build_sample_item(
        {
            library => $library->{branchcode},
        }
    );

    my ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_1->barcode );
    is( $error->{STATS}, 1, '"Error" flag "STATS" must be set if CanBookBeIssued is called with a statistic patron (category_type=X)' );

    my $stat = Koha::Statistics->search( { itemnumber => $item_1->itemnumber } )->next;
    is( $stat->branch,         C4::Context->userenv->{'branch'}, 'Recorded a branch' );
    is( $stat->type,           'localuse',                       'Recorded type as localuse' );
    is( $stat->itemnumber,     $item_1->itemnumber,              'Recorded an itemnumber' );
    is( $stat->itemtype,       $item_1->effective_itemtype,      'Recorded an itemtype' );
    is( $stat->borrowernumber, $patron->borrowernumber,          'Recorded a borrower number' );
    is( $stat->ccode,          $item_1->ccode,                   'Recorded a collection code' );
    is( $stat->categorycode,   $patron->categorycode,            'Recorded a categorycode' );
    is( $stat->location,       $item_1->location,                'Recorded a location' );

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
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber1,
            biblionumber     => $biblio->biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            itemnumber       => $checkitem,
            found            => $found,
        }
    );

    my %reserving_borrower_data2 = (
        firstname =>  'Kirk',
        surname => 'Reservation',
        categorycode => $patron_category->{categorycode},
        branchcode => $branch,
    );
    my $reserving_borrowernumber2 = Koha::Patron->new(\%reserving_borrower_data2)->store->borrowernumber;
    AddReserve(
        {
            branchcode       => $branch,
            borrowernumber   => $reserving_borrowernumber2,
            biblionumber     => $biblio->biblionumber,
            priority         => $priority,
            reservation_date => $resdate,
            expiration_date  => $expdate,
            notes            => $notes,
            itemnumber       => $checkitem,
            found            => $found,
        }
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

    my $biblionumber = $builder->build_sample_biblio(
        {
            branchcode => $library->{branchcode},
        }
    )->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->{branchcode},
        }
    );

    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->{branchcode},
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => $library->{branchcode},
            rules        => {
                reservesallowed => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 1,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
                maxissueqty     => 20
            }
        }
    );

    my ( $error, $question, $alerts );
    my $issue = AddIssue( $patron->unblessed, $item_1->barcode, dt_from_string->add( days => 1 ) );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 0);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    cmp_deeply(
        { error => $error, alerts => $alerts },
        { error => {}, alerts => {} },
        'No error or alert should be raised'
    );
    is( $question->{BIBLIO_ALREADY_ISSUED}, 1, 'BIBLIO_ALREADY_ISSUED question flag should be set if AllowMultipleIssuesOnABiblio=0 and issue already exists' );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 1);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    cmp_deeply(
        { error => $error, question => $question, alerts => $alerts },
        { error => {}, question => {}, alerts => {} },
        'No BIBLIO_ALREADY_ISSUED flag should be set if AllowMultipleIssuesOnABiblio=1'
    );

    # Add a subscription
    Koha::Subscription->new({ biblionumber => $biblionumber })->store;

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 0);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    cmp_deeply(
        { error => $error, question => $question, alerts => $alerts },
        { error => {}, question => {}, alerts => {} },
        'No BIBLIO_ALREADY_ISSUED flag should be set if it is a subscription'
    );

    t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 1);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron, $item_2->barcode );
    cmp_deeply(
        { error => $error, question => $question, alerts => $alerts },
        { error => {}, question => {}, alerts => {} },
        'No BIBLIO_ALREADY_ISSUED flag should be set if it is a subscription'
    );
};

subtest 'AddReturn + CumulativeRestrictionPeriods' => sub {
    plan tests => 8;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    # Add 2 items
    my $biblionumber = $builder->build_sample_biblio(
        {
            branchcode => $library->{branchcode},
        }
    )->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->{branchcode},
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->{branchcode},
        }
    );

    # And the circulation rule
    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                issuelength => 1,
                firstremind => 1,        # 1 day of grace
                finedays    => 2,        # 2 days of fine per day of overdue
                lengthunit  => 'days',
            }
        }
    );

    # Patron cannot issue item_1, they have overdues
    my $now = dt_from_string;
    my $five_days_ago = $now->clone->subtract( days => 5 );
    my $ten_days_ago  = $now->clone->subtract( days => 10 );
    AddIssue( $patron->unblessed, $item_1->barcode, $five_days_ago );    # Add an overdue
    AddIssue( $patron->unblessed, $item_2->barcode, $ten_days_ago )
      ;    # Add another overdue

    t::lib::Mocks::mock_preference( 'CumulativeRestrictionPeriods', '0' );
    AddReturn( $item_1->barcode, $library->{branchcode}, undef, $now );
    my $suspensions = $patron->restrictions->search( { type => 'SUSPENSION' } );
    is( $suspensions->count, 1, "Suspension added" );
    my $THE_suspension = $suspensions->next;

    # FIXME Is it right? I'd have expected 5 * 2 - 1 instead
    # Same for the others
    my $expected_expiration = output_pref(
        {
            dt         => $now->clone->add( days => ( 5 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $THE_suspension->expiration, $expected_expiration, "Suspesion expiration set" );

    AddReturn( $item_2->barcode, $library->{branchcode}, undef, $now );
    $suspensions = $patron->restrictions->search( { type => 'SUSPENSION' } );
    is( $suspensions->count, 1, "Only one suspension" );
    $THE_suspension = $suspensions->next;

    $expected_expiration = output_pref(
        {
            dt         => $now->clone->add( days => ( 10 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $THE_suspension->expiration, $expected_expiration, "Suspension expiration date updated" );

    Koha::Patron::Debarments::DelUniqueDebarment(
        { borrowernumber => $patron->borrowernumber, type => 'SUSPENSION' } );

    t::lib::Mocks::mock_preference( 'CumulativeRestrictionPeriods', '1' );
    AddIssue( $patron->unblessed, $item_1->barcode, $five_days_ago );    # Add an overdue
    AddIssue( $patron->unblessed, $item_2->barcode, $ten_days_ago )
      ;    # Add another overdue
    AddReturn( $item_1->barcode, $library->{branchcode}, undef, $now );
    $suspensions = $patron->restrictions->search( { type => 'SUSPENSION' } );
    is( $suspensions->count, 1, "Only one suspension" );
    $THE_suspension = $suspensions->next;

    $expected_expiration = output_pref(
        {
            dt         => $now->clone->add( days => ( 5 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $THE_suspension->expiration, $expected_expiration, "Suspension expiration date updated" );

    AddReturn( $item_2->barcode, $library->{branchcode}, undef, $now );
    $suspensions = $patron->restrictions->search( { type => 'SUSPENSION' } );
    is( $suspensions->count, 1, "Only one suspension" );
    $THE_suspension = $suspensions->next;

    $expected_expiration = output_pref(
        {
            dt => $now->clone->add( days => ( 5 - 1 ) * 2 + ( 10 - 1 ) * 2 ),
            dateformat => 'sql',
            dateonly   => 1
        }
    );
    is( $THE_suspension->expiration, $expected_expiration, "Suspension expiration date updated" );
};

subtest 'AddReturn + suspension_chargeperiod' => sub {
    plan tests => 29;

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $biblionumber = $builder->build_sample_biblio(
        {
            branchcode => $library->{branchcode},
        }
    )->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $library->{branchcode},
        }
    );

    # And the issuing rule
    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            rules        => {
                issuelength => 1,
                firstremind => 0,    # 0 day of grace
                finedays    => 2,    # 2 days of fine per day of overdue
                suspension_chargeperiod => 1,
                lengthunit              => 'days',
            }
        }
    );

    my $now = dt_from_string;
    my $five_days_ago = $now->clone->subtract( days => 5 );
    # We want to charge 2 days every day, without grace
    # With 5 days of overdue: 5 * Z
    my $expected_expiration = $now->clone->add( days => ( 5 * 2 ) / 1 );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );

    # Same with undef firstremind
    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => '*',
            rules        => {
                issuelength => 1,
                firstremind => undef,    # 0 day of grace
                finedays    => 2,    # 2 days of fine per day of overdue
                suspension_chargeperiod => 1,
                lengthunit              => 'days',
            }
        }
    );
    {
    my $now = dt_from_string;
    my $five_days_ago = $now->clone->subtract( days => 5 );
    # We want to charge 2 days every day, without grace
    # With 5 days of overdue: 5 * Z
    my $expected_expiration = $now->clone->add( days => ( 5 * 2 ) / 1 );
    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $five_days_ago,
            expiration_date => $expected_expiration,
        }
    );
    }
    # We want to charge 2 days every 2 days, without grace
    # With 5 days of overdue: (5 * 2) / 2
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'suspension_chargeperiod',
            rule_value   => '2',
        }
    );

    $expected_expiration = $now->clone->add( days => floor( 5 * 2 ) / 2 );
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
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                suspension_chargeperiod => 3,
                firstremind             => 1,
            }
        }
    );
    $expected_expiration = $now->clone->add( days => floor( ( ( 5 - 1 ) / 3 ) * 2 ) );
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
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                finedays                => 2,
                suspension_chargeperiod => 1,
                firstremind             => 0,
            }
        }
    );
    t::lib::Mocks::mock_preference('finesCalendar', 'noFinesWhenClosed');
    t::lib::Mocks::mock_preference('SuspensionsCalendar', 'noSuspensionsWhenClosed');

    # Adding a holiday 2 days ago
    my $calendar = C4::Calendar->new(branchcode => $library->{branchcode});
    my $two_days_ago = $now->clone->subtract( days => 2 );
    $calendar->insert_single_holiday(
        day             => $two_days_ago->day,
        month           => $two_days_ago->month,
        year            => $two_days_ago->year,
        title           => 'holidayTest-2d',
        description     => 'holidayDesc 2 days ago'
    );
    # With 5 days of overdue, only 4 (x finedays=2) days must charged (one was an holiday)
    $expected_expiration = $now->clone->add( days => floor( ( ( 5 - 0 - 1 ) / 1 ) * 2 ) );
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
    my $two_days_ahead = $now->clone->add( days => 2 );
    $calendar->insert_single_holiday(
        day             => $two_days_ahead->day,
        month           => $two_days_ahead->month,
        year            => $two_days_ahead->year,
        title           => 'holidayTest+2d',
        description     => 'holidayDesc 2 days ahead'
    );

    # Same as above, but we should skip D+2
    $expected_expiration = $now->clone->add( days => floor( ( ( 5 - 0 - 1 ) / 1 ) * 2 ) + 1 );
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
            return_date     => $now->clone->add(days => 5),
            expiration_date => $now->clone->add(days => 5 + (5 * 2 - 1) ),
        }
    );

    test_debarment_on_checkout(
        {
            item            => $item_1,
            library         => $library,
            patron          => $patron,
            due_date        => $now->clone->add(days => 1),
            return_date     => $now->clone->add(days => 5),
            expiration_date => $now->clone->add(days => 5 + (4 * 2 - 1) ),
        }
    );

    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules => {
                finedays   => 0,
                lengthunit => 'days',
              }
        }
    );

    Koha::Patron::Debarments::AddDebarment(
        {
            borrowernumber => $patron->borrowernumber,
            expiration     => '9999-12-31',
            type           => 'MANUAL',
        }
    );

    AddIssue( $patron->unblessed, $item_1->barcode, $now->clone->subtract( days => 1 ) );
    my ( undef, $message ) = AddReturn( $item_1->barcode, $library->{branchcode}, undef, $now );
    is( $message->{WasReturned} && exists $message->{ForeverDebarred}, 1, 'Forever debarred message for Addreturn when overdue');

    Koha::Patron::Debarments::DelUniqueDebarment(
        {
            borrowernumber => $patron->borrowernumber,
            type           => 'MANUAL',
        }
    );
    Koha::Patron::Debarments::AddDebarment(
        {
            borrowernumber => $patron->borrowernumber,
            expiration     => $now->clone->add( days => 10 ),
            type           => 'MANUAL',
        }
    );

    AddIssue( $patron->unblessed, $item_1->barcode, $now->clone->subtract( days => 1 ) );
    (undef, $message) = AddReturn( $item_1->barcode, $library->{branchcode}, undef, $now );
    is( $message->{WasReturned} && exists $message->{PrevDebarred}, 1, 'Previously debarred message for Addreturn when overdue');
};

subtest 'CanBookBeIssued + AutoReturnCheckedOutItems' => sub {
    plan tests => 2;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_category->{categorycode}
            }
        }
    );
    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_category->{categorycode}
            }
        }
    );

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });

    my $item = $builder->build_sample_item(
        {
            library      => $library->branchcode,
        }
    );

    my ( $error, $question, $alerts );
    my $issue = AddIssue( $patron1->unblessed, $item->barcode );

    t::lib::Mocks::mock_preference('AutoReturnCheckedOutItems', 0);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron2, $item->barcode );
    is( $question->{ISSUED_TO_ANOTHER}, 1, 'ISSUED_TO_ANOTHER question flag should be set if AutoReturnCheckedOutItems is disabled and item is checked out to another' );

    t::lib::Mocks::mock_preference('AutoReturnCheckedOutItems', 1);
    ( $error, $question, $alerts ) = CanBookBeIssued( $patron2, $item->barcode );
    is( $alerts->{RETURNED_FROM_ANOTHER}->{patron}->borrowernumber, $patron1->borrowernumber, 'RETURNED_FROM_ANOTHER alert flag should be set if AutoReturnCheckedOutItems is enabled and item is checked out to another' );

    t::lib::Mocks::mock_preference('AutoReturnCheckedOutItems', 0);
};


subtest 'AddReturn | is_overdue' => sub {
    plan tests => 9;

    t::lib::Mocks::mock_preference('MarkLostItemsAsReturned', 'batchmod|moredetail|cronjob|additem|pendingreserves|onpayment');
    t::lib::Mocks::mock_preference('CalculateFinesOnReturn', 1);
    t::lib::Mocks::mock_preference('finesMode', 'production');
    t::lib::Mocks::mock_preference('MaxFine', '100');

    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $manager->branchcode });

    my $item = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            replacementprice => 7
        }
    );

    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                issuelength  => 6,
                lengthunit   => 'days',
                fine         => 1,        # Charge 1 every day of overdue
                chargeperiod => 1,
            }
        }
    );

    my $now   = dt_from_string;
    my $one_day_ago   = $now->clone->subtract( days => 1 );
    my $two_days_ago  = $now->clone->subtract( days => 2 );
    my $five_days_ago = $now->clone->subtract( days => 5 );
    my $ten_days_ago  = $now->clone->subtract( days => 10 );

    # No return date specified, today will be used => 10 days overdue charged
    AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->barcode, $library->{branchcode} );
    is( int($patron->account->balance()), 10, 'Patron should have a charge of 10 (10 days x 1)' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify return date 5 days before => no overdue charged
    AddIssue( $patron->unblessed, $item->barcode, $five_days_ago ); # date due was 5d ago
    AddReturn( $item->barcode, $library->{branchcode}, undef, $ten_days_ago );
    is( int($patron->account->balance()), 0, 'AddReturn: pass return_date => no overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify return date 5 days later => 5 days overdue charged
    AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->barcode, $library->{branchcode}, undef, $five_days_ago );
    is( int($patron->account->balance()), 5, 'AddReturn: pass return_date => overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    # specify return date 5 days later, specify exemptfine => no overdue charge
    AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago ); # date due was 10d ago
    AddReturn( $item->barcode, $library->{branchcode}, 1, $five_days_ago );
    is( int($patron->account->balance()), 0, 'AddReturn: pass return_date => no overdue' );
    Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;

    subtest 'bug 22877 | Lost item return' => sub {

        plan tests => 3;

        my $issue = AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago );    # date due was 10d ago

        # Fake fines cronjob on this checkout
        my ($fine) =
          CalcFine( $item, $patron->categorycode, $library->{branchcode},
            $ten_days_ago, $now );
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => $fine,
                due            => output_pref($ten_days_ago)
            }
        );
        is( int( $patron->account->balance() ),
            10, "Overdue fine of 10 days overdue" );

        # Fake longoverdue with charge and not marking returned
        LostItem( $item->itemnumber, 'cronjob', 0 );
        is( int( $patron->account->balance() ),
            17, "Lost fine of 7 plus 10 days overdue" );

        # Now we return it today
        AddReturn( $item->barcode, $library->{branchcode} );
        is( int( $patron->account->balance() ),
            17, "Should have a single 10 days overdue fine and lost charge" );

        # Cleanup
        Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;
    };

    subtest 'bug 8338 | backdated return resulting in zero amount fine' => sub {

        plan tests => 17;

        t::lib::Mocks::mock_preference('CalculateFinesOnBackdate', 1);

        my $issue = AddIssue( $patron->unblessed, $item->barcode, $one_day_ago );    # date due was 1d ago

        # Fake fines cronjob on this checkout
        my ($fine) =
          CalcFine( $item, $patron->categorycode, $library->{branchcode},
            $one_day_ago, $now );
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => $fine,
                due            => output_pref($one_day_ago)
            }
        );
        is( int( $patron->account->balance() ),
            1, "Overdue fine of 1 day overdue" );

        # Backdated return (dropbox mode example - charge should be removed)
        AddReturn( $item->barcode, $library->{branchcode}, 1, $one_day_ago );
        is( int( $patron->account->balance() ),
            0, "Overdue fine should be annulled" );
        my $lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber });
        is( $lines->count, 0, "Overdue fine accountline has been removed");

        $issue = AddIssue( $patron->unblessed, $item->barcode, $two_days_ago );    # date due was 2d ago

        # Fake fines cronjob on this checkout
        ($fine) =
          CalcFine( $item, $patron->categorycode, $library->{branchcode},
            $two_days_ago, $now );
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => $fine,
                due            => output_pref($one_day_ago)
            }
        );
        is( int( $patron->account->balance() ),
            2, "Overdue fine of 2 days overdue" );

        # Payment made against fine
        $lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber });
        my $debit = $lines->next;
        my $credit = $patron->account->add_credit(
            {
                amount    => 2,
                type      => 'PAYMENT',
                interface => 'test',
            }
        );
        $credit->apply( { debits => [$debit] } );

        is( int( $patron->account->balance() ),
            0, "Overdue fine should be paid off" );
        $lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber });
        is ( $lines->count, 2, "Overdue (debit) and Payment (credit) present");
        my $line = $lines->next;
        is( $line->amount+0, 2, "Overdue fine amount remains as 2 days");
        is( $line->amountoutstanding+0, 0, "Overdue fine amountoutstanding reduced to 0");

        # Backdated return (dropbox mode example - charge should be removed)
        AddReturn( $item->barcode, $library->{branchcode}, undef, $one_day_ago );
        is( int( $patron->account->balance() ),
            -1, "Refund credit has been applied" );
        $lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber }, { order_by => { '-asc' => 'accountlines_id' }});
        is( $lines->count, 3, "Overdue (debit), Payment (credit) and Refund (credit) are all present");

        $line = $lines->next;
        is($line->amount+0,1, "Overdue fine amount has been reduced to 1");
        is($line->amountoutstanding+0,0, "Overdue fine amount outstanding remains at 0");
        is($line->status,'RETURNED', "Overdue fine is fixed");
        $line = $lines->next;
        is($line->amount+0,-2, "Original payment amount remains as 2");
        is($line->amountoutstanding+0,0, "Original payment remains applied");
        $line = $lines->next;
        is($line->amount+0,-1, "Refund amount correctly set to 1");
        is($line->amountoutstanding+0,-1, "Refund amount outstanding unspent");

        # Cleanup
        Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;
    };

    subtest 'bug 25417 | backdated return + exemptfine' => sub {

        plan tests => 2;

        t::lib::Mocks::mock_preference('CalculateFinesOnBackdate', 1);

        my $issue = AddIssue( $patron->unblessed, $item->barcode, $one_day_ago );    # date due was 1d ago

        # Fake fines cronjob on this checkout
        my ($fine) =
          CalcFine( $item, $patron->categorycode, $library->{branchcode},
            $one_day_ago, $now );
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => $fine,
                due            => output_pref($one_day_ago)
            }
        );
        is( int( $patron->account->balance() ),
            1, "Overdue fine of 1 day overdue" );

        # Backdated return (dropbox mode example - charge should no longer exist)
        AddReturn( $item->barcode, $library->{branchcode}, 1, $one_day_ago );
        is( int( $patron->account->balance() ),
            0, "Overdue fine should be annulled" );

        # Cleanup
        Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber })->delete;
    };

    subtest 'bug 24075 | backdated return with return datetime matching due datetime' => sub {
        plan tests => 7;

        t::lib::Mocks::mock_preference( 'CalculateFinesOnBackdate', 1 );

        my $due_date = dt_from_string;
        my $issue = AddIssue( $patron->unblessed, $item->barcode, $due_date );

        # Add fine
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => 0.25,
                due            => output_pref($due_date)
            }
        );
        is( $patron->account->balance(),
            0.25, 'Overdue fine of $0.25 recorded' );

        # Backdate return to exact due date and time
        my ( undef, $message ) =
          AddReturn( $item->barcode, $library->{branchcode},
            undef, $due_date );

        my $accountline =
          Koha::Account::Lines->find( { issue_id => $issue->id } );
        ok( !$accountline, 'accountline removed as expected' );

        # Re-issue
        $issue = AddIssue( $patron->unblessed, $item->barcode, $due_date );

        # Add fine
        UpdateFine(
            {
                issue_id       => $issue->issue_id,
                itemnumber     => $item->itemnumber,
                borrowernumber => $patron->borrowernumber,
                amount         => .25,
                due            => output_pref($due_date)
            }
        );
        is( $patron->account->balance(),
            0.25, 'Overdue fine of $0.25 recorded' );

        # Partial pay accruing fine
        my $lines = Koha::Account::Lines->search(
            {
                borrowernumber => $patron->borrowernumber,
                issue_id       => $issue->id
            }
        );
        my $debit  = $lines->next;
        my $credit = $patron->account->add_credit(
            {
                amount    => .20,
                type      => 'PAYMENT',
                interface => 'test',
            }
        );
        $credit->apply( { debits => [$debit] } );

        is( $patron->account->balance(), .05, 'Overdue fine reduced to $0.05' );

        # Backdate return to exact due date and time
        ( undef, $message ) =
          AddReturn( $item->barcode, $library->{branchcode},
            undef, $due_date );

        $lines = Koha::Account::Lines->search(
            {
                borrowernumber => $patron->borrowernumber,
                issue_id       => $issue->id
            }
        );
        $accountline = $lines->next;
        is( $accountline->amountoutstanding + 0,
            0, 'Partially paid fee amount outstanding was reduced to 0' );
        is( $accountline->amount + 0,
            0, 'Partially paid fee amount was reduced to 0' );
        is( $patron->account->balance(), -0.20, 'Patron refund recorded' );

        # Cleanup
        Koha::Account::Lines->search(
            { borrowernumber => $patron->borrowernumber } )->delete;
    };

    subtest 'enh 23091 | Lost item return policies' => sub {
        plan tests => 5;

        my $manager = $builder->build_object({ class => "Koha::Patrons" });

        my $branchcode_false =
          $builder->build( { source => 'Branch' } )->{branchcode};
        my $specific_rule_false = $builder->build(
            {
                source => 'CirculationRule',
                value  => {
                    branchcode   => $branchcode_false,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'lostreturn',
                    rule_value   => 0
                }
            }
        );
        my $branchcode_refund =
          $builder->build( { source => 'Branch' } )->{branchcode};
        my $specific_rule_refund = $builder->build(
            {
                source => 'CirculationRule',
                value  => {
                    branchcode   => $branchcode_refund,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'lostreturn',
                    rule_value   => 'refund'
                }
            }
        );
        my $branchcode_restore =
          $builder->build( { source => 'Branch' } )->{branchcode};
        my $specific_rule_restore = $builder->build(
            {
                source => 'CirculationRule',
                value  => {
                    branchcode   => $branchcode_restore,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'lostreturn',
                    rule_value   => 'restore'
                }
            }
        );
        my $branchcode_charge =
          $builder->build( { source => 'Branch' } )->{branchcode};
        my $specific_rule_charge = $builder->build(
            {
                source => 'CirculationRule',
                value  => {
                    branchcode   => $branchcode_charge,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'lostreturn',
                    rule_value   => 'charge'
                }
            }
        );

        my $branchcode_refund_unpaid =
        $builder->build( { source => 'Branch' } )->{branchcode};
        my $specific_rule_refund_unpaid = $builder->build(
            {
                source => 'CirculationRule',
                value  => {
                    branchcode   => $branchcode_refund_unpaid,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'lostreturn',
                    rule_value   => 'refund_unpaid'
                }
            }
        );

        my $replacement_amount = 99.00;
        t::lib::Mocks::mock_preference( 'AllowReturnToBranch', 'anywhere' );
        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee', 1 );
        t::lib::Mocks::mock_preference( 'WhenLostForgiveFine',          0 );
        t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems',       0 );
        t::lib::Mocks::mock_preference( 'RefundLostOnReturnControl',
            'CheckinLibrary' );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge',
            undef );

        subtest 'lostreturn | refund_unpaid' => sub {
            plan tests => 21;

            t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $branchcode_refund_unpaid });

            my $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Mark item as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( int($lost_fee_line->amount),
                $replacement_amount, 'The right LOST amount is generated' );
            is( int($lost_fee_line->amountoutstanding),
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            is(
                int($patron->account->balance),
                $replacement_amount ,
                "Account balance equals the replacement amount after being charged lost fee when no payments has been made"
            );

            # Return lost item without any payments having been made
            my ( $returned, $message ) = AddReturn( $item->barcode, $branchcode_refund_unpaid );

            $lost_fee_line->discard_changes;

            is( int($lost_fee_line->amount), $replacement_amount, 'The LOST amount is left intact' );
            is( int($lost_fee_line->amountoutstanding) , 0, 'The LOST amountoutstanding is zero' );
            is( $lost_fee_line->status, 'FOUND', 'The FOUND status was set' );
            is(
                int($patron->account->balance),
                0,
                'Account balance should be zero after returning item with lost fee when no payments has been made'
            );

            # Create a second item
            $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Mark item as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            $lost_fee_line = $lost_fee_lines->next;

            # Make partial payment
            $patron->account->payin_amount({
                type => 'PAYMENT',
                interface => 'intranet',
                payment_type => 'CASH',
                user_id => $patron->borrowernumber,
                amount => 39.00,
                debits => [$lost_fee_line]
            });

            $lost_fee_line->discard_changes;

            is( int($lost_fee_line->amountoutstanding),
                60,
                'The LOST amountoutstanding is the expected amount after partial payment of lost fee'
            );

            is(
                int($patron->account->balance),
                60,
                'Account balance is the expected amount after partial payment of lost fee'
            );

             # Return lost item with partial payment having been made
            ( $returned, $message ) = AddReturn( $item->barcode, $branchcode_refund_unpaid );

            $lost_fee_line->discard_changes;

            is( int($lost_fee_line->amountoutstanding) , 0, 'The LOST amountoutstanding is zero after returning lost item with partial payment' );
            is( $lost_fee_line->status, 'FOUND', 'The FOUND status was set for lost item with partial payment' );
            is(
                int($patron->account->balance),
                0,
                'Account balance should be zero after returning item with lost fee when partial payment has been made'
            );

            # Create a third item
            $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

            # Mark item as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            $lost_fee_line = $lost_fee_lines->next;

            # Make full payment
            $patron->account->payin_amount({
                type => 'PAYMENT',
                interface => 'intranet',
                payment_type => 'CASH',
                user_id => $patron->borrowernumber,
                amount => $replacement_amount,
                debits => [$lost_fee_line]
            });

            $lost_fee_line->discard_changes;

            is( int($lost_fee_line->amountoutstanding),
                0,
                'The LOST amountoutstanding is the expected amount after partial payment of lost fee'
            );

            is(
                int($patron->account->balance),
                0,
                'Account balance is the expected amount after partial payment of lost fee'
            );

             # Return lost item with partial payment having been made
            ( $returned, $message ) = AddReturn( $item->barcode, $branchcode_refund_unpaid );

            $lost_fee_line->discard_changes;

            is( int($lost_fee_line->amountoutstanding) , 0, 'The LOST amountoutstanding is zero after returning lost item with full payment' );
            is( $lost_fee_line->status, 'FOUND', 'The FOUND status was set for lost item with partial payment' );
            is(
                int($patron->account->balance),
                0,
                'Account balance should be zero after returning item with lost fee when full payment has been made'
            );
        };

        subtest 'lostreturn | false' => sub {
            plan tests => 12;

            t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $branchcode_false });

            my $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago );

            # Fake fines cronjob on this checkout
            my ($fine) =
              CalcFine( $item, $patron->categorycode, $library->{branchcode},
                $ten_days_ago, $now );
            UpdateFine(
                {
                    issue_id       => $issue->issue_id,
                    itemnumber     => $item->itemnumber,
                    borrowernumber => $patron->borrowernumber,
                    amount         => $fine,
                    due            => output_pref($ten_days_ago)
                }
            );
            my $overdue_fees = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'OVERDUE'
                }
            );
            is( $overdue_fees->count, 1, 'Overdue item fee produced' );
            my $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                10, 'The right OVERDUE amount is generated' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The right OVERDUE amountoutstanding is generated' );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            # Return lost item
            my ( $returned, $message ) =
              AddReturn( $item->barcode, $branchcode_false, undef, $five_days_ago );

            $overdue_fee->discard_changes;
            is( $overdue_fee->amount + 0,
                10, 'The OVERDUE amount is left intact' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The OVERDUE amountoutstanding is left intact' );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The LOST amount is left intact' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The LOST amountoutstanding is left intact' );
            # FIXME: Should we set the LOST fee status to 'FOUND' regardless of whether we're refunding or not?
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );
        };

        subtest 'lostreturn | refund' => sub {
            plan tests => 12;

            t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $branchcode_refund });

            my $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago );

            # Fake fines cronjob on this checkout
            my ($fine) =
              CalcFine( $item, $patron->categorycode, $library->{branchcode},
                $ten_days_ago, $now );
            UpdateFine(
                {
                    issue_id       => $issue->issue_id,
                    itemnumber     => $item->itemnumber,
                    borrowernumber => $patron->borrowernumber,
                    amount         => $fine,
                    due            => output_pref($ten_days_ago)
                }
            );
            my $overdue_fees = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'OVERDUE'
                }
            );
            is( $overdue_fees->count, 1, 'Overdue item fee produced' );
            my $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                10, 'The right OVERDUE amount is generated' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The right OVERDUE amountoutstanding is generated' );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            # Return the lost item
            my ( undef, $message ) =
              AddReturn( $item->barcode, $branchcode_refund, undef, $five_days_ago );

            $overdue_fee->discard_changes;
            is( $overdue_fee->amount + 0,
                10, 'The OVERDUE amount is left intact' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The OVERDUE amountoutstanding is left intact' );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The LOST amount is left intact' );
            is( $lost_fee_line->amountoutstanding + 0,
                0,
                'The LOST amountoutstanding is refunded' );
            is( $lost_fee_line->status, 'FOUND', 'The LOST status was set to FOUND' );
        };

        subtest 'lostreturn | restore' => sub {
            plan tests => 13;

            t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $branchcode_restore });

            my $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode , $ten_days_ago);

            # Fake fines cronjob on this checkout
            my ($fine) =
              CalcFine( $item, $patron->categorycode, $library->{branchcode},
                $ten_days_ago, $now );
            UpdateFine(
                {
                    issue_id       => $issue->issue_id,
                    itemnumber     => $item->itemnumber,
                    borrowernumber => $patron->borrowernumber,
                    amount         => $fine,
                    due            => output_pref($ten_days_ago)
                }
            );
            my $overdue_fees = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'OVERDUE'
                }
            );
            is( $overdue_fees->count, 1, 'Overdue item fee produced' );
            my $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                10, 'The right OVERDUE amount is generated' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The right OVERDUE amountoutstanding is generated' );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            # Simulate refunding overdue fees upon marking item as lost
            my $overdue_forgive = $patron->account->add_credit(
                {
                    amount     => 10.00,
                    user_id    => $manager->borrowernumber,
                    library_id => $branchcode_restore,
                    interface  => 'test',
                    type       => 'FORGIVEN',
                    item_id    => $item->itemnumber
                }
            );
            $overdue_forgive->apply( { debits => [$overdue_fee] } );
            $overdue_fee->discard_changes;
            is($overdue_fee->amountoutstanding + 0, 0, 'Overdue fee forgiven');

            # Do nothing
            my ( undef, $message ) =
              AddReturn( $item->barcode, $branchcode_restore, undef, $five_days_ago );

            $overdue_fee->discard_changes;
            is( $overdue_fee->amount + 0,
                10, 'The OVERDUE amount is left intact' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The OVERDUE amountoutstanding is restored' );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The LOST amount is left intact' );
            is( $lost_fee_line->amountoutstanding + 0,
                0,
                'The LOST amountoutstanding is refunded' );
            is( $lost_fee_line->status, 'FOUND', 'The LOST status was set to FOUND' );
        };

        subtest 'lostreturn | charge' => sub {
            plan tests => 16;

            t::lib::Mocks::mock_userenv({ patron => $manager, branchcode => $branchcode_charge });

            my $item = $builder->build_sample_item(
                {
                    replacementprice => $replacement_amount
                }
            );

            # Issue the item
            my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode, $ten_days_ago );

            # Fake fines cronjob on this checkout
            my ($fine) =
              CalcFine( $item, $patron->categorycode, $library->{branchcode},
                $ten_days_ago, $now );
            UpdateFine(
                {
                    issue_id       => $issue->issue_id,
                    itemnumber     => $item->itemnumber,
                    borrowernumber => $patron->borrowernumber,
                    amount         => $fine,
                    due            => output_pref($ten_days_ago)
                }
            );
            my $overdue_fees = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'OVERDUE'
                }
            );
            is( $overdue_fees->count, 1, 'Overdue item fee produced' );
            my $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                10, 'The right OVERDUE amount is generated' );
            is( $overdue_fee->amountoutstanding + 0,
                10,
                'The right OVERDUE amountoutstanding is generated' );

            # Simulate item marked as lost
            $item->itemlost(3)->store;
            C4::Circulation::LostItem( $item->itemnumber, 1 );

            my $lost_fee_lines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'LOST'
                }
            );
            is( $lost_fee_lines->count, 1, 'Lost item fee produced' );
            my $lost_fee_line = $lost_fee_lines->next;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The right LOST amount is generated' );
            is( $lost_fee_line->amountoutstanding + 0,
                $replacement_amount,
                'The right LOST amountoutstanding is generated' );
            is( $lost_fee_line->status, undef, 'The LOST status was not set' );

            # Simulate refunding overdue fees upon marking item as lost
            my $overdue_forgive = $patron->account->add_credit(
                {
                    amount     => 10.00,
                    user_id    => $manager->borrowernumber,
                    library_id => $branchcode_charge,
                    interface  => 'test',
                    type       => 'FORGIVEN',
                    item_id    => $item->itemnumber
                }
            );
            $overdue_forgive->apply( { debits => [$overdue_fee] } );
            $overdue_fee->discard_changes;
            is($overdue_fee->amountoutstanding + 0, 0, 'Overdue fee forgiven');

            # Do nothing
            my ( undef, $message ) =
              AddReturn( $item->barcode, $branchcode_charge, undef, $five_days_ago );

            $lost_fee_line->discard_changes;
            is( $lost_fee_line->amount + 0,
                $replacement_amount, 'The LOST amount is left intact' );
            is( $lost_fee_line->amountoutstanding + 0,
                0,
                'The LOST amountoutstanding is refunded' );
            is( $lost_fee_line->status, 'FOUND', 'The LOST status was set to FOUND' );

            $overdue_fees = Koha::Account::Lines->search(
                {
                    borrowernumber  => $patron->id,
                    itemnumber      => $item->itemnumber,
                    debit_type_code => 'OVERDUE'
                },
                {
                    order_by => { '-asc' => 'accountlines_id'}
                }
            );
            is( $overdue_fees->count, 2, 'A second OVERDUE fee has been added' );
            $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                10, 'The original OVERDUE amount is left intact' );
            is( $overdue_fee->amountoutstanding + 0,
                0,
                'The original OVERDUE amountoutstanding is left as forgiven' );
            $overdue_fee = $overdue_fees->next;
            is( $overdue_fee->amount + 0,
                5, 'The new OVERDUE amount is correct for the backdated return' );
            is( $overdue_fee->amountoutstanding + 0,
                5,
                'The new OVERDUE amountoutstanding is correct for the backdated return' );
        };
    };
};

subtest '_FixOverduesOnReturn' => sub {
    plan tests => 14;

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

    my $patron = $builder->build( { source => 'Borrower' } );

    ## Start with basic call, should just close out the open fine
    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber => $patron->{borrowernumber},
            debit_type_code    => 'OVERDUE',
            status         => 'UNRETURNED',
            itemnumber     => $item->itemnumber,
            amount => 99.00,
            amountoutstanding => 99.00,
            interface => 'test',
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber, undef, 'RETURNED' );

    $accountline->_result()->discard_changes();

    is( $accountline->amountoutstanding+0, 99, 'Fine has the same amount outstanding as previously' );
    isnt( $accountline->status, 'UNRETURNED', 'Open fine ( account type OVERDUE ) has been closed out ( status not UNRETURNED )');
    is( $accountline->status, 'RETURNED', 'Passed status has been used to set as RETURNED )');

    ## Run again, with exemptfine enabled
    $accountline->set(
        {
            debit_type_code    => 'OVERDUE',
            status         => 'UNRETURNED',
            amountoutstanding => 99.00,
        }
    )->store();

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber, 1, 'RETURNED' );

    $accountline->_result()->discard_changes();
    my $offset = Koha::Account::Offsets->search({ debit_id => $accountline->id, type => 'APPLY' })->next();

    is( $accountline->amountoutstanding + 0, 0, 'Fine amountoutstanding has been reduced to 0' );
    isnt( $accountline->status, 'UNRETURNED', 'Open fine ( account type OVERDUE ) has been closed out ( status not UNRETURNED )');
    is( $accountline->status, 'RETURNED', 'Open fine ( account type OVERDUE ) has been set to returned ( status RETURNED )');
    is( ref $offset, "Koha::Account::Offset", "Found matching offset for fine reduction via forgiveness" );
    is( $offset->amount + 0, -99, "Amount of offset is correct" );
    my $credit = $offset->credit;
    is( ref $credit, "Koha::Account::Line", "Found matching credit for fine forgiveness" );
    is( $credit->amount + 0, -99, "Credit amount is set correctly" );
    is( $credit->amountoutstanding + 0, 0, "Credit amountoutstanding is correctly set to 0" );

    # Bug 25417 - Only forgive fines where there is an amount outstanding to forgive
    $accountline->set(
        {
            debit_type_code    => 'OVERDUE',
            status         => 'UNRETURNED',
            amountoutstanding => 0.00,
        }
    )->store();
    $offset->delete;

    C4::Circulation::_FixOverduesOnReturn( $patron->{borrowernumber}, $item->itemnumber, 1, 'RETURNED' );

    $accountline->_result()->discard_changes();
    $offset = Koha::Account::Offsets->search({ debit_id => $accountline->id, type => 'CREATE' })->next();
    is( $offset, undef, "No offset created when trying to forgive fine with no outstanding balance" );
    isnt( $accountline->status, 'UNRETURNED', 'Open fine ( account type OVERDUE ) has been closed out ( status not UNRETURNED )');
    is( $accountline->status, 'RETURNED', 'Passed status has been used to set as RETURNED )');
};

subtest 'Set waiting flag' => sub {
    plan tests => 11;

    my $library_1 = $builder->build( { source => 'Branch' } );
    my $patron_1  = $builder->build( { source => 'Borrower', value => { branchcode => $library_1->{branchcode}, categorycode => $patron_category->{categorycode} } } );
    my $library_2 = $builder->build( { source => 'Branch' } );
    my $patron_2  = $builder->build( { source => 'Borrower', value => { branchcode => $library_2->{branchcode}, categorycode => $patron_category->{categorycode} } } );

    my $item = $builder->build_sample_item(
        {
            library      => $library_1->{branchcode},
        }
    );

    set_userenv( $library_2 );
    my $reserve_id = AddReserve(
        {
            branchcode     => $library_2->{branchcode},
            borrowernumber => $patron_2->{borrowernumber},
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );

    set_userenv( $library_1 );
    my $do_transfer = 1;
    my ( $res, $rr ) = AddReturn( $item->barcode, $library_1->{branchcode} );
    ModReserveAffect( $item->itemnumber, undef, $do_transfer, $reserve_id );
    my $hold = Koha::Holds->find( $reserve_id );
    is( $hold->found, 'T', 'Hold is in transit' );

    my ( $status ) = CheckReserves($item->itemnumber);
    is( $status, 'Transferred', 'Hold is not waiting yet');

    set_userenv( $library_2 );
    $do_transfer = 0;
    AddReturn( $item->barcode, $library_2->{branchcode} );
    ModReserveAffect( $item->itemnumber, undef, $do_transfer, $reserve_id );
    $hold = Koha::Holds->find( $reserve_id );
    is( $hold->found, 'W', 'Hold is waiting' );
    ( $status ) = CheckReserves($item->itemnumber);
    is( $status, 'Waiting', 'Now the hold is waiting');

    #Bug 21944 - Waiting transfer checked in at branch other than pickup location
    set_userenv( $library_1 );
    (undef, my $messages, undef, undef ) = AddReturn ( $item->barcode, $library_1->{branchcode} );
    $hold = Koha::Holds->find( $reserve_id );
    is( $hold->found, undef, 'Hold is no longer marked waiting' );
    is( $hold->priority, 1,  "Hold is now priority one again");
    is( $hold->waitingdate, undef, "Hold no longer has a waiting date");
    is( $hold->itemnumber, $item->itemnumber, "Hold has retained its' itemnumber");
    is( $messages->{ResFound}->{ResFound}, "Reserved", "Hold is still returned");
    is( $messages->{ResFound}->{found}, undef, "Hold is no longer marked found in return message");
    is( $messages->{ResFound}->{priority}, 1, "Hold is priority 1 in return message");
};

subtest 'Cancel transfers on lost items' => sub {
    plan tests => 6;

    my $library_to = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item   = $builder->build_sample_item();
    my $holdingbranch = $item->holdingbranch;
    # Historic transfer (datearrived is defined)
    my $old_transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => \'NOW()',
                datearrived   => \'NOW()',
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );
    # Queued transfer (datesent is undefined)
    my $transfer_1 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );
    # In transit transfer (datesent is defined, datearrived and datecancelled are both undefined)
    my $transfer_2 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => \'NOW()',
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    # Simulate item being marked as lost
    $item->itemlost(1)->store;
    LostItem( $item->itemnumber, 'test', 1 );

    $transfer_1->discard_changes;
    isnt($transfer_1->datecancelled, undef, "Queud transfer was cancelled upon item lost");
    is($transfer_1->cancellation_reason, 'ItemLost', "Cancellation reason was set to 'ItemLost'");
    $transfer_2->discard_changes;
    isnt($transfer_2->datecancelled, undef, "Active transfer was cancelled upon item lost");
    is($transfer_2->cancellation_reason, 'ItemLost', "Cancellation reason was set to 'ItemLost'");
    $old_transfer->discard_changes;
    is($old_transfer->datecancelled, undef, "Old transfers are unaffected");
    $item->discard_changes;
    is($item->holdingbranch, $holdingbranch, "Items holding branch remains unchanged");
};

subtest 'CanBookBeIssued | is_overdue' => sub {
    plan tests => 3;

    # Set a simple circ policy
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rules        => {
                maxissueqty     => 1,
                reservesallowed => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 1,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
            }
        }
    );

    my $now   = dt_from_string()->truncate( to => 'day' );
    my $five_days_go = $now->clone->add( days => 5 );
    my $ten_days_go  = $now->clone->add( days => 10);
    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

    my $item = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
        }
    );

    my $issue = AddIssue( $patron->unblessed, $item->barcode, $five_days_go ); # date due was 10d ago
    my $actualissue = Koha::Checkouts->find( { itemnumber => $item->itemnumber } );
    is( output_pref({ str => $actualissue->date_due, dateonly => 1}), output_pref({ str => $five_days_go, dateonly => 1}), "First issue works");
    my ($issuingimpossible, $needsconfirmation) = CanBookBeIssued($patron, $item->barcode, $ten_days_go, undef, undef, undef);
    is( $needsconfirmation->{RENEW_ISSUE}, 1, "This is a renewal");
    is( $needsconfirmation->{TOO_MANY}, undef, "Not too many, is a renewal");
};

subtest 'ItemsDeniedRenewal rules are checked' => sub {
    plan tests => 4;

    my $idr_lib = $builder->build_object({ class => 'Koha::Libraries'});
    Koha::CirculationRules->set_rules(
        {
            categorycode => '*',
            itemtype     => '*',
            branchcode   => $idr_lib->branchcode,
            rules        => {
                reservesallowed => 25,
                issuelength     => 14,
                lengthunit      => 'days',
                renewalsallowed => 10,
                renewalperiod   => 7,
                norenewalbefore => undef,
                auto_renew      => 0,
                fine            => .10,
                chargeperiod    => 1,
            }
        }
    );

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
    my $issue = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                returndate      => undef,
                renewals_count  => 0,
                auto_renew      => 0,
                borrowernumber  => $idr_borrower->borrowernumber,
                itemnumber      => $allow_book->itemnumber,
                onsite_checkout => 0,
                date_due        => $future,
            }
        }
    );

    my $mock_item_class = Test::MockModule->new("Koha::Item");
    $mock_item_class->mock( 'is_denied_renewal', sub { return 1; } );

    my ( $mayrenew, $error ) = CanBookBeRenewed( $idr_borrower->borrowernumber, $issue->itemnumber );
    is( $mayrenew, 0, 'Renewal blocked when $item->is_denied_renewal returns true' );
    is( $error, 'item_denied_renewal', 'Renewal blocked when $item->is_denied_renewal returns true' );

    $mock_item_class->unmock( 'is_denied_renewal' );
    $mock_item_class->mock( 'is_denied_renewal', sub { return 0; } );

    ( $mayrenew, $error ) = CanBookBeRenewed( $idr_borrower->borrowernumber, $issue->itemnumber );
    is( $mayrenew, 1, 'Renewal allowed when $item->is_denied_renewal returns false' );
    is( $error, undef, 'Renewal allowed when $item->is_denied_renewal returns false' );

    $mock_item_class->unmock( 'is_denied_renewal' );
};

subtest 'CanBookBeIssued | item-level_itypes=biblio' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('item-level_itypes', 0); # biblio
    my $library = $builder->build( { source => 'Branch' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } )->store;

    my $item = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
        }
    );

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
    my $item = $builder->build_sample_item(
        {
            library  => $library->{branchcode},
            itype    => $itemtype->{itemtype},
        }
    );
    $item->biblioitem->itemtype($itemtype->{itemtype})->store;

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

subtest 'CanBookBeIssued | recalls' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference("UseRecalls", 1);
    t::lib::Mocks::mock_preference("item-level_itypes", 1);
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $item = $builder->build_sample_item;
    Koha::CirculationRules->set_rules({
        branchcode => undef,
        itemtype => undef,
        categorycode => undef,
        rules => {
            recalls_allowed => 10,
        },
    });

    # item-level recall
    my $recall = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => $item->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron1->branchcode,
        }
    )->store;

    my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron2, $item->barcode, undef, undef, undef, undef );
    is( $needsconfirmation->{RECALLED}->id, $recall->id, "Another patron has placed an item-level recall on this item" );

    $recall->set_cancelled;

    # biblio-level recall
    $recall = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => undef,
            item_level        => 0,
            pickup_library_id => $patron1->branchcode,
        }
    )->store;

    ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron2, $item->barcode, undef, undef, undef, undef );
    is( $needsconfirmation->{RECALLED}->id, $recall->id, "Another patron has placed a biblio-level recall and this item is eligible to fill it" );

    $recall->set_cancelled;

    # biblio-level recall
    $recall = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            biblio_id         => $item->biblionumber,
            item_id           => undef,
            item_level        => 0,
            pickup_library_id => $patron1->branchcode,
        }
    )->store;
    $recall->set_waiting( { item => $item, expirationdate => dt_from_string() } );

    my ( undef, undef, undef, $messages ) = CanBookBeIssued( $patron1, $item->barcode, undef, undef, undef, undef );
    is( $messages->{RECALLED}, $recall->id, "This book can be issued by this patron and they have placed a recall" );

    $recall->set_cancelled;
};

subtest 'AddReturn should clear items.onloan for unissued items' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference( "AllowReturnToBranch", 'anywhere' );
    my $item = $builder->build_sample_item(
        {
            onloan => '2018-01-01',
        }
    );

    AddReturn( $item->barcode, $item->homebranch );
    $item->discard_changes; # refresh
    is( $item->onloan, undef, 'AddReturn did clear items.onloan' );
};

subtest 'AddReturn | recalls' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference("UseRecalls", 1);
    t::lib::Mocks::mock_preference("item-level_itypes", 1);
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $item1 = $builder->build_sample_item;
    Koha::CirculationRules->set_rules({
        branchcode => undef,
        itemtype => undef,
        categorycode => undef,
        rules => {
            recalls_allowed => 10,
        },
    });

    # this item can fill a recall with pickup at this branch
    AddIssue( $patron1->unblessed, $item1->barcode );
    my $recall1 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            biblio_id         => $item1->biblionumber,
            item_id           => $item1->itemnumber,
            item_level        => 1,
            pickup_library_id => $item1->homebranch,
        }
    )->store;
    my ( $doreturn, $messages, $iteminfo, $borrowerinfo ) = AddReturn( $item1->barcode, $item1->homebranch );
    is( $messages->{RecallFound}->id, $recall1->id, "Recall found" );
    $recall1->set_cancelled;

    # this item can fill a recall but needs transfer
    AddIssue( $patron1->unblessed, $item1->barcode );
    $recall1 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            biblio_id         => $item1->biblionumber,
            item_id           => $item1->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron2->branchcode,
        }
    )->store;
    ( $doreturn, $messages, $iteminfo, $borrowerinfo ) = AddReturn( $item1->barcode, $item1->homebranch );
    is( $messages->{RecallNeedsTransfer}, $item1->homebranch, "Recall requiring transfer found" );
    $recall1->set_cancelled;

    # this item is already in transit, do not ask to transfer
    AddIssue( $patron1->unblessed, $item1->barcode );
    $recall1 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            biblio_id         => $item1->biblionumber,
            item_id           => $item1->itemnumber,
            item_level        => 1,
            pickup_library_id => $patron2->branchcode,
        }
    )->store;
    $recall1->start_transfer;
    ( $doreturn, $messages, $iteminfo, $borrowerinfo ) = AddReturn( $item1->barcode, $patron2->branchcode );
    is( $messages->{TransferredRecall}->id, $recall1->id, "In transit recall found" );
    $recall1->set_cancelled;
};

subtest 'AddReturn | bundles' => sub {
    plan tests => 1;

    my $schema = Koha::Database->schema;
    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $host_item1 = $builder->build_sample_item;
    my $bundle_item1 = $builder->build_sample_item;
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item1->itemnumber, item => $bundle_item1->itemnumber } );

    my ( $doreturn, $messages, $iteminfo, $borrowerinfo ) = AddReturn( $bundle_item1->barcode, $bundle_item1->homebranch );
    is($messages->{InBundle}->id, $host_item1->id, 'AddReturn returns InBundle host item when item is part of a bundle');

    $schema->storage->txn_rollback;
};

subtest 'AddRenewal and AddIssuingCharge tests' => sub {

    plan tests => 13;


    t::lib::Mocks::mock_preference('item-level_itypes', 1);

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
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes', value => { rentalcharge_daily => 0.00 }});
    my $patron   = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $library->id }
    });

    my $biblio = $builder->build_sample_biblio({ title=> $title, author => $author });
    my $item_id = Koha::Item->new(
        {
            biblionumber     => $biblio->biblionumber,
            homebranch       => $library->id,
            holdingbranch    => $library->id,
            barcode          => $barcode,
            replacementprice => 23.00,
            itype            => $itemtype->id
        },
    )->store->itemnumber;
    my $item = Koha::Items->find( $item_id );

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( userenv => { branch => $library->id } );

    # Check the item out
    AddIssue( $patron->unblessed, $item->barcode );

    throws_ok {
        AddRenewal( $patron->borrowernumber, $item->itemnumber, $library->id, undef, {break=>"the_renewal"} );
    } 'Koha::Exceptions::Checkout::FailedRenewal', 'Exception is thrown when renewal update to issues fails';

    t::lib::Mocks::mock_preference( 'RenewalLog', 0 );
    my $date = output_pref( { dt => dt_from_string(), dateonly => 1, dateformat => 'iso' } );
    my %params_renewal = (
        timestamp => { -like => $date . "%" },
        module => "CIRCULATION",
        action => "RENEWAL",
    );
    my $old_log_size = Koha::ActionLogs->count( \%params_renewal );;
    AddRenewal( $patron->id, $item->id, $library->id );
    my $new_log_size = Koha::ActionLogs->count( \%params_renewal );
    is( $new_log_size, $old_log_size, 'renew log not added because of the syspref RenewalLog' );

    my $checkouts = $patron->checkouts;
    # The following will fail if run on 00:00:00
    unlike ( $checkouts->next->lastreneweddate, qr/00:00:00/, 'AddRenewal should set the renewal date with the time part');

    my $lines = Koha::Account::Lines->search({
        borrowernumber => $patron->id,
        itemnumber     => $item->id
    });

    is( $lines->count, 2 );

    my $line = $lines->next;
    is( $line->debit_type_code, 'RENT',       'The issue of item with issuing charge generates an accountline of the correct type' );
    is( $line->branchcode,  $library->id, 'AddIssuingCharge correctly sets branchcode' );
    is( $line->description, '',     'AddIssue does not set a hardcoded description for the accountline' );

    $line = $lines->next;
    is( $line->debit_type_code, 'RENT_RENEW', 'The renewal of item with issuing charge generates an accountline of the correct type' );
    is( $line->branchcode,  $library->id, 'AddRenewal correctly sets branchcode' );
    is( $line->description, '', 'AddRenewal does not set a hardcoded description for the accountline' );

    t::lib::Mocks::mock_preference( 'RenewalLog', 1 );

    $context = Test::MockModule->new('C4::Context');
    $context->mock( userenv => { branch => undef, interface => 'CRON'} ); #Test statistical logging of renewal via cron (atuo_renew)

    my $now = dt_from_string;
    $date = output_pref( { dt => $now, dateonly => 1, dateformat => 'iso' } );
    $old_log_size = Koha::ActionLogs->count( \%params_renewal );
    my $sth = $dbh->prepare("SELECT COUNT(*) FROM statistics WHERE itemnumber = ? AND branch = ?");
    $sth->execute($item->id, $library->id);
    my ($old_stats_size) = $sth->fetchrow_array;
    AddRenewal( $patron->id, $item->id, $library->id );
    $new_log_size = Koha::ActionLogs->count( \%params_renewal );
    $sth->execute($item->id, $library->id);
    my ($new_stats_size) = $sth->fetchrow_array;
    is( $new_log_size, $old_log_size + 1, 'renew log successfully added' );
    is( $new_stats_size, $old_stats_size + 1, 'renew statistic successfully added with passed branch' );

    AddReturn( $item->id, $library->id, undef, $date );
    AddIssue( $patron->unblessed, $item->barcode, $now );
    AddRenewal( $patron->id, $item->id, $library->id, undef, undef, 1 );
    my $lines_skipped = Koha::Account::Lines->search({
        borrowernumber => $patron->id,
        itemnumber     => $item->id
    });
    is( $lines_skipped->count, 5, 'Passing skipfinecalc causes fine calculation on renewal to be skipped' );

};

subtest 'AddRenewal() adds to renewals' => sub {
    plan tests => 5;

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $patron   = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $library->id }
    });

    my $item = $builder->build_sample_item();

    set_userenv( $library->unblessed );

    # Check the item out
    my $issue = AddIssue( $patron->unblessed, $item->barcode );
    is(ref($issue), 'Koha::Checkout', 'Issue added');

    # Renew item
    my $duedate = AddRenewal( $patron->id, $item->id, $library->id, undef, undef, undef, undef, 1 );

    ok( $duedate, "Renewal added" );

    my $renewals = Koha::Checkouts::Renewals->search({ checkout_id => $issue->issue_id });
    is($renewals->count, 1, 'One renewal added');
    my $THE_renewal = $renewals->next;
    is( $THE_renewal->renewer_id, C4::Context->userenv->{'number'}, 'Renewer recorded from context' );
    is( $THE_renewal->renewal_type, 'Automatic', 'AddRenewal "automatic" parameter sets renewal type to "Automatic"');
};

subtest 'ProcessOfflinePayment() tests' => sub {

    plan tests => 4;


    my $amount = 123;

    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $result  = C4::Circulation::ProcessOfflinePayment({ cardnumber => $patron->cardnumber, amount => $amount, branchcode => $library->id });

    is( $result, 'Success.', 'The right string is returned' );

    my $lines = $patron->account->lines;
    is( $lines->count, 1, 'line created correctly');

    my $line = $lines->next;
    is( $line->amount+0, $amount * -1, 'amount picked from params' );
    is( $line->branchcode, $library->id, 'branchcode set correctly' );

};

subtest 'Incremented fee tests' => sub {
    plan tests => 19;

    my $dt = dt_from_string();
    Time::Fake->offset( $dt->epoch );

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } )->store;

    $module->mock( 'userenv', sub { { branch => $library->id } } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    )->store;

    my $itemtype = $builder->build_object(
        {
            class => 'Koha::ItemTypes',
            value => {
                notforloan                   => undef,
                rentalcharge                 => 0,
                rentalcharge_daily           => 1,
                rentalcharge_daily_calendar  => 0
            }
        }
    )->store;

    my $item = $builder->build_sample_item(
        {
            library  => $library->id,
            itype    => $itemtype->id,
        }
    );

    is( $itemtype->rentalcharge_daily + 0,1, 'Daily rental charge stored and retreived correctly' );
    is( $item->effective_itemtype, $itemtype->id, "Itemtype set correctly for item" );

    my $now         = dt_from_string;
    my $dt_from     = $now->clone;
    my $dt_to       = $now->clone->add( days => 7 );
    my $dt_to_renew = $now->clone->add( days => 13 );

    # Daily Tests
    my $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    my $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        7,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 0"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        6,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 0, for renewal"
    );
    $accountline->delete();
    $issue->delete();

    t::lib::Mocks::mock_preference( 'finesCalendar', 'noFinesWhenClosed' );
    $itemtype->rentalcharge_daily_calendar(1)->store();
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        7,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 1"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        6,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 1, for renewal"
    );
    $accountline->delete();
    $issue->delete();

    my $calendar = C4::Calendar->new( branchcode => $library->id );
    # DateTime 1..7 (Mon..Sun), C4::Calender 0..6 (Sun..Sat)
    my $closed_day =
        ( $dt_from->day_of_week == 6 ) ? 0
      : ( $dt_from->day_of_week == 7 ) ? 1
      :                                  $dt_from->day_of_week + 1;
    my $closed_day_name = $dt_from->clone->add(days => 1)->day_name;
    $calendar->insert_week_day_holiday(
        weekday     => $closed_day,
        title       => 'Test holiday',
        description => 'Test holiday'
    );
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        6,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 1 and closed $closed_day_name"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        5,
        "Daily rental charge calculated correctly with rentalcharge_daily_calendar = 1 and closed $closed_day_name, for renewal"
    );
    $accountline->delete();
    $issue->delete();

    $itemtype->rentalcharge(2)->store;
    is( $itemtype->rentalcharge + 0, 2, 'Rental charge updated and retreived correctly' );
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    my $accountlines =
      Koha::Account::Lines->search( { itemnumber => $item->id } );
    is( $accountlines->count, '2', "Fixed charge and accrued charge recorded distinctly" );
    $accountlines->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountlines = Koha::Account::Lines->search( { itemnumber => $item->id } );
    is( $accountlines->count, '2', "Fixed charge and accrued charge recorded distinctly, for renewal" );
    $accountlines->delete();
    $issue->delete();
    $itemtype->rentalcharge(0)->store;
    is( $itemtype->rentalcharge + 0, 0, 'Rental charge reset and retreived correctly' );

    # Hourly
    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $itemtype->id,
            branchcode   => $library->id,
            rule_name    => 'lengthunit',
            rule_value   => 'hours',
        }
    );

    $itemtype->rentalcharge_hourly('0.25')->store();
    is( $itemtype->rentalcharge_hourly, '0.25', 'Hourly rental charge stored and retreived correctly' );

    $dt_to       = $now->clone->add( hours => 168 );
    $dt_to_renew = $now->clone->add( hours => 312 );

    $itemtype->rentalcharge_hourly_calendar(0)->store();
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        42,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 0 (168h * 0.25u)"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        36,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 0, for renewal (312h - 168h * 0.25u)"
    );
    $accountline->delete();
    $issue->delete();

    $itemtype->rentalcharge_hourly_calendar(1)->store();
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        36,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 1 and closed $closed_day_name (168h - 24h * 0.25u)"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        30,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 1 and closed $closed_day_name, for renewal (312h - 168h - 24h * 0.25u"
    );
    $accountline->delete();
    $issue->delete();

    $calendar->delete_holiday( weekday => $closed_day );
    $issue =
      AddIssue( $patron->unblessed, $item->barcode, $dt_to, undef, $dt_from );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        42,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 1 (168h - 0h * 0.25u"
    );
    $accountline->delete();
    AddRenewal( $patron->id, $item->id, $library->id, $dt_to_renew, $dt_to );
    $accountline = Koha::Account::Lines->find( { itemnumber => $item->id } );
    is(
        $accountline->amount + 0,
        36,
        "Hourly rental charge calculated correctly with rentalcharge_hourly_calendar = 1, for renewal (312h - 168h - 0h * 0.25u)"
    );
    $accountline->delete();
    $issue->delete();
    Time::Fake->reset;
};

subtest 'CanBookBeIssued & RentalFeesCheckoutConfirmation' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('RentalFeesCheckoutConfirmation', 1);
    t::lib::Mocks::mock_preference('item-level_itypes', 1);

    my $library =
      $builder->build_object( { class => 'Koha::Libraries' } )->store;
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    )->store;

    my $itemtype = $builder->build_object(
        {
            class => 'Koha::ItemTypes',
            value => {
                notforloan             => 0,
                rentalcharge           => 0,
                rentalcharge_daily => 0
            }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library    => $library->id,
            notforloan => 0,
            itemlost   => 0,
            withdrawn  => 0,
            itype      => $itemtype->id,
        }
    )->store;

    my ( $issuingimpossible, $needsconfirmation );
    my $dt_from = dt_from_string();
    my $dt_due = $dt_from->clone->add( days => 3 );

    $itemtype->rentalcharge(1)->store;
    ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, $dt_due, undef, undef, undef );
    is_deeply( $needsconfirmation, { RENTALCHARGE => '1.00' }, 'Item needs rentalcharge confirmation to be issued' );
    $itemtype->rentalcharge('0')->store;
    $itemtype->rentalcharge_daily(1)->store;
    ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, $dt_due, undef, undef, undef );
    is_deeply( $needsconfirmation, { RENTALCHARGE => '3' }, 'Item needs rentalcharge confirmation to be issued, increment' );
    $itemtype->rentalcharge_daily('0')->store;
};

subtest 'CanBookBeIssued & CircConfirmItemParts' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference('CircConfirmItemParts', 1);

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    )->store;

    my $item = $builder->build_sample_item(
        {
            materials => 'includes DVD',
        }
    )->store;

    my $dt_due = dt_from_string->add( days => 3 );

    my ( $issuingimpossible, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, $dt_due, undef, undef, undef );
    is_deeply( $needsconfirmation, { ADDITIONAL_MATERIALS => 'includes DVD' }, 'Item needs confirmation of additional parts' );
};

subtest 'Do not return on renewal (LOST charge)' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference('MarkLostItemsAsReturned', 'onpayment');
    my $library = $builder->build_object( { class => "Koha::Libraries" } );
    my $manager = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv({ patron => $manager,branchcode => $manager->branchcode });

    my $biblio = $builder->build_sample_biblio;

    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->biblionumber,
            library          => $library->branchcode,
            replacementprice => 99.00,
            itype            => $itemtype,
        }
    );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    AddIssue( $patron->unblessed, $item->barcode );

    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            debit_type_code   => 'LOST',
            status            => undef,
            itemnumber        => $item->itemnumber,
            amount            => 12,
            amountoutstanding => 12,
            interface         => 'something',
        }
    )->store();

    # AddRenewal doesn't call _FixAccountForLostAndFound
    AddIssue( $patron->unblessed, $item->barcode );

    is( $patron->checkouts->count, 1,
        'Renewal should not return the item even if a LOST payment has been made earlier'
    );
};

subtest 'Filling a hold should cancel existing transfer' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference('AutomaticItemReturn', 1);

    my $libraryA = $builder->build_object( { class => 'Koha::Libraries' } );
    my $libraryB = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $patron_category->{categorycode},
                branchcode => $libraryA->branchcode,
            }
        }
    )->store;

    my $item = $builder->build_sample_item({
        homebranch => $libraryB->branchcode,
    });

    my ( undef, $message ) = AddReturn( $item->barcode, $libraryA->branchcode, undef, undef );
    is( Koha::Item::Transfers->search({ itemnumber => $item->itemnumber, datearrived => undef })->count, 1, "We generate a transfer on checkin");
    AddReserve({
        branchcode     => $libraryA->branchcode,
        borrowernumber => $patron->borrowernumber,
        biblionumber   => $item->biblionumber,
        itemnumber     => $item->itemnumber
    });
    my $reserves = Koha::Holds->search({ itemnumber => $item->itemnumber });
    is( $reserves->count, 1, "Reserve is placed");
    ( undef, $message ) = AddReturn( $item->barcode, $libraryA->branchcode, undef, undef );
    my $reserve = $reserves->next;
    ModReserveAffect( $item->itemnumber, $patron->borrowernumber, 0, $reserve->reserve_id );
    $reserve->discard_changes;
    ok( $reserve->found eq 'W', "Reserve is marked waiting" );
    is( Koha::Item::Transfers->search({ itemnumber => $item->itemnumber, datearrived => undef })->count, 0, "No outstanding transfers when hold is waiting");
};

subtest 'Tests for NoRefundOnLostReturnedItemsAge with AddReturn' => sub {

    plan tests => 4;

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 0);
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );

    my $biblionumber = $builder->build_sample_biblio(
        {
            branchcode => $library->branchcode,
        }
    )->biblionumber;

    # And the circulation rule
    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                issuelength => 14,
                lengthunit  => 'days',
            }
        }
    );
    $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 'refund'
            }
        }
    );

    subtest 'NoRefundOnLostReturnedItemsAge = undef' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', undef );

        my $lost_on = dt_from_string->subtract( days => 7 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        my ( $doreturn, $messages ) = AddReturn( $item->barcode, $library->branchcode, undef, dt_from_string );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 0, "Lost fee was refunded" );
        $a->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge > length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 6 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        my ( $doreturn, $messages ) = AddReturn( $item->barcode, $library->branchcode, undef, dt_from_string );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 0, "Lost fee was refunded" );
        $a->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge = length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 7 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        my ( $doreturn, $messages ) = AddReturn( $item->barcode, $library->branchcode, undef, dt_from_string );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 42, "Lost fee was not refunded" );
        $a->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge < length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 8 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        );
        $a = $a->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        my ( $doreturn, $messages ) = AddReturn( $item->barcode, $library->branchcode, undef, dt_from_string );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 42, "Lost fee was not refunded" );
        $a->delete;
    };
};

subtest 'Tests for NoRefundOnLostReturnedItemsAge with AddIssue' => sub {

    plan tests => 4;

    t::lib::Mocks::mock_preference('BlockReturnOfLostItems', 0);
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );
    my $patron2  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );

    my $biblionumber = $builder->build_sample_biblio(
        {
            branchcode => $library->branchcode,
        }
    )->biblionumber;

    # And the circulation rule
    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                issuelength => 14,
                lengthunit  => 'days',
            }
        }
    );
    $builder->build(
        {
            source => 'CirculationRule',
            value  => {
                branchcode   => undef,
                categorycode => undef,
                itemtype     => undef,
                rule_name    => 'lostreturn',
                rule_value   => 'refund'
            }
        }
    );

    subtest 'NoRefundOnLostReturnedItemsAge = undef' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', undef );

        my $lost_on = dt_from_string->subtract( days => 7 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        $issue = AddIssue( $patron2->unblessed, $item->barcode );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 0, "Lost fee was refunded" );
        $a->delete;
        $issue->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge > length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 6 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        $issue = AddIssue( $patron2->unblessed, $item->barcode );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 0, "Lost fee was refunded" );
        $a->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge = length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 7 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        )->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        $issue = AddIssue( $patron2->unblessed, $item->barcode );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 42, "Lost fee was not refunded" );
        $a->delete;
    };

    subtest 'NoRefundOnLostReturnedItemsAge < length of days item has been lost' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'WhenLostChargeReplacementFee',   1 );
        t::lib::Mocks::mock_preference( 'NoRefundOnLostReturnedItemsAge', 7 );

        my $lost_on = dt_from_string->subtract( days => 8 )->date;

        my $item = $builder->build_sample_item(
            {
                biblionumber     => $biblionumber,
                library          => $library->branchcode,
                replacementprice => '42',
            }
        );
        my $issue = AddIssue( $patron->unblessed, $item->barcode );
        LostItem( $item->itemnumber, 'cli', 0 );
        $item->_result->itemlost(1);
        $item->_result->itemlost_on( $lost_on );
        $item->_result->update();

        my $a = Koha::Account::Lines->search(
            {
                itemnumber     => $item->id,
                borrowernumber => $patron->borrowernumber
            }
        );
        $a = $a->next;
        ok( $a, "Found accountline for lost fee" );
        is( $a->amountoutstanding + 0, 42, "Lost fee charged correctly" );
        $issue = AddIssue( $patron2->unblessed, $item->barcode );
        $a = $a->get_from_storage;
        is( $a->amountoutstanding + 0, 42, "Lost fee was not refunded" );
        $a->delete;
    };
};

subtest 'transferbook tests' => sub {
    plan tests => 9;

    throws_ok
    { C4::Circulation::transferbook({}); }
    'Koha::Exceptions::MissingParameter',
    'Koha::Patron->store raises an exception on missing params';

    throws_ok
    { C4::Circulation::transferbook({to_branch=>'anything'}); }
    'Koha::Exceptions::MissingParameter',
    'Koha::Patron->store raises an exception on missing params';

    throws_ok
    { C4::Circulation::transferbook({from_branch=>'anything'}); }
    'Koha::Exceptions::MissingParameter',
    'Koha::Patron->store raises an exception on missing params';

    my ($doreturn,$messages) = C4::Circulation::transferbook({to_branch=>'there',from_branch=>'here'});
    is( $doreturn, 0, "No return without barcode");
    ok( exists $messages->{BadBarcode}, "We get a BadBarcode message if no barcode passed");
    is( $messages->{BadBarcode}, undef, "No barcode passed means undef BadBarcode" );

    ($doreturn,$messages) = C4::Circulation::transferbook({to_branch=>'there',from_branch=>'here',barcode=>'BadBarcode'});
    is( $doreturn, 0, "No return without barcode");
    ok( exists $messages->{BadBarcode}, "We get a BadBarcode message if no barcode passed");
    is( $messages->{BadBarcode}, 'BadBarcode', "No barcode passed means undef BadBarcode" );

};

subtest 'Checkout should correctly terminate a transfer' => sub {
    plan tests => 7;

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_1->branchcode }
        }
    );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_2->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library_1->branchcode,
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library_1->branchcode } );
    my $reserve_id = AddReserve(
        {
            branchcode     => $library_2->branchcode,
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    my $do_transfer = 1;
    ModItemTransfer( $item->itemnumber, $library_1->branchcode,
        $library_2->branchcode, 'Manual' );
    ModReserveAffect( $item->itemnumber, undef, $do_transfer, $reserve_id );
    GetOtherReserves( $item->itemnumber )
      ;    # To put the Reason, it's what does returns.pl...
    my $hold = Koha::Holds->find($reserve_id);
    is( $hold->found, 'T', 'Hold is in transit' );
    my $transfer = $item->get_transfer;
    is( $transfer->frombranch, $library_1->branchcode );
    is( $transfer->tobranch,   $library_2->branchcode );
    is( $transfer->reason,     'Reserve' );

    t::lib::Mocks::mock_userenv( { branchcode => $library_2->branchcode } );
    AddIssue( $patron_1->unblessed, $item->barcode );
    $transfer = $transfer->get_from_storage;
    isnt( $transfer->datearrived, undef );
    $hold = $hold->get_from_storage;
    is( $hold->found, undef, 'Hold is waiting' );
    is( $hold->priority, 1, );
};

subtest 'AddIssue records staff who checked out item if appropriate' => sub  {
    plan tests => 2;

    $module->mock( 'userenv', sub { { branch => $library->{id} } } );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );
    my $issuer = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $patron_category->{categorycode} }
        }
    );
    my $item_1 = $builder->build_sample_item(
        {
            library  => $library->{branchcode}
        }
    );

    my $item_2 = $builder->build_sample_item(
        {
            library  => $library->branchcode
        }
    );

    $module->mock( 'userenv', sub { { branch => $library->id, number => $issuer->borrowernumber } } );

    my $dt_from = dt_from_string();
    my $dt_to   = dt_from_string()->add( days => 7 );

    my $issue_1 = AddIssue( $patron->unblessed, $item_1->barcode, $dt_to, undef, $dt_from );

    is( $issue_1->issuer, undef, "Staff who checked out the item not recorded when RecordStaffUserOnCheckout turned off" );

    t::lib::Mocks::mock_preference('RecordStaffUserOnCheckout', 1);

    my $issue_2 =
      AddIssue( $patron->unblessed, $item_2->barcode, $dt_to, undef, $dt_from );

    is( $issue_2->issuer->borrowernumber, $issuer->borrowernumber, "Staff who checked out the item recorded when RecordStaffUserOnCheckout turned on" );
};

subtest "Item's onloan value should be set if checked out item is checked out to a different patron" => sub {
    plan tests => 2;

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_1->branchcode }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_1->branchcode }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library_1->branchcode,
        }
    );

    AddIssue( $patron_1->unblessed, $item->barcode );
    ok( $item->get_from_storage->onloan, "Item's onloan column is set after initial checkout" );
    AddIssue( $patron_2->unblessed, $item->barcode );
    ok( $item->get_from_storage->onloan, "Item's onloan column is set after second checkout" );
};

subtest "updateWrongTransfer tests" => sub {
    plan tests => 5;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            datelastseen  => undef
        }
    );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $library2->branchcode,
                tobranch      => $library1->branchcode,
                daterequested => dt_from_string,
                datesent      => dt_from_string,
                datecancelled => undef,
                datearrived   => undef,
                reason        => 'Manual'
            }
        }
    );
    is( ref($transfer), 'Koha::Item::Transfer', 'Mock transfer added' );

    my $new_transfer = C4::Circulation::updateWrongTransfer($item->itemnumber, $library1->branchcode);
    is(ref($new_transfer), 'Koha::Item::Transfer', "updateWrongTransfer returns a 'Koha::Item::Transfer' object");
    ok( !$new_transfer->in_transit, "New transfer is NOT created as in transit (or cancelled)");

    my $original_transfer = $transfer->get_from_storage;
    ok( defined($original_transfer->datecancelled), "Original transfer was cancelled");
    is( $original_transfer->cancellation_reason, 'WrongTransfer', "Original transfer cancellation reason is 'WrongTransfer'");
};

subtest "SendCirculationAlert" => sub {
    plan tests => 3;

    # When you would unsuspectingly call this unit test (with perl, not prove), you will be bitten by LOCK.
    # LOCK will commit changes and ruin your data
    # In order to prevent that, we will add KOHA_TESTING to $ENV; see further Circulation.pm
    $ENV{KOHA_TESTING} = 1;

    # Setup branch, borrowr, and notice
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    set_userenv( $library->unblessed);
    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    C4::Members::Messaging::SetMessagingPreference({
        borrowernumber => $patron->id,
        message_transport_types => ['sms'],
        message_attribute_id => 5
    });
    my $item = $builder->build_sample_item();
    my $checkin_notice = $builder->build_object({
        class => 'Koha::Notice::Templates',
        value =>{
            module => 'circulation',
            code => 'CHECKIN',
            branchcode => $library->branchcode,
            name => 'Test Checkin',
            is_html => 0,
            content => "Checkins:\n----\n[% biblio.title %]-[% old_checkout.issue_id %]\n----Thank you.",
            message_transport_type => 'sms',
            lang => 'default'
        }
    })->store;

    # Checkout an item, mark it returned, generate a notice
    my $issue_1 = AddIssue( $patron->unblessed, $item->barcode);
    MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 0, { skip_record_index => 1} );
    C4::Circulation::SendCirculationAlert({
        type => 'CHECKIN',
        item => $item->unblessed,
        borrower => $patron->unblessed,
        branch => $library->branchcode,
        issue => $issue_1
    });
    my $notice = Koha::Notice::Messages->find({ borrowernumber => $patron->id, letter_code => 'CHECKIN' });
    is($notice->content,"Checkins:\n".$item->biblio->title."-".$issue_1->id."\nThank you.", 'Letter generated with expected output on first checkin' );
    is($notice->to_address, $patron->smsalertnumber, "Letter has the correct to_address set to smsalertnumber for SMS type notices");

    # Checkout an item, mark it returned, generate a notice
    my $issue_2 = AddIssue( $patron->unblessed, $item->barcode);
    MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 0, { skip_record_index => 1} );
    C4::Circulation::SendCirculationAlert({
        type => 'CHECKIN',
        item => $item->unblessed,
        borrower => $patron->unblessed,
        branch => $library->branchcode,
        issue => $issue_2
    });
    $notice->discard_changes();
    is($notice->content,"Checkins:\n".$item->biblio->title."-".$issue_1->id."\n".$item->biblio->title."-".$issue_2->id."\nThank you.", 'Letter appended with expected output on second checkin' );

};

subtest "GetSoonestRenewDate tests" => sub {
    plan tests => 6;
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'norenewalbefore',
            rule_value   => '7',
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                autorenew_checkouts => 1,
            }
        }
    );
    my $item = $builder->build_sample_item();
    my $issue = AddIssue( $patron->unblessed, $item->barcode);
    my $datedue = dt_from_string( $issue->date_due() );

    # Bug 14395
    # Test 'exact time' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'exact_time' );
    is(
        GetSoonestRenewDate( $issue ),
        $datedue->clone->add( days => -7 ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );

    # Bug 14395
    # Test 'date' setting for syspref NoRenewalBeforePrecision
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'date' );
    is(
        GetSoonestRenewDate( $issue ),
        $datedue->clone->add( days => -7 )->truncate( to => 'day' ),
        'Bug 14395: Renewals permitted 7 days before due date, as expected'
    );


    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'norenewalbefore',
            rule_value   => undef,
        }
    );

    is(
        GetSoonestRenewDate( $issue ),
        dt_from_string,
        'Checkouts without auto-renewal can be renewed immediately if no norenewalbefore'
    );

    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'date' );
    $issue->auto_renew(1)->store;
    is(
        GetSoonestRenewDate( $issue ),
        $datedue->clone->truncate( to => 'day' ),
        'Checkouts with auto-renewal can be renewed earliest on due date if no renewalbefore'
    );
    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'exact' );
    is(
        GetSoonestRenewDate( $issue ),
        $datedue,
        'Checkouts with auto-renewal can be renewed earliest on due date if no renewalbefore'
    );

    t::lib::Mocks::mock_preference( 'NoRenewalBeforePrecision', 'date' );
    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            branchcode   => undef,
            itemtype     => undef,
            rule_name    => 'norenewalbefore',
            rule_value   => 1,
        }
    );
    $issue->date_due( dt_from_string )->store;
    is(
        GetSoonestRenewDate( $issue ),
        dt_from_string->subtract( days => 1 )->truncate( to => 'day' ),
        'Checkouts with auto-renewal can be renewed 1 day before due date if no renewalbefore = 1 and precision = "date"'
    );
};

subtest "CanBookBeIssued + needsconfirmation message" => sub {
    plan tests => 4;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio = $builder->build_object({ class => 'Koha::Biblios' });
    my $biblioitem = $builder->build_object({ class => 'Koha::Biblioitems', value => { biblionumber => $biblio->biblionumber }});
    my $item = $builder->build_object({ class => 'Koha::Items' , value => { biblionumber => $biblio->biblionumber }});

    my $hold = $builder->build_object({ class => 'Koha::Holds', value => {
        biblionumber => $item->biblionumber,
        branchcode => $library->branchcode,
        itemnumber => undef,
        itemtype => undef,
        priority => 1,
        found => undef,
        suspend => 0,
    }});

    my ( $error, $needsconfirmation, $alerts, $messages );

    ( $error, $needsconfirmation, $alerts, $messages ) = CanBookBeIssued( $patron, $item->barcode );
    is($needsconfirmation->{resbranchcode}, $hold->branchcode, "Branchcodes match when hold exists.");

    $hold->priority(0)->store();

    $hold->found("W")->store();
    ( $error, $needsconfirmation, $alerts, $messages ) = CanBookBeIssued( $patron, $item->barcode );
    is($needsconfirmation->{resbranchcode}, $hold->branchcode, "Branchcodes match when hold is waiting.");

    $hold->found("T")->store();
    ( $error, $needsconfirmation, $alerts, $messages ) = CanBookBeIssued( $patron, $item->barcode );
    is($needsconfirmation->{resbranchcode}, $hold->branchcode, "Branchcodes match when hold is being transferred.");

    $hold->found("P")->store();
    ( $error, $needsconfirmation, $alerts, $messages ) = CanBookBeIssued( $patron, $item->barcode );
    is($needsconfirmation->{resbranchcode}, $hold->branchcode, "Branchcodes match when hold is being processed.");
};

subtest 'Tests for BlockReturnOfWithdrawnItems' => sub {

    plan tests => 1;

    t::lib::Mocks::mock_preference('BlockReturnOfWithdrawnItems', 1);
    t::lib::Mocks::mock_preference('RecordLocalUseOnReturn', 0);
    my $item = $builder->build_sample_item();
    $item->withdrawn(1)->itemlost(1)->store;
    my @return = AddReturn( $item->barcode, $item->homebranch, 0, undef );
    is_deeply(
        \@return,
        [ 0, { NotIssued => $item->barcode, withdrawn => 1 }, undef, {} ], "Item returned as withdrawn, no other messages");
};

subtest 'Tests for transfer not in transit' => sub {

    plan tests => 2;


    # These tests are to ensure a 'pending' transfer, generated by
    # stock rotation, will be advanced when checked in

    my $item = $builder->build_sample_item();
    my $transfer = $builder->build_object({ class => 'Koha::Item::Transfers', value => {
        itemnumber => $item->id,
        reason => 'StockrotationRepatriation',
        datesent => undef,
        frombranch => $item->homebranch,
    }});
    my @return = AddReturn( $item->barcode, $item->homebranch, 0, undef );
    is_deeply(
        \@return,
        [ 0, { WasTransfered => $transfer->tobranch, TransferTrigger => 'StockrotationRepatriation', NotIssued => $item->barcode }, undef, {} ], "Item is reported to have been transferred");

    $transfer->discard_changes;
    ok( $transfer->datesent, 'The datesent field is populated, i.e. transfer is initiated');

};

subtest 'Tests for RecordLocalUseOnReturn' => sub {

    plan tests => 2;

    t::lib::Mocks::mock_preference('RecordLocalUseOnReturn', 0);
    my $item = $builder->build_sample_item();
    $item->withdrawn(1)->itemlost(1)->store;
    my @return = AddReturn( $item->barcode, $item->homebranch, 0, undef );
    is_deeply(
        \@return,
        [ 0, { NotIssued => $item->barcode, withdrawn => 1  }, undef, {} ], "RecordLocalUSeOnReturn is off, no local use recorded");

    t::lib::Mocks::mock_preference('RecordLocalUseOnReturn', 1);
    my @return2 = AddReturn( $item->barcode, $item->homebranch, 0, undef );
    is_deeply(
        \@return2,
        [ 0, { NotIssued => $item->barcode, withdrawn => 1, LocalUse => 1  }, undef, {} ], "Local use is recorded");
};

$schema->storage->txn_rollback;
C4::Context->clear_syspref_cache();
$branches = Koha::Libraries->search();
for my $branch ( $branches->next ) {
    my $key = $branch->branchcode . "_holidays";
    $cache->clear_from_cache($key);
}
