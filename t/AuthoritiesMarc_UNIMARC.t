#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
        use_ok('C4::AuthoritiesMarc::UNIMARC');
}

my @test = C4::AuthoritiesMarc::UNIMARC::default_auth_type_location();
ok(($test[0] == 152) && ($test[1] eq 'b'), "correct variables being returned");
