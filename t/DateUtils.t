use strict;
use warnings;
use 5.010;
use DateTime;
use DateTime::TimeZone;

use C4::Context;
use Test::More tests => 30;

BEGIN { use_ok('Koha::DateUtils'); }

my $tz = C4::Context->tz;

isa_ok( $tz, 'DateTime::TimeZone', 'Context returns timezone object' );

my $testdate_iso = '2011-06-16';                   # Bloomsday 2011
my $dt = dt_from_string( $testdate_iso, 'iso' );

isa_ok( $dt, 'DateTime', 'dt_from_string returns a DateTime object' );

cmp_ok( $dt->ymd(), 'eq', $testdate_iso, 'Returned object matches input' );

$dt->set_hour(12);
$dt->set_minute(0);

my $date_string = output_pref( $dt, 'iso', '24hr' );
cmp_ok $date_string, 'eq', '2011-06-16 12:00', 'iso output';

$date_string = output_pref( $dt, 'iso', '12hr' );
cmp_ok $date_string, 'eq', '2011-06-16 12:00 PM', 'iso output 12hr';

# "notime" doesn't actually mean anything in this context, but we
# can't pass undef or output_pref will try to access the database
$date_string = output_pref( $dt, 'iso', 'notime', 1 );
cmp_ok $date_string, 'eq', '2011-06-16', 'iso output (date only)';

$date_string = output_pref( $dt, 'us', '24hr' );
cmp_ok $date_string, 'eq', '06/16/2011 12:00', 'us output';

$date_string = output_pref( $dt, 'us', '12hr' );
cmp_ok $date_string, 'eq', '06/16/2011 12:00 PM', 'us output 12hr';

$date_string = output_pref( $dt, 'us', 'notime', 1 );
cmp_ok $date_string, 'eq', '06/16/2011', 'us output (date only)';

# metric should return the French Revolutionary Calendar Really
$date_string = output_pref( $dt, 'metric', '24hr' );
cmp_ok $date_string, 'eq', '16/06/2011 12:00', 'metric output';

$date_string = output_pref( $dt, 'metric', 'notime', 1 );
cmp_ok $date_string, 'eq', '16/06/2011', 'metric output (date only)';

$date_string = output_pref_due( $dt, 'metric', '24hr' );
cmp_ok $date_string, 'eq', '16/06/2011 12:00',
  'output_pref_due preserves non midnight HH:SS';

$dt->set_hour(23);
$dt->set_minute(59);
$date_string = output_pref_due( $dt, 'metric', '24hr' );
cmp_ok $date_string, 'eq', '16/06/2011',
  'output_pref_due truncates HH:SS at midnight';

my $dear_dirty_dublin = DateTime::TimeZone->new( name => 'Europe/Dublin' );
my $new_dt = dt_from_string( '16/06/2011', 'metric', $dear_dirty_dublin );
isa_ok( $new_dt, 'DateTime', 'Create DateTime with different timezone' );
cmp_ok( $new_dt->ymd(), 'eq', $testdate_iso,
    'Returned Dublin object matches input' );

$new_dt = dt_from_string( '2011-06-16 12:00', 'sql' );
isa_ok( $new_dt, 'DateTime', 'Create DateTime from (mysql) sql' );
cmp_ok( $new_dt->ymd(), 'eq', $testdate_iso, 'sql returns correct date' );

$new_dt = dt_from_string( $dt, 'iso' );
isa_ok( $new_dt, 'DateTime', 'Passed a DateTime dt_from_string returns it' );

# C4::Dates allowed 00th of the month

my $ymd = '2012-01-01';
my $dt0 = dt_from_string( '00/01/2012', 'metric' );
isa_ok( $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero metric day' );
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects metric day 0' );

$dt0 = dt_from_string( '01/00/2012', 'us' );
isa_ok( $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero us day' );
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects us day 0' );

$dt0 = dt_from_string( '2012-01-00', 'iso' );
isa_ok( $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero iso day' );
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects iso day 0' );

# Return undef if passed mysql 0 dates
$dt0 = dt_from_string( '0000-00-00', 'iso' );
is( $dt0, undef, "undefined returned for 0 iso date" );

my $formatted = format_sqldatetime( '2011-06-16 12:00:07', 'metric', '24hr' );
cmp_ok( $formatted, 'eq', '16/06/2011 12:00', 'format_sqldatetime conversion' );

$formatted = format_sqldatetime( undef, 'metric' );
cmp_ok( $formatted, 'eq', q{},
    'format_sqldatetime formats undef as empty string' );

$formatted = format_sqlduedatetime( '2011-06-16 12:00:07', 'metric', '24hr' );
cmp_ok(
    $formatted, 'eq',
    '16/06/2011 12:00',
    'format_sqlduedatetime conversion for hourly loans'
);

$formatted = format_sqlduedatetime( '2011-06-16 23:59:07', 'metric', '24hr' );
cmp_ok( $formatted, 'eq', '16/06/2011',
    'format_sqlduedatetime conversion for daily loans' );
