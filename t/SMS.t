#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::SMS');
}


my $driver = 'my mock driver';
t::lib::Mocks::mock_preference('SMSSendDriver', $driver);
is( C4::SMS->driver(), $driver, 'driver returns the SMSSendDriver correctly' );


my $send_sms = C4::SMS->send_sms();
is( $send_sms, undef, 'send_sms without arguments returns undef' );

$send_sms = C4::SMS->send_sms({
    destination => 'my destination',
});
is( $send_sms, undef, 'send_sms without message returns undef' );

$send_sms = C4::SMS->send_sms({
    message => 'my message',
});
is( $send_sms, undef, 'send_sms without destination returns undef' );

$send_sms = C4::SMS->send_sms({
    destination => 'my destination',
    message => 'my message',
    driver => '',
});
is( $send_sms, undef, 'send_sms with an undef driver returns undef' );

$send_sms = C4::SMS->send_sms({
    destination => '+33123456789',
    message => 'my message',
    driver => 'Test',
});
is( $send_sms, 1, 'send_sms returns 1' );
