#!/usr/bin/perl

use Modern::Perl;
use C4::Context;
use Koha::DateUtils;
use Test::More tests => 7;
use Test::MockModule;
use t::lib::Mocks;

BEGIN {
        use_ok('Koha::Template::Plugin::KohaDates');
}

my $module_context = new Test::MockModule('C4::Context');

my $date = "1973-05-21";
my $context = C4::Context->new();

my $filter = Koha::Template::Plugin::KohaDates->new();
ok ($filter, "new()");

t::lib::Mocks::mock_preference( "dateformat", 'iso' );
$context->clear_syspref_cache();

my $filtered_date = $filter->filter($date);
is ($filtered_date,$date, "iso conversion") or diag ("iso conversion fails");

#$filter = Koha::Template::Plugin::KohaDates->new();
t::lib::Mocks::mock_preference( "dateformat", 'us' );
$context->clear_syspref_cache();

$filtered_date = $filter->filter($date);
is ($filtered_date,'05/21/1973', "us conversion") or diag ("us conversion fails $filtered_date");

t::lib::Mocks::mock_preference( "dateformat", 'metric' );
$context->clear_syspref_cache();

$filtered_date = $filter->filter($date);
is ($filtered_date,'21/05/1973', "metric conversion") or diag ("metric conversion fails $filtered_date");

$module_context->mock(
    'tz',
    sub {
        return DateTime::TimeZone->new( name => 'Europe/Lisbon' );
    }
);

$filtered_date = $filter->filter('1979-04-01');
is( $filtered_date, '01/04/1979', 'us: dt_from_string should return the valid date if a DST is given' );

$module_context->mock(
    'tz',
    sub {
        return DateTime::TimeZone->new( name => 'Europe/Paris' );
    }
);

$filtered_date = $filter->filter('2014-03-30 02:00:00');
is( $filtered_date, '30/03/2014', 'us: dt_from_string should return a DateTime object if a DST is given' );
