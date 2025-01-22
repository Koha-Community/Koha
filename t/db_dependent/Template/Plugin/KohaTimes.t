#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 6;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::KohaTimes');
}

my $module_context = Test::MockModule->new('C4::Context');

my $test_time     = "21:45:32";
my $test_midnight = "00:00:00";

my $context = C4::Context->new();

my $filter = Koha::Template::Plugin::KohaTimes->new();
ok( $filter, "new()" );

t::lib::Mocks::mock_preference( "TimeFormat", '24hr' );
$context->clear_syspref_cache();

my $filtered_time = $filter->filter($test_time);
is( $filtered_time, "21:45", "24-hour conversion" ) or diag("24-hour conversion failed");

t::lib::Mocks::mock_preference( "TimeFormat", '12hr' );
$context->clear_syspref_cache();

$filtered_time = $filter->filter($test_time);
is( $filtered_time, "09:45 pm", "12-hour conversion" ) or diag("12-hour conversion failed");

$filtered_time = $filter->filter($test_midnight);
is( $filtered_time, "12:00 am", "12-hour midnight/AM conversion" ) or diag("12-hour midnight/AM conversion failed");
