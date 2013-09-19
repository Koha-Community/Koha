#!/usr/bin/perl

use Modern::Perl;
use Koha::DateUtils;
use DateTime::Duration;
use C4::Biblio;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use C4::Items;
use C4::Context;

use Test::More tests => 24;

BEGIN {
    use_ok('C4::Circulation');
}
can_ok(
    'C4::Circulation',
    qw(AddIssue
      AddIssuingCharge
      AddRenewal
      AddReturn
      GetBiblioIssues
      GetIssuingCharges
      GetIssuingRule
      GetItemIssue
      GetItemIssues
      GetOpenIssue
      GetRenewCount
      GetUpcomingDueIssues
      )
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM issuingrules|);

#Add sample datas

#Add Dates

my $dt_today    = dt_from_string;
my $today       = output_pref( $dt_today, 'iso', '24hr', 1 );

my $dt_today2 = dt_from_string;
my $dur10 = DateTime::Duration->new( days => -10 );
$dt_today2->add_duration($dur10);
my $daysago10 = output_pref( $dt_today2, 'iso', '24hr', 1 );

#Add branch and category
my $samplebranch1 = {
    add            => 1,
    branchcode     => 'CPL',
    branchname     => 'Sample Branch',
    branchaddress1 => 'sample adr1',
    branchaddress2 => 'sample adr2',
    branchaddress3 => 'sample adr3',
    branchzip      => 'sample zip',
    branchcity     => 'sample city',
    branchstate    => 'sample state',
    branchcountry  => 'sample country',
    branchphone    => 'sample phone',
    branchfax      => 'sample fax',
    branchemail    => 'sample email',
    branchurl      => 'sample url',
    branchip       => 'sample ip',
    branchprinter  => undef,
    opac_info      => 'sample opac',
};
my $samplebranch2 = {
    add            => 1,
    branchcode     => 'MPL',
    branchname     => 'Sample Branch2',
    branchaddress1 => 'sample adr1_2',
    branchaddress2 => 'sample adr2_2',
    branchaddress3 => 'sample adr3_2',
    branchzip      => 'sample zip2',
    branchcity     => 'sample city2',
    branchstate    => 'sample state2',
    branchcountry  => 'sample country2',
    branchphone    => 'sample phone2',
    branchfax      => 'sample fax2',
    branchemail    => 'sample email2',
    branchurl      => 'sample url2',
    branchip       => 'sample ip2',
    branchprinter  => undef,
    opac_info      => 'sample opac2',
};
ModBranch($samplebranch1);
ModBranch($samplebranch2);

my $samplecat = {
    categorycode          => 'CAT1',
    description           => 'Description1',
    enrolmentperiod       => 'Null',
    enrolmentperioddate   => 'Null',
    dateofbirthrequired   => 'Null',
    finetype              => 'Null',
    bulk                  => 'Null',
    enrolmentfee          => 'Null',
    overduenoticerequired => 'Null',
    issuelimit            => 'Null',
    reservefee            => 'Null',
    hidelostitems         => 0,
    category_type         => 'Null'
};
my $query =
"INSERT INTO categories (categorycode,description,enrolmentperiod,enrolmentperioddate,dateofbirthrequired ,finetype,bulk,enrolmentfee,overduenoticerequired,issuelimit ,reservefee ,hidelostitems ,category_type) VALUES( ?,?,?,?,?,?,?,?,?,?,?,?,?)";
$dbh->do(
    $query, {},
    $samplecat->{categorycode},          $samplecat->{description},
    $samplecat->{enrolmentperiod},       $samplecat->{enrolmentperioddate},
    $samplecat->{dateofbirthrequired},   $samplecat->{finetype},
    $samplecat->{bulk},                  $samplecat->{enrolmentfee},
    $samplecat->{overduenoticerequired}, $samplecat->{issuelimit},
    $samplecat->{reservefee},            $samplecat->{hidelostitems},
    $samplecat->{category_type}
);

#Add biblio and item
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $samplebranch1->{branchcode} ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' );

my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => 'barcode_1',
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode},
        issue          => 1,
        reserve        => 1
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => 'barcode_2',
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch2->{branchcode},
        notforloan     => 1,
        issue          => 1
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

#Add borrower
my $borrower_id1 = C4::Members::AddMember(
    firstname    => 'firstname1',
    surname      => 'surname1 ',
    categorycode => $samplecat->{categorycode},
    branchcode   => $samplebranch1->{branchcode},
);
my $borrower_1 = C4::Members::GetMember(borrowernumber => $borrower_id1);
my $borrower_id2 = C4::Members::AddMember(
    firstname    => 'firstname2',
    surname      => 'surname2 ',
    categorycode => $samplecat->{categorycode},
    branchcode   => $samplebranch2->{branchcode},
);
my $borrower_2 = C4::Members::GetMember(borrowernumber => $borrower_id2);

# NEED TO BE FIXED !!!
# The first parameter for set_userenv is the class ref
#my @USERENV = ( $borrower_id1, 'test', 'MASTERTEST', 'firstname', 'username', 'CPL', 'CPL', 'email@example.org' );
my @USERENV = ( $borrower_id1, 'test', 'MASTERTEST', 'firstname', 'CPL', 'CPL', 'email@example.org' );

C4::Context->_new_userenv('DUMMY_SESSION_ID');
C4::Context->set_userenv(@USERENV);

