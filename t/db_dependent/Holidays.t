use strict;
use warnings;
use 5.010;
use DateTime;
use DateTime::TimeZone;

use C4::Context;
use Koha::DateUtils;
use Test::More tests => 12;

BEGIN { use_ok('Koha::Calendar'); }
BEGIN { use_ok('C4::Calendar'); }

my $branchcode = 'MPL';

my $koha_calendar = Koha::Calendar->new( branchcode => $branchcode );
my $c4_calendar = C4::Calendar->new( branchcode => $branchcode );

isa_ok( $koha_calendar, 'Koha::Calendar', 'Koha::Calendar class returned' );
isa_ok( $c4_calendar,   'C4::Calendar',   'C4::Calendar class returned' );

my $sunday = DateTime->new(
    year  => 2011,
    month => 6,
    day   => 26,
);
my $monday = DateTime->new(
    year  => 2011,
    month => 6,
    day   => 27,
);
my $christmas = DateTime->new(
    year  => 2032,
    month => 12,
    day   => 25,
);
my $newyear = DateTime->new(
    year  => 2035,
    month => 1,
    day   => 1,
);

is( $koha_calendar->is_holiday($sunday),    1, 'Sunday is a closed day' );
is( $koha_calendar->is_holiday($monday),    0, 'Monday is not a closed day' );
is( $koha_calendar->is_holiday($christmas), 1, 'Christmas is a closed day' );
is( $koha_calendar->is_holiday($newyear), 1, 'New Years day is a closed day' );

my $custom_holiday = DateTime->new(
    year  => 2013,
    month => 11,
    day   => 12,
);
is( $koha_calendar->is_holiday($custom_holiday), 0, '2013-11-10 does not start off as a holiday' );
$koha_calendar->add_holiday($custom_holiday);
is( $koha_calendar->is_holiday($custom_holiday), 1, 'able to add holiday for testing' );

my $today = dt_from_string();
C4::Calendar->new( branchcode => 'CPL' )->insert_single_holiday(
    day         => $today->day(),
    month       => $today->month(),
    year        => $today->year(),
    title       => "$today",
    description => "$today",
);
is( Koha::Calendar->new( branchcode => 'CPL' )->is_holiday( $today ), 1, "Today is a holiday for CPL" );
is( Koha::Calendar->new( branchcode => 'MPL' )->is_holiday( $today ), 0, "Today is not a holiday for MPL");
