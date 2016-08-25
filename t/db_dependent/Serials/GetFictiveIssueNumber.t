#!/usr/bin/perl

use C4::Context;
use Test::More tests => 18;
use Modern::Perl;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

use C4::Serials::Frequency;
use C4::Serials;

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
my $issueNumber;

$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-01', $frequency );
is( $issueNumber, '1' );

$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-02', $frequency );
is( $issueNumber, '2' );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-03', $frequency );
is( $issueNumber, '3' );

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
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-01', $frequency );
is( $issueNumber, '1' );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-02', $frequency );
is( $issueNumber, '3' );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-03', $frequency );
is( $issueNumber, '5' );

$subscription->{countissuesperunit} = 2;
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-01', $frequency );
is( $issueNumber, '2' );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-02', $frequency );
is( $issueNumber, '4' );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-03', $frequency );
is( $issueNumber, '6' );

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
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-01', $frequency );
is( $issueNumber, 1 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-02', $frequency );
is( $issueNumber, 1 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-03', $frequency );
is( $issueNumber, 2 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-04', $frequency );
is( $issueNumber, 2 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-05', $frequency );
is( $issueNumber, 3 );

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
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-01', $frequency );
is( $issueNumber, 1 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-02', $frequency );
is( $issueNumber, 1 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-08', $frequency );
is( $issueNumber, 2 );
$issueNumber =
  C4::Serials::GetFictiveIssueNumber( $subscription, '1970-01-15', $frequency );
is( $issueNumber, 3 );

$dbh->rollback;
