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

use Test::NoWarnings;
use Test::More tests => 11;
use Test::Warn;

BEGIN {
    use_ok( 'C4::SIP::Sip', qw( timestamp ) );
}

my $date_time = C4::SIP::Sip::timestamp();
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format no param' );

my $t = time();

$date_time = C4::SIP::Sip::timestamp($t);
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format secs' );

$date_time = C4::SIP::Sip::timestamp('2011-01-12');
ok( $date_time eq '20110112    235900', 'Timestamp iso date string' );

my $myChecksum     = C4::SIP::Sip::Checksum::checksum("12345");
my $checker        = 65281;
my $stringChecksum = C4::SIP::Sip::Checksum::checksum("teststring");
my $stringChecker  = 64425;

is( $myChecksum,     $checker,       "Checksum: $myChecksum matches expected output" );
is( $stringChecksum, $stringChecker, "Checksum: $stringChecksum matches expected output" );

my $testdata  = "abcdAZ";
my $something = C4::SIP::Sip::Checksum::checksum($testdata);

$something = sprintf( "%4X", $something );
ok( C4::SIP::Sip::Checksum::verify_cksum( $testdata . $something ), "Checksum: $something is valid." );

my $invalidTest;
warning_is { $invalidTest = C4::SIP::Sip::Checksum::verify_cksum("1234567") }
'verify_cksum: no sum detected',
    'verify_cksum prints the expected warning for an invalid checksum';
is( $invalidTest, 0, "Checksum: 1234567 is invalid as expected" );

subtest 'remove_password_from_message' => sub {
    plan tests => 9;

    is(
        C4::SIP::Sip::remove_password_from_message("INPUT MSG: '9300CNterm1|COterm1|CPCPL|'"),
        "INPUT MSG: '9300CNterm1|CO***|CPCPL|'", "93 Login - password"
    );

    is(
        C4::SIP::Sip::remove_password_from_message("INPUT MSG: '9300CNterm1|COt|CPCPL|'"),
        "INPUT MSG: '9300CNterm1|CO***|CPCPL|'", "93 Login - short password"
    );

    is(
        C4::SIP::Sip::remove_password_from_message("INPUT MSG: '9300CNterm1|CO%&/()=+qwerty123456|CPCPL|'"),
        "INPUT MSG: '9300CNterm1|CO***|CPCPL|'", "93 Login - Complex password"
    );

    is(
        C4::SIP::Sip::remove_password_from_message("INPUT MSG: '9300CNterm1|CO1234|CPCPL|'"),
        "INPUT MSG: '9300CNterm1|CO***|CPCPL|'", "93 Login - PIN"
    );

    is(
        C4::SIP::Sip::remove_password_from_message(
            "11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC1234|AD1234|BON"),
        '11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC***|AD***|BON',
        "11 Checkout"
    );

    is(
        C4::SIP::Sip::remove_password_from_message(
            "11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC12|34|AD1234|BON"),
        '11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC***|34|AD***|BON',
        "11 Checkout with pipe in password"
    );

    is(
        C4::SIP::Sip::remove_password_from_message(
            "11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC|AD1234|BON"),
        '11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC***|AD***|BON',
        "11 Checkout - empty AC"
    );

    is(
        C4::SIP::Sip::remove_password_from_message(
            "11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC1234|AD|BON"),
        '11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC***|AD***|BON',
        "11 Checkout - empty AD"
    );

    is(
        C4::SIP::Sip::remove_password_from_message(
            "11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC|AD|BON"),
        '11YN20240903    134450                  AOCPL|AA23529000035676|AB39999000003697|AC***|AD***|BON',
        "11 Checkout - empty AC and AND"
    );
};
