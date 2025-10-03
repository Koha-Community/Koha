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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 15;
use Test::Exception;

use DateTime;
use DateTime::TimeZone;

use t::lib::TestBuilder;
use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

BEGIN {
    use_ok('Koha::Calendar');
    use_ok('C4::Calendar');
}

my $schema  = Koha::Database->new->schema;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

subtest 'is_holiday timezone tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    $dbh->do("DELETE FROM special_holidays");

    # Clear cache
    Koha::Caches->get_instance->flush_all;

    # Artificially set timezone
    my $timezone = 'America/Santiago';
    $ENV{TZ} = $timezone;
    use POSIX qw(tzset);
    tzset;

    my $branch   = $builder->build( { source => 'Branch' } )->{branchcode};
    my $calendar = Koha::Calendar->new( branchcode => $branch );

    C4::Calendar->new( branchcode => $branch )->insert_exception_holiday(
        day         => 6,
        month       => 9,
        year        => 2015,
        title       => 'Invalid date',
        description => 'Invalid date description',
    );

    my $exception_holiday = DateTime->new( day => 6, month => 9, year => 2015 );
    my $now_dt            = DateTime->now;

    my $diff;
    eval { $diff = $calendar->days_between( $now_dt, $exception_holiday ) };
    unlike(
        $@,
        qr/Invalid local time for date in time zone: America\/Santiago/,
        'Avoid invalid datetime due to DST'
    );

    $schema->storage->txn_rollback;
};

$schema->storage->txn_begin;

# Create two fresh branches for the tests
my $branch_1 = $builder->build( { source => 'Branch' } )->{branchcode};
my $branch_2 = $builder->build( { source => 'Branch' } )->{branchcode};

C4::Calendar->new( branchcode => $branch_1 )->insert_week_day_holiday(
    weekday     => 0,
    title       => '',
    description => 'Sundays',
);

my $holiday2add = dt_from_string("2015-01-01");
C4::Calendar->new( branchcode => $branch_1 )->insert_day_month_holiday(
    day         => $holiday2add->day(),
    month       => $holiday2add->month(),
    year        => $holiday2add->year(),
    title       => '',
    description => "New Year's Day",
);
$holiday2add = dt_from_string("2014-12-25");
C4::Calendar->new( branchcode => $branch_1 )->insert_day_month_holiday(
    day         => $holiday2add->day(),
    month       => $holiday2add->month(),
    year        => $holiday2add->year(),
    title       => '',
    description => 'Christmas',
);

my $koha_calendar = Koha::Calendar->new( branchcode => $branch_1 );
my $c4_calendar   = C4::Calendar->new( branchcode => $branch_1 );

isa_ok( $koha_calendar, 'Koha::Calendar', 'Koha::Calendar class returned' );
isa_ok( $c4_calendar,   'C4::Calendar',   'C4::Calendar class returned' );

my $sunday = DateTime->new(
    year  => 2011,
    month => 6,
    day   => 26,
);
my $monday = DateTime->new(
    year  => 2011,
    month => 6,
    day   => 27,
);
my $christmas = DateTime->new(
    year  => 2032,
    month => 12,
    day   => 25,
);
my $newyear = DateTime->new(
    year  => 2035,
    month => 1,
    day   => 1,
);

is( $koha_calendar->is_holiday($sunday),    1, 'Sunday is a closed day' );
is( $koha_calendar->is_holiday($monday),    0, 'Monday is not a closed day' );
is( $koha_calendar->is_holiday($christmas), 1, 'Christmas is a closed day' );
is( $koha_calendar->is_holiday($newyear),   1, 'New Years day is a closed day' );

$dbh->do("DELETE FROM repeatable_holidays");
$dbh->do("DELETE FROM special_holidays");

my $custom_holiday = DateTime->new(
    year  => 2013,
    month => 11,
    day   => 12,
);

my $today = dt_from_string();
C4::Calendar->new( branchcode => $branch_2 )->insert_single_holiday(
    day         => $today->day(),
    month       => $today->month(),
    year        => $today->year(),
    title       => "$today",
    description => "$today",
);

is( Koha::Calendar->new( branchcode => $branch_2 )->is_holiday($today), 1, "Today is a holiday for $branch_2" );
is( Koha::Calendar->new( branchcode => $branch_1 )->is_holiday($today), 0, "Today is not a holiday for $branch_1" );

$schema->storage->txn_rollback;

