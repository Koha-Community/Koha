#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
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

use Koha::AdvancedEditorMacros;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

subtest 'list() tests' => sub {
    plan tests => 8;

    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 9 }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );
    my $password = 'thePassword123';
    $patron_1->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron_1->userid;

    # Create test context
    my $macro_1 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                name           => 'Test1',
                macro          => 'delete 100',
                borrowernumber => $patron_1->borrowernumber,
                shared         => 0,
            }
        }
    );
    my $macro_2 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                name           => 'Test2',
                macro          => 'delete 100',
                borrowernumber => $patron_1->borrowernumber,
                shared         => 1,
            }
        }
    );
    my $macro_3 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                name           => 'Test3',
                macro          => 'delete 100',
                borrowernumber => $patron_2->borrowernumber,
                shared         => 0,
            }
        }
    );
    my $macro_4 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                name           => 'Test4',
                macro          => 'delete 100',
                borrowernumber => $patron_2->borrowernumber,
                shared         => 1,
            }
        }
    );

    my $macros_index =
        Koha::AdvancedEditorMacros->search( { -or => { shared => 1, borrowernumber => $patron_1->borrowernumber } } )
        ->count - 1;
    ## Authorized user tests
    # Make sure we are returned with the correct amount of macros
    $t->get_ok("//$userid:$password@/api/v1/advanced_editor/macros")
        ->status_is( 200, 'REST3.2.2' )
        ->json_has( '/' . $macros_index . '/macro_id' )
        ->json_hasnt( '/' . ( $macros_index + 1 ) . '/macro_id' );

    subtest 'query parameters' => sub {

        plan tests => 15;
        $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros?name=" . $macro_2->name )
            ->status_is(200)
            ->json_is( [ $macro_2->to_api ] );
        $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros?name=" . $macro_3->name )
            ->status_is(200)
            ->json_is( [] );
        $t->get_ok("//$userid:$password@/api/v1/advanced_editor/macros?macro_text=delete%20100")
            ->status_is(200)
            ->json_is( [ $macro_1->to_api, $macro_2->to_api, $macro_4->to_api ] );
        $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros?patron_id=" . $patron_1->borrowernumber )
            ->status_is(200)
            ->json_is( [ $macro_1->to_api, $macro_2->to_api ] );
        $t->get_ok("//$userid:$password@/api/v1/advanced_editor/macros?shared=1")
            ->status_is(200)
            ->json_is( [ $macro_2->to_api, $macro_4->to_api ] );
    };

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/advanced_editor/macros?macro_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/macro_blah', message => 'Malformed query string' } ] );

};

subtest 'get() tests' => sub {

    plan tests => 15;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $macro_1 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                shared => 1,
            }
        }
    );
    my $macro_2 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                shared => 0,
            }
        }
    );
    my $macro_3 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => {
                borrowernumber => $patron->borrowernumber,
                shared         => 0,
            }
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros/" . $macro_1->id )
        ->status_is( 403, 'Cannot get a shared macro via regular endpoint' )
        ->json_is( '/error' => 'This macro is shared, you must access it via advanced_editor/macros/shared' );

    $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros/shared/" . $macro_1->id )
        ->status_is( 200, 'Can get a shared macro via shared endpoint' )
        ->json_is( $macro_1->to_api );

    $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros/" . $macro_2->id )
        ->status_is( 403, 'Cannot access another users macro' )
        ->json_is( '/error' => 'You do not have permission to access this macro' );

    $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros/" . $macro_3->id )
        ->status_is( 200, 'Can get your own private macro' )
        ->json_is( $macro_3->to_api );

    my $non_existent_code = $macro_1->id;
    $macro_1->delete;

    $t->get_ok( "//$userid:$password@/api/v1/advanced_editor/macros/" . $non_existent_code )
        ->status_is(404)
        ->json_is( '/error' => 'Macro not found' );

};

subtest 'add() tests' => sub {

    plan tests => 24;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'advanced_editor',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $macro = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => { shared => 0 }
        }
    );
    my $macro_values = $macro->to_api;
    delete $macro_values->{macro_id};
    $macro->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_values )->status_is(403);

    # Authorized attempt to write invalid data
    my $macro_with_invalid_field = {%$macro_values};
    $macro_with_invalid_field->{'big_mac_ro'} = 'Mac attack';

    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: big_mac_ro.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_values )
        ->status_is( 201, 'REST3.2.1' )
        ->json_has( '/macro_id', 'We generated a new id' )
        ->json_is( '/name'       => $macro_values->{name},       'The name matches what we supplied' )
        ->json_is( '/macro_text' => $macro_values->{macro_text}, 'The text matches what we supplied' )
        ->json_is( '/patron_id'  => $macro_values->{patron_id},  'The borrower matches the borrower who submitted' )
        ->json_is( '/shared'     => Mojo::JSON->false,           'The macro is not shared' )
        ->header_like( Location => qr|^\/api\/v1\/advanced_editor/macros\/d*|, 'Correct location' );

    # save the library_id
    my $macro_id = 999;

    # Authorized attempt to create with existing id
    $macro_values->{macro_id} = $macro_id;

    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_values )
        ->status_is(400)
        ->json_is(
        '/errors' => [
            {
                message => "Read-only.",
                path    => "/body/macro_id"
            }
        ]
        );

    $macro_values->{shared} = Mojo::JSON->true;
    delete $macro_values->{macro_id};

    # Unauthorized attempt to write a shared macro on private endpoint
    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_values )->status_is(403);

    # Unauthorized attempt to write a private macro on shared endpoint
    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/shared" => json => $macro_values )
        ->status_is(403);

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'create_shared_macros',
            },
        }
    );

    # Authorized attempt to write a shared macro on private endpoint
    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros" => json => $macro_values )->status_is(403);

    # Authorized attempt to write a shared macro on shared endpoint
    $t->post_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/shared" => json => $macro_values )
        ->status_is(201);

};

