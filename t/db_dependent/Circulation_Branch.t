#!/usr/bin/perl

use Modern::Perl;
use C4::Biblio;
use C4::Members;
use C4::Circulation;
use C4::Items;
use C4::Context;
use Koha::Library;

use Test::More tests => 14;

BEGIN {
    use_ok('C4::Circulation');
}

can_ok( 'C4::Circulation', qw(
    AddIssue
    AddReturn
    GetBranchBorrowerCircRule
    GetBranchItemRule
    GetIssuingRule
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
$dbh->do(q|DELETE FROM itemtypes|);
$dbh->do(q|DELETE FROM branch_item_rules|);
$dbh->do(q|DELETE FROM branch_borrower_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_circ_rules|);
$dbh->do(q|DELETE FROM default_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_item_rules|);

#Add branch and category
my $samplebranch1 = {
    branchcode     => 'SAB1',
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
    branchcode     => 'SAB2',
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
Koha::Library->new($samplebranch1)->store;
Koha::Library->new($samplebranch2)->store;

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
"INSERT INTO categories (categorycode,
                        description,
                        enrolmentperiod,
                        enrolmentperioddate,
                        dateofbirthrequired ,
                        finetype,
                        bulk,
                        enrolmentfee,
                        overduenoticerequired,
                        issuelimit,
                        reservefee,
                        hidelostitems,
                        category_type
                        )
VALUES( ?,?,?,?,?,?,?,?,?,?,?,?,?)";
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

#Add itemtypes
my $sampleitemtype1 = {
    itemtype     => 'BOOK',
    description  => 'BookDescription',
    rentalcharge => '10.0',
    notforloan   => 1,
    imageurl     => 'Null',
    summary      => 'BookSummary'
};
my $sampleitemtype2 = {
    itemtype     => 'DVD',
    description  => 'DvdDescription',
    rentalcharge => '5.0',
    notforloan   => 0,
    imageurl     => 'Null',
    summary      => 'DvdSummary'
};
$query =
"INSERT INTO itemtypes (itemtype,
                    description,
                    rentalcharge,
                    notforloan,
                    imageurl,
                    summary
                    )
 VALUES( ?,?,?,?,?,?)";
my $sth = $dbh->prepare($query);
$sth->execute(
    $sampleitemtype1->{itemtype},     $sampleitemtype1->{description},
    $sampleitemtype1->{rentalcharge}, $sampleitemtype1->{notforloan},
    $sampleitemtype1->{imageurl},     $sampleitemtype1->{summary}
);
$sth->execute(
    $sampleitemtype2->{itemtype},     $sampleitemtype2->{description},
    $sampleitemtype2->{rentalcharge}, $sampleitemtype2->{notforloan},
    $sampleitemtype2->{imageurl},     $sampleitemtype2->{summary}
);

#Add biblio and item
my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '952', '0', '0', a => $samplebranch1->{branchcode} ) );
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' );

# item 2 has home branch and holding branch samplebranch1
my @sampleitem1 = C4::Items::AddItem(
    {
        barcode        => 'barcode_1',
        itemcallnumber => 'callnumber1',
        homebranch     => $samplebranch1->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode}
    },
    $biblionumber
);
my $item_id1    = $sampleitem1[2];

# item 2 has holding branch samplebranch2
my @sampleitem2 = C4::Items::AddItem(
    {
        barcode        => 'barcode_2',
        itemcallnumber => 'callnumber2',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch1->{branchcode}
    },
    $biblionumber
);
my $item_id2 = $sampleitem2[2];

# item 3 has item type sampleitemtype2 with noreturn policy
my @sampleitem3 = C4::Items::AddItem(
    {
        barcode        => 'barcode_3',
        itemcallnumber => 'callnumber3',
        homebranch     => $samplebranch2->{branchcode},
        holdingbranch  => $samplebranch2->{branchcode},
        itype          => $sampleitemtype2->{itemtype}
    },
    $biblionumber
);
my $item_id3 = $sampleitem3[2];

#Add borrower
my $borrower_id1 = C4::Members::AddMember(
    firstname    => 'firstname1',
    surname      => 'surname1 ',
    categorycode => $samplecat->{categorycode},
    branchcode   => $samplebranch1->{branchcode},
);
my $borrower_1 = C4::Members::GetMember(borrowernumber => $borrower_id1);

is_deeply(
    GetBranchBorrowerCircRule(),
    { maxissueqty => undef, maxonsiteissueqty => undef },
"Without parameter, GetBranchBorrower returns undef (unilimited) for maxissueqty and maxonsiteissueqty if no rules defined"
);

$query = q|
    INSERT INTO branch_borrower_circ_rules
    (branchcode, categorycode, maxissueqty, maxonsiteissueqty)
    VALUES( ?, ?, ?, ? )
