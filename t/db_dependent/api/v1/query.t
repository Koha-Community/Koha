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

use Koha::Cities;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'q handling tests' => sub {

    plan tests => 17;

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

    # delete all cities
    Koha::Cities->new->delete;

    # No cities, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)
      ->json_is( [] );

    my $names = [ 'AA', 'BA', 'BA', 'CA', 'DA', 'EB', 'FB', 'GB', 'HB', 'IB', ];

    # Add 10 cities
    foreach my $i ( 0 .. 9 ) {
        $builder->build_object(
            { class => 'Koha::Cities', value => { city_name => $names->[$i] } }
        );
    }

    t::lib::Mocks::mock_preference( 'RESTdefaultPageSize', 20 );

    my $q_ends_with_a = 'q={"name":{"-like":"%A"}}';

    my $cities =
      $t->get_ok(
        "//$userid:$password@/api/v1/cities?$q_ends_with_a")
      ->status_is(200)->tx->res->json;

    is( scalar @{$cities}, 5, '5 cities retrieved' );

    my $q_starts_with_a = 'q={"name":{"-like":"A%"}}';

    $cities =
      $t->get_ok(
        "//$userid:$password@/api/v1/cities?$q_ends_with_a&$q_starts_with_a")
      ->status_is(200)->tx->res->json;

    is( scalar @{$cities}, 1, '1 city retrieved' );

    my $q_empty_list = "q=[]";

    $cities =
      $t->get_ok(
        "//$userid:$password@/api/v1/cities?$q_ends_with_a&$q_starts_with_a&$q_empty_list")
      ->status_is(200)->tx->res->json;

    is( scalar @{$cities}, 1, 'empty list as trailing query, 1 city retrieved' );

    $cities =
      $t->get_ok(
        "//$userid:$password@/api/v1/cities?$q_empty_list&$q_ends_with_a&$q_starts_with_a")
      ->status_is(200)->tx->res->json;

    is( scalar @{$cities}, 1, 'empty list as first query, 1 city retrieved' );

    $t->get_ok("//$userid:$password@/api/v1/cities" => { 'x-koha-request-id' => 100 } )
      ->header_is( 'x-koha-request-id' => 100 );

    $schema->storage->txn_rollback;
};

subtest 'x-koha-embed tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }     # superlibrarian
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron_id = $builder->build_object( { class => 'Koha::Patrons' } )->id;

    my $res = $t->get_ok(
        "//$userid:$password@/api/v1/patrons?q={\"me.patron_id\":$patron_id}"
          => { 'x-koha-embed' => 'extended_attributes' } )->status_is(200)
      ->tx->res->json;

    is( scalar @{$res}, 1, 'One patron returned' );

    $res = $t->get_ok(
        "//$userid:$password@/api/v1/patrons?q={\"me.patron_id\":$patron_id}" => {
            'x-koha-embed' =>
              'extended_attributes,custom_bad_embed,another_bad_embed'
        }
    )->status_is(400);

    $res = $t->get_ok(
        "//$userid:$password@/api/v1/cities" => {
            'x-koha-embed' => 'any_embed'
        }
    )->status_is(400)->tx->res->json;

    is($res, 'Embedding objects is not allowed on this endpoint.', 'Correct error message is returned');

    $schema->storage->txn_rollback;
};
