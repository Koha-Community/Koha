#!/usr/bin/perl;

use Modern::Perl;
use Test::More;# tests => 3;

use C4::Context;
use_ok('C4::Overdues');
can_ok('C4::Overdues', 'GetOverdueMessageTransportTypes');

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
    INSERT INTO overduerules ( branchcode, categorycode ) VALUES
    ('CPL', 'PT'),
    ('CPL', 'YA'),
    ('', 'PT'),
    ('', 'YA')
|);

$dbh->do(q|
    INSERT INTO overduerules_transport_types( branchcode, categorycode, letternumber, message_transport_type ) VALUES
    ('CPL', 'PT', 1, 'email'),
    ('CPL', 'PT', 2, 'sms'),
    ('CPL', 'PT', 3, 'email'),
    ('CPL', 'YA', 3, 'print'),
    ('', 'PT', 1, 'email'),
    ('', 'PT', 2, 'email'),
    ('', 'PT', 2, 'sms'),
    ('', 'PT', 3, 'sms'),
    ('', 'PT', 3, 'email'),
    ('', 'PT', 3, 'print'),
    ('', 'YA', 2, 'sms')
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


done_testing;
