#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 4;

BEGIN {
    use_ok( 'C4::ClassSortRoutine::Generic', qw( get_class_sort_key ) );
}

my $cn_class = "My class ";
my $cn_item  = " hellO";

my $cn_sort = C4::ClassSortRoutine::Generic::get_class_sort_key( $cn_class, $cn_item );

is( $cn_sort, "MY_CLASS_HELLO", "testing cnsort" );

$cn_sort = C4::ClassSortRoutine::Generic::get_class_sort_key( undef, undef );

is( $cn_sort, "", "Testing blank cnsort" );
