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

use Test::More tests => 6;
use Time::Fake;

use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;
use DateTime::Duration;
use Koha::Caches;
use Koha::Calendar;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
$schema->storage->txn_begin;

my $today = dt_from_string();
my $holiday_dt = $today->clone;
$holiday_dt->add(days => 3);

Koha::Caches->get_instance()->flush_all();

subtest 'Original tests from t' => sub {
    # We need to mock the C4::Context->preference method for
    # simplicity and re-usability of the session definition. Any
    # syspref fits for syspref-agnostic tests.
    my $module_context = Test::MockModule->new('C4::Context');
    $module_context->mock(
        'preference',
        sub {
            return 'Calendar';
        }
    );

    my $mpl = $builder->build_object({ class => 'Koha::Libraries' })->branchcode;
    my $cpl = $builder->build_object({ class => 'Koha::Libraries' })->branchcode;
    my $rows = [ # add weekly holidays
        { branchcode => $mpl, weekday => 0 }, # sundays
        { branchcode => $mpl, weekday => 6 }, # saturdays
        { branchcode => $mpl, day => 1, month => 1 },      # new year's day
        { branchcode => $mpl, day => 25, month => 12 },    # chrismas
    ];
    $schema->resultset('RepeatableHoliday')->delete_all;
    $schema->resultset('RepeatableHoliday')->create({ %$_, description => q{} }) for @$rows;

    $rows = [ # exception holidays
        { branchcode => $mpl, day => 11, month => 11, year => 2012, isexception => 1 },    # sunday exception
        { branchcode => $mpl, day => 1,  month => 6,  year => 2011, isexception => 0 },
        { branchcode => $mpl, day => 4,  month => 7,  year => 2012, isexception => 0 },
        { branchcode => $cpl, day => 6,  month => 8,  year => 2012, isexception => 0 },
        { branchcode => $mpl, day => 7,  month => 7,  year => 2012, isexception => 1 }, # holiday exception
        { branchcode => $mpl, day => 7,  month => 7,  year => 2012, isexception => 0 }, # holiday
    ];
    $schema->resultset('SpecialHoliday')->delete_all;
    $schema->resultset('SpecialHoliday')->create({ %$_, description => q{} }) for @$rows;

    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache( $mpl.'_holidays' );
    $cache->clear_from_cache( $cpl.'_holidays' );

    # $mpl branch is arbitrary, is not used at all but is needed for initialization
    my $cal = Koha::Calendar->new( branchcode => $mpl );

    isa_ok( $cal, 'Koha::Calendar', 'Calendar class returned' );

    my $saturday = DateTime->new(
        year      => 2012,
        month     => 11,
        day       => 24,
    );

    my $sunday = DateTime->new(
        year      => 2012,
        month     => 11,
        day       => 25,
    );

    my $monday = DateTime->new(
        year      => 2012,
        month     => 11,
        day       => 26,
    );

    my $new_year = DateTime->new(
        year        => 2013,
        month       => 1,
        day         => 1,
    );

    my $single_holiday = DateTime->new(
        year      => 2011,
        month     => 6,
        day       => 1,
    );    # should be a holiday

    my $notspecial = DateTime->new(
        year      => 2011,
        month     => 6,
        day       => 2
    );    # should NOT be a holiday

    my $sunday_exception = DateTime->new(
        year      => 2012,
        month     => 11,
        day       => 11
    );

    my $day_after_christmas = DateTime->new(
        year    => 2012,
        month   => 12,
        day     => 26
    );  # for testing negative addDuration

    my $holiday_for_another_branch = DateTime->new(
        year => 2012,
        month => 8,
        day => 6, # This is a monday
    );

    my $holiday_excepted = DateTime->new(
        year => 2012,
        month => 7,
        day => 7, # Both a holiday and exception
    );

    {   # Syspref-agnostic tests
        is ( $saturday->day_of_week, 6, '\'$saturday\' is actually a saturday (6th day of week)');
        is ( $sunday->day_of_week, 7, '\'$sunday\' is actually a sunday (7th day of week)');
        is ( $monday->day_of_week, 1, '\'$monday\' is actually a monday (1st day of week)');
        is ( $cal->is_holiday($saturday), 1, 'Saturday is a closed day' );
        is ( $cal->is_holiday($sunday), 1, 'Sunday is a closed day' );
        is ( $cal->is_holiday($monday), 0, 'Monday is not a closed day' );
        is ( $cal->is_holiday($new_year), 1, 'Month/Day closed day test (New year\'s day)' );
        is ( $cal->is_holiday($single_holiday), 1, 'Single holiday closed day test' );
        is ( $cal->is_holiday($notspecial), 0, 'Fixed single date that is not a holiday test' );
        is ( $cal->is_holiday($sunday_exception), 0, 'Exception holiday is not a closed day test' );
        is ( $cal->is_holiday($holiday_for_another_branch), 0, 'Holiday defined for another branch should not be defined as an holiday' );
        is ( $cal->is_holiday($holiday_excepted), 0, 'Holiday defined and excepted should not be a holiday' );
    }

    {   # Bugzilla #8966 - is_holiday truncates referenced date
        my $later_dt = DateTime->new(    # Monday
            year      => 2012,
            month     => 9,
            day       => 17,
            hour      => 17,
            minute    => 30,
            time_zone => 'Europe/London',
        );


        is( $cal->is_holiday($later_dt), 0, 'bz-8966 (1/2) Apply is_holiday for the next test' );
        cmp_ok( $later_dt, 'eq', '2012-09-17T17:30:00', 'bz-8966 (2/2) Date should be the same after is_holiday' );
    }

    {   # Bugzilla #8800 - is_holiday should use truncated date for 'contains' call
        my $single_holiday_time = DateTime->new(
            year  => 2011,
            month => 6,
            day   => 1,
            hour  => 11,
            minute  => 2
        );

        is( $cal->is_holiday($single_holiday_time),
            $cal->is_holiday($single_holiday) ,
            'bz-8800 is_holiday should truncate the date for holiday validation' );
    }

        my $one_day_dur = DateTime::Duration->new( days => 1 );
        my $two_day_dur = DateTime::Duration->new( days => 2 );
        my $seven_day_dur = DateTime::Duration->new( days => 7 );

        my $dt = dt_from_string( '2012-07-03','iso' ); #tuesday

        my $test_dt = DateTime->new(    # Monday
            year      => 2012,
            month     => 7,
            day       => 23,
            hour      => 11,
            minute    => 53,
        );

        my $later_dt = DateTime->new(    # Monday
            year      => 2012,
            month     => 9,
            day       => 17,
            hour      => 17,
            minute    => 30,
            time_zone => 'Europe/London',
        );

    {    ## 'Datedue' tests

        $cal = Koha::Calendar->new( branchcode => $mpl, days_mode => 'Datedue' );

        is($cal->addDuration( $dt, $one_day_dur, 'days' ), # tuesday
            dt_from_string('2012-07-05','iso'),
            'Single day add (Datedue, matches holiday, shift)' );

        is($cal->addDuration( $dt, $two_day_dur, 'days' ),
            dt_from_string('2012-07-05','iso'),
            'Two days add, skips holiday (Datedue)' );

        cmp_ok($cal->addDuration( $test_dt, $seven_day_dur, 'days' ), 'eq',
            '2012-07-30T11:53:00',
            'Add 7 days (Datedue)' );

        is( $cal->addDuration( $saturday, $one_day_dur, 'days' )->day_of_week, 1,
            'addDuration skips closed Sunday (Datedue)' );

        is( $cal->addDuration($day_after_christmas, -1, 'days')->ymd(), '2012-12-24',
            'Negative call to addDuration (Datedue)' );

        ## Note that the days_between API says closed days are not considered.
        ## This tests are here as an API test.
        cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                    '==', 40, 'days_between calculates correctly (Days)' );

        cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                    '==', 40, 'Test parameter order not relevant (Days)' );
    }

    {   ## 'Calendar' tests'

        $cal = Koha::Calendar->new( branchcode => $mpl, days_mode => 'Calendar' );

        $dt = dt_from_string('2012-07-03','iso');

        is($cal->addDuration( $dt, $one_day_dur, 'days' ),
            dt_from_string('2012-07-05','iso'),
            'Single day add (Calendar)' );

        cmp_ok($cal->addDuration( $test_dt, $seven_day_dur, 'days' ), 'eq',
           '2012-08-01T11:53:00',
           'Add 7 days (Calendar)' );

        is( $cal->addDuration( $saturday, $one_day_dur, 'days' )->day_of_week, 1,
                'addDuration skips closed Sunday (Calendar)' );

        is( $cal->addDuration($day_after_christmas, -1, 'days')->ymd(), '2012-12-24',
                'Negative call to addDuration (Calendar)' );

        cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                    '==', 40, 'days_between calculates correctly (Calendar)' );

        cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                    '==', 40, 'Test parameter order not relevant (Calendar)' );
    }


    {   ## 'Days' tests

        $cal = Koha::Calendar->new( branchcode => $mpl, days_mode => 'Days' );

        $dt = dt_from_string('2012-07-03','iso');

        is($cal->addDuration( $dt, $one_day_dur, 'days' ),
            dt_from_string('2012-07-04','iso'),
            'Single day add (Days)' );

        cmp_ok($cal->addDuration( $test_dt, $seven_day_dur, 'days' ),'eq',
            '2012-07-30T11:53:00',
            'Add 7 days (Days)' );

        is( $cal->addDuration( $saturday, $one_day_dur, 'days' )->day_of_week, 7,
            'addDuration doesn\'t skip closed Sunday (Days)' );

        is( $cal->addDuration($day_after_christmas, -1, 'days')->ymd(), '2012-12-25',
            'Negative call to addDuration (Days)' );

        ## Note that the days_between API says closed days are not considered.
        ## This tests are here as an API test.
        cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                    '==', 40, 'days_between calculates correctly (Days)' );

        cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                    '==', 40, 'Test parameter order not relevant (Days)' );

    }

    {
        $cal = Koha::Calendar->new( branchcode => $cpl );
        is ( $cal->is_holiday($single_holiday), 0, 'Single holiday for MPL, not CPL' );
        is ( $cal->is_holiday($holiday_for_another_branch), 1, 'Holiday defined for CPL should be defined as an holiday' );
    }

    subtest 'days_mode parameter' => sub {
        plan tests => 1;

        t::lib::Mocks::mock_preference('useDaysMode', 'Days');

        $cal = Koha::Calendar->new( branchcode => $cpl, days_mode => 'Calendar' );
        is( $cal->{days_mode}, 'Calendar', q|If set, days_mode is correctly set|);
    };

    $cache->clear_from_cache( $mpl.'_holidays' );
    $cache->clear_from_cache( $cpl.'_holidays' );
};

