#!/usr/bin/perl;

use Modern::Perl;
use Test::More tests => 16;

use C4::Context;
use C4::Branch;
use_ok('C4::Overdues');
can_ok('C4::Overdues', 'GetOverdueMessageTransportTypes');
can_ok('C4::Overdues', 'GetBranchcodesWithOverdueRules');

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

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

my $all_branches = C4::Branch::GetBranches;
my @branchcodes = keys %$all_branches;

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
