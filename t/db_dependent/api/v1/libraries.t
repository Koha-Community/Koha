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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 5;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Libraries;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    # Create test context
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $another_library = $library->unblessed; # create a copy of $library but make
    delete $another_library->{branchcode};     # sure branchcode will be regenerated
    $another_library = $builder->build_object({ class => 'Koha::Libraries', value => $another_library });

    ## Authorized user tests
    my $count_of_libraries = Koha::Libraries->search->count;
    # Make sure we are returned with the correct amount of libraries
    $t->get_ok( "//$userid:$password@/api/v1/libraries" )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_has('/'.($count_of_libraries-1).'/library_id')
      ->json_hasnt('/'.($count_of_libraries).'/library_id');

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
            opac_info         => 'opac_info',
        };

        my $size = keys %{$fields};

        plan tests => $size * 3;

        foreach my $field ( keys %{$fields} ) {
            my $model_field = $fields->{ $field };
            my $result =
            $t->get_ok("//$userid:$password@/api/v1/libraries?$field=" . $library->$model_field)
              ->status_is(200)
              ->json_has( [ $library, $another_library ] );
        }
    };

    # Warn on unsupported query parameter
    $t->get_ok( "//$userid:$password@/api/v1/libraries?library_blah=blah" )
      ->status_is(400)
      ->json_is( [{ path => '/query/library_blah', message => 'Malformed query string'}] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/libraries/" . $library->branchcode )
      ->status_is( 200, 'SWAGGER3.2.2' )
      ->json_is( '' => Koha::REST::V1::Library::_to_api( $library->TO_JSON ), 'SWAGGER3.3.2' );

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

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $library_obj = $builder->build_object({ class => 'Koha::Libraries' });
    my $library     = Koha::REST::V1::Library::_to_api( $library_obj->TO_JSON );
    $library_obj->delete;

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/libraries" => json => $library )
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = { %$library };
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
      ->status_is( 201, 'SWAGGER3.2.1' )
      ->json_is( '' => $library, 'SWAGGER3.3.1' )
      ->header_is( Location => '/api/v1/libraries/' . $library->{library_id}, 'SWAGGER3.4.1' );

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
          ->json_has( '/error' => "Fails when trying to add an existing library_id")
          ->json_is(  '/conflict', 'PRIMARY' ); } # WTF
        qr/^DBD::mysql::st execute failed: Duplicate entry '(.*)' for key 'PRIMARY'/;

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $library    = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_id = $library->branchcode;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/libraries/$library_id"
                    => json => { name => 'New unauthorized name change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $library_with_missing_field = {
        address1 => "New library address",
    };

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_missing_field )
      ->status_is(400)
      ->json_has( "/errors" =>
          [ { message => "Missing property.", path => "/body/address2" } ]
      );

    my $deleted_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_with_updated_field = Koha::REST::V1::Library::_to_api( $deleted_library->TO_JSON );
    $library_with_updated_field->{library_id} = $library_id;
    $deleted_library->delete;

    $t->put_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" => json => $library_with_updated_field )
      ->status_is(200, 'SWAGGER3.2.1')
      ->json_is( '' => $library_with_updated_field, 'SWAGGER3.3.3' );

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = { %$library_with_updated_field };
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

    my $non_existent_code = 'nope'.int(rand(10000));
    $t->put_ok("//$auth_userid:$password@/api/v1/libraries/$non_existent_code" => json => $library_with_updated_field)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 1 }
    });
    my $password = 'thePassword123';
    $authorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $auth_userid = $authorized_patron->userid;

    my $unauthorized_patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 4 }
    });
    $unauthorized_patron->set_password({ password => $password, skip_validation => 1 });
    my $unauth_userid = $unauthorized_patron->userid;

    my $library_id = $builder->build( { source => 'Branch' } )->{branchcode};

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/libraries/$library_id" )
      ->status_is(403);

    $t->delete_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" )
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok( "//$auth_userid:$password@/api/v1/libraries/$library_id" )
      ->status_is(404);

    $schema->storage->txn_rollback;
};
