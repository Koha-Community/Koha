#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 6;
use Test::Exception;

BEGIN { use_ok('Koha::DateTime::Format::RFC3339'); }

subtest 'UTC datetime' => sub {
    plan tests => 7;

    my $dt = Koha::DateTime::Format::RFC3339->parse_datetime('2024-01-02T10:11:12Z');

    is( $dt->year,   2024 );
    is( $dt->month,  1 );
    is( $dt->day,    2 );
    is( $dt->hour,   10 );
    is( $dt->minute, 11 );
    is( $dt->second, 12 );
    ok( $dt->time_zone->is_utc );
};

subtest 'with timezone' => sub {
    plan tests => 7;

    my $dt = Koha::DateTime::Format::RFC3339->parse_datetime('2024-01-02T10:11:12+01:30');

    is( $dt->year,            2024 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->time_zone->name, '+0130' );
};

subtest 'fractions of seconds are ignored' => sub {
    plan tests => 8;

    my $dt = Koha::DateTime::Format::RFC3339->parse_datetime('2024-01-02T10:11:12.34+01:30');

    is( $dt->year,            2024 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->nanosecond,      0 );
    is( $dt->time_zone->name, '+0130' );
};

subtest 'invalid date throws an exception' => sub {
    plan tests => 1;

    throws_ok {
        my $dt = Koha::DateTime::Format::RFC3339->parse_datetime('2024-01-02T10:11:12');
    }
    qr/Invalid date format/;
};
