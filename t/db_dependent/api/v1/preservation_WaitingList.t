#!/usr/bin/env perl

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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Preservation::Trains;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'add_item, list, remove_item tests' => sub {

    plan tests => 34;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item;
    my $item_3 = $builder->build_sample_item;

    t::lib::Mocks::mock_preference( 'PreservationNotForLoanWaitingListIn', undef );
    $t->get_ok("//$userid:$password@/api/v1/preservation/waiting-list/items")->status_is(400)->json_is(
        {
            error     => 'MissingSettings',
            parameter => 'PreservationNotForLoanWaitingListIn'
        }
    );

    my $not_for_loan_waiting_list_in = 24;
    t::lib::Mocks::mock_preference(
        'PreservationNotForLoanWaitingListIn',
        $not_for_loan_waiting_list_in
    );

    $t->get_ok("//$userid:$password@/api/v1/preservation/waiting-list/items")->status_is(200)->json_is( [] );

    # Add items
    $t->post_ok(
        "//$userid:$password@/api/v1/preservation/waiting-list/items" => json => [
            { item_id => $item_1->itemnumber },
            { barcode => $item_3->barcode }
        ]
    )->status_is(201)->json_is(
        [
            { item_id => $item_1->itemnumber },
            { item_id => $item_3->itemnumber }
        ]
    );

    is( $item_1->get_from_storage->notforloan, $not_for_loan_waiting_list_in );
    is( $item_2->get_from_storage->notforloan, 0 );
    is( $item_3->get_from_storage->notforloan, $not_for_loan_waiting_list_in );

    $t->post_ok(
        "//$userid:$password@/api/v1/preservation/waiting-list/items" => json => [
            { item_id => $item_2->itemnumber },
            { barcode => $item_3->barcode }
        ]
    )->status_is(201)->json_is( [ { item_id => $item_2->itemnumber } ] );

    is( $item_1->get_from_storage->notforloan, $not_for_loan_waiting_list_in );
    is( $item_2->get_from_storage->notforloan, $not_for_loan_waiting_list_in );
    is( $item_3->get_from_storage->notforloan, $not_for_loan_waiting_list_in );

    $t->delete_ok( "//$userid:$password@/api/v1/preservation/waiting-list/items/" . $item_2->itemnumber )
        ->status_is(204);

    is(
        $item_2->get_from_storage->notforloan, 0,
        "Item removed from the waiting list has its notforloan status back to 0"
    );

    # Add item_1 to a non-received train
    my $train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan => 42,
                closed_on    => undef,
                sent_on      => undef,
                received_on  => undef
            }
        }
    );
    $train->add_item( { item_id => $item_1->itemnumber } );

    # And try to add it to the waiting list
    warning_like {
        $t->post_ok( "//$userid:$password@/api/v1/preservation/waiting-list/items" => json =>
                [ { item_id => $item_1->itemnumber } ] )->status_is(201)->json_is( [] );
    }
    qr[Cannot add item to waiting list, it is already in a non-received train];

    # Add item_3 to a train, receive the train and add the item to the waiting list
    $train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan => 42,
                closed_on    => undef,
                sent_on      => undef,
                received_on  => undef
            }
        }
    );
    $train->add_item( { item_id => $item_3->itemnumber } );
    $train->received_on(dt_from_string)->store;

    $t->post_ok(
        "//$userid:$password@/api/v1/preservation/waiting-list/items" => json => [ { item_id => $item_3->itemnumber } ]
    )->status_is(201)->json_is( [ { item_id => $item_3->itemnumber } ] );

    $t->delete_ok( "//$userid:$password@/api/v1/preservation/waiting-list/items/" . $item_2->itemnumber )
        ->status_is(204);

    $item_2->delete;
    $t->delete_ok("//$userid:$password@/api/v1/preservation/waiting-list/items")->status_is(404);

    $t->delete_ok( "//$userid:$password@/api/v1/preservation/waiting-list/items/" . $item_2->itemnumber )
        ->status_is(404);

    $schema->storage->txn_rollback;
};
