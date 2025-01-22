#!/usr/bin/env perl

# Copyright 2023 PTFS Europe

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
use Test::More tests => 4;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ERM::EUsage::CounterFiles;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::ERM::EUsage::CounterFiles->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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
    # No counter files, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/counter_files")->status_is(200)->json_is( [] );

    my $counter_file = $builder->build_object( { class => 'Koha::ERM::EUsage::CounterFiles' } );

    # One counter_file created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/counter_files")->status_is(200)->json_is( [ $counter_file->to_api ] );

    my $another_counter_file = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::CounterFiles',
        }
    );

    # Two counter_files created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/counter_files")->status_is(200)
        ->json_is( [ $counter_file->to_api, $another_counter_file->to_api, ] );

    # Attempt to search by type like 'ko'
    $counter_file->delete;
    $another_counter_file->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/counter_files?q=[{"me.type":{"like":"%ko%"}}]~)->status_is(200)
        ->json_is( [] );

    my $counter_file_to_search = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::CounterFiles',
            value => {
                type => 'koha',
            }
        }
    );

    # Search works, searching for type like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/counter_files?q=[{"me.type":{"like":"%ko%"}}]~)->status_is(200)
        ->json_is( [ $counter_file_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/erm/counter_files?blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/counter_files")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $counter_file = $builder->build_object( { class => 'Koha::ERM::EUsage::CounterFiles' } );
    my $librarian    = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    # This counter_file exists, should get returned
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/counter_files/" . $counter_file->erm_counter_files_id . "/file/content" )
        ->status_is(200);

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/counter_files/"
            . $counter_file->erm_counter_files_id
            . "/file/content" )->status_is(403);

    # Attempt to get non-existent counter_file
    my $counter_file_to_delete = $builder->build_object( { class => 'Koha::ERM::EUsage::CounterFiles' } );
    my $non_existent_id        = $counter_file_to_delete->erm_counter_files_id;
    $counter_file_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/erm/counter_files/$non_existent_id/file/content")->status_is(404)
        ->json_is( '/error' => 'COUNTER file not found' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**28 }
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

    my $counter_file_id =
        $builder->build_object( { class => 'Koha::ERM::EUsage::CounterFiles' } )->erm_counter_files_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/erm/counter_files/$counter_file_id")->status_is(403);

    # Delete existing counter_file
    $t->delete_ok("//$userid:$password@/api/v1/erm/counter_files/$counter_file_id")->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent counter_file
    $t->delete_ok("//$userid:$password@/api/v1/erm/counter_files/$counter_file_id")->status_is(404);

    $schema->storage->txn_rollback;
};
