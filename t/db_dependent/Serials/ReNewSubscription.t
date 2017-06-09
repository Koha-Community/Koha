#!/usr/bin/perl

# This script includes tests for ReNewSubscription

# Copyright 2015 BibLibre, Paul Poulain
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

use Test::More tests => 1;
use Test::MockModule;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Serials;

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

# Create fake subscription, daily subscription, duration 12 months, issues startint at #100
my $subscription = $builder->build({
    source => 'Subscription',
    value  => {
        biblionumber    => 1,
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
        subscriptionid => $subscription->{subscriptionid},
        histenddate    => undef,
        opacnote       => 'Testing',
    }
});

# Actual testing starts here!

# Renew the subscription and check that enddate has not been set
ReNewSubscription($subscription->{subscriptionid},'',"2016-01-01",'','',12,'');
my $history = Koha::Subscription::Histories->find($subscription->{subscriptionid});

is ( $history->histenddate(), undef, 'subscription history not empty after renewal');

# End of tests

$schema->storage->txn_rollback;

