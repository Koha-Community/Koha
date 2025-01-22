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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AdditionalFields;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    Koha::AdditionalFields->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters
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
    # No additional fields, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types")->status_is(200)->json_is( [] );

    my $additional_field = $builder->build_object(
        {
            class => 'Koha::AdditionalFields',
            value => { tablename => 'aqinvoices', name => 'af_name' },
        }
    );

    # One additional_field created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types")->status_is(200)
        ->json_is( [ $additional_field->to_api ] );

    my $another_additional_field = $builder->build_object(
        {
            class => 'Koha::AdditionalFields',
            value => { tablename => 'aqinvoices', name => 'second_af_name' },
        }
    );

    my $additional_field_different_tablename = $builder->build_object(
        {
            class => 'Koha::AdditionalFields',
            value => { tablename => 'aqbasket', name => 'third_af_name' },
        }
    );

    # Three additional fields created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types")->status_is(200)->json_is(
        [
            $additional_field->to_api,
            $another_additional_field->to_api,
            $additional_field_different_tablename->to_api
        ]
    );

    my $additional_field_yet_another_different_tablename = $builder->build_object(
        {
            class => 'Koha::AdditionalFields',
            value => { tablename => 'subscription', name => 'fourth_af_name' },
        }
    );

    # Four additional fields created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types")->status_is(200)->json_is(
        [
            $additional_field->to_api,
            $another_additional_field->to_api,
            $additional_field_different_tablename->to_api,
            $additional_field_yet_another_different_tablename->to_api,
        ]
    );

    # Filtering works, two existing additional fields returned for the queried table name
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types?resource_type=invoice")->status_is(200)
        ->json_is( [ $additional_field->to_api, $another_additional_field->to_api ] );

    # Filtering works for unmapped tablename
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types?resource_type=subscription")->status_is(200)
        ->json_is( [ $additional_field_yet_another_different_tablename->to_api ] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/extended_attribute_types?blah=blah")->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/extended_attribute_types")->status_is(403);

    $schema->storage->txn_rollback;
};
