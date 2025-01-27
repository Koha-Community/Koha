#!/usr/bin/perl;

use Modern::Perl;
use Test::More tests => 18;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::Libraries;

use t::lib::Mocks;
use t::lib::TestBuilder;

use_ok( 'C4::Overdues', qw( GetOverdueMessageTransportTypes GetBranchcodesWithOverdueRules UpdateFine ) );
can_ok( 'C4::Overdues', 'GetOverdueMessageTransportTypes' );
can_ok( 'C4::Overdues', 'GetBranchcodesWithOverdueRules' );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);
$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|DELETE FROM overduerules_transport_types|);

$dbh->do(
    q|
    INSERT INTO message_transport_types( message_transport_type ) VALUES ('email'), ('phone'), ('print'), ('sms')
|
);

$dbh->do(
    q|
    INSERT INTO overduerules ( overduerules_id, branchcode, categorycode ) VALUES
    (1, 'CPL', 'PT'),
    (2, 'CPL', 'YA'),
    (3, '', 'PT'),
    (4, '', 'YA')
|
);

$dbh->do(
    q|INSERT INTO overduerules_transport_types (overduerules_id, letternumber, message_transport_type) VALUES
    (1, 1, 'email'),
    (1, 2, 'sms'),
    (1, 3, 'email'),
    (2, 3, 'print'),
    (3, 1, 'email'),
    (3, 2, 'email'),
    (3, 2, 'sms'),
    (3, 3, 'sms'),
    (3, 3, 'email'),
    (3, 3, 'print'),
    (4, 2, 'sms')
|
);

