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

use Test::NoWarnings;
use Test::More tests => 11;

use Koha::Database;
use Koha::Subscription;
use Koha::Subscriptions;
use Koha::Biblio;
use Koha::Biblios;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

use_ok('Koha::Subscription');

subtest 'Koha::Subscription->biblio' => sub {
    plan tests => 1;

    my $biblio       = Koha::Biblio->new()->store();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    )->store();

    my $b = $subscription->biblio;
    is( $b->biblionumber, $biblio->biblionumber, 'Koha::Subscription->biblio returns the correct biblio' );
};

subtest 'Notifications on new issues - add_subscriber|remove_subscriber|subscribers' => sub {
    plan tests => 5;
    my $subscriber_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $subscriber_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $subscription = Koha::Subscription->new(
        {
            biblionumber => Koha::Biblio->new->store->biblionumber,
        }
    )->store();

    my $subscribers = $subscription->subscribers;
    is( $subscribers->count, 0,               '->subscribers should return 0 if there are no subscribers' );
    is( ref($subscribers),   'Koha::Patrons', '->subscribers should return a Koha::Patrons object' );

    $subscription->add_subscriber($subscriber_1);
    $subscription->add_subscriber($subscriber_2);

    $subscribers = $subscription->subscribers;
    is( $subscribers->count, 2, '->subscribers should return 2 if there are 2 subscribers' );

    $subscription->remove_subscriber($subscriber_1);

    $subscribers = $subscription->subscribers;
    is( $subscribers->count, 1, '->remove_subscriber should have remove the subscriber' );

    $subscription->remove_subscriber($subscriber_1);    # We do not explode if the patron is not a subscriber

    my $is_subscriber = $subscribers->find( $subscriber_2->borrowernumber );
    ok( $is_subscriber, 'This structure is used in the code and should work as expected' );

};

subtest 'Koha::Subscription->vendor' => sub {
    plan tests => 3;
    my $vendor       = $builder->build_object( { class => 'Koha::Acquisition::Booksellers' } );
    my $subscription = $builder->build_object(
        {
            class => 'Koha::Subscriptions',
            value => { aqbooksellerid => $vendor->id }
        }
    );
    is(
        ref( $subscription->vendor ), 'Koha::Acquisition::Bookseller',
        'Koha::Subscription->vendor should return a Koha::Acquisition::Bookseller'
    );
    is(
        $subscription->vendor->id, $subscription->aqbooksellerid,
        'Koha::Subscription->vendor should return the correct vendor'
    );

    $vendor->delete();
    $subscription->discard_changes;
    is( $subscription->vendor, undef, 'Koha::Subscription->vendor should return undef if the vendor is deleted' );
};

subtest 'Koha::Subscription->frequency' => sub {
    plan tests => 2;
    my $frequency    = $builder->build_object( { class => 'Koha::Subscription::Frequencies' } );
    my $subscription = $builder->build_object(
        {
            class => 'Koha::Subscriptions',
            value => { periodicity => $frequency->id }
        }
    );
    is(
        ref( $subscription->frequency ), 'Koha::Subscription::Frequency',
        'Koha::Subscription->frequency should return a Koha::Subscription::Frequency'
    );
    is(
        $subscription->frequency->id, $frequency->id,
        'Koha::Subscription->frequency should return the correct frequency'
    );
};

my $nb_of_subs = Koha::Subscriptions->search->count;
my $biblio_1   = $builder->build_sample_biblio;
my $bi_1       = $biblio_1->biblioitem;
my $sub_freq_1 = $builder->build( { source => 'SubscriptionFrequency' } );
my $sub_np_1   = $builder->build( { source => 'SubscriptionNumberpattern' } );
my $sub_1      = $builder->build(
    {
        source => 'Subscription',
        value  => {
            biblionumber  => $biblio_1->biblionumber,
            periodicity   => $sub_freq_1->{id},
            numberpattern => $sub_np_1->{id}
        }
    }
);

is(
    Koha::Subscriptions->search->count,
    $nb_of_subs + 1,
    'The subscription should have been added'
);
is(
    $sub_1->{biblionumber},
    $biblio_1->biblionumber,
    'The link between sub and biblio is well done'
);
is(
    $sub_1->{periodicity}, $sub_freq_1->{id},
    'The link between sub and sub_freq is well done'
);
is(
    $sub_1->{numberpattern},
    $sub_np_1->{id},
    'The link between sub and sub_numberpattern is well done'
);

my $ref = {
    'title'           => $biblio_1->title,
    'sfdescription'   => $sub_freq_1->{description},
    'unit'            => $sub_freq_1->{unit},
    'unitsperissue'   => $sub_freq_1->{unitsperissue},
    'issuesperunit'   => $sub_freq_1->{issuesperunit},
    'label'           => $sub_np_1->{label},
    'sndescription'   => $sub_np_1->{description},
    'numberingmethod' => $sub_np_1->{numberingmethod},
    'label'           => $sub_np_1->{label},
    'label1'          => $sub_np_1->{label1},
    'add1'            => $sub_np_1->{add1},
    'every1'          => $sub_np_1->{every1},
    'whenmorethan1'   => $sub_np_1->{whenmorethan1},
    'setto1'          => $sub_np_1->{setto1},
    'numbering1'      => $sub_np_1->{numbering1},
    'label2'          => $sub_np_1->{label2},
    'add2'            => $sub_np_1->{add2},
    'every2'          => $sub_np_1->{every2},
    'whenmorethan2'   => $sub_np_1->{whenmorethan2},
    'setto2'          => $sub_np_1->{setto2},
    'numbering2'      => $sub_np_1->{numbering2},
    'label3'          => $sub_np_1->{label3},
    'add3'            => $sub_np_1->{add3},
    'every3'          => $sub_np_1->{every3},
    'whenmorethan3'   => $sub_np_1->{whenmorethan3},
    'setto3'          => $sub_np_1->{setto3},
    'numbering3'      => $sub_np_1->{numbering3},
    'issn'            => $bi_1->issn,
    'ean'             => $bi_1->ean,
    'publishercode'   => $bi_1->publishercode,
};

is_deeply(
    Koha::Subscription->get_sharable_info( $sub_1->{subscriptionid} ),
    $ref, "get_sharable_info function is ok"
);

$schema->storage->txn_rollback;

1;
