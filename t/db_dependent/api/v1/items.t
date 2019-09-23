#!/usr/bin/env perl

# Copyright 2016 Koha-Suomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Items;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $item   = $builder->build_object( { class => 'Koha::Items' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password(
        { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/items" )
      ->status_is(403)
      ->json_is(
        '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/items" )
      ->status_is( 200, 'SWAGGER3.2.2' );

    my $items_count = Koha::Items->search->count;
    my $response_count = scalar @{ $t->tx->res->json };

    is( $items_count, $response_count, 'The API returns all the items' );

    $t->get_ok( "//$userid:$password@/api/v1/items?external_id=" . $item->barcode )
      ->status_is(200)
      ->json_is( '' => [ Koha::REST::V1::Items::_to_api( $item->TO_JSON ) ], 'SWAGGER3.3.2');

    my $barcode = $item->barcode;
    $item->delete;

    $t->get_ok( "//$userid:$password@/api/v1/items?external_id=" . $item->barcode )
      ->status_is(200)
      ->json_is( '' => [] );

    $schema->storage->txn_rollback;
};


subtest 'get() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $item = $builder->build_object( { class => 'Koha::Items' } );
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });

    my $nonprivilegedpatron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 0 }
    });

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $nonprivilegedpatron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is(403)
      ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password({ password => $password, skip_validation => 1 });
    $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '' => Koha::REST::V1::Items::_to_api( $item->TO_JSON ), 'SWAGGER3.3.2' );

    my $non_existent_code = $item->itemnumber;
    $item->delete;

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $non_existent_code )
      ->status_is(404)
      ->json_is( '/error' => 'Item not found' );

    $schema->storage->txn_rollback;
};
