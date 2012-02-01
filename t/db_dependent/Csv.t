#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
        use_ok('C4::Csv');
}

ok(C4::Csv::GetCsvProfiles(), 'test getting csv profiles');
is(C4::Csv::GetCsvProfile(),undef, 'test getting csv profiles');

ok(C4::Csv::GetCsvProfilesLoop(), 'test getting profile loop');
