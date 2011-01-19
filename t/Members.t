#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use Test::Class::Load qw(t/);

use Test::More tests => 15;

BEGIN {
        use_ok('C4::Members');
}

#KohaTest::clear_test_database();
#KohaTest::create_test_database();

#my %data;
#$data{cardnumber}=51;
#my $addmem=AddMember(%data);
#warn $addmem;

my $member=GetMemberDetails("","23529000878885");
is ($member->{firstname}, "Marie", "Got member");

$member->{firstname}="Claire";
ModMember(%$member);
my $changedmember=GetMemberDetails("","23529000878885");
is ($changedmember->{firstname}, "Claire", "Member Changed");

$member->{firstname}="Marie";
ModMember(%$member);
my $changedmember=GetMemberDetails("","23529000878885");
is ($changedmember->{firstname}, "Marie", "Membered Returned");

$member->{email}="Marie\@email.com";
ModMember(%$member);
my $searchemail=Search($member);
is ($member->{email}, "Marie\@email.com", "Email search works");

$member->{ethnicity}="German";
ModMember(%$member);
my $searcheth=Search($member);
is ($member->{ethnicity}, "German", "Ethnicity Works");

my @searchstring=("Mcknight");
my ($results) = Search(\@searchstring,undef,undef,undef,["surname"]);
is ($results->[0]->{surname}, "Mcknight", "Surname Search works");

$member->{phone}="555-12123";
ModMember(%$member);

my @searchstring=("555-12123");
my ($results) = Search(\@searchstring,undef,undef,undef,["phone"]);
is ($results->[0]->{phone}, "555-12123", "phone Search works");

my $checkcardnum=C4::Members::checkcardnumber("23529000878885", "");
is ($checkcardnum, "1", "Card No. in use");

my $checkcardnum=C4::Members::checkcardnumber("67", "");
is ($checkcardnum, "0", "Card No. not used");

my $age=GetAge("1992-08-14", "2011-01-19");
is ($age, "18", "Age correct");

my $age=GetAge("2011-01-19", "1992-01-19");
is ($age, "-19", "Birthday In the Future");

my $sortdet=C4::Members::GetSortDetails("lost", "3");
is ($sortdet, "Lost and Paid For", "lost and paid works");

my $sortdet2=C4::Members::GetSortDetails("loc", "child");
is ($sortdet2, "Children's Area", "Child area works");

my $sortdet3=C4::Members::GetSortDetails("withdrawn", "1");
is ($sortdet3, "Withdrawn", "Withdrawn works");


