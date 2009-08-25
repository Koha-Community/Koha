#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Data::Dumper;

use C4::SQLHelper qw(:all);

use Test::More tests => 3;

BEGIN {
    use_ok('C4::SQLHelper');
}

my $borrid=InsertInTable("borrowers",{firstname=>"Jean",surname=>"Valjean",city=>" ",zipcode=>" ",email=>"email",categorycode=>"EL"});
my $status=UpdateInTable("borrowers",{borrowernumber=>$borrid,firstname=>"Jean",surname=>"Valjean",city=>"ma6tVaCracker ",zipcode=>" ",email=>"email"});
my $borrowers=SearchInTable("borrowers",{firstname=>"Jean"});