my $mtts;

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( 'CPL', 'PT' );
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no letternumber given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( 'CPL', undef, 1 );
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no categorycode given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL');
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no letternumber and categorycode given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( 'CPL', 'PT', 1 );
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: first overdue is by email for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( 'CPL', 'PT', 2 );
is_deeply( $mtts, ['sms'], 'GetOverdueMessageTransportTypes: second overdue is by sms for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( 'CPL', 'PT', 3 );
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: third overdue is by email for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( '', 'PT', 1 );
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: first overdue is by email for PT (default)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( '', 'PT', 2 );
is_deeply(
    $mtts, [ 'email', 'sms' ],
    'GetOverdueMessageTransportTypes: second overdue is by email and sms for PT (default)'
);

$mtts = C4::Overdues::GetOverdueMessageTransportTypes( '', 'PT', 3 );
is_deeply(
    $mtts, [ 'print', 'sms', 'email' ],
    'GetOverdueMessageTransportTypes: third overdue is by print, sms and email for PT (default). With print in first.'
);

# Test GetBranchcodesWithOverdueRules
$dbh->do(q|DELETE FROM overduerules|);

my @overdue_branches;
warnings_are { @overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules(); } [],
    "No warnings thrown when no overdue rules exist";

$dbh->do(
    q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( '', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|
);

my @branchcodes = map { $_->branchcode } Koha::Libraries->search->as_list;

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply(
    [ sort @overdue_branches ], [ sort @branchcodes ],
    'If a default rule exists, all branches should be returned'
);

$dbh->do(
    q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|
);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply(
    [ sort @overdue_branches ], [ sort @branchcodes ],
    'If a default rule exists and a specific rule exists, all branches should be returned'
);

$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(
    q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|
);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( \@overdue_branches, ['CPL'], 'If only a specific rule exist, only 1 branch should be returned' );

$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(
    q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1_CPL', 1, 5, 'LETTER_CODE2_CPL', 1, 10, 'LETTER_CODE3_CPL', 1 ),
        ( 'MPL', '', 1, 'LETTER_CODE1_MPL', 1, 5, 'LETTER_CODE2_MPL', 1, 10, 'LETTER_CODE3_MPL', 1 )
|
);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( \@overdue_branches, [ 'CPL', 'MPL' ], 'If only 2 specific rules exist, 2 branches should be returned' );

$schema->storage->txn_rollback;

subtest 'UpdateFine tests' => sub {

    plan tests => 75;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'MaxFine', '100' );

    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item1     = $builder->build_sample_item();
    my $item2     = $builder->build_sample_item();
    my $checkout1 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item1->itemnumber, borrowernumber => $patron->id }
        }
    );
    my $checkout2 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item2->itemnumber, borrowernumber => $patron->id }
        }
    );

    # Try to add 0 amount fine
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '0',
            due            => $checkout1->date_due
        }
    );

    my $fines = Koha::Account::Lines->search( { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 0, "No fine added when amount is 0" );

    # Total : Outstanding : MaxFine
    #   0   :      0      :   100

    # Add fine 1 - First Item Overdue
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '50',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search( { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 1, "Fine added when amount is greater than 0" );
    my $fine = $fines->next;
    is( $fine->amount + 0,            50,                     "Fine amount correctly set to 50" );
    is( $fine->amountoutstanding + 0, 50,                     "Fine amountoutstanding correctly set to 50" );
    is( $fine->issue_id,              $checkout1->issue_id,   "Fine is associated with the correct issue" );
    is( $fine->itemnumber,            $checkout1->itemnumber, "Fine is associated with the correct item" );

    # Total : Outstanding : MaxFine
    #  50   :     50      :   100

    # Increase fine 1 - First Item Overdue
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '80',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search( { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 1, "Existing fine updated" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "Fine amount correctly updated to 80" );
    is( $fine->amountoutstanding + 0, 80, "Fine amountoutstanding correctly updated to 80" );

    # Total : Outstanding : MaxFine
    #  80   :     80      :   100

    # Add fine 2 - Second Item Overdue
    UpdateFine(
        {
            issue_id       => $checkout2->issue_id,
            itemnumber     => $item2->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '30',
            due            => $checkout2->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 2, "New fine added for second checkout" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "First fine amount unchanged" );
    is( $fine->amountoutstanding + 0, 80, "First fine amountoutstanding unchanged" );
    my $fine2 = $fines->next;
    is( $fine2->amount + 0,             20, "Second fine capped at '20' by MaxFine" );
    is( $fine2->amountoutstanding + 0,  20, "Second fine amountoutstanding capped at '20' by MaxFine" );
    is( $fine2->issue_id,               $checkout2->issue_id,   "Second fine is associated with the correct issue" );
    is( $fine2->itemnumber,             $checkout2->itemnumber, "Second fine is associated with the correct item" );
    is( $fine->amount + $fine2->amount, '100',                  "Total fines = 100" );
    is( $fine->amountoutstanding + $fine2->amountoutstanding, '100', "Total outstanding = 100" );

    # Total : Outstanding : MaxFine
    #  100  :     100     :   100

    # A day passes, the item is still overdue, update fine is called again
    # we don't expect to increase above MaxFine of 100
    UpdateFine(
        {
            issue_id       => $checkout2->issue_id,
            itemnumber     => $item2->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '40',
            due            => $checkout2->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 2, "Existing fine updated for second checkout, no new fine added" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "First fine amount unchanged" );
    is( $fine->amountoutstanding + 0, 80, "First fine amountoutstanding unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0,             20, "Second fine capped at '20' by MaxFine" );
    is( $fine2->amountoutstanding + 0,  20, "Second fine amountoutstanding capped at '20' by MaxFine" );
    is( $fine2->issue_id,               $checkout2->issue_id,   "Second fine is associated with the correct issue" );
    is( $fine2->itemnumber,             $checkout2->itemnumber, "Second fine is associated with the correct item" );
    is( $fine->amount + $fine2->amount, '100',                  "Total fines = 100" );
    is( $fine->amountoutstanding + $fine2->amountoutstanding, '100', "Total outstanding = 100" );

    # Total : Outstanding : MaxFine
    #  100  :     100     :   100

    # Partial pay fine 1
    $fine->amountoutstanding(50)->store;

    # Total : Outstanding : MaxFine
    #  100  :     50      :   100

    # Increase fine 2 - Second item overdue
    UpdateFine(
        {
            issue_id       => $checkout2->issue_id,
            itemnumber     => $item2->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '30',
            due            => $checkout2->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 2, "Still two fines after second checkout update" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "First fine amount unchanged" );
    is( $fine->amountoutstanding + 0, 50, "First fine amountoutstanding unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0,            30, "Second fine increased after partial payment of first" );
    is( $fine2->amountoutstanding + 0, 30, "Second fine amountoutstanding increased after partial payment of first" );
    is( $fine->amount + $fine2->amount,                       '110', "Total fines = 100" );
    is( $fine->amountoutstanding + $fine2->amountoutstanding, '80',  "Total outstanding = 80" );

    # Total : Outstanding : MaxFine
    #  110  :     80      :   100

    # Fix fine 1 - First item renewed
    $fine->status('RETURNED')->store;

    # Add fine 3 - First item second overdue
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '30',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 3, "Third fine added for overdue renewal" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "First fine amount unchanged" );
    is( $fine->amountoutstanding + 0, 50, "First fine amountoutstanding unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0,            30, "Second fine amount unchanged" );
    is( $fine2->amountoutstanding + 0, 30, "Second fine amountoutstanding unchanged" );
    my $fine3 = $fines->next;
    is( $fine3->amount + 0,            20,                   "Third fine amount capped due to MaxFine" );
    is( $fine3->amountoutstanding + 0, 20,                   "Third fine amountoutstanding capped at '20' by MaxFine" );
    is( $fine3->issue_id,              $checkout1->issue_id, "Third fine is associated with the correct issue" );
    is( $fine3->itemnumber,            $checkout1->itemnumber,  "Third fine is associated with the correct item" );
    is( $fine->amount + $fine2->amount + $fine3->amount, '130', "Total fines = 130" );
    is(
        $fine->amountoutstanding + $fine2->amountoutstanding + $fine3->amountoutstanding, '100',
        "Total outstanding = 100"
    );

    # Total : Outstanding : MaxFine
    #  130  :     100     :   100

    # Payoff accruing fine and ensure next increment doesn't create a new one (bug #24146)
    $fine3->amountoutstanding('0')->store;
    is( $fine->amount + $fine2->amount + $fine3->amount, '130', "Total fines = 130" );
    is(
        $fine->amountoutstanding + $fine2->amountoutstanding + $fine3->amountoutstanding, '80',
        "Total outstanding = 80"
    );

    # Total : Outstanding : MaxFine
    #  130  :      80     :   100

    # Increase fine 3 - First item, second overdue increase
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '50',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 3, "Still three fines after third checkout update" );
    $fine = $fines->next;
    is( $fine->amount + 0,            80, "First fine amount unchanged" );
    is( $fine->amountoutstanding + 0, 50, "First fine amountoutstanding unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0,            30, "Second fine amount unchanged" );
    is( $fine2->amountoutstanding + 0, 30, "Second fine amountoutstanding unchanged" );
    $fine3 = $fines->next;
    is( $fine3->amount + 0,            40,                      "Third fine amount capped due to MaxFine" );
    is( $fine3->amountoutstanding + 0, 20,                      "Third fine amountoutstanding increased ..." );
    is( $fine3->issue_id,              $checkout1->issue_id,    "Third fine is associated with the correct issue" );
    is( $fine3->itemnumber,            $checkout1->itemnumber,  "Third fine is associated with the correct item" );
    is( $fine->amount + $fine2->amount + $fine3->amount, '150', "Total fines = 150" );
    is(
        $fine->amountoutstanding + $fine2->amountoutstanding + $fine3->amountoutstanding, '100',
        "Total outstanding = 100"
    );

    # Total : Outstanding : MaxFine
    #  150  :      100     :   100

    # FIXME: Add test to check whether sundry/manual charges are included within MaxFine.
    # FIXME: Add test to ensure other charges are not included within MaxFine.

    # Disable MaxFine
    t::lib::Mocks::mock_preference( 'MaxFine', '0' );
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '50',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 3, "Still only three fines after MaxFine cap removed" );
    $fine = $fines->next;
    is( $fine->amount + 0, 80, "First fine amount unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0, 30, "Second fine amount unchanged" );
    $fine3 = $fines->next;
    is( $fine3->amount + 0,            50, "Third fine increased now MaxFine cap is disabled" );
    is( $fine3->amountoutstanding + 0, 30, "Third fine increased now MaxFine cap is disabled" );

    # If somehow the fine should be reduced, we changed rules or checkout date or something
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '30',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 3, "Still only three fines after MaxFine cap removed and third fine altered" );
    $fine = $fines->next;
    is( $fine->amount + 0, 80, "First fine amount unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount + 0, 30, "Second fine amount unchanged" );
    $fine3 = $fines->next;
    is( $fine3->amount + 0,            30, "Third fine reduced" );
    is( $fine3->amountoutstanding + 0, 10, "Third fine amount outstanding is reduced" );

    # Ensure maxfine calculations work correctly for floats (bug #25127)
    # 7.2 (maxfine) - 7.2 (total_amount_other) != 8.88178419700125e-16 (😢)
    t::lib::Mocks::mock_preference( 'MaxFine', '7.2' );
    my $patron_1   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item_1     = $builder->build_sample_item();
    my $item_2     = $builder->build_sample_item();
    my $checkout_1 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber     => $item_1->itemnumber,
                borrowernumber => $patron_1->id
            }
        }
    );
    my $checkout_2 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber     => $item_2->itemnumber,
                borrowernumber => $patron->id
            }
        }
    );
    my $account = $patron_1->account;
    $account->add_debit(
        {
            type      => 'OVERDUE',
            amount    => '6.99',
            issue_id  => $checkout_1->issue_id,
            interface => 'TEST'
        }
    );
    $account->add_debit(
        {
            type      => 'OVERDUE',
            amount    => '.10',
            issue_id  => $checkout_1->issue_id,
            interface => 'TEST'
        }
    );
    $account->add_debit(
        {
            type      => 'OVERDUE',
            amount    => '.10',
            issue_id  => $checkout_1->issue_id,
            interface => 'TEST'
        }
    );
    $account->add_debit(
        {
            type      => 'OVERDUE',
            amount    => '.01',
            issue_id  => $checkout_1->issue_id,
            interface => 'TEST'
        }
    );
    UpdateFine(
        {
            issue_id       => $checkout_2->issue_id,
            itemnumber     => $item_2->itemnumber,
            borrowernumber => $patron_1->borrowernumber,
            amount         => '.1',
            due            => $checkout_2->date_due
        }
    );
    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron_1->borrowernumber },
        { order_by       => { '-asc' => 'accountlines_id' } }
    );
    is( $fines->count, 4, "New amount should be 0 so no fine added" );
    ok(
        C4::Circulation::AddReturn( $item_1->barcode, $item_1->homebranch, 1 ),
        "Returning the item and forgiving fines succeeds"
    );

    t::lib::Mocks::mock_preference( 'MaxFine', 0 );

    # Ensure CalcFine calculations work correctly for floats (bug #27079)
    # 1.800000 (amount from database) != 1.8~ (CalcFine of 0.15cents * 12units) (😢)
    my $amount = 0.15 * 12;
    UpdateFine(
        {
            issue_id       => $checkout_2->issue_id,
            itemnumber     => $item_2->itemnumber,
            borrowernumber => $patron_1->borrowernumber,
            amount         => $amount,
            due            => $checkout_2->date_due
        }
    );
    $fine = Koha::Account::Lines->search( { issue_id => $checkout_2->issue_id } )->single;
    ok( $fine, 'Fine added for checkout 2' );
    is( $fine->amount, "1.800000", "Fine amount is 1.800000 as expected" );

    $fine->amountoutstanding(0)->store;
    $fine->discard_changes;
    is( $fine->amountoutstanding + 0, 0, "Fine was paid off" );
    UpdateFine(
        {
            issue_id       => $checkout_2->issue_id,
            itemnumber     => $item_2->itemnumber,
            borrowernumber => $patron_1->borrowernumber,
            amount         => $amount,
            due            => $checkout_2->date_due
        }
    );
    my $refunds =
        Koha::Account::Lines->search( { itemnumber => $item_2->itemnumber, credit_type_code => 'OVERPAYMENT' } );
    is( $refunds->count, 0, "Overpayment refund not added when the amounts are equal" );

    # Adding an OVERDUE fine not linked with a checkout (possible with historical OVERDUE fines)
    $builder->build_object(
        {
            class => "Koha::Account::Lines",
            value => {
                borrowernumber  => $patron_1->borrowernumber,
                issue_id        => undef,
                debit_type_code => 'OVERDUE',
            }
        }
    );
    $fine->issue_id(undef)->store;
    warnings_are {
        UpdateFine(
            {
                issue_id       => $checkout_2->issue_id,
                itemnumber     => $item_2->itemnumber,
                borrowernumber => $patron_1->borrowernumber,
                amount         => $amount,
                due            => $checkout_2->date_due
            }
        );
    }
    [], 'No warning generated if fine is not linked with a checkout';

    $schema->storage->txn_rollback;
};
