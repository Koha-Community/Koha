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

use utf8;
use Encode;

use Test::More tests => 8;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Circulation qw( AddIssue AddReturn );

use Koha::Biblios;
use Koha::Database;
use Koha::Checkouts;
use Koha::Old::Checkouts;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio({
        title  => 'The unbearable lightness of being',
        author => 'Milan Kundera'
    });
    $t->get_ok("//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber)
      ->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                => { Accept => 'application/weird+format' } )
      ->status_is(400);

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/json' } )
      ->status_is(200)
      ->json_is( '/title', 'The unbearable lightness of being' )
      ->json_is( '/author', 'Milan Kundera' );

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marcxml+xml' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc-in-json' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
      ->status_is(200)
      ->content_is($biblio->metadata->record->as_formatted);

    $biblio->delete;
    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc' } )
      ->status_is(404)
      ->json_is( '/error', 'Object not found.' );

    subtest 'marc-in-json encoding tests' => sub {

        plan tests => 3;

        my $title_with_diacritics = "L'insoutenable légèreté de l'être";

        my $biblio = $builder->build_sample_biblio(
            {
                title  => $title_with_diacritics,
                author => "Milan Kundera"
            }
        );

        my $result = $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                    => { Accept => 'application/marc-in-json' } )
          ->status_is(200)->tx->res->body;

        my $encoded_title  = Encode::encode( "UTF-8", $title_with_diacritics );

        like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );
    };

    $schema->storage->txn_rollback;
};

