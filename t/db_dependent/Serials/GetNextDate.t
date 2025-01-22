#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 103;

use Koha::Database;
use C4::Serials qw( GetNextDate );
use C4::Serials::Frequency;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# TEST CASE - 1 issue per day, no irregularities
my $frequency = {
    description   => "One issue per day",
    unit          => 'day',
    issuesperunit => 1,
    unitsperissue => 1,
};

my $subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
my $publisheddate = $subscription->{firstacquidate};

$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-03' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-04' );

# TEST CASE - 1 issue per day, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '2;4',          # Skip the second and fourth issues
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-03' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-05' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-06' );

# TEST CASE - 2 issues per day, no irregularity
$frequency = {
    description   => "Two issues per day",
    unit          => 'day',
    issuesperunit => 2,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-03' );

# TEST CASE - 2 issues per day, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-04' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-04' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-05' );

# TEST CASE - 1 issue every 2 days, no irregularity
$frequency = {
    description   => "one issue every two days",
    unit          => 'day',
    issuesperunit => 1,
    unitsperissue => 2,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-03' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-05' );

# TEST CASE - 1 issue every 2 days, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-03' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-07' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-09' );

# TEST CASE - 1 issue per week, no irregularity
$frequency = {
    description   => "one issue per week",
    unit          => 'week',
    issuesperunit => 1,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-08' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-15' );

# TEST CASE - 1 issue per week, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-08' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-22' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-29' );

# TEST CASE - 1 issue every 2 weeks, no irregularity
$frequency = {
    description   => "one issue every 2 weeks",
    unit          => 'week',
    issuesperunit => 1,
    unitsperissue => 2,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-15' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-29' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-12' );

# TEST CASE - 1 issue every 2 weeks, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-15' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-12' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-26' );

# TEST CASE - 2 issues per week, no irregularity
$frequency = {
    description   => "two issues per week",
    unit          => 'week',
    issuesperunit => 2,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-04' );

# when more than 1 issue per week, date is automatically set to the same day of
# week as firstacquidate
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-08' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-11' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-15' );

# TEST CASE - 2 issues per week, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-04' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-11' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-22' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-25' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-29' );

# TEST CASE - 6 issues per week, no irregularity
$frequency = {
    description   => "six issues per week",
    unit          => 'week',
    issuesperunit => 6,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-06',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-07' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-08' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-09' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-10' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-11' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-13' );

# TEST CASE - 6 issues per week, irregularities
$subscription = {
    firstacquidate     => '1970-01-06',
    irregularity       => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-07' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-09' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-13' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-14' );

# TEST CASE - 1 issue per month, no irregularity
$frequency = {
    description   => "1 issue per month",
    unit          => 'month',
    issuesperunit => 1,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-03-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-04-01' );

# TEST CASE - 1 issue per month, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-03-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-05-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-06-01' );

# TEST CASE - 1 issue every 2 months, no irregularity
$frequency = {
    description   => "1 issue every 2 months",
    unit          => 'month',
    issuesperunit => 1,
    unitsperissue => 2,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-03-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-05-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-07-01' );

# TEST CASE - 1 issue every 2 months, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '2;3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-07-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-09-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-11-01' );

# TEST CASE - 2 issues per month, no irregularity
$frequency = {
    description   => "2 issues per month",
    unit          => 'month',
    issuesperunit => 2,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-16', 'January has 31 days' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-16', 'February has only 28 days' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-03-01' );

# TEST CASE - 2 issues per month, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-01-16', 'January has 31 days' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-02-16', 'February has only 28 days' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-04-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-04-16', 'April has 30 days' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-05-01' );

# TEST CASE - 1 issue per year, no irregularity
$frequency = {
    description   => "1 issue per year",
    unit          => 'year',
    issuesperunit => 1,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1971-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1972-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1973-01-01' );

# TEST CASE - 1 issue per year, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1972-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1974-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1975-01-01' );

# TEST CASE - 1 issue every 2 years, no irregularity
$frequency = {
    description   => "1 issue every 2 years",
    unit          => 'year',
    issuesperunit => 1,
    unitsperissue => 2,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1972-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1974-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1976-01-01' );

# TEST CASE - 1 issue every 2 years, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1974-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1978-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1980-01-01' );

# Move publisheddate to Feb 29 (leap year 1980)
$publisheddate = '1980-02-29';
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1982-02-28', 'Test +2 year from Feb 29' );

# TEST CASE - 2 issues per year, no irregularity
$frequency = {
    description   => "1 issue every 2 years",
    unit          => 'year',
    issuesperunit => 2,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-07-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1971-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1971-07-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1972-01-01' );

# TEST CASE - 2 issues per year, irregularities
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1970-07-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1971-07-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1973-01-01' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1973-07-02' );
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, '1974-01-01' );

# TEST CASE - 9 issues per year, dates spread throughout month
$frequency = {
    description   => "9 issues per year",
    unit          => 'year',
    issuesperunit => 9,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-08-10',
    irregularity       => '',
    countissuesperunit => 1,
};
my @dates = ( $subscription->{firstacquidate} );
foreach ( 1 .. 27 ) {
    push @dates, GetNextDate( $subscription, $dates[-1], $frequency );
}
is( $dates[9],  '1971-08-10', 'Freq 9/yr, 1 year passed' );
is( $dates[18], '1972-08-10', 'Freq 9/yr, 2 years passed (leap year)' );
is( $dates[27], '1973-08-10', 'Freq 9/yr, 3 years passed' );

# Keep (first) position in cycle, but shift back 9 days
is( GetNextDate( $subscription, '1973-08-01', $frequency ), '1973-09-10', 'Back 9 days, without annual correction' );

# Set position to last in cycle, and shift back 9 days; annual correction
$subscription->{countissuesperunit} = 9;
is(
    GetNextDate( $subscription, '1973-08-01', $frequency ), '1973-09-15',
    'Last in cycle, back 9 days, expect annual correction'
);

# TEST CASE - Irregular
$frequency = {
    description   => "Irregular",
    unit          => undef,
    issuesperunit => 1,
    unitsperissue => 1,
};
$subscription = {
    firstacquidate     => '1970-01-01',
    irregularity       => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};

# GetNextDate always return undef if subscription is irregular
$publisheddate = GetNextDate( $subscription, $publisheddate, $frequency );
is( $publisheddate, undef );

# GetNextDate returns undef if one of two first parameters is undef
$publisheddate = GetNextDate( $subscription, undef, $frequency );
is( $publisheddate, undef );
$publisheddate = GetNextDate( undef, $subscription->{firstacquidate}, $frequency );
is( $publisheddate, undef );
$publisheddate = GetNextDate( undef, undef, $frequency );
is( $publisheddate, undef );

$schema->storage->txn_rollback;
