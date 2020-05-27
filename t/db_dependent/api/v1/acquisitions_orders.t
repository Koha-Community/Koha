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

use Test::More tests => 5;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Acquisition::Orders;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    my $basket = $builder->build_object({ class => 'Koha::Acquisition::Baskets' });
    # Create test context
    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { basketno => $basket->basketno, orderstatus => 'new' }
        }
    );
    my $another_order = $order->unblessed; # create a copy of $order but make
    delete $another_order->{ordernumber};  # sure ordernumber will be regenerated
    $another_order = $builder->build_object({ class => 'Koha::Acquisition::Orders', value => $another_order });

    ## Authorized user tests
    my $count_of_orders = Koha::Acquisition::Orders->search->count;
    # Make sure we are returned with the correct amount of orders
    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/orders" )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_has('/'.($count_of_orders-1).'/order_id')
      ->json_hasnt('/'.($count_of_orders).'/order_id');

    subtest 'query parameters' => sub {

        my $fields = {
            biblio_id => 'biblionumber',
            basket_id => 'basketno',
            fund_id   => 'budget_id',
        };

        my $size = keys %{$fields};

        plan tests => $size * (2 + 2 * $size);

        foreach my $field ( keys %{$fields} ) {
            my $model_field = $fields->{ $field };
            my $result = $t->get_ok("//$userid:$password@/api/v1/acquisitions/orders?$field=" . $order->$model_field)
              ->status_is(200);

            foreach my $key ( keys %{$fields} ) {
              my $key_field = $fields->{ $key };
              # Check the result order first since it's not predefined.
              if ($result->tx->res->json->[0]->{$key} eq $order->$key_field) {
                $result->json_is( "/0/$key", $order->$key_field );
                $result->json_is( "/1/$key", $another_order->$key_field );
              } else {
                $result->json_is( "/0/$key", $another_order->$key_field );
                $result->json_is( "/1/$key", $order->$key_field );
              }
            }
        }
    };

    # Warn on unsupported query parameter
    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/orders?order_blah=blah" )
      ->status_is(400)
      ->json_is( [{ path => '/query/order_blah', message => 'Malformed query string'}] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => { orderstatus => 'new' }
        }
    );
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2048 }
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/orders/" . $order->ordernumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '' => $order->to_api, 'SWAGGER3.3.2' );

    my $non_existent_order_id = $order->ordernumber;
    $order->delete;

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/orders/" . $non_existent_order_id )
      ->status_is(404)
      ->json_is( '/error' => 'Order not found' );

    # Regression tests for bug 25513
    # Pick a high value that could be transformed into exponential
    # representation and not considered a number by buggy DBD::mysql versions
    $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus => 'new',
                ecost_tax_excluded => 9963405519357589504,
                unitprice => 10177559957753600000
            }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/acquisitions/orders/" . $order->ordernumber )
      ->json_is( '' => $order->to_api, 'Number representation should be consistent' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $order_obj = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                orderstatus => 'new',
                unitprice   => 10,
                replacementprice => 10,
                quantity    => 2,
                quantityreceived => 0,
                datecancellationprinted => undef,
                order_internalnote => 'This is a dummy note for testing'
            }
        }
    );
    my $order = $order_obj->to_api;
    $order_obj->delete;
    delete $order->{ordernumber};
    $order->{uncertain_price} = Mojo::JSON->false;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/acquisitions/orders" => json => $order )
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $order_with_invalid_field = { %$order };
    $order_with_invalid_field->{'orderinvalid'} = 'Order invalid';

    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders" => json => $order_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: orderinvalid.",
                path    => "/body"
            }
        ]
    );

    # Authorized attempt to write
    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders" => json => $order )
      ->status_is( 201, 'SWAGGER3.2.1' )
      ->json_is( '/internal_note' => $order->{internal_note}, 'SWAGGER3.3.1' )
      ->header_like( Location => qr/\/api\/v1\/acquisitions\/orders\/\d*/, 'SWAGGER3.4.1' );

    # save the order_id
    my $order_id = $order->{order_id};
    # Authorized attempt to create with null id
    $order->{order_id} = undef;

    $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders" => json => $order )
      ->status_is(400)
      ->json_has('/errors');

    # Authorized attempt to create with existing id
    $order->{order_id} = $order_id;

    warning_like {
        $t->post_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders" => json => $order )
          ->status_is(409)
          ->json_has( '/error' => "Fails when trying to add an existing order_id")
          ->json_like( '/conflict' => qr/(aqorders\.)?PRIMARY/ ); }
        qr/DBD::mysql::st execute failed: Duplicate entry '(.*)' for key '(aqorders\.)?PRIMARY'/;

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $library    = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_id = $library->branchcode;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/libraries/$library_id"
                    => json => { name => 'New unauthorized name change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $library_with_missing_field = {
        address1 => "New library address",
    };

    my $result = $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_missing_field )
      ->status_is(400);
    # Check the result order first since it's not predefined.
    if ($result->tx->res->json->{errors}->[0]->{path} eq '/body/name') {
      $result->json_is(
        "/errors",
        [
          {message => "Missing property.", path => "/body/name"},
          {message => "Missing property.", path => "/body/library_id"}
        ]
      );
    } else {
      $result->json_is(
        "/errors",
        [
          {message => "Missing property.", path => "/body/library_id"},
          {message => "Missing property.", path => "/body/name"}
        ]
      );
    }

    my $deleted_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_with_updated_field = $deleted_library->to_api;
    $library_with_updated_field->{library_id} = $library_id;
    $deleted_library->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_updated_field )
      ->status_is(200, 'SWAGGER3.2.1')
      ->json_is( '' => $library_with_updated_field, 'SWAGGER3.3.3' );

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = { %$library_with_updated_field };
    $library_with_invalid_field->{'branchinvalid'} = 'Library invalid';

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: branchinvalid.",
                path    => "/body"
            }
        ]
    );

    my $non_existent_code = 'nope'.int(rand(10000));
    $t->put_ok("//$auth_userid:$password@/api/v1/libraries/$non_existent_code" => json => $library_with_updated_field)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $order = $builder->build_object( { class => 'Koha::Acquisition::Orders' } );

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/acquisitions/orders/" . $order->ordernumber )
      ->status_is(403);

    $t->delete_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders/" . $order->ordernumber )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok( "//$auth_userid:$password@/api/v1/acquisitions/orders/" . $order->ordernumber )
      ->status_is(404);

    $schema->storage->txn_rollback;
};