subtest 'copy_to_branch' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $branch1   = $builder->build( { source => 'Branch' } )->{branchcode};
    my $calendar1 = C4::Calendar->new( branchcode => $branch1 );
    my $sunday    = dt_from_string("2020-03-15");
    $calendar1->insert_week_day_holiday(
        weekday     => 0,
        title       => '',
        description => 'Sundays',
    );

    my $day_month = dt_from_string("2020-03-17");
    $calendar1->insert_day_month_holiday(
        day         => $day_month->day(),
        month       => $day_month->month(),
        year        => $day_month->year(),
        title       => '',
        description => "",
    );

    my $future_date = dt_from_string("9999-12-31");
    $calendar1->insert_single_holiday(
        day         => $future_date->day(),
        month       => $future_date->month(),
        year        => $future_date->year(),
        title       => "",
        description => "",
    );

    my $future_exception = dt_from_string("9999-12-30");
    $calendar1->insert_exception_holiday(
        day         => $future_exception->day(),
        month       => $future_exception->month(),
        year        => $future_exception->year(),
        title       => "",
        description => "",
    );

    my $past_date = dt_from_string("2019-11-20");
    $calendar1->insert_single_holiday(
        day         => $past_date->day(),
        month       => $past_date->month(),
        year        => $past_date->year(),
        title       => "",
        description => "",
    );

    my $past_exception = dt_from_string("2020-03-09");
    $calendar1->insert_exception_holiday(
        day         => $past_exception->day(),
        month       => $past_exception->month(),
        year        => $past_exception->year(),
        title       => "",
        description => "",
    );

    my $branch2 = $builder->build( { source => 'Branch' } )->{branchcode};

    C4::Calendar->new( branchcode => $branch1 )->copy_to_branch($branch2);

    my $calendar2  = C4::Calendar->new( branchcode => $branch2 );
    my $exceptions = $calendar2->get_exception_holidays;

    is( $calendar2->isHoliday( $sunday->day, $sunday->month, $sunday->year ), 1, "Weekday holiday copied to branch 2" );
    is(
        $calendar2->isHoliday( $day_month->day, $day_month->month, $day_month->year ), 1,
        "Day/month holiday copied to branch 2"
    );
    is(
        $calendar2->isHoliday( $future_date->day, $future_date->month, $future_date->year ), 1,
        "Single holiday copied to branch 2"
    );
    is( ( grep { $_->{date} eq "9999-12-30" } values %$exceptions ), 1, "Exception holiday copied to branch 2" );
    is(
        $calendar2->isHoliday( $past_date->day, $past_date->month, $past_date->year ), 0,
        "Don't copy past single holidays"
    );
    is( ( grep { $_->{date} eq "2020-03-09" } values %$exceptions ), 0, "Don't copy past exception holidays " );

    C4::Calendar->new( branchcode => $branch1 )->copy_to_branch($branch2);

    #Select all rows with same values from database
    my $dbh                     = C4::Context->dbh;
    my $get_repeatable_holidays = "SELECT a.* FROM repeatable_holidays a
        JOIN (SELECT branchcode, weekday, day, month, COUNT(*)
        FROM repeatable_holidays
        GROUP BY branchcode, weekday, day, month HAVING count(*) > 1) b
        ON a.branchcode = b.branchcode
        AND ( a.weekday = b.weekday OR (a.day = b.day AND a.month = b.month))
        ORDER BY a.branchcode;";
    my $sth = $dbh->prepare($get_repeatable_holidays);
    $sth->execute;

    my @repeatable_holidays;
    while ( my $row = $sth->fetchrow_hashref ) {
        push @repeatable_holidays, $row;
    }

    is( scalar(@repeatable_holidays), 0, "None of the repeatable holidays were doubled" );

    my $get_special_holidays = "SELECT a.* FROM special_holidays a
    JOIN (SELECT branchcode, day, month, year, isexception, COUNT(*)
    FROM special_holidays
    GROUP BY branchcode, day, month, year, isexception HAVING count(*) > 1) b
    ON a.branchcode = b.branchcode
    AND a.day = b.day AND a.month = b.month AND a.year = b.year AND a.isexception = b.isexception
    ORDER BY a.branchcode;";
    $sth = $dbh->prepare($get_special_holidays);
    $sth->execute;

    my @special_holidays;
    while ( my $row = $sth->fetchrow_hashref ) {
        push @special_holidays, $row;
    }

    is( scalar(@special_holidays), 0, "None of the special holidays were doubled" );

    $schema->storage->txn_rollback;

};

subtest 'with a library that is never open' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my $calendar   = C4::Calendar->new( branchcode => $branchcode );
    foreach my $weekday ( 0 .. 6 ) {
        $calendar->insert_week_day_holiday( weekday => $weekday, title => '', description => '' );
    }

    my $now = dt_from_string;

    subtest 'next_open_days should throw an exception' => sub {
        my $kcalendar = Koha::Calendar->new( branchcode => $branchcode, days_mode => 'Calendar' );
        throws_ok { $kcalendar->next_open_days( $now, 1 ) } 'Koha::Exceptions::Calendar::NoOpenDays';
    };

    subtest 'prev_open_days should throw an exception' => sub {
        my $kcalendar = Koha::Calendar->new( branchcode => $branchcode, days_mode => 'Calendar' );
        throws_ok { $kcalendar->prev_open_days( $now, 1 ) } 'Koha::Exceptions::Calendar::NoOpenDays';
    };

    $schema->storage->txn_rollback;
};

subtest 'with a library that is *almost* never open' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my $calendar   = C4::Calendar->new( branchcode => $branchcode );
    foreach my $weekday ( 0 .. 6 ) {
        $calendar->insert_week_day_holiday( weekday => $weekday, title => '', description => '' );
    }

    my $now                    = dt_from_string;
    my $open_day_in_the_future = $now->clone()->add( years => 1 );
    my $open_day_in_the_past   = $now->clone()->subtract( years => 1 );
    $calendar->insert_exception_holiday( date => $open_day_in_the_future->ymd, title => '', description => '' );
    $calendar->insert_exception_holiday( date => $open_day_in_the_past->ymd,   title => '', description => '' );

    subtest 'next_open_days should find the open day' => sub {
        my $kcalendar     = Koha::Calendar->new( branchcode => $branchcode, days_mode => 'Calendar' );
        my $next_open_day = $kcalendar->next_open_days( $now, 1 );
        is( $next_open_day->ymd, $open_day_in_the_future->ymd );
    };

    subtest 'prev_open_days should find the open day' => sub {
        my $kcalendar     = Koha::Calendar->new( branchcode => $branchcode, days_mode => 'Calendar' );
        my $prev_open_day = $kcalendar->prev_open_days( $now, 1 );
        is( $prev_open_day->ymd, $open_day_in_the_past->ymd );
    };

    $schema->storage->txn_rollback;
};

# Clear cache
Koha::Caches->get_instance->flush_all;
