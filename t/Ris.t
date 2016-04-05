#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
        use_ok('C4::Ris');
}

is(C4::Ris::print_typetag(),undef,'test printing typetag');

is(C4::Ris::print_title(),undef, 'test printing title when print_title is nil');

is(C4::Ris::print_stitle(),undef, 'test printing info from series title field when its nil');
