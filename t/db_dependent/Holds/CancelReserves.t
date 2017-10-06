#!/usr/bin/perl

use Modern::Perl;

use C4::Reserves;
use Koha::DateUtils;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::More tests => 5;

use_ok('C4::Reserves');

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new();

t::lib::Mocks::mock_preference('ExpireReservesOnHolidays', 0);
# Waiting reservers could be canceled only if ExpireReservesMaxPickUpDelay is set to "allow", see bug 19260
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

$schema->storage->txn_rollback;
