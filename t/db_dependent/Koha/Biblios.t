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

use C4::Reserves;

use Koha::DateUtils qw( dt_from_string );
use Koha::Biblios;
use Koha::Patrons;
use Koha::Subscriptions;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron = $builder->build( { source => 'Borrower' } );
$patron = Koha::Patrons->find( $patron->{borrowernumber} );

my $biblio = Koha::Biblio->new()->store();

my $biblioitem = $schema->resultset('Biblioitem')->new(
    {
        biblionumber => $biblio->id
    }
)->insert();

subtest 'holds + current_holds' => sub {
    plan tests => 5;
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber );
    my $holds = $biblio->holds;
    is( ref($holds), 'Koha::Holds', '->holds should return a Koha::Holds object' );
    is( $holds->count, 1, '->holds should only return 1 hold' );
    is( $holds->next->borrowernumber, $patron->borrowernumber, '->holds should return the correct hold' );
    $holds->delete;

    # Add a hold in the future
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber, undef, undef, dt_from_string->add( days => 2 ) );
    $holds = $biblio->holds;
    is( $holds->count, 1, '->holds should return future holds' );
    $holds = $biblio->current_holds;
    is( $holds->count, 0, '->current_holds should not return future holds' );
    $holds->delete;

};

subtest 'subscriptions' => sub {
    plan tests => 2;
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    my $biblio        = Koha::Biblios->find( $biblio->id );
    my $subscriptions = $biblio->subscriptions;
    is( ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 2, 'Koha::Biblio->subscriptions should return the correct number of subscriptions');
};

subtest 'waiting_or_in_transit' => sub {
    plan tests => 4;
    my $biblio = $builder->build( { source => 'Biblio' } );
    my $item = $builder->build({
        source => 'Item',
        value => {
            biblionumber => $biblio->{biblionumber}
        }
    });
    my $reserve = $builder->build({
        source => 'Reserve',
        value => {
            biblionumber => $biblio->{biblionumber},
            found => undef
        }
    });

    $reserve = Koha::Holds->find($reserve->{reserve_id});
    $biblio = Koha::Biblios->find($biblio->{biblionumber});

    is($biblio->has_items_waiting_or_intransit, 0, 'Item is neither waiting nor in transit');

    $reserve->found('W')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is waiting');

    $reserve->found('T')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is in transit');

    my $transfer = $builder->build({
        source => 'Branchtransfer',
        value => {
            itemnumber => $item->{itemnumber},
            datearrived => undef
        }
    });
    my $t = Koha::Database->new()->schema()->resultset( 'Branchtransfer' )->find($transfer->{branchtransfer_id});
    $reserve->found(undef)->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item has transfer');
};

$schema->storage->txn_rollback;

