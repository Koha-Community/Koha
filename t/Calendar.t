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

use Test::More;
use Test::MockModule;

use DateTime;
use DateTime::Duration;
use Koha::Caches;
use Koha::DateUtils;

use t::lib::Mocks;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 39;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use_ok('Koha::Calendar');

use Test::DBIx::Class;

my $db = Test::MockModule->new('Koha::Database');
$db->mock(
    _new_schema => sub { return Schema(); }
);

# We need to mock the C4::Context->preference method for
# simplicity and re-usability of the session definition. Any
# syspref fits for syspref-agnostic tests.
my $module_context = new Test::MockModule('C4::Context');
$module_context->mock(
    'preference',
    sub {
        return 'Calendar';
    }
);

fixtures_ok [
    # weekly holidays
    RepeatableHoliday => [
        [ qw( branchcode day month weekday title description) ],
        [ 'MPL', undef, undef, 0, '', '' ], # sundays
        [ 'MPL', undef, undef, 6, '', '' ],# saturdays
        [ 'MPL', 1, 1, undef, '', ''], # new year's day
        [ 'MPL', 25, 12, undef, '', ''], # chrismas
    ],
    # exception holidays
    SpecialHoliday => [
        [qw( branchcode day month year title description isexception )],
        [ 'MPL', 11, 11, 2012, '', '', 1 ],    # sunday exception
        [ 'MPL', 1,  6,  2011, '', '', 0 ],
        [ 'MPL', 4,  7,  2012, '', '', 0 ],
        [ 'CPL', 6,  8,  2012, '', '', 0 ],
      ],
], "add fixtures";

my $cache = Koha::Caches->get_instance();
$cache->clear_from_cache( 'single_holidays' ) ;
$cache->clear_from_cache( 'exception_holidays' ) ;

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

my $holiday_for_another_branch = DateTime->new(
    year => 2012,
    month => 8,
    day => 6, # This is a monday
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

    $module_context->unmock('preference');
    $module_context->mock(
        'preference',
        sub {
            return 'Datedue';
        }
    );

    $cal = Koha::Calendar->new( branchcode => 'MPL' );

    is($cal->addDate( $dt, $one_day_dur, 'days' ), # tuesday
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

{
    $cal = Koha::Calendar->new( branchcode => 'CPL' );
    is ( $cal->is_holiday($single_holiday), 0, 'Single holiday for MPL, not CPL' );
    is ( $cal->is_holiday($holiday_for_another_branch), 1, 'Holiday defined for CPL should be defined as an holiday' );
}

subtest 'days_mode parameter' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('useDaysMode', 'Days');
    my $cal = Koha::Calendar->new( branchcode => 'CPL' );
    is( $cal->{days_mode}, 'Days', q|If not set, days_mode defaults to syspref's value|);

    $cal = Koha::Calendar->new( branchcode => 'CPL', days_mode => 'Calendar' );
    is( $cal->{days_mode}, 'Calendar', q|If set, days_mode is correctly set|);
};

END {
    $cache->clear_from_cache( 'single_holidays' ) ;
    $cache->clear_from_cache( 'exception_holidays' ) ;
};