my $userenv = C4::Context->userenv
  or BAIL_OUT("No userenv");

#Begin Tests

#Test AddIssue
$query = " SELECT count(*) FROM issues";
my $sth = $dbh->prepare($query);
$sth->execute;
my $countissue = $sth -> fetchrow_array;
is ($countissue ,0, "there is no issue");
my $datedue1 = C4::Circulation::AddIssue( $borrower_1, "code", $daysago10,0, $today, '' );
like(
    $datedue1,
    qr/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/,
    "AddRenewal returns a date"
);
my $issue_id1 = $dbh->last_insert_id( undef, undef, 'issues', undef );

my $datedue2 = C4::Circulation::AddIssue( $borrower_1, 'nonexistent_barcode' );
is( $datedue2, undef, "AddIssue returns undef if no datedue is specified" );
my $issue_id2 = $dbh->last_insert_id( undef, undef, 'issues', undef );

$sth->execute;
$countissue = $sth -> fetchrow_array;
#FIXME: Currently AddIssue doesn't add correctly issues
#is ($countissue,2,"2 issues have been added");

#Test AddIssuingCharge
$query = " SELECT count(*) FROM accountlines";
$sth = $dbh->prepare($query);
$sth->execute;
my $countaccount = $sth -> fetchrow_array;
is ($countaccount,0,"0 accountline exists");
is( C4::Circulation::AddIssuingCharge( $item_id1, $borrower_id1, 10 ),
    1, "An issuing charge has been added" );
my $account_id = $dbh->last_insert_id( undef, undef, 'accountlines', undef );
$sth->execute;
$countaccount = $sth -> fetchrow_array;
is ($countaccount,1,"1 accountline has been added");

#Test AddRenewal
my $datedue3 =
  AddRenewal( $borrower_id1, $item_id1, $samplebranch1->{branchcode},
    $datedue1, $daysago10 );
like(
    $datedue3,
    qr/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/,
    "AddRenewal returns a date"
);

#Test GetBiblioIssues
is( GetBiblioIssues(), undef, "GetBiblio Issues without parameters" );

#Test GetItemIssue
#FIXME : As the issues are not correctly added in the database, these tests don't work correctly
is(GetItemIssue,undef,"Without parameter GetItemIssue returns undef");
#is(GetItemIssue($item_id1),{},"Item1's issues");

#Test GetItemIssues
#FIXME: this routine currently doesn't work be
#is_deeply (GetItemIssues,{},"Without parameter, GetItemIssue returns all the issues");

#Test GetOpenIssue
is( GetOpenIssue(), undef, "Without parameter GetOpenIssue returns undef" );
is( GetOpenIssue(-1), undef,
    "With wrong parameter GetOpenIssue returns undef" );
my $openissue = GetOpenIssue($borrower_id1, $item_id1);

my @renewcount;
#Test GetRenewCount
$datedue2 = C4::Circulation::AddIssue( $borrower_1, 'barcode_1' );
isnt( $datedue2, undef, "AddIssue does not return undef if datedue is specified" );
#Without anything in DB
@renewcount = C4::Circulation::GetRenewCount();
is_deeply(
    \@renewcount,
    [ 0, undef, 0 ], # FIXME Need to be fixed
    "Without issuing rules and without parameter, GetRenewCount returns renewcount = 0, renewsallowed = undef, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount(-1);
is_deeply(
    \@renewcount,
    [ 0, undef, 0 ], # FIXME Need to be fixed
    "Without issuing rules and without wrong parameter, GetRenewCount returns renewcount = 0, renewsallowed = undef, renewsleft = 0"
);
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 0, undef, 0 ], # FIXME Need to be fixed
    "Without issuing rules and with a valid parameter, renewcount = 0, renewsallowed = undef, renewsleft = 0"
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
    [ 0, 0, 0 ],
    "With issuing rules (renewal disallowed) and with a valid parameter, Getrenewcount returns renewcount = 0, renewsallowed = 0, renewsleft = 0"
);

# Add a default rule: renewal is allowed
$dbh->do(q|
    UPDATE issuingrules SET renewalsallowed = 3
|);
@renewcount = C4::Circulation::GetRenewCount();
is_deeply(
    \@renewcount,
    [ 0, 3, 3 ],
    "With issuing rules (renewal allowed) and without parameter, GetRenewCount returns renewcount = 0, renewsallowed = 3, renewsleft = 3"
);
@renewcount = C4::Circulation::GetRenewCount(-1);
is_deeply(
    \@renewcount,
    [ 0, 3, 3 ],
    "With issuing rules (renewal allowed) and without wrong parameter, GetRenewCount returns renewcount = 0, renewsallowed = 3, renewsleft = 3"
);
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 0, 3, 3 ],
    "With issuing rules (renewal allowed) and with a valid parameter, Getrenewcount of item1 returns 3 renews left"
);

AddRenewal( $borrower_id1, $item_id1, $samplebranch1->{branchcode},
    $datedue3, $daysago10 );
@renewcount = C4::Circulation::GetRenewCount($borrower_id1, $item_id1);
is_deeply(
    \@renewcount,
    [ 1, 3, 2 ],
    "With issuing rules (renewal allowed, 2 remaining) and with a valid parameter, Getrenewcount of item1 returns 2 renews left"
);


#End transaction
$dbh->rollback;
