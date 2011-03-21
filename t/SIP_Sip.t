#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 4;

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

