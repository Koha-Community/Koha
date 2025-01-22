#!/usr/bin/perl

# This test deals with GetFictiveIssueNumber (from C4::Serials)

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 6;

use Koha::Database;
use C4::Serials qw( GetFictiveIssueNumber GetSubscription );
use C4::Serials::Frequency;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

subtest 'Tests for irregular frequency' => sub {
    plan tests => 2;

    # Add a frequency
    my $freq_irr = AddSubscriptionFrequency(
        {
            description => "Irregular",
            unit        => undef,
        }
    );

    # Test it
    my $subscription = {
        periodicity    => $freq_irr,
        firstacquidate => '1972-02-07',
    };
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-12-31' ), undef, 'Irregular: should be undef' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-12-31' ), undef, 'Irregular: still undef' );
};

subtest 'Tests for yearly frequencies' => sub {
    plan tests => 10;

    # First add a few frequencies
    my $freq_1i_1y = AddSubscriptionFrequency(
        {
            description   => "1 issue per year",
            unit          => 'year',
            issuesperunit => 1,
            unitsperissue => 1,
        }
    );
    my $freq_1i_3y = AddSubscriptionFrequency(
        {
            description   => "1 issue per 3 years",
            unit          => 'year',
            issuesperunit => 1,
            unitsperissue => 3,
        }
    );
    my $freq_5i_1y = AddSubscriptionFrequency(
        {
            description   => "5 issues per year",
            unit          => 'year',
            issuesperunit => 5,
            unitsperissue => 1,
        }
    );
    my $freq_366i_1y = AddSubscriptionFrequency(
        {
            description   => "366 issue per year",
            unit          => 'year',
            issuesperunit => 366,
            unitsperissue => 1,
        }
    );

    # TEST CASE - 1 issue per year
    my $subscription = {
        periodicity        => $freq_1i_1y,
        firstacquidate     => '1972-02-10',
        countissuesperunit => 1,
    };

    my $frequency = GetSubscriptionFrequency($freq_1i_1y);

    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-09', $frequency ), 1, 'Feb 9 still 1' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-10', $frequency ), 2, 'Feb 10 goes to 2' );

    # TEST CASE - 1 issue per 3 years
    $subscription->{periodicity}    = $freq_1i_3y;
    $subscription->{firstacquidate} = '1972-02-20';
    $frequency                      = GetSubscriptionFrequency($freq_1i_3y);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1975-02-19', $frequency ), 1, 'Feb 19, 1975 still 1' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1975-02-20', $frequency ), 2, 'Feb 20, 1975 goes to 2' );

    # TEST CASE - 5 issues per year
    $subscription->{periodicity}        = $freq_5i_1y;
    $subscription->{firstacquidate}     = '1972-02-29';                            #leap year
    $subscription->{countissuesperunit} = 1;
    $frequency                          = GetSubscriptionFrequency($freq_5i_1y);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-05-11', $frequency ), 1, 'May 11 still 1' );
    $subscription->{countissuesperunit} = 2;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-05-12', $frequency ), 2, 'May 12 goes to 2' );
    $subscription->{countissuesperunit} = 5;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-27', $frequency ), 5, 'Feb 27 should still be 5' );
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-28', $frequency ), 6, 'Feb 28 goes to 6' );

    # TEST CASE - 366 issues per year (hypothetical example)
    # Testing prevention of divide by zero
    $subscription->{periodicity}        = $freq_366i_1y;
    $subscription->{firstacquidate}     = '1972-02-29';                              #leap year
    $subscription->{countissuesperunit} = 366;
    $frequency                          = GetSubscriptionFrequency($freq_366i_1y);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-27', $frequency ), 366, 'Feb 27 still at 366' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-02-28', $frequency ), 732, 'Feb 28 goes to 732' );

};

