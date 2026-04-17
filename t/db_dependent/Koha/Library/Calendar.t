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

use Test::More tests => 6;
use Test::Exception;
use Test::NoWarnings;

use Koha::Caches;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Library::Calendar::WeeklyClosures;
use Koha::Library::Calendar::RepeatingClosures;
use Koha::Library::Calendar::SingleClosures;
use Koha::Library::Calendar::Exceptions;
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Library::Calendar');
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
    $builder->build_object(
        {
            class => 'Koha::Library::Calendar::SingleClosures',
            value =>
                { library_id => $branchcode, date => $wednesday->ymd, title => 'Wednesday Holiday', description => '' }
        }
    );

    # Make Saturday and Sunday holidays (weekend)
    $builder->build_object(
        {
            class => 'Koha::Library::Calendar::SingleClosures',
            value =>
                { library_id => $branchcode, date => $saturday->ymd, title => 'Saturday Holiday', description => '' }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::Library::Calendar::SingleClosures',
            value => { library_id => $branchcode, date => $sunday->ymd, title => 'Sunday Holiday', description => '' }
        }
    );

    my $calendar = Koha::Library::Calendar->new( branchcode => $branchcode );

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

subtest 'CRUD methods' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $calendar = Koha::Library::Calendar->new( branchcode => $library->branchcode );

    # add_weekly_closure
    my $weekly = $calendar->add_weekly_closure( { weekday => 0, title => 'Sundays', description => 'Closed' } );
    isa_ok( $weekly, 'Koha::Library::Calendar::WeeklyClosure', 'add_weekly_closure returns object' );
    is(
        Koha::Library::Calendar::WeeklyClosures->search( { library_id => $library->branchcode } )->count, 1,
        'Weekly closure created'
    );

    # add_repeating_closure
    my $repeating =
        $calendar->add_repeating_closure( { day => 25, month => 12, title => 'Christmas', description => '' } );
    isa_ok( $repeating, 'Koha::Library::Calendar::RepeatingClosure', 'add_repeating_closure returns object' );
    is(
        Koha::Library::Calendar::RepeatingClosures->search( { library_id => $library->branchcode } )->count, 1,
        'Repeating closure created'
    );

    # add_single_closure
    my $single = $calendar->add_single_closure( { date => '2026-06-15', title => 'Staff day', description => '' } );
    isa_ok( $single, 'Koha::Library::Calendar::SingleClosure', 'add_single_closure returns object' );
    is(
        Koha::Library::Calendar::SingleClosures->search( { library_id => $library->branchcode } )->count, 1,
        'Single closure created'
    );

    # add_exception
    my $exception = $calendar->add_exception( { date => '2026-12-25', title => 'Special opening', description => '' } );
    isa_ok( $exception, 'Koha::Library::Calendar::Exception', 'add_exception returns object' );
    is( Koha::Library::Calendar::Exceptions->search( { library_id => $library->branchcode } )->count, 1, 'Exception created' );

    # Verify is_holiday uses the new data
    my $cal    = Koha::Library::Calendar->new( branchcode => $library->branchcode );
    my $sunday = dt_from_string('2026-06-14');                                # a Sunday
    is( $cal->is_holiday($sunday), 1, 'Sunday is closed after add_weekly_closure' );

    my $june15 = dt_from_string('2026-06-15');
    is( $cal->is_holiday($june15), 1, 'Single closure date is closed' );

    my $xmas = dt_from_string('2026-12-25');
    is( $cal->is_holiday($xmas), 0, 'Exception overrides repeating closure' );

    # delete methods
    $calendar->delete_weekly_closure( { weekday => 0 } );
    is(
        Koha::Library::Calendar::WeeklyClosures->search( { library_id => $library->branchcode } )->count, 0,
        'Weekly closure deleted'
    );

    $calendar->delete_repeating_closure( { day => 25, month => 12 } );
    is(
        Koha::Library::Calendar::RepeatingClosures->search( { library_id => $library->branchcode } )->count, 0,
        'Repeating closure deleted'
    );

    $calendar->delete_single_closure( { date => '2026-06-15' } );
    is(
        Koha::Library::Calendar::SingleClosures->search( { library_id => $library->branchcode } )->count, 0,
        'Single closure deleted'
    );

    $calendar->delete_exception( { date => '2026-12-25' } );
    is( Koha::Library::Calendar::Exceptions->search( { library_id => $library->branchcode } )->count, 0, 'Exception deleted' );

    # copy_to
    $calendar->add_weekly_closure( { weekday => 6,            title => 'Saturdays', description => '' } );
    $calendar->add_single_closure( { date    => '2027-01-01', title => 'New Year',  description => '' } );

    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    $calendar->copy_to( $library2->branchcode );

    is(
        Koha::Library::Calendar::WeeklyClosures->search( { library_id => $library2->branchcode } )->count, 1,
        'Weekly closure copied'
    );
    is(
        Koha::Library::Calendar::SingleClosures->search( { library_id => $library2->branchcode } )->count, 1,
        'Single closure copied'
    );

    # copy_to should not duplicate
    $calendar->copy_to( $library2->branchcode );
    is(
        Koha::Library::Calendar::WeeklyClosures->search( { library_id => $library2->branchcode } )->count, 1,
        'No duplicate after second copy'
    );
    is(
        Koha::Library::Calendar::SingleClosures->search( { library_id => $library2->branchcode } )->count, 1,
        'No duplicate single after second copy'
    );

    # Verify is_holiday after deletions and re-init
    my $cal2 = Koha::Library::Calendar->new( branchcode => $library->branchcode );
    is( $cal2->is_holiday($june15), 0, 'Deleted single closure no longer a holiday' );

    $schema->storage->txn_rollback;
};

