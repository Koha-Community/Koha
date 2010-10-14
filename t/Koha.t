#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 2;

use_ok('C4::Koha');

#
# test that &slashifyDate returns correct (non-US) date
#
my $date = "01/01/2002";
my $newdate = &slashifyDate("2002-01-01");

ok($date eq $newdate, 'slashifyDate');
