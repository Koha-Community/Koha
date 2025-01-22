#!/usr/bin/env perl

# Copyright 2023 PTFS Europe

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

use JSON         qw(encode_json);
use Array::Utils qw( array_minus );

use Koha::ERM::EUsage::CounterFiles;
use Koha::Database;

# The Usage statistics module uses an external API to fetch data from the counter registry
# This test is designed to catch any changes in the response that the API provides so that we can react quickly to ensure the module still functions as expected

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'get() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my @expected_fields = (
        "abbrev",
        "address",
        "address_country",
        "audited",
        "contact",
        "content_provider_name",
        "host_types",
        "id",
        "name",
        "reports",
        "sushi_services",
        "website",
    );

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

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/counter_registry")->status_is(403);

    # Authorised access test
    my $q = encode_json( { "name" => "EBSCO Information Services" } );
    my $counter_registry =
        $t->get_ok("//$userid:$password@/api/v1/erm/counter_registry?q=$q")->status_is(200)->tx->res->json;

    my $registry_to_check      = @$counter_registry[0];
    my @response_fields        = map { $_ } keys %$registry_to_check;
    my @new_fields_in_response = array_minus( @response_fields, @expected_fields );

    is( scalar(@new_fields_in_response), 0, 'The response fields match the expected fields' );

    $schema->storage->txn_rollback;
};
