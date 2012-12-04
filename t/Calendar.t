#!/usr/bin/env perl

use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Test::More tests => 35;
use Test::MockModule;
use DBD::Mock;
use Koha::DateUtils;

BEGIN {
    use_ok('Koha::Calendar');

    # This was the only test C4 had
    # Remove when no longer used
    use_ok('C4::Calendar');
}

my $module_context = new Test::MockModule('C4::Context');
$module_context->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);

# We need to mock the C4::Context->preference method for
# simplicity and re-usability of the session definition. Any
# syspref fits for syspref-agnostic tests.
$module_context->mock(
    'preference',
    sub {
        return 'Calendar';
    }
);


my $holidays_session = DBD::Mock::Session->new('holidays_session' => (
    { # weekly holidays
        statement => "SELECT weekday FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NOT NULL",
        results   => [
                        ['weekday'],
                        [0],    # sundays
                        [6]     # saturdays
                     ]
    },
    { # day and month repeatable holidays
        statement => "SELECT day, month FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NULL",
        results   => [
                        [ 'month', 'day' ],
                        [ 1, 1 ],   # new year's day
                        [12,25]     # christmas
                     ]
    },
    { # exception holidays
        statement => "SELECT day, month, year FROM special_holidays WHERE branchcode = ? AND isexception = 1",
        results   => [
                        [ 'day', 'month', 'year' ],
                        [ 11, 11, 2012 ] # sunday exception
                     ]
    },
    { # single holidays
        statement => "SELECT day, month, year FROM special_holidays WHERE branchcode = ? AND isexception = 0",
        results   => [
                        [ 'day', 'month', 'year' ],
                        [ 1, 6, 2011 ],  # single holiday
                        [ 4, 7, 2012 ]
                     ]
    }
));

# Initialize the global $dbh variable
my $dbh = C4::Context->dbh();
# Apply the mock session
$dbh->{ mock_session } = $holidays_session;
# 'MPL' branch is arbitrary, is not used at all but is needed for initialization
my $cal = Koha::Calendar->new( branchcode => 'MPL' );

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
);  # for testing negative addDate


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

    my $dt = dt_from_string( '2012-07-03','iso' );
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

    $module_context->unmock('preference');
    $module_context->mock(
        'preference',
        sub {
            return 'Datedue';
        }
    );
    # rewind dbh session
    $holidays_session->reset;


    $cal = Koha::Calendar->new( branchcode => 'MPL' );

    is($cal->addDate( $dt, $one_day_dur, 'days' ),
        dt_from_string('2012-07-05','iso'),
        'Single day add (Datedue, matches holiday, shift)' );

    is($cal->addDate( $dt, $two_day_dur, 'days' ),
        dt_from_string('2012-07-05','iso'),
        'Two days add, skips holiday (Datedue)' );

    cmp_ok($cal->addDate( $test_dt, $seven_day_dur, 'days' ), 'eq',
        '2012-07-30T11:53:00',
        'Add 7 days (Datedue)' );

    is( $cal->addDate( $saturday, $one_day_dur, 'days' )->day_of_week, 1,
        'addDate skips closed Sunday (Datedue)' );

    is( $cal->addDate($day_after_christmas, -1, 'days')->ymd(), '2012-12-24',
        'Negative call to addDate (Datedue)' );

    ## Note that the days_between API says closed days are not considered.
    ## This tests are here as an API test.
    cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                '==', 40, 'days_between calculates correctly (Days)' );

    cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                '==', 40, 'Test parameter order not relevant (Days)' );


}


{   ## 'Calendar' tests'

    $module_context->unmock('preference');
    $module_context->mock(
        'preference',
        sub {
            return 'Calendar';
        }
    );
    # rewind dbh session
    $holidays_session->reset;

    $cal = Koha::Calendar->new( branchcode => 'MPL' );

    $dt = dt_from_string('2012-07-03','iso');

    is($cal->addDate( $dt, $one_day_dur, 'days' ),
        dt_from_string('2012-07-05','iso'),
        'Single day add (Calendar)' );

    cmp_ok($cal->addDate( $test_dt, $seven_day_dur, 'days' ), 'eq',
       '2012-08-01T11:53:00',
       'Add 7 days (Calendar)' );

    is( $cal->addDate( $saturday, $one_day_dur, 'days' )->day_of_week, 1,
            'addDate skips closed Sunday (Calendar)' );

    is( $cal->addDate($day_after_christmas, -1, 'days')->ymd(), '2012-12-24',
            'Negative call to addDate (Calendar)' );

    cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                '==', 40, 'days_between calculates correctly (Calendar)' );

    cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                '==', 40, 'Test parameter order not relevant (Calendar)' );
}


{   ## 'Days' tests
    $module_context->unmock('preference');
    $module_context->mock(
        'preference',
        sub {
            return 'Days';
        }
    );
    # rewind dbh session
    $holidays_session->reset;

    $cal = Koha::Calendar->new( branchcode => 'MPL' );

    $dt = dt_from_string('2012-07-03','iso');

    is($cal->addDate( $dt, $one_day_dur, 'days' ),
        dt_from_string('2012-07-04','iso'),
        'Single day add (Days)' );

    cmp_ok($cal->addDate( $test_dt, $seven_day_dur, 'days' ),'eq',
        '2012-07-30T11:53:00',
        'Add 7 days (Days)' );

    is( $cal->addDate( $saturday, $one_day_dur, 'days' )->day_of_week, 7,
        'addDate doesn\'t skip closed Sunday (Days)' );

    is( $cal->addDate($day_after_christmas, -1, 'days')->ymd(), '2012-12-25',
        'Negative call to addDate (Days)' );

    ## Note that the days_between API says closed days are not considered.
    ## This tests are here as an API test.
    cmp_ok( $cal->days_between( $test_dt, $later_dt )->in_units('days'),
                '==', 40, 'days_between calculates correctly (Days)' );

    cmp_ok( $cal->days_between( $later_dt, $test_dt )->in_units('days'),
                '==', 40, 'Test parameter order not relevant (Days)' );

}
