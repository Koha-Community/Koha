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

use Test::More tests => 53;
use Test::MockModule;
use Test::Exception;

use Data::Dumper qw/Dumper/;
use C4::Context;
use Koha::Database;
use Koha::Holds;
use Koha::List::Patron qw( AddPatronList AddPatronsToList );
use Koha::Patrons;
use Koha::Patron::Relationship;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
        use_ok('C4::Members', qw( checkcardnumber GetBorrowersToExpunge DeleteUnverifiedOpacRegistrations DeleteExpiredOpacRegistrations ));
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $patron_category = $builder->build({ source => 'Category' });
my $CARDNUMBER   = 'TESTCARD01';
my $FIRSTNAME    = 'Marie';
my $SURNAME      = 'Mcknight';
my $BRANCHCODE   = $library1->{branchcode};

my $CHANGED_FIRSTNAME = "Marry Ann";
my $EMAIL             = "Marie\@email.com";
my $EMAILPRO          = "Marie\@work.com";
my $PHONE             = "555-12123";

# XXX should be randomised and checked against the database
my $IMPOSSIBLE_CARDNUMBER = "XYZZZ999";

t::lib::Mocks::mock_userenv();

# Make a borrower for testing
my %data = (
    cardnumber => $CARDNUMBER,
    firstname =>  $FIRSTNAME . q{ },
    surname => $SURNAME,
    categorycode => $patron_category->{categorycode},
    branchcode => $BRANCHCODE,
    dateofbirth => '',
    dateexpiry => '9999-12-31',
    userid => 'tomasito'
);

my $addmem=Koha::Patron->new(\%data)->store->borrowernumber;
ok($addmem, "Koha::Patron->store()");

my $patron = Koha::Patrons->find( { cardnumber => $CARDNUMBER } )
  or BAIL_OUT("Cannot read member with card $CARDNUMBER");
my $member = $patron->unblessed;

ok ( $member->{firstname}    eq $FIRSTNAME    &&
     $member->{surname}      eq $SURNAME      &&
     $member->{categorycode} eq $patron_category->{categorycode} &&
     $member->{branchcode}   eq $BRANCHCODE
     , "Got member")
  or diag("Mismatching member details: ".Dumper(\%data, $member));

is($member->{dateofbirth}, undef, "Empty dates handled correctly");

$member->{firstname} = $CHANGED_FIRSTNAME . q{ };
$member->{email}     = $EMAIL;
$member->{phone}     = $PHONE;
$member->{emailpro}  = $EMAILPRO;
$patron->set($member)->store;
my $changedmember = Koha::Patrons->find( { cardnumber => $CARDNUMBER } )->unblessed;
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


# Add a new borrower
%data = (
    cardnumber   => "123456789",
    firstname    => "Tomasito",
    surname      => "None",
    categorycode => $patron_category->{categorycode},
    branchcode   => $library2->{branchcode},
    dateofbirth  => '',
    debarred     => '',
    dateexpiry   => '',
    dateenrolled => '',
);
my $borrowernumber = Koha::Patron->new( \%data )->store->borrowernumber;
$patron = Koha::Patrons->find( $borrowernumber );
my $borrower = $patron->unblessed;
is( $borrower->{dateofbirth}, undef, 'Koha::Patron->store should undef dateofbirth if empty string is given');
is( $borrower->{debarred}, undef, 'Koha::Patron->store should undef debarred if empty string is given');
isnt( $borrower->{dateexpiry}, '0000-00-00', 'Koha::Patron->store should not set dateexpiry to 0000-00-00 if empty string is given');
isnt( $borrower->{dateenrolled}, '0000-00-00', 'Koha::Patron->store should not set dateenrolled to 0000-00-00 if empty string is given');

$patron->set({ dateofbirth => '', debarred => '', dateexpiry => '', dateenrolled => '' })->store;
$borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
is( $borrower->{dateofbirth}, undef, 'Koha::Patron->store should undef dateofbirth if empty string is given');
is( $borrower->{debarred}, undef, 'Koha::Patron->store should undef debarred if empty string is given');
isnt( $borrower->{dateexpiry}, '0000-00-00', 'Koha::Patron->store should not set dateexpiry to 0000-00-00 if empty string is given');
isnt( $borrower->{dateenrolled}, '0000-00-00', 'Koha::Patron->store should not set dateenrolled to 0000-00-00 if empty string is given');

