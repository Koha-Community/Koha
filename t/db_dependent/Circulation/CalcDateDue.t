#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 19;
use Test::MockModule;
use DBI;
use DateTime;
use t::lib::Mocks;
use t::lib::TestBuilder;
use C4::Calendar qw( new insert_single_holiday delete_holiday insert_week_day_holiday );

use Koha::CirculationRules;

use_ok('C4::Circulation', qw( CalcDateDue ));

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;


my $library = $builder->build_object({ class => 'Koha::Libraries' })->store;
my $dateexpiry = '2013-01-01';
my $patron_category = $builder->build_object({ class => 'Koha::Patron::Categories', value => { category_type => 'B' } })->store;
my $borrower = $builder->build_object(
    {
        class  => 'Koha::Patrons',
        value  => {
            categorycode => $patron_category->categorycode,
            dateexpiry => $dateexpiry,
        }
    }
)->store;

my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' })->store->itemtype;
my $issuelength = 10;
my $renewalperiod = 5;
my $lengthunit = 'days';

Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        categorycode => $patron_category->categorycode,
        itemtype     => $itemtype,
        branchcode   => $library->branchcode,
        rules        => {
            issuelength   => $issuelength,
            renewalperiod => $renewalperiod,
            lengthunit    => $lengthunit,
        }
    }
);

#Set syspref ReturnBeforeExpiry = 1 and useDaysMode = 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'Days');

my $branchcode = $library->branchcode;

my $cache = Koha::Caches->get_instance();
my $key   = $branchcode . "_holidays";
$cache->clear_from_cache($key);

my $start_date = DateTime->new({year => 2013, month => 2, day => 9});
my $date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, $dateexpiry . 'T23:59:00', 'date expiry');
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );


#Set syspref ReturnBeforeExpiry = 1 and useDaysMode != 'Days'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 1);
t::lib::Mocks::mock_preference('useDaysMode', 'noDays');

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

$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2013-02-' . (9 + $issuelength) . 'T23:59:00', "date expiry ( 9 + $issuelength )");

$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is($date, '2013-02-' . (9 + $renewalperiod) . 'T23:59:00', "date expiry ( 9 + $renewalperiod )");


# Now we want to test the Dayweek useDaysMode option
# For this we need a loan period that is a mutiple of 7 days
# But, since we currently don't have that, let's test it does the
# right thing in that case, it should act as though useDaysMode is set to
# Datedue
#Set syspref ReturnBeforeExpiry = 0 and useDaysMode = 'Dayweek'
t::lib::Mocks::mock_preference('ReturnBeforeExpiry', 0);
t::lib::Mocks::mock_preference('useDaysMode', 'Dayweek');

# No closed day interfering, so we should get the regular due date
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2013-02-' . (9 + $issuelength) . 'T23:59:00', "useDaysMode = Dayweek, no closed days, issue date expiry ( start + $issuelength )");

$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is($date, '2013-02-' . (9 + $renewalperiod) . 'T23:59:00', "useDaysMode = Dayweek, no closed days, renewal date expiry ( start + $renewalperiod )");

# Now let's add a closed day on the expected renewal date, it should
# roll forward as per Datedue (i.e. one day at a time)
# For issues...
$calendar->insert_single_holiday(
    day             => 9 + $issuelength,
    month           => 2,
    year            => 2013,
    title           =>'DayweekTest1',
    description     => 'DayweekTest1'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower );
is($date, '2013-02-' . (9 + $issuelength + 1) . 'T23:59:00', "useDaysMode = Dayweek, closed on due date, 10 day loan (should not trigger 7 day roll forward), issue date expiry ( start + $issuelength  + 1 )");
# Remove the holiday we just created
$calendar->delete_holiday(
    day             => 9 + $issuelength,
    month           => 2,
    year            => 2013
);

