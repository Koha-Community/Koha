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

use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

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
    # No FTP/SFTP servers, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/config/sftp_servers")->status_is(200)->json_is( [] );

    my $sftp_server = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );

    # One sftp server created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/config/sftp_servers")->status_is(200)->json_is( [ $sftp_server->to_api ] );

    my $another_sftp_server = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );

    # Two FTP/SFTP servers created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/config/sftp_servers")->status_is(200)
        ->json_is( [ $sftp_server->to_api, $another_sftp_server->to_api, ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/config/sftp_servers")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
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

    $t->get_ok( "//$userid:$password@/api/v1/config/sftp_servers/" . $sftp_server->id )->status_is(200)
        ->json_is( $sftp_server->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/config/sftp_servers/" . $sftp_server->id )->status_is(403);

    my $sftp_server_to_delete = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );
    my $non_existent_id = $sftp_server_to_delete->id;
    $sftp_server_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/config/sftp_servers/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'FTP/SFTP server not found' );

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

    my $sftp_server = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );
    my $sftp_server_data = $sftp_server->to_api;
    delete $sftp_server_data->{sftp_server_id};
    $sftp_server->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/config/sftp_servers" => json => $sftp_server_data )
        ->status_is(403);

    # Authorized attempt to write invalid data
    my $sftp_server_with_invalid_field = {
        name => 'Some other server',
        blah => 'blah'
    };

    $t->post_ok( "//$userid:$password@/api/v1/config/sftp_servers" => json => $sftp_server_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $sftp_server_id =
        $t->post_ok( "//$userid:$password@/api/v1/config/sftp_servers" => json => $sftp_server_data )
        ->status_is( 201, 'SWAGGER3.2.1' )
        ->header_like( Location => qr|^\/api\/v1\/config\/sftp_servers\/\d*|, 'SWAGGER3.4.1' )
        ->json_is( '/name' => $sftp_server_data->{name} )->tx->res->json->{sftp_server_id};

    # Authorized attempt to create with null id
    $sftp_server_data->{sftp_server_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/config/sftp_servers" => json => $sftp_server_data )->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $sftp_server_data->{sftp_server_id} = $sftp_server_id;
    $t->post_ok( "//$userid:$password@/api/v1/config/sftp_servers" => json => $sftp_server_data )->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/sftp_server_id"
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

    my $sftp_server_id = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    )->id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/config/sftp_servers/$sftp_server_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $sftp_server_with_missing_field = {
        host    => 'localhost',
        passive => '1'
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id" => json => $sftp_server_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $sftp_server_with_updated_field = {
        name     => "Some name",
        password => "some_pass",
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id" => json => $sftp_server_with_updated_field )
        ->status_is(200)->json_is( '/name' => 'Some name' );

    # Authorized attempt to write invalid data
    my $sftp_server_with_invalid_field = {
        blah => "Blah",
        name => 'Some name'
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id" => json => $sftp_server_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    my $sftp_server_to_delete = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );
    my $non_existent_id = $sftp_server_to_delete->id;
    $sftp_server_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/config/sftp_servers/$non_existent_id" => json => $sftp_server_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $sftp_server_with_updated_field->{sftp_server_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id" => json => $sftp_server_with_updated_field )
        ->status_is(404);

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

    my $sftp_server_id = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/config/sftp_servers/$sftp_server_id")->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id")->status_is( 204, 'SWAGGER3.2.4' )
        ->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/config/sftp_servers/$sftp_server_id")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'test() tests' => sub {

    plan tests => 5;

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

    my $sftp_server = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                password => undef,
                key_file => undef,
                status   => undef,
            },
        }
    );
    my $sftp_server_id = $sftp_server->id;

    # Unauthorized attempt to test
    $t->get_ok("//$unauth_userid:$password@/api/v1/sftp_server/$sftp_server_id/test_connection")->status_is(403);

    $t->get_ok("//$userid:$password@/api/v1/sftp_server/$sftp_server_id/test_connection")
        ->status_is( 200, 'SWAGGER3.2.4' )
        ->content_is( '{"1_ftp_conn":{"err":"cannot connect to '
            . $sftp_server->host
            . ': Name or service not known","msg":null,"passed":false}}', 'SWAGGER3.3.4' );

    $schema->storage->txn_rollback;
};
