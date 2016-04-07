#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 7;
use Test::MockModule;
use DBI;
use DateTime;
use t::lib::Mocks;

BEGIN {
    t::lib::Mocks::mock_dbh;
}

use_ok('C4::Circulation');

my $dbh = C4::Context->dbh();

my $issuelength = 10;
my $renewalperiod = 5;
my $lengthunit = 'days';

my $expected = {
    issuelength => $issuelength,
    renewalperiod => $renewalperiod,
    lengthunit => $lengthunit
};

my $default = {
    issuelength => 0,
    renewalperiod => 0,
    lengthunit => 'days'
};

my $loanlength;
my $mock_undef = [
    []
];

my $mock_loan_length = [
    ['issuelength', 'renewalperiod', 'lengthunit'],
    [$issuelength, $renewalperiod, $lengthunit]
];

my $categorycode = 'B';
my $itemtype = 'MX';
my $branchcode = 'FPL';

#=== GetLoanLength
$dbh->{mock_add_resultset} = $mock_loan_length;
$loanlength = C4::Circulation::GetLoanLength($categorycode, $itemtype, $branchcode);
is_deeply($loanlength, $expected, 'first matches');

$dbh->{mock_add_resultset} = $mock_undef;
$loanlength = C4::Circulation::GetLoanLength($categorycode, $itemtype, $branchcode);
is_deeply($loanlength, $default, 'none matches');

#=== CalcDateDue

#Set syspref ReturnBeforeExpiry = 1 and useDaysMode = 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'Days');

my $dateexpiry = '2013-01-01';

my $borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
my $start_date = DateTime->new({year => 2013, month => 2, day => 9});
$dbh->{mock_add_resultset} = $mock_loan_length;
my $date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, $dateexpiry . 'T23:59:00', 'date expiry');
$dbh->{mock_add_resultset} = $mock_loan_length;
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );


#Set syspref ReturnBeforeExpiry = 1 and useDaysMode != 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'noDays');

$borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$dbh->{mock_add_resultset} = $mock_loan_length;
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, $dateexpiry . 'T23:59:00', 'date expiry');

$dbh->{mock_add_resultset} = $mock_loan_length;
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );


#Set syspref ReturnBeforeExpiry = 0 and useDaysMode = 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 0);
t::lib::Mocks::mock_preference('useDaysMode', 'Days');

$borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$dbh->{mock_add_resultset} = $mock_loan_length;
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2013-02-' . (9 + $issuelength) . 'T23:59:00', "date expiry ( 9 + $issuelength )");

$dbh->{mock_add_resultset} = $mock_loan_length;
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is($date, '2013-02-' . (9 + $renewalperiod) . 'T23:59:00', "date expiry ( 9 + $renewalperiod )");
