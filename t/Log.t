#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
        use_ok('C4::Log');
}

ok( my $hash=GetLogStatus(),"Testing GetLogStatus");

ok( $hash->{BorrowersLog}, 'Testing hash is non empty');
