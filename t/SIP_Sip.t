#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
        use FindBin;
        use lib "$FindBin::Bin/../C4/SIP";
        use_ok('C4::SIP::Sip');
}

my $date_time = Sip::timestamp();
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format no param');

my $t = time();

$date_time = Sip::timestamp($t);
like( $date_time, qr/^\d{8}    \d{6}$/, 'Timestamp format secs');

$date_time = Sip::timestamp('2011-01-12');
ok( $date_time eq '20110112    235900', 'Timestamp iso date string');

my $myChecksum = Sip::Checksum::checksum("12345");
my $checker = 65281;
my $stringChecksum = Sip::Checksum::checksum("teststring");
my $stringChecker = 64425;

is( $myChecksum, $checker, "Checksum: $myChecksum matches expected output");
is( $stringChecksum, $stringChecker, "Checksum: $stringChecksum matches expected output");

my $testdata = "abcdAZ";
my $something = Sip::Checksum::checksum($testdata);

$something =  sprintf("%4X", $something);
ok( Sip::Checksum::verify_cksum($testdata.$something), "Checksum: $something is valid.");

my $invalidTest = Sip::Checksum::verify_cksum("1234567");
is($invalidTest, 0, "Checksum: 1234567 is invalid as expected");
