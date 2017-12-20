#!/usr/bin/perl

# Copyright 2016 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 3;

use Koha::Subscriptions;
use Koha::Biblio;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Subscription->biblio' => sub {
    plan tests => 1;

    my $biblio = Koha::Biblio->new()->store();
    my $subscription = Koha::Subscription->new({
        biblionumber => $biblio->biblionumber,
    })->store();

    my $b = $subscription->biblio;
    is($b->biblionumber, $biblio->biblionumber, 'Koha::Subscription->biblio returns the correct biblio');
};

subtest 'Notifications on new issues - add_subscriber|remove_subscriber|subscribers' => sub {
    plan tests => 5;
    my $subscriber_1 = $builder->build_object( { class => 'Koha::Patrons' });
    my $subscriber_2 = $builder->build_object( { class => 'Koha::Patrons' });

    my $subscription = Koha::Subscription->new({
        biblionumber => Koha::Biblio->new->store->biblionumber,
    })->store();

    my $subscribers = $subscription->subscribers;
    is( $subscribers->count, 0, '->subscribers should return 0 if there are no subscribers');
    is( ref($subscribers), 'Koha::Patrons', '->subscribers should return a Koha::Patrons object');

    $subscription->add_subscriber( $subscriber_1 );
    $subscription->add_subscriber( $subscriber_2 );

    $subscribers = $subscription->subscribers;
    is( $subscribers->count, 2, '->subscribers should return 2 if there are 2 subscribers' );

    $subscription->remove_subscriber( $subscriber_1 );

    $subscribers = $subscription->subscribers;
    is( $subscribers->count, 1, '->remove_subscriber should have remove the subscriber' );

    $subscription->remove_subscriber( $subscriber_1 ); # We do not explode if the patron is not a subscriber

    my $is_subscriber = $subscribers->find( $subscriber_2->borrowernumber );
    ok( $is_subscriber, 'This structure is used in the code and should work as expected' );

};

subtest 'Koha::Subscription->vendor' => sub {
    plan tests => 2;
    my $vendor = $builder->build( { source => 'Aqbookseller' } );
    my $subscription = $builder->build(
        {
            source => 'Subscription',
            value  => { aqbooksellerid => $vendor->{id} }
        }
    );
    my $object = Koha::Subscriptions->find( $subscription->{subscriptionid} );
    is( ref($object->vendor), 'Koha::Acquisition::Bookseller', 'Koha::Subscription->vendor should return a Koha::Acquisition::Bookseller' );
    is( $object->vendor->id, $subscription->{aqbooksellerid}, 'Koha::Subscription->vendor should return the correct vendor' );
};

$schema->storage->txn_rollback;

1;
