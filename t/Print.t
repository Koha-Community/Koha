#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
        use_ok('C4::Print');
}
ok( !NetworkPrint(""));

