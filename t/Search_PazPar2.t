#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
        use_ok('C4::Search::PazPar2');
}

my $obj = C4::Search::PazPar2->new();
ok ($obj, "testing new works");
is ($obj->init(), "1", "testing init returns '1' when given no arguments");
is ($obj->search(), "1", "testing search returns '1' when given no arguments");
is ($obj->stat(), undef, "testing stat returns undef when given no arguments");
is ($obj->show(), undef, "testing show returns undef when given no arguments");
is ($obj->record(), undef, "testing record returns undef when given no arguments");
is ($obj->termlist(), undef, "testing termlist returns undef when given no arguments");
