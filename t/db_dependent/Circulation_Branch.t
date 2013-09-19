#!/usr/bin/perl

use Modern::Perl;
use C4::Biblio;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use C4::Items;
use C4::Context;

use Test::More tests => 10;

BEGIN {
    use_ok('C4::Circulation');
}

can_ok( 'C4::Circulation', qw(
                            GetBranchBorrowerCircRule
                            GetBranchItemRule
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
    add            => 1,
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
    add            => 1,
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

$query =
"INSERT INTO branch_borrower_circ_rules (branchcode,categorycode,maxissueqty) VALUES( ?,?,?)";
$dbh->do(
    $query, {},
    $samplebranch1->{branchcode},
    $samplecat->{categorycode}, 5
);
$query =
"INSERT INTO default_branch_circ_rules (branchcode,maxissueqty,holdallowed,returnbranch) VALUES( ?,?,?,?)";
$dbh->do( $query, {}, $samplebranch2->{branchcode},
    3, 1, $samplebranch2->{branchcode} );
$query =
"INSERT INTO default_circ_rules (singleton,maxissueqty,holdallowed,returnbranch) VALUES( ?,?,?,?)";
$dbh->do( $query, {}, 'singleton', 4, 3, $samplebranch1->{branchcode} );

$query =
"INSERT INTO branch_item_rules (branchcode,itemtype,holdallowed,returnbranch) VALUES( ?,?,?,?)";
$sth = $dbh->prepare($query);
$sth->execute(
    $samplebranch1->{branchcode},
    $sampleitemtype1->{itemtype},
    5, $samplebranch1->{branchcode}
);
$sth->execute(
    $samplebranch2->{branchcode},
    $sampleitemtype2->{itemtype},
    5, $samplebranch1->{branchcode}
);

#Test GetBranchBorrowerCircRule
is_deeply(
    GetBranchBorrowerCircRule(),
    { maxissueqty => 4 },
"Without parameter, GetBranchBorrower returns the maxissueqty of default_circ_rules"
);
is_deeply(
    GetBranchBorrowerCircRule( $samplebranch2->{branchcode} ),
    { maxissueqty => 3 },
"Without only the branchcode specified, GetBranchBorrower returns the maxissueqty corresponding"
);
is_deeply(
    GetBranchBorrowerCircRule(
        $samplebranch1->{branchcode},
        $samplecat->{categorycode}
    ),
    { maxissueqty => 5 },
    "GetBranchBorrower returns the maxissueqty of the branch1 and the category1"
);
is_deeply(
    GetBranchBorrowerCircRule( -1, -1 ),
    { maxissueqty => 4 },
"GetBranchBorrower  with wrong parameters returns tthe maxissueqty of default_circ_rules"
);

#Test GetBranchItemRule
is_deeply(
    GetBranchItemRule(
        $samplebranch1->{branchcode},
        $sampleitemtype1->{itemtype}
    ),
    { returnbranch => $samplebranch1->{branchcode}, holdallowed => 5 },
    "GetBranchitem returns holdallowed and return branch"
);
is_deeply(
    GetBranchItemRule(),
    { returnbranch => $samplebranch1->{branchcode}, holdallowed => 3 },
"Without parameters GetBranchItemRule returns the values in default_circ_rules"
);
is_deeply(
    GetBranchItemRule( $samplebranch1->{branchcode} ),
    { returnbranch => $samplebranch1->{branchcode}, holdallowed => 3 },
"With only a branchcode GetBranchItemRule returns values in default_branch_circ_rules"
);
is_deeply(
    GetBranchItemRule( -1, -1 ),
    { returnbranch => $samplebranch1->{branchcode}, holdallowed => 3 },
    "With only one parametern GetBranchItemRule returns default values"
);

$dbh->rollback;