subtest 'get_items() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio();
    $t->get_ok("//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/items")
      ->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/items")
      ->status_is(200)
      ->json_is( '' => [], 'No items on the biblio' );

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/items")
      ->status_is(200)
      ->json_is( '' => [ $item_1->to_api, $item_2->to_api ], 'The items are returned' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 } # no permissions
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $item      = $builder->build_sample_item();
    my $biblio_id = $item->biblionumber;

    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(403, 'Not enough permissions makes it return the right code');

    # Add permissions
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 9,
                code           => 'edit_catalogue'
            }
        }
    );


    # Bibs with items cannot be deleted
    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(409);

    $item->delete();

    # Bibs with no items can be deleted
    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok("//$userid:$password@/api/v1/biblios/$biblio_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'get_public() tests' => sub {

    plan tests => 25;

    $schema->storage->txn_begin;

    my $category = $builder->build_object({ class => 'Koha::Patron::Categories' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags        => undef, # opac user
                categorycode => $category->categorycode
            }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio({
        title  => 'The unbearable lightness of being',
        author => 'Milan Kundera'
    });

    # Make sure author in shown in the OPAC
    my $subfields = Koha::MarcSubfieldStructures->search({ tagfield => '100' });
    while ( my $subfield = $subfields->next ) {
        $subfield->set({ hidden => -1 })->store;
    }
    Koha::Caches->get_instance()->flush_all;

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                => { Accept => 'application/weird+format' } )
      ->status_is(400);

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
      ->status_is(200)
      ->content_like( qr{100\s+_aMilan Kundera} )
      ->content_like( qr{245\s+_aThe unbearable lightness of being} );

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marcxml+xml' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc-in-json' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
      ->status_is(200)
      ->content_is($biblio->metadata->record->as_formatted);

    subtest 'anonymous access' => sub {
        plan tests => 9;

        $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marcxml+xml' } )
          ->status_is(200);

        $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                    => { Accept => 'application/marc-in-json' } )
        ->status_is(200);

        $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                    => { Accept => 'application/marc' } )
        ->status_is(200);

        $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                    => { Accept => 'text/plain' } )
        ->status_is(200)
        ->content_is($biblio->metadata->record->as_formatted);
    };

    subtest 'marc-in-json encoding tests' => sub {

        plan tests => 3;

        my $title_with_diacritics = "L'insoutenable légèreté de l'être";

        my $biblio = $builder->build_sample_biblio(
            {
                title  => $title_with_diacritics,
                author => "Milan Kundera"
            }
        );

        my $result = $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                    => { Accept => 'application/marc-in-json' } )
          ->status_is(200)->tx->res->body;

        my $encoded_title  = Encode::encode( "UTF-8", $title_with_diacritics );

        like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );
    };

    # Hide author in OPAC
    $subfields = Koha::MarcSubfieldStructures->search({ tagfield => '100' });
    while ( my $subfield = $subfields->next ) {
        $subfield->set({ hidden => 1 })->store;
    }

    Koha::Caches->get_instance()->flush_all;

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
      ->status_is(200)
      ->content_unlike( qr{100\s+_aMilan Kundera} )
      ->content_like( qr{245\s+_aThe unbearable lightness of being} );

    subtest 'hidden_in_opac tests' => sub {

        plan tests => 6;

        my $biblio_hidden_in_opac = 1;

        my $biblio_class = Test::MockModule->new('Koha::Biblio');
        # force biblio hidden in OPAC
        $biblio_class->mock( 'hidden_in_opac', sub { return $biblio_hidden_in_opac; } );

        $t->get_ok( "/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
          ->status_is(404, 'hidden_in_opac + anonymous => hidden');

        my $category_override_hidden_items = 0;
        my $category_class = Test::MockModule->new('Koha::Patron::Category');
        $category_class->mock( 'override_hidden_items', sub { return $category_override_hidden_items; } );
        $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
          ->status_is(404, "hidden_in_opac + patron whose category doesn't override => hidden");

        # Make the category override
        $category_override_hidden_items = 1;
        $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'text/plain' } )
          ->status_is(200, "hidden_in_opac + patron whose category that overrides => displayed");

        t::lib::Mocks::mock_preference('OpacHiddenItems');
    };

    $biblio->delete;
    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber
                 => { Accept => 'application/marc' } )
      ->status_is(404)
      ->json_is( '/error', 'Object not found.' );

    $schema->storage->txn_rollback;
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

    # Small trick to ease testing
    Koha::Libraries->search->update({ pickup_location => 0 });

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'A', pickup_location => 1 } });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'B', pickup_location => 1 } });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries', value => { marcorgcode => 'C', pickup_location => 1 } });

    my $library_1_api = $library_1->to_api();
    my $library_2_api = $library_2->to_api();
    my $library_3_api = $library_3->to_api();

    $library_1_api->{needs_override} = Mojo::JSON->false;
    $library_2_api->{needs_override} = Mojo::JSON->false;
    $library_3_api->{needs_override} = Mojo::JSON->true;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { userid => 'tomasito', flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 6,
                code           => 'place_holds',
            },
        }
    );

    my $biblio_class = Test::MockModule->new('Koha::Biblio');
    $biblio_class->mock(
        'pickup_locations',
        sub {
            my ( $self, $params ) = @_;
            my $mock_patron = $params->{patron};
            is( $mock_patron->borrowernumber,
                $patron->borrowernumber, 'Patron passed correctly' );
            return Koha::Libraries->search(
                {
                    branchcode => {
                        '-in' => [
                            $library_1->branchcode,
                            $library_2->branchcode
                        ]
                    }
                },
                {   # we make sure no surprises in the order of the result
                    order_by => { '-asc' => 'marcorgcode' }
                }
            );
        }
    );

    my $biblio = $builder->build_sample_biblio;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/"
          . $biblio->id
          . "/pickup_locations?patron_id=" . $patron->id )
      ->json_is( [ $library_1_api, $library_2_api ] );

    # filtering works!
    $t->get_ok( "//$userid:$password@/api/v1/biblios/"
          . $biblio->id
          . '/pickup_locations?'
          . 'patron_id=' . $patron->id . '&q={"marc_org_code": { "-like": "A%" }}' )
      ->json_is( [ $library_1_api ] );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    my $library_4 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 0, marcorgcode => 'X' } });
    my $library_5 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1, marcorgcode => 'Y' } });

    my $library_5_api = $library_5->to_api();
    $library_5_api->{needs_override} = Mojo::JSON->true;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/"
          . $biblio->id
          . "/pickup_locations?"
          . "patron_id=" . $patron->id . "&_order_by=marc_org_code" )
      ->json_is( [ $library_1_api, $library_2_api, $library_3_api, $library_5_api ] );

    subtest 'Pagination and AllowHoldPolicyOverride tests' => sub {

        plan tests => 27;

        t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

        $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->id . "/pickup_locations?" . "patron_id=" . $patron->id . "&_order_by=marc_org_code" . "&_per_page=1" )
          ->json_is( [$library_1_api] )
          ->header_is( 'X-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_is( 'X-Base-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_unlike( 'Link', qr|rel="prev"| )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=2.*|_page=2.*\&_per_page=1.*)>\; rel="next"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=1.*|_page=1.*\&_per_page=1).*>\; rel="first"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=4.*|_page=4.*\&_per_page=1).*>\; rel="last"# );

        $t->get_ok( "//$userid:$password@/api/v1/biblios/"
              . $biblio->id
              . "/pickup_locations?"
              . "patron_id="
              . $patron->id
              . "&_order_by=marc_org_code"
              . "&_per_page=1&_page=3" )    # force the needs_override=1 check
          ->json_is( [$library_3_api] )
          ->header_is( 'X-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_is( 'X-Base-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=2.*|_page=2.*\&_per_page=1.*)>\; rel="prev"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=4.*|_page=4.*\&_per_page=1.*)>\; rel="next"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=1.*|_page=1.*\&_per_page=1).*>\; rel="first"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=4.*|_page=4.*\&_per_page=1).*>\; rel="last"# );

        t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 0 );

        $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->id . "/pickup_locations?" . "patron_id=" . $patron->id . "&_order_by=marc_org_code" . "&_per_page=1" )
          ->json_is( [$library_1_api] )
          ->header_is( 'X-Total-Count', '2' )
          ->header_is( 'X-Base-Total-Count', '2' )
          ->header_unlike( 'Link', qr|rel="prev"| )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=2.*|_page=2.*\&_per_page=1.*)>\; rel="next"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=1.*|_page=1.*\&_per_page=1).*>\; rel="first"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=2.*|_page=2.*\&_per_page=1).*>\; rel="last"# );
    };

    my $deleted_patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $deleted_patron_id = $deleted_patron->id;
    $deleted_patron->delete;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/"
          . $biblio->id
          . "/pickup_locations?"
          . "patron_id=" . $deleted_patron_id )
      ->status_is( 400 )
      ->json_is( '/error' => 'Patron not found' );

    $biblio->delete;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/"
          . $biblio->id
          . "/pickup_locations?"
          . "patron_id=" . $patron->id )
      ->status_is( 404 )
      ->json_is( '/error' => 'Biblio not found' );

    $schema->storage->txn_rollback;
};

