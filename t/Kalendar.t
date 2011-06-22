use strict;
use warnings;
use 5.010;
use DateTime;
use DateTime::TimeZone;

use C4::Context;
use Test::More tests => 8;    # last test to print

BEGIN { use_ok('Koha::Calendar'); }

my $cal = Koha::Calendar->new( TEST_MODE => 1 );

isa_ok( $cal, 'Koha::Calendar', 'Calendar class returned' );

my $saturday = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 25,
    time_zone => 'Europe/London',
);
my $sunday = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 26,
    time_zone => 'Europe/London',
);
my $monday = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 27,
    time_zone => 'Europe/London',
);
my $bloomsday = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 16,
    time_zone => 'Europe/London',
);    # should be a holiday
my $special = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 1,
    time_zone => 'Europe/London',
);    # should be a holiday
my $notspecial = DateTime->new(
    year      => 2011,
    month     => 6,
    day       => 2,
    time_zone => 'Europe/London',
);    # should NOT be a holiday
is( $cal->is_holiday($sunday), 1, 'Sunday is a closed day' );   # wee free test;
is( $cal->is_holiday($monday),     0, 'Monday is not a closed day' );    # alas
is( $cal->is_holiday($bloomsday),  1, 'month/day closed day test' );
is( $cal->is_holiday($special),    1, 'special closed day test' );
is( $cal->is_holiday($notspecial), 0, 'open day test' );

my $dt = $cal->addDate( $saturday, 1, 'days' );
is( $dt->day_of_week, 1, 'addDate skips closed Sunday' );
