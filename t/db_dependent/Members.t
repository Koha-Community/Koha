#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 34;
use Data::Dumper;
use C4::Context;

BEGIN {
        use_ok('C4::Members');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

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
    dateofbirth => '',
    dateexpiry => '9999-12-31',
    userid => 'tomasito'
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

is($member->{dateofbirth}, undef, "Empty dates handled correctly");

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

C4::Context->set_preference( 'CardnumberLength', '' );
C4::Context->clear_syspref_cache();

my $checkcardnum=C4::Members::checkcardnumber($CARDNUMBER, "");
is ($checkcardnum, "1", "Card No. in use");

$checkcardnum=C4::Members::checkcardnumber($IMPOSSIBLE_CARDNUMBER, "");
is ($checkcardnum, "0", "Card No. not used");

C4::Context->set_preference( 'CardnumberLength', '4' );
C4::Context->clear_syspref_cache();

$checkcardnum=C4::Members::checkcardnumber($IMPOSSIBLE_CARDNUMBER, "");
is ($checkcardnum, "2", "Card number is too long");

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

$notice_email = GetNoticeEmailAddress($member->{'borrowernumber'});
is ($notice_email, $EMAILPRO, "GetNoticeEmailAddress returns correct value when AutoEmailPrimaryAddress is emailpro");

ok(!$member->{is_expired}, "GetMemberDetails() indicates that patron is not expired");
ModMember(borrowernumber => $member->{'borrowernumber'}, dateexpiry => '2001-01-1');
$member = GetMemberDetails($member->{'borrowernumber'});
ok($member->{is_expired}, "GetMemberDetails() indicates that patron is expired");

# clean up 
DelMember($member->{borrowernumber});
$results = Search($CARDNUMBER,undef,undef,undef,["cardnumber"]);
ok (!_find_member($results), "Delete member")
  or diag("Card $CARDNUMBER found for the deleted member in the resultset: ".Dumper($results));

# Check_Userid tests
%data = (
    cardnumber   => "123456789",
    firstname    => "Tomasito",
    surname      => "None",
    categorycode => "S",
    branchcode   => "MPL",
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'tomasito'
);
# Add a new borrower
my $borrowernumber = AddMember( %data );
is( Check_Userid( 'tomasito', $borrowernumber ), 1,
    'recently created userid -> unique (borrowernumber passed)' );
is( Check_Userid( 'tomasitoxxx', $borrowernumber ), 1,
    'non-existent userid -> unique (borrowernumber passed)' );
is( Check_Userid( 'tomasito', '' ), 0,
    'userid exists (blank borrowernumber)' );
is( Check_Userid( 'tomasitoxxx', '' ), 1,
    'non-existent userid -> unique (blank borrowernumber)' );

# Add a new borrower with the same userid but different cardnumber
$data{ cardnumber } = "987654321";
my $new_borrowernumber = AddMember( %data );
is( Check_Userid( 'tomasito', '' ), 0,
    'userid not unique (blank borrowernumber)' );
is( Check_Userid( 'tomasito', $borrowernumber ), 0,
    'userid not unique (first borrowernumber passed)' );
is( Check_Userid( 'tomasito', $new_borrowernumber ), 0,
    'userid not unique (second borrowernumber passed)' );

# Regression tests for BZ12226
is( Check_Userid( C4::Context->config('user'), '' ), 0,
    'Check_Userid should return 0 for the DB user (Bug 12226)');

subtest 'GetMemberAccountBalance' => sub {

    plan tests => 10;

    my $members_mock = new Test::MockModule('C4::Members');
    $members_mock->mock( 'GetMemberAccountRecords', sub {
        my ($borrowernumber) = @_;
        if ($borrowernumber) {
            my @accountlines = (
            { amountoutstanding => '7', accounttype => 'Rent' },
            { amountoutstanding => '5', accounttype => 'Res' },
            { amountoutstanding => '3', accounttype => 'Pay' } );
            return ( 15, \@accountlines );
        }
        else {
            my @accountlines;
            return ( 0, \@accountlines );
        }
    });

    my $person = GetMemberDetails(undef,undef);
    ok( !$person , 'Expected no member details from undef,undef' );
    $person = GetMemberDetails(undef,'987654321');
    is( $person->{amountoutstanding}, 15,
        'Expected 15 outstanding for cardnumber.');
    $borrowernumber = $person->{borrowernumber};
    $person = GetMemberDetails($borrowernumber,undef);
    is( $person->{amountoutstanding}, 15,
        'Expected 15 outstanding for borrowernumber.');
    $person = GetMemberDetails($borrowernumber,'987654321');
    is( $person->{amountoutstanding}, 15,
        'Expected 15 outstanding for both borrowernumber and cardnumber.');

    # do not count holds charges
    C4::Context->set_preference( 'HoldsInNoissuesCharge', '1' );
    C4::Context->set_preference( 'ManInvInNoissuesCharge', '0' );
    my ($total, $total_minus_charges,
        $other_charges) = C4::Members::GetMemberAccountBalance(123);
    is( $total, 15 , "Total calculated correctly");
    is( $total_minus_charges, 15, "Holds charges are not count if HoldsInNoissuesCharge=1");
    is( $other_charges, 0, "Holds charges are not considered if HoldsInNoissuesCharge=1");

    C4::Context->set_preference( 'HoldsInNoissuesCharge', '0' );
    ($total, $total_minus_charges,
        $other_charges) = C4::Members::GetMemberAccountBalance(123);
    is( $total, 15 , "Total calculated correctly");
    is( $total_minus_charges, 10, "Holds charges are count if HoldsInNoissuesCharge=0");
    is( $other_charges, 5, "Holds charges are considered if HoldsInNoissuesCharge=1");

    $dbh->rollback();
};

sub _find_member {
    my ($resultset) = @_;
    my $found = $resultset && grep( { $_->{cardnumber} && $_->{cardnumber} eq $CARDNUMBER } @$resultset );
    return $found;
}

1;
