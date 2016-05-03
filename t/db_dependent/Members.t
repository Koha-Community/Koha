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

use Test::More tests => 77;
use Test::MockModule;
use Data::Dumper;
use C4::Context;
use Koha::Database;
use Koha::List::Patron;


use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
        use_ok('C4::Members');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $CARDNUMBER   = 'TESTCARD01';
my $FIRSTNAME    = 'Marie';
my $SURNAME      = 'Mcknight';
my $CATEGORYCODE = 'S';
my $BRANCHCODE   = $library1->{branchcode};

my $CHANGED_FIRSTNAME = "Marry Ann";
my $EMAIL             = "Marie\@email.com";
my $EMAILPRO          = "Marie\@work.com";
my $PHONE             = "555-12123";

# XXX should be randomised and checked against the database
my $IMPOSSIBLE_CARDNUMBER = "XYZZZ999";

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
my $BRANCH_IDX = 5;

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

testAgeAccessors(\%data); #Age accessor tests don't touch the db so it is safe to run them with just the object.

my $addmem=AddMember(%data);
ok($addmem, "AddMember()");

# It's not really a Move, it's a Copy.
my $result = MoveMemberToDeleted($addmem);
ok($result,"MoveMemberToDeleted()");

my $sth = $dbh->prepare("SELECT * from borrowers WHERE borrowernumber=?");
$sth->execute($addmem);
my $MemberAdded = $sth->fetchrow_hashref;

$sth = $dbh->prepare("SELECT * from deletedborrowers WHERE borrowernumber=?");
$sth->execute($addmem);
my $MemberMoved = $sth->fetchrow_hashref;

is_deeply($MemberMoved,$MemberAdded,"Confirm MoveMemberToDeleted.");

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
$member->{phone}     = $PHONE;
$member->{emailpro}  = $EMAILPRO;
ModMember(%$member);
my $changedmember=GetMemberDetails("",$CARDNUMBER);
ok ( $changedmember->{firstname} eq $CHANGED_FIRSTNAME &&
     $changedmember->{email}     eq $EMAIL             &&
     $changedmember->{phone}     eq $PHONE             &&
     $changedmember->{emailpro}  eq $EMAILPRO
     , "Member Changed")
  or diag("Mismatching member details: ".Dumper($member, $changedmember));

t::lib::Mocks::mock_preference( 'CardnumberLength', '' );
C4::Context->clear_syspref_cache();

my $checkcardnum=C4::Members::checkcardnumber($CARDNUMBER, "");
is ($checkcardnum, "1", "Card No. in use");

$checkcardnum=C4::Members::checkcardnumber($IMPOSSIBLE_CARDNUMBER, "");
is ($checkcardnum, "0", "Card No. not used");

t::lib::Mocks::mock_preference( 'CardnumberLength', '4' );
C4::Context->clear_syspref_cache();

$checkcardnum=C4::Members::checkcardnumber($IMPOSSIBLE_CARDNUMBER, "");
is ($checkcardnum, "2", "Card number is too long");



t::lib::Mocks::mock_preference( 'AutoEmailPrimaryAddress', 'OFF' );
C4::Context->clear_syspref_cache();

my $notice_email = GetNoticeEmailAddress($member->{'borrowernumber'});
is ($notice_email, $EMAIL, "GetNoticeEmailAddress returns correct value when AutoEmailPrimaryAddress is off");

t::lib::Mocks::mock_preference( 'AutoEmailPrimaryAddress', 'emailpro' );
C4::Context->clear_syspref_cache();

$notice_email = GetNoticeEmailAddress($member->{'borrowernumber'});
is ($notice_email, $EMAILPRO, "GetNoticeEmailAddress returns correct value when AutoEmailPrimaryAddress is emailpro");

ok(!$member->{is_expired}, "GetMemberDetails() indicates that patron is not expired");
ModMember(borrowernumber => $member->{'borrowernumber'}, dateexpiry => '2001-01-1');
$member = GetMemberDetails($member->{'borrowernumber'});
ok($member->{is_expired}, "GetMemberDetails() indicates that patron is expired");

# clean up 
DelMember($member->{borrowernumber});
my $borrower = GetMember( cardnumber => $CARDNUMBER );
is( $borrower, undef, 'DelMember should remove the patron' );

