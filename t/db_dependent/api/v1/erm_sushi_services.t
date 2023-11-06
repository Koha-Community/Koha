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

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use JSON qw(encode_json);

use Koha::ERM::EUsage::CounterFiles;
use Koha::Database;

my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'get() tests' => sub {
    plan tests => 5;

    my $service_url = "https://registry.projectcounter.org/api/v1/sushi-service/b94bc981-fa16-4bf6-ba5f-6c113f7ffa0b/";
    my $expected_response = {
        "api_key_info"=> "",
        "api_key_required"=> 0,
        "contact"=> {
            "email"=> 'chadmovalli@ebsco.com',
            "form_url"=> "",
            "person"=> "Chad Movalli",
            "phone"=> ""
        },
        "counter_release"=> "5",
        "credentials_auto_expire"=> 0,
        "credentials_auto_expire_info"=> "",
        "customer_id_info"=> "This is your EBSCOhost Customer ID",
        "customizations_in_place"=> 0,
        "customizations_info"=> "",
        "data_host"=> "https:\/\/registry.projectcounter.org\/api\/v1\/usage-data-host\/72a35413-6fcd-44f2-8bce-0c7b2373e33f\/",
        "id"=> "b94bc981-fa16-4bf6-ba5f-6c113f7ffa0b",
        "ip_address_authorization"=> 0,
        "ip_address_authorization_info"=> "",
        "notification_count"=> 1,
        "notifications_url"=> "https:\/\/registry.projectcounter.org\/api\/v1\/sushi-service\/b94bc981-fa16-4bf6-ba5f-6c113f7ffa0b\/notification\/",
        "platform_attr_required"=> 0,
        "platform_specific_info"=> "",
        "request_volume_limits_applied"=> 0,
        "request_volume_limits_info"=> "",
        "requestor_id_info"=> "Customers generate their Requestor ID in EBSCOAdmin on the SUSHI Authentication tab within the COUNTER R5 Reports section.",
        "requestor_id_required"=> 1,
        "url"=> "https:\/\/sushi.ebscohost.com\/R5"
    };

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
    my $q = encode_json(
        {
            "url" => $service_url
        }
    );
    my $sushi_service = $t->get_ok("//$userid:$password@/api/v1/erm/sushi_service?q=$q")->status_is(200)
        ->tx->res->json;
    is_deeply( $sushi_service, $expected_response );
};
