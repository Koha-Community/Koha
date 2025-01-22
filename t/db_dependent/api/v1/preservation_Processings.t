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

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Preservation::Processings;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    Koha::Preservation::Processings->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
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
    # No processings, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/preservation/processings")->status_is(200)->json_is( [] );

    my $processing = $builder->build_object(
        {
            class => 'Koha::Preservation::Processings',
        }
    );

    # One processing created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/preservation/processings")->status_is(200)
        ->json_is( [ $processing->to_api ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/preservation/processings")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $attributes = [
        {
            name          => 'color',
            type          => 'authorised_value',
            option_source => 'COLORS'
        },
        { name => 'title', type => 'db_column', option_source => '245$a' },
        {
            name => 'height',
            type => 'free_text'
        },
    ];
    $attributes = $processing->attributes($attributes);
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
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

    # This processing exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/preservation/processings/" . $processing->processing_id )->status_is(200)
        ->json_is( $processing->to_api );

    # Return one processing with attributes
    $t->get_ok( "//$userid:$password@/api/v1/preservation/processings/"
            . $processing->processing_id => { 'x-koha-embed' => 'attributes' } )->status_is(200)
        ->json_is( { %{ $processing->to_api }, attributes => $attributes->to_api } );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/preservation/processings/" . $processing->processing_id )
        ->status_is(403);

    # Attempt to get non-existent processing
    my $processing_to_delete = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $non_existent_id      = $processing_to_delete->processing_id;
    $processing_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/preservation/processings/$non_existent_id")->status_is(404)
        ->json_is( '/error' => 'Processing not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
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

    my $default_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $processing         = {
        name => "processing name",
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/preservation/processings" => json => $processing )->status_is(403);

    # Authorized attempt to write invalid data
    my $processing_with_invalid_field = {
        blah => "processing Blah",
        %$processing,
    };

    $t->post_ok( "//$userid:$password@/api/v1/preservation/processings" => json => $processing_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $processing_id =
        $t->post_ok( "//$userid:$password@/api/v1/preservation/processings" => json => $processing )
        ->status_is( 201, 'REST3.2.1' )->header_like(
        Location => qr|^/api/v1/preservation/processings/\d*|,
        'REST3.4.1'
    )->json_is( '/name' => $processing->{name} )->tx->res->json->{processing_id};

    # Authorized attempt to create with null id
    $processing->{processing_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/preservation/processings" => json => $processing )->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $processing->{processing_id} = $processing_id;
    $t->post_ok( "//$userid:$password@/api/v1/preservation/processings" => json => $processing )->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/processing_id"
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
            value => { flags => 2**30 }
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

    my $processing_id = $builder->build_object( { class => 'Koha::Preservation::Processings' } )->processing_id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/preservation/processings/$processing_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $processing_with_missing_field = {};

    $t->put_ok( "//$userid:$password@/api/v1/preservation/processings/$processing_id" => json =>
            $processing_with_missing_field )->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    my $default_processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    # Full object update on PUT
    my $processing_with_updated_field = {
        name => "New name",
    };

    $t->put_ok( "//$userid:$password@/api/v1/preservation/processings/$processing_id" => json =>
            $processing_with_updated_field )->status_is(200)->json_is( '/name' => 'New name' );

    # Authorized attempt to write invalid data
    my $processing_with_invalid_field = {
        blah => "processing Blah",
        %$processing_with_updated_field,
    };

    $t->put_ok( "//$userid:$password@/api/v1/preservation/processings/$processing_id" => json =>
            $processing_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
            );

    # Attempt to update non-existent processing
    my $processing_to_delete = $builder->build_object( { class => 'Koha::Preservation::Processings' } );
    my $non_existent_id      = $processing_to_delete->processing_id;
    $processing_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/preservation/processings/$non_existent_id" => json =>
            $processing_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $processing_with_updated_field->{processing_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/preservation/processings/$processing_id" => json =>
            $processing_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**30 }
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

    my $processing_id = $builder->build_object( { class => 'Koha::Preservation::Processings' } )->processing_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/preservation/processings/$processing_id")->status_is(403);

    # Delete existing processing
    $t->delete_ok("//$userid:$password@/api/v1/preservation/processings/$processing_id")->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent processing
    $t->delete_ok("//$userid:$password@/api/v1/preservation/processings/$processing_id")->status_is(404);

    $schema->storage->txn_rollback;
};
