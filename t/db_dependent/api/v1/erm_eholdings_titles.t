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

use Koha::ERM::EHoldings::Titles;
use Koha::ERM::EHoldings::Packages;
use Koha::Virtualshelves;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    Koha::ERM::EHoldings::Titles->search->delete;

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
    # No EHoldings title, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/titles")
      ->status_is(200)->json_is( [] );

    my $ehtitle =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } );

    # One EHoldings title created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/titles")
      ->status_is(200)->json_is( [ $ehtitle->to_api ] );

    my $another_ehtitle = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Titles',
            value => { publication_type => $ehtitle->publication_type }
        }
    );
    my $ehtitle_with_another_publication_type =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } );

    # Two EHoldings titles created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/eholdings/local/titles")
      ->status_is(200)->json_is(
        [
            $ehtitle->to_api,
            $another_ehtitle->to_api,
            $ehtitle_with_another_publication_type->to_api
        ]
      );

    # Filtering works, two EHoldings titles sharing publication_type
    $t->get_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/titles?publication_type="
          . $ehtitle->publication_type )->status_is(200)
      ->json_is( [ $ehtitle->to_api, $another_ehtitle->to_api ] );

    # Attempt to search by publication_title like 'ko'
    $ehtitle->delete;
    $another_ehtitle->delete;
    $ehtitle_with_another_publication_type->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/eholdings/local/titles?q=[{"me.publication_title":{"like":"%ko%"}}]~)
      ->status_is(200)->json_is( [] );

    my $ehtitle_to_search = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Titles',
            value => {
                publication_title => 'koha',
            }
        }
    );

    # Search works, searching for publication_title like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/eholdings/local/titles?q=[{"me.publication_title":{"like":"%ko%"}}]~)
      ->status_is(200)->json_is( [ $ehtitle_to_search->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles?blah=blah")
      ->status_is(400)
      ->json_is(
        [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eholdings/local/titles")
      ->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $ehtitle =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } );
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

    # This EHoldings title exists, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/erm/eholdings/local/titles/"
          . $ehtitle->title_id )->status_is(200)->json_is( $ehtitle->to_api );

    # Return one EHoldings title with embed
    $t->get_ok( "//$userid:$password@/api/v1/erm/eholdings/local/titles/"
          . $ehtitle->title_id =>
          { 'x-koha-embed' => 'resources,resources.package' } )->status_is(200)
      ->json_is( { %{ $ehtitle->to_api }, resources => [] } );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/eholdings/local/titles/"
          . $ehtitle->title_id )->status_is(403);

    # Attempt to get non-existent EHoldings title
    my $ehtitle_to_delete =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } );
    my $non_existent_id = $ehtitle_to_delete->title_id;
    $ehtitle_to_delete->delete;

    $t->get_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/titles/$non_existent_id"
    )->status_is(404)->json_is( '/error' => 'eHolding title not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 24;

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

    my $ehtitle = {
        publication_title => "Publication title",
        print_identifier  => "Print-format identifier",
        online_identifier => "Online-format identifier",
        date_first_issue_online =>
          "Date of first serial issue available online",
        num_first_vol_online   => "Number of first volume available online",
        num_first_issue_online => "Number of first issue available online",
        date_last_issue_online => "Date of last issue available online",
        num_last_vol_online    => "Number of last volume available online",
        num_last_issue_online  => "Number of last issue available online",
        title_url              => "Title-level URL",
        first_author           => "First author",
        embargo_info           => "Embargo information",
        coverage_depth         => "Coverage depth",
        notes                  => "Notes",
        publisher_name         => "Publisher name",
        publication_type       => "Book",
        date_monograph_published_print =>
          "Date the monograph is first published in print",
        date_monograph_published_online =>
          "Date the monograph is first published online",
        monograph_volume  => "Number of volume for monograph",
        monograph_edition => "Edition of the monograph",
        first_editor      => "First editor",
        parent_publication_title_id =>
          "Title identifier of the parent publication",
        preceeding_publication_title_id =>
          "Title identifier of any preceding publication title",
        access_type => "Access type"
    };

    # Unauthorized attempt to write
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/erm/eholdings/local/titles" =>
          json => $ehtitle )->status_is(403);

    # Authorized attempt to write invalid data
    my $ehtitle_with_invalid_field = {
        blah              => "EHolding Title Blah",
        publication_title => "Publication title",
        print_identifier  => "Print-format identifier"
    };

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles" => json =>
          $ehtitle_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Authorized attempt to write
    my $ehtitle_id =
      $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles" => json =>
          $ehtitle )->status_is( 201, 'SWAGGER3.2.1' )->header_like(
        Location => qr|^/api/v1/erm/eholdings/local/titles/\d*|,
        'SWAGGER3.4.1'
    )->json_is( '/publication_title' => $ehtitle->{publication_title} )
      ->json_is( '/print_identifier' => $ehtitle->{print_identifier} )
      ->json_is( '/notes'            => $ehtitle->{notes} )
      ->json_is( '/publisher_name'   => $ehtitle->{publisher_name} )
      ->tx->res->json->{title_id};

    # Import titles from virtualshelf to package
    my $ehpackage_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Packages' } )
      ->package_id;

    my $virtual_shelf =
      $builder->build_object(
        {
          class => 'Koha::Virtualshelves',
      } );
    $virtual_shelf->transfer_ownership($librarian->borrowernumber);
     my $virtual_shelf_id = $virtual_shelf->shelfnumber;

    my $import_request =
    {
        list_id  => $virtual_shelf_id,
        package_id => $ehpackage_id
    };

    $t->post_ok(
    "//$userid:$password@/api/v1/erm/eholdings/local/titles/import" => json =>
      $import_request )->status_is(201)->json_has('/job_id');

    # Attempt to import titles from a virtualshelf that doesn't exist
    $virtual_shelf->delete;
    $t->post_ok(
    "//$userid:$password@/api/v1/erm/eholdings/local/titles/import" => json =>
      $import_request )->status_is(404)->json_is(
        { error => 'List not found' }
      );

    # Authorized attempt to create with null id
    $ehtitle->{title_id} = undef;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles" => json =>
          $ehtitle )->status_is(400)->json_has('/errors');

    # Authorized attempt to create with existing id
    $ehtitle->{title_id} = $ehtitle_id;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles" => json =>
          $ehtitle )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/title_id"
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

    my $ehtitle_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } )
      ->title_id;

    # Unauthorized attempt to update
    $t->put_ok(
"//$unauth_userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id"
          => json =>
          { publication_title => 'New unauthorized publication_title change' } )
      ->status_is(403);

    # Attempt partial update on a PUT
    my $ehtitle_with_missing_field = { date_first_issue_online =>
          "Date of first serial issue available online", };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id" =>
          json => $ehtitle_with_missing_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Missing property.",
                path    => "/body/publication_title"
            }
        ]
          );

    # Full object update on PUT
    my $ehtitle_with_updated_field = {
        publication_title => "Publication title",
        print_identifier  => "Print-format identifier",
        online_identifier => "Online-format identifier",
        date_first_issue_online =>
          "Date of first serial issue available online",
        num_first_vol_online   => "Number of first volume available online",
        num_first_issue_online => "Number of first issue available online",
        date_last_issue_online => "Date of last issue available online",
        num_last_vol_online    => "Number of last volume available online",
        num_last_issue_online  => "Number of last issue available online",
        title_url              => "Title-level URL",
        first_author           => "First author",
        embargo_info           => "Embargo information",
        coverage_depth         => "Coverage depth",
        notes                  => "Notes",
        publisher_name         => "Publisher name",
        publication_type       => "Book",
        date_monograph_published_print =>
          "Date the monograph is first published in print",
        date_monograph_published_online =>
          "Date the monograph is first published online",
        monograph_volume  => "Number of volume for monograph",
        monograph_edition => "Edition of the monograph",
        first_editor      => "First editor",
        parent_publication_title_id =>
          "Title identifier of the parent publication",
        preceeding_publication_title_id =>
          "Title identifier of any preceding publication title",
        access_type => "Access type"
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id" =>
          json => $ehtitle_with_updated_field )->status_is(200)
      ->json_is( '/publication_title' => 'Publication title' );

    # Authorized attempt to write invalid data
    my $ehtitle_with_invalid_field = {
        blah              => "EHolding Title Blah",
        publication_title => "Publication title",
        print_identifier  => "Print-format identifier"
    };

    $t->put_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id" =>
          json => $ehtitle_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
          );

    # Attempt to update non-existent EHolding title
    my $ehtitle_to_delete =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } );
    my $non_existent_id = $ehtitle_to_delete->title_id;
    $ehtitle_to_delete->delete;

    $t->put_ok(
"//$userid:$password@/api/v1/erm/eholdings/local/titles/$non_existent_id"
          => json => $ehtitle_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $ehtitle_with_updated_field->{title_id} = 2;

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id" =>
          json => $ehtitle_with_updated_field )->status_is(404);

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

    my $ehtitle_id =
      $builder->build_object( { class => 'Koha::ERM::EHoldings::Titles' } )
      ->title_id;

    # Unauthorized attempt to delete
    $t->delete_ok(
"//$unauth_userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id"
    )->status_is(403);

    # Delete existing EHolding title
    $t->delete_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id")
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( '', 'SWAGGER3.3.4' );

    # Attempt to delete non-existent EHolding title
    $t->delete_ok(
        "//$userid:$password@/api/v1/erm/eholdings/local/titles/$ehtitle_id")
      ->status_is(404);

    $schema->storage->txn_rollback;
};