# Check_Userid tests
%data = (
    cardnumber   => "123456789",
    firstname    => "Tomasito",
    surname      => "None",
    categorycode => "S",
    branchcode   => $library2->{branchcode},
    dateofbirth  => '',
    debarred     => '',
    dateexpiry   => '',
    dateenrolled => '',
);
# Add a new borrower
my $borrowernumber = AddMember( %data );
is( Check_Userid( 'tomasito.non', $borrowernumber ), 1,
    'recently created userid -> unique (borrowernumber passed)' );
is( Check_Userid( 'tomasitoxxx', $borrowernumber ), 1,
    'non-existent userid -> unique (borrowernumber passed)' );
is( Check_Userid( 'tomasito.none', '' ), 0,
    'userid exists (blank borrowernumber)' );
is( Check_Userid( 'tomasitoxxx', '' ), 1,
    'non-existent userid -> unique (blank borrowernumber)' );

$borrower = GetMember( borrowernumber => $borrowernumber );
is( $borrower->{dateofbirth}, undef, 'AddMember should undef dateofbirth if empty string is given');
is( $borrower->{debarred}, undef, 'AddMember should undef debarred if empty string is given');
isnt( $borrower->{dateexpiry}, '0000-00-00', 'AddMember should not set dateexpiry to 0000-00-00 if empty string is given');
isnt( $borrower->{dateenrolled}, '0000-00-00', 'AddMember should not set dateenrolled to 0000-00-00 if empty string is given');

ModMember( borrowernumber => $borrowernumber, dateofbirth => '', debarred => '', dateexpiry => '', dateenrolled => '' );
$borrower = GetMember( borrowernumber => $borrowernumber );
is( $borrower->{dateofbirth}, undef, 'ModMember should undef dateofbirth if empty string is given');
is( $borrower->{debarred}, undef, 'ModMember should undef debarred if empty string is given');
isnt( $borrower->{dateexpiry}, '0000-00-00', 'ModMember should not set dateexpiry to 0000-00-00 if empty string is given');
isnt( $borrower->{dateenrolled}, '0000-00-00', 'ModMember should not set dateenrolled to 0000-00-00 if empty string is given');

ModMember( borrowernumber => $borrowernumber, dateofbirth => '1970-01-01', debarred => '2042-01-01', dateexpiry => '9999-12-31', dateenrolled => '2015-09-06' );
$borrower = GetMember( borrowernumber => $borrowernumber );
is( $borrower->{dateofbirth}, '1970-01-01', 'ModMember should correctly set dateofbirth if a valid date is given');
is( $borrower->{debarred}, '2042-01-01', 'ModMember should correctly set debarred if a valid date is given');
is( $borrower->{dateexpiry}, '9999-12-31', 'ModMember should correctly set dateexpiry if a valid date is given');
is( $borrower->{dateenrolled}, '2015-09-06', 'ModMember should correctly set dateenrolled if a valid date is given');

# Add a new borrower with the same userid but different cardnumber
$data{ cardnumber } = "987654321";
my $new_borrowernumber = AddMember( %data );
is( Check_Userid( 'tomasito.none', '' ), 0,
    'userid not unique (blank borrowernumber)' );
is( Check_Userid( 'tomasito.none', $new_borrowernumber ), 0,
    'userid not unique (second borrowernumber passed)' );
$borrower = GetMember( borrowernumber => $new_borrowernumber );
ok( $borrower->{userid} ne 'tomasito', "Borrower with duplicate userid has new userid generated" );

$data{ cardnumber } = "234567890";
$data{userid} = 'a_user_id';
$borrowernumber = AddMember( %data );
$borrower = GetMember( borrowernumber => $borrowernumber );
is( $borrower->{userid}, $data{userid}, 'AddMember should insert the given userid' );

