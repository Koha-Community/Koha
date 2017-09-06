#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 7;
use Test::MockModule;
use DBI;
use DateTime;
use t::lib::Mocks;
use t::lib::TestBuilder;
use C4::Calendar;

use_ok('C4::Circulation');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $categorycode = 'B';
my $itemtype = 'MX';
my $branchcode = 'FPL';
my $issuelength = 10;
my $renewalperiod = 5;
my $lengthunit = 'days';

Koha::Database->schema->resultset('Issuingrule')->create({
  categorycode => $categorycode,
  itemtype => $itemtype,
  branchcode => $branchcode,
  issuelength => $issuelength,
  renewalperiod => $renewalperiod,
  lengthunit => $lengthunit,
});

#Set syspref ReturnBeforeExpiry = 1 and useDaysMode = 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'Days');

my $cache           = Koha::Caches->get_instance();
$cache->clear_from_cache('single_holidays');

my $dateexpiry = '2013-01-01';

my $borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
my $start_date = DateTime->new({year => 2013, month => 2, day => 9});
my $date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, $dateexpiry . 'T23:59:00', 'date expiry');
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );


#Set syspref ReturnBeforeExpiry = 1 and useDaysMode != 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'noDays');

$borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, $dateexpiry . 'T23:59:00', 'date expiry with useDaysMode to noDays');

# Let's add a special holiday on 2013-01-01. With ReturnBeforeExpiry and
# useDaysMode different from 'Days', return should forward the dateexpiry.
my $calendar = C4::Calendar->new(branchcode => $branchcode);
$calendar->insert_single_holiday(
    day             => 1,
    month           => 1,
    year            => 2013,
    title           =>'holidayTest',
    description     => 'holidayDesc'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2012-12-31T23:59:00', 'date expiry should be 2013-01-01 -1 day');
$calendar->insert_single_holiday(
    day             => 31,
    month           => 12,
    year            => 2012,
    title           =>'holidayTest',
    description     => 'holidayDesc'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2012-12-30T23:59:00', 'date expiry should be 2013-01-01 -2 day');


$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );


#Set syspref ReturnBeforeExpiry = 0 and useDaysMode = 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 0);
t::lib::Mocks::mock_preference('useDaysMode', 'Days');

$borrower = {categorycode => 'B', dateexpiry => $dateexpiry};
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2013-02-' . (9 + $issuelength) . 'T23:59:00', "date expiry ( 9 + $issuelength )");

$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is($date, '2013-02-' . (9 + $renewalperiod) . 'T23:59:00', "date expiry ( 9 + $renewalperiod )");

$cache->clear_from_cache('single_holidays');
$schema->storage->txn_rollback;
