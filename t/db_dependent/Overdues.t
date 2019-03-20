#!/usr/bin/perl;

use Modern::Perl;
use Test::More tests => 17;

use C4::Context;
use Koha::Database;
use Koha::Libraries;

use t::lib::Mocks;
use t::lib::TestBuilder;

use_ok('C4::Overdues');
can_ok('C4::Overdues', 'GetOverdueMessageTransportTypes');
can_ok('C4::Overdues', 'GetBranchcodesWithOverdueRules');

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);
$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|DELETE FROM overduerules_transport_types|);

$dbh->do(q|
    INSERT INTO message_transport_types( message_transport_type ) VALUES ('email'), ('phone'), ('print'), ('sms')
|);

$dbh->do(q|
    INSERT INTO overduerules ( overduerules_id, branchcode, categorycode ) VALUES
    (1, 'CPL', 'PT'),
    (2, 'CPL', 'YA'),
    (3, '', 'PT'),
    (4, '', 'YA')
|);

$dbh->do(q|INSERT INTO overduerules_transport_types (overduerules_id, letternumber, message_transport_type) VALUES
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
|);

my $mtts;

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL', 'PT');
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no letternumber given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL', undef, 1);
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no categorycode given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL');
is( $mtts, undef, 'GetOverdueMessageTransportTypes: returns undef if no letternumber and categorycode given' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL', 'PT', 1);
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: first overdue is by email for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL', 'PT', 2);
is_deeply( $mtts, ['sms'], 'GetOverdueMessageTransportTypes: second overdue is by sms for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('CPL', 'PT', 3);
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: third overdue is by email for PT (CPL)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('', 'PT', 1);
is_deeply( $mtts, ['email'], 'GetOverdueMessageTransportTypes: first overdue is by email for PT (default)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('', 'PT', 2);
is_deeply( $mtts, ['email', 'sms'], 'GetOverdueMessageTransportTypes: second overdue is by email and sms for PT (default)' );

$mtts = C4::Overdues::GetOverdueMessageTransportTypes('', 'PT', 3);
is_deeply( $mtts, ['print', 'sms', 'email'], 'GetOverdueMessageTransportTypes: third overdue is by print, sms and email for PT (default). With print in first.' );

# Test GetBranchcodesWithOverdueRules
$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( '', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|);

my @branchcodes = map { $_->branchcode } Koha::Libraries->search;

my @overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( [ sort @overdue_branches ], [ sort @branchcodes ], 'If a default rule exists, all branches should be returned' );

$dbh->do(q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( [ sort @overdue_branches ], [ sort @branchcodes ], 'If a default rule exists and a specific rule exists, all branches should be returned' );

$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1', 1, 5, 'LETTER_CODE2', 1, 10, 'LETTER_CODE3', 1 )
|);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( \@overdue_branches, ['CPL'] , 'If only a specific rule exist, only 1 branch should be returned' );

$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|
    INSERT INTO overduerules
        ( branchcode,categorycode, delay1,letter1,debarred1, delay2,letter2,debarred2, delay3,letter3,debarred3 )
        VALUES
        ( 'CPL', '', 1, 'LETTER_CODE1_CPL', 1, 5, 'LETTER_CODE2_CPL', 1, 10, 'LETTER_CODE3_CPL', 1 ),
        ( 'MPL', '', 1, 'LETTER_CODE1_MPL', 1, 5, 'LETTER_CODE2_MPL', 1, 10, 'LETTER_CODE3_MPL', 1 )
|);

@overdue_branches = C4::Overdues::GetBranchcodesWithOverdueRules();
is_deeply( \@overdue_branches, ['CPL', 'MPL'] , 'If only 2 specific rules exist, 2 branches should be returned' );

$schema->storage->txn_rollback;

subtest 'UpdateFine tests' => sub {

    plan tests => 25;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'MaxFine', '100' );

    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item1     = $builder->build_sample_item();
    my $item2     = $builder->build_sample_item();
    my $checkout1 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item1->itemnumber }
        }
    );
    my $checkout2 = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => { itemnumber => $item2->itemnumber }
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

    my $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 0, "No fine added when amount is 0" );

    # Add fine 1
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
        { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 1, "Fine added when amount is greater than 0" );
    my $fine = $fines->next;
    is( $fine->amount, '50.000000', "Fine amount correctly set to 50" );
    is( $fine->issue_id, $checkout1->issue_id, "Fine is associated with the correct issue" );
    is( $fine->itemnumber, $checkout1->itemnumber, "Fine is associated with the correct item" );

    # Increase fine 1
    UpdateFine(
        {
            issue_id       => $checkout1->issue_id,
            itemnumber     => $item1->itemnumber,
            borrowernumber => $patron->borrowernumber,
            amount         => '80',
            due            => $checkout1->date_due
        }
    );

    $fines = Koha::Account::Lines->search(
        { borrowernumber => $patron->borrowernumber } );
    is( $fines->count, 1, "Existing fine updated" );
    $fine = $fines->next;
    is( $fine->amount, '80.000000', "Fine amount correctly updated to 80" );

    # Add fine 2
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
    is( $fines->count,        2,    "New fine added for second checkout" );
    $fine = $fines->next;
    is( $fine->amount, '80.000000', "First fine amount unchanged" );
    my $fine2 = $fines->next;
    is( $fine2->amount, '20.000000', "Second fine capped at '20' by MaxFine" );
    is( $fine2->issue_id, $checkout2->issue_id, "Second fine is associated with the correct issue" );
    is( $fine2->itemnumber, $checkout2->itemnumber, "Second fine is associated with the correct item" );

    # Partial pay fine 1
    $fine->amountoutstanding('50')->store;
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
    is( $fines->count,        2,    "Still two fines after second checkout update" );
    $fine = $fines->next;
    is( $fine->amount, '80.000000', "First fine amount unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount, '30.000000', "Second fine increased after partial payment of first" );

    # Fix fine 1, create third fine
    $fine->accounttype('F')->store;
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
    is( $fines->count,        3,    "Third fine added for overdue renewal" );
    $fine = $fines->next;
    is( $fine->amount, '80.000000', "First fine amount unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount, '30.000000', "Second fine amount unchanged" );
    my $fine3 = $fines->next;
    is( $fine3->amount, '20.000000', "Third fine amount capped due to MaxFine" );
    is( $fine3->issue_id, $checkout1->issue_id, "Third fine is associated with the correct issue" );
    is( $fine3->itemnumber, $checkout1->itemnumber, "Third fine is associated with the correct item" );

    # FIXME: Add test to check whether sundry/manual charges are included within MaxFine.
    # FIXME: Add test to ensure other charges are not included within MaxFine.

    # Disable MaxFine
    t::lib::Mocks::mock_preference( 'MaxFine', '0' );
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
    is( $fines->count,        3,    "Still only three fines after MaxFine cap removed" );
    $fine = $fines->next;
    is( $fine->amount, '80.000000', "First fine amount unchanged" );
    $fine2 = $fines->next;
    is( $fine2->amount, '30.000000', "Second fine amount unchanged" );
    $fine3 = $fines->next;
    is( $fine3->amount, '30.000000', "Third fine increased now MaxFine cap is disabled" );

    $schema->storage->txn_rollback;
};
