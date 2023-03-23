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

use Test::More tests => 11;
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

    plan tests => 22;

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

    subtest 'marcxml encoding tests' => sub {
        plan tests => 3;

        my $marcflavour = C4::Context->preference('marcflavour');
        t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');


        my $title_with_diacritics = "L'insoutenable légèreté de l'être";

        my $biblio = $builder->build_sample_biblio(
            {
                title  => $title_with_diacritics,
                author => "Milan Kundera"
            }
        );

        my $record = $biblio->metadata->record;
        $record->leader('     nam         3  4500');
        $biblio->metadata->metadata($record->as_xml_record('UNIMARC'));
        $biblio->metadata->store;

        my $result = $t->get_ok( "//$userid:$password@/api/v1/biblios/" . $biblio->biblionumber
                    => { Accept => 'application/marcxml+xml' } )
          ->status_is(200)->tx->res->body;

        my $encoded_title  = Encode::encode( "UTF-8", $title_with_diacritics );

        like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );
        t::lib::Mocks::mock_preference('marcflavour', $marcflavour);
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


subtest 'post() tests' => sub {

    plan tests => 13;

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

    my $frameworkcode = 'BKS';
    my $marcxml = q|<?xml version="1.0" encoding="UTF-8"?>
    <record
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
        xmlns="http://www.loc.gov/MARC21/slim">

      <leader>01102pam a2200289 a 7500</leader>
      <controlfield tag="001">2504398</controlfield>
      <controlfield tag="005">20200421093816.0</controlfield>
      <controlfield tag="008">920610s1993    caub         s001 0 eng  </controlfield>
      <datafield tag="010" ind1=" " ind2=" ">
        <subfield code="a">   92021731 </subfield>
      </datafield>
      <datafield tag="020" ind1=" " ind2=" ">
        <subfield code="a">05200784381 (Test marcxml)</subfield>
      </datafield>
      <datafield tag="020" ind1=" " ind2=" ">
        <subfield code="a">05200784461 (Test marcxml)</subfield>
      </datafield>
      <datafield tag="040" ind1=" " ind2=" ">
        <subfield code="a">DLC</subfield>
        <subfield code="c">DLC</subfield>
        <subfield code="d">DLC</subfield>
      </datafield>
      <datafield tag="041" ind1="0" ind2=" ">
        <subfield code="a">enggrc</subfield>
      </datafield>
      <datafield tag="050" ind1="0" ind2="0">
        <subfield code="a">PA522</subfield>
        <subfield code="b">.M38 1993</subfield>
      </datafield>
      <datafield tag="082" ind1="0" ind2="0">
        <subfield code="a">480</subfield>
        <subfield code="2">20</subfield>
      </datafield>
      <datafield tag="100" ind1="1" ind2=" ">
        <subfield code="a">Mastronarde, Donald J.</subfield>
        <subfield code="9">389</subfield>
      </datafield>
      <datafield tag="245" ind1="1" ind2="0">
        <subfield code="a">Introduction to Attic Greek (Using marcxml) /</subfield>
        <subfield code="c">Donald J. Mastronarde.</subfield>
      </datafield>
      <datafield tag="260" ind1=" " ind2=" ">
        <subfield code="a">Berkeley :</subfield>
        <subfield code="b">University of California Press,</subfield>
        <subfield code="c">c1993.</subfield>
      </datafield>
      <datafield tag="300" ind1=" " ind2=" ">
        <subfield code="a">ix, 425 p. :</subfield>
        <subfield code="b">maps ;</subfield>
        <subfield code="c">26 cm.</subfield>
      </datafield>
      <datafield tag="500" ind1=" " ind2=" ">
        <subfield code="a">Includes index.</subfield>
      </datafield>
      <datafield tag="650" ind1=" " ind2="0">
        <subfield code="a">Attic Greek dialect</subfield>
        <subfield code="9">7</subfield>
      </datafield>
      <datafield tag="856" ind1="4" ind2="2">
        <subfield code="3">Contributor biographical information</subfield>
        <subfield code="u">http://www.loc.gov/catdir/bios/ucal051/92021731.html</subfield>
      </datafield>
      <datafield tag="856" ind1="4" ind2="2">
        <subfield code="3">Publisher description</subfield>
        <subfield code="u">http://www.loc.gov/catdir/description/ucal041/92021731.html</subfield>
      </datafield>
      <datafield tag="906" ind1=" " ind2=" ">
        <subfield code="a">7</subfield>
        <subfield code="b">cbc</subfield>
        <subfield code="c">orignew</subfield>
        <subfield code="d">1</subfield>
        <subfield code="e">ocip</subfield>
        <subfield code="f">19</subfield>
        <subfield code="g">y-gencatlg</subfield>
      </datafield>
      <datafield tag="942" ind1=" " ind2=" ">
        <subfield code="2">ddc</subfield>
        <subfield code="c">BK</subfield>
      </datafield>
      <datafield tag="955" ind1=" " ind2=" ">
        <subfield code="a">pc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93</subfield>
      </datafield>
      <datafield tag="999" ind1=" " ind2=" ">
        <subfield code="c">3</subfield>
        <subfield code="d">3</subfield>
      </datafield>
    </record>|;

    my $mij = q|{
      "fields": [
        {
          "001": "2504398"
        },
        {
          "005": "20200421093816.0"
        },
        {
          "008": "920610s1993    caub         s001 0 eng  "
        },
        {
          "010": {
            "ind1": " ",
            "subfields": [
              {
                "a": "   92021731 "
              }
            ],
            "ind2": " "
          }
        },
        {
          "020": {
            "subfields": [
              {
                "a": "05200784382 (Test mij)"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "020": {
            "subfields": [
              {
                "a": "05200784462 (Test mij)"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "040": {
            "subfields": [
              {
                "a": "DLC"
              },
              {
                "c": "DLC"
              },
              {
                "d": "DLC"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "041": {
            "ind2": " ",
            "subfields": [
              {
                "a": "enggrc"
              }
            ],
            "ind1": "0"
          }
        },
        {
          "050": {
            "subfields": [
              {
                "a": "PA522"
              },
              {
                "b": ".M38 1993"
              }
            ],
            "ind1": "0",
            "ind2": "0"
          }
        },
        {
          "082": {
            "subfields": [
              {
                "a": "480"
              },
              {
                "2": "20"
              }
            ],
            "ind2": "0",
            "ind1": "0"
          }
        },
        {
          "100": {
            "ind2": " ",
            "subfields": [
              {
                "a": "Mastronarde, Donald J."
              },
              {
                "9": "389"
              }
            ],
            "ind1": "1"
          }
        },
        {
          "245": {
            "ind1": "1",
            "subfields": [
              {
                "a": "Introduction to Attic Greek  (Using mij) /"
              },
              {
                "c": "Donald J. Mastronarde."
              }
            ],
            "ind2": "0"
          }
        },
        {
          "260": {
            "subfields": [
              {
                "a": "Berkeley :"
              },
              {
                "b": "University of California Press,"
              },
              {
                "c": "c1993."
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "300": {
            "ind1": " ",
            "subfields": [
              {
                "a": "ix, 425 p. :"
              },
              {
                "b": "maps ;"
              },
              {
                "c": "26 cm."
              }
            ],
            "ind2": " "
          }
        },
        {
          "500": {
            "subfields": [
              {
                "a": "Includes index."
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "650": {
            "subfields": [
              {
                "a": "Attic Greek dialect"
              },
              {
                "9": "7"
              }
            ],
            "ind2": "0",
            "ind1": " "
          }
        },
        {
          "856": {
            "subfields": [
              {
                "3": "Contributor biographical information"
              },
              {
                "u": "http://www.loc.gov/catdir/bios/ucal051/92021731.html"
              }
            ],
            "ind2": "2",
            "ind1": "4"
          }
        },
        {
          "856": {
            "ind1": "4",
            "subfields": [
              {
                "3": "Publisher description"
              },
              {
                "u": "http://www.loc.gov/catdir/description/ucal041/92021731.html"
              }
            ],
            "ind2": "2"
          }
        },
        {
          "906": {
            "subfields": [
              {
                "a": "7"
              },
              {
                "b": "cbc"
              },
              {
                "c": "orignew"
              },
              {
                "d": "1"
              },
              {
                "e": "ocip"
              },
              {
                "f": "19"
              },
              {
                "g": "y-gencatlg"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "942": {
            "subfields": [
              {
                "2": "ddc"
              },
              {
                "c": "BK"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "955": {
            "subfields": [
              {
                "a": "pc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "999": {
            "subfields": [
              {
                "c": "3"
              },
              {
                "d": "3"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        }
      ],
      "leader": "01102pam a2200289 a 8500"
    }|;
    my $marc = q|01102pam a2200289 a 9500001000800000005001700008008004100025010001700066020002800083020003500111040001800146041001100164050002100175082001200196100003200208245005800240260005600298300003300354500002000387650002700407856009500434856008700529906004500616942001200661955013000673999000900803250439820200421093816.0920610s1993    caub         s001 0 eng    a   92021731   a05200784383 (Test usmarc)  a05200784463 (Test usmarc)  aDLCcDLCdDLC0 aenggrc00aPA522b.M38 199300a4802201 aMastronarde, Donald J.938910aIntroduction to Attic Greek  (Using usmarc) /cDonald J. Mastronarde.  aBerkeley :bUniversity of California Press,cc1993.  aix, 425 p. :bmaps ;c26 cm.  aIncludes index. 0aAttic Greek dialect97423Contributor biographical informationuhttp://www.loc.gov/catdir/bios/ucal051/92021731.html423Publisher descriptionuhttp://www.loc.gov/catdir/description/ucal041/92021731.html  a7bcbccorignewd1eocipf19gy-gencatlg  2ddccBK  apc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93  c3d3|;

    $t->post_ok("//$userid:$password@/api/v1/biblios")
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

    $t->post_ok("//$userid:$password@/api/v1/biblios" => {'Content-Type' => 'application/marcxml+xml', 'x-framework-id' => $frameworkcode, "x-record-schema" => 'INVALID'})
      ->status_is(400, 'Invalid header x-record-schema');

    $t->post_ok("//$userid:$password@/api/v1/biblios" => {'Content-Type' => 'application/marcxml+xml', 'x-framework-id' => $frameworkcode} => $marcxml)
      ->status_is(200)
      ->json_has('/id');

    $t->post_ok("//$userid:$password@/api/v1/biblios" => {'Content-Type' => 'application/marc-in-json', 'x-framework-id' => $frameworkcode, 'x-confirm-not-duplicate' => 1} => $mij)
      ->status_is(200)
      ->json_has('/id');

    $t->post_ok("//$userid:$password@/api/v1/biblios" => {'Content-Type' => 'application/marc', 'x-framework-id' => $frameworkcode} => $marc)
      ->status_is(200)
      ->json_has('/id');

    $schema->storage->txn_rollback;
};

subtest 'put() tests' => sub {

    plan tests => 14;

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

    my $frameworkcode = 'BKS';
    my $biblio = $builder->build_sample_biblio({frameworkcode => $frameworkcode});

    my $biblionumber = $biblio->biblionumber;

    my $marcxml = q|<?xml version="1.0" encoding="UTF-8"?>
    <record
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
        xmlns="http://www.loc.gov/MARC21/slim">

      <leader>01102pam a2200289 a 6500</leader>
      <controlfield tag="001">2504398</controlfield>
      <controlfield tag="005">20200421093816.0</controlfield>
      <controlfield tag="008">920610s1993    caub         s001 0 eng  </controlfield>
      <datafield tag="010" ind1=" " ind2=" ">
        <subfield code="a">   92021731 </subfield>
      </datafield>
      <datafield tag="020" ind1=" " ind2=" ">
        <subfield code="a">05200784384 (Test json)</subfield>
      </datafield>
      <datafield tag="020" ind1=" " ind2=" ">
        <subfield code="a">05200784464 (Test json)</subfield>
      </datafield>
      <datafield tag="040" ind1=" " ind2=" ">
        <subfield code="a">DLC</subfield>
        <subfield code="c">DLC</subfield>
        <subfield code="d">DLC</subfield>
      </datafield>
      <datafield tag="041" ind1="0" ind2=" ">
        <subfield code="a">enggrc</subfield>
      </datafield>
      <datafield tag="050" ind1="0" ind2="0">
        <subfield code="a">PA522</subfield>
        <subfield code="b">.M38 1993</subfield>
      </datafield>
      <datafield tag="082" ind1="0" ind2="0">
        <subfield code="a">480</subfield>
        <subfield code="2">20</subfield>
      </datafield>
      <datafield tag="100" ind1="1" ind2=" ">
        <subfield code="a">Mastronarde, Donald J.</subfield>
        <subfield code="9">389</subfield>
      </datafield>
      <datafield tag="245" ind1="1" ind2="0">
        <subfield code="a">Introduction to Attic Greek  (Using marcxml) /</subfield>
        <subfield code="c">Donald J. Mastronarde.</subfield>
      </datafield>
      <datafield tag="260" ind1=" " ind2=" ">
        <subfield code="a">Berkeley :</subfield>
        <subfield code="b">University of California Press,</subfield>
        <subfield code="c">c1993.</subfield>
      </datafield>
      <datafield tag="300" ind1=" " ind2=" ">
        <subfield code="a">ix, 425 p. :</subfield>
        <subfield code="b">maps ;</subfield>
        <subfield code="c">26 cm.</subfield>
      </datafield>
      <datafield tag="500" ind1=" " ind2=" ">
        <subfield code="a">Includes index.</subfield>
      </datafield>
      <datafield tag="650" ind1=" " ind2="0">
        <subfield code="a">Attic Greek dialect</subfield>
        <subfield code="9">7</subfield>
      </datafield>
      <datafield tag="856" ind1="4" ind2="2">
        <subfield code="3">Contributor biographical information</subfield>
        <subfield code="u">http://www.loc.gov/catdir/bios/ucal051/92021731.html</subfield>
      </datafield>
      <datafield tag="856" ind1="4" ind2="2">
        <subfield code="3">Publisher description</subfield>
        <subfield code="u">http://www.loc.gov/catdir/description/ucal041/92021731.html</subfield>
      </datafield>
      <datafield tag="906" ind1=" " ind2=" ">
        <subfield code="a">7</subfield>
        <subfield code="b">cbc</subfield>
        <subfield code="c">orignew</subfield>
        <subfield code="d">1</subfield>
        <subfield code="e">ocip</subfield>
        <subfield code="f">19</subfield>
        <subfield code="g">y-gencatlg</subfield>
      </datafield>
      <datafield tag="942" ind1=" " ind2=" ">
        <subfield code="2">ddc</subfield>
        <subfield code="c">BK</subfield>
      </datafield>
      <datafield tag="955" ind1=" " ind2=" ">
        <subfield code="a">pc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93</subfield>
      </datafield>
      <datafield tag="999" ind1=" " ind2=" ">
        <subfield code="c">3</subfield>
        <subfield code="d">3</subfield>
      </datafield>
    </record>|;

    my $mij = q|{
      "fields": [
        {
          "001": "2504398"
        },
        {
          "005": "20200421093816.0"
        },
        {
          "008": "920610s1993    caub         s001 0 eng  "
        },
        {
          "010": {
            "ind1": " ",
            "subfields": [
              {
                "a": "   92021731 "
              }
            ],
            "ind2": " "
          }
        },
        {
          "020": {
            "subfields": [
              {
                "a": "05200784382 (Test mij)"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "020": {
            "subfields": [
              {
                "a": "05200784462 (Test mij)"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "040": {
            "subfields": [
              {
                "a": "DLC"
              },
              {
                "c": "DLC"
              },
              {
                "d": "DLC"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "041": {
            "ind2": " ",
            "subfields": [
              {
                "a": "enggrc"
              }
            ],
            "ind1": "0"
          }
        },
        {
          "050": {
            "subfields": [
              {
                "a": "PA522"
              },
              {
                "b": ".M38 1993"
              }
            ],
            "ind1": "0",
            "ind2": "0"
          }
        },
        {
          "082": {
            "subfields": [
              {
                "a": "480"
              },
              {
                "2": "20"
              }
            ],
            "ind2": "0",
            "ind1": "0"
          }
        },
        {
          "100": {
            "ind2": " ",
            "subfields": [
              {
                "a": "Mastronarde, Donald J."
              },
              {
                "9": "389"
              }
            ],
            "ind1": "1"
          }
        },
        {
          "245": {
            "ind1": "1",
            "subfields": [
              {
                "a": "Introduction to Attic Greek  (Using mij) /"
              },
              {
                "c": "Donald J. Mastronarde."
              }
            ],
            "ind2": "0"
          }
        },
        {
          "260": {
            "subfields": [
              {
                "a": "Berkeley :"
              },
              {
                "b": "University of California Press,"
              },
              {
                "c": "c1993."
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "300": {
            "ind1": " ",
            "subfields": [
              {
                "a": "ix, 425 p. :"
              },
              {
                "b": "maps ;"
              },
              {
                "c": "26 cm."
              }
            ],
            "ind2": " "
          }
        },
        {
          "500": {
            "subfields": [
              {
                "a": "Includes index."
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "650": {
            "subfields": [
              {
                "a": "Attic Greek dialect"
              },
              {
                "9": "7"
              }
            ],
            "ind2": "0",
            "ind1": " "
          }
        },
        {
          "856": {
            "subfields": [
              {
                "3": "Contributor biographical information"
              },
              {
                "u": "http://www.loc.gov/catdir/bios/ucal051/92021731.html"
              }
            ],
            "ind2": "2",
            "ind1": "4"
          }
        },
        {
          "856": {
            "ind1": "4",
            "subfields": [
              {
                "3": "Publisher description"
              },
              {
                "u": "http://www.loc.gov/catdir/description/ucal041/92021731.html"
              }
            ],
            "ind2": "2"
          }
        },
        {
          "906": {
            "subfields": [
              {
                "a": "7"
              },
              {
                "b": "cbc"
              },
              {
                "c": "orignew"
              },
              {
                "d": "1"
              },
              {
                "e": "ocip"
              },
              {
                "f": "19"
              },
              {
                "g": "y-gencatlg"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        },
        {
          "942": {
            "subfields": [
              {
                "2": "ddc"
              },
              {
                "c": "BK"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "955": {
            "subfields": [
              {
                "a": "pc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93"
              }
            ],
            "ind2": " ",
            "ind1": " "
          }
        },
        {
          "999": {
            "subfields": [
              {
                "c": "3"
              },
              {
                "d": "3"
              }
            ],
            "ind1": " ",
            "ind2": " "
          }
        }
      ],
      "leader": "01102pam a2200289 a 8500"
    }|;
    my $marc = q|01116pam a2200289 a 4500001000800000005001700008008004100025010001700066020002800083020002800111040001800139041001100157050002100168082001200189100003200201245007500233260005600308300003300364500002000397650002700417856009500444856008700539906004500626942001200671955013000683999001300813250439820221223213433.0920610s1993    caub         s001 0 eng    a   92021731   a05200784384 (Test json)  a05200784464 (Test json)  aDLCcDLCdDLC0 aenggrc00aPA522b.M38 199300a4802201 aMastronarde, Donald J.938910aIntroduction to Attic Greek  (Using usmarc) /cDonald J. Mastronarde.  aBerkeley :bUniversity of California Press,cc1993.  aix, 425 p. :bmaps ;c26 cm.  aIncludes index. 0aAttic Greek dialect97423Contributor biographical informationuhttp://www.loc.gov/catdir/bios/ucal051/92021731.html423Publisher descriptionuhttp://www.loc.gov/catdir/description/ucal041/92021731.html  a7bcbccorignewd1eocipf19gy-gencatlg  2ddccBK  apc05 to ea00 06-11-92; ea04 to SCD 06-11-92; fd11 06-11-92 (PA522.M...); fr21 06-12-92; fs62 06-15-92; CIP ver. pv07 11-12-93  c715d715|;

    $t->put_ok("//$userid:$password@/api/v1/biblios/$biblionumber")
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

    $t->put_ok("//$userid:$password@/api/v1/biblios/$biblionumber" => {'Content-Type' => 'application/marcxml+xml', 'x-framework-id' => $frameworkcode} => $marcxml)
      ->status_is(200)
      ->json_has('/id');

    $biblio = Koha::Biblios->find($biblionumber);

    is($biblio->title, 'Introduction to Attic Greek  (Using marcxml) /');

    $t->put_ok("//$userid:$password@/api/v1/biblios/$biblionumber" => {'Content-Type' => 'application/marc-in-json', 'x-framework-id' => $frameworkcode} => $mij)
      ->status_is(200)
      ->json_has('/id');

    $biblio = Koha::Biblios->find($biblionumber);

    is($biblio->title, 'Introduction to Attic Greek  (Using mij) /');

    $t->put_ok("//$userid:$password@/api/v1/biblios/$biblionumber" => {'Content-Type' => 'application/marc', 'x-framework-id' => $frameworkcode} => $marc)
      ->status_is(200)
      ->json_has('/id');

    $biblio = Koha::Biblios->find($biblionumber);

    is($biblio->title, 'Introduction to Attic Greek  (Using usmarc) /');

    $schema->storage->txn_rollback;
};

subtest 'list() tests' => sub {

    plan tests => 15;

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

    t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');

    my $title_with_diacritics = "L'insoutenable légèreté de l'être";
    my $biblio = $builder->build_sample_biblio(
        {
            title  => $title_with_diacritics,
            author => "Milan Kundera"
        }
    );

    my $record = $biblio->metadata->record;
    $record->leader('     nam         3  4500');
    $biblio->metadata->metadata($record->as_xml_record('UNIMARC'))->store;

    my $biblionumber1 = $biblio->biblionumber;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $biblionumber2 = $builder->build_sample_biblio->biblionumber;

    my $search =
"[{\"biblionumber\": \"$biblionumber1\"}, {\"biblionumber\": \"$biblionumber2\"}]";
    $t->get_ok(
        "//$userid:$password@/api/v1/biblios/" => { 'x-koha-query' => $search }
    )->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'application/weird+format', 'x-koha-query' => $search } )
      ->status_is(400, 'Status is 400 for bad format');

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'application/json', 'x-koha-query' => $search } )
      ->status_is(200, 'Status is 200 for application/json');

    my $result = $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'application/marcxml+xml', 'x-koha-query' => $search } )
      ->status_is(200, 'Status is 200 for application/marcxml+xml')->tx->res->body;

    my $encoded_title  = Encode::encode( "UTF-8", $title_with_diacritics );
    like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'application/marc-in-json', 'x-koha-query' => $search } )
      ->status_is(200, 'Status is 200 for application/marc-in-json');

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'application/marc', 'x-koha-query' => $search } )
      ->status_is(200, 'Status is 200 for application/marc');

    $t->get_ok( "//$userid:$password@/api/v1/biblios/" =>
          { Accept => 'text/plain', 'x-koha-query' => $search } )
      ->status_is(200, 'Status is 200 for text/plain');

    $schema->storage->txn_rollback;
};