subtest 'ModMember should not update userid if not true' => sub {
    plan tests => 3;
    ModMember( borrowernumber => $borrowernumber, firstname => 'Tomas', userid => '' );
    $borrower = GetMember( borrowernumber => $borrowernumber );
    is ( $borrower->{userid}, $data{userid}, 'ModMember should not update the userid with an empty string' );
    ModMember( borrowernumber => $borrowernumber, firstname => 'Tomas', userid => 0 );
    $borrower = GetMember( borrowernumber => $borrowernumber );
    is ( $borrower->{userid}, $data{userid}, 'ModMember should not update the userid with an 0');
    ModMember( borrowernumber => $borrowernumber, firstname => 'Tomas', userid => undef );
    $borrower = GetMember( borrowernumber => $borrowernumber );
    is ( $borrower->{userid}, $data{userid}, 'ModMember should not update the userid with an undefined value');
};

#Regression tests for bug 10612
my $library3 = $builder->build({
    source => 'Branch',
});
$builder->build({
        source => 'Category',
        value => {
            categorycode         => 'STAFFER',
            description          => 'Staff dont batch del',
            category_type        => 'S',
        },
});

$builder->build({
        source => 'Category',
        value => {
            categorycode         => 'CIVILIAN',
            description          => 'Civilian batch del',
            category_type        => 'A',
        },
});

$builder->build({
        source => 'Category',
        value => {
            categorycode         => 'KIDclamp',
            description          => 'Kid to be guaranteed',
            category_type        => 'C',
        },
});

my $borrower1 = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode=>'STAFFER',
            branchcode => $library3->{branchcode},
            dateexpiry => '2015-01-01',
        },
});
my $bor1inlist = $borrower1->{borrowernumber};
my $borrower2 = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode=>'STAFFER',
            branchcode => $library3->{branchcode},
            dateexpiry => '2015-01-01',
        },
});

my $guarantee = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode=>'KIDclamp',
            branchcode => $library3->{branchcode},
            dateexpiry => '2015-01-01',
        },
});

my $bor2inlist = $borrower2->{borrowernumber};

$builder->build({
        source => 'OldIssue',
        value  => {
            borrowernumber => $bor2inlist,
            timestamp => '2016-01-01',
        },
});

