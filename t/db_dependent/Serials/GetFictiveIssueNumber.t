#!/usr/bin/perl

# This test deals with GetFictiveIssueNumber (from C4::Serials)

use Modern::Perl;
use Test::More tests => 2;

use Koha::Database;
use C4::Serials;
use C4::Serials::Frequency;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

subtest 'Tests for irregular frequency' => sub {
    plan tests => 2;

    # Add a frequency
    my $freq_irr = AddSubscriptionFrequency({
        description => "Irregular",
        unit => undef,
    });

    # Test it
    my $subscription = {
        periodicity => $freq_irr,
        firstacquidate => '1972-02-07',
    };
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1972-12-31'), 0, 'Irregular: should be zero' );
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-12-31'), 0, 'Irregular: still zero' );
};

subtest 'Tests for yearly frequencies' => sub {
    plan tests => 10;

    # First add a few frequencies
    my $freq_1i_1y = AddSubscriptionFrequency({
        description => "1 issue per year",
        unit => 'year',
        issuesperunit => 1,
        unitsperissue => 1,
    });
    my $freq_1i_3y = AddSubscriptionFrequency({
        description => "1 issue per 3 years",
        unit => 'year',
        issuesperunit => 1,
        unitsperissue => 3,
    });
    my $freq_5i_1y = AddSubscriptionFrequency({
        description => "5 issues per year",
        unit => 'year',
        issuesperunit => 5,
        unitsperissue => 1,
    });
    my $freq_366i_1y = AddSubscriptionFrequency({
        description => "366 issue per year",
        unit => 'year',
        issuesperunit => 366,
        unitsperissue => 1,
    });

    # TEST CASE - 1 issue per year
    my $subscription = {
        periodicity => $freq_1i_1y,
        firstacquidate => '1972-02-10',
        countissuesperunit => 1,
    };
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-09'), 1, 'Feb 9 still 1' );
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-10'), 2, 'Feb 10 goes to 2' );

    # TEST CASE - 1 issue per 3 years
    $subscription->{periodicity} = $freq_1i_3y;
    $subscription->{firstacquidate} = '1972-02-20';
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1975-02-19'), 1, 'Feb 19, 1975 still 1' );
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1975-02-20'), 2, 'Feb 20, 1975 goes to 2' );

    # TEST CASE - 5 issues per year
    $subscription->{periodicity} = $freq_5i_1y;
    $subscription->{firstacquidate} = '1972-02-29'; #leap year
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1972-05-11'), 1, 'May 11 still 1' );
    $subscription->{countissuesperunit} = 2;
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1972-05-12'), 2, 'May 12 goes to 2' );
    $subscription->{countissuesperunit} = 5;
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-27'), 5, 'Feb 27 should still be 5' );
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-28'), 6, 'Feb 28 goes to 6' );

    # TEST CASE - 366 issues per year (hypothetical example)
    # Testing prevention of divide by zero
    $subscription->{periodicity} = $freq_366i_1y;
    $subscription->{firstacquidate} = '1972-02-29'; #leap year
    $subscription->{countissuesperunit} = 366;
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-27'), 366, 'Feb 27 still at 366' );
    is( C4::Serials::GetFictiveIssueNumber($subscription, '1973-02-28'), 732, 'Feb 28 goes to 732' );

};

# TODO: subtest 'Tests for monthly frequencies' => sub {
# TODO: subtest 'Tests for weekly frequencies' => sub {
# TODO: subtest 'Tests for dayly frequencies' => sub {

$schema->storage->txn_rollback;
