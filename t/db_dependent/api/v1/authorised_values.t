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
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AuthorisedValues;
use Koha::Database;

use JSON qw( encode_json );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list_av_from_category() tests' => sub {

    plan tests => 22;

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

    ## Authorized user tests
    # No category, 404 expected
    $t->get_ok("//$userid:$password@/api/v1/authorised_value_categories/NON_EXISTS/authorised_values")
        ->status_is(404)
        ->json_is( '/error' => 'Category not found' );

    my $av_cat = $builder->build_object( { class => 'Koha::AuthorisedValueCategories' } )->category_name;

    # No AVs, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/authorised_value_categories/$av_cat/authorised_values")
        ->status_is(200)
        ->json_is( [] );

    my $av = $builder->build_object( { class => 'Koha::AuthorisedValues', value => { category => $av_cat } } );

    # One av created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/authorised_value_categories/$av_cat/authorised_values")
        ->status_is(200)
        ->json_is( [ $av->to_api ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/authorised_value_categories/$av_cat/authorised_values")
        ->status_is(403);

    # Test the query webservice endpoint for multiple av_cats
    my $av_cat_2 =
        $builder->build_object( { class => 'Koha::AuthorisedValueCategories', value => { category_name => 'cat_a' } } );
    my $av_cat_3 =
        $builder->build_object( { class => 'Koha::AuthorisedValueCategories', value => { category_name => 'cat_b' } } );
    my $query = { "me.category_name" => [ $av_cat_2->category_name, $av_cat_3->category_name ] };
    $t->get_ok( "//$userid:$password@/api/v1/authorised_value_categories?q=" . encode_json($query) )
        ->status_is(200)
        ->json_is( [ $av_cat_2->to_api, $av_cat_3->to_api ] );

    # Test the above but with x-koha-embed: authorised_values
    my $embedded_query = { "me.category_name" => [ $av_cat_2->category_name, $av_cat_3->category_name ] };
    $t->get_ok( "//$userid:$password@/api/v1/authorised_value_categories?q="
            . encode_json($embedded_query) => { 'x-koha-embed' => 'authorised_values' } )
        ->status_is(200)
        ->json_has( '/0/authorised_values', 'authorised_values object correctly embedded' )
        ->json_has( '/1/authorised_values', 'authorised_values object correctly embedded' )
        ->json_hasnt( '/2/', 'authorised_values object correctly embedded' );

    # Test the query webservice endpoint for multiple av_cats with authorised_values embedded
    my $av_2 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => $av_cat_2->category_name,
                authorised_value => 'a',
                lib              => undef
            }
        }
    );
    my $av_3 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => $av_cat_2->category_name,
                authorised_value => 'c',
                lib              => 'description_value'
            }
        }
    );
    my $av_4 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => $av_cat_2->category_name,
                authorised_value => 'b',
                lib              => 'description_value'
            }
        }
    );

    my $embedded_av_query = { "me.category_name" => [ $av_cat_2->category_name ] };
    $t->get_ok(
        "//$userid:$password@/api/v1/authorised_value_categories?_order_by=authorised_values.authorised_value&q="
            . encode_json($embedded_av_query) => { 'x-koha-embed' => 'authorised_values' } )->status_is(200)->json_is(
        [
            {
                %{ $av_cat_2->to_api },
                authorised_values => [ $av_2->to_api, $av_4->to_api, $av_3->to_api ]
            }
        ]
            );

    $schema->storage->txn_rollback;
};
