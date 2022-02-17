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

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Cities;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() pagination tests' => sub {

    plan tests => 66;

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

    my $names = [
        'AA',
        'BA',
        'BA',
        'CA',
        'DA',
        'EB',
        'FB',
        'GB',
        'HB',
        'IB',
    ];

    # Add 10 cities
    foreach my $i ( 0 .. 9 ) {
        $builder->build_object( { class => 'Koha::Cities', value => { city_name => $names->[$i] } } );
    }

    t::lib::Mocks::mock_preference( 'RESTdefaultPageSize', 20 );

    my $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)
      ->header_is( 'X-Total-Count', '10' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_unlike( 'Link', qr|rel="prev"| )
      ->header_unlike( 'Link', qr|rel="next"| )
      ->header_like( 'Link',
        qr#(_per_page=20\&_page=1|_page=1\&_per_page=20)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=20\&_page=1|_page=1\&_per_page=20)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 10, '10 libraries retrieved' );

    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities?q={\"name\":{\"-like\":\"\%A\"}}")->status_is(200)
      ->header_is( 'X-Total-Count', '5', 'The resultset has 5 items' )
      ->header_is( 'X-Base-Total-Count', '10', 'The resultset, without the filter, has 10' )
      ->header_unlike( 'Link', qr|rel="prev"| )
      ->header_unlike( 'Link', qr|rel="next"| )
      ->header_like( 'Link',
        qr#(_per_page=20.*\&_page=1.*|_page=1.*\&_per_page=20.*)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=20.*\&_page=1.*|_page=1.*\&_per_page=20.*)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 5, '5 libraries retrieved' );

    t::lib::Mocks::mock_preference( 'RESTdefaultPageSize', 3 );

    # _per_page overrides RESTdefaultPageSize
    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities?_per_page=20")
      ->status_is(200)
      ->header_is( 'X-Total-Count', '10' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_unlike( 'Link', qr|rel="prev"| )
      ->header_unlike( 'Link', qr|rel="next"| )
      ->header_like( 'Link',
        qr#(_per_page=20\&_page=1|_page=1\&_per_page=20)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=20\&_page=1|_page=1\&_per_page=20)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 10, '10 libraries retrieved' );

    # page 1
    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities")->status_is(200)
      ->header_is( 'X-Total-Count', '10' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_unlike( 'Link', qr|rel="prev"| )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=1|_page=1\&_per_page=3)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=2|_page=2\&_per_page=3)>\; rel="next"# )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=4|_page=4\&_per_page=3)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 3, '3 libraries retrieved' );

    # This tests X-Base-Total-Count, .* is used for q=, as we don't want
    # to add all combinations to the regex
    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities?_per_page=2&_page=2&q={\"name\":{\"-like\":\"\%A\"}}")->status_is(200)
      ->header_is( 'X-Total-Count', '5' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_like( 'Link',
        qr#(_per_page=2.*\&_page=1.*|_page=1.*\&_per_page=2.*)>\; rel="prev"# )
      ->header_like( 'Link',
        qr#(_per_page=2.*\&_page=1.*|_page=1.*\&_per_page=2.*)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=2.*\&_page=3.*|_page=3.*\&_per_page=2.*)>\; rel="next"# )
      ->header_like( 'Link',
        qr#(_per_page=2.*\&_page=3.*|_page=3.*\&_per_page=2.*)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 2, '2 libraries retrieved' );

    # last page, with only one result
    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities?_page=4")->status_is(200)
      ->header_is( 'X-Total-Count', '10' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=3|_page=3\&_per_page=3)>\; rel="prev"# )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=1|_page=1\&_per_page=3)>\; rel="first"# )
      ->header_unlike( 'Link', qr#rel="next"# )
      ->header_like( 'Link',
        qr#(_per_page=3\&_page=4|_page=4\&_per_page=3)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 1, '1 library retrieved' );

    $libraries =
      $t->get_ok("//$userid:$password@/api/v1/cities?_per_page=-1")
      ->status_is(200)
      ->header_is( 'X-Total-Count', '10' )
      ->header_is( 'X-Base-Total-Count', '10' )
      ->header_unlike( 'Link', qr|rel="prev"| )
      ->header_unlike( 'Link', qr|rel="next"| )
      ->header_like( 'Link',
        qr#(_per_page=-1\&_page=1|_page=1\&_per_page=-1)>\; rel="first"# )
      ->header_like( 'Link',
        qr#(_per_page=-1\&_page=1|_page=1\&_per_page=-1)>\; rel="last"# )
      ->tx->res->json;

    is( scalar @{$libraries}, 10, '10 libraries retrieved, -1 means all' );

    $schema->storage->txn_rollback;
};
