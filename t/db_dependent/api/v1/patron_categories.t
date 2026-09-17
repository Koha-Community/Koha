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
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

use C4::Auth;
use Koha::Database;

use JSON qw(encode_json);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { categorycode => 'TEST', description => 'Test' }
        }
    );

    $category->add_library_limit( $library->branchcode );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**2, categorycode => 'TEST', branchcode => $library->branchcode }  # catalogue flag = 2
        }
    );

    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    $t->get_ok("//$userid:$password@/api/v1/patron_categories")->status_is(200);

    $t->get_ok("//$userid:$password@/api/v1/patron_categories?q={\"me.categorycode\":\"TEST\"}")
        ->status_is(200)
        ->json_has('/0/name')
        ->json_is( '/0/name' => 'Test' )
        ->json_hasnt('/1');

    # Off limits search

    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $off_limits_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { categorycode => 'CANT', description => 'Cant' }
        }
    );

    my $off_limits_librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value =>
                { flags => 2**2, categorycode => 'CANT', branchcode => $library_2->branchcode }    # catalogue flag = 2
        }
    );
    my $off_limits_password = 'thePassword123';
    $off_limits_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $off_limits_userid = $off_limits_librarian->userid;

    $t->get_ok("//$off_limits_userid:$off_limits_password@/api/v1/patron_categories?q={\"me.categorycode\":\"TEST\"}")
        ->status_is(200)
        ->json_hasnt('/0');

    # Off limits librarian category has changed to one within limits

    $off_limits_librarian->branchcode( $library->branchcode )->store;

    $t->get_ok("//$off_limits_userid:$off_limits_password@/api/v1/patron_categories?q={\"me.categorycode\":\"TEST\"}")
        ->status_is(200)
        ->json_has('/0/name')
        ->json_is( [ $category->to_api ] )
        ->json_hasnt('/1');

    $schema->storage->txn_rollback;

};

subtest 'add() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3, categorycode => 'TEST', branchcode => $library->branchcode } # parameters flag = 3
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

    my $category = {
        patron_category_id => 'new',
        name               => "A new category",
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/patron_categories" => json => $category )->status_is(403);

    # Authorized attempt to write invalid data
    my $category_with_invalid_field = {
        blah => "Category Blah",
        name => "Won't work"
    };

    $t->post_ok( "//$userid:$password@/api/v1/patron_categories" => json => $category_with_invalid_field )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
        );

    # Authorized attempt to write
    my $patron_category_id =
        $t->post_ok( "//$userid:$password@/api/v1/patron_categories" => json => $category )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^\/api\/v1\/patron_categories/\d*|,
        'REST3.4.1'
        )->json_is( '/name' => $category->{name} )->tx->res->json->{patron_category_id};

    $schema->storage->txn_rollback;
};
