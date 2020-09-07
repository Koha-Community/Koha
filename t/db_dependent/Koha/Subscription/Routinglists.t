#!/usr/bin/perl

# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WIT HOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 1;
use t::lib::TestBuilder;

use C4::Biblio;

use Koha::Database;
use Koha::Patrons;
use Koha::Subscriptions;
use Koha::Subscription::Routinglists;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'new() tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = Koha::Biblio->new()->store();
    my $subscription = Koha::Subscription->new({
        biblionumber => $biblio->biblionumber,
        }
    )->store;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $library->id } });

    my $routinglist_count = Koha::Subscription::Routinglists->count;
    my $routinglist = Koha::Subscription::Routinglist->new({
        borrowernumber   => $patron->borrowernumber,
        ranking          => 1,
        subscriptionid   => $subscription->subscriptionid
    })->store;

    is( Koha::Subscription::Routinglists->search->count, $routinglist_count +1, 'One routing list added' );

    my $retrieved_routinglist = Koha::Subscription::Routinglists->find( $routinglist->routingid );
    is ( $retrieved_routinglist->routingid, $routinglist->routingid, "Find a routing list by id returns the correct routing list");

    $routinglist->ranking(4)->update;
    is ( $routinglist->ranking, 4, "Routing list ranking has been updated");

    $routinglist->delete;
    is ( Koha::Subscription::Routinglists->search->count, $routinglist_count, 'One subscription list deleted' );

};

$schema->storage->txn_rollback;
