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

use Test::More tests => 32;
use DateTime::Duration;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio;
use C4::Circulation;
use C4::Context;
use C4::Items;
use C4::Members;
use C4::Reserves;
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils;
use Koha::Holds;
use Koha::Library;
use Koha::Patrons;

BEGIN {
    require_ok('C4::Circulation');
}

can_ok(
    'C4::Circulation',
    qw(AddIssue
      AddIssuingCharge
      AddRenewal
      AddReturn
      GetBiblioIssues
      GetIssuingCharges
      GetOpenIssue
      GetRenewCount
      GetUpcomingDueIssues
      )
);

#Start transaction
my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new();

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM issuingrules|);
$dbh->do(q|DELETE FROM reserves|);
$dbh->do(q|DELETE FROM old_reserves|);
$dbh->do(q|DELETE FROM statistics|);

# Generate sample datas
my $itemtype = $builder->build(
    {   source => 'Itemtype',
        value  => { notforloan => undef, rentalcharge => 0 }
    }
)->{itemtype};
my $branchcode_1 = $builder->build({ source => 'Branch' })->{branchcode};
my $branchcode_2 = $builder->build({ source => 'Branch' })->{branchcode};
my $branchcode_3 = $builder->build({ source => 'Branch' })->{branchcode};
my $categorycode = $builder->build({
        source => 'Category',
        value => { enrolmentfee => undef }
    })->{categorycode};

# Add Dates
my $dt_today = dt_from_string;
my $today    = output_pref(
    {   dt         => $dt_today,
        dateformat => 'iso',
        timeformat => '24hr',
        dateonly   => 1
    }
);

my $dt_today2 = dt_from_string;
my $dur10 = DateTime::Duration->new( days => -10 );
$dt_today2->add_duration($dur10);
my $daysago10 = output_pref(
    {   dt         => $dt_today2,
        dateformat => 'iso',
        timeformat => '24hr',
        dateonly   => 1
    }
);

# Add biblio and item
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $branchcode_1 ) );

my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' );

my $barcode_1 = 'barcode_1';
my $barcode_2 = 'barcode_2';
my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => $barcode_1,
        itemcallnumber => 'callnumber1',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        issue          => 1,
        reserve        => 1,
        itype          => $itemtype
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => $barcode_2,
        itemcallnumber => 'callnumber2',
        homebranch     => $branchcode_2,
        holdingbranch  => $branchcode_2,
        notforloan     => 1,
        issue          => 1,
        itype          => $itemtype
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

#Add borrower
my $borrower_id1 = C4::Members::AddMember(
    firstname    => 'firstname1',
    surname      => 'surname1 ',
    categorycode => $categorycode,
    branchcode   => $branchcode_1
);
my $borrower_1 = Koha::Patrons->find( $borrower_id1 )->unblessed;
my $borrower_id2 = C4::Members::AddMember(
    firstname    => 'firstname2',
    surname      => 'surname2 ',
    categorycode => $categorycode,
    branchcode   => $branchcode_2,
);
my $borrower_2 = Koha::Patrons->find( $borrower_id2 )->unblessed;

my @USERENV = (
    $borrower_id1, 'test', 'MASTERTEST', 'firstname', $branchcode_1,
    $branchcode_1, 'email@example.org'
);

my @USERENV_DIFFERENT_LIBRARY = (
    $borrower_id1, 'test', 'MASTERTEST', 'firstname', $branchcode_3,
    $branchcode_3, 'email@example.org'
);


C4::Context->_new_userenv('DUMMY_SESSION_ID');
C4::Context->set_userenv(@USERENV);

my $userenv = C4::Context->userenv
  or BAIL_OUT("No userenv");

#Begin Tests

#Test AddIssue
my $query = " SELECT count(*) FROM issues";
my $sth = $dbh->prepare($query);
$sth->execute;
my $countissue = $sth -> fetchrow_array;
is ($countissue ,0, "there is no issue");
my $issue1 = C4::Circulation::AddIssue( $borrower_1, $barcode_1, $daysago10,0, $today, '' );
is( ref $issue1, 'Koha::Schema::Result::Issue',
       'AddIssue returns a Koha::Schema::Result::Issue object' );
my $datedue1 = dt_from_string( $issue1->date_due() );
like(
    $datedue1,
    qr/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/,
    "Koha::Schema::Result::Issue->date_due() returns a date"
);
my $issue_id1 = $issue1->issue_id;

