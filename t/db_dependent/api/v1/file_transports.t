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

use Test::More tests => 6;
use Test::Mojo;
use Test::NoWarnings;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::File::Transports;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    Koha::File::Transports->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    ## Authorized user tests
    # No File transports, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/config/file_transports")->status_is(200)->json_is( [] );

    my $file_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );

    # One file transport created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/config/file_transports")
        ->status_is(200)
        ->json_is( [ $file_transport->to_api ] );

    my $another_file_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );

    # Two File transports created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/config/file_transports")
        ->status_is(200)
        ->json_is( [ $file_transport->to_api, $another_file_transport->to_api, ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/config/file_transports")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $file_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    $t->get_ok( "//$userid:$password@/api/v1/config/file_transports/" . $file_transport->id )
        ->status_is(200)
        ->json_is( $file_transport->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/config/file_transports/" . $file_transport->id )->status_is(403);

    my $file_transport_to_delete = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );
    my $non_existent_id = $file_transport_to_delete->id;
    $file_transport_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/config/file_transports/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'File transport not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    Koha::File::Transports->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $file_transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );
    my $file_transport_data = $file_transport->to_api;
    delete $file_transport_data->{file_transport_id};
    $file_transport->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/config/file_transports" => json => $file_transport_data )
        ->status_is(403);

    # Authorized attempt to write invalid data
    my $file_transport_with_invalid_field = {
        name => 'Some other server',
        blah => 'blah'
    };

    $t->post_ok( "//$userid:$password@/api/v1/config/file_transports" => json => $file_transport_with_invalid_field )
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
    my $file_transport_id =
        $t->post_ok( "//$userid:$password@/api/v1/config/file_transports" => json => $file_transport_data )
        ->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like( Location => qr|^\/api\/v1\/config\/file_transports\/\d*|, 'SWAGGER3.4.1' )
        ->json_is( '/name' => $file_transport_data->{name} )
        ->tx->res->json->{file_transport_id};

    # Authorized attempt to create with null id
    $file_transport_data->{file_transport_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/config/file_transports" => json => $file_transport_data )
        ->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $file_transport_data->{file_transport_id} = $file_transport_id;
    $t->post_ok( "//$userid:$password@/api/v1/config/file_transports" => json => $file_transport_data )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/file_transport_id"
            }
        ]
        );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $file_transport_id = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    )->id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/config/file_transports/$file_transport_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $file_transport_with_missing_field = {
        host    => 'localhost',
        passive => '1'
    };

    $t->put_ok( "//$userid:$password@/api/v1/config/file_transports/$file_transport_id" => json =>
            $file_transport_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $file_transport_with_updated_field = {
        name     => "Some name",
        password => "some_pass",
    };

    $t->put_ok( "//$userid:$password@/api/v1/config/file_transports/$file_transport_id" => json =>
            $file_transport_with_updated_field )->status_is(200)->json_is( '/name' => 'Some name' );

    # Authorized attempt to write invalid data
    my $file_transport_with_invalid_field = {
        blah => "Blah",
        name => 'Some name'
    };

    $t->put_ok( "//$userid:$password@/api/v1/config/file_transports/$file_transport_id" => json =>
            $file_transport_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
            );

    my $file_transport_to_delete = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    );
    my $non_existent_id = $file_transport_to_delete->id;
    $file_transport_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/config/file_transports/$non_existent_id" => json =>
            $file_transport_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $file_transport_with_updated_field->{file_transport_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/config/file_transports/$file_transport_id" => json =>
            $file_transport_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3**2 }    # parameters flag = 3
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

    my $file_transport_id = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
                status    => undef,
            },
        }
    )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/config/file_transports/$file_transport_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/config/file_transports/$file_transport_id")
        ->status_is( 204, 'SWAGGER3.2.4' )
        ->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/config/file_transports/$file_transport_id")->status_is(404);

    $schema->storage->txn_rollback;
};

1;