subtest 'update() tests' => sub {
    plan tests => 32;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'advanced_editor',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $macro = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => { borrowernumber => $authorized_patron->borrowernumber, shared => 0 }
        }
    );
    my $macro_2 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => { borrowernumber => $unauthorized_patron->borrowernumber, shared => 0 }
        }
    );
    my $macro_id     = $macro->id;
    my $macro_2_id   = $macro_2->id;
    my $macro_values = $macro->to_api;
    delete $macro_values->{macro_id};

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/advanced_editor/macros/$macro_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $macro_with_missing_field = {
        name => "Call it macro-roni",
    };

    $t->put_ok(
        "//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_id" => json => $macro_with_missing_field )
        ->status_is(400)
        ->json_has( "/errors" => [ { message => "Missing property.", path => "/body/macro_text" } ] );

    my $macro_update = {
        name       => "Macro-update",
        macro_text => "delete 100",
        patron_id  => $authorized_patron->borrowernumber,
        shared     => Mojo::JSON->false,
    };

    my $test =
        $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_id" => json => $macro_update )
        ->status_is( 200, 'Authorized user can update a macro' )
        ->json_is( '/macro_id'   => $macro_id,                   'We get the id back' )
        ->json_is( '/name'       => $macro_update->{name},       'We get the name back' )
        ->json_is( '/macro_text' => $macro_update->{macro_text}, 'We get the text back' )
        ->json_is( '/patron_id'  => $macro_update->{patron_id},  'We get the patron_id back' )
        ->json_is( '/shared'     => $macro_update->{shared},     'It should still not be shared' );

    # Now try to make the macro shared
    $macro_update->{shared} = Mojo::JSON->true;

    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/shared/$macro_id" => json => $macro_update )
        ->status_is( 403, 'Cannot make your macro shared on private endpoint' );
    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/shared/$macro_id" => json => $macro_update )
        ->status_is( 403, 'Cannot make your macro shared without permission' );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'create_shared_macros',
            },
        }
    );

    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_id" => json => $macro_update )
        ->status_is( 403, 'Cannot make your macro shared on the private endpoint' );

    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/shared/$macro_id" => json => $macro_update )
        ->status_is( 200, 'Can update macro to shared with permission' )
        ->json_is( '/macro_id'   => $macro_id,                   'We get back the id' )
        ->json_is( '/name'       => $macro_update->{name},       'We get back the name' )
        ->json_is( '/macro_text' => $macro_update->{macro_text}, 'We get back the text' )
        ->json_is( '/patron_id'  => $macro_update->{patron_id},  'We get back our patron id' )
        ->json_is( '/shared'     => Mojo::JSON->true,            'It is shared' );

    # Authorized attempt to write invalid data
    my $macro_with_invalid_field = {%$macro_update};
    $macro_with_invalid_field->{'big_mac_ro'} = 'Mac attack';

    $t->put_ok(
        "//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_id" => json => $macro_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: big_mac_ro.",
                path    => "/body"
            }
        ]
        );

    my $non_existent_macro = $builder->build_object( { class => 'Koha::AdvancedEditorMacros' } );
    my $non_existent_code  = $non_existent_macro->id;
    $non_existent_macro->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/$non_existent_code" => json => $macro_update )
        ->status_is(404);

    $t->put_ok( "//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_2_id" => json => $macro_update )
        ->status_is( 403, "Cannot update other borrowers private macro" );
};

subtest 'delete() tests' => sub {
    plan tests => 12;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'advanced_editor',
            },
        }
    );

    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $macro = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => { borrowernumber => $authorized_patron->borrowernumber, shared => 0 }
        }
    );
    my $macro_2 = $builder->build_object(
        {
            class => 'Koha::AdvancedEditorMacros',
            value => { borrowernumber => $unauthorized_patron->borrowernumber, shared => 0 }
        }
    );
    my $macro_id   = $macro->id;
    my $macro_2_id = $macro_2->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/advanced_editor/macros/$macro_2_id")
        ->status_is( 403, "Cannot delete macro without permission" );

    $t->delete_ok("//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_id")
        ->status_is( 204, 'Can delete macro with permission' );

    $t->delete_ok("//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_2_id")
        ->status_is( 403, 'Cannot delete other users macro with permission' );

    $macro_2->shared(1)->store();

    $t->delete_ok("//$auth_userid:$password@/api/v1/advanced_editor/macros/shared/$macro_2_id")
        ->status_is( 403, 'Cannot delete other users shared macro without permission' );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'delete_shared_macros',
            },
        }
    );
    $t->delete_ok("//$auth_userid:$password@/api/v1/advanced_editor/macros/$macro_2_id")
        ->status_is( 403, 'Cannot delete other users shared macro with permission on private endpoint' );
    $t->delete_ok("//$auth_userid:$password@/api/v1/advanced_editor/macros/shared/$macro_2_id")
        ->status_is( 204, 'Can delete other users shared macro with permission' );

};

$schema->storage->txn_rollback;
