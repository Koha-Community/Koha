#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 4;
use MARC::Record;

BEGIN {
        use_ok('C4::AuthoritiesMarc::MARC21');
}

my @result = C4::AuthoritiesMarc::MARC21::default_auth_type_location();
ok($result[0] eq '942', "testing default_auth_type_location has first value '942'");
ok($result[1] eq 'a', "testing default_auth_type_location has first value 'a'");

my $marc_record = MARC::Record->new();
is(C4::AuthoritiesMarc::MARC21::fix_marc21_auth_type_location($marc_record, '', ''), undef, "testing fix_marc21_auth_type_location returns undef with empty MARC record");
