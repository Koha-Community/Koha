#!/usr/bin/env perl

use strict;
use warnings;
use DateTime;
use Test::More tests => 14;
use Koha::DateUtils;

BEGIN {
    use_ok('Koha::Calendar');

    # This was the only test C4 had
    # Remove when no longer used
    use_ok('C4::Calendar');
}

my $cal = Koha::Calendar->new( TEST_MODE => 1 );

isa_ok( $cal, 'Koha::Calendar' );

my $test_dt = DateTime->new(    # Monday
    year      => 2012,
    month     => 7,
    day       => 23,
    hour      => 11,
    minute    => 53,
    time_zone => 'Europe/London',
);

my $later_dt = DateTime->new(    # Monday
    year      => 2012,
    month     => 9,
    day       => 17,
    hour      => 17,
    minute    => 30,
    time_zone => 'Europe/London',
);

my $daycount = $cal->days_between( $test_dt, $later_dt );
cmp_ok( $daycount->in_units('days'),
    '==', 48, 'days_between calculates correctly' );

my $ret = $cal->addDate( $test_dt, 1, 'days' );

cmp_ok( $ret->ymd(), 'eq', '2012-07-24', 'Simple Single Day Add (Calendar)`' );

$ret = $cal->addDate( $test_dt, 7, 'days' );
cmp_ok( $ret->ymd(), 'eq', '2012-07-31', 'Add 7 days Calendar mode' );
$cal->set_daysmode('Datedue');
$ret = $cal->addDate( $test_dt, 7, 'days' );
cmp_ok( $ret->ymd(), 'eq', '2012-07-30', 'Add 7 days Datedue mode' );
$cal->set_daysmode('Days');
$ret = $cal->addDate( $test_dt, 7, 'days' );
cmp_ok( $ret->ymd(), 'eq', '2012-07-30', 'Add 7 days Days mode' );
$cal->set_daysmode('Calendar');

# example tests for bug report
$cal->clear_weekly_closed_days();

$daycount = $cal->days_between( dt_from_string('2012-01-10'),
    dt_from_string("2012-05-05") )->in_units('days');
cmp_ok( $daycount, '==', 116, 'test larger intervals' );
$daycount = $cal->days_between( dt_from_string("2012-01-01"),
    dt_from_string("2012-05-05") )->in_units('days');
cmp_ok( $daycount, '==', 125, 'test positive intervals' );
my $daycount2 = $cal->days_between( dt_from_string("2012-05-05"),
    dt_from_string("2012-01-01") )->in_units('days');
cmp_ok( $daycount2, '==', $daycount, 'test parameter order not relevant' );
$daycount = $cal->days_between( dt_from_string("2012-07-01"),
    dt_from_string("2012-07-15") )->in_units('days');
cmp_ok( $daycount, '==', 14, 'days_between calculates correctly' );
$cal->add_holiday( dt_from_string('2012-07-06') );
$daycount = $cal->days_between( dt_from_string("2012-07-01"),
    dt_from_string("2012-07-15") )->in_units('days');
cmp_ok( $daycount, '==', 13, 'holiday correctly recognized' );

$cal->add_holiday( dt_from_string('2012-07-07') );
$daycount = $cal->days_between( dt_from_string("2012-07-01"),
    dt_from_string("2012-07-15") )->in_units('days');
cmp_ok( $daycount, '==', 12, 'multiple holidays correctly recognized' );
