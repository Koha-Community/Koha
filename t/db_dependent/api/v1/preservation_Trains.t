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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Preservation::Trains;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    Koha::Preservation::Trains->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    ## Authorized user tests
    # No trains, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/preservation/trains")->status_is(200)->json_is( [] );

    my $train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
        }
    );

    # One train created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/preservation/trains")->status_is(200)->json_is( [ $train->to_api ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/preservation/trains")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $train              = $builder->build_object( { class => 'Koha::Preservation::Trains' } );
    my $default_processing = $train->default_processing;
    my $librarian          = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # This train exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/preservation/trains/" . $train->train_id )
        ->status_is(200)
        ->json_is( $train->to_api );

    # Return one train with some embeds
    $t->get_ok( "//$userid:$password@/api/v1/preservation/trains/"
            . $train->train_id => { 'x-koha-embed' => 'items,default_processing' } )
        ->status_is(200)
        ->json_is( { %{ $train->to_api }, items => [], default_processing => $default_processing->unblessed } );

    # Return one train with all embeds
    $t->get_ok(
        "//$userid:$password@/api/v1/preservation/trains/"
            . $train->train_id => {
            'x-koha-embed' =>
                'items,items.attributes,items.attributes.processing_attribute,default_processing,default_processing.attributes'
            }
    )->status_is(200)->json_is(
        {
            %{ $train->to_api }, items => [],
            default_processing => { %{ $default_processing->unblessed }, attributes => [] }
        }
    );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/preservation/trains/" . $train->train_id )->status_is(403);

    # Attempt to get non-existent train
    my $train_to_delete = $builder->build_object( { class => 'Koha::Preservation::Trains' } );
    my $non_existent_id = $train_to_delete->train_id;
    $train_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/preservation/trains/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Train not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 18;

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

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $default_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $train              = {
        name                  => "train name",
        description           => "train description",
        default_processing_id => $default_processing->processing_id,
        not_for_loan          => 42,
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/preservation/trains" => json => $train )->status_is(403);

    # Authorized attempt to write invalid data
    my $train_with_invalid_field = {
        blah => "train Blah",
        %$train,
    };

    $t->post_ok( "//$userid:$password@/api/v1/preservation/trains" => json => $train_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $train_id =
        $t->post_ok( "//$userid:$password@/api/v1/preservation/trains" => json => $train )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^/api/v1/preservation/trains/\d*|,
        'REST3.4.1'
        )
        ->json_is( '/name'                  => $train->{name} )
        ->json_is( '/description'           => $train->{description} )
        ->json_is( '/default_processing_id' => $train->{default_processing_id} )
        ->json_is( '/not_for_loan'          => $train->{not_for_loan} )
        ->tx->res->json->{train_id};

    # Authorized attempt to create with null id
    $train->{train_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/preservation/trains" => json => $train )
        ->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $train->{train_id} = $train_id;
    $t->post_ok( "//$userid:$password@/api/v1/preservation/trains" => json => $train )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/train_id"
            }
        ]
    );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

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

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $train_id = $builder->build_object( { class => 'Koha::Preservation::Trains' } )->train_id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/preservation/trains/$train_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $train_with_missing_field = {};

    $t->put_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id" => json => $train_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    my $default_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    # Full object update on PUT
    my $train_with_updated_field = {
        name                  => "New name",
        description           => "train description",
        default_processing_id => $default_processing->processing_id,
        not_for_loan          => 42,
    };

    $t->put_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id" => json => $train_with_updated_field )
        ->status_is(200)
        ->json_is( '/name' => 'New name' );

    # Authorized attempt to write invalid data
    my $train_with_invalid_field = {
        blah => "train Blah",
        %$train_with_updated_field,
    };

    $t->put_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id" => json => $train_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Attempt to update non-existent train
    my $train_to_delete = $builder->build_object( { class => 'Koha::Preservation::Trains' } );
    my $non_existent_id = $train_to_delete->train_id;
    $train_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/preservation/trains/$non_existent_id" => json => $train_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $train_with_updated_field->{train_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id" => json => $train_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

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

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $train_id = $builder->build_object( { class => 'Koha::Preservation::Trains' } )->train_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/preservation/trains/$train_id")->status_is(403);

    # Delete existing train
    $t->delete_ok("//$userid:$password@/api/v1/preservation/trains/$train_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent train
    $t->delete_ok("//$userid:$password@/api/v1/preservation/trains/$train_id")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest '*_item() tests' => sub {

    plan tests => 35;

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

    my $not_for_loan_waiting_list_in = 24;
    my $not_for_loan_train_in        = 42;

    t::lib::Mocks::mock_preference(
        'PreservationNotForLoanWaitingListIn',
        $not_for_loan_waiting_list_in
    );

    my $default_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $another_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    my $attributes = [
        {
            name          => 'color',
            type          => 'authorised_value',
            option_source => 'COLORS'
        },
        { name => 'title', type => 'db_column', option_source => '245$a' },
        {
            name => 'height',
            type => 'free_text'
        },
    ];
    my $processing_attributes = $default_processing->attributes($attributes);
    my $color_attribute       = $processing_attributes->search( { name => 'color' } )->next;
    my $title_attribute       = $processing_attributes->search( { name => 'title' } )->next;
    my $height_attribute      = $processing_attributes->search( { name => 'height' } )->next;

    my $train = $builder->build_object(
        {
            class => 'Koha::Preservation::Trains',
            value => {
                not_for_loan          => $not_for_loan_train_in,
                default_processing_id => $default_processing->processing_id,
                closed_on             => undef,
                sent_on               => undef,
                received_on           => undef,
            }
        }
    );
    my $train_id = $train->train_id;

    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item;
    my $item_3 = $builder->build_sample_item;

    # Add item not in waiting list
    $t->post_ok(
        "//$userid:$password@/api/v1/preservation/trains/$train_id/items" => json => { item_id => $item_1->itemnumber }
    )->status_is(400)->json_is( { error => 'Item not in waiting list' } );

    $item_1->notforloan($not_for_loan_waiting_list_in)->store;

    # Add item in waiting list
    my $item_attributes = [
        {
            processing_attribute_id => $color_attribute->processing_attribute_id,
            value                   => 'red'
        },
        {
            processing_attribute_id => $title_attribute->processing_attribute_id,
            value                   => 'my title'
        },
    ];
    my $train_item_id =
        $t->post_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id/items" => json =>
            { item_id => $item_1->itemnumber, attributes => $item_attributes } )
        ->status_is( 201, 'REST3.2.1' )
        ->json_is( '/item_id'       => $item_1->itemnumber )
        ->json_is( '/processing_id' => $train->default_processing_id )
        ->json_has('/added_on')
        ->tx->res->json->{train_item_id};
    my $train_item = Koha::Preservation::Train::Items->find($train_item_id);

    $t->get_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id/items/$train_item_id" =>
            { 'x-koha-embed' => 'attributes' } )->status_is(200)->json_is(
        {
            %{ $train_item->to_api },
            attributes => $train_item->attributes->to_api
        }
            );

    is(
        $item_1->get_from_storage->notforloan,
        $train->not_for_loan,
        "Item not for loan has been set to train's not for loan"
    );

    # Add deleted item
    $item_2->delete;
    $t->post_ok(
        "//$userid:$password@/api/v1/preservation/trains/$train_id/items" => json => { item_id => $item_2->itemnumber }
    )->status_is(404)->json_is( { error => 'Item not found', error_code => 'not_found' } );

    # batch add items
    # Nothing added (FIXME maybe not 201?)
    warning_is {
        $t->post_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id/items/batch" => json =>
                [ { item_id => $item_3->itemnumber } ] )->status_is(201)->json_is( [] );
    }
    'Item not added to train: [Cannot add item to train, it is not in the waiting list]';

    $item_3->notforloan($not_for_loan_waiting_list_in)->store;
    $t->post_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id/items/batch" => json =>
            [ { item_id => $item_3->itemnumber } ] )
        ->status_is(201)
        ->json_is( '/0/item_id'       => $item_3->itemnumber )
        ->json_is( '/0/processing_id' => $train->default_processing_id )
        ->json_has('/0/added_on');

    # Update item
    my $new_item_attributes = [
        {
            processing_attribute_id => $title_attribute->processing_attribute_id,
            value                   => 'my new title'
        },
        {
            processing_attribute_id => $height_attribute->processing_attribute_id,
            value                   => '24cm'
        },
    ];
    $t->put_ok(
        "//$userid:$password@/api/v1/preservation/trains/$train_id/items/$train_item_id" => json => {
            item_id    => $item_1->itemnumber,
            attributes => $new_item_attributes,
        }
    )->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/preservation/trains/$train_id/items/$train_item_id" =>
            { 'x-koha-embed' => 'attributes' } )->status_is(200)->json_is(
        {
            %{ $train_item->to_api },
            attributes => $train_item->attributes->to_api
        }
            );

    # Delete existing item
    $t->delete_ok("//$userid:$password@/api/v1/preservation/trains/$train_id/items/$train_item_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Delete non existing item
    $t->delete_ok("//$userid:$password@/api/v1/preservation/trains/$train_id/items/$train_item_id")
        ->status_is(404)
        ->json_is( '/error' => 'Train item not found' );

    $schema->storage->txn_rollback;
};
