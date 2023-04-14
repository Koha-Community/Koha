#!/usr/bin/perl

# This script includes tests for ReNewSubscription

# Copyright 2015 BibLibre, Paul Poulain
# Copyright 2018 Catalyst IT, Alex Buckley
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 10;
use Test::MockModule;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Serials qw( NewSubscription ReNewSubscription GetSubscription GetSubscriptionLength );

use Koha::Database;
use Koha::Subscription::Histories;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

# create fake numberpattern & fake periodicity
my $frequency = $builder->build({
    source => 'SubscriptionFrequency',
    value => {
        description   => "daily",
        unit          => "day",
        unitsperissue => 1,
    },
});

my $pattern = $builder->build({
    source => 'SubscriptionNumberpattern',
    value => {
        label           => 'mock',
        description     =>'mock',
        numberingmethod => 'Issue {X}',
        add1            => 1,
        every1          => 1,
        setto1          => 100,
    }
});

my $biblio = $builder->build_sample_biblio();

# Create fake subscription, daily subscription, duration 12 months, issues startint at #100
my $subscription = $builder->build({
    source => 'Subscription',
    value  => {
        biblionumber    => $biblio->biblionumber,
        startdate       => '2015-01-01',
        enddate         => '2015-12-31',
        aqbooksellerid  => 1,
        periodicity     => $frequency->{id},
        numberpattern   => $pattern->{id},
        monthlength     => 12,
    },
});

my $subscriptionhistory = $builder->build({
    source => 'Subscriptionhistory',
    value  => {
        biblionumber   => $biblio->biblionumber,
        subscriptionid => $subscription->{subscriptionid},
        histenddate    => undef,
        opacnote       => 'Testing',
    }
});

t::lib::Mocks::mock_preference( 'RenewSerialAddsSuggestion', '0' );
my $suggestions_count = Koha::Suggestions->search()->count;

# Actual testing starts here!
# Renew the subscription and check that enddate has been set
ReNewSubscription(
    {
        subscriptionid => $subscription->{subscriptionid},
        startdate      => "2016-01-01",
        monthlength    => 12
    }
);

$subscription = Koha::Subscriptions->find( $subscription->{subscriptionid} );
is( $subscription->enddate, '2017-01-01', "We don't update the subscription end date when renewing with a month length");

is( $suggestions_count, Koha::Suggestions->search()->count, "Suggestion not added when RenewSerialAddsSuggestion set to Don't add");

t::lib::Mocks::mock_preference( 'RenewSerialAddsSuggestion', '1' );

ReNewSubscription(
    {
        subscriptionid => $subscription->{subscriptionid},
        startdate      => "2016-01-01",
        monthlength    => 12
    }
);

is( $suggestions_count + 1, Koha::Suggestions->search()->count, "Suggestion added when RenewSerialAddsSuggestion set to add");

my $history = Koha::Subscription::Histories->find($subscription->subscriptionid);

is ( $history->histenddate(), undef, 'subscription history not empty after renewal');
# Calculate the subscription length for the renewal for issues, days and months

my ($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('issues', 7);
is ( $numberlength, 7, "Subscription length is 7 issues");

($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('weeks', 7);
is ( $weeklength, 7, "Subscription length is 7 weeks");

($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('months', 7);
is ( $monthlength, 7, "Subscription length is 7 months");

# Check subscription length when no value is inputted into the numeric sublength field
($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('months', '');
is ($monthlength, undef, "Subscription length is undef months, invalid month data was not stored");

# Check subscription length when a letter is inputted into the numeric sublength field
($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('issues', 'w');
is ($monthlength, undef, "Subscription length is undef issues, invalid issue data was not stored");

# Check subscription length when a special character is inputted into numberic sublength field
($numberlength, $weeklength, $monthlength) = GetSubscriptionLength('weeks', '!');
is ($weeklength, undef, "Subscription length is undef weeks, invalid weeks data was not stored");

# End of tests

$schema->storage->txn_rollback;

