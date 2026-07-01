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
use Test::More tests => 9;
use Test::Mojo;
use Test::MockModule;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON qw(encode_json);

use Koha::Bookings;
use Koha::Database;
use Koha::DateUtils qw (dt_from_string output_pref);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::Bookings->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/bookings")->status_is(403);

    ## Authorized user tests
    # No bookings, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/bookings")->status_is(200)->json_is( [] );

    # One booking
    my $start_0   = dt_from_string->subtract( days => 2 )->truncate( to => 'day' );
    my $end_0     = dt_from_string->add( days => 4 )->truncate( to => 'day' );
    my $booking_0 = $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                start_date => $start_0,
                end_date   => $end_0
            }
        }
    );

    $t->get_ok("//$userid:$password@/api/v1/bookings")->status_is(200)->json_is( [ $booking_0->to_api ] );

    # More bookings
    my $start_1   = dt_from_string->add( days => 1 )->truncate( to => 'day' );
    my $end_1     = dt_from_string->add( days => 6 )->truncate( to => 'day' );
    my $booking_1 = $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                start_date => $start_1,
                end_date   => $end_1
            }
        }
    );

    my $start_2   = dt_from_string->add( days => 4 )->truncate( to => 'day' );
    my $end_2     = dt_from_string->add( days => 8 )->truncate( to => 'day' );
    my $booking_2 = $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                start_date => $start_2,
                end_date   => $end_2
            }
        }
    );

    # No filtering
    $t->get_ok("//$userid:$password@/api/v1/bookings")->status_is(200)->json_is(
        '' => [
            $booking_0->to_api,
            $booking_1->to_api,
            $booking_2->to_api
        ],
        'unfiltered returns all bookings'
    );

    # Filtering works, two bookings after today
    my $api_filter = encode_json(
        { 'me.start_date' => { '>=' => output_pref( { dateformat => "rfc3339", dt => dt_from_string } ) } } );
    $t->get_ok("//$userid:$password@/api/v1/bookings?q=$api_filter")->status_is(200)->json_is(
        '' => [
            $booking_1->to_api,
            $booking_2->to_api
        ],
        'filtered returns two future bookings'
    );

    $api_filter = encode_json(
        { 'me.start_date' => { '<=' => output_pref( { dateformat => "rfc3339", dt => dt_from_string } ) } } );
    $t->get_ok("//$userid:$password@/api/v1/bookings?q=$api_filter")
        ->status_is(200)
        ->json_is( '' => [ $booking_0->to_api ], 'filtering to before today also works' );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/bookings?booking_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/booking_blah', message => 'Malformed query string' } ] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $booking   = $builder->build_object( { class => 'Koha::Bookings' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/bookings/" . $booking->booking_id )->status_is(403);

    # Authorized user tests
    $t->get_ok( "//$userid:$password@/api/v1/bookings/" . $booking->booking_id )
        ->status_is(200)
        ->json_is( $booking->to_api );

    my $booking_to_delete = $builder->build_object( { class => 'Koha::Bookings' } );
    my $non_existent_id   = $booking_to_delete->id;
    $booking_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/bookings/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Booking not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
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

    my $biblio         = $builder->build_sample_biblio;
    my $item1          = $builder->build_sample_item( { bookable => 1, biblionumber => $biblio->id } );
    my $item2          = $builder->build_sample_item( { bookable => 1, biblionumber => $biblio->id } );
    my $pickup_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $booking        = {
        biblio_id         => $biblio->id,
        item_id           => $item1->itemnumber,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/bookings" => json => $booking )->status_is(403);

    # Authorized attempt to write invalid data
    my $booking_with_invalid_field = { %{$booking}, blah => 'some stuff' };

    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_with_invalid_field )
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
    my $booking_id =
        $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like( Location => qr|^\/api\/v1\/bookings/\d*|, 'REST3.4.1' )
        ->json_is( '/biblio_id' => $biblio->id )
        ->tx->res->json->{booking_id};

    # Authorized attempt to create with null id
    $booking->{booking_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    # Use different dates to avoid triggering clash detection (we want to test duplicate ID handling)
    $booking->{booking_id} = $booking_id;
    $booking->{start_date} = output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 10 ) } );
    $booking->{end_date}   = output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 14 ) } );
    warnings_like {
        $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking )
            ->status_is(409)
            ->json_is( "/error" => "Duplicate booking_id" );
    }
    qr/DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key '(.*\.?)PRIMARY'/;

    # TODO: Test bookings clashes
    # TODO: Test item auto-assignment

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
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

    my $booking_id = $builder->build_object( { class => 'Koha::Bookings' } )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/bookings/$booking_id" => json => { name => 'New unauthorized name change' }
    )->status_is(403);

    my $biblio         = $builder->build_sample_biblio;
    my $item           = $builder->build_sample_item( { bookable => 1, biblionumber => $biblio->id } );
    my $pickup_library = $builder->build_object( { class => 'Koha::Libraries' } );

    # Attempt partial update on a PUT
    my $booking_with_missing_field = {
        item_id           => $item->itemnumber,
        patron_id         => $patron->id,
        pickup_library_id => $pickup_library->branchcode,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    $t->put_ok( "//$userid:$password@/api/v1/bookings/$booking_id" => json => $booking_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/biblio_id" } ] );

    # Full object update on PUT
    my $booking_with_updated_field = {
        biblio_id         => $biblio->id,
        item_id           => $item->itemnumber,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    $t->put_ok( "//$userid:$password@/api/v1/bookings/$booking_id" => json => $booking_with_updated_field )
        ->status_is(200)
        ->json_is( '/biblio_id' => $biblio->id );

    # Authorized attempt to write invalid data
    my $booking_with_invalid_field = {
        blah              => "Booking Blah",
        biblio_id         => $biblio->id,
        item_id           => $item->itemnumber,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    $t->put_ok( "//$userid:$password@/api/v1/bookings/$booking_id" => json => $booking_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    my $booking_to_delete = $builder->build_object( { class => 'Koha::Bookings' } );
    my $non_existent_id   = $booking_to_delete->id;
    $booking_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/bookings/$non_existent_id" => json => $booking_with_updated_field )
        ->status_is(404);

    # TODO: Test bookings clashes
    # TODO: Test item auto-assignment

    # Wrong method (POST)
    $booking_with_updated_field->{booking_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/bookings/$booking_id" => json => $booking_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
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

    my $booking_id = $builder->build_object( { class => 'Koha::Bookings' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/bookings/$booking_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/bookings/$booking_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/bookings/$booking_id")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'patch() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
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

    my $booking_id = $builder->build_object( { class => 'Koha::Bookings' } )->id;

    # Unauthorized attempt to partial update via PATCH
    $t->patch_ok( "//$unauth_userid:$password@/api/v1/bookings/$booking_id" => json => { status => 'cancelled' } )
        ->status_is(403);

    my $biblio         = $builder->build_sample_biblio;
    my $item           = $builder->build_sample_item( { bookable => 1, biblionumber => $biblio->id } );
    my $pickup_library = $builder->build_object( { class => 'Koha::Libraries' } );

    # Authorized attempt to write invalid data
    my $booking_with_invalid_field = {
        blah => "Booking Blah",
    };

    $t->patch_ok( "//$userid:$password@/api/v1/bookings/$booking_id" => json => $booking_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    $schema->storage->txn_rollback;
};

subtest 'add() with itemtype_id tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
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

    # Create itemtype and items
    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $biblio   = $builder->build_sample_biblio;
    my $item1    = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            bookable     => 1,
            itype        => $itemtype->itemtype
        }
    );
    my $item2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            bookable     => 1,
            itype        => $itemtype->itemtype
        }
    );

    my $pickup_library = $builder->build_object( { class => 'Koha::Libraries' } );

    # Test 1: Booking with itemtype_id instead of item_id should work
    my $booking_with_itemtype = {
        biblio_id         => $biblio->id,
        itemtype_id       => $itemtype->itemtype,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    my $tx =
        $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_with_itemtype )
        ->status_is( 201, 'Created booking with itemtype_id' )
        ->json_has( '/item_id', 'Server assigned an item_id' )
        ->json_is( '/biblio_id' => $biblio->id );

    my $assigned_item_id = $tx->tx->res->json->{item_id};
    ok(
        $assigned_item_id == $item1->itemnumber || $assigned_item_id == $item2->itemnumber,
        'Assigned item is one of the items of the specified itemtype'
    );

    # Test 2: Booking with both item_id and itemtype_id should fail
    my $booking_with_both = {
        biblio_id         => $biblio->id,
        item_id           => $item1->itemnumber,
        itemtype_id       => $itemtype->itemtype,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 10 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 14 ) } ),
    };

    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_with_both )
        ->status_is(400)
        ->json_is( '/error' => 'Cannot specify both item_id and itemtype_id' );

    # Test 3: Booking with neither item_id nor itemtype_id should fail
    my $booking_with_neither = {
        biblio_id         => $biblio->id,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 20 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 24 ) } ),
    };

    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_with_neither )
        ->status_is(400)
        ->json_is( '/error' => 'Either item_id or itemtype_id must be provided' );

    # Test 4: Verify optimal selection - book all items, then try to book again
    # Book item2 for the same period as the first booking
    my $booking_item2 = {
        biblio_id         => $biblio->id,
        item_id           => $item2->itemnumber,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 2 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 6 ) } ),
    };

    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_item2 )->status_is(201);

    # Now try to create another booking with itemtype_id for the same period
    # Should fail since both items are booked
    my $booking_should_fail = {
        biblio_id         => $biblio->id,
        itemtype_id       => $itemtype->itemtype,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 3 ) } ),
        end_date          => output_pref( { dateformat => "rfc3339", dt => dt_from_string->add( days => 5 ) } ),
    };

    $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking_should_fail )
        ->status_is(400)
        ->json_is( '/error' => 'Booking would conflict' );

    $schema->storage->txn_rollback;
};

