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

use t::lib::Mocks;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::SMS');
}


my $driver = 'my mock driver';
t::lib::Mocks::mock_preference('SMSSendDriver', $driver);
is( C4::SMS->driver(), $driver, 'driver returns the SMSSendDriver correctly' );

t::lib::Mocks::mock_preference('SMSSendUsername', 'username');
t::lib::Mocks::mock_preference('SMSSendPassword', 'pwd');

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

1;