my $library = $builder->build_object({ class => 'Koha::Libraries' });
my $calendar = Koha::Calendar->new( branchcode => $library->branchcode, days_mode => 'Calendar' );
my $holiday = $builder->build(
    {
        source => 'SpecialHoliday',
        value  => {
            branchcode  => $library->branchcode,
            day         => $holiday_dt->day,
            month       => $holiday_dt->month,
            year        => $holiday_dt->year,
            title       => 'My holiday',
            isexception => 0
        },
    }
);

subtest 'days_forward' => sub {
    plan tests => 4;

    my $forwarded_dt = $calendar->days_forward( $today, 2 );
    my $expected = $today->clone->add( days => 2 );
    is( $forwarded_dt->ymd, $expected->ymd, 'With no holiday on the perioddays_forward should add 2 days' );

    $forwarded_dt = $calendar->days_forward( $today, 5 );
    $expected = $today->clone->add( days => 6 );
    is( $forwarded_dt->ymd, $expected->ymd, 'With holiday on the perioddays_forward should add 5 days + 1 day for holiday'
    );

    $forwarded_dt = $calendar->days_forward( $today, 0 );
    is( $forwarded_dt->ymd, $today->ymd, '0 day should return start dt' );

    $forwarded_dt = $calendar->days_forward( $today, -2 );
    is( $forwarded_dt->ymd, $today->ymd, 'negative day should return start dt' );
};

