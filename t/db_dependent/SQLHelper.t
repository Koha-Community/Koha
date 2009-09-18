#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Data::Dumper;

use C4::SQLHelper qw(:all);

use Test::More tests => 10;

BEGIN {
    use_ok('C4::SQLHelper');
}
use C4::Category;
use C4::Branch;
my @categories=C4::Category->all;
my $branches=C4::Branch->GetBranches;
my @branchcodes=keys %$branches;
my $borrid;
ok($borrid=InsertInTable("borrowers",{firstname=>"Jean",surname=>"Valjean",city=>" ",zipcode=>" ",email=>"email",categorycode=>$categories[0]->{categorycode}, branchcode=>$branchcodes[0]}),"Insert In Table");
ok(my $status=UpdateInTable("borrowers",{borrowernumber=>$borrid,firstname=>"Jean",surname=>"Valjean",city=>"ma6tVaCracker ",zipcode=>" ",email=>"email", branchcode=>$branchcodes[1]}),"Update In Table");
my $borrowers=SearchInTable("borrowers",{firstname=>"Jean"});
ok(@$borrowers>0, "Search In Table hashref");
my $borrowers=SearchInTable("borrowers","Jean");
ok(@$borrowers>0, "Search In Table string");
my $borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}]);
ok(@$borrowers>0, "Search In Table arrayref");
my $borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)]);
ok(keys %{$$borrowers[0]} ==1, "Search In Table columns out limit");
my $borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname surname title)]);
ok(@$borrowers>0, "Search In Table columns out limit");
my $borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname title)]);
ok(@$borrowers==0, "Search In Table columns filter firstname title limit Valjean not in other fields than surname ");
my $borrowers=SearchInTable("borrowers",["Val",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(surname)],"wide");
ok(@$borrowers>0, "Search In Table columns filter surname  Val on a wide search found ");
my $borrowers=SearchInTable("borrowers",["Val",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(surname)],"exact");
ok(@$borrowers==0, "Search In Table columns filter surname  Val in exact search not found ");
