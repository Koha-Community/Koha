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

use Koha::Tickets;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    Koha::Tickets->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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
    # No tickets, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/tickets")->status_is(200)
      ->json_is( [] );

    my $ticket = $builder->build_object( { class => 'Koha::Tickets' } );

    # One ticket created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/tickets")->status_is(200)
      ->json_is( [ $ticket->to_api ] );

    my $another_ticket = $builder->build_object( { class => 'Koha::Tickets' } );
    my $and_another_ticket =
      $builder->build_object( { class => 'Koha::Tickets' } );

    # Two tickets created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/tickets")->status_is(200)->json_is(
        [
            $ticket->to_api, $another_ticket->to_api,
            $and_another_ticket->to_api
        ]
    );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/tickets?ticket_blah=blah")
      ->status_is(400)->json_is(
        [
            {
                path    => '/query/ticket_blah',
                message => 'Malformed query string'
            }
        ]
      );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/tickets")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $ticket    = $builder->build_object( { class => 'Koha::Tickets' } );
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    $t->get_ok( "//$userid:$password@/api/v1/tickets/" . $ticket->id )
      ->status_is(200)->json_is( $ticket->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/tickets/" . $ticket->id )
      ->status_is(403);

    my $ticket_to_delete =
      $builder->build_object( { class => 'Koha::Tickets' } );
    my $non_existent_id = $ticket_to_delete->id;
    $ticket_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/tickets/$non_existent_id")
      ->status_is(404)->json_is( '/error' => 'Ticket not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2 }    # catalogue flag = 2
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

    my $biblio = $builder->build_sample_biblio();
    my $ticket = {
        biblio_id => $biblio->id,
        title     => "Test ticket",
        body      => "Test ticket details",
    };

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/tickets" => json => $ticket )
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $ticket_with_invalid_field = {
        blah      => "Something wrong",
        biblio_id => $biblio->id,
        title     => "Test ticket",
        body      => "Test ticket details",
    };

    $t->post_ok( "//$userid:$password@/api/v1/tickets" => json =>
          $ticket_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $ticket_id =
      $t->post_ok( "//$userid:$password@/api/v1/tickets" => json => $ticket )
      ->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/tickets/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/biblio_id' => $ticket->{biblio_id} )
      ->json_is( '/title'       => $ticket->{title} )
      ->json_is( '/body'        => $ticket->{body} )
      ->json_is( '/reporter_id' => $librarian->id )->tx->res->json->{ticket_id};

    # Authorized attempt to create with null id
    $ticket->{ticket_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/tickets" => json => $ticket )
      ->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $ticket->{ticket_id} = $ticket_id;
    $t->post_ok( "//$userid:$password@/api/v1/tickets" => json => $ticket )
      ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/ticket_id"
            }
        ]
      );

    # Authorized attempt to write missing data
    my $ticket_with_missing_field = {
        biblio_id => $biblio->id,
        body      => "Test ticket details",
    };

    $t->post_ok( "//$userid:$password@/api/v1/tickets" => json =>
          $ticket_with_missing_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Missing property.",
                path    => "/body/title"
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
            value => { flags => 2**9 }    # editcatalogue flag = 9
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

    my $ticket_id = $builder->build_object( { class => 'Koha::Tickets' } )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/tickets/$ticket_id" => json =>
          { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $ticket_with_missing_field = {
        body      => "Test ticket details",
    };

    $t->put_ok( "//$userid:$password@/api/v1/tickets/$ticket_id" => json =>
          $ticket_with_missing_field )->status_is(400)
      ->json_is( "/errors" =>
          [ { message => "Missing property.", path => "/body/title" } ] );

    # Full object update on PUT
    my $ticket_with_updated_field = {
        title     => "Test ticket update",
        body      => "Test ticket update details",
    };

    $t->put_ok( "//$userid:$password@/api/v1/tickets/$ticket_id" => json =>
          $ticket_with_updated_field )->status_is(200)
      ->json_is( '/title' => 'Test ticket update' );

    # Authorized attempt to write invalid data
    my $ticket_with_invalid_field = {
        blah        => "Ticket Blah",
        title     => "Test ticket update",
        body      => "Test ticket update details",
    };

    $t->put_ok( "//$userid:$password@/api/v1/tickets/$ticket_id" => json =>
          $ticket_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    my $ticket_to_delete =
      $builder->build_object( { class => 'Koha::Tickets' } );
    my $non_existent_id = $ticket_to_delete->id;
    $ticket_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/tickets/$non_existent_id" => json =>
          $ticket_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $ticket_with_updated_field->{ticket_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/tickets/$ticket_id" => json =>
          $ticket_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**9 }    # editcatalogue flag = 9
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

    my $ticket_id = $builder->build_object( { class => 'Koha::Tickets' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/tickets/$ticket_id")
      ->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/tickets/$ticket_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    $t->delete_ok("//$userid:$password@/api/v1/tickets/$ticket_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
