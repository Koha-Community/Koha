#!/usr/bin/perl

use C4::Context;
use Test::More tests => 96;
use Modern::Perl;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

use C4::Serials::Frequency;
use C4::Serials;

# TEST CASE - 1 issue per day, no irregularities
my $frequency = {
    description => "One issue per day",
    unit => 'day',
    issuesperunit => 1,
    unitsperissue => 1,
};
my $id = AddSubscriptionFrequency($frequency);

my $subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
my $publisheddate = $subscription->{firstacquidate};

$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-04');

# TEST CASE - 1 issue per day, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '2;4',  # Skip the second and fourth issues
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-05');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-06');

# TEST CASE - 2 issues per day, no irregularity
$id = AddSubscriptionFrequency({
    description => "Two issues per day",
    unit => 'day',
    issuesperunit => 2,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');

# TEST CASE - 2 issues per day, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-04');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-04');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-05');

# TEST CASE - 1 issue every 2 days, no irregularity
$id = AddSubscriptionFrequency({
    description => "one issue every two days",
    unit => 'day',
    issuesperunit => 1,
    unitsperissue => 2,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-05');

# TEST CASE - 1 issue every 2 days, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-07');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-09');

# TEST CASE - 1 issue per week, no irregularity
$id = AddSubscriptionFrequency({
    description => "one issue per week",
    unit => 'week',
    issuesperunit => 1,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-08');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-15');

# TEST CASE - 1 issue per week, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-08');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-22');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-29');

# TEST CASE - 1 issue every 2 weeks, no irregularity
$id = AddSubscriptionFrequency({
    description => "one issue every 2 weeks",
    unit => 'week',
    issuesperunit => 1,
    unitsperissue => 2,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-15');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-29');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-12');

# TEST CASE - 1 issue every 2 weeks, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-15');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-12');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-26');

# TEST CASE - 2 issues per week, no irregularity
$id = AddSubscriptionFrequency({
    description => "two issues per week",
    unit => 'week',
    issuesperunit => 2,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
# when more than 1 issue per week, date is automatically set to the same day of
# week as firstacquidate
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-08');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-10');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-15');

# TEST CASE - 2 issues per week, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-03');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-10');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-22');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-24');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-29');

# TEST CASE - 6 issues per week, no irregularity
$id = AddSubscriptionFrequency({
    description => "six issues per week",
    unit => 'week',
    issuesperunit => 6,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-06',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-07');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-08');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-09');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-10');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-11');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-13');

# TEST CASE - 6 issues per week, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-06',
    irregularity => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-07');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-09');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-13');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-14');

# TEST CASE - 1 issue per month, no irregularity
$id = AddSubscriptionFrequency({
    description => "1 issue per month",
    unit => 'month',
    issuesperunit => 1,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-03-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-04-01');

# TEST CASE - 1 issue per month, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-03-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-05-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-06-01');

# TEST CASE - 1 issue every 2 months, no irregularity
$id = AddSubscriptionFrequency({
    description => "1 issue every 2 months",
    unit => 'month',
    issuesperunit => 1,
    unitsperissue => 2,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-03-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-05-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-07-01');

# TEST CASE - 1 issue every 2 months, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '2;3',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-07-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-09-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-11-01');

# TEST CASE - 2 issues per month, no irregularity
$id = AddSubscriptionFrequency({
    description => "2 issues per month",
    unit => 'month',
    issuesperunit => 2,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-16', 'January has 31 days');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-15', 'February has only 28 days');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-03-01');

# TEST CASE - 2 issues per month, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-01-16', 'January has 31 days');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-02-15', 'February has only 28 days');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-04-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-04-16', 'April has 30 days');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-05-01');

# TEST CASE - 1 issue per year, no irregularity
$id = AddSubscriptionFrequency({
    description => "1 issue per year",
    unit => 'year',
    issuesperunit => 1,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1971-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1972-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1973-01-01');

# TEST CASE - 1 issue per year, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1972-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1974-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1975-01-01');

# TEST CASE - 1 issue every 2 years, no irregularity
$id = AddSubscriptionFrequency({
    description => "1 issue every 2 years",
    unit => 'year',
    issuesperunit => 1,
    unitsperissue => 2,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1972-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1974-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1976-01-01');

# TEST CASE - 1 issue every 2 years, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '2;4',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1974-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1978-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1980-01-01');

# TEST CASE - 2 issues per year, no irregularity
$id = AddSubscriptionFrequency({
    description => "1 issue every 2 years",
    unit => 'year',
    issuesperunit => 2,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-07-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1971-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1971-07-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1972-01-01');

# TEST CASE - 2 issues per year, irregularities
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '3;5;6',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1970-07-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1971-07-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1973-01-01');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1973-07-02');
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, '1974-01-01');

# TEST CASE - Irregular
$id = AddSubscriptionFrequency({
    description => "Irregular",
    unit => undef,
    issuesperunit => 1,
    unitsperissue => 1,
});
$subscription = {
    periodicity => $id,
    firstacquidate => '1970-01-01',
    irregularity => '',
    countissuesperunit => 1,
};
$publisheddate = $subscription->{firstacquidate};
# GetNextDate always return undef if subscription is irregular
$publisheddate = GetNextDate($subscription, $publisheddate);
is($publisheddate, undef);

# GetNextDate returns undef if one of two first parameters is undef
$publisheddate = GetNextDate($subscription, undef);
is($publisheddate, undef);
$publisheddate = GetNextDate(undef, $subscription->{firstacquidate});
is($publisheddate, undef);
$publisheddate = GetNextDate(undef, undef);
is($publisheddate, undef);

$dbh->rollback;
