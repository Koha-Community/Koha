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
use Test::More tests => 6;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Patron::Messages;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::Patron::Messages->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    for my $permission (qw(list_borrowers edit_borrowers)) {
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => $permission,
                },
            }
        );
    }

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $librarian->branchcode }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    ## Authorized user tests
    # No messages, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/messages")->status_is(200)->json_is( [] );

    my $message = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $patron->borrowernumber } } );

    # One message created, should get returned
    my $res = $t->get_ok("//$userid:$password@/api/v1/messages")->status_is(200)->tx->res->json;

    is( scalar @{$res}, 1, 'One message returned' );

    my $another_message = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { message_type => $message->message_type, borrowernumber => $patron->borrowernumber }
        }
    );
    my $message_with_another_message_type = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $patron->borrowernumber } } );

    # Two messages created, they should both be returned
    my $res2 = $t->get_ok("//$userid:$password@/api/v1/messages")->status_is(200)->tx->res->json;

    is( scalar @{$res2}, 3, 'Three messages returned' );

    # Filtering works, two messages sharing message_type
    my $res3 =
        $t->get_ok( "//$userid:$password@/api/v1/messages?message_type=" . $message->message_type )->status_is(200)
        ->tx->res->json;

    is( scalar @{$res3}, 2, 'Two messages returned' );

    my $res4 =
        $t->get_ok( "//$userid:$password@/api/v1/messages?message=" . $message->message )->status_is(200)
        ->tx->res->json;

    is( scalar @{$res4}, 1, 'One message returned' );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/messages?message_blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/message_blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/messages")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    for my $permission (qw(list_borrowers edit_borrowers)) {
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => $permission,
                },
            }
        );
    }

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $librarian->branchcode }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $message = $builder->build_object(
        { class => 'Koha::Patron::Messages', value => { borrowernumber => $patron->borrowernumber } } );

    my $res =
        $t->get_ok( "//$userid:$password@/api/v1/messages/" . $message->message_id )->status_is(200)->tx->res->json;

    is( $res->{message_id}, $message->message_id, 'message_id matches' );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/messages/" . $message->message_id )->status_is(403);

    my $message_to_delete = $builder->build_object( { class => 'Koha::Patron::Messages' } );
    my $non_existent_id   = $message_to_delete->id;
    $message_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/messages/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'Message not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 27;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    for my $permission (qw(list_borrowers edit_borrowers)) {
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => $permission,
                },
            }
        );
    }

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $librarian->branchcode }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $message = {
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy"
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/messages" => json => $message )->status_is(403);

    # Authorized attempt to write invalid data
    my $message_with_invalid_field = {
        blah         => "message Blah",
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message_with_invalid_field )->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $message_id =
        $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/messages/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/patron_id' => $message->{patron_id} )->json_is( '/library_id' => $message->{library_id} )
        ->json_is( '/message_type' => $message->{message_type} )->json_is( '/message' => $message->{message} )
        ->json_is( '/manager_id'   => $librarian->borrowernumber )->tx->res->json->{message_id};

    # Authorized attempt to write with manager_id defined
    $message->{manager_id} = $message->{patron_id};
    $message_id =
        $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/messages/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/patron_id' => $message->{patron_id} )->json_is( '/library_id' => $message->{library_id} )
        ->json_is( '/message_type' => $message->{message_type} )->json_is( '/message' => $message->{message} )
        ->json_is( '/manager_id'   => $message->{patron_id} )->tx->res->json->{message_id};

    # Authorized attempt to create with null id
    $message->{message_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $message->{message_id} = $message_id;
    warnings_like {
        $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is(409);
    }
    qr/Duplicate ID/;

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    for my $permission (qw(list_borrowers edit_borrowers)) {
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => $permission,
                },
            }
        );
    }

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $librarian->branchcode }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $message_id = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { branchcode => $librarian->branchcode, borrowernumber => $patron->borrowernumber }
        }
    )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/messages/$message_id" => json => {
            message      => 'New unauthorized name change',
            message_type => 'B',
            patron_id    => $unauth_userid,
        }
    )->status_is(403);

    # Attempt partial update on a PUT
    my $message_with_missing_field = {
        patron_id  => $patron->borrowernumber,
        library_id => $patron->branchcode,
        message    => "Old Fox jumped over Cheeseboy",
        manager_id => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/message_type" } ] );

    my $message_with_empty_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_empty_field )
        ->status_is(400)->json_is( '/error' => "message_type cannot be empty" );

    my $message_with_null_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => undef,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_null_field )
        ->status_is(400)->json_is( '/error' => "library_id cannot be empty" );

    # Full object update on PUT
    my $message_with_updated_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_updated_field )
        ->status_is(200)->json_is( '/message' => 'Old Fox jumped over Cheeseboy' );

    # Authorized attempt to write invalid data
    my $message_with_invalid_field = {
        blah         => "message Blah",
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    my $message_to_delete = $builder->build_object( { class => 'Koha::Patron::Messages' } );
    my $non_existent_id   = $message_to_delete->id;
    $message_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/messages/$non_existent_id" => json => $message_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $message_with_updated_field->{message_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_updated_field )
        ->status_is(404);

    # Partual update on a PATCH
    my $message_with_some_updates = { message => "Young Fox jumped over Cheeseboy" };

    $t->patch_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_some_updates )
        ->status_is(200)->json_is( '/message' => 'Young Fox jumped over Cheeseboy' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    for my $permission (qw(list_borrowers edit_borrowers)) {
        $builder->build(
            {
                source => 'UserPermission',
                value  => {
                    borrowernumber => $librarian->borrowernumber,
                    module_bit     => 4,
                    code           => $permission,
                },
            }
        );
    }

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $librarian->branchcode }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $message_id = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { branchcode => $librarian->branchcode, borrowernumber => $patron->borrowernumber }
        }
    )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/messages/$message_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/messages/$message_id")->status_is(204)->content_is('');

    $t->delete_ok("//$userid:$password@/api/v1/messages/$message_id")->status_is(404);

    $schema->storage->txn_rollback;
};
