#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 3;

BEGIN {
    use_ok( 'C4::AuthoritiesMarc::UNIMARC', qw( default_auth_type_location ) );
}

my @test = C4::AuthoritiesMarc::UNIMARC::default_auth_type_location();
ok( ( $test[0] == 152 ) && ( $test[1] eq 'b' ), "correct variables being returned" );
