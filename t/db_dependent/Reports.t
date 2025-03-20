#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 3;

BEGIN {
    use_ok( 'C4::Reports', qw( GetDelimiterChoices ) );
}

ok( GetDelimiterChoices(), "Testing getting delimiter choices" )
    ;    #Not testing the value of the output just that it returns something.