# ...and for renewals...
$calendar->insert_single_holiday(
    day             => 9 + $renewalperiod,
    month           => 2,
    year            => 2013,
    title           =>'DayweekTest2',
    description     => 'DayweekTest2'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is($date, '2013-02-' . (9 + $renewalperiod + 1) . 'T23:59:00', "useDaysMode = Dayweek, closed on due date, 5 day renewal (should not trigger 7 day roll forward), renewal date expiry ( start + $renewalperiod  + 1 )");
# Remove the holiday we just created
$calendar->delete_holiday(
    day             => 9 + $renewalperiod,
    month           => 2,
    year            => 2013,
);

# Now we test it does the right thing if the loan and renewal periods
# are a multiple of 7 days
my $dayweek_issuelength = 14;
my $dayweek_renewalperiod = 7;
my $dayweek_lengthunit = 'days';

$patron_category = $builder->build_object({ class => 'Koha::Patron::Categories', value => { category_type => 'K' } })->store;

Koha::CirculationRules->set_rules(
    {
        categorycode => $patron_category->categorycode,
        itemtype     => $itemtype,
        branchcode   => $branchcode,
        rules        => {
            issuelength   => $dayweek_issuelength,
            renewalperiod => $dayweek_renewalperiod,
            lengthunit    => $dayweek_lengthunit,
        }
    }
);

my $dayweek_borrower = $builder->build_object(
    {
        class  => 'Koha::Patrons',
        value  => {
            categorycode => $patron_category->categorycode,
            dateexpiry => $dateexpiry,
        }
    }
);

# For issues...
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$calendar->insert_single_holiday(
    day             => 9 + $dayweek_issuelength,
    month           => 2,
    year            => 2013,
    title           =>'DayweekTest3',
    description     => 'DayweekTest3'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower );
my $issue_should_add = $dayweek_issuelength + 7;
my $dayweek_issue_expected = $start_date->add( days => $issue_should_add );
is($date, $dayweek_issue_expected->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, closed on due date, 14 day loan (should trigger 7 day roll forward), issue date expiry ( start + $issue_should_add )");
# Remove the holiday we just created
$calendar->delete_holiday(
    day             => 9 + $dayweek_issuelength,
    month           => 2,
    year            => 2013,
);

# ...and for renewals...
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$calendar->insert_single_holiday(
    day             => 9 + $dayweek_renewalperiod,
    month           => 2,
    year            => 2013,
    title           => 'DayweekTest4',
    description     => 'DayweekTest4'
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower, 1 );
my $renewal_should_add = $dayweek_renewalperiod + 7;
my $dayweek_renewal_expected = $start_date->add( days => $renewal_should_add );
is($date, $dayweek_renewal_expected->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, closed on due date, 7 day renewal (should trigger 7 day roll forward), renewal date expiry ( start + $renewal_should_add )");
# Remove the holiday we just created
$calendar->delete_holiday(
    day             => 9 + $dayweek_renewalperiod,
    month           => 2,
    year            => 2013,
);

# Now test it continues to roll forward by 7 days until it finds
# an open day, so we create a 3 week period of closed Saturdays
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
my $expected_rolled_date = DateTime->new({year => 2013, month => 3, day => 9});
my $holiday = $start_date->clone();
$holiday->add(days => 7);
$calendar->insert_single_holiday(
    day             => $holiday->day,
    month           => $holiday->month,
    year            => 2013,
    title           =>'DayweekTest5',
    description     => 'DayweekTest5'
);
$holiday->add(days => 7);
$calendar->insert_single_holiday(
    day             => $holiday->day,
    month           => $holiday->month,
    year            => 2013,
    title           =>'DayweekTest6',
    description     => 'DayweekTest6'
);
$holiday->add(days => 7);
$calendar->insert_single_holiday(
    day             => $holiday->day,
    month           => $holiday->month,
    year            => 2013,
    title           =>'DayweekTest7',
    description     => 'DayweekTest7'
);
# For issues...
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower );
$dayweek_issue_expected = $start_date->add( days => $issue_should_add );
is($date, $expected_rolled_date->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, closed on due date and two subequent due dates, 14 day loan (should trigger 2 x 7 day roll forward), issue date expiry ( start + 28 )");
# ...and for renewals...
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower, 1 );
$dayweek_issue_expected = $start_date->add( days => $renewal_should_add );
is($date, $expected_rolled_date->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, closed on due date and three subsequent due dates, 7 day renewal (should trigger 3 x 7 day roll forward), issue date expiry ( start + 28 )");
# Remove the holidays we just created
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
my $del_holiday = $start_date->clone();
$del_holiday->add(days => 7);
$calendar->delete_holiday(
    day             => $del_holiday->day,
    month           => $del_holiday->month,
    year            => 2013
);
$del_holiday->add(days => 7);
$calendar->delete_holiday(
    day             => $del_holiday->day,
    month           => $del_holiday->month,
    year            => 2013
);
$del_holiday->add(days => 7);
$calendar->delete_holiday(
    day             => $del_holiday->day,
    month           => $del_holiday->month,
    year            => 2013
);

# Now test that useDaysMode "Dayweek" doesn't try to roll forward onto
# a permanently closed day and instead rolls forward just one day
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
# Our tests are concerned with Saturdays, so let's close on Saturdays
$calendar->insert_week_day_holiday(
    weekday => 6,
    title => "Saturday closure",
    description => "Closed on Saturdays"
);
# For issues...
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower );
$dayweek_issue_expected = $start_date->add( days => $dayweek_issuelength + 1 );
is($date, $dayweek_issue_expected->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, due on Saturday, closed on Saturdays, 14 day loan (should trigger 1 day roll forward), issue date expiry ( start + 15 )");
# ...and for renewals...
$start_date = DateTime->new({year => 2013, month => 2, day => 9});
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $dayweek_borrower, 1 );
$dayweek_renewal_expected = $start_date->add( days => $dayweek_renewalperiod + 1 );
is($date, $dayweek_renewal_expected->strftime('%F') . 'T23:59:00', "useDaysMode = Dayweek, due on Saturday, closed on Saturdays, 7 day renewal (should trigger 1 day roll forward), issue date expiry ( start + 8 )");
# Remove the holiday we just created
$calendar->delete_holiday(
    weekday => 6
);

# Renewal period of 0 is valid
Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            issuelength   => 9999,
            renewalperiod => 0,
            lengthunit    => 'days',
            daysmode      => 'Days',
        }
    }
);
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is( $date->ymd, $start_date->ymd, "Dates should match for renewalperiod of 0" );

# Renewal period of "" should trigger fallover to issuelength for renewal
Koha::CirculationRules->search()->delete();
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            issuelength   => 7,
            renewalperiod => q{},
            lengthunit    => 'days',
            daysmode      => 'Days',
        }
    }
);
my $renewed_date = $start_date->clone->add( days => 7 );
$date = C4::Circulation::CalcDateDue( $start_date, $itemtype, $branchcode, $borrower, 1 );
is( $date->ymd, $renewed_date->ymd, 'Renewal period of "" should trigger fallover to issuelength for renewal' );

$cache->clear_from_cache($key);
$schema->storage->txn_rollback;
