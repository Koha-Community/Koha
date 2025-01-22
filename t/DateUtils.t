use Modern::Perl;
use DateTime;
use DateTime::TimeZone;

use C4::Context;

use Test::NoWarnings;
use Test::More tests => 84;

use Test::MockModule;
use Test::Warn;
use Time::HiRes qw/ gettimeofday /;
use Try::Tiny;

use Koha::DateUtils qw( dt_from_string output_pref format_sqldatetime flatpickr_date_format );

use t::lib::Mocks;

t::lib::Mocks::mock_preference( 'dateformat', 'us' );
t::lib::Mocks::mock_preference( 'TimeFormat', 'This_is_not_used_but_called' );

my $tz = C4::Context->tz;

isa_ok( $tz, 'DateTime::TimeZone', 'Context returns timezone object' );

my $testdate_iso = '2011-06-16';                             # Bloomsday 2011
my $dt           = dt_from_string( $testdate_iso, 'iso' );

isa_ok( $dt, 'DateTime', 'dt_from_string returns a DateTime object' );

cmp_ok( $dt->ymd(), 'eq', $testdate_iso, 'Returned object matches input' );

$dt->set_hour(12);
$dt->set_minute(0);

my $date_string;

my $dateformat = C4::Context->preference('dateformat');
cmp_ok output_pref( { dt => $dt, dateformat => $dateformat } ),
    'eq',
    output_pref($dt),
    'output_pref gives an hashref or a dt';

$date_string = output_pref( { dt => $dt, dateformat => 'iso', timeformat => '24hr' } );
cmp_ok $date_string, 'eq', '2011-06-16 12:00', 'iso output';

$date_string = output_pref( { dt => $dt, dateformat => 'iso', timeformat => '12hr' } );
cmp_ok $date_string, 'eq', '2011-06-16 12:00 PM', 'iso output 12hr';

$date_string = output_pref( { dt => $dt, dateformat => 'rfc3339' } );
like( $date_string, qr/2011-06-16T12:00:00\+|-\d\d:\d\d/, 'RFC3339 output' );

$date_string = output_pref( { dt => $dt, dateformat => 'rfc3339', dateonly => 1 } );
is( $date_string, '2011-06-16', 'RFC3339 output' );

# "notime" doesn't actually mean anything in this context, but we
# can't pass undef or output_pref will try to access the database
$date_string = output_pref( { dt => $dt, dateformat => 'iso', timeformat => 'notime', dateonly => 1 } );
cmp_ok $date_string, 'eq', '2011-06-16', 'iso output (date only)';

$date_string = output_pref( { dt => $dt, dateformat => 'us', timeformat => '24hr' } );
cmp_ok $date_string, 'eq', '06/16/2011 12:00', 'us output';

$date_string = output_pref( { dt => $dt, dateformat => 'us', timeformat => '12hr' } );
cmp_ok $date_string, 'eq', '06/16/2011 12:00 PM', 'us output 12hr';

$date_string = output_pref( { dt => $dt, dateformat => 'us', timeformat => 'notime', dateonly => 1 } );
cmp_ok $date_string, 'eq', '06/16/2011', 'us output (date only)';

# metric should return the French Revolutionary Calendar Really
$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => '24hr' } );
cmp_ok $date_string, 'eq', '16/06/2011 12:00', 'metric output';

$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => 'notime', dateonly => 1 } );
cmp_ok $date_string, 'eq', '16/06/2011', 'metric output (date only)';

$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => '24hr' } );
cmp_ok $date_string, 'eq', '16/06/2011 12:00',
    'output_pref preserves non midnight HH:SS';

my $dear_dirty_dublin = DateTime::TimeZone->new( name => 'Europe/Dublin' );
my $new_dt            = dt_from_string( '16/06/2011', 'metric', $dear_dirty_dublin );
isa_ok( $new_dt, 'DateTime', 'Create DateTime with different timezone' );
cmp_ok(
    $new_dt->ymd(), 'eq', $testdate_iso,
    'Returned Dublin object matches input'
);

