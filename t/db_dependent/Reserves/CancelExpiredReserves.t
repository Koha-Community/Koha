#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 6;
use Test::NoWarnings;
use Test::MockModule;
use Time::Fake;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Members;
use C4::Reserves qw( CancelExpiredReserves );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;
use Koha::Old::Holds;

my $builder = t::lib::TestBuilder->new();
my $schema  = Koha::Database->new->schema;

$schema->storage->txn_begin;

subtest 'CancelExpiredReserves tests incl. holidays' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays', 0 );

    # Waiting holds could be cancelled only if ExpireReservesMaxPickUpDelay is set to "allow", see bug 19260
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );

    my $today               = dt_from_string();
    my $reserve_reservedate = $today->clone;
    $reserve_reservedate->subtract( days => 30 );

    my $reserve1_expirationdate = $today->clone;
    $reserve1_expirationdate->add( days => 1 );

    # Reserve not expired
    my $reserve1 = $builder->build(
        {
            source => 'Reserve',
            value  => {
                reservedate            => $reserve_reservedate,
                patron_expiration_date => $reserve1_expirationdate,
                cancellationdate       => undef,
                priority               => 0,
                found                  => 'W',
            },
        }
    );

    CancelExpiredReserves();
    my $r1 = Koha::Holds->find( $reserve1->{reserve_id} );
    ok( $r1, 'Reserve 1 should not be canceled.' );

    my $reserve2_expirationdate = $today->clone;
    $reserve2_expirationdate->subtract( days => 1 );

    # Reserve expired
    my $reserve2 = $builder->build(
        {
            source => 'Reserve',
            value  => {
                reservedate            => $reserve_reservedate,
                patron_expiration_date => $reserve2_expirationdate,
                cancellationdate       => undef,
                priority               => 0,
                found                  => 'W',
            },
        }
    );

    CancelExpiredReserves();
    my $r2 = Koha::Holds->find( $reserve2->{reserve_id} );
    is( $r2, undef, 'reserve 2 should be canceled.' );

    # Reserve expired on holiday
    my $reserve3 = $builder->build(
        {
            source => 'Reserve',
            value  => {
                reservedate            => $reserve_reservedate,
                patron_expiration_date => $reserve2_expirationdate,
                branchcode             => 'LIB1',
                cancellationdate       => undef,
                priority               => 0,
                found                  => 'W',
            },
        }
    );

    Koha::Caches->get_instance()->flush_all();
    my $holiday = $builder->build(
        {
            source => 'SpecialHoliday',
            value  => {
                branchcode  => 'LIB1',
                day         => $today->day,
                month       => $today->month,
                year        => $today->year,
                title       => 'My holiday',
                isexception => 0
            },
        }
    );

    CancelExpiredReserves();
    my $r3 = Koha::Holds->find( $reserve3->{reserve_id} );
    ok( $r3, 'Reserve 3 should not be canceled.' );

    t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays', 1 );
    CancelExpiredReserves();
    $r3 = Koha::Holds->find( $reserve3->{reserve_id} );
    is( $r3, undef, 'Reserve 3 should be canceled.' );
};

subtest 'Test handling of waiting reserves by CancelExpiredReserves' => sub {
    plan tests => 2;

    Koha::Holds->delete;

    my $category       = $builder->build( { source => 'Category' } );
    my $branchcode     = $builder->build( { source => 'Branch' } )->{branchcode};
    my $item           = $builder->build_sample_item;
    my $itemnumber     = $item->itemnumber;
    my $borrowernumber = $builder->build(
        { source => 'Borrower', value => { categorycode => $category->{categorycode}, branchcode => $branchcode } } )
        ->{borrowernumber};

    my $resdate    = dt_from_string->add( days => -20 );
    my $expdate    = dt_from_string->add( days => -2 );
    my $notexpdate = dt_from_string->add( days =>  2 );

    my $hold1 = Koha::Hold->new(
        {
            branchcode     => $branchcode,
            borrowernumber => $borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            reservedate    => $resdate,
            expirationdate => $notexpdate,
            found          => undef,
        }
    )->store;

    my $hold2 = Koha::Hold->new(
        {
            branchcode     => $branchcode,
            borrowernumber => $borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 2,
            reservedate    => $resdate,
            expirationdate => $expdate,
            found          => undef,
        }
    )->store;

    my $hold3 = Koha::Hold->new(
        {
            branchcode     => $branchcode,
            borrowernumber => $borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $itemnumber,
            priority       => 0,
            reservedate    => $resdate,
            expirationdate => $expdate,
            found          => 'W',
        }
    )->store;

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 0 );
    CancelExpiredReserves();
    my $count1 = Koha::Holds->search->count;
    is( $count1, 2, 'Only the non-waiting expired holds should be cancelled' );

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );
    CancelExpiredReserves();
    my $count2 = Koha::Holds->search->count;
    is( $count2, 1, 'Also the waiting expired hold should be cancelled now' );

};

subtest 'Test handling of in transit reserves by CancelExpiredReserves' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );
    my $expdate = dt_from_string->add( days => -2 );
    my $reserve = $builder->build(
        {
            source => 'Reserve',
            value  => {
                patron_expiration_date => '2018-01-01',
                found                  => 'T',
                cancellationdate       => undef,
                suspend                => 0,
                suspend_until          => undef
            }
        }
    );
    my $count = Koha::Holds->search->count;
    CancelExpiredReserves();
    is( Koha::Holds->search->count, $count - 1, "Transit hold is cancelled if ExpireReservesMaxPickUpDelay set" );

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 0 );
    my $reserve2 = $builder->build(
        {
            source => 'Reserve',
            value  => {
                patron_expiration_date => '2018-01-01',
                found                  => 'T',
                cancellationdate       => undef,
                suspend                => 0,
                suspend_until          => undef
            }
        }
    );
    CancelExpiredReserves();
    is( Koha::Holds->search->count, $count - 1, "Transit hold is cancelled if ExpireReservesMaxPickUpDelay unset" );

};

