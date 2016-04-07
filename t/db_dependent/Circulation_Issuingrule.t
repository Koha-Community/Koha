#!/usr/bin/perl

use Modern::Perl;
use C4::Context;
use DateTime;
use Koha::DateUtils;
use Koha::Library;

use Test::More tests => 10;

BEGIN {
    use_ok('C4::Circulation');
}
can_ok(
    'C4::Circulation',
    qw(
      GetHardDueDate
      GetIssuingRule
      GetLoanLength
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
$dbh->do(q|DELETE FROM issuingrules|);

#Add sample datas

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

#Begin Tests

#Test GetIssuingRule
my $sampleissuingrule1 = {
    reservecharge      => '0.000000',
    chargename         => 'Null',
    restrictedtype     => 0,
    accountsent        => 0,
    maxissueqty        => 5,
    maxonsiteissueqty  => 4,
    finedays           => 0,
    lengthunit         => 'days',
    renewalperiod      => 5,
    norenewalbefore    => 6,
    auto_renew         => 0,
    issuelength        => 5,
    chargeperiod       => 0,
    chargeperiod_charge_at => 0,
    rentaldiscount     => '2.000000',
    reservesallowed    => 0,
    hardduedate        => '2013-01-01',
    branchcode         => $samplebranch1->{branchcode},
    fine               => '0.000000',
    hardduedatecompare => 5,
    overduefinescap    => '0.000000',
    renewalsallowed    => 0,
    firstremind        => 0,
    itemtype           => 'BOOK',
    categorycode       => $samplecat->{categorycode},
    maxsuspensiondays  => 0,
    onshelfholds       => 0,
    opacitemholds      => 'N',
    cap_fine_to_replacement_price => 0,
};
my $sampleissuingrule2 = {
    branchcode         => $samplebranch2->{branchcode},
    categorycode       => $samplecat->{categorycode},
    itemtype           => 'BOOK',
    maxissueqty        => 2,
    maxonsiteissueqty  => 1,
    renewalsallowed    => 'Null',
    renewalperiod      => 2,
    norenewalbefore    => 7,
    auto_renew         => 0,
    reservesallowed    => 'Null',
    issuelength        => 2,
    lengthunit         => 'days',
    hardduedate        => 2,
    hardduedatecompare => 'Null',
    fine               => 'Null',
    finedays           => 'Null',
    firstremind        => 'Null',
    chargeperiod       => 'Null',
    chargeperiod_charge_at => 0,
    rentaldiscount     => 2.00,
    overduefinescap    => 'Null',
    accountsent        => 'Null',
    reservecharge      => 'Null',
    chargename         => 'Null',
    restrictedtype     => 'Null',
    maxsuspensiondays  => 0,
    onshelfholds       => 1,
    opacitemholds      => 'Y',
    cap_fine_to_replacement_price => 0,
};
my $sampleissuingrule3 = {
    branchcode         => $samplebranch1->{branchcode},
    categorycode       => $samplecat->{categorycode},
    itemtype           => 'DVD',
    maxissueqty        => 3,
    maxonsiteissueqty  => 2,
    renewalsallowed    => 'Null',
    renewalperiod      => 3,
    norenewalbefore    => 8,
    auto_renew         => 0,
    reservesallowed    => 'Null',
    issuelength        => 3,
    lengthunit         => 'days',
    hardduedate        => 3,
    hardduedatecompare => 'Null',
    fine               => 'Null',
    finedays           => 'Null',
    firstremind        => 'Null',
    chargeperiod       => 'Null',
    chargeperiod_charge_at => 0,
    rentaldiscount     => 3.00,
    overduefinescap    => 'Null',
    accountsent        => 'Null',
    reservecharge      => 'Null',
    chargename         => 'Null',
    restrictedtype     => 'Null',
    maxsuspensiondays  => 0,
    onshelfholds       => 1,
    opacitemholds      => 'F',
    cap_fine_to_replacement_price => 0,
};

$query = 'INSERT INTO issuingrules (
                branchcode,
                categorycode,
                itemtype,
                maxissueqty,
                maxonsiteissueqty,
                renewalsallowed,
                renewalperiod,
                norenewalbefore,
                auto_renew,
                reservesallowed,
                issuelength,
                lengthunit,
                hardduedate,
                hardduedatecompare,
                fine,
                finedays,
                firstremind,
                chargeperiod,
                chargeperiod_charge_at,
                rentaldiscount,
                overduefinescap,
                accountsent,
                reservecharge,
                chargename,
                restrictedtype,
                maxsuspensiondays,
                onshelfholds,
                opacitemholds,
                cap_fine_to_replacement_price
                ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
my $sth = $dbh->prepare($query);
$sth->execute(
    $sampleissuingrule1->{branchcode},
    $sampleissuingrule1->{categorycode},
    $sampleissuingrule1->{itemtype},
    $sampleissuingrule1->{maxissueqty},
    $sampleissuingrule1->{maxonsiteissueqty},
    $sampleissuingrule1->{renewalsallowed},
    $sampleissuingrule1->{renewalperiod},
    $sampleissuingrule1->{norenewalbefore},
    $sampleissuingrule1->{auto_renew},
    $sampleissuingrule1->{reservesallowed},
    $sampleissuingrule1->{issuelength},
    $sampleissuingrule1->{lengthunit},
    $sampleissuingrule1->{hardduedate},
    $sampleissuingrule1->{hardduedatecompare},
    $sampleissuingrule1->{fine},
    $sampleissuingrule1->{finedays},
    $sampleissuingrule1->{firstremind},
    $sampleissuingrule1->{chargeperiod},
    $sampleissuingrule1->{chargeperiod_charge_at},
    $sampleissuingrule1->{rentaldiscount},
    $sampleissuingrule1->{overduefinescap},
    $sampleissuingrule1->{accountsent},
    $sampleissuingrule1->{reservecharge},
    $sampleissuingrule1->{chargename},
    $sampleissuingrule1->{restrictedtype},
    $sampleissuingrule1->{maxsuspensiondays},
    $sampleissuingrule1->{onshelfholds},
    $sampleissuingrule1->{opacitemholds},
    $sampleissuingrule1->{cap_fine_to_replacement_price},
);
$sth->execute(
    $sampleissuingrule2->{branchcode},
    $sampleissuingrule2->{categorycode},
    $sampleissuingrule2->{itemtype},
    $sampleissuingrule2->{maxissueqty},
    $sampleissuingrule2->{maxonsiteissueqty},
    $sampleissuingrule2->{renewalsallowed},
    $sampleissuingrule2->{renewalperiod},
    $sampleissuingrule2->{norenewalbefore},
    $sampleissuingrule2->{auto_renew},
    $sampleissuingrule2->{reservesallowed},
    $sampleissuingrule2->{issuelength},
    $sampleissuingrule2->{lengthunit},
    $sampleissuingrule2->{hardduedate},
    $sampleissuingrule2->{hardduedatecompare},
    $sampleissuingrule2->{fine},
    $sampleissuingrule2->{finedays},
    $sampleissuingrule2->{firstremind},
    $sampleissuingrule2->{chargeperiod},
    $sampleissuingrule2->{chargeperiod_charge_at},
    $sampleissuingrule2->{rentaldiscount},
    $sampleissuingrule2->{overduefinescap},
    $sampleissuingrule2->{accountsent},
    $sampleissuingrule2->{reservecharge},
    $sampleissuingrule2->{chargename},
    $sampleissuingrule2->{restrictedtype},
    $sampleissuingrule2->{maxsuspensiondays},
    $sampleissuingrule2->{onshelfholds},
    $sampleissuingrule2->{opacitemholds},
    $sampleissuingrule2->{cap_fine_to_replacement_price},
);
$sth->execute(
    $sampleissuingrule3->{branchcode},
    $sampleissuingrule3->{categorycode},
    $sampleissuingrule3->{itemtype},
    $sampleissuingrule3->{maxissueqty},
    $sampleissuingrule3->{maxonsiteissueqty},
    $sampleissuingrule3->{renewalsallowed},
    $sampleissuingrule3->{renewalperiod},
    $sampleissuingrule3->{norenewalbefore},
    $sampleissuingrule3->{auto_renew},
    $sampleissuingrule3->{reservesallowed},
    $sampleissuingrule3->{issuelength},
    $sampleissuingrule3->{lengthunit},
    $sampleissuingrule3->{hardduedate},
    $sampleissuingrule3->{hardduedatecompare},
    $sampleissuingrule3->{fine},
    $sampleissuingrule3->{finedays},
    $sampleissuingrule3->{firstremind},
    $sampleissuingrule3->{chargeperiod},
    $sampleissuingrule3->{chargeperiod_charge_at},
    $sampleissuingrule3->{rentaldiscount},
    $sampleissuingrule3->{overduefinescap},
    $sampleissuingrule3->{accountsent},
    $sampleissuingrule3->{reservecharge},
    $sampleissuingrule3->{chargename},
    $sampleissuingrule3->{restrictedtype},
    $sampleissuingrule3->{maxsuspensiondays},
    $sampleissuingrule3->{onshelfholds},
    $sampleissuingrule3->{opacitemholds},
    $sampleissuingrule3->{cap_fine_to_replacement_price},
);

is_deeply(
    GetIssuingRule(
        $samplecat->{categorycode},
        'Book', $samplebranch1->{branchcode}
    ),
    $sampleissuingrule1,
    "GetIssuingCharge returns issuingrule1's informations"
);

#Test GetLoanLength
is_deeply(
    C4::Circulation::GetLoanLength(
        $samplecat->{categorycode},
        'BOOK', $samplebranch1->{branchcode}
    ),
    { issuelength => 5, lengthunit => 'days', renewalperiod => 5 },
    "GetLoanLength"
);
is_deeply(
    C4::Circulation::GetLoanLength(),
    {
        issuelength   => 21,
        renewalperiod => 21,
        lengthunit    => 'days',
    },
    "Without parameters, GetLoanLength returns hardcoded values"
);
is_deeply(
    C4::Circulation::GetLoanLength( -1, -1 ),
    {
        issuelength   => 21,
        renewalperiod => 21,
        lengthunit    => 'days',
    },
    "With wrong parameters, GetLoanLength returns hardcoded values"
);
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode} ),
    {
        issuelength   => 21,
        renewalperiod => 21,
        lengthunit    => 'days',
    },
    "With only one parameter, GetLoanLength returns hardcoded values"
);    #NOTE : is that really what is expected?
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode}, 'BOOK' ),
    {
        issuelength   => 21,
        renewalperiod => 21,
        lengthunit    => 'days',
    },
    "With only two parameters, GetLoanLength returns hardcoded values"
);    #NOTE : is that really what is expected?
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode}, 'BOOK', $samplebranch1->{branchcode} ),
    {
        issuelength   => 5,
        renewalperiod => 5,
        lengthunit    => 'days',
    },
    "With the correct number of parameters, GetLoanLength returns the expected values"
);

#Test GetHardDueDate
my @hardduedate = C4::Circulation::GetHardDueDate( $samplecat->{categorycode},
    'BOOK', $samplebranch1->{branchcode} );
is_deeply(
    \@hardduedate,
    [
        dt_from_string( $sampleissuingrule1->{hardduedate}, 'iso' ),
        $sampleissuingrule1->{hardduedatecompare}
    ],
    "GetHardDueDate returns the duedate and the duedatecompare"
);

#End transaction
$dbh->rollback;
