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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON         qw(encode_json);
use Array::Utils qw( array_minus );

use Koha::ERM::EUsage::CounterFiles;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

# The Usage statistics module uses an external API to fetch data from the counter registry
# This test is designed to catch any changes in the response that the API provides so that we can react quickly to ensure the module still functions as expected

subtest 'get() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $service_url = "https://registry.countermetrics.org/api/v1/sushi-service/b94bc981-fa16-4bf6-ba5f-6c113f7ffa0b/";
    my @expected_fields = (
        "api_key_info",
        "api_key_required",
        "contact",
        "counter_release",
        "credentials_auto_expire",
        "credentials_auto_expire_info",
        "customer_id_info",
        "customizations_in_place",
        "customizations_info",
        "data_host",
        "id",
        "ip_address_authorization",
        "ip_address_authorization_info",
        "last_audit",
        "migrations",
        "notification_count",
        "notifications_url",
        "platform_attr_required",
        "platform_specific_info",
        "request_volume_limits_applied",
        "request_volume_limits_info",
        "requestor_id_info",
        "requestor_id_required",
        "url",
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
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/sushi_service")->status_is(403);

    # Authorised access test
    my $q             = encode_json( { "url" => $service_url } );
    my $sushi_service = $t->get_ok("//$userid:$password@/api/v1/erm/sushi_service?q=$q")->status_is(200)->tx->res->json;

    my @response_fields        = map { $_ } keys %$sushi_service;
    my @new_fields_in_response = array_minus( @response_fields, @expected_fields );

    is( scalar(@new_fields_in_response), 0, "Compare response from sushi server" )
        or diag "This is not a new error within Koha, the following new field(s) have been added to the API response: "
        . join( ', ', @new_fields_in_response )
        . '. They should be added to the API definition';

    $schema->storage->txn_rollback;
};
