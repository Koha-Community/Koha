#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 1;
use Test::MockModule;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'order by me.barcode should return 200' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $bundle = $builder->build_sample_item;
    my $item   = $builder->build_sample_item;
    $bundle->add_to_bundle($item);

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );

    my $password = 'thePassword123';

    $patron->set_password( { password => $password, skip_validation => 1 } );

    my $userid     = $patron->userid;
    my $itemnumber = $bundle->itemnumber;

    $t->get_ok("//$userid:$password@/api/v1/items/$itemnumber/bundled_items?_order_by=+me.barcode")->status_is(200);

    $schema->storage->txn_rollback;
};