subtest 'closed_dates_in_range' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branchcode = $library->branchcode;

    # Sunday closed every week, 25 December every year, 2026-06-15 single,
    # 2026-12-25 open exception (overrides the repeating rule).
    $builder->build_object(
        { class => 'Koha::Library::Calendar::WeeklyClosures', value => { library_id => $branchcode, weekday => 0 } } );
    $builder->build_object(
        {
            class => 'Koha::Library::Calendar::RepeatingClosures',
            value => { library_id => $branchcode, day => 25, month => 12 }
        }
    );
    $builder->build_object(
        { class => 'Koha::Library::Calendar::SingleClosures', value => { library_id => $branchcode, date => '2026-06-15' } } );
    $builder->build_object(
        { class => 'Koha::Library::Calendar::Exceptions', value => { library_id => $branchcode, date => '2026-12-25' } } );

    my $calendar = Koha::Library::Calendar->new( branchcode => $branchcode );

    my $closed = $calendar->closed_dates_in_range( dt_from_string('2026-06-14'), dt_from_string('2026-06-16') );
    is_deeply( $closed, [ '2026-06-14', '2026-06-15' ], 'Sunday and single closure returned' );

    $closed = $calendar->closed_dates_in_range( dt_from_string('2026-12-24'), dt_from_string('2026-12-26') );
    is_deeply( $closed, [], 'Exception suppresses repeating closure on 2026-12-25' );

    $closed = $calendar->closed_dates_in_range( dt_from_string('2027-06-15'), dt_from_string('2027-06-15') );
    is_deeply( $closed, [], 'Open Tuesday not returned' );

    $closed = $calendar->closed_dates_in_range( dt_from_string('2027-12-25'), dt_from_string('2027-12-25') );
    is_deeply( $closed, ['2027-12-25'], 'Repeating closure returned in a year with no exception' );

    throws_ok { $calendar->closed_dates_in_range() } qr/Missing from_dt/, 'croaks without from_dt';

    $schema->storage->txn_rollback;
};

subtest 'delete_*_closure clears _holidays cache' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branchcode = $library->branchcode;
    my $cache_key  = $branchcode . '_holidays';
    my $cache      = Koha::Caches->get_instance;

    my $calendar = Koha::Library::Calendar->new( branchcode => $branchcode );

    $calendar->add_single_closure( { date => '2027-07-04', title => 'Independence', description => '' } );
    $calendar->is_holiday( dt_from_string('2027-07-04') );    # warm cache
    ok( defined $cache->get_from_cache($cache_key), 'Cache warm after is_holiday (single)' );
    $calendar->delete_single_closure( { date => '2027-07-04' } );
    is( $cache->get_from_cache($cache_key), undef, 'Cache cleared after delete_single_closure' );

    $calendar->add_exception( { date => '2027-07-05', title => 'Special open', description => '' } );
    $calendar->is_holiday( dt_from_string('2027-07-05') );    # warm cache
    ok( defined $cache->get_from_cache($cache_key), 'Cache warm after is_holiday (exception)' );
    $calendar->delete_exception( { date => '2027-07-05' } );
    is( $cache->get_from_cache($cache_key), undef, 'Cache cleared after delete_exception' );

    $schema->storage->txn_rollback;
};