|;

$dbh->do(
    $query, {},
    $samplebranch1->{branchcode},
    $samplecat->{categorycode}, 5, 6
);

$query = q|
    INSERT INTO default_branch_circ_rules
    (branchcode, maxissueqty, maxonsiteissueqty, holdallowed, returnbranch)
    VALUES( ?, ?, ?, ?, ? )
|;
$dbh->do( $query, {}, $samplebranch2->{branchcode},
    3, 2, 1, 'holdingbranch' );
$query = q|
    INSERT INTO default_circ_rules
    (singleton, maxissueqty, maxonsiteissueqty, holdallowed, returnbranch)
    VALUES( ?, ?, ?, ?, ? )
|;
$dbh->do( $query, {}, 'singleton', 4, 5, 3, 'homebranch' );

$query =
"INSERT INTO branch_item_rules (branchcode,itemtype,holdallowed,returnbranch) VALUES( ?,?,?,?)";
$sth = $dbh->prepare($query);
$sth->execute(
    $samplebranch1->{branchcode},
    $sampleitemtype1->{itemtype},
    5, 'homebranch'
);
$sth->execute(
    $samplebranch2->{branchcode},
    $sampleitemtype1->{itemtype},
    5, 'holdingbranch'
);
$sth->execute(
    $samplebranch2->{branchcode},
    $sampleitemtype2->{itemtype},
    5, 'noreturn'
);

#Test GetBranchBorrowerCircRule
is_deeply(
    GetBranchBorrowerCircRule(),
    { maxissueqty => 4, maxonsiteissueqty => 5 },
"Without parameter, GetBranchBorrower returns the maxissueqty and maxonsiteissueqty of default_circ_rules"
);
is_deeply(
    GetBranchBorrowerCircRule( $samplebranch2->{branchcode} ),
    { maxissueqty => 3, maxonsiteissueqty => 2 },
"Without only the branchcode specified, GetBranchBorrower returns the maxissueqty and maxonsiteissueqty corresponding"
);
is_deeply(
    GetBranchBorrowerCircRule(
        $samplebranch1->{branchcode},
        $samplecat->{categorycode}
    ),
    { maxissueqty => 5, maxonsiteissueqty => 6 },
    "GetBranchBorrower returns the maxissueqty and maxonsiteissueqty of the branch1 and the category1"
);
is_deeply(
    GetBranchBorrowerCircRule( -1, -1 ),
    { maxissueqty => 4, maxonsiteissueqty => 5 },
"GetBranchBorrower with wrong parameters returns the maxissueqty and maxonsiteissueqty of default_circ_rules"
);

#Test GetBranchItemRule
is_deeply(
    GetBranchItemRule(
        $samplebranch1->{branchcode},
        $sampleitemtype1->{itemtype}
    ),
    { returnbranch => 'homebranch', holdallowed => 5 },
    "GetBranchitem returns holdallowed and return branch"
);
is_deeply(
    GetBranchItemRule(),
    { returnbranch => 'homebranch', holdallowed => 3 },
"Without parameters GetBranchItemRule returns the values in default_circ_rules"
);
is_deeply(
    GetBranchItemRule( $samplebranch2->{branchcode} ),
    { returnbranch => 'holdingbranch', holdallowed => 1 },
"With only a branchcode GetBranchItemRule returns values in default_branch_circ_rules"
);
is_deeply(
    GetBranchItemRule( -1, -1 ),
    { returnbranch => 'homebranch', holdallowed => 3 },
    "With only one parametern GetBranchItemRule returns default values"
);

# Test return policies
C4::Context->set_preference('AutomaticItemReturn','0');

# item1 returned at branch2 should trigger transfer to homebranch
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id1, $samplebranch1->{branchcode} );

my ($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_1',
    $samplebranch2->{branchcode});
is( $messages->{NeedsTransfer}, $samplebranch1->{branchcode}, "AddReturn respects default return policy - return to homebranch" );

# item2 returned at branch2 should trigger transfer to holding branch
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id2, $samplebranch2->{branchcode} );
($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_2',
    $samplebranch2->{branchcode});
is( $messages->{NeedsTransfer}, $samplebranch1->{branchcode}, "AddReturn respects branch return policy - item2->homebranch policy = 'holdingbranch'" );

# item3 should not trigger transfer - floating collection
$query =
"INSERT INTO issues (borrowernumber,itemnumber,branchcode) VALUES( ?,?,? )";
$dbh->do( $query, {}, $borrower_id1, $item_id3, $samplebranch1->{branchcode} );
($doreturn, $messages, $iteminformation, $borrower) = AddReturn('barcode_3',
    $samplebranch1->{branchcode});
is($messages->{NeedsTransfer},undef,"AddReturn respects branch item return policy - noreturn");


$dbh->rollback;