my $owner = AddMember (categorycode => 'STAFFER', branchcode => $library2->{branchcode} );
my $list1 = AddPatronList( { name => 'Test List 1', owner => $owner } );
my @listpatrons = ($bor1inlist, $bor2inlist);
AddPatronsToList(  { list => $list1, borrowernumbers => \@listpatrons });
my $patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),0,'No staff deleted from list of all staff');
ModMember( borrowernumber => $bor2inlist, categorycode => 'CIVILIAN' );
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted from list');
$patstodel = GetBorrowersToExpunge( {branchcode => $library3->{branchcode},patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by branchcode and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by expirationdate and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by last issue date');

ModMember( borrowernumber => $bor1inlist, categorycode => 'CIVILIAN' );
ModMember( borrowernumber => $guarantee->{borrowernumber} ,guarantorid=>$bor1inlist );

$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted from list');
$patstodel = GetBorrowersToExpunge( {branchcode => $library3->{branchcode},patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by branchcode and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by expirationdate and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by last issue date');
ModMember( borrowernumber => $guarantee->{borrowernumber}, guarantorid=>'' );

$builder->build({
        source => 'Issue',
        value  => {
            borrowernumber => $bor2inlist,
        },
});
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
is( scalar(@$patstodel),1,'Borrower with issue not deleted from list');
$patstodel = GetBorrowersToExpunge( {branchcode => $library3->{branchcode},patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'Borrower with issue not deleted by branchcode and list');
$patstodel = GetBorrowersToExpunge( {category_code => 'CIVILIAN',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'Borrower with issue not deleted by category_code and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'Borrower with issue not deleted by expiration_date and list');
$builder->schema->resultset( 'Issue' )->delete_all;
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 2,'Borrowers without issue deleted from list');
$patstodel = GetBorrowersToExpunge( {category_code => 'CIVILIAN',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by category_code and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by expiration_date and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by last issue date');





# Regression tests for BZ13502
## Remove all entries with userid='' (should be only 1 max)
$dbh->do(q|DELETE FROM borrowers WHERE userid = ''|);
## And create a patron with a userid=''
$borrowernumber = AddMember( categorycode => 'S', branchcode => $library2->{branchcode} );
$dbh->do(q|UPDATE borrowers SET userid = '' WHERE borrowernumber = ?|, undef, $borrowernumber);
# Create another patron and verify the userid has been generated
$borrowernumber = AddMember( categorycode => 'S', branchcode => $library2->{branchcode} );
ok( $borrowernumber > 0, 'AddMember should have inserted the patron even if no userid is given' );
$borrower = GetMember( borrowernumber => $borrowernumber );
ok( $borrower->{userid},  'A userid should have been generated correctly' );

# Regression tests for BZ12226
is( Check_Userid( C4::Context->config('user'), '' ), 0,
    'Check_Userid should return 0 for the DB user (Bug 12226)');

subtest 'GetMemberAccountRecords' => sub {

    plan tests => 2;

    my $borrowernumber = $builder->build({ source => 'Borrower' })->{ borrowernumber };
    my $accountline_1  = $builder->build({
        source => 'Accountline',
        value  => {
            borrowernumber    => $borrowernumber,
            amountoutstanding => 64.60
        }
    });

    my ($total,undef,undef) = GetMemberAccountRecords( $borrowernumber );
    is( $total , 64.60, "Rounding works correctly in total calculation (single value)" );

    my $accountline_2 = $builder->build({
        source => 'Accountline',
        value  => {
            borrowernumber    => $borrowernumber,
            amountoutstanding => 10.65
        }
    });

    ($total,undef,undef) = GetMemberAccountRecords( $borrowernumber );
    is( $total , 75.25, "Rounding works correctly in total calculation (multiple values)" );

};

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
    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge', '1' );
    t::lib::Mocks::mock_preference( 'ManInvInNoissuesCharge', '0' );
    my ($total, $total_minus_charges,
        $other_charges) = C4::Members::GetMemberAccountBalance(123);
    is( $total, 15 , "Total calculated correctly");
    is( $total_minus_charges, 15, "Holds charges are not count if HoldsInNoissuesCharge=1");
    is( $other_charges, 0, "Holds charges are not considered if HoldsInNoissuesCharge=1");

    t::lib::Mocks::mock_preference( 'HoldsInNoissuesCharge', '0' );
    ($total, $total_minus_charges,
        $other_charges) = C4::Members::GetMemberAccountBalance(123);
    is( $total, 15 , "Total calculated correctly");
    is( $total_minus_charges, 10, "Holds charges are count if HoldsInNoissuesCharge=0");
    is( $other_charges, 5, "Holds charges are considered if HoldsInNoissuesCharge=1");
};

subtest 'purgeSelfRegistration' => sub {
    plan tests => 2;

    #purge unverified
    my $d=360;
    C4::Members::DeleteUnverifiedOpacRegistrations($d);
    foreach(1..3) {
        $dbh->do("INSERT INTO borrower_modifications (timestamp, borrowernumber, verification_token) VALUES ('2014-01-01 01:02:03',0,?)", undef, (scalar localtime)."_$_");
    }
    is( C4::Members::DeleteUnverifiedOpacRegistrations($d), 3, 'Test for DeleteUnverifiedOpacRegistrations' );

    #purge members in temporary category
    my $c= 'XYZ';
    $dbh->do("INSERT IGNORE INTO categories (categorycode) VALUES ('$c')");
    t::lib::Mocks::mock_preference('PatronSelfRegistrationDefaultCategory', $c );
    t::lib::Mocks::mock_preference('PatronSelfRegistrationExpireTemporaryAccountsDelay', 360);
    C4::Members::DeleteExpiredOpacRegistrations();
    $dbh->do("INSERT INTO borrowers (surname, address, city, branchcode, categorycode, dateenrolled) VALUES ('Testaabbcc', 'Street 1', 'CITY', ?, '$c', '2014-01-01 01:02:03')", undef, $library1->{branchcode});
    is( C4::Members::DeleteExpiredOpacRegistrations(), 1, 'Test for DeleteExpiredOpacRegistrations');
};

sub _find_member {
    my ($resultset) = @_;
    my $found = $resultset && grep( { $_->{cardnumber} && $_->{cardnumber} eq $CARDNUMBER } @$resultset );
    return $found;
}

# Regression tests for BZ15343
my $password="";
( $borrowernumber, $password ) = AddMember_Opac(surname=>"Dick",firstname=>'Philip',branchcode => $library2->{branchcode});
is( $password =~ /^[a-zA-Z]{10}$/ , 1, 'Test for autogenerated password if none submitted');
( $borrowernumber, $password ) = AddMember_Opac(surname=>"Deckard",firstname=>"Rick",password=>"Nexus-6",branchcode => $library2->{branchcode});
is( $password eq "Nexus-6", 1, 'Test password used if submitted');
$borrower = GetMember(borrowernumber => $borrowernumber);
my $hashed_up =  Koha::AuthUtils::hash_password("Nexus-6", $borrower->{password});
is( $borrower->{password} eq $hashed_up, 1, 'Check password hash equals hash of submitted password' );



### ------------------------------------- ###
### Testing GetAge() / SetAge() functions ###
### ------------------------------------- ###
#USES the package $member-variable to mock a koha.borrowers-object
sub testAgeAccessors {
    my ($member) = @_;
    my $original_dateofbirth = $member->{dateofbirth};

    ##Testing GetAge()
    my $age=GetAge("1992-08-14", "2011-01-19");
    is ($age, "18", "Age correct");

    $age=GetAge("2011-01-19", "1992-01-19");
    is ($age, "-19", "Birthday In the Future");

    ##Testing SetAge() for now()
    my $dt_now = DateTime->now();
    $age = DateTime::Duration->new(years => 12, months => 6, days => 1);
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '12', "SetAge 12 years");

    $age = DateTime::Duration->new(years => 18, months => 12, days => 31);
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '19', "SetAge 18+1 years"); #This is a special case, where months=>12 and days=>31 constitute one full year, hence we get age 19 instead of 18.

    $age = DateTime::Duration->new(years => 18, months => 12, days => 30);
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '19', "SetAge 18 years");

    $age = DateTime::Duration->new(years => 0, months => 1, days => 1);
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '0', "SetAge 0 years");

    $age = '0018-12-31';
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '19', "SetAge ISO_Date 18+1 years"); #This is a special case, where months=>12 and days=>31 constitute one full year, hence we get age 19 instead of 18.

    $age = '0018-12-30';
    C4::Members::SetAge( $member, $age );
    $age = C4::Members::GetAge( $member->{dateofbirth} );
    is ($age, '19', "SetAge ISO_Date 18 years");

    $age = '18-1-1';
    eval { C4::Members::SetAge( $member, $age ); };
    is ((length $@ > 1), '1', "SetAge ISO_Date $age years FAILS");

    $age = '0018-01-01';
    eval { C4::Members::SetAge( $member, $age ); };
    is ((length $@ == 0), '1', "SetAge ISO_Date $age years succeeds");

    ##Testing SetAge() for relative_date
    my $relative_date = DateTime->new(year => 3010, month => 3, day => 15);

    $age = DateTime::Duration->new(years => 10, months => 3);
    C4::Members::SetAge( $member, $age, $relative_date );
    $age = C4::Members::GetAge( $member->{dateofbirth}, $relative_date->ymd() );
    is ($age, '10', "SetAge, 10 years and 3 months old person was born on ".$member->{dateofbirth}." if todays is ".$relative_date->ymd());

    $age = DateTime::Duration->new(years => 112, months => 1, days => 1);
    C4::Members::SetAge( $member, $age, $relative_date );
    $age = C4::Members::GetAge( $member->{dateofbirth}, $relative_date->ymd() );
    is ($age, '112', "SetAge, 112 years, 1 months and 1 days old person was born on ".$member->{dateofbirth}." if today is ".$relative_date->ymd());

    $age = '0112-01-01';
    C4::Members::SetAge( $member, $age, $relative_date );
    $age = C4::Members::GetAge( $member->{dateofbirth}, $relative_date->ymd() );
    is ($age, '112', "SetAge ISO_Date, 112 years, 1 months and 1 days old person was born on ".$member->{dateofbirth}." if today is ".$relative_date->ymd());

    $member->{dateofbirth} = $original_dateofbirth; #It is polite to revert made changes in the unit tests.
} #sub testAgeAccessors

# regression test for bug 16009
my $patron;
eval {
    my $patron = GetMember(cardnumber => undef);
};
is($@, '', 'Bug 16009: GetMember(cardnumber => undef) works');
is($patron, undef, 'Bug 16009: GetMember(cardnumber => undef) returns undef');

1;
