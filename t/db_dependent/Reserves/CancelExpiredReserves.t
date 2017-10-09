#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Members;
use C4::Reserves;
use Koha::Database;
use Koha::DateUtils;
use Koha::Holds;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'CancelExpiredReserves tests incl. holidays' => sub {
    plan tests => 4;

    my $builder = t::lib::TestBuilder->new();

    t::lib::Mocks::mock_preference('ExpireReservesOnHolidays', 0);
    # Waiting holds could be cancelled only if ExpireReservesMaxPickUpDelay is set to "allow", see bug 19260
    t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelay', 1);


    my $today = dt_from_string();
    my $reserve_reservedate = $today->clone;
    $reserve_reservedate->subtract(days => 30);

    my $reserve1_expirationdate = $today->clone;
    $reserve1_expirationdate->add(days => 1);

    # Reserve not expired
    my $reserve1 = $builder->build({
        source => 'Reserve',
        value => {
            reservedate => $reserve_reservedate,
            expirationdate => $reserve1_expirationdate,
            cancellationdate => undef,
            priority => 0,
            found => 'W',
        },
    });

    CancelExpiredReserves();
    my $r1 = Koha::Holds->find($reserve1->{reserve_id});
    ok($r1, 'Reserve 1 should not be canceled.');

    my $reserve2_expirationdate = $today->clone;
    $reserve2_expirationdate->subtract(days => 1);

    # Reserve expired
    my $reserve2 = $builder->build({
        source => 'Reserve',
        value => {
            reservedate => $reserve_reservedate,
            expirationdate => $reserve2_expirationdate,
            cancellationdate => undef,
            priority => 0,
            found => 'W',
        },
    });

    CancelExpiredReserves();
    my $r2 = Koha::Holds->find($reserve2->{reserve_id});
    is($r2, undef,'reserve 2 should be canceled.');

    # Reserve expired on holiday
    my $reserve3 = $builder->build({
        source => 'Reserve',
        value => {
            reservedate => $reserve_reservedate,
            expirationdate => $reserve2_expirationdate,
            branchcode => 'LIB1',
            cancellationdate => undef,
            priority => 0,
            found => 'W',
        },
    });

    Koha::Caches->get_instance()->flush_all();
    my $holiday = $builder->build({
        source => 'SpecialHoliday',
        value => {
            branchcode => 'LIB1',
            day => $today->day,
            month => $today->month,
            year => $today->year,
            title => 'My holiday',
            isexception => 0
        },
    });

    CancelExpiredReserves();
    my $r3 = Koha::Holds->find($reserve3->{reserve_id});
    ok($r3,'Reserve 3 should not be canceled.');

    t::lib::Mocks::mock_preference('ExpireReservesOnHolidays', 1);
    CancelExpiredReserves();
    $r3 = Koha::Holds->find($reserve3->{reserve_id});
    is($r3, undef,'Reserve 3 should be canceled.');
};

subtest 'Test handling of waiting reserves by CancelExpiredReserves' => sub {
    plan tests => 2;

    Koha::Holds->delete;

    my $builder = t::lib::TestBuilder->new();
    my $category = $builder->build({ source => 'Category' });
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
    my $biblio = $builder->build({ source => 'Biblio' });
    my $bibnum = $biblio->{biblionumber};
    my $item = $builder->build({ source => 'Item', value => { biblionumber => $bibnum }});
    my $itemnumber = $item->{itemnumber};
    my $borrowernumber = $builder->build({ source => 'Borrower', value => { categorycode => $category->{categorycode}, branchcode => $branchcode }})->{borrowernumber};

    my $resdate = dt_from_string->add( days => -20 );
    my $expdate = dt_from_string->add( days => -2 );
    my $notexpdate = dt_from_string->add( days => 2 );

    my $hold1 = Koha::Hold->new({
        branchcode => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber => $bibnum,
        priority => 1,
        reservedate => $resdate,
        expirationdate => $notexpdate,
        found => undef,
    })->store;

    my $hold2 = Koha::Hold->new({
        branchcode => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber => $bibnum,
        priority => 2,
        reservedate => $resdate,
        expirationdate => $expdate,
        found => undef,
    })->store;

    my $hold3 = Koha::Hold->new({
        branchcode => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber => $bibnum,
        itemnumber => $itemnumber,
        priority => 0,
        reservedate => $resdate,
        expirationdate => $expdate,
        found => 'W',
    })->store;

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 0 );
    CancelExpiredReserves();
    my $count1 = Koha::Holds->search->count;
    is( $count1, 2, 'Only the non-waiting expired holds should be cancelled');

    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );
    CancelExpiredReserves();
    my $count2 = Koha::Holds->search->count;
    is( $count2, 1, 'Also the waiting expired hold should be cancelled now');
};

$schema->storage->txn_rollback;
