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
use Test::More tests => 8;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use List::Util qw(min);

use Koha::Libraries;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    # Create test context
    my $library         = $builder->build_object( { class => 'Koha::Libraries' } );
    my $another_library = $library->unblessed;                                      # create a copy of $library but make
    delete $another_library->{branchcode};    # sure branchcode will be regenerated
    $another_library = $builder->build_object( { class => 'Koha::Libraries', value => $another_library } );

    ## Authorized user tests
    # Make sure we are returned with the correct amount of libraries
    $t->get_ok("//$userid:$password@/api/v1/libraries")->status_is( 200, 'REST3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };
    my $expected_count = min( Koha::Libraries->count, C4::Context->preference('RESTdefaultPageSize') );
    is( $response_count, $expected_count, 'Results count is paginated' );

    subtest 'query parameters' => sub {

        my $fields = {
            name              => 'branchname',
            address1          => 'branchaddress1',
            address2          => 'branchaddress2',
            address3          => 'branchaddress3',
            postal_code       => 'branchzip',
            city              => 'branchcity',
            state             => 'branchstate',
            country           => 'branchcountry',
            phone             => 'branchphone',
            fax               => 'branchfax',
            email             => 'branchemail',
            reply_to_email    => 'branchreplyto',
            return_path_email => 'branchreturnpath',
            url               => 'branchurl',
            ip                => 'branchip',
            notes             => 'branchnotes',
        };

        my $size = keys %{$fields};

        plan tests => $size * ( 2 + 2 * $size );

        foreach my $field ( keys %{$fields} ) {
            my $model_field = $fields->{$field};
            my $result =
                $t->get_ok( "//$userid:$password@/api/v1/libraries?$field=" . $library->$model_field )->status_is(200);
            foreach my $key ( keys %{$fields} ) {
                my $key_field = $fields->{$key};
                $result->json_is( "/0/$key", $library->$key_field );
                $result->json_is( "/1/$key", $another_library->$key_field );
            }
        }
    };

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/libraries?library_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/library_blah', message => 'Malformed query string' } ] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode )
        ->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => $library->to_api, 'REST3.3.2' );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/"
            . $library->branchcode => { 'x-koha-embed' => 'cash_registers,desks' } )
        ->status_is(200)
        ->json_is( { %{ $library->to_api }, desks => [], cash_registers => [] } );

    my $desk = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->id } } );
    my $cash_register =
        $builder->build_object( { class => 'Koha::Cash::Registers', value => { branch => $library->id } } );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/"
            . $library->branchcode => { 'x-koha-embed' => 'cash_registers,desks' } )
        ->status_is(200)
        ->json_is(
        { %{ $library->to_api }, desks => [ $desk->to_api ], cash_registers => [ $cash_register->to_api ] } );

    my $non_existent_code = $library->branchcode;
    $library->delete;

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $non_existent_code )
        ->status_is(404)
        ->json_is( '/error' => 'Library not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $library_obj = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library     = $library_obj->to_api;
    $library_obj->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/libraries" => json => $library )->status_is(403);

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = {%$library};
    $library_with_invalid_field->{'branchinvalid'} = 'Library invalid';

    $t->post_ok( "//$auth_userid:$password@/api/v1/libraries" => json => $library_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: branchinvalid.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    $t->post_ok( "//$auth_userid:$password@/api/v1/libraries" => json => $library )
        ->status_is( 201, 'REST3.2.1' )
        ->json_is( '' => $library, 'REST3.3.1' )
        ->header_is( Location => '/api/v1/libraries/' . $library->{library_id}, 'REST3.4.1' );

    # save the library_id
    my $library_id = $library->{library_id};

    # Authorized attempt to create with null id
    $library->{library_id} = undef;

    $t->post_ok( "//$auth_userid:$password@/api/v1/libraries" => json => $library )
        ->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $library->{library_id} = $library_id;

    warning_like {
        $t->post_ok( "//$auth_userid:$password@/api/v1/libraries" => json => $library )
            ->status_is(409)
            ->json_has( '/error' => "Fails when trying to add an existing library_id" )
            ->json_like( '/conflict' => qr/(branches\.)?PRIMARY/ );
    }
    qr/DBD::mysql::st execute failed: Duplicate entry '(.*)' for key '(branches\.)?PRIMARY'/;

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_id = $library->branchcode;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/libraries/$library_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $library_with_missing_field = {
        address1 => "New library address",
    };

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_missing_field )
        ->status_is(400)
        ->json_has( "/errors" => [ { message => "Missing property.", path => "/body/address2" } ] );

    my $deleted_library            = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_with_updated_field = $deleted_library->to_api;
    $library_with_updated_field->{library_id} = $library_id;
    $deleted_library->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_updated_field )
        ->status_is( 200, 'REST3.2.1' )
        ->json_is( '' => $library_with_updated_field, 'REST3.3.3' );

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = {%$library_with_updated_field};
    $library_with_invalid_field->{'branchinvalid'} = 'Library invalid';

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: branchinvalid.",
                path    => "/body"
            }
        ]
        );

    my $non_existent_code = 'nope' . int( rand(10000) );
    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$non_existent_code" => json => $library_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $library_id = $builder->build( { source => 'Branch' } )->{branchcode};

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/libraries/$library_id")->status_is(403);

    $t->delete_ok("//$auth_userid:$password@/api/v1/libraries/$library_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    $t->delete_ok("//$auth_userid:$password@/api/v1/libraries/$library_id")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'list_desks() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    t::lib::Mocks::mock_preference( 'UseCirculationDesks', 0 );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode . "/desks" )
        ->status_is(404)
        ->json_is( '/error' => q{Feature disabled} );

    my $non_existent_code = $library->branchcode;
    $library->delete;

    t::lib::Mocks::mock_preference( 'UseCirculationDesks', 1 );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $non_existent_code . "/desks" )
        ->status_is(404)
        ->json_is( '/error' => 'Library not found' );

    my $desk_1 = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->id } } );
    my $desk_2 = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->id } } );

    my $res =
        $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode . "/desks" )
        ->status_is(200)
        ->json_is( '/0/desk_id' => $desk_1->id )
        ->json_is( '/1/desk_id' => $desk_2->id )
        ->tx->res->json;

    is( scalar @{$res}, 2 );

    $schema->storage->txn_rollback;
};

subtest 'list_cash_registers() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    t::lib::Mocks::mock_preference( 'UseCashRegisters', 0 );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode . "/cash_registers" )
        ->status_is(404)
        ->json_is( '/error' => q{Feature disabled} );

    my $non_existent_code = $library->branchcode;
    $library->delete;

    t::lib::Mocks::mock_preference( 'UseCashRegisters', 1 );

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $non_existent_code . "/cash_registers" )
        ->status_is(404)
        ->json_is( '/error' => 'Library not found' );

    my $cash_register_1 =
        $builder->build_object( { class => 'Koha::Cash::Registers', value => { branch => $library->id } } );
    my $cash_register_2 =
        $builder->build_object( { class => 'Koha::Cash::Registers', value => { branch => $library->id } } );

    my $res =
        $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode . "/cash_registers" )
        ->status_is(200)
        ->json_is( '/0/cash_register_id' => $cash_register_1->id )
        ->json_is( '/1/cash_register_id' => $cash_register_2->id )
        ->tx->res->json;

    is( scalar @{$res}, 2 );

    $schema->storage->txn_rollback;
};
