#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 10;

BEGIN {
        use_ok('C4::ClassSortRoutine::Dewey');
}

my $cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key(undef, undef );
is($cn_sort,"","testing whitespace");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("....",".....");
is($cn_sort,"","testing fullstops");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("123","456");
is($cn_sort,"123_456000000000000","testing numbers");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("abc123","456");
is($cn_sort,"ABC_123_456000000000000","testing alphanumeric");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("ab         c123","45   6");
is($cn_sort,"AB_C123_45_600000000000000","testing middle whitespace");

$cn_sort     = C4::ClassSortRoutine::Dewey::get_class_sort_key("YR DVD 800.1","");
my $cn_sort2 = C4::ClassSortRoutine::Dewey::get_class_sort_key("YR DVD 900","");
ok( $cn_sort lt $cn_sort2, "testing prefix plus decimal" );

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("971/P23w/v.1-2/pt.8","");
is($cn_sort,"971_000000000000000_P23W_V_12_PT_8", "Test 1 for bug 8836");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("971.01 P23w v.1-2 pt.6-7","");
is($cn_sort,"971_010000000000000_P23W_V_12_PT_67", "Test 2 for bug 8836");

$cn_sort = C4::ClassSortRoutine::Dewey::get_class_sort_key("971.01 P23w v.1-2 pt.7","");
is($cn_sort,"971_010000000000000_P23W_V_12_PT_7", "Test 3 for bug 8836");
