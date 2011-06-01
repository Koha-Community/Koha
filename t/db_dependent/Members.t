#!/usr/bin/perl
#
# This is to test C4/Members
# It requires a working Koha database with the sample data

use strict;
use warnings;

use Test::More tests => 15;

BEGIN {
        use_ok('C4::Members');
}


# Make a borrower for testing
my $data = { cardnumber => 'TESTCARD01',
    firstname => 'Marie',
    surname => 'Mcknight',
    categorycode => 'S',
    branchcode => 's'
    };

my $addmem=AddMember(%$data);


my $member=GetMemberDetails("","TESTCARD01");
is ($member->{firstname}, "Marie", "Got member");

$member->{firstname}="Claire";
ModMember(%$member);
my $changedmember=GetMemberDetails("","TESTCARD01");
is ($changedmember->{firstname}, "Claire", "Member Changed");

$member->{firstname}="Marie";
ModMember(%$member);
$changedmember=GetMemberDetails("","TESTCARD01");
is ($changedmember->{firstname}, "Marie", "Member Returned");

$member->{email}="Marie\@email.com";
ModMember(%$member);
$changedmember=GetMemberDetails("","TESTCARD01");
is ($changedmember->{email}, "Marie\@email.com", "Email Set works");

$member->{ethnicity}="German";
ModMember(%$member);
$changedmember=GetMemberDetails("","TESTCARD01");
is ($changedmember->{ethnicity}, "German", "Ethnicity Works");

my @searchstring=("Mcknight");
my ($results) = Search(\@searchstring,undef,undef,undef,["surname"]);
is ($results->[0]->{surname}, "Mcknight", "Surname Search works");

$member->{phone}="555-12123";
ModMember(%$member);

@searchstring=("555-12123");
($results) = Search(\@searchstring,undef,undef,undef,["phone"]);
is ($results->[0]->{phone}, "555-12123", "phone Search works");

my $checkcardnum=C4::Members::checkcardnumber("TESTCARD01", "");
is ($checkcardnum, "1", "Card No. in use");

$checkcardnum=C4::Members::checkcardnumber("67", "");
is ($checkcardnum, "0", "Card No. not used");

my $age=GetAge("1992-08-14", "2011-01-19");
is ($age, "18", "Age correct");

$age=GetAge("2011-01-19", "1992-01-19");
is ($age, "-19", "Birthday In the Future");

my $sortdet=C4::Members::GetSortDetails("lost", "3");
is ($sortdet, "Lost and Paid For", "lost and paid works");

my $sortdet2=C4::Members::GetSortDetails("loc", "child");
is ($sortdet2, "Children's Area", "Child area works");

my $sortdet3=C4::Members::GetSortDetails("withdrawn", "1");
is ($sortdet3, "Withdrawn", "Withdrawn works");

# clean up 
DelMember($member->{borrowernumber});