my $issue2 = C4::Circulation::AddIssue( $borrower_1, 'nonexistent_barcode' );
is( $issue2, undef, "AddIssue returns undef if no datedue is specified" );

$sth->execute;
$countissue = $sth -> fetchrow_array;
is ($countissue,1,"1 issues have been added");

#Test AddIssuingCharge
$query = " SELECT count(*) FROM accountlines";
$sth = $dbh->prepare($query);
$sth->execute;
my $countaccount = $sth -> fetchrow_array;
is ($countaccount,0,"0 accountline exists");
my $checkout = Koha::Checkouts->find( $issue_id1 );
my $offset = C4::Circulation::AddIssuingCharge( $checkout, 10 );
is( ref( $offset ), 'Koha::Account::Offset', "An issuing charge has been added" );
my $charge = Koha::Account::Lines->find( $offset->debit_id );
is( $charge->issue_id, $issue_id1, 'Issue id is set correctly for issuing charge' );
my $account_id = $dbh->last_insert_id( undef, undef, 'accountlines', undef );
$sth->execute;
$countaccount = $sth -> fetchrow_array;
is ($countaccount,1,"1 accountline has been added");

# Test AddRenewal

my $se = Test::MockModule->new( 'C4::Context' );
$se->mock( 'interface', sub {return 'intranet'});

# Let's renew this one at a different library for statistical purposes to test Bug 17781
C4::Context->set_userenv(@USERENV_DIFFERENT_LIBRARY);
my $datedue3 = AddRenewal( $borrower_id1, $item_id1, $branchcode_1, $datedue1, $daysago10 );
C4::Context->set_userenv(@USERENV);

like(
    $datedue3,
    qr/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/,
    "AddRenewal returns a date"
);

my $stat = $dbh->selectrow_hashref("SELECT * FROM statistics WHERE type = 'renew' AND borrowernumber = ? AND itemnumber = ? AND branch = ?", undef, $borrower_id1, $item_id1, $branchcode_3 );
ok( $stat, "Bug 17781 - 'Improper branchcode set during renewal' still fixed" );

$se->mock( 'interface', sub {return 'opac'});

#Let's do an opac renewal - whatever branchcode we send should be used
my $opac_renew_issue = $builder->build({
    source=>"Issue",
    value=>{
        date_due => '2017-01-01',
        branch => $branchcode_1,
        itype => $itemtype,
        borrowernumber => $borrower_id1
    }
});

my $datedue4 = AddRenewal( $opac_renew_issue->{borrowernumber}, $opac_renew_issue->{itemnumber}, "Stavromula", $datedue1, $daysago10 );

$stat = $dbh->selectrow_hashref("SELECT * FROM statistics WHERE type = 'renew' AND borrowernumber = ? AND itemnumber = ? AND branch = ?", undef,  $opac_renew_issue->{borrowernumber},  $opac_renew_issue->{itemnumber}, "Stavromula" );
ok( $stat, "Bug 18572 - 'Bug 18572 - OpacRenewalBranch is now respected" );



#Test GetBiblioIssues
is( GetBiblioIssues(), undef, "GetBiblio Issues without parameters" );

#Test GetOpenIssue
is( GetOpenIssue(), undef, "Without parameter GetOpenIssue returns undef" );
is( GetOpenIssue(-1), undef,
    "With wrong parameter GetOpenIssue returns undef" );
my $openissue = GetOpenIssue($borrower_id1, $item_id1);

