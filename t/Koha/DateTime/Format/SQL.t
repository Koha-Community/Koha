#!/usr/bin/perl

use Modern::Perl;
use DateTime::TimeZone;
use Test::Exception;
use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 6;

BEGIN { use_ok('Koha::DateTime::Format::SQL'); }

my $local_timezone   = DateTime::TimeZone->new( name => 'local' );
my $koha_config_mock = Test::MockModule->new('Koha::Config');
my $config           = { timezone => '' };
$koha_config_mock->mock( 'get', sub { $config->{ $_[1] } } );

subtest 'normal datetime, no timezone configured' => sub {
    plan tests => 7;

    $config->{timezone} = '';
    $Koha::DateTime::Format::SQL::timezone = undef;

    my $dt = Koha::DateTime::Format::SQL->parse_datetime('2024-01-02 10:11:12');

    is( $dt->year,            2024 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->time_zone->name, $local_timezone->name );
};

subtest 'normal datetime, with timezone configured' => sub {
    plan tests => 7;

    $config->{timezone} = 'Pacific/Auckland';
    $Koha::DateTime::Format::SQL::timezone = undef;

    my $dt = Koha::DateTime::Format::SQL->parse_datetime('2024-01-02 10:11:12');

    is( $dt->year,            2024 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->time_zone->name, 'Pacific/Auckland' );
};

subtest 'infinite datetime, no timezone configured' => sub {
    plan tests => 7;

    $config->{timezone} = '';
    $Koha::DateTime::Format::SQL::timezone = undef;

    my $dt = Koha::DateTime::Format::SQL->parse_datetime('9999-01-02 10:11:12');

    is( $dt->year,            9999 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->time_zone->name, 'floating' );
};

subtest 'normal datetime, with timezone configured' => sub {
    plan tests => 7;

    $config->{timezone} = 'Pacific/Auckland';
    $Koha::DateTime::Format::SQL::timezone = undef;

    my $dt = Koha::DateTime::Format::SQL->parse_datetime('9999-01-02 10:11:12');

    is( $dt->year,            9999 );
    is( $dt->month,           1 );
    is( $dt->day,             2 );
    is( $dt->hour,            10 );
    is( $dt->minute,          11 );
    is( $dt->second,          12 );
    is( $dt->time_zone->name, 'floating' );
};
