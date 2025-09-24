#!/usr/bin/perl

# Copyright 2025 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 3;
use Test::Exception;
use Test::NoWarnings;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Calendar');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'has_business_days_between' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branchcode = $library->branchcode;

    # Create test dates
    my $monday    = dt_from_string('2024-01-01');    # Monday
    my $tuesday   = dt_from_string('2024-01-02');    # Tuesday
    my $wednesday = dt_from_string('2024-01-03');    # Wednesday
    my $thursday  = dt_from_string('2024-01-04');    # Thursday
    my $friday    = dt_from_string('2024-01-05');    # Friday
    my $saturday  = dt_from_string('2024-01-06');    # Saturday
    my $sunday    = dt_from_string('2024-01-07');    # Sunday

    # Make Wednesday a holiday
    my $wednesday_holiday = $builder->build(
        {
            source => 'SpecialHoliday',
            value  => {
                branchcode  => $branchcode,
                day         => $wednesday->day,
                month       => $wednesday->month,
                year        => $wednesday->year,
                title       => 'Wednesday Holiday',
                isexception => 0
            },
        }
    );

    # Make Saturday and Sunday holidays (weekend)
    my $saturday_holiday = $builder->build(
        {
            source => 'SpecialHoliday',
            value  => {
                branchcode  => $branchcode,
                day         => $saturday->day,
                month       => $saturday->month,
                year        => $saturday->year,
                title       => 'Saturday Holiday',
                isexception => 0
            },
        }
    );

    my $sunday_holiday = $builder->build(
        {
            source => 'SpecialHoliday',
            value  => {
                branchcode  => $branchcode,
                day         => $sunday->day,
                month       => $sunday->month,
                year        => $sunday->year,
                title       => 'Sunday Holiday',
                isexception => 0
            },
        }
    );

    my $calendar = Koha::Calendar->new( branchcode => $branchcode );

    # Test 1: Business day between two business days
    is(
        $calendar->has_business_days_between( $monday, $wednesday ), 1,
        'Should find business day (Tuesday) between Monday and Wednesday'
    );

    # Test 2: No business days between consecutive business days
    is(
        $calendar->has_business_days_between( $monday, $tuesday ), 0,
        'Should find no business days between consecutive days'
    );

    # Test 3: Holiday between two business days
    is(
        $calendar->has_business_days_between( $tuesday, $thursday ), 0,
        'Should find no business days when only holiday (Wednesday) is between'
    );

    # Test 4: Multiple days with business days
    is(
        $calendar->has_business_days_between( $monday, $friday ), 1,
        'Should find business days between Monday and Friday'
    );

    # Test 5: Only holidays between dates
    is(
        $calendar->has_business_days_between( $friday, $sunday ), 0,
        'Should find no business days between Friday and Sunday (Saturday is holiday)'
    );

    # Test 6: Same date
    is(
        $calendar->has_business_days_between( $monday, $monday ), 0,
        'Should find no business days between same date'
    );

    $schema->storage->txn_rollback;
};
