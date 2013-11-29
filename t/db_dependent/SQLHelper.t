#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Debug;
use C4::SQLHelper qw(:all);

use Test::More tests => 21;

use_ok('C4::SQLHelper');

use C4::Category;
use C4::Branch;
my @categories=C4::Category->all;
my $insert;
ok(($insert=InsertInTable("branches",{branchcode=>"ZZZZ",branchname=>"Brancheinconnue",city=>" ",zipcode=>" "},1))==0,"AddBranch (Insert In Table with primary key defined)");
my $branches=C4::Branch::GetBranches;
my @branchcodes=keys %$branches;
my ($borrid, $borrtmp);
ok($borrid=InsertInTable("borrowers",{firstname=>"Jean",surname=>"Valjean",city=>" ",zipcode=>" ",email=>"email",categorycode=>$categories[0]->{categorycode}, branchcode=>$branchcodes[0]}),"Insert In Table");
$borrtmp=InsertInTable("borrowers",{firstname=>"Jean",surname=>"cocteau",city=>" ",zipcode=>" ",email=>"email",categorycode=>$categories[0]->{categorycode}, branchcode=>$branchcodes[0]});
ok(my $status=UpdateInTable("borrowers",{borrowernumber=>$borrid,firstname=>"Jean",surname=>"Valjean",city=>"Dampierre",zipcode=>" ",email=>"email", branchcode=>$branchcodes[1]}),"Update In Table");
my $borrowers=SearchInTable("borrowers");
ok(@$borrowers>0, "Search In Table All values");
$borrowers=SearchInTable("borrowers",{borrowernumber=>$borrid});
ok(@$borrowers==1, "Search In Table by primary key on table");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"});
ok(@$borrowers>0, "Search In Table hashref");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"},[{firstname=>1},{borrowernumber=>1}],undef, [qw(borrowernumber)]);
ok(($$borrowers[0]{borrowernumber} + 0) > ($$borrowers[1]{borrowernumber} + 0), "Search In Table Order");
$borrowers=SearchInTable("borrowers",{firstname=>"Jean"},[{surname=>0},{firstname=>1}], undef, [qw(firstname surname)]);
ok(uc($$borrowers[0]{surname}) lt uc($$borrowers[1]{surname}), "Search In Table Order");
$borrowers=SearchInTable("borrowers","Jean");
ok(@$borrowers>0, "Search In Table string");
#FIXME : When searching on All the fields of the table, seems to return Junk
eval{$borrowers=SearchInTable("borrowers","Jean Valjean",undef,undef,undef,[qw(firstname surname borrowernumber cardnumber)],"start_with")};
#eval{$borrowers=SearchInTable("borrowers","Jean Valjean",undef,undef,undef,undef,"start_with")};
# This would not be much efficient because of "numbers" special treatment : We return stuff if empty or '' as soon as search is NOT exact
# This behaviour is implemented because of branchcode and numbers can be null
$debug && warn Dump(@$borrowers);
ok(scalar(@$borrowers)==1 && !($@), "Search In Table does an implicit AND of all the words in strings");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}]);
ok(@$borrowers>0, "Search In Table arrayref");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)]);
ok(keys %{$$borrowers[0]} ==1, "Search In Table columns out limit");
$borrowers=SearchInTable("borrowers",["Valjean",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname surname title)]);
ok(@$borrowers>0, "Search In Table columns out limit to borrowernumber AND filter firstname surname title");
$borrowers=SearchInTable("borrowers",["Val",{firstname=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(surname)],"start_with");
ok(@$borrowers>0, "Search In Table columns filter surname  Val on a wide search found ");
$borrowers=eval{SearchInTable("borrowers",["Val",{member=>"Jean"}],undef,undef,[qw(borrowernumber)],[qw(firstname title)],"exact")};
ok(@$borrowers==0 && !($@), "Search In Table fails gracefully when no correct field passed in hash");
$borrowers=eval{SearchInTable("borrowers",["Jea"],undef,undef,undef,[qw(firstname surname borrowernumber)],"start_with")};
ok(@$borrowers>0 && !($@), "Search on simple value in firstname");

$status=DeleteInTable("borrowers",{borrowernumber=>$borrid});
ok($status>0 && !($@), "DeleteInTable OK");
$status=DeleteInTable("borrowers",{borrowernumber=>$borrtmp});
ok($status>0 && !($@), "DeleteInTable OK");
$status=DeleteInTable("branches", {branchcode => 'ZZZZ'});
ok($status>0 && !($@), "DeleteInTable (branch) OK");

my @biblio_columns = C4::SQLHelper::GetColumns('biblio');
my @expected_columns = qw(biblionumber frameworkcode author title unititle notes
    serial seriestitle copyrightdate timestamp datecreated abstract);
is_deeply([sort @biblio_columns], [sort @expected_columns], "GetColumns('biblio') returns all columns of biblio table");