subtest 'Tests for monthly frequencies' => sub {
    plan tests => 8;

    # First add a few frequencies
    my $freq_1i_5m = AddSubscriptionFrequency(
        {
            description   => "1 issue per 5 months",
            unit          => 'month',
            issuesperunit => 1,
            unitsperissue => 5,
        }
    );
    my $freq_4i_1m = AddSubscriptionFrequency(
        {
            description   => "4 issue per month",
            unit          => 'month',
            issuesperunit => 4,
            unitsperissue => 1,
        }
    );

    # TEST CASE - 1 issue per 5 months
    my $subscription = {
        periodicity        => $freq_1i_5m,
        firstacquidate     => '1972-02-10',
        countissuesperunit => 1,
    };
    my $frequency = GetSubscriptionFrequency($freq_1i_5m);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-07-09', $frequency ), 1, 'Jul 9 still 1' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-07-10', $frequency ), 2, 'Jul 10 goes to 2' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-05-09', $frequency ), 3, 'May 9 still 3' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1973-05-10', $frequency ), 4, 'May 10 goes to 4' );

    # TEST CASE - 4 issue per 1 months
    $subscription = {
        periodicity        => $freq_4i_1m,
        firstacquidate     => '1972-02-22',
        countissuesperunit => 1,
    };
    $frequency = GetSubscriptionFrequency($freq_4i_1m);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-02-28', $frequency ), 1, 'Feb 28 still 1' );
    $subscription->{countissuesperunit} = 2;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-02-29', $frequency ), 2, 'Feb 29 goes to 2' );
    $subscription->{countissuesperunit} = 4;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-21', $frequency ), 4, 'Mar 21 still 4' );
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-22', $frequency ), 5, 'Mar 22 goes to 5' );

};

subtest 'Tests for weekly frequencies' => sub {
    plan tests => 4;

    # First add a few frequencies
    my $freq_1i_7w = AddSubscriptionFrequency(
        {
            description   => "1 issue per 7 weeks",
            unit          => 'week',
            issuesperunit => 1,
            unitsperissue => 7,
        }
    );
    my $freq_3i_1w = AddSubscriptionFrequency(
        {
            description   => "3 issues per week",
            unit          => 'week',
            issuesperunit => 3,
            unitsperissue => 1,
        }
    );

    # TEST CASE - 1 issue per 7 weeks
    my $subscription = {
        periodicity        => $freq_1i_7w,
        firstacquidate     => '1972-02-10',
        countissuesperunit => 1,
    };
    my $frequency = GetSubscriptionFrequency($freq_1i_7w);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-29', $frequency ), 1, 'Mar 29 still 1' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-30', $frequency ), 2, 'Mar 30 goes to 2' );

    # TEST CASE - 3 issue per 1 week
    $subscription = {
        periodicity        => $freq_3i_1w,
        firstacquidate     => '1972-02-03',
        countissuesperunit => 1,
    };
    $subscription->{countissuesperunit} = 3;
    $frequency = GetSubscriptionFrequency($freq_3i_1w);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-02-09', $frequency ), 3, 'Feb 9 still 3' );
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-02-10', $frequency ), 4, 'Feb 10 goes to 4' );
};

subtest 'Tests for dayly frequencies' => sub {
    plan tests => 4;

    # First add a few frequencies
    my $freq_1i_12d = AddSubscriptionFrequency(
        {
            description   => "1 issue per 12 days",
            unit          => 'day',
            issuesperunit => 1,
            unitsperissue => 12,
        }
    );
    my $freq_3i_1d = AddSubscriptionFrequency(
        {
            description   => "3 issues per day",
            unit          => 'day',
            issuesperunit => 3,
            unitsperissue => 1,
        }
    );

    # TEST CASE - 1 issue per 12 days
    my $subscription = {
        periodicity        => $freq_1i_12d,
        firstacquidate     => '1972-03-16',
        countissuesperunit => 1,
    };
    my $frequency = GetSubscriptionFrequency($freq_1i_12d);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-27', $frequency ), 1, 'Mar 27 still 1' );
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-03-28', $frequency ), 2, 'Mar 28 goes to 2' );

    # TEST CASE - 3 issue per day
    $subscription = {
        periodicity        => $freq_3i_1d,
        firstacquidate     => '1972-04-23',
        countissuesperunit => 1,
    };
    $subscription->{countissuesperunit} = 3;
    $frequency = GetSubscriptionFrequency($freq_3i_1d);
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-05-01', $frequency ), 27, 'May 1 still 27' );
    $subscription->{countissuesperunit} = 1;
    is( C4::Serials::GetFictiveIssueNumber( $subscription, '1972-05-02', $frequency ), 28, 'May 2 goes to 28' );
};

$schema->storage->txn_rollback;
