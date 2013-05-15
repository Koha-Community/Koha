#!/usr/bin/perl
#
# This is to test C4/Members
# It requires a working Koha database with the sample data

use strict;
use warnings;

use Test::More tests => 22;
use Data::Dumper;

BEGIN {
        use_ok('C4::Members');
}


my $CARDNUMBER   = 'TESTCARD01';
my $FIRSTNAME    = 'Marie';
my $SURNAME      = 'Mcknight';
my $CATEGORYCODE = 'S';
my $BRANCHCODE   = 'CPL';

my $CHANGED_FIRSTNAME = "Marry Ann";
my $EMAIL             = "Marie\@email.com";
my $EMAILPRO          = "Marie\@work.com";
my $ETHNICITY         = "German";
my $PHONE             = "555-12123";

# XXX should be randomised and checked against the database
my $IMPOSSIBLE_CARDNUMBER = "XYZZZ999";

my $INDEPENDENT_BRANCHES_PREF = 'IndependentBranches';

# XXX make a non-commit transaction and rollback rather than insert/delete

#my ($usernum, $userid, $usercnum, $userfirstname, $usersurname, $userbranch, $branchname, $userflags, $emailaddress, $branchprinter)= @_;
my @USERENV = (
    1,
    'test',
    'MASTERTEST',
    'Test',
    'Test',
    't',
    'Test',
    0,
);
my $BRANCH_IDX = 4;

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv ( @USERENV );

my $userenv = C4::Context->userenv
  or BAIL_OUT("No userenv");

# Make a borrower for testing
my %data = (
    cardnumber => $CARDNUMBER,
    firstname =>  $FIRSTNAME,
    surname => $SURNAME,
    categorycode => $CATEGORYCODE,
    branchcode => $BRANCHCODE,
);

my $addmem=AddMember(%data);
ok($addmem, "AddMember()");

my $member=GetMemberDetails("",$CARDNUMBER)
  or BAIL_OUT("Cannot read member with card $CARDNUMBER");

ok ( $member->{firstname}    eq $FIRSTNAME    &&
     $member->{surname}      eq $SURNAME      &&
     $member->{categorycode} eq $CATEGORYCODE &&
     $member->{branchcode}   eq $BRANCHCODE
     , "Got member")
  or diag("Mismatching member details: ".Dumper(\%data, $member));

$member->{firstname} = $CHANGED_FIRSTNAME;
$member->{email}     = $EMAIL;
$member->{ethnicity} = $ETHNICITY;
$member->{phone}     = $PHONE;
$member->{emailpro}  = $EMAILPRO;
ModMember(%$member);
my $changedmember=GetMemberDetails("",$CARDNUMBER);
ok ( $changedmember->{firstname} eq $CHANGED_FIRSTNAME &&
     $changedmember->{email}     eq $EMAIL             &&
     $changedmember->{ethnicity} eq $ETHNICITY         &&
     $changedmember->{phone}     eq $PHONE             &&
     $changedmember->{emailpro}  eq $EMAILPRO
     , "Member Changed")
  or diag("Mismatching member details: ".Dumper($member, $changedmember));

C4::Context->set_preference( $INDEPENDENT_BRANCHES_PREF, '0' );
C4::Context->clear_syspref_cache();

my $results = Search($CARDNUMBER);
ok (@$results == 1, "Search cardnumber returned only one result")
  or diag("Multiple members with Card $CARDNUMBER: ".Dumper($results));
ok (_find_member($results), "Search cardnumber")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

my @searchstring=($SURNAME);
$results = Search(\@searchstring);
ok (_find_member($results), "Search (arrayref)")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

$results = Search(\@searchstring,undef,undef,undef,["surname"]);
ok (_find_member($results), "Surname Search (arrayref)")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

$results = Search("$CHANGED_FIRSTNAME $SURNAME", "surname");
ok (_find_member($results), "Full name  Search (string)")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

@searchstring=($PHONE);
$results = Search(\@searchstring,undef,undef,undef,["phone"]);
ok (_find_member($results), "Phone Search (arrayref)")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

$results = Search($PHONE,undef,undef,undef,["phone"]);
ok (_find_member($results), "Phone Search (string)")
  or diag("Card $CARDNUMBER not found in the resultset: ".Dumper($results));

C4::Context->set_preference( $INDEPENDENT_BRANCHES_PREF, '1' );
C4::Context->clear_syspref_cache();

$results = Search("$CHANGED_FIRSTNAME $SURNAME", "surname");
ok (!_find_member($results), "Full name  Search (string) for independent branches, different branch")
  or diag("Card $CARDNUMBER found in the resultset for independent branches: ".Dumper(C4::Context->preference($INDEPENDENT_BRANCHES_PREF), $results));

@searchstring=($SURNAME);
$results = Search(\@searchstring);
ok (!_find_member($results), "Search (arrayref) for independent branches, different branch")
  or diag("Card $CARDNUMBER found in the resultset for independent branches: ".Dumper(C4::Context->preference($INDEPENDENT_BRANCHES_PREF), $results));

$USERENV[$BRANCH_IDX] = $BRANCHCODE;
C4::Context->set_userenv ( @USERENV );

$results = Search("$CHANGED_FIRSTNAME $SURNAME", "surname");
ok (_find_member($results), "Full name  Search (string) for independent branches, same branch")
  or diag("Card $CARDNUMBER not found in the resultset for independent branches: ".Dumper(C4::Context->preference($INDEPENDENT_BRANCHES_PREF), $results));

@searchstring=($SURNAME);
$results = Search(\@searchstring);
ok (_find_member($results), "Search (arrayref) for independent branches, same branch")
  or diag("Card $CARDNUMBER not found in the resultset for independent branches: ".Dumper(C4::Context->preference($INDEPENDENT_BRANCHES_PREF), $results));


my $checkcardnum=C4::Members::checkcardnumber($CARDNUMBER, "");
is ($checkcardnum, "1", "Card No. in use");

$checkcardnum=C4::Members::checkcardnumber($IMPOSSIBLE_CARDNUMBER, "");
is ($checkcardnum, "0", "Card No. not used");

my $age=GetAge("1992-08-14", "2011-01-19");
is ($age, "18", "Age correct");

$age=GetAge("2011-01-19", "1992-01-19");
is ($age, "-19", "Birthday In the Future");

C4::Context->set_preference( 'AutoEmailPrimaryAddress', 'OFF' );
C4::Context->clear_syspref_cache();

my $notice_email = GetNoticeEmailAddress($member->{'borrowernumber'});
is ($notice_email, $EMAIL, "GetNoticeEmailAddress returns correct value when AutoEmailPrimaryAddress is off");

C4::Context->set_preference( 'AutoEmailPrimaryAddress', 'emailpro' );
C4::Context->clear_syspref_cache();

my $notice_email = GetNoticeEmailAddress($member->{'borrowernumber'});
is ($notice_email, $EMAILPRO, "GetNoticeEmailAddress returns correct value when AutoEmailPrimaryAddress is emailpro");


# clean up 
DelMember($member->{borrowernumber});
$results = Search($CARDNUMBER,undef,undef,undef,["cardnumber"]);
ok (!_find_member($results), "Delete member")
  or diag("Card $CARDNUMBER found for the deleted member in the resultset: ".Dumper($results));


exit;

sub _find_member {
    my ($resultset) = @_;
    my $found = $resultset && grep( { $_->{cardnumber} && $_->{cardnumber} eq $CARDNUMBER } @$resultset );
    return $found;
}