subtest 'Test handling of cancellation reason if passed' => sub {
    plan tests => 2;

    my $expdate = dt_from_string->add( days => -2 );
    my $reserve = $builder->build(
        {
            source => 'Reserve',
            value  => {
                patron_expiration_date => '2018-01-01',
                found                  => 'T',
                cancellationdate       => undef,
                suspend                => 0,
                suspend_until          => undef
            }
        }
    );
    my $reserve_id = $reserve->{reserve_id};
    my $count      = Koha::Holds->search->count;
    {
        # Prevent warning 'No reserves HOLD_CANCELLATION letter transported by email'
        my $mock_letters = Test::MockModule->new('C4::Letters');
        $mock_letters->mock( 'GetPreparedLetter', sub { return } );

        CancelExpiredReserves("EXPIRED");
    }
    is( Koha::Holds->search->count, $count - 1, "Hold is cancelled when reason is passed" );
    my $old_reserve = Koha::Old::Holds->find($reserve_id);
    is( $old_reserve->cancellation_reason, 'EXPIRED', "Hold cancellation_reason was set correctly" );
};

subtest 'Holiday logic edge cases' => sub {

    plan tests => 2;

    subtest 'Hold expired on business day should be cancelled retrospectively when script runs on holiday' => sub {
        plan tests => 1;

        $schema->storage->txn_begin;

        t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays',     0 );
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );

        # Clear any existing holidays from previous tests
        Koha::Caches->get_instance()->flush_all();

        # Create a library for our tests
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        # The bug scenario: Hold expired on Monday (business day), script runs on Wednesday (holiday)
        # The hold SHOULD be cancelled because it expired on a business day and Tuesday was a business day
        # that was missed, so we need retrospective cancellation even though today is a holiday

        my $monday    = dt_from_string('2024-01-15');    # Monday (business day, hold expires)
        my $wednesday = dt_from_string('2024-01-17');    # Wednesday (holiday, script runs now)

        # Create a hold that expired on Monday (business day)
        my $hold_expired_monday = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    branchcode             => $library->branchcode,
                    patron_expiration_date => $monday->ymd,
                    expirationdate         => $monday->ymd,
                    cancellationdate       => undef,
                    priority               => 0,
                    found                  => 'W',
                },
            }
        );

        # Make Wednesday a holiday (but Monday and Tuesday are business days)
        my $wednesday_holiday = $builder->build(
            {
                source => 'SpecialHoliday',
                value  => {
                    branchcode  => $library->branchcode,
                    day         => $wednesday->day,
                    month       => $wednesday->month,
                    year        => $wednesday->year,
                    title       => 'Wednesday Holiday',
                    isexception => 0
                },
            }
        );

        # Clear cache so holiday is recognized
        Koha::Caches->get_instance()->flush_all();

        # Set fake time to Wednesday (holiday)
        Time::Fake->offset( $wednesday->epoch );

        # The hold SHOULD be cancelled because:
        # 1. It expired on Monday (business day)
        # 2. Tuesday was a business day that was missed
        # 3. Even though today (Wednesday) is a holiday, we need retrospective cancellation
        CancelExpiredReserves();

        my $hold_check = Koha::Holds->find( $hold_expired_monday->id );
        is(
            $hold_check, undef,
            'Hold that expired on business day should be cancelled retrospectively even when script runs on holiday'
        );

        # Reset time
        Time::Fake->reset;

        $schema->storage->txn_rollback;
    };

    subtest 'Hold expired on holiday should not be cancelled when script runs on same holiday' => sub {
        plan tests => 1;

        $schema->storage->txn_begin;

        t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays',     0 );
        t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );

        # Clear any existing holidays from previous tests
        Koha::Caches->get_instance()->flush_all();

        # Create a library for our tests
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        # Control scenario: Hold expired on Monday (holiday), script runs on Monday (same holiday)
        # The hold should NOT be cancelled because it expired today and today is a holiday

        my $monday = dt_from_string('2024-01-15');    # Monday (holiday, hold expires and script runs)

        # Create a hold that expired on Monday (holiday)
        my $hold_expired_monday = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    branchcode             => $library->branchcode,
                    patron_expiration_date => $monday->ymd,
                    expirationdate         => $monday->ymd,
                    cancellationdate       => undef,
                    priority               => 0,
                    found                  => 'W',
                },
            }
        );

        # Make Monday a holiday
        my $monday_holiday = $builder->build(
            {
                source => 'SpecialHoliday',
                value  => {
                    branchcode  => $library->branchcode,
                    day         => $monday->day,
                    month       => $monday->month,
                    year        => $monday->year,
                    title       => 'Monday Holiday',
                    isexception => 0
                },
            }
        );

        # Clear cache so holiday is recognized
        Koha::Caches->get_instance()->flush_all();

        # Set fake time to Monday (holiday)
        Time::Fake->offset( $monday->epoch );

        # The hold should NOT be cancelled because it expired today and today is a holiday
        CancelExpiredReserves();

        my $hold_check = Koha::Holds->find( $hold_expired_monday->id );
        ok(
            $hold_check,
            'Hold that expired on holiday should not be cancelled when script runs on same holiday'
        );

        # Reset time
        Time::Fake->reset;

        $schema->storage->txn_rollback;
    };
};

$schema->storage->txn_rollback;