SKIP: {
    skip "Don't test execution time of dt_from_string on slow servers", 6 if $ENV{SLOW_SERVER};
    for (qw/ 2014-01-01 2100-01-01 9999-01-01 /) {
        my $duration = gettimeofday();
        $new_dt   = dt_from_string( $_, 'iso', $dear_dirty_dublin );
        $duration = gettimeofday() - $duration;
        cmp_ok $duration, '<', 1, "Create DateTime with dt_from_string() for $_ with TZ in less than 1s";
        $duration = gettimeofday();
        output_pref( { dt => $new_dt } );
        $duration = gettimeofday() - $duration;
        cmp_ok $duration, '<', 1, "Create DateTime with output_pref() for $_ with TZ in less than 1s";
    }
}

$new_dt = dt_from_string( '2011-06-16 12:00', 'sql' );
isa_ok( $new_dt, 'DateTime', 'Create DateTime from (mysql) sql' );
cmp_ok( $new_dt->ymd(), 'eq', $testdate_iso, 'sql returns correct date' );

$new_dt = dt_from_string( $dt, 'iso' );
isa_ok( $new_dt, 'DateTime', 'Passed a DateTime dt_from_string returns it' );

my $ymd = '2012-01-01';
my $dt0 = dt_from_string( '00/01/2012', 'metric' );
isa_ok(
    $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero metric day'
);
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects metric day 0' );

$dt0 = dt_from_string( '01/00/2012', 'us' );
isa_ok(
    $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero us day'
);
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects us day 0' );

$dt0 = dt_from_string( '2012-01-00', 'iso' );
isa_ok(
    $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero iso day'
);
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects iso day 0' );

$dt0 = dt_from_string( '2012-01-00T12:00:00Z', 'rfc3339' );
isa_ok(
    $dt0, 'DateTime',
    'dt_from_string returns a DateTime object passed a zero rfc3339 day'
);
cmp_ok( $dt0->ymd(), 'eq', $ymd, 'Returned object corrects rfc3339 day 0' );

$dt0 = dt_from_string( '2012-01-01T23:59:00.0Z', 'rfc3339' );
cmp_ok( $dt0->epoch(), 'eq', '1325462340', 'dt_from_string handles seconds with 1 decimal place' );

$dt0 = dt_from_string( '2012-01-01T23:59:00.00Z', 'rfc3339' );
cmp_ok( $dt0->epoch(), 'eq', '1325462340', 'dt_from_string handles seconds with 2 decimal places' );

$dt0 = dt_from_string( '2012-01-01t23:59:59.999z', 'rfc3339' );
cmp_ok( $dt0->epoch(), 'eq', '1325462399', 'dt_from_string handles seconds with 3 decimal places' );

$dt0 = dt_from_string( '2012-01-01T23:59:59.999+02:00', 'rfc3339' );
cmp_ok( $dt0->epoch(), 'eq', '1325455199', 'dt_from_string handles seconds with 3 decimal places and a timezone' );

eval {
    $dt0 = dt_from_string( '2012-01-01T23:59:59.999Z+02:00', 'rfc3339' );    # Do not combine Z with +02 !
};
like( $@, qr/Invalid date format/, 'dt_from_string should die when passed a bad rfc3339 date string' );

eval {
    $dt0 = dt_from_string( '2021-11-03T10:16:59Z+00:00', 'iso' );   # Z and +00 are the same, but should not be together
};
like(
    $@, qr/.*does not match the date format \(iso\).*/,
    'dt_from_string should die when passed a bad iso date string'
);

