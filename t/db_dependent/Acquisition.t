#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
        use_ok('C4::Acquisition');
}

my ($basket, $basketno);
ok($basketno = NewBasket(1,1),			"NewBasket(  1 , 1  ) returns $basketno");
ok($basket   = GetBasket($basketno),	"GetBasket($basketno) returns $basket");

