#!/usr/bin/perl

use Modern::Perl;
use C4::Context;
use DateTime;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::CirculationRules;
use Koha::Library;

use t::lib::TestBuilder;

use Test::NoWarnings;
use Test::More tests => 10;

BEGIN {
    use_ok( 'C4::Circulation', qw( GetHardDueDate GetLoanLength ) );
}
can_ok(
    'C4::Circulation',
    qw(
        GetHardDueDate
        GetLoanLength
    )
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM edifact_ean|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM circulation_rules|);

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
};
Koha::Library->new($samplebranch1)->store;
Koha::Library->new($samplebranch2)->store;

my $samplecat = {
    categorycode          => 'CAT1',
    description           => 'Description1',
    enrolmentperiod       => undef,
    enrolmentperioddate   => undef,
    dateofbirthrequired   => undef,
    enrolmentfee          => undef,
    overduenoticerequired => undef,
    reservefee            => undef,
    hidelostitems         => 0,
    category_type         => 'A',
};
my $query =
    "INSERT INTO categories (categorycode,description,enrolmentperiod,enrolmentperioddate,dateofbirthrequired,enrolmentfee,overduenoticerequired ,reservefee ,hidelostitems ,category_type) VALUES( ?,?,?,?,?,?,?,?,?,?)";
$dbh->do(
    $query, {},
    $samplecat->{categorycode},          $samplecat->{description},
    $samplecat->{enrolmentperiod},       $samplecat->{enrolmentperioddate},
    $samplecat->{dateofbirthrequired},   $samplecat->{enrolmentfee},
    $samplecat->{overduenoticerequired}, $samplecat->{reservefee},
    $samplecat->{hidelostitems},         $samplecat->{category_type}
);

my $builder         = t::lib::TestBuilder->new;
my $sampleitemtype1 = $builder->build( { source => 'Itemtype' } )->{itemtype};
my $sampleitemtype2 = $builder->build( { source => 'Itemtype' } )->{itemtype};

#Begin Tests

my $default = {
    issuelength   => 0,
    renewalperiod => 0,
    lengthunit    => 'days'
};

#Test get_effective_rules
my $sampleissuingrule1 = {
    branchcode   => $samplebranch1->{branchcode},
    categorycode => $samplecat->{categorycode},
    itemtype     => $sampleitemtype1,
    rules        => {
        finedays                         => 0,
        lengthunit                       => 'days',
        renewalperiod                    => 5,
        norenewalbefore                  => 6,
        auto_renew                       => 0,
        issuelength                      => 5,
        chargeperiod                     => 0,
        chargeperiod_charge_at           => 0,
        rentaldiscount                   => 2,
        reservesallowed                  => 0,
        hardduedate                      => '2013-01-01',
        fine                             => 0,
        hardduedatecompare               => 5,
        overduefinescap                  => 0,
        renewalsallowed                  => 0,
        firstremind                      => 0,
        maxsuspensiondays                => 0,
        onshelfholds                     => 0,
        opacitemholds                    => 'N',
        cap_fine_to_replacement_price    => 0,
        holds_per_record                 => 1,
        article_requests                 => 'yes',
        no_auto_renewal_after            => undef,
        no_auto_renewal_after_hard_limit => undef,
        suspension_chargeperiod          => 1,
        holds_per_day                    => undef,
    }
};
my $sampleissuingrule2 = {
    branchcode   => $samplebranch2->{branchcode},
    categorycode => $samplecat->{categorycode},
    itemtype     => $sampleitemtype1,
    rules        => {
        renewalsallowed               => 0,
        renewalperiod                 => 2,
        norenewalbefore               => 7,
        auto_renew                    => 0,
        reservesallowed               => 0,
        issuelength                   => 2,
        lengthunit                    => 'days',
        hardduedate                   => 2,
        hardduedatecompare            => undef,
        fine                          => undef,
        finedays                      => undef,
        firstremind                   => undef,
        chargeperiod                  => undef,
        chargeperiod_charge_at        => 0,
        rentaldiscount                => 2.00,
        overduefinescap               => undef,
        maxsuspensiondays             => 0,
        onshelfholds                  => 1,
        opacitemholds                 => 'Y',
        cap_fine_to_replacement_price => 0,
        holds_per_record              => 1,
        article_requests              => 'yes',
    }
};
my $sampleissuingrule3 = {
    branchcode   => $samplebranch1->{branchcode},
    categorycode => $samplecat->{categorycode},
    itemtype     => $sampleitemtype2,
    rules        => {
        renewalsallowed               => 0,
        renewalperiod                 => 3,
        norenewalbefore               => 8,
        auto_renew                    => 0,
        reservesallowed               => 0,
        issuelength                   => 3,
        lengthunit                    => 'days',
        hardduedate                   => 3,
        hardduedatecompare            => undef,
        fine                          => undef,
        finedays                      => undef,
        firstremind                   => undef,
        chargeperiod                  => undef,
        chargeperiod_charge_at        => 0,
        rentaldiscount                => 3.00,
        overduefinescap               => undef,
        maxsuspensiondays             => 0,
        onshelfholds                  => 1,
        opacitemholds                 => 'F',
        cap_fine_to_replacement_price => 0,
        holds_per_record              => 1,
        article_requests              => 'yes',
    }
};

Koha::CirculationRules->set_rules($sampleissuingrule1);
Koha::CirculationRules->set_rules($sampleissuingrule2);
Koha::CirculationRules->set_rules($sampleissuingrule3);

#Test GetLoanLength
is_deeply(
    C4::Circulation::GetLoanLength(
        $samplecat->{categorycode},
        $sampleitemtype1, $samplebranch1->{branchcode}
    ),
    { issuelength => 5, lengthunit => 'days', renewalperiod => 5 },
    "GetLoanLength"
);

is_deeply(
    C4::Circulation::GetLoanLength(),
    $default,
    "Without parameters, GetLoanLength returns hardcoded values"
);
is_deeply(
    C4::Circulation::GetLoanLength( -1, -1 ),
    $default,
    "With wrong parameters, GetLoanLength returns hardcoded values"
);
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode} ),
    $default,
    "With only one parameter, GetLoanLength returns hardcoded values"
);    #NOTE : is that really what is expected?
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode}, $sampleitemtype1 ),
    $default,
    "With only two parameters, GetLoanLength returns hardcoded values"
);    #NOTE : is that really what is expected?
is_deeply(
    C4::Circulation::GetLoanLength( $samplecat->{categorycode}, $sampleitemtype1, $samplebranch1->{branchcode} ),
    {
        issuelength   => 5,
        renewalperiod => 5,
        lengthunit    => 'days',
    },
    "With the correct number of parameters, GetLoanLength returns the expected values"
);

#Test GetHardDueDate
my @hardduedate = C4::Circulation::GetHardDueDate(
    $samplecat->{categorycode},
    $sampleitemtype1, $samplebranch1->{branchcode}
);
is_deeply(
    \@hardduedate,
    [
        dt_from_string( $sampleissuingrule1->{rules}->{hardduedate}, 'iso' ),
        $sampleissuingrule1->{rules}->{hardduedatecompare}
    ],
    "GetHardDueDate returns the duedate and the duedatecompare"
);