my @renewcount;
#Test GetRenewCount
my $issue3 = C4::Circulation::AddIssue( $borrower_1, $barcode_1 );
#Without anything in DB
@renewcount = C4::Circulation::GetRenewCount();
is_deeply(
    \@renewcount,
    [ 0, 0, 0 ], # FIXME Need to be fixed, see FIXME in GetRenewCount
    "Without issuing rules and without parameter, GetRenewCount returns renewcount = 0, renewsallowed = undef, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount(-1);
is_deeply(
    \@renewcount,
    [ 0, 0, 0 ], # FIXME Need to be fixed
    "Without issuing rules and without wrong parameter, GetRenewCount returns renewcount = 0, renewsallowed = undef, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 2, 0, 0 ],
    "Without issuing rules and with a valid parameter, renewcount = 2, renewsallowed = undef, renewsleft = 0"
);

#With something in DB
# Add a default rule: No renewal allowed
$dbh->do(q|
    INSERT INTO issuingrules( categorycode, itemtype, branchcode, issuelength, renewalsallowed )
    VALUES ( '*', '*', '*', 10, 0 )
|);
@renewcount = C4::Circulation::GetRenewCount();
is_deeply(
    \@renewcount,
    [ 0, 0, 0 ],
    "With issuing rules (renewal disallowed) and without parameter, GetRenewCount returns renewcount = 0, renewsallowed = 0, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount(-1);
is_deeply(
    \@renewcount,
    [ 0, 0, 0 ],
    "With issuing rules (renewal disallowed) and without wrong parameter, GetRenewCount returns renewcount = 0, renewsallowed = 0, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 2, 0, 0 ],
    "With issuing rules (renewal disallowed) and with a valid parameter, Getrenewcount returns renewcount = 2, renewsallowed = 0, renewsleft = 0"
);

# Add a default rule: renewal is allowed
$dbh->do(q|
    UPDATE issuingrules SET renewalsallowed = 3
|);
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 2, 3, 1 ],
    "With issuing rules (renewal allowed) and with a valid parameter, Getrenewcount of item1 returns 3 renews left"
);

AddRenewal( $borrower_id1, $item_id1, $branchcode_1,
    $datedue3, $daysago10 );
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 3, 3, 0 ],
    "With issuing rules (renewal allowed, 1 remaining) and with a valid parameter, Getrenewcount of item1 returns 0 renews left"
);

$dbh->do("DELETE FROM old_issues");
AddReturn($barcode_1);
my $return = $dbh->selectrow_hashref("SELECT DATE(returndate) AS return_date, CURRENT_DATE() AS today FROM old_issues LIMIT 1" );
ok( $return->{return_date} eq $return->{today}, "Item returned with no return date specified has todays date" );

$dbh->do("DELETE FROM old_issues");
C4::Circulation::AddIssue( $borrower_1, $barcode_1, $daysago10, 0, $today );
AddReturn($barcode_1, undef, undef, undef, '2014-04-01 23:42');
$return = $dbh->selectrow_hashref("SELECT * FROM old_issues LIMIT 1" );
ok( $return->{returndate} eq '2014-04-01 23:42:00', "Item returned with a return date of '2014-04-01 23:42' has that return date" );

my $itemnumber;
($biblionumber, $biblioitemnumber, $itemnumber) = C4::Items::AddItem(
    {
        barcode        => 'barcode_3',
        itemcallnumber => 'callnumber3',
        homebranch     => $branchcode_1,
        holdingbranch  => $branchcode_1,
        notforloan     => 1,
        itype          => $itemtype
    },
    $biblionumber
);

t::lib::Mocks::mock_preference( 'UpdateNotForLoanStatusOnCheckin', q{} );
AddReturn( 'barcode_3', $branchcode_1 );
my $item = GetItem( $itemnumber );
ok( $item->{notforloan} eq 1, 'UpdateNotForLoanStatusOnCheckin does not modify value when not enabled' );

t::lib::Mocks::mock_preference( 'UpdateNotForLoanStatusOnCheckin', '1: 9' );
AddReturn( 'barcode_3', $branchcode_1 );
$item = GetItem( $itemnumber );
ok( $item->{notforloan} eq 9, q{UpdateNotForLoanStatusOnCheckin updates notforloan value from 1 to 9 with setting "1: 9"} );

AddReturn( 'barcode_3', $branchcode_1 );
$item = GetItem( $itemnumber );
ok( $item->{notforloan} eq 9, q{UpdateNotForLoanStatusOnCheckin does not update notforloan value from 9 with setting "1: 9"} );

# Bug 14640 - Cancel the hold on checking out if asked
my $reserve_id = AddReserve($branchcode_1, $borrower_id1, $biblionumber,
    undef,  1, undef, undef, "a note", "a title", undef, '');
ok( $reserve_id, 'The reserve should have been inserted' );
AddIssue( $borrower_2, $barcode_1, dt_from_string, 'cancel' );
my $hold = Koha::Holds->find( $reserve_id );
is( $hold, undef, 'The reserve should have been correctly cancelled' );

#End transaction
$schema->storage->txn_rollback;
