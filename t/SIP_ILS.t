#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
        use FindBin;
        use lib "$FindBin::Bin/../C4/SIP";
        use_ok('C4::SIP::ILS');
}

