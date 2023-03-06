#!/usr/bin/env perl

# Copyright 2016 Koha-Suomi
#
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
use Test::MockModule;
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

    my $item   = $builder->build_sample_item;
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );

    # Make sure we have at least 10 items
    for ( 1..10 ) {
        $builder->build_sample_item;
    }

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

    $t->get_ok( "//$userid:$password@/api/v1/items?_per_page=10" )
      ->status_is( 200, 'SWAGGER3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };

    is( $response_count, 10, 'The API returns 10 items' );

    $t->get_ok( "//$userid:$password@/api/v1/items?external_id=" . $item->barcode )
      ->status_is(200)
      ->json_is( '' => [ $item->to_api ], 'SWAGGER3.3.2');

    my $barcode = $item->barcode;
    $item->delete;

    $t->get_ok( "//$userid:$password@/api/v1/items?external_id=" . $item->barcode )
      ->status_is(200)
      ->json_is( '' => [] );

    $schema->storage->txn_rollback;
};

subtest 'list_public() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # Clean out all demo items
    Koha::Items->delete();

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $mocked_category = Test::MockModule->new('Koha::Patron::Category');
    my $exception = 1;
    $mocked_category->mock( 'override_hidden_items', sub {
        return $exception;
    });

    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # have a fresh biblio
    my $biblio = $builder->build_sample_biblio;
    # have two itemtypes
    my $itype_1 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itype_2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    # have 5 items on that biblio
    my $item_1 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => -1,
            itype        => $itype_1->itemtype,
            withdrawn    => 1,
            copynumber   => undef
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 2,
            copynumber   => undef
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 1,
            itype        => $itype_1->itemtype,
            withdrawn    => 3,
            copynumber   => undef
        }
    );
    my $item_4 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_2->itemtype,
            withdrawn    => 4,
            copynumber   => undef
        }
    );
    my $item_5 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 0,
            itype        => $itype_1->itemtype,
            withdrawn    => 5,
            copynumber   => undef
        }
    );
    my $item_6 = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            itemlost     => 2,
            itype        => $itype_1->itemtype,
            withdrawn    => 5,
            copynumber   => undef
        }
    );

    my $rules = undef;
    my $mocked_context = Test::MockModule->new('C4::Context');
    $mocked_context->mock( 'yaml_preference', sub {
        return $rules;
    });

    subtest 'anonymous access' => sub {
        plan tests => 21;

        t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
        my $res = $t->get_ok( "/api/v1/public/items" )->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 6, 'No rules set, hidelostitems unset, all items returned');

        t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
        $res = $t->get_ok( "/api/v1/public/items" )->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 3, 'No rules set, hidelostitems set, 3 items hidden');

        t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
        $rules = { biblionumber => [ $biblio->biblionumber ] };
        $res = $t->get_ok( "/api/v1/public/items" )->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 0, 'Biblionumber rule set, hidelostitems unset, all items hidden');

        $rules = { withdrawn => [ 1, 2 ] };
        $res = $t->get_ok( "/api/v1/public/items" )->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 4, 'Withdrawn rule set, hidelostitems unset, 2 items hidden');

        $rules = { itype => [ $itype_1->itemtype ] };
        $res = $t->get_ok( "/api/v1/public/items" )->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 2, 'Itype rule set, hidelostitems unset, 4 items hidden');

        $rules = { withdrawn => [ 1 ] };
        $res = $t->get_ok( "/api/v1/public/items?external_id=" . $item_1->barcode )
          ->status_is(200)->tx->res->json;
        is( scalar @{ $res }, 0, 'Withdrawn rule set, hidelostitems unset, search on barcode returns no item');

        $rules = undef;
        $t->get_ok( "/api/v1/public/items?external_id=" . $item_1->barcode )
          ->status_is(200)->json_is(
            '/0' => $item_1->to_api( { public => 1 } ),
'No rules set, hidelostitems unset, public form of item returned on barcode search'
          );
    };

    subtest 'logged in user access' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
        $rules = { withdrawn => [ 1, 2 ] };
        my $res = $t->get_ok("//$userid:$password@/api/v1/public/items")
          ->status_is(200)->tx->res->json;
        is(
            scalar @{$res},
            3,
'Rules on withdrawn but patron with override passed, hidelostitems set'
        );
    };

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 30;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item;
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
      ->json_is( '' => $item->to_api, 'SWAGGER3.3.2' );

    my $non_existent_code = $item->itemnumber;
    $item->delete;

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $non_existent_code )
      ->status_is(404)
      ->json_is( '/error' => 'Item not found' );

    t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );

    my $biblio = $builder->build_sample_biblio;
    my $itype =
      $builder->build_object( { class => 'Koha::ItemTypes' } );
    $item = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, itype => $itype->itemtype } );

    isnt( $biblio->itemtype, $itype->itemtype, "Test biblio level itemtype and item level itemtype do not match");

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '/item_type_id' => $itype->itemtype, 'item-level_itypes:0' )
      ->json_is( '/effective_item_type_id' => $biblio->itemtype, 'item-level_itypes:0' );

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '/item_type_id' => $itype->itemtype, 'item-level_itype:1' )
      ->json_is( '/effective_item_type_id' => $itype->itemtype, 'item-level_itypes:1' );


    my $biblio_itype = Koha::ItemTypes->find($biblio->itemtype);
    $biblio_itype->notforloan(3)->store();
    $itype->notforloan(2)->store();
    $item->notforloan(1)->store();

    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '/not_for_loan_status' => 1, 'not_for_loan_status is 1' )
      ->json_is( '/effective_not_for_loan_status' => 1, 'effective_not_for_loan_status picks up item level' );

    $item->notforloan(0)->store();
    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '/not_for_loan_status' => 0, 'not_for_loan_status is 0' )
      ->json_is( '/effective_not_for_loan_status' => 2, 'effective_not_for_loan_status now picks up itemtype level - item-level_itypes:1' );

    t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );
    $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->itemnumber )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '/not_for_loan_status' => 0, 'not_for_loan_status is 0' )
      ->json_is( '/effective_not_for_loan_status' => 3, 'effective_not_for_loan_status now picks up itemtype level - item-level_itypes:0' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    my $fail = 0;
    my $expected_error;

    # we want to control all the safe_to_delete use cases
    my $item_class = Test::MockModule->new('Koha::Item');
    $item_class->mock( 'safe_to_delete', sub {
        if ( $fail ) {
            return Koha::Result::Boolean->new(0)->add_message({ message => $expected_error });
        }
        else {
            return Koha::Result::Boolean->new(1);
        }
    });

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**9 }    # catalogue flag = 2
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $item = $builder->build_sample_item;

    my $errors = {
        book_on_loan       => { code => 'checked_out',        description => 'The item is checked out' },
        book_reserved      => { code => 'found_hold',         description => 'Waiting or in-transit hold for the item' },
        last_item_for_hold => { code => 'last_item_for_hold', description => 'The item is the last one on a record on which a biblio-level hold is placed' },
        linked_analytics   => { code => 'linked_analytics',   description => 'The item has linked analytic records' },
        not_same_branch    => { code => 'not_same_branch',    description => 'The item is blocked by independent branches' },
    };

    $fail = 1;

    foreach my $error_code ( keys %{$errors} ) {

        $expected_error = $error_code;

        $t->delete_ok( "//$userid:$password@/api/v1/items/" . $item->id )
          ->status_is(409)
          ->json_is(
            { error      => $errors->{$error_code}->{description},
              error_code => $errors->{$error_code}->{code},
            }
        );
    }

    $expected_error = 'unknown_error';
    $t->delete_ok( "//$userid:$password@/api/v1/items/" . $item->id )
      ->status_is(500, 'unhandled error case generated default unhandled exception message')
      ->json_is(
        { error      => 'Something went wrong, check Koha logs for details.',
          error_code => 'internal_server_error',
        }
    );

    $fail = 0;

    $t->delete_ok("//$userid:$password@/api/v1/items/" . $item->id)
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok("//$userid:$password@/api/v1/items/" . $item->id)
      ->status_is(404);

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

    my $item = $builder->build_sample_item();

    my $item_class = Test::MockModule->new('Koha::Item');
    $item_class->mock(
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

    $t->get_ok( "//$userid:$password@/api/v1/items/"
          . $item->id
          . "/pickup_locations?patron_id=" . $patron->id )
      ->json_is( [ $library_1_api, $library_2_api ] );

    # filtering works!
    $t->get_ok( "//$userid:$password@/api/v1/items/"
          . $item->id
          . '/pickup_locations?'
          . 'patron_id=' . $patron->id . '&q={"marc_org_code": { "-like": "A%" }}' )
      ->json_is( [ $library_1_api ] );

    t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

    my $library_4 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 0, marcorgcode => 'X' } });
    my $library_5 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1, marcorgcode => 'Y' } });

    my $library_5_api = $library_5->to_api();
    $library_5_api->{needs_override} = Mojo::JSON->true;

    $t->get_ok( "//$userid:$password@/api/v1/items/"
          . $item->id
          . "/pickup_locations?"
          . "patron_id=" . $patron->id . "&_order_by=marc_org_code" )
      ->json_is( [ $library_1_api, $library_2_api, $library_3_api, $library_5_api ] );

    subtest 'Pagination and AllowHoldPolicyOverride tests' => sub {

        plan tests => 27;

        t::lib::Mocks::mock_preference( 'AllowHoldPolicyOverride', 1 );

        $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->id . "/pickup_locations?" . "patron_id=" . $patron->id . "&_order_by=marc_org_code" . "&_per_page=1" )
          ->json_is( [$library_1_api] )
          ->header_is( 'X-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_is( 'X-Base-Total-Count', '4', '4 is the count for libraries with pickup_location=1' )
          ->header_unlike( 'Link', qr|rel="prev"| )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=2.*|_page=2.*\&_per_page=1.*)>\; rel="next"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=1.*|_page=1.*\&_per_page=1).*>\; rel="first"# )
          ->header_like( 'Link', qr#(_per_page=1.*\&_page=4.*|_page=4.*\&_per_page=1).*>\; rel="last"# );

        $t->get_ok( "//$userid:$password@/api/v1/items/"
              . $item->id
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

        $t->get_ok( "//$userid:$password@/api/v1/items/" . $item->id . "/pickup_locations?" . "patron_id=" . $patron->id . "&_order_by=marc_org_code" . "&_per_page=1" )
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

    $t->get_ok( "//$userid:$password@/api/v1/items/"
          . $item->id
          . "/pickup_locations?"
          . "patron_id=" . $deleted_patron_id )
      ->status_is( 400 )
      ->json_is( '/error' => 'Patron not found' );

    $item->delete;

    $t->get_ok( "//$userid:$password@/api/v1/items/"
          . $item->id
          . "/pickup_locations?"
          . "patron_id=" . $patron->id )
      ->status_is( 404 )
      ->json_is( '/error' => 'Item not found' );

    $schema->storage->txn_rollback;
};