subtest 'get_items_public() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $override_hidden_items = 0;

    my $mocked_category = Test::MockModule->new('Koha::Patron::Category');
    $mocked_category->mock(
        'override_hidden_items',
        sub {
            return $override_hidden_items;
        }
    );

    my $rules = undef;

    my $mocked_context = Test::MockModule->new('C4::Context');
    $mocked_context->mock(
        'yaml_preference',
        sub {
            return $rules;
        }
    );

    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio();

    $t->get_ok(
        "//$userid:$password@/api/v1/public/biblios/" . $biblio->id . "/items" )
      ->status_is(200)->json_is( '' => [], 'No items on the biblio' );

    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->id } );
    my $item_2 = $builder->build_sample_item(
        { biblionumber => $biblio->id, withdrawn => 1 } );

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/"
          . $biblio->biblionumber
          . "/items" )->status_is(200)->json_is(
        '' => [
            $item_1->to_api( { public => 1 } ),
            $item_2->to_api( { public => 1 } )
        ],
        'The items are returned'
          );

    $rules = { withdrawn => ['1'] };

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/"
          . $biblio->biblionumber
          . "/items" )->status_is(200)->json_is(
        '' => [ $item_1->to_api( { public => 1 } ) ],
        'The items are returned, hidden one is not returned'
          );

    $t->get_ok( "/api/v1/public/biblios/"
          . $biblio->biblionumber
          . "/items" )->status_is(200)->json_is(
        '' => [ $item_1->to_api( { public => 1 } ) ],
        'Anonymous user, items are returned, hidden one is not returned'
          );


    $override_hidden_items = 1;

    $t->get_ok( "//$userid:$password@/api/v1/public/biblios/"
          . $biblio->biblionumber
          . "/items" )->status_is(200)->json_is(
        '' => [
            $item_1->to_api( { public => 1 } ),
            $item_2->to_api( { public => 1 } )
        ],
        'The items are returned, the patron category has an override'
          );

    $schema->storage->txn_rollback;
};

subtest 'get_checkouts() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio();
    $t->get_ok("//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/checkouts")
      ->status_is(403);

    $patron->flags(1)->store; # circulate permissions

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/checkouts")
      ->status_is(200)
      ->json_is( '' => [], 'No checkouts on the biblio' );

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    AddIssue( $patron->unblessed, $item_1->barcode );
    AddIssue( $patron->unblessed, $item_2->barcode );

    my $ret = $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/checkouts")
      ->status_is(200)
      ->tx->res->json;

    my $checkout_1 = Koha::Checkouts->find({ itemnumber => $item_1->id });
    my $checkout_2 = Koha::Checkouts->find({ itemnumber => $item_2->id });

    is_deeply( $ret, [ $checkout_1->to_api, $checkout_2->to_api ] );

    AddReturn( $item_1->barcode );

    $ret = $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/checkouts")
      ->status_is(200)
      ->tx->res->json;

    is_deeply( $ret, [ $checkout_2->to_api ] );

    $ret = $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/checkouts?checked_in=1")
      ->status_is(200)
      ->tx->res->json;

    my $old_checkout_1 = Koha::Old::Checkouts->find( $checkout_1->id );

    is_deeply( $ret, [ $old_checkout_1->to_api ] );

    $schema->storage->txn_rollback;
};

subtest 'set_rating() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio();
    $t->post_ok("/api/v1/public/biblios/" . $biblio->biblionumber . "/ratings" => json => { rating => 3 })
      ->status_is(403);

    $t->post_ok("//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber . "/ratings" => json => { rating => 3 })
      ->status_is(200)
      ->json_is( '/rating', '3' )
      ->json_is( '/average', '3' )
      ->json_is( '/count', '1' );

    $t->post_ok("//$userid:$password@/api/v1/public/biblios/" . $biblio->biblionumber . "/ratings" => json => { rating => undef })
      ->status_is(200)
      ->json_is( '/rating', undef )
      ->json_is( '/average', '0' )
      ->json_is( '/count', '0' );

    $schema->storage->txn_rollback;

};