subtest 'add() applies the library timezone to start_date/end_date (Bug 42868)' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    # Regression test for Bug 42868: the API converts the incoming RFC3339
    # instant to C4::Context->tz before storing it in the timezone-naive
    # 'datetime' column (see Koha::Object::_recursive_fixup), so a client
    # must anchor day boundaries to the library's configured timezone, not
    # UTC, or the stored date shifts whenever that timezone isn't UTC.
    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'tz', sub { 'America/New_York' } );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }     # no additional permissions
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $librarian->borrowernumber,
                module_bit     => 1,
                code           => 'manage_bookings',
            },
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $biblio         = $builder->build_sample_biblio;
    my $item           = $builder->build_sample_item( { bookable => 1, biblionumber => $biblio->id } );
    my $pickup_library = $builder->build_object( { class => 'Koha::Libraries' } );

    # 2026-07-01T00:00:00 and 2026-07-01T23:59:59 in America/New_York (EDT, UTC-4) -
    # exactly what place_booking.js sends via dayjs.tz(date, $timezone()).
    my $booking = {
        biblio_id         => $biblio->id,
        item_id           => $item->itemnumber,
        pickup_library_id => $pickup_library->branchcode,
        patron_id         => $patron->id,
        start_date        => '2026-07-01T04:00:00Z',
        end_date          => '2026-07-02T03:59:59Z',
    };

    my $booking_id =
        $t->post_ok( "//$userid:$password@/api/v1/bookings" => json => $booking )
        ->status_is(201)
        ->tx->res->json->{booking_id};

    my ( $start_date, $end_date ) = $schema->storage->dbh->selectrow_array(
        q{SELECT start_date, end_date FROM bookings WHERE booking_id = ?},
        undef, $booking_id
    );

    is(
        $start_date, '2026-07-01 00:00:00',
        'start_date is stored as library-local midnight, not shifted by the UTC offset'
    );
    is(
        $end_date, '2026-07-01 23:59:59',
        'end_date is stored as library-local end of day, not shifted by the UTC offset'
    );

    $context->unmock('tz');

    $schema->storage->txn_rollback;
};
