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

use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Tickets;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
t::lib::Mocks::mock_preference( 'NotifyPasswordChange', 0 );

subtest 'list_updates() tests' => sub {

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

    my $ticket    = $builder->build_object( { class => 'Koha::Tickets' } );
    my $ticket_id = $ticket->id;

    ## Authorized user tests
    # No updates, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/tickets/$ticket_id/updates")
      ->status_is(200)->json_is( [] );

    my $update = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { ticket_id => $ticket_id }
        }
    );

    # One ticket update added, should get returned
    $t->get_ok("//$userid:$password@/api/v1/tickets/$ticket_id/updates")
      ->status_is(200)->json_is( [ $update->to_api ] );

    my $update_2 = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { ticket_id => $ticket_id }
        }
    );
    my $update_3 = $builder->build_object(
        {
            class => 'Koha::Ticket::Updates',
            value => { ticket_id => $ticket_id }
        }
    );

    # Two ticket updates added, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/tickets/$ticket_id/updates")
      ->status_is(200)
      ->json_is( [ $update->to_api, $update_2->to_api, $update_3->to_api, ] );

    # Warn on unsupported query parameter
    $t->get_ok(
"//$userid:$password@/api/v1/tickets/$ticket_id/updates?ticket_blah=blah"
    )->status_is(400)->json_is(
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

subtest 'add_update() tests' => sub {

    plan tests => 34;

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

    my $ticket = $builder->build_object(
        {
            class => 'Koha::Tickets',
            value => { reporter_id => $patron->id }
        }
    );
    my $ticket_id = $ticket->id;

    my $update = {
        message => "First ticket update",
        public  => Mojo::JSON->false
    };

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/tickets/$ticket_id/updates" =>
          json => $update )->status_is(403);

    # Authorized attempt to write
    my $update_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/tickets/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/message' => $update->{message} )
      ->json_is( '/public'  => $update->{public} )
      ->json_is( '/user_id' => $librarian->id )->tx->res->json->{update_id};

    # Check that notice trigger didn't fire for non-public update
    my $notices =
      Koha::Notice::Messages->search( { borrowernumber => $patron->id } );
    is( $notices->count, 0,
        'No notices queued when the update is marked as not public' );

    # Authorized attempt to create with null id
    $update->{update_id} = undef;
    $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $update->{update_id} = $update_id;
    $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/update_id"
            }
        ]
          );
    delete $update->{update_id};

    # Authorized attempt to write missing data
    my $update_with_missing_field = { message => "Another ticket update" };

    $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update_with_missing_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Missing property.",
                path    => "/body/public"
            }
        ]
          );

    # Check that notice trigger fired for public update
    $update->{public} = Mojo::JSON->true;
    $update_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/tickets/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/message' => $update->{message} )
      ->json_is( '/public'  => $update->{public} )
      ->json_is( '/user_id' => $librarian->id )->tx->res->json->{update_id};

    $notices =
      Koha::Notice::Messages->search( { borrowernumber => $patron->id } );
    is( $notices->count, 1,
        'One notice queued when the update is marked as public' );
    my $THE_notice = $notices->next;
    is( $THE_notice->letter_code, 'TICKET_UPDATE',
        'Notice queued was a TICKET_UPDATE for non-status changing update'
    );
    $THE_notice->delete;

    $update->{state} = 'resolved';
    $update_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/tickets/$ticket_id/updates" => json =>
          $update )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/tickets/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/message' => $update->{message} )
      ->json_is( '/public'  => $update->{public} )
      ->json_is( '/user_id' => $librarian->id )->tx->res->json->{update_id};

    $notices =
      Koha::Notice::Messages->search( { borrowernumber => $patron->id } );
    is( $notices->count, 1,
        'One notice queued when the update is marked as public' );
    $THE_notice = $notices->next;
    is( $THE_notice->letter_code, 'TICKET_RESOLVE',
        'Notice queued was a TICKET_RESOLVED for status changing update'
    );

    $schema->storage->txn_rollback;
};