subtest 'crossing_DST' => sub {

    plan tests => 3;

    my $tz = DateTime::TimeZone->new( name => 'America/New_York' );
    my $start_date = dt_from_string( "2016-03-09 02:29:00", undef, $tz );
    my $end_date   = dt_from_string( "2017-01-01 00:00:00", undef, $tz );
    my $days_between = $calendar->days_between( $start_date, $end_date );
    is( $days_between->delta_days, 298, "Days calculated correctly" );
    $days_between = $calendar->days_between( $end_date, $start_date );
    is( $days_between->delta_days, 298, "Swapping returns the same" );
    my $hours_between = $calendar->hours_between( $start_date, $end_date );
    is(
        $hours_between->delta_minutes,
        298 * 24 * 60 - 149,
        "Hours (in minutes) calculated correctly"
    );
};

subtest 'hours_between | days_between' => sub {

    plan tests => 2;

    #    November 2019
    # Su Mo Tu We Th Fr Sa
    #                 1  2
    #  3  4 *5* 6  7  8  9
    # 10 11 12 13 14 15 16
    # 17 18 19 20 21 22 23
    # 24 25 26 27 28 29 30

    my $now    = dt_from_string('2019-11-05 12:34:56'); # Today is 2019 Nov 5th
    my $nov_6  = dt_from_string('2019-11-06 12:34:56');
    my $nov_7  = dt_from_string('2019-11-07 12:34:56');
    my $nov_12 = dt_from_string('2019-11-12 12:34:56');
    my $nov_13 = dt_from_string('2019-11-13 12:34:56');
    my $nov_15 = dt_from_string('2019-11-15 12:34:56');
    Time::Fake->offset($now->epoch);

    subtest 'No holiday' => sub {

        plan tests => 2;

        my $library = $builder->build_object({ class => 'Koha::Libraries' });
        my $calendar = Koha::Calendar->new( branchcode => $library->branchcode );

        subtest 'Same hours' => sub {

            plan tests => 8;

            # Between 5th and 6th
            my $diff_hours = $calendar->hours_between( $now, $nov_6 )->hours;
            is( $diff_hours, 1 * 24, 'hours: 1 day, no holiday' );
            my $diff_days = $calendar->days_between( $now, $nov_6 )->delta_days;
            is( $diff_days, 1, 'days: 1 day, no holiday' );

            # Between 5th and 7th
            $diff_hours = $calendar->hours_between( $now, $nov_7 )->hours;
            is( $diff_hours, 2 * 24, 'hours: 2 days, no holiday' );
            $diff_days = $calendar->days_between( $now, $nov_7 )->delta_days;
            is( $diff_days, 2, 'days: 2 days, no holiday' );

            # Between 5th and 12th
            $diff_hours = $calendar->hours_between( $now, $nov_12 )->hours;
            is( $diff_hours, 7 * 24, 'hours: 7 days, no holiday' );
            $diff_days = $calendar->days_between( $now, $nov_12 )->delta_days;
            is( $diff_days, 7, 'days: 7 days, no holiday' );

            # Between 5th and 15th
            $diff_hours = $calendar->hours_between( $now, $nov_15 )->hours;
            is( $diff_hours, 10 * 24, 'hours: 10 days, no holiday' );
            $diff_days = $calendar->days_between( $now, $nov_15 )->delta_days;
            is( $diff_days, 10, 'days: 10 days, no holiday' );
        };

        subtest 'Different hours' => sub {

            plan tests => 10;

            # Between 5th and 5th (Same day short hours loan)
            my $diff_hours = $calendar->hours_between( $now, $now->clone->add(hours => 3) )->hours;
            is( $diff_hours, 3, 'hours: 3 hours, no holidays' );
            my $diff_days = $calendar->days_between( $now, $now->clone->add(hours => 3) )->delta_days;
            is( $diff_days, 0, 'days: 3 hours, no holidays' );

            # Between 5th and 6th
            $diff_hours = $calendar->hours_between( $now, $nov_6->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 1 * 24 - 3, 'hours: 21 hours, no holidays' );
            $diff_days = $calendar->days_between( $now, $nov_6->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 1, 'days: 21 hours, no holidays' );

            # Between 5th and 7th
            $diff_hours = $calendar->hours_between( $now, $nov_7->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 2 * 24 - 3, 'hours: 45 hours, no holidays' );
            $diff_days = $calendar->days_between( $now, $nov_7->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 2, 'days: 45 hours, no holidays' );

            # Between 5th and 12th
            $diff_hours = $calendar->hours_between( $now, $nov_12->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 7 * 24 - 3, 'hours: 165 hours, no holidays' );
            $diff_days = $calendar->days_between( $now, $nov_12->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 7, 'days: 165 hours, no holidays' );

            # Between 5th and 15th
            $diff_hours = $calendar->hours_between( $now, $nov_15->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 10 * 24 - 3, 'hours: 237 hours, no holidays' );
            $diff_days = $calendar->days_between( $now, $nov_15->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 10, 'days: 237 hours, no holidays' );
        };
    };

    subtest 'With holiday' => sub {
        plan tests => 2;

        my $library = $builder->build_object({ class => 'Koha::Libraries' });

        # Wednesdays are closed
        my $dbh = C4::Context->dbh;
        $dbh->do(q|
            INSERT INTO repeatable_holidays (branchcode,weekday,day,month,title,description)
            VALUES ( ?, ?, NULL, NULL, ?, '' )
        |, undef, $library->branchcode, 3, 'Closed on Wednesday');

        my $calendar = Koha::Calendar->new( branchcode => $library->branchcode );

        subtest 'Same hours' => sub {
            plan tests => 12;

            my ( $diff_hours, $diff_days );

            # Between 5th and 6th (This case should never happen in real code, one cannot return on a closed day)
            $diff_hours = $calendar->hours_between( $now, $nov_6 )->hours;
            is( $diff_hours, 0 * 24, 'hours: 1 day, end_dt = holiday' ); # FIXME Is this really should be 0?
            $diff_days = $calendar->days_between( $now, $nov_6)->delta_days;
            is( $diff_days, 0, 'days: 1 day, end_dt = holiday' ); # FIXME Is this really should be 0?

            # Between 6th and 7th (This case should never happen in real code, one cannot issue on a closed day)
            $diff_hours = $calendar->hours_between( $nov_6, $nov_7 )->hours;
            is( $diff_hours, 0 * 24, 'hours: 1 day, start_dt = holiday' ); # FIXME Is this really should be 0?
            $diff_days = $calendar->days_between( $nov_6, $nov_7 )->delta_days;
            is( $diff_days, 0, 'days: 1 day, start_dt = holiday' ); # FIXME Is this really should be 0?

            # Between 5th and 7th
            $diff_hours = $calendar->hours_between( $now, $nov_7 )->hours;
            is( $diff_hours, 2 * 24 - 1 * 24, 'hours: 2 days, 1 holiday' );
            $diff_days = $calendar->days_between( $now, $nov_7 )->delta_days;
            is( $diff_days, 2 - 1, 'days: 2 days, 1 holiday' );

            # Between 5th and 12th
            $diff_hours = $calendar->hours_between( $now, $nov_12 )->hours;
            is( $diff_hours, 7 * 24 - 1 * 24, 'hours: 7 days, 1 holiday' );
            $diff_days = $calendar->days_between( $now, $nov_12)->delta_days;
            is( $diff_days, 7 - 1, 'day: 7 days, 1 holiday' );

            # Between 5th and 13th
            $diff_hours = $calendar->hours_between( $now, $nov_13 )->hours;
            is( $diff_hours, 8 * 24 - 2 * 24, 'hours: 8 days, 2 holidays' );
            $diff_days = $calendar->days_between( $now, $nov_13)->delta_days;
            is( $diff_days, 8 - 2, 'days: 8 days, 2 holidays' );

            # Between 5th and 15th
            $diff_hours = $calendar->hours_between( $now, $nov_15 )->hours;
            is( $diff_hours, 10 * 24 - 2 * 24, 'hours: 10 days, 2 holidays' );
            $diff_days = $calendar->days_between( $now, $nov_15)->delta_days;
            is( $diff_days, 10 - 2, 'days: 10 days, 2 holidays' );
        };

        subtest 'Different hours' => sub {
            plan tests => 14;

            my ( $diff_hours, $diff_days );

            # Between 5th and 5th (Same day short hours loan)
            # No test - Tested above as 5th is an open day

            # Between 5th and 6th (This case should never happen in real code, one cannot return on a closed day)
            my $duration = $calendar->hours_between( $now, $nov_6->clone->subtract(hours => 3) );
            is( $duration->hours, abs(0 * 24 - 3), 'hours: 21 hours, end_dt = holiday' ); # FIXME $duration->hours always return a abs
            is( $duration->is_negative, 1, '? is negative ?' ); # FIXME Do really test for that case in our calls to hours_between?
            $duration = $calendar->days_between( $now, $nov_6->clone->subtract(hours => 3) );
            is( $duration->hours, abs(0), 'days: 21 hours, end_dt = holiday' ); # FIXME Is this correct?

            # Between 6th and 7th (This case should never happen in real code, one cannot issue on a closed day)
            $duration = $calendar->hours_between( $nov_6, $nov_7->clone->subtract(hours => 3) );
            is( $duration->hours, abs(0 * 24 - 3), 'hours: 21 hours, start_dt = holiday' ); # FIXME $duration->hours always return a abs
            is( $duration->is_negative, 1, '? is negative ?' ); # FIXME Do really test for that case in our calls to hours_between?
            $duration = $calendar->days_between( $nov_6, $nov_7->clone->subtract(hours => 3) );
            is( $duration->hours, abs(0), 'days: 21 hours, start_dt = holiday' ); # FIXME Is this correct?

            # Between 5th and 7th
            $diff_hours = $calendar->hours_between( $now, $nov_7->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 2 * 24 - 1 * 24 - 3, 'hours: 45 hours, 1 holiday' );
            $diff_days = $calendar->days_between( $now, $nov_7->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 2 - 1, 'days: 45 hours, 1 holiday' );

            # Between 5th and 12th
            $diff_hours = $calendar->hours_between( $now, $nov_12->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 7 * 24 - 1 * 24 - 3, 'hours: 165 hours, 1 holiday' );
            $diff_days = $calendar->days_between( $now, $nov_12->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 7 - 1, 'days: 165 hours, 1 holiday' );

            # Between 5th and 13th
            $diff_hours = $calendar->hours_between( $now, $nov_13->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 8 * 24 - 2 * 24 - 3, 'hours: 289 hours, 2 holidays ' );
            $diff_days = $calendar->days_between( $now, $nov_13->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 8 - 1, 'days: 289 hours, 2 holidays' );

            # Between 5th and 15th
            $diff_hours = $calendar->hours_between( $now, $nov_15->clone->subtract(hours => 3) )->hours;
            is( $diff_hours, 10 * 24 - 2 * 24 - 3, 'hours: 237 hours, 2 holidays' );
            $diff_days = $calendar->days_between( $now, $nov_15->clone->subtract(hours => 3) )->delta_days;
            is( $diff_days, 10 - 2, 'days: 237 hours, 2 holidays' );
        };

    };

    Time::Fake->reset;
};

