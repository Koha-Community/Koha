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
use Test::More tests => 4;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON qw(encode_json);

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();
my $t       = Test::Mojo->new('Koha::REST::V1');

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list_managers() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron_with_permission =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**11 } } );    ## 11 == acquisition
    my $patron_without_permission =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $superlibrarian =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'thePassword123';
    $superlibrarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $superlibrarian->userid;
    $superlibrarian->discard_changes;

    my $api_filter = encode_json(
        { 'me.patron_id' => [ $patron_with_permission->id, $patron_without_permission->id, $superlibrarian->id ] } );

    $t->get_ok("//$userid:$password@/api/v1/acquisitions/baskets/managers?q=$api_filter")->status_is(200)->json_is(
        [
            $patron_with_permission->to_api( { user => $patron_with_permission } ),
            $superlibrarian->to_api( { user => $superlibrarian } )
        ]
    );

    $schema->storage->txn_rollback;
};

subtest 'list() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    $schema->resultset('Aqbasket')->search->delete;

    my $superlibrarian =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'thePassword123';
    $superlibrarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $superlibrarian->userid;
    $superlibrarian->discard_changes;

    $t->get_ok("//$userid:$password@/api/v1/acquisitions/baskets")->status_is(200)->json_is( [] );

    my $vendor = $builder->build_object(
        {
            class => 'Koha::Acquisition::Booksellers',
        }
    );
    my $basket = $builder->build_object(
        {
            class => 'Koha::Acquisition::Baskets',
            value => { closedate => undef, authorisedby => undef, booksellerid => $vendor->id, branch => undef }
        }
    );

    $t->get_ok("//$userid:$password@/api/v1/acquisitions/baskets")->status_is(200)->json_is( [ $basket->to_api ] );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $vendor = $builder->build_object(
        {
            class => 'Koha::Acquisition::Booksellers',
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $url = "//$userid:$password@/api/v1/acquisitions/baskets";

    $t->post_ok( $url, json => {} )->status_is(403);

    $schema->resultset('UserPermission')->create(
        {
            borrowernumber => $patron->borrowernumber,
            module_bit     => 11,
            code           => 'order_manage',
        }
    );

    $t->post_ok( $url, json => {} )->status_is(400);

    $t->post_ok( $url, json => { vendor_id => $vendor->id } )
        ->status_is(201)
        ->json_has('/basket_id')
        ->json_is( '/vendor_id', $vendor->id );

    my $basket = {
        vendor_id   => $vendor->id,
        name        => 'Basket #1',
        vendor_note => 'Vendor note',
    };
    $t->post_ok( $url, json => $basket )
        ->status_is(201)
        ->json_has('/basket_id')
        ->json_is( '/vendor_id',   $basket->{vendor_id} )
        ->json_is( '/name',        $basket->{name} )
        ->json_is( '/vendor_note', $basket->{vendor_note} );

    $schema->storage->txn_rollback;
};
