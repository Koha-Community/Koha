#!/usr/bin/env perl

# Copyright 2023 Theke Solutions
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::RecordSources;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    for ( 1 .. 10 ) {
        $builder->build_object( { class => 'Koha::RecordSources' } );
    }

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    $t->get_ok("//$userid:$password@/api/v1/record_sources")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/record_sources?_per_page=10")->status_is( 200, 'REST3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };

    is( $response_count, 10, 'The API returns 10 sources' );

    my $id = $source->record_source_id;
    $t->get_ok("//$userid:$password@/api/v1/record_sources?q={\"record_source_id\": $id}")->status_is(200)
        ->json_is( '' => [ $source->to_api ], 'REST3.3.2' );

    $source->delete;

    $t->get_ok("//$userid:$password@/api/v1/record_sources?q={\"record_source_id\": $id}")->status_is(200)
        ->json_is( '' => [] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    my $id = $source->record_source_id;

    $t->get_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => $source->to_api, 'REST3.3.2' );

    $source->delete;

    $t->get_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is(404)
        ->json_is( '/error' => 'Record source not found' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    my $id = $source->record_source_id;

    $t->delete_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $source->delete();
    $t->delete_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is( 404, 'REST4.3' )
        ->json_is( { error => q{Record source not found}, error_code => q{not_found} } );

    $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    $id     = $source->id;

    my $biblio   = $builder->build_sample_biblio();
    my $metadata = $biblio->metadata;
    $metadata->record_source_id( $source->id )->store();

    $t->delete_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is( 409, 'REST3.2.4.1' );

    $biblio->delete();

    $t->delete_ok("//$userid:$password@/api/v1/record_sources/$id")->status_is( 204, 'REST3.2.4' )
        ->content_is( q{}, 'REST3.3.4' );

    my $deleted_source = Koha::RecordSources->search( { record_source_id => $id } );

    is( $deleted_source->count, 0, 'No record source found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $nonprivilegedpatron->userid;
    my $patron_id = $nonprivilegedpatron->borrowernumber;

    $t->post_ok( "//$userid:$password@/api/v1/record_sources" => json => { name => 'test1' } )->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    my $source_id =
        $t->post_ok( "//$userid:$password@/api/v1/record_sources" => json => { name => 'test1' } )
        ->status_is( 201, 'REST3.2.2' )->json_is( '/name', 'test1' )->json_is( '/can_be_edited', 0 )
        ->tx->res->json->{record_source_id};

    my $created_source = Koha::RecordSources->find($source_id);

    is( $created_source->name, 'test1', 'Record source found' );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters flag = 2
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

    my $source    = Koha::RecordSource->new( { name => 'old_name' } )->store;
    my $source_id = $source->id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/record_sources/$source_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $source_with_missing_field = {};

    $t->put_ok( "//$userid:$password@/api/v1/record_sources/$source_id" => json => $source_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $source_with_updated_field = {
        name => "new_name",
    };

    $t->put_ok( "//$userid:$password@/api/v1/record_sources/$source_id" => json => $source_with_updated_field )
        ->status_is(200)->json_is( '/name' => $source_with_updated_field->{name} );

    # Authorized attempt to write invalid data
    my $source_with_invalid_field = {
        name   => "blah",
        potato => "yeah",
    };

    $t->put_ok( "//$userid:$password@/api/v1/record_sources/$source_id" => json => $source_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: potato.",
                path    => "/body"
            }
        ]
        );

    my $source_to_delete = $builder->build_object( { class => 'Koha::RecordSources' } );
    my $non_existent_id  = $source_to_delete->id;
    $source_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/record_sources/$non_existent_id" => json => $source_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $source_with_updated_field->{record_source_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/record_sources/$source_id" => json => $source_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};
