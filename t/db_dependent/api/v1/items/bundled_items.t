#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'bundled_items()' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $item       = $builder->build_sample_item;
    my $itemnumber = $item->itemnumber;
    my $patron     = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );

    # Make sure we have at least 10 items
    for ( 1 .. 10 ) {
        my $bundled_item = $builder->build_sample_item;
        $item->add_to_bundle($bundled_item);
    }

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    $t->get_ok("//$userid:$password@/api/v1/items/$itemnumber/bundled_items")
        ->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/items/$itemnumber/bundled_items")->status_is( 200, 'REST3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };

    is( $response_count, 10, 'The API returns 10 bundled items' );

    $schema->storage->txn_rollback;

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

};

subtest 'add_to_bundle' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my $item       = $builder->build_sample_item;
    my $itemnumber = $item->itemnumber;
    my $patron     = $builder->build_object(
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

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    my $item_to_bundle = $builder->build_sample_item;
    my $link           = {
        item_id       => undef,
        external_id   => $item_to_bundle->barcode,
        force_checkin => 0,
        ignore_holds  => 0,
        marc_link     => 0
    };

    $t->post_ok( "//$userid:$password@/api/v1/items/$itemnumber/bundled_items" => json => $link )
        ->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->post_ok( "//$userid:$password@/api/v1/items/$itemnumber/bundled_items" => json => $link )
        ->status_is( 201, 'Link created successfully' )
        ->json_is( '/item_id' => $item_to_bundle->itemnumber, 'Bundled item returned' );

    $t->post_ok( "//$userid:$password@/api/v1/items/$itemnumber/bundled_items" => json => $link )
        ->status_is( 409, 'Cannot re-link already linked item' )
        ->json_is( '/error_code' => 'already_bundled', 'Correct error code' );

    # marc_link
    $item_to_bundle      = $builder->build_sample_item;
    $link->{external_id} = $item_to_bundle->barcode;
    $link->{marc_link}   = 1;

    my $bundled_marc = $item_to_bundle->biblio->metadata->record;
    is( $bundled_marc->field('773'), undef, 'No 773 field in item to bundle' );

    $t->post_ok( "//$userid:$password@/api/v1/items/$itemnumber/bundled_items" => json => $link )
        ->status_is( 201, 'Link created successfully' )
        ->json_is( '/item_id' => $item_to_bundle->itemnumber, 'Bundled item returned' );

    $item_to_bundle->discard_changes;
    $bundled_marc = $item_to_bundle->biblio->metadata->record;
    is(
        ref( $bundled_marc->field('773') ), 'MARC::Field',
        '773 field is set after bundling with "marc_link = 1"'
    );

    $schema->storage->txn_rollback;
};