$patron->set({ dateofbirth => '1970-01-01', debarred => '2042-01-01', dateexpiry => '9999-12-31', dateenrolled => '2015-09-06' })->store;
$borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
is( $borrower->{dateofbirth}, '1970-01-01', 'Koha::Patron->store should correctly set dateofbirth if a valid date is given');
is( $borrower->{debarred}, '2042-01-01', 'Koha::Patron->store should correctly set debarred if a valid date is given');
is( $borrower->{dateexpiry}, '9999-12-31', 'Koha::Patron->store should correctly set dateexpiry if a valid date is given');
is( $borrower->{dateenrolled}, '2015-09-06', 'Koha::Patron->store should correctly set dateenrolled if a valid date is given');

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
            flags => undef,
        },
});
my $bor1inlist = $borrower1->{borrowernumber};
my $borrower2 = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode=>'STAFFER',
            branchcode => $library3->{branchcode},
            dateexpiry => '2015-01-01',
            flags => undef,
        },
});

my $guarantee = $builder->build({
        source => 'Borrower',
        value  => {
            categorycode=>'KIDclamp',
            branchcode => $library3->{branchcode},
            dateexpiry => '2015-01-01',
            flags => undef,
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

# The following calls to GetBorrowersToExpunge are assuming that the pref
# IndependentBranches is off.
t::lib::Mocks::mock_preference('IndependentBranches', 0);

my $anonymous_patron = Koha::Patron->new({ categorycode => 'CIVILIAN', branchcode => $library2->{branchcode} })->store->borrowernumber;
t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous_patron);

my $owner = Koha::Patron->new({ categorycode => 'STAFFER', branchcode => $library2->{branchcode} })->store->borrowernumber;
my $list1 = AddPatronList( { name => 'Test List 1', owner => $owner } );

AddPatronsToList( { list => $list1, borrowernumbers => [$anonymous_patron] } );
my $patstodel = GetBorrowersToExpunge( { patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel), 0, 'Anonymous Patron not deleted from list' );

my @listpatrons = ($bor1inlist, $bor2inlist);
AddPatronsToList(  { list => $list1, borrowernumbers => \@listpatrons });
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),0,'No staff deleted from list of all staff');
Koha::Patrons->find($bor2inlist)->set({ categorycode => 'CIVILIAN' })->store;
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted from list');
$patstodel = GetBorrowersToExpunge( {branchcode => $library3->{branchcode},patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by branchcode and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by expirationdate and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Staff patron not deleted by last issue date');

Koha::Patrons->find($bor1inlist)->set({ categorycode => 'CIVILIAN' })->store;

t::lib::Mocks::mock_preference( 'borrowerRelationship', 'test' );

my $relationship = Koha::Patron::Relationship->new( { guarantor_id => $bor1inlist, guarantee_id => $guarantee->{borrowernumber}, relationship => 'test' } )->store();

$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted from list');
$patstodel = GetBorrowersToExpunge( {branchcode => $library3->{branchcode},patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by branchcode and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by expirationdate and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
ok( scalar(@$patstodel) == 1 && $patstodel->[0]->{'borrowernumber'} eq $bor2inlist,'Guarantor patron not deleted by last issue date');
$relationship->delete();

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
$patstodel = GetBorrowersToExpunge( {category_code => [], patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'category_code can contain an empty arrayref');
$patstodel = GetBorrowersToExpunge( {category_code => ['CIVILIAN','STAFFER'],patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'Borrower with issue not deleted by multiple category_code and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),1,'Borrower with issue not deleted by expiration_date and list');
$builder->schema->resultset( 'Issue' )->delete_all;
$patstodel = GetBorrowersToExpunge( {patron_list_id => $list1->patron_list_id()} );
ok( scalar(@$patstodel)== 2,'Borrowers without issue deleted from list');
$patstodel = GetBorrowersToExpunge( {category_code => 'CIVILIAN',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by category_code and list');
$patstodel = GetBorrowersToExpunge( {category_code => ['CIVILIAN','STAFFER'],patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by multiple category_code and list');
$patstodel = GetBorrowersToExpunge( {expired_before => '2015-01-02',patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by expiration_date and list');
$patstodel = GetBorrowersToExpunge( {not_borrowed_since => '2016-01-02', patron_list_id => $list1->patron_list_id() } );
is( scalar(@$patstodel),2,'Borrowers without issues deleted by last issue date');

# Test GetBorrowersToExpunge and TrackLastPatronActivity
$dbh->do(q|UPDATE borrowers SET lastseen=NULL|);
$builder->build({
    source => 'Borrower',
    value => {
        lastseen => '2016-01-01 01:01:01',
        categorycode => 'CIVILIAN',
        flags => undef,
    }
});
$builder->build({
    source => 'Borrower',
    value => {
        lastseen => '2016-02-02 02:02:02',
        categorycode => 'CIVILIAN',
        flags => undef,
    }
});
$builder->build({
    source => 'Borrower',
    value => {
        lastseen => '2016-03-03 03:03:03',
        categorycode => 'CIVILIAN',
        flags => undef,
    }
});
$patstodel = GetBorrowersToExpunge( { last_seen => '1999-12-12' });
is( scalar @$patstodel, 0, 'TrackLastPatronActivity - 0 patrons must be deleted' );
$patstodel = GetBorrowersToExpunge( { last_seen => '2016-02-15' });
is( scalar @$patstodel, 2, 'TrackLastPatronActivity - 2 patrons must be deleted' );
$patstodel = GetBorrowersToExpunge( { last_seen => '2016-04-04' });
is( scalar @$patstodel, 3, 'TrackLastPatronActivity - 3 patrons must be deleted' );
my $patron2 = $builder->build({
    source => 'Borrower',
    value => {
        lastseen => undef,
        flags => undef,
    }
});
t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '0' );
Koha::Patrons->find( $patron2->{borrowernumber} )->track_login;
is( Koha::Patrons->find( $patron2->{borrowernumber} )->lastseen, undef, 'Lastseen should not be changed' );
Koha::Patrons->find( $patron2->{borrowernumber} )->track_login({ force => 1 });
isnt( Koha::Patrons->find( $patron2->{borrowernumber} )->lastseen, undef, 'Lastseen should be changed now' );

# Test GetBorrowersToExpunge and regular patron with permission
$builder->build({
        source => 'Category',
        value => {
            categorycode         => 'SMALLSTAFF',
            description          => 'Small staff',
            category_type        => 'A',
        },
});
$borrowernumber = Koha::Patron->new({
    categorycode => 'SMALLSTAFF',
    branchcode => $library2->{branchcode},
    flags => undef,
})->store->borrowernumber;
$patron = Koha::Patrons->find( $borrowernumber );
$patstodel = GetBorrowersToExpunge( {category_code => 'SMALLSTAFF' } );
is( scalar @$patstodel, 1, 'Regular patron with flags=undef can be deleted' );
$patron->set({ flags => 0 })->store;
$patstodel = GetBorrowersToExpunge( {category_code => 'SMALLSTAFF' } );
is( scalar @$patstodel, 1, 'Regular patron with flags=0 can be deleted' );
$patron->set({ flags => 4 })->store;
$patstodel = GetBorrowersToExpunge( {category_code => 'SMALLSTAFF' } );
is( scalar @$patstodel, 0, 'Regular patron with flags>0 can not be deleted' );

# Regression tests for BZ13502
## Remove all entries with userid='' (should be only 1 max)
$dbh->do(q|DELETE FROM borrowers WHERE userid = ''|);
## And create a patron with a userid=''
$borrowernumber = Koha::Patron->new({ categorycode => $patron_category->{categorycode}, branchcode => $library2->{branchcode} })->store->borrowernumber;
$dbh->do(q|UPDATE borrowers SET userid = '' WHERE borrowernumber = ?|, undef, $borrowernumber);
# Create another patron and verify the userid has been generated
$borrowernumber = Koha::Patron->new({ categorycode => $patron_category->{categorycode}, branchcode => $library2->{branchcode} })->store->borrowernumber;
ok( $borrowernumber > 0, 'Koha::Patron->store should have inserted the patron even if no userid is given' );
$borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
ok( $borrower->{userid},  'A userid should have been generated correctly' );

subtest 'purgeSelfRegistration' => sub {
    plan tests => 8;

    #purge unverified
    my $d=360;
    C4::Members::DeleteUnverifiedOpacRegistrations($d);
    foreach(1..3) {
        $dbh->do("INSERT INTO borrower_modifications (timestamp, borrowernumber, verification_token, changed_fields) VALUES ('2014-01-01 01:02:03',0,?,'firstname,surname')", undef, (scalar localtime)."_$_");
    }
    # Add a record with a borrowernumber which should not be deleted by DeleteUnverifiedOpacRegistrations
    # NOTE: We are using the borrowernumber from the last test outside this subtest
    $dbh->do( "INSERT INTO borrower_modifications (timestamp, borrowernumber, verification_token, changed_fields) VALUES ('2014-01-01 01:02:03', ?, '', 'firstname,surname' )", undef, $borrowernumber );
    is( C4::Members::DeleteUnverifiedOpacRegistrations($d), 3, 'Test for DeleteUnverifiedOpacRegistrations' );

    #purge members in temporary category
    my $c= 'XYZ';
    $dbh->do("INSERT IGNORE INTO categories (categorycode) VALUES ('$c')");
    t::lib::Mocks::mock_preference('PatronSelfRegistrationDefaultCategory', $c );
    C4::Members::DeleteExpiredOpacRegistrations();
    my $self_reg = $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            dateenrolled => '2014-01-01 01:02:03',
            categorycode => $c
        }
    });

    # First test if empty PatronSelfRegistrationExpireTemporaryAccountsDelay returns zero
    t::lib::Mocks::mock_preference('PatronSelfRegistrationExpireTemporaryAccountsDelay', q{} );
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations with empty delay" );
    # Test zero too
    t::lib::Mocks::mock_preference('PatronSelfRegistrationExpireTemporaryAccountsDelay', 0 );
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations with delay 0" );
    # Also check empty category
    t::lib::Mocks::mock_preference('PatronSelfRegistrationDefaultCategory', q{} );
    t::lib::Mocks::mock_preference('PatronSelfRegistrationExpireTemporaryAccountsDelay', 360 );
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations with empty category" );
    t::lib::Mocks::mock_preference('PatronSelfRegistrationDefaultCategory', $c );

    my $checkout     = $builder->build_object({
        class=>'Koha::Checkouts',
        value=>{
            borrowernumber=>$self_reg->borrowernumber
        }
    });
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations doesn't delete borrower with checkout");

    my $account_line = $builder->build_object(
        {
            class => 'Koha::Account::Lines',
            value => {
                borrowernumber    => $self_reg->borrowernumber,
                amountoutstanding => 5,
            }
        }
    );
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations doesn't delete borrower with checkout and fine");

    $checkout->delete;
    is( C4::Members::DeleteExpiredOpacRegistrations(), 0, "DeleteExpiredOpacRegistrations doesn't delete borrower with fine and no checkout");

    $account_line->delete;
    is( C4::Members::DeleteExpiredOpacRegistrations(), 1, "DeleteExpiredOpacRegistrations does delete borrower with no fines and no checkouts");

};

sub _find_member {
    my ($resultset) = @_;
    my $found = $resultset && grep( { $_->{cardnumber} && $_->{cardnumber} eq $CARDNUMBER } @$resultset );
    return $found;
}

$schema->storage->txn_rollback;

subtest 'Koha::Patron->store (invalid categorycode) tests' => sub {
    plan tests => 1;
    # TODO Move this to t/db_dependent/Koha/Patrons.t subtest ->store

    $schema->storage->txn_begin;

    my $category    = $builder->build_object({ class => 'Koha::Patron::Categories' });
    my $category_id = $category->id;
    # Remove category to make sure the id is not on the DB
    $category->delete;

    my $patron_data = {
        categorycode => $category_id
    };

    throws_ok
        { Koha::Patron->new( $patron_data )->store; }
        'Koha::Exceptions::Object::FKConstraint',
        'AddMember raises an exception on invalid categorycode';

    $schema->storage->txn_rollback;
};
