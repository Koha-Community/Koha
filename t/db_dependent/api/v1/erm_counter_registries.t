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

    my $expected_response = [
        {
            "abbrev" => "EBSCO",
            "address" => "EBSCO Information Services\n10 Estes Street\nIpswich, MA 01938",
            "address_country" => {
                "code" => "US",
                "name" => "United States of America"
            },
            "contact" => {
                "email" => 'chadmovalli@ebsco.com',
                "form_url" => "",
                "person" => "Chad Movalli",
                "phone" => ""
            },
            "content_provider_name" => "EBSCO",
            "host_types" => [
                {
                    "name" => "Aggregated_Full_Content"
                }
            ],
            "id" => "b2b2736c-2cb9-48ec-91f4-870336acfb1c",
            "name" => "EBSCO Information Services",
            "reports" => [
                {
                    "counter_release" => "5",
                    "report_id" => "TR_J4",
                    "report_name" => "Title Report - Journal Report 4"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "DR_D2",
                    "report_name" => "Database Report - Report 2"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_J3",
                    "report_name" => "Title Report - Journal Report 3"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "DR_D1",
                    "report_name" => "Database Report - Report 1"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_J2",
                    "report_name" => "Title Report - Journal Report 2"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "PR",
                    "report_name" => "Platform Master Report"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_B2",
                    "report_name" => "Title Report - Book Report 2"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_B3",
                    "report_name" => "Title Report - Book Report 3"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR",
                    "report_name" => "Title Master Report"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_B1",
                    "report_name" => "Title Report - Book Report 1"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "PR_P1",
                    "report_name" => "Platform Report - Report 1"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "TR_J1",
                    "report_name" => "Title Report - Journal Report 1"
                },
                {
                    "counter_release" => "5",
                    "report_id" => "DR",
                    "report_name" => "Database Master Report"
                }
            ],
            "sushi_services" => [
                {
                    "counter_release" => "5",
                    "url" => "https:\/\/registry.projectcounter.org\/api\/v1\/sushi-service\/b94bc981-fa16-4bf6-ba5f-6c113f7ffa0b\/"
                }
            ],
            "website" => "https:\/\/www.ebsco.com\/"
        }
    ];

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
    my $q                = encode_json( { "name" => "EBSCO Information Services" } );
    my $counter_registry = $t->get_ok("//$userid:$password@/api/v1/erm/counter_registry?q=$q")->status_is(200)->tx->res->json;
    is_deeply( $counter_registry, $expected_response );
};
