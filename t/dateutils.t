use strict;
use warnings;
use 5.010;

use C4::Context;
use Test::More tests => 7;    # last test to print

BEGIN { use_ok('Koha::DateUtils'); }

my $tz = C4::Context->tz;

isa_ok( $tz, 'DateTime::TimeZone', 'Context returns timezone object' );

my $testdate_iso = '2011-06-16';                   # Bloomsday 2011
my $dt = dt_from_string( $testdate_iso, 'iso' );

isa_ok( $dt, 'DateTime', 'dt_from_string returns a DateTime object' );

cmp_ok( $dt->ymd(), 'eq', $testdate_iso, 'Returned object matches input' );

$dt->set_hour(12);
$dt->set_minute(0);

my $date_string = output_pref( $dt, 'iso' );
cmp_ok $date_string, 'eq', '2011-06-16 12:00', 'iso output';

$date_string = output_pref( $dt, 'us' );
cmp_ok $date_string, 'eq', '06/16/2011 12:00', 'us output';

# metric should return the French Revolutionary Calendar Really
$date_string = output_pref( $dt, 'metric' );
cmp_ok $date_string, 'eq', '16/06/2011 12:00', 'metric output';
