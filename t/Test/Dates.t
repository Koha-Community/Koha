use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 9;
use t::lib::Dates;
use Koha::DateUtils qw( dt_from_string );

my $date_1 = '2017-01-01 01:00:00';
my $date_2 = '2018-02-02 01:00:00';
my $dt_1   = dt_from_string($date_1);
my $dt_2   = dt_from_string($date_2);

is( t::lib::Dates::compare( $dt_1, $dt_2 ), -1, '2017 is before 2018' );
is( t::lib::Dates::compare( $dt_2, $dt_1 ),  1, '2018 is after 2017' );

is( t::lib::Dates::compare( $date_1, $date_2 ), -1, '2017 is before 2018 (strings comparison)' );
is( t::lib::Dates::compare( $date_2, $date_1 ),  1, '2018 is after 2017 (strings comparison)' );

my $dt_3 = $dt_1->clone->subtract( seconds => 5 );
is(
    t::lib::Dates::compare( $dt_1, $dt_3 ),
    0, 'If there is less than 1min, the dates are considered identicals'
);
is(
    t::lib::Dates::compare( $dt_3, $dt_1 ),
    0, 'If there is less than 1min, the dates are considered identicals'
);

$dt_1 = DateTime->new( year => 2001, month => 1, day => 1, hour => 0, minute => 0, second => 0, time_zone => '+0000' );
$dt_3 = DateTime->new( year => 2001, month => 1, day => 1, hour => 4, minute => 0, second => 0, time_zone => '+0400' );
is( t::lib::Dates::compare( $dt_1, $dt_3 ), 0, 'Different timezone but same date/time' );

$dt_1 = DateTime->new( year => 2001, month => 1, day => 1, hour => 0, minute => 0, second => 0, time_zone => '+0000' );
$dt_3 = DateTime->new( year => 2001, month => 1, day => 1, hour => 0, minute => 0, second => 0, time_zone => '+0400' );
is( t::lib::Dates::compare( $dt_1, $dt_3 ), 1, 'Different timezone and different date/time' );
