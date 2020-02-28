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

use Test::More tests => 4;
use Time::Fake;
use t::lib::TestBuilder;

use DateTime;
use Koha::Caches;
use Koha::DateUtils;

use_ok('Koha::Calendar');

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $today = dt_from_string();
my $holiday_dt = $today->clone;
$holiday_dt->add(days => 3);

Koha::Caches->get_instance()->flush_all();

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build_object({ class => 'Koha::Libraries' });
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

my $calendar = Koha::Calendar->new( branchcode => $library->branchcode, days_mode => 'Calendar' );

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

};

$schema->storage->txn_rollback();
