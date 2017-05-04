#!/usr/bin/perl

use Modern::Perl;

use C4::Reserves;
use Koha::DateUtils;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::More tests => 11;

use_ok('C4::Reserves');

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->do(q{DELETE FROM special_holidays});
$dbh->do(q{DELETE FROM repeatable_holidays});
$dbh->do("DELETE FROM reserves");

my $builder = t::lib::TestBuilder->new();

# Category, branch and patrons
$builder->build({
    source => 'Category',
    value  => {
        categorycode => 'XYZ1',
    },
});
$builder->build({
    source => 'Branch',
    value  => {
        branchcode => 'LIB1',
    },
});

$builder->build({
    source => 'Branch',
    value  => {
        branchcode => 'LIB2',
    },
});

my $patron1 = $builder->build({
    source => 'Borrower',
    value  => {
        categorycode => 'XYZ1',
        branchcode => 'LIB1',
    },
});

my $patron2 = $builder->build({
    source => 'Borrower',
    value  => {
        categorycode => 'XYZ1',
        branchcode => 'LIB2',
    },
});

my $biblio = $builder->build({
    source => 'Biblio',
    value  => {
        title => 'Title 1',    },
});

my $biblio2 = $builder->build({
    source => 'Biblio',
    value  => {
        title => 'Title 2',    },
});

my $biblio3 = $builder->build({
    source => 'Biblio',
    value  => {
        title => 'Title 3',    },
});

my $biblio4 = $builder->build({
    source => 'Biblio',
    value  => {
        title => 'Title 4',    },
});

my $item1 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio->{biblionumber},
    },
});

my $item2 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio2->{biblionumber},
    },
});

my $item3 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio3->{biblionumber},
    },
});

my $item4 = $builder->build({
    source => 'Item',
    value  => {
        biblionumber => $biblio4->{biblionumber},
    },
});

my $today = dt_from_string();

my $reserve1_reservedate = $today->clone;
$reserve1_reservedate->subtract(days => 20);

my $reserve1_expirationdate = $today->clone;
$reserve1_expirationdate->add(days => 6);

my $reserve1 = $builder->build({
    source => 'Reserve',
    value => {
        borrowernumber => $patron1->{borrowernumber},
        reservedate => $reserve1_reservedate->ymd,
        expirationdate => undef,
        biblionumber => $biblio->{biblionumber},
        branchcode => 'LIB1',
        priority => 1,
        found => '',
    },
});

t::lib::Mocks::mock_preference('ExpireReservesMaxPickUpDelay', 1);
t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', 6);

ModReserveAffect( $item1->{itemnumber}, $patron1->{borrowernumber});
my $r = Koha::Holds->find($reserve1->{reserve_id});

is($r->waitingdate, $today->ymd, 'Waiting date should be set to today' );
is($r->expirationdate, $reserve1_expirationdate->ymd, 'Expiration date should be set to today + 6' );
is($r->found, 'W', 'Reserve status is now "waiting"' );
is($r->priority, 0, 'Priority should be 0' );
is($r->itemnumber, $item1->{itemnumber}, 'Item number should be set correctly' );

my $reserve2 = $builder->build({
    source => 'Reserve',
    value => {
        borrowernumber => $patron2->{borrowernumber},
        reservedate => $reserve1_reservedate->ymd,
        expirationdate => undef,
        biblionumber => $biblio2->{biblionumber},
        branchcode => 'LIB1',
        priority => 1,
        found => '',
    },
});

ModReserveAffect( $item2->{itemnumber}, $patron2->{borrowernumber}, 1);
my $r2 = Koha::Holds->find($reserve2->{reserve_id});

is($r2->found, 'T', '2nd reserve - Reserve status is now "To transfer"' );
is($r2->priority, 0, '2nd reserve - Priority should be 0' );
is($r2->itemnumber, $item2->{itemnumber}, '2nd reserve - Item number should be set correctly' );

my $reserve3 = $builder->build({
    source => 'Reserve',
    value => {
        borrowernumber => $patron2->{borrowernumber},
        reservedate => $reserve1_reservedate->ymd,
        expirationdate => undef,
        biblionumber => $biblio3->{biblionumber},
        branchcode => 'LIB1',
        priority => 1,
        found => '',
    },
});

my $special_holiday1_dt = $today->clone;
$special_holiday1_dt->add(days => 2);

my $holiday = $builder->build({
    source => 'SpecialHoliday',
    value => {
        branchcode => 'LIB1',
        day => $special_holiday1_dt->day,
        month => $special_holiday1_dt->month,
        year => $special_holiday1_dt->year,
        title => 'My special holiday',
        isexception => 0
    },
});

my $special_holiday2_dt = $today->clone;
$special_holiday2_dt->add(days => 4);

my $holiday2 = $builder->build({
    source => 'SpecialHoliday',
    value => {
        branchcode => 'LIB1',
        day => $special_holiday2_dt->day,
        month => $special_holiday2_dt->month,
        year => $special_holiday2_dt->year,
        title => 'My special holiday 2',
        isexception => 0
    },
});

Koha::Caches->get_instance->flush_all;

t::lib::Mocks::mock_preference('ExcludeHolidaysFromMaxPickUpDelay', 1);
ModReserveAffect( $item3->{itemnumber}, $patron2->{borrowernumber});

# Add 6 days of pickup delay + 1 day of holiday.
my $expected_expiration = $today->clone;
$expected_expiration->add(days => 8);

my $r3 = Koha::Holds->find($reserve3->{reserve_id});
is($r3->expirationdate, $expected_expiration->ymd, 'Expiration date should be set to today + 7' );

my $reserve4_reservedate = $today->clone;
my $requested_expiredate = $today->clone()->add(days => 6);

my $reserve4 = $builder->build({
    source => 'Reserve',
    value => {
        borrowernumber => $patron2->{borrowernumber},
        reservedate => $reserve4_reservedate->ymd,
        expirationdate => $requested_expiredate->ymd,
        biblionumber => $biblio4->{biblionumber},
        branchcode => 'LIB1',
        priority => 1,
        found => '',
    },
});

t::lib::Mocks::mock_preference('ReservesMaxPickUpDelay', 10);
ModReserveAffect( $item4->{itemnumber}, $patron2->{borrowernumber}, 0, $reserve4->{reserve_id});

my $r4 = Koha::Holds->find($reserve4->{reserve_id});
is($r4->expirationdate, $requested_expiredate->ymd, 'Requested expiration date should be kept' );

$schema->storage->txn_rollback;
