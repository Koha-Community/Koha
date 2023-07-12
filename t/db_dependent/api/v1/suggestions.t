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

use Koha::Suggestions;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 12 } # suggestions flag = 12
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
    my $patron_id     = $patron->id;

    ## Authorized user tests
    # No suggestions by patron, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/suggestions?q={\"suggested_by\":\"$patron_id\"}")
      ->status_is(200)->json_is( [] );

    my $suggestion_1 = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { suggestedby => $patron_id, STATUS => 'ASKED' }
        }
    );

    # One suggestion created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/suggestions?q={\"suggested_by\":\"$patron_id\"}")
      ->status_is(200)->json_is( [ $suggestion_1->to_api ] );

    my $suggestion_2 = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { suggestedby => $patron_id, STATUS => 'ASKED' }
        }
    );

    # Two SMTP servers created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/suggestions?q={\"suggested_by\":\"$patron_id\"}")
      ->status_is(200)
      ->json_is( [ $suggestion_1->to_api, $suggestion_2->to_api, ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/suggestions")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $librarian  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 12 } # suggestions flag = 12
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
    my $patron_id = $patron->id;

    my $suggestion = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { suggestedby => $patron_id, STATUS => 'ASKED' }
        }
    );

    $t->get_ok(
        "//$userid:$password@/api/v1/suggestions/" . $suggestion->id )
      ->status_is(200)->json_is( $suggestion->to_api );

    $t->get_ok( "//$unauth_userid:$password@/api/v1/suggestions/"
          . $suggestion->id )->status_is(403);

    my $suggestion_to_delete = $builder->build_object( { class => 'Koha::Suggestions' } );
    my $non_existent_id = $suggestion_to_delete->id;
    $suggestion_to_delete->delete;

    $t->get_ok(
        "//$userid:$password@/api/v1/suggestions/$non_existent_id")
      ->status_is(404)->json_is( '/error' => 'Suggestion not found.' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 12 } # suggestions flag = 12
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
    my $patron_id     = $patron->id;

    my $suggestion = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { suggestedby => $patron_id, STATUS => 'ASKED' }
        }
    );
    my $suggestion_data = $suggestion->to_api;
    delete $suggestion_data->{suggestion_id};
    $suggestion->delete;

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/suggestions" => json =>
          $suggestion_data )->status_is(403);

    # Authorized attempt to write invalid data
    my $suggestion_with_invalid_field = {
        blah => 'blah'
    };

    $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json =>
          $suggestion_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $generated_suggestion =
      $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json =>
          $suggestion_data )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^\/api\/v1\/suggestions\/\d*|,
        'SWAGGER3.4.1'
    )->tx->res->json;

    my $suggestion_id = $generated_suggestion->{suggestion_id};
    is_deeply(
        $generated_suggestion,
        Koha::Suggestions->find($suggestion_id)->to_api,
        'The object is returned'
    );

    # Authorized attempt to create with null id
    $suggestion_data->{suggestion_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json =>
          $suggestion_data )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $suggestion_data->{suggestion_id} = $suggestion_id;
    $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json =>
          $suggestion_data )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/suggestion_id"
            }
        ]
          );

    subtest 'x-koha-override tests' => sub {

        plan tests => 14;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        t::lib::Mocks::mock_preference( 'MaxTotalSuggestions',    4 );
        t::lib::Mocks::mock_preference( 'MaxOpenSuggestions',     2 );
        t::lib::Mocks::mock_preference( 'NumberOfSuggestionDays', 2 );

        my $suggestion = $builder->build_object(
            {   class => 'Koha::Suggestions',
                value => { suggestedby => $patron->id, STATUS => 'ACCEPTED' }
            }
        );

        my $suggestion_data = $suggestion->to_api;
        delete $suggestion_data->{suggestion_id};
        delete $suggestion_data->{status};

        $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json => $suggestion_data )
          ->status_is( 201, 'First pending suggestion' );

        $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json => $suggestion_data )
          ->status_is( 201, 'Second pending suggestion' );

        $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json => $suggestion_data )
          ->status_is(400)
          ->json_is( '/error_code' => 'max_pending_reached' );

        $t->post_ok( "//$userid:$password@/api/v1/suggestions"
             => { 'x-koha-override' => 'max_pending' }
             => json => $suggestion_data )
          ->status_is( 201, 'max_pending override does the job' );

        $t->post_ok( "//$userid:$password@/api/v1/suggestions" => json => $suggestion_data )
          ->status_is(400)
          ->json_is( '/error_code' => 'max_total_reached' );

        $t->post_ok(
            "//$userid:$password@/api/v1/suggestions" => { 'x-koha-override' => 'any' } => json => $suggestion_data )
          ->status_is( 201, 'any overrides anything' );
    };

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 12 } # suggestions flag = 12
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

    my $suggestion_id = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { STATUS => 'ASKED' }
        }
    )->id;

    # Unauthorized attempt to update
    $t->put_ok(
        "//$unauth_userid:$password@/api/v1/suggestions/$suggestion_id"
          => json => { name => 'New unauthorized name change' } )
      ->status_is(403);

    # Full object update on PUT
    my $suggestion_with_updated_field = { reason => "Some reason", };

    $t->put_ok(
        "//$userid:$password@/api/v1/suggestions/$suggestion_id" =>
          json => $suggestion_with_updated_field )->status_is(200)
      ->json_is( '/reason' => 'Some reason' );

    # Authorized attempt to write invalid data
    my $suggestion_with_invalid_field = {
        blah   => "Blah",
        reason => 'Some reason'
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/suggestions/$suggestion_id" =>
          json => $suggestion_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    my $suggestion_to_delete = $builder->build_object({ class => 'Koha::Suggestions' });
    my $non_existent_id = $suggestion_to_delete->id;
    $suggestion_to_delete->delete;

    $t->put_ok(
        "//$userid:$password@/api/v1/suggestions/$non_existent_id" =>
          json => $suggestion_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $suggestion_with_updated_field->{smtp_server_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/suggestions/$suggestion_id" =>
          json => $suggestion_with_updated_field )->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 12 } # suggestions flag = 12
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

    my $suggestion_id = $builder->build_object({ class => 'Koha::Suggestions' } )->id;

    # Unauthorized attempt to delete
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/suggestions/$suggestion_id"
    )->status_is(403);

    $t->delete_ok(
        "//$userid:$password@/api/v1/suggestions/$suggestion_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( q{}, 'SWAGGER3.3.4' );

    $t->delete_ok(
        "//$userid:$password@/api/v1/suggestions/$suggestion_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
