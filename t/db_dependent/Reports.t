#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
        use_ok('C4::Reports');
}


ok(GetDelimiterChoices(),"Testing getting delimeter choices");  #Not testing the value of the output just that it returns something.