# ISO string tests
subtest 'dt_from_string - iso format' => sub {
    plan tests => 7;

    my $module_context = Test::MockModule->new('C4::Context');
    $module_context->mock(
        'tz',
        sub {
            return DateTime::TimeZone->new( name => 'Europe/Paris' );
        }
    );

    # Dateonly
    my $dt_iso = dt_from_string( '2012-01-01', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325372400', 'dt_from_string handles dateonly string' );

    # Saturday December 31, 2011 23:00:00 (UTC) == Sunday January 01, 2012 00:00:00 Europe/Paris (CET/+01:00)

    eval { $dt_iso = dt_from_string( '2012-01-32', 'iso' ); };
    like( $@, qr/^Validation failed/, 'Fail on invalid dateonly string' );

    # Datetime
    $dt_iso = dt_from_string( '2012-01-01T23:59:59', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325458799', 'dt_from_string with no offset assumes "local"' );

    # Sunday January 01, 2012 22:59:59 (UTC) == Sunday January 01, 2012 23:59:59 Europe/Paris (CET/+01:00)

    # Datetime with timezone
    $dt_iso = dt_from_string( '2012-01-01T23:59:59Z', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325462399', 'dt_from_string with UTC prescribed as Z' );

    # Sunday January 01, 2012 23:59:59 (UTC)

    $dt_iso = dt_from_string( '2012-01-01T23:59:59+02:00', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325455199', 'dt_from_string with offset +02:00' );

    # Sunday January 01, 2012 21:59:59 (UTC) == Sunday January 01, 2012 23:59:59 Europe/Athens (EET/+02:00)
    # Allow +02 or +0200 too
    $dt_iso = dt_from_string( '2012-01-01T23:59:59+02', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325455199', 'dt_from_string with offset +02' );
    $dt_iso = dt_from_string( '2012-01-01T23:59:59+0200', 'iso' );
    cmp_ok( $dt_iso->epoch(), 'eq', '1325455199', 'dt_from_string with offset +0200' );

};

# Return undef if passed mysql 0 dates
$dt0 = dt_from_string( '0000-00-00', 'iso' );
is( $dt0, undef, "undefined returned for 0 iso date" );

# Return undef if passed mysql 9999-* date
my $dt9999 = dt_from_string( '9999-12-31', 'sql' );
is( $dt9999->ymd(), '9999-12-31', "dt_from_string should return a DateTime object for 9999-12-31" );

my $formatted = format_sqldatetime( '2011-06-16 12:00:07', 'metric', '24hr' );
cmp_ok( $formatted, 'eq', '16/06/2011 12:00', 'format_sqldatetime conversion' );

$formatted = format_sqldatetime( undef, 'metric' );
cmp_ok(
    $formatted, 'eq', q{},
    'format_sqldatetime formats undef as empty string'
);

# Test the as_due_date parameter
$dt = DateTime->new(
    year   => 2013,
    month  => 12,
    day    => 11,
    hour   => 23,
    minute => 59,
);
$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => '24hr', as_due_date => 1 } );
cmp_ok $date_string, 'eq', '11/12/2013', 'as_due_date with hours and timeformat 24hr';

$date_string =
    output_pref( { dt => $dt, dateformat => 'metric', timeformat => '24hr', dateonly => 1, as_due_date => 1 } );
cmp_ok $date_string, 'eq', '11/12/2013', 'as_due_date without hours and timeformat 24hr';

$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => '12hr', as_due_date => 1 } );
cmp_ok $date_string, 'eq', '11/12/2013', 'as_due_date with hours and timeformat 12hr';

$date_string =
    output_pref( { dt => $dt, dateformat => 'metric', timeformat => '12hr', dateonly => 1, as_due_date => 1 } );
cmp_ok $date_string, 'eq', '11/12/2013', 'as_due_date without hours and timeformat 12hr';

# Test as_due_date for hourly loans
$dt = DateTime->new(
    year   => 2013,
    month  => 12,
    day    => 11,
    hour   => 18,
    minute => 35,
);
$date_string = output_pref( { dt => $dt, dateformat => 'metric', timeformat => '24hr', as_due_date => 1 } );
cmp_ok $date_string, 'eq', '11/12/2013 18:35', 'as_due_date with hours and timeformat 24hr (non-midnight time)';
$date_string = output_pref( { dt => $dt, dateformat => 'us', timeformat => '12hr', as_due_date => 1 } );
cmp_ok $date_string, 'eq', '12/11/2013 06:35 PM', 'as_due_date with hours and timeformat 12hr (non-midnight time)';

my $now = DateTime->now;
is( dt_from_string, $now, "Without parameter, dt_from_string should return today" );

my $module_context = Test::MockModule->new('C4::Context');
$module_context->mock(
    'tz',
    sub {
        return DateTime::TimeZone->new( name => 'Europe/Lisbon' );
    }
);

$dt = dt_from_string('1979-04-01');
isa_ok( $dt, 'DateTime', 'dt_from_string should return a DateTime object if a DST is given' );

$module_context->mock(
    'tz',
    sub {
        return DateTime::TimeZone->new( name => 'Europe/Paris' );
    }
);

$dt = dt_from_string('2014-03-30 02:00:00');
isa_ok( $dt, 'DateTime', 'dt_from_string should return a DateTime object if a DST is given' );

# Test output_pref for invalid local time explosion
$dt = DateTime->new(
    year   => 2017,
    month  => 3,
    day    => 26,
    hour   => 1,
    minute => 35,
);
$module_context->mock(
    'tz',
    sub {
        return DateTime::TimeZone->new( name => 'Europe/London' );
    }
);
is(
    output_pref( { dt => $dt, dateonly => 0 } ), '03/26/2017 01:35',
    'output_pref should return even if an invalid DST time is passed'
);

# Test dt_from_string
t::lib::Mocks::mock_preference( 'dateformat', 'metric' );
t::lib::Mocks::mock_preference( 'TimeFormat', '24hr' );

# dt_from_string should take into account the dateformat pref, or the given parameter
$dt = dt_from_string('31/01/2015');
is( ref($dt), 'DateTime', '31/01/2015 is a correct date in metric format' );
is( output_pref( { dt => $dt, dateonly => 1 } ), '31/01/2015' );
$dt = eval { dt_from_string( '31/01/2015', 'iso' ); };
is( ref($dt), '', '31/01/2015 is not a correct date in iso format' );
$dt = eval { dt_from_string( '01/01/2015', 'iso' ); };
is( ref($dt), '', '01/01/2015 is not a correct date in iso format' );
$dt = eval { dt_from_string( '01/01/2015', 'rfc3339' ); };
is( ref($dt), '', '01/01/2015 is not a correct date in rfc3339 format' );
$dt = eval { dt_from_string( '31/01/2015', 'us' ); };
is( ref($dt), '', '31/01/2015 is not a correct date in us format' );
$dt = dt_from_string( '01/01/2015', 'us' );
is( ref($dt), 'DateTime', '01/01/2015 is a correct date in us format' );
$dt = dt_from_string( '01.01.2015', 'dmydot' );
is( ref($dt), 'DateTime', '01.01.2015 is a correct date in dmydot format' );

# default value for hh and mm is 00:00
$dt = dt_from_string('31/01/2015');
is(
    output_pref( { dt => $dt } ), '31/01/2015 00:00',
    'dt_from_string should generate a DT object with 00:00 as default hh:mm'
);

$dt = dt_from_string('31/01/2015 12:34');
is( output_pref( { dt => $dt } ), '31/01/2015 12:34', 'dt_from_string should match hh:mm' );

$dt = dt_from_string('31/01/2015 12:34:56');
is( output_pref( { dt => $dt } ), '31/01/2015 12:34', 'dt_from_string should match hh:mm:ss' );

# date before 1900
$dt = dt_from_string('01/01/1900');
is( output_pref( { dt => $dt, dateonly => 1 } ), '01/01/1900', 'dt_from_string should manage date < 1900' );

# fallback
$dt = dt_from_string('2015-01-31 01:02:03');
is( output_pref( { dt => $dt } ), '31/01/2015 01:02', 'dt_from_string should fallback to sql format' );

# 12hr format
$dt = dt_from_string('2015-01-31 01:02 AM');
is( output_pref( { dt => $dt } ), '31/01/2015 01:02', 'dt_from_string ' );
$dt = dt_from_string('2015-01-31 01:02:03 AM');
is( output_pref( { dt => $dt } ), '31/01/2015 01:02', 'dt_from_string ' );
$dt = dt_from_string('2015-01-31 01:02 PM');
is( output_pref( { dt => $dt } ), '31/01/2015 13:02', 'dt_from_string ' );
$dt = dt_from_string('2015-01-31 01:02:03 PM');
is( output_pref( { dt => $dt } ), '31/01/2015 13:02', 'dt_from_string ' );
$dt = dt_from_string('2015-01-31 12:02 AM');
is( output_pref( { dt => $dt } ), '31/01/2015 00:02', 'dt_from_string ' );
$dt = dt_from_string('2015-01-31 12:02:03 AM');
is( output_pref( { dt => $dt } ), '31/01/2015 00:02', 'dt_from_string ' );

subtest 'TimeFormat 12hr' => sub {
    plan tests => 4;

    $dt = DateTime->new( year => 2020, month => 5, day => 28, hour => 12, minute => 49 );
    t::lib::Mocks::mock_preference( 'TimeFormat', '12hr' );
    my $output = output_pref( { dt => $dt, dateformat => 'iso' } );
    $dt = dt_from_string( $output, 'iso' );
    is( output_pref( { dt => $dt } ), '28/05/2020 12:49 PM', "12 NOON formatted correctly in 12hr format" );
    t::lib::Mocks::mock_preference( 'TimeFormat', '24hr' );
    is( output_pref( { dt => $dt } ), '28/05/2020 12:49', "12 NOON formatted correctly in 24hr format" );

    $dt = DateTime->new( year => 2020, month => 5, day => 28, hour => 0, minute => 49 );
    t::lib::Mocks::mock_preference( 'TimeFormat', '12hr' );
    $output = output_pref( { dt => $dt, dateformat => 'iso' } );
    $dt     = dt_from_string( $output, 'iso' );
    is( output_pref( { dt => $dt } ), '28/05/2020 12:49 AM', "12 MIDNIGHT formatted correctly in 12hr format" );
    t::lib::Mocks::mock_preference( 'TimeFormat', '24hr' );
    is( output_pref( { dt => $dt } ), '28/05/2020 00:49', "12 MIDNIGHT formatted correctly in 24hr format" );
};

# output_pref with no parameters, single parameter (no hash)
is( output_pref(), undef, 'Call output_pref without parameters' );
try {
    output_pref('no_dt');
    ok( 0, 'Passed single invalid dt to output_pref' );
} catch {
    is(
        ref($_), 'Koha::Exceptions::WrongParameter',
        'Passed single invalid dt to output_pref'
    );
};

# pass invalid dt via hash
try {
    output_pref( { dt => 'no_dt' } );
    ok( 0, 'Passed invalid dt in hash to output_pref' );
} catch {
    is(
        ref($_), 'Koha::Exceptions::WrongParameter',
        'Passed invalid dt in hash to output_pref'
    );
};

# output_pref with str parameter
is(
    output_pref( { 'str' => $testdate_iso, dateformat => 'iso', dateonly => 1 } ), $testdate_iso,
    'output_pref should handle correctly the iso parameter'
);
my $output_for_invalid_date;
try {
    $output_for_invalid_date = output_pref( { str => 'invalid_date' } );
    ok( 0, 'Invalid date string passed to output_pref' );
} catch {
    is(
        ref($_), 'Koha::Exceptions::WrongParameter',
        'Invalid date string passed to output_pref'
    );
};
is( $output_for_invalid_date, undef, 'No return value from output_pref' );
try {
    output_pref( { 'str' => $testdate_iso, dt => $dt, dateformat => 'iso', dateonly => 1 } );
    ok( 0, 'output_pref should carp if str and dt parameters are passed together' );
} catch {
    is(
        ref($_), 'Koha::Exceptions::WrongParameter',
        'output_pref should throw an exception if str and dt parameters are passed together'
    );
};

subtest 'flatpickr_date_format' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'dateformat', 'iso' );
    is( flatpickr_date_format(),         'Y-m-d', 'check fallback to pref' );
    is( flatpickr_date_format(q{}),      undef,   'empty string' );
    is( flatpickr_date_format('metric'), 'd/m/Y', 'check valid arg' );
    is( flatpickr_date_format('zz'),     undef,   'wrong arg' );
};

# End of tests
