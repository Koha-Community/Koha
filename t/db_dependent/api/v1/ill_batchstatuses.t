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

use Test::More tests => 5;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::IllbatchStatus;
use Koha::IllbatchStatuses;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    Koha::IllbatchStatuses->search->delete;

    # Create an admin user
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 2**22    # 22 => ill
            }
        }
    );
    my $password = 'yoda4ever!';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    ## Authorized user tests
    # No statuses, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/ill/batchstatuses")->status_is(200)->json_is( [] );

    my $status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses',
            value => {
                name      => "Han Solo",
                code      => "SOLO",
                is_system => 0
            }
        }
    );

    # One batch created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/ill/batchstatuses")->status_is(200)->json_has( '/0/id', 'ID' )
        ->json_has( '/0/name', 'Name' )->json_has( '/0/code', 'Code' )->json_has( '/0/is_system', 'is_system' );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'Rebelz4DaWin';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses',
            value => {
                name      => "Han Solo",
                code      => "SOLO",
                is_system => 0
            }
        }
    );

    # Unauthorised user
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/ill/batchstatuses/" . $status->code )->status_is(200)
        ->json_has( '/id',        'ID' )->json_has( '/name', 'Name' )->json_has( '/code', 'Code' )
        ->json_has( '/is_system', 'is_system' );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/ill/batchstatuses/" . $status->id )->status_is(403);

    my $status_to_delete  = $builder->build_object( { class => 'Koha::IllbatchStatuses' } );
    my $non_existent_code = $status_to_delete->code;
    $status_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/ill/batchstatuses/$non_existent_code")->status_is(404)
        ->json_is( '/error' => 'ILL batch status not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = '3poRox';
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

    my $status_metadata = {
        name      => "In a bacta tank",
        code      => "BACTA",
        is_system => 0
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/ill/batchstatuses" => json => $status_metadata )->status_is(403);

    # Authorized attempt to write invalid data
    my $status_with_invalid_field = {
        %{$status_metadata},
        doh => 1
    };

    $t->post_ok( "//$userid:$password@/api/v1/ill/batchstatuses" => json => $status_with_invalid_field )->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: doh.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $status_id =
        $t->post_ok( "//$userid:$password@/api/v1/ill/batchstatuses" => json => $status_metadata )->status_is(201)
        ->json_has( '/id',        'ID' )->json_has( '/name', 'Name' )->json_has( '/code', 'Code' )
        ->json_has( '/is_system', 'is_system' );

    # Authorized attempt to create with null id
    $status_metadata->{id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/ill/batchstatuses" => json => $status_metadata )->status_is(400)
        ->json_has('/errors');

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'aw3s0m3y0d41z';
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

    my $status_code = $builder->build_object( { class => 'Koha::IllbatchStatuses' } )->code;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/ill/batchstatuses/$status_code" => json =>
            { name => 'These are not the droids you are looking for' } )->status_is(403);

    # Attempt partial update on a PUT
    my $status_with_missing_field = {
        code      => $status_code,
        is_system => 0
    };

    $t->put_ok( "//$userid:$password@/api/v1/ill/batchstatuses/$status_code" => json => $status_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $status_with_updated_field = {
        name      => "Master Ploo Koon",
        code      => $status_code,
        is_system => 0
    };

    $t->put_ok( "//$userid:$password@/api/v1/ill/batchstatuses/$status_code" => json => $status_with_updated_field )
        ->status_is(200)->json_is( '/name' => 'Master Ploo Koon' );

    # Authorized attempt to write invalid data
    my $status_with_invalid_field = {
        doh  => 1,
        name => "Master Mace Windu",
        code => $status_code
    };

    $t->put_ok( "//$userid:$password@/api/v1/ill/batchstatuses/$status_code" => json => $status_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: doh.",
                path    => "/body"
            }
        ]
        );

    my $status_to_delete  = $builder->build_object( { class => 'Koha::IllbatchStatuses' } );
    my $non_existent_code = $status_to_delete->code;
    $status_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/ill/batchstatuses/$non_existent_code" => json => $status_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 's1th43v3r!';
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

    my $non_system_status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses',
            value => { is_system => 0 }
        }
    );

    my $system_status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses',
            value => { is_system => 1 }
        }
    );

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/ill/batchstatuses/" . $non_system_status->code )->status_is(403);

    $t->delete_ok( "//$userid:$password@/api/v1/ill/batchstatuses/" . $non_system_status->code )->status_is(204);

    $t->delete_ok( "//$userid:$password@/api/v1/ill/batchstatuses/" . $non_system_status->code )->status_is(404);

    $t->delete_ok( "//$userid:$password@/api/v1/ill/batchstatuses/" . $system_status->code )->status_is(400)
        ->json_is( "/errors" => [ { message => "ILL batch status cannot be deleted" } ] );

    $schema->storage->txn_rollback;
};
