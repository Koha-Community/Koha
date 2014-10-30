#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
        use_ok('C4::SIP::Sip');
}

my $date_time = C4::SIP::Sip::timestamp();
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format no param');

my $t = time();

$date_time = C4::SIP::Sip::timestamp($t);
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format secs');

$date_time = C4::SIP::Sip::timestamp('2011-01-12');
ok( $date_time eq '20110112    235900', 'Timestamp iso date string');

my $myChecksum = C4::SIP::Sip::Checksum::checksum("12345");
my $checker = 65281;
my $stringChecksum = C4::SIP::Sip::Checksum::checksum("teststring");
my $stringChecker = 64425;

is( $myChecksum, $checker, "Checksum: $myChecksum matches expected output");
is( $stringChecksum, $stringChecker, "Checksum: $stringChecksum matches expected output");

my $testdata = "abcdAZ";
my $something = C4::SIP::Sip::Checksum::checksum($testdata);

$something =  sprintf("%4X", $something);
ok( C4::SIP::Sip::Checksum::verify_cksum($testdata.$something), "Checksum: $something is valid.");

my $invalidTest;
warning_is { $invalidTest = C4::SIP::Sip::Checksum::verify_cksum("1234567") }
            'verify_cksum: no sum detected',
            'verify_cksum prints the expected warning for an invalid checksum';
is($invalidTest, 0, "Checksum: 1234567 is invalid as expected");