subtest 'is_holiday' => sub {
    plan tests => 1;

    subtest 'weekday holidays' => sub {
        plan tests => 7;

        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $day = dt_from_string();
        my $dow = scalar $day->day_of_week;
        $dow = 0 if $dow == 7;

        # Closed this day of the week
        my $dbh = C4::Context->dbh;
        $dbh->do(
            q|
            INSERT INTO repeatable_holidays (branchcode,weekday,day,month,title,description)
            VALUES ( ?, ?, NULL, NULL, ?, '' )
        |, undef, $library->branchcode, $dow, "TEST"
        );

        # Iterate 7 days
        my $sth = $dbh->prepare(
"UPDATE repeatable_holidays SET weekday = ? WHERE branchcode = ? AND title = 'TEST'"
        );
        for my $i ( 0 .. 6 ) {
            my $calendar =
              Koha::Calendar->new( branchcode => $library->branchcode );

            is( $calendar->is_holiday($day), 1, $day->day_name() ." works as a repeatable holiday");

            # Increment the date and holiday day
            $day->add( days => 1 );
            $dow++;
            $dow = 0 if $dow == 7;
            $sth->execute($dow, $library->branchcode);
        }
    };
};

subtest 'get_push_amt' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference('useDaysMode', 'Dayweek');

    subtest 'weekday holidays' => sub {
        plan tests => 7;

        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $day = dt_from_string();
        my $dow = scalar $day->day_of_week;
        $dow = 0 if $dow == 7;

        # Closed this day of the week
        my $dbh = C4::Context->dbh;
        $dbh->do(
            q|
            INSERT INTO repeatable_holidays (branchcode,weekday,day,month,title,description)
            VALUES ( ?, ?, NULL, NULL, ?, '' )
        |, undef, $library->branchcode, $dow, "TEST"
        );

        # Iterate 7 days
        my $sth = $dbh->prepare(
"UPDATE repeatable_holidays SET weekday = ? WHERE branchcode = ? AND title = 'TEST'"
        );
        for my $i ( 0 .. 6 ) {
            my $calendar =
              Koha::Calendar->new( branchcode => $library->branchcode, days_mode => 'Dayweek' );

            my $npa;
            eval {
                local $SIG{ALRM} = sub { die "alarm\n" };    # NB: \n required
                alarm 2;
                $npa = $calendar->next_open_days( $day, 0 );
                alarm 0;
            };
            if ($@) {
                die unless $@ eq "alarm\n";    # propagate unexpected errors
                # timed out
                ok(0, "next_push_amt succeeded for ".$day->day_name()." weekday holiday");
            }
            else {
                ok($npa, "next_push_amt succeeded for ".$day->day_name()." weekday holiday");
            }

            # Increment the date and holiday day
            $day->add( days => 1 );
            $dow++;
            $dow = 0 if $dow == 7;
            $sth->execute( $dow, $library->branchcode );
        }
    };
};

$schema->storage->txn_rollback();
