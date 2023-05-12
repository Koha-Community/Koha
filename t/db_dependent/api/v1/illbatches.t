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

use Koha::Illbatch;
use Koha::Illbatches;
use Koha::Illrequests;
use Koha::IllbatchStatuses;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    Koha::Illbatches->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 2 ** 22 # 22 => ill
            }
        }
    );

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );

    my $password = 'sheev_is_da_boss!';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    ## Authorized user tests
    # No batches, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/illbatches")
      ->status_is(200)
      ->json_is( [] );

    my $batch = $builder->build_object({
        class => 'Koha::Illbatches',
        value => {
            name           => "PapaPalpatine",
            backend        => "Mock",
            borrowernumber => $librarian->borrowernumber,
            branchcode => $branch->branchcode
        }
    });

    my $illrq = $builder->build({
        source => 'Illrequest',
        value => {
            borrowernumber => $librarian->borrowernumber,
            batch_id       => $batch->id
        }
    });

    # One batch created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/illbatches")
      ->status_is(200)
      ->json_has( '/0/id', 'Batch ID' )
      ->json_has( '/0/name', 'Batch name' )
      ->json_has( '/0/backend', 'Backend name' )
      ->json_has( '/0/borrowernumber', 'Borrowernumber' )
      ->json_has( '/0/branchcode', 'Branchcode' )
      ->json_has( '/0/patron', 'patron embedded' )
      ->json_has( '/0/branch', 'branch embedded' )
      ->json_has( '/0/requests_count', 'request count' );

    # Try to create a second batch with the same name, this should fail
    my $another_batch = $builder->build_object({ class => 'Koha::Illbatches', value => {
        name => $batch->name
    } });
    # Create a second batch with a different name
    my $batch_with_another_name = $builder->build_object({ class => 'Koha::Illbatches' });

    # Two batches created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/illbatches")
      ->status_is(200)
      ->json_has('/0', 'has first batch')
      ->json_has('/1', 'has second batch');

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                cardnumber => 999,
                flags => 0
            }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/illbatches")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 15;

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

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );

    my $batch = $builder->build_object({
        class => 'Koha::Illbatches',
        value => {
            name           => "LeiaOrgana",
            backend        => "Mock",
            borrowernumber => $librarian->borrowernumber,
            branchcode     => $branch->branchcode
        }
    });


    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    $t->get_ok( "//$userid:$password@/api/v1/illbatches/" . $batch->id )
      ->status_is(200)
      ->json_has( '/id', 'Batch ID' )
      ->json_has( '/name', 'Batch name' )
      ->json_has( '/backend', 'Backend name' )
      ->json_has( '/borrowernumber', 'Borrowernumber' )
      ->json_has( '/branchcode', 'Branchcode' )
      ->json_has( '/patron', 'patron embedded' )
      ->json_has( '/branch', 'branch embedded' )
      ->json_has( '/requests_count', 'request count' );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/illbatches/" . $batch->id )
      ->status_is(403);

    my $batch_to_delete = $builder->build_object({ class => 'Koha::Illbatches' });
    my $non_existent_id = $batch_to_delete->id;
    $batch_to_delete->delete;

    $t->get_ok( "//$userid:$password@/api/v1/illbatches/$non_existent_id" )
      ->status_is(404)
      ->json_is( '/error' => 'ILL batch not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests =>19;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'v4d3rRox';
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

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );

    my $batch_status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses'
        }
    );

    my $batch_metadata = {
        name           => "Anakin's requests",
        backend        => "Mock",
        cardnumber     => $librarian->cardnumber,
        branchcode     => $branch->branchcode,
        statuscode     => $batch_status->code
    };

    # Unauthorized attempt to write
    $t->post_ok("//$unauth_userid:$password@/api/v1/illbatches" => json => $batch_metadata)
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $batch_with_invalid_field = {
        %{$batch_metadata},
        doh => 1
    };

    $t->post_ok( "//$userid:$password@/api/v1/illbatches" => json => $batch_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: doh.",
                path    => "/body"
            }
        ]
      );

    # Authorized attempt to write
    my $batch_id =
      $t->post_ok( "//$userid:$password@/api/v1/illbatches" => json => $batch_metadata )
        ->status_is( 201 )
        ->json_is( '/name'           => $batch_metadata->{name} )
        ->json_is( '/backend'        => $batch_metadata->{backend} )
        ->json_is( '/borrowernumber' => $librarian->borrowernumber )
        ->json_is( '/branchcode'     => $batch_metadata->{branchcode} )
        ->json_is( '/statuscode'     => $batch_status->code )
        ->json_has( '/patron' )
        ->json_has( '/status' )
        ->json_has( '/requests_count' )
        ->json_has( '/branch' );

    # Authorized attempt to create with null id
    $batch_metadata->{id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/illbatches" => json => $batch_metadata )
      ->status_is(400)
      ->json_has('/errors');

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

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

    my $branch = $builder->build_object(
        {
            class => 'Koha::Libraries'
        }
    );

    my $batch_id = $builder->build_object({ class => 'Koha::Illbatches' } )->id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/illbatches/$batch_id" => json => { name => 'These are not the droids you are looking for' } )
      ->status_is(403);

    my $batch_status = $builder->build_object(
        {
            class => 'Koha::IllbatchStatuses'
        }
    );

    # Attempt partial update on a PUT
    my $batch_with_missing_field = {
        backend => "Mock",
        borrowernumber => $librarian->borrowernumber,
        branchcode => $branch->branchcode,
        statuscode => $batch_status->code
    };

    $t->put_ok( "//$userid:$password@/api/v1/illbatches/$batch_id" => json => $batch_with_missing_field )
      ->status_is(400)
      ->json_is( "/errors" =>
          [ { message => "Missing property.", path => "/body/name" } ]
      );

    # Full object update on PUT
    my $batch_with_updated_field = {
        name           => "Master Ploo Koon",
        backend        => "Mock",
        borrowernumber => $librarian->borrowernumber,
        branchcode => $branch->branchcode,
        statuscode => $batch_status->code
    };

    $t->put_ok( "//$userid:$password@/api/v1/illbatches/$batch_id" => json => $batch_with_updated_field )
      ->status_is(200)
      ->json_is( '/name' => 'Master Ploo Koon' );

    # Authorized attempt to write invalid data
    my $batch_with_invalid_field = {
        doh  => 1,
        name => "Master Mace Windu",
        backend => "Mock"
    };

    $t->put_ok( "//$userid:$password@/api/v1/illbatches/$batch_id" => json => $batch_with_invalid_field )
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: doh.",
                path    => "/body"
            }
        ]
    );

    my $batch_to_delete = $builder->build_object({ class => 'Koha::Cities' });
    my $non_existent_id = $batch_to_delete->id;
    $batch_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/illbatches/$non_existent_id" => json => $batch_with_updated_field )
      ->status_is(404);

    # Wrong method (POST)
    $batch_with_updated_field->{id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/illbatches/$batch_id" => json => $batch_with_updated_field )
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 6;

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

    my $batch_id = $builder->build_object({ class => 'Koha::Illbatches' })->id;

    # Unauthorized attempt to delete
    $t->delete_ok( "//$unauth_userid:$password@/api/v1/illbatches/$batch_id" )
      ->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/illbatches/$batch_id")
      ->status_is(204);

    $t->delete_ok("//$userid:$password@/api/v1/illbatches/$batch_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
