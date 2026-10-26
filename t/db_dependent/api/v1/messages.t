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
use Test::More tests => 7;
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

    plan tests => 32;

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
        {
            class => 'Koha::Patron::Messages',
            value => { borrowernumber => $patron->borrowernumber, message_type => 'L' }
        }
    );

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
        {
            class => 'Koha::Patron::Messages',
            value => { borrowernumber => $patron->borrowernumber, message_type => 'B' }
        }
    );

    # Two messages created, they should both be returned
    my $res2 = $t->get_ok("//$userid:$password@/api/v1/messages")->status_is(200)->tx->res->json;

    is( scalar @{$res2}, 3, 'Three messages returned' );

    # Filtering works, two messages sharing message_type
    my $res3 =
        $t->get_ok( "//$userid:$password@/api/v1/messages?message_type=" . $message->message_type )
        ->status_is(200)
        ->tx->res->json;

    is( scalar @{$res3}, 2, 'Two messages returned' );

    my $res4 =
        $t->get_ok( "//$userid:$password@/api/v1/messages?message=" . $message->message )
        ->status_is(200)
        ->tx->res->json;

    is( scalar @{$res4}, 1, 'One message returned' );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/messages?message_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/message_blah', message => 'Malformed query string' } ] );

    # Pagination and sorting
    $t->get_ok("//$userid:$password@/api/v1/messages?_page=1&_per_page=2&_order_by=-message_id")
        ->status_is(200)
        ->header_is( 'X-Total-Count' => 3 )
        ->json_is( '/0/message_id' => $message_with_another_message_type->id );

    is( scalar @{ $t->tx->res->json }, 2, 'Pagination is honored' );

    # q parameter
    $t->get_ok( "//$userid:$password@/api/v1/messages?q={\"message_id\":" . $another_message->id . "}" )
        ->status_is(200)
        ->json_is( '/0/message_id' => $another_message->id );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/messages")->status_is(403);

    # view_borrower_infos_from_any_libraries alone is not enough
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 4,
                code           => 'view_borrower_infos_from_any_libraries',
            },
        }
    );
    $t->get_ok("//$unauth_userid:$password@/api/v1/messages")->status_is(403);

    # Unauthenticated access
    $t->get_ok("/api/v1/messages")->status_is(401);

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

    $t->get_ok("//$userid:$password@/api/v1/messages/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Message not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 46;

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

    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message_with_invalid_field )
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
    my $message_id =
        $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )
        ->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/messages/\d*|,
        'SWAGGER3.4.1'
        )
        ->json_is( '/patron_id'    => $message->{patron_id} )
        ->json_is( '/library_id'   => $message->{library_id} )
        ->json_is( '/message_type' => $message->{message_type} )
        ->json_is( '/message'      => $message->{message} )
        ->json_is( '/manager_id'   => $librarian->borrowernumber )
        ->tx->res->json->{message_id};

    # Authorized attempt to write with manager_id defined
    $message->{manager_id} = $message->{patron_id};
    $message_id =
        $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )
        ->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/messages/\d*|,
        'SWAGGER3.4.1'
        )
        ->json_is( '/patron_id'    => $message->{patron_id} )
        ->json_is( '/library_id'   => $message->{library_id} )
        ->json_is( '/message_type' => $message->{message_type} )
        ->json_is( '/message'      => $message->{message} )
        ->json_is( '/manager_id'   => $message->{patron_id} )
        ->tx->res->json->{message_id};

    # Authorized attempt to create with null id
    $message->{message_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $message->{message_id} = $message_id;
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => $message )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/message_id"
            }
        ]
    );
    delete $message->{message_id};

    # Invalid message_type
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => { %{$message}, message_type => 'Z' } )
        ->status_is(400)
        ->json_is( '/errors/0/path' => '/body/message_type' );

    # Empty message
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => { %{$message}, message => '' } )
        ->status_is(400)
        ->json_is( '/errors/0/path' => '/body/message' );

    my $deleted_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted_patron_id = $deleted_patron->id;
    $deleted_patron->delete;

    # Non-existent patron
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => { %{$message}, patron_id => $deleted_patron_id } )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_patron_id' );

    # Non-existent manager
    warning_like {
        $t->post_ok(
            "//$userid:$password@/api/v1/messages" => json => { %{$message}, manager_id => $deleted_patron_id } )
            ->status_is(400)
            ->json_is( '/error_code' => 'invalid_manager_id' );
    }
    qr/Broken FK constraint/;

    my $deleted_library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $deleted_library_id = $deleted_library->id;
    $deleted_library->delete;

    # Non-existent library
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => { %{$message}, library_id => $deleted_library_id } )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_library_id' );

    # null library_id defaults to the logged in user library
    $t->post_ok( "//$userid:$password@/api/v1/messages" => json => { %{$message}, library_id => undef } )
        ->status_is(201)
        ->json_is( '/library_id' => $librarian->branchcode );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

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
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/message_type" } ] );

    my $message_with_empty_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_empty_field )
        ->status_is(400)
        ->json_is( '/errors/0/path' => '/body/message_type' );

    my $message_with_null_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => undef,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_null_field )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_library_id' );

    # Full object update on PUT
    my $message_with_updated_field = {
        patron_id    => $patron->borrowernumber,
        library_id   => $patron->branchcode,
        message_type => "B",
        message      => "Old Fox jumped over Cheeseboy",
        manager_id   => $librarian->borrowernumber
    };

    $t->put_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => $message_with_updated_field )
        ->status_is(200)
        ->json_is( '/message' => 'Old Fox jumped over Cheeseboy' );

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
        ->status_is(400)
        ->json_is(
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
        ->status_is(200)
        ->json_is( '/message' => 'Young Fox jumped over Cheeseboy' );

    my $deleted_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted_patron_id = $deleted_patron->id;
    $deleted_patron->delete;

    $t->patch_ok( "//$userid:$password@/api/v1/messages/$message_id" => json => { patron_id => $deleted_patron_id } )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_patron_id' );

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

subtest 'library restrictions tests' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'AllowAllMessageDeletion', 0 );

    my $library       = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );

    # Librarians in $library can only see patrons from their group
    my $group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { ft_hide_patron_info => 1, branchcode => undef, parent_id => undef }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { parent_id => $group->id, branchcode => $library->id }
        }
    );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $library->id }
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

    my $visible_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library->id } } );
    my $hidden_patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $other_library->id } } );

    my $visible_message = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { borrowernumber => $visible_patron->id, branchcode => $library->id }
        }
    );
    my $hidden_message = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { borrowernumber => $hidden_patron->id, branchcode => $library->id }
        }
    );
    my $other_library_message = $builder->build_object(
        {
            class => 'Koha::Patron::Messages',
            value => { borrowernumber => $visible_patron->id, branchcode => $other_library->id }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/messages?q={\"patron_id\":{\"-in\":["
            . $visible_patron->id . ","
            . $hidden_patron->id
            . "]}}" )->status_is(200);
    is_deeply(
        [ sort map { $_->{message_id} } @{ $t->tx->res->json } ],
        [ sort ( $visible_message->id, $other_library_message->id ) ],
        'Only messages for visible patrons are listed'
    );

    $t->get_ok( "//$userid:$password@/api/v1/messages/" . $hidden_message->id )->status_is(404);

    # Cannot create or move messages to patrons the user cannot see
    $t->post_ok(
        "//$userid:$password@/api/v1/messages" => json => {
            patron_id    => $hidden_patron->id,
            message_type => 'L',
            message      => 'Sneaky'
        }
    )->status_is(400)->json_is( '/error_code' => 'invalid_patron_id' );

    $t->patch_ok(
        "//$userid:$password@/api/v1/messages/" . $visible_message->id => json => { patron_id => $hidden_patron->id } )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_patron_id' );

    # AllowAllMessageDeletion disabled: only messages from the user library can be modified
    $t->patch_ok(
        "//$userid:$password@/api/v1/messages/" . $other_library_message->id => json => { message => 'Nope' } )
        ->status_is(404);
    $t->delete_ok( "//$userid:$password@/api/v1/messages/" . $other_library_message->id )->status_is(404);

    # AllowAllMessageDeletion enabled
    t::lib::Mocks::mock_preference( 'AllowAllMessageDeletion', 1 );

    $t->patch_ok( "//$userid:$password@/api/v1/messages/" . $other_library_message->id => json => { message => 'Yes' } )
        ->status_is(200)
        ->json_is( '/message' => 'Yes' );
    $t->delete_ok( "//$userid:$password@/api/v1/messages/" . $other_library_message->id )->status_is(204);

    # Messages for patrons the user cannot see are never reachable
    $t->delete_ok( "//$userid:$password@/api/v1/messages/" . $hidden_message->id )->status_is(404);

    $schema->storage->txn_rollback;
};
