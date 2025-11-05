#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 14;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $bookseller = $builder->build_object(
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

$t->post_ok( $url, json => { vendor_id => $bookseller->id } )->status_is(201)->json_has('/basket_id')
    ->json_is( '/vendor_id', $bookseller->id );

my $basket = {
    vendor_id   => $bookseller->id,
    name        => 'Basket #1',
    vendor_note => 'Vendor note',
};
$t->post_ok( $url, json => $basket )->status_is(201)->json_has('/basket_id')
    ->json_is( '/vendor_id',   $basket->{vendor_id} )->json_is( '/name', $basket->{name} )
    ->json_is( '/vendor_note', $basket->{vendor_note} );

$schema->storage->txn_rollback;
