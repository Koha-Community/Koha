#!/usr/bin/perl

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
use Test::More tests => 3;
use Test::Exception;
use Test::Warn;

use Koha::Preservation::Trains;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'default_processing' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $processing         = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $another_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    my $train = $builder->build_object(
        { class => 'Koha::Preservation::Trains', value => { default_processing_id => $processing->processing_id } } );

    my $default_processing = $train->default_processing;
    is(
        ref($default_processing), 'Koha::Preservation::Processing',
        '->default_processing returns a Koha::Preservation::Processing object'
    );
    is( $default_processing->processing_id, $processing->processing_id, 'correct processing is returned' );
    $processing->delete;
    $default_processing = $train->get_from_storage->default_processing;
    is( $default_processing, undef, 'deleting the processing does not delete the train' );

    $schema->storage->txn_rollback;
};

subtest 'add_items & items' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my $not_for_loan_waiting_list_in = 24;
    my $not_for_loan_train_in        = 42;
    my $train                        = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan => $not_for_loan_train_in,
                closed_on    => undef,
                sent_on      => undef,
                received_on  => undef
            }
        }
    );
    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item;
    my $item_3 = $builder->build_sample_item;

    $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => 'NOT_LOAN', authorised_value => $not_for_loan_waiting_list_in }
        }
    );
    $item_1->notforloan($not_for_loan_waiting_list_in)->store;
    $item_2->notforloan(0)->store;    # item_2 is not in the waiting list
    $item_3->notforloan($not_for_loan_waiting_list_in)->store;
    t::lib::Mocks::mock_preference( 'PreservationNotForLoanWaitingListIn', $not_for_loan_waiting_list_in );
    warning_is {
        $train->add_items(
            [ { item_id => $item_1->itemnumber }, { item_id => $item_2->itemnumber }, { barcode => $item_3->barcode } ]
        );
    }
    'Item not added to train: [Cannot add item to train, it is not in the waiting list]';
    my $items_train = $train->items;
    is( $items_train->count, 2, '2 items added to the train' );
    my $item_train_1     = $items_train->find( { item_id => $item_1->itemnumber } );
    my $item_train_3     = $items_train->find( { item_id => $item_3->itemnumber } );
    my $catalogue_item_1 = $item_train_1->catalogue_item;
    is( ref($catalogue_item_1),        'Koha::Item' );
    is( $catalogue_item_1->notforloan, $not_for_loan_train_in );

    my $catalogue_item_3 = $item_train_3->catalogue_item;
    is( ref($catalogue_item_3),        'Koha::Item' );
    is( $catalogue_item_3->notforloan, $not_for_loan_train_in );

    is( $item_1->get_from_storage->notforloan, $not_for_loan_train_in );
    is( $item_2->get_from_storage->notforloan, 0 );
    is( $item_3->get_from_storage->notforloan, $not_for_loan_train_in );

    is(
        ref( $item_train_1->train ),
        'Koha::Preservation::Train',
        'Train::Item->train returns a Koha::Preservation::Train object'
    );

    warning_is {
        $train->add_item( { item_id => $item_2->itemnumber }, { skip_waiting_list_check => 1 } );
    }
    '';
    is( $train->items->count, 3, 'the item has been added to the train' );
    is( $item_2->get_from_storage->notforloan, $not_for_loan_train_in );

    my $another_train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan => $not_for_loan_train_in,
                closed_on    => undef,
                sent_on      => undef,
                received_on  => undef
            }
        }
    );

    $train->closed_on(dt_from_string)->store;

    throws_ok {
        $another_train->add_item( { item_id => $item_1->itemnumber }, { skip_waiting_list_check => 1 } );
    }
    'Koha::Exceptions::Preservation::ItemAlreadyInAnotherTrain';

    my $item_4 = $builder->build_sample_item;
    throws_ok {
        $train->add_item( { item_id => $item_4->itemnumber } );
    }
    'Koha::Exceptions::Preservation::CannotAddItemToClosedTrain';

    $schema->storage->txn_rollback;
};
