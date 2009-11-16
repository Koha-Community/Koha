#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Debug;
use C4::SQLHelper qw(:all);

use Test::More tests => 18;

#1
BEGIN {
    use_ok('C4::SQLHelper');
}
use C4::Category;
use C4::Branch;
my @categories=C4::Category->all;
my $branches=C4::Branch->GetBranches;
my @branchcodes=keys %$branches;
my ($borrid, $borrtmp);
ok($borrid=InsertInTable("borrowers",{firstname=>"Jean",surname=>"Valjean",city=>" ",zipcode=>" ",email=>"email",categorycode=>$categories[0]->{categorycode}, branchcode=>$branchcodes[0]}),"Insert In Table");
$borrtmp=InsertInTable("borrowers",{firstname=>"Jean",surname=>"cocteau",city=>" ",zipcode=>" ",email=>"email",categorycode=>$categories[0]->{categorycode}, branchcode=>$branchcodes[0]});
ok(my $status=UpdateInTable("borrowers",{borrowernumber=>$borrid,firstname=>"Jean",surname=>"Valjean",city=>"Dampierre",zipcode=>" ",email=>"email", branchcode=>$branchcodes[1]}),"Update In Table");
my $borrowers=SearchInTable("borrowers");
#4
ok(@$borrowers>0, "Search In Table All values");
$borrowers=SearchInTable("borrowers",{borrowernumber=>$borrid});
#5
ok(@$borrowers==1, "Search In Table by primary key on table");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"});
#6
ok(@$borrowers>0, "Search In Table hashref");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"},[{firstname=>1},{borrowernumber=>1}],undef, [qw(borrowernumber)]);
ok(($$borrowers[0]{borrowernumber} + 0) > ($$borrowers[1]{borrowernumber} + 0), "Search In Table Order");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"},[{surname=>0},{firstname=>1}], undef, [qw(firstname surname)]);
ok(uc($$borrowers[0]{surname}) lt uc($$borrowers[1]{surname}), "Search In Table Order");
$borrowers=SearchInTable("borrowers","Jean");
#7
ok(@$borrowers>0, "Search In Table string");
eval{$borrowers=SearchInTable("borrowers","Jean Valjean")};
#8
ok(scalar(@$borrowers)==1 && !($@), "Search In Table does an implicit AND of all the words in strings");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}]);
#9
ok(@$borrowers>0, "Search In Table arrayref");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)]);
#10
ok(keys %{$$borrowers[0]} ==1, "Search In Table columns out limit");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname surname title)]);
#11
ok(@$borrowers>0, "Search In Table columns out limit to borrowernumber AND filter firstname surname title");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname title)]);
#12
ok(@$borrowers==0, "Search In Table columns filter firstname title limit Valjean not in other fields than surname ");
$borrowers=SearchInTable("borrowers",["Val",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(surname)],"start_with");
#13
ok(@$borrowers>0, "Search In Table columns filter surname  Val on a wide search found ");
$borrowers=SearchInTable("borrowers",["Val",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(surname)],"exact");
#14
ok(@$borrowers==0, "Search In Table columns filter surname  Val in exact search not found ");
$borrowers=eval{SearchInTable("borrowers",["Val",{member=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname title)],"exact")};
#15
ok(@$borrowers==0 && !($@), "Search In Table fails gracefully when no correct field passed in hash");
$borrowers=eval{SearchInTable("borrowers",["Jean"],undef,undef,undef,[qw(firstname surname borrowernumber)],"start_with")};
ok(@$borrowers==0 && !($@), "Search In Table fails gracefully when no correct field passed in hash");

$status=DeleteInTable("borrowers",{borrowernumber=>$borrid});
#16
ok($status>0 && !($@), "DeleteInTable OK");
$status=DeleteInTable("borrowers",{borrowernumber=>$borrtmp});
