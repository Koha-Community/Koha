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
use Test::More tests => 7;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ERM::EUsage::UsageDataProviders;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'list() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    Koha::ERM::EUsage::UsageDataProviders->search->delete;

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
    # No usage_data_providers, so empty array should be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/usage_data_providers")->status_is(200)->json_is( [] );

    my %additional_fields = (
        earliest_title    => '',
        latest_title      => '',
        earliest_database => '',
        latest_database   => '',
        earliest_item     => '',
        latest_item       => '',
        earliest_platform => '',
        latest_platform   => '',
        last_run          => ''
    );

    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $udp_result          = { %{ $usage_data_provider->to_api }, %additional_fields };

    # One usage_data_provider created, should get returned
    $t->get_ok("//$userid:$password@/api/v1/erm/usage_data_providers")->status_is(200)->json_is( [$udp_result] );

    my $another_usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
        }
    );
    my $another_udp_result = { %{ $another_usage_data_provider->to_api }, %additional_fields };

    # Two usage_data_providers created, they should both be returned
    $t->get_ok("//$userid:$password@/api/v1/erm/usage_data_providers")->status_is(200)->json_is(
        [
            $udp_result,
            $another_udp_result,
        ]
    );

    # Attempt to search by name like 'ko'
    $usage_data_provider->delete;
    $another_usage_data_provider->delete;
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/usage_data_providers?q=[{"me.name":{"like":"%ko%"}}]~)
        ->status_is(200)
        ->json_is( [] );

    my $usage_data_provider_to_search = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                name => 'koha',
            }
        }
    );
    my $search_udp_result = { %{ $usage_data_provider_to_search->to_api }, %additional_fields };

    # Search works, searching for name like 'ko'
    $t->get_ok(qq~//$userid:$password@/api/v1/erm/usage_data_providers?q=[{"me.name":{"like":"%ko%"}}]~)
        ->status_is(200)
        ->json_is( [$search_udp_result] );

    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/erm/usage_data_providers?blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/blah', message => 'Malformed query string' } ] );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/usage_data_providers")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $librarian           = $builder->build_object(
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

    # This usage_data_provider exists, should get returned
    $t->get_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/" . $usage_data_provider->erm_usage_data_provider_id )
        ->status_is(200)
        ->json_is( $usage_data_provider->to_api );

    # Unauthorized access
    $t->get_ok( "//$unauth_userid:$password@/api/v1/erm/usage_data_providers/"
            . $usage_data_provider->erm_usage_data_provider_id )->status_is(403);

    # Attempt to get non-existent usage_data_provider
    my $usage_data_provider_to_delete = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $non_existent_id               = $usage_data_provider_to_delete->erm_usage_data_provider_id;
    $usage_data_provider_to_delete->delete;

    $t->get_ok("//$userid:$password@/api/v1/erm/usage_data_providers/$non_existent_id")
        ->status_is(404)
        ->json_is( '/error' => 'Usage data provider not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 20;

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

    my $usage_data_provider = {
        name           => "usage_data_provider name",
        customer_id    => "1",
        requestor_id   => "1",
        api_key        => "1",
        service_url    => "www.test.co.uk",
        report_release => "test"
    };

    # Unauthorized attempt to write
    $t->post_ok( "//$unauth_userid:$password@/api/v1/erm/usage_data_providers" => json => $usage_data_provider )
        ->status_is(403);

    # Authorized attempt to write invalid data
    my $usage_data_provider_with_invalid_field = {
        blah           => "usage_data_provider Blah",
        name           => "usage_data_provider name",
        customer_id    => "1",
        requestor_id   => "1",
        api_key        => "1",
        service_url    => "www.test.co.uk",
        report_release => "test"
    };

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers" => json => $usage_data_provider_with_invalid_field )
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
    my $usage_data_provider_id =
        $t->post_ok( "//$userid:$password@/api/v1/erm/usage_data_providers" => json => $usage_data_provider )
        ->status_is( 201, 'REST3.2.1' )
        ->header_like(
        Location => qr|^/api/v1/erm/usage_data_providers/\d*|,
        'REST3.4.1'
        )
        ->json_is( '/name'           => $usage_data_provider->{name} )
        ->json_is( '/customer_id'    => $usage_data_provider->{customer_id} )
        ->json_is( '/requestor_id'   => $usage_data_provider->{requestor_id} )
        ->json_is( '/api_key'        => $usage_data_provider->{api_key} )
        ->json_is( '/service_url'    => $usage_data_provider->{service_url} )
        ->json_is( '/report_release' => $usage_data_provider->{report_release} )
        ->tx->res->json->{erm_usage_data_provider_id};

    # Authorized attempt to create with null id
    $usage_data_provider->{erm_usage_data_provider_id} = undef;
    $t->post_ok( "//$userid:$password@/api/v1/erm/usage_data_providers" => json => $usage_data_provider )
        ->status_is(400)
        ->json_has('/errors');

    # Authorized attempt to create with existing id
    $usage_data_provider->{erm_usage_data_provider_id} = $usage_data_provider_id;
    $t->post_ok( "//$userid:$password@/api/v1/erm/usage_data_providers" => json => $usage_data_provider )
        ->status_is(400)
        ->json_is(
        "/errors" => [
            {
                message => "Read-only.",
                path    => "/body/erm_usage_data_provider_id"
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

    my $usage_data_provider_id =
        $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } )->erm_usage_data_provider_id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $usage_data_provider_with_missing_field = {
        description    => 'New description',
        customer_id    => "1",
        requestor_id   => "1",
        api_key        => "1",
        service_url    => "www.test.co.uk",
        report_release => "test"
    };

    $t->put_ok( "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id" => json =>
            $usage_data_provider_with_missing_field )
        ->status_is(400)
        ->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $usage_data_provider_with_updated_field = {
        name           => 'New name',
        description    => 'New description',
        customer_id    => "1",
        requestor_id   => "1",
        api_key        => "1",
        service_url    => "www.test.co.uk",
        report_release => "test"
    };

    $t->put_ok( "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id" => json =>
            $usage_data_provider_with_updated_field )->status_is(200)->json_is( '/name' => 'New name' );

    # Authorized attempt to write invalid data
    my $usage_data_provider_with_invalid_field = {
        blah        => "usage_data_provider Blah",
        name        => "usage_data_provider name",
        description => "usage_data_provider description",
    };

    $t->put_ok( "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id" => json =>
            $usage_data_provider_with_invalid_field )->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: blah.",
                path    => "/body"
            }
        ]
            );

    # Attempt to update non-existent usage_data_provider
    my $usage_data_provider_to_delete = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $non_existent_id               = $usage_data_provider_to_delete->erm_usage_data_provider_id;
    $usage_data_provider_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/erm/usage_data_providers/$non_existent_id" => json =>
            $usage_data_provider_with_updated_field )->status_is(404);

    # Wrong method (POST)
    $usage_data_provider_with_updated_field->{erm_usage_data_provider_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id" => json =>
            $usage_data_provider_with_updated_field )->status_is(404);

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

    my $usage_data_provider_id =
        $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } )->erm_usage_data_provider_id;

    # Unauthorized attempt to delete
    $t->delete_ok("//$unauth_userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id")
        ->status_is(403);

    # Delete existing usage_data_provider
    $t->delete_ok("//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id")
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( '', 'REST3.3.4' );

    # Attempt to delete non-existent usage_data_provider
    $t->delete_ok("//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id")->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'process_SUSHI_response() tests' => sub {

    plan tests => 27;

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

    my $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => { report_types => 'TR_J1;PR' }
        }
    );
    my $usage_data_provider_id = $usage_data_provider->erm_usage_data_provider_id;

    my $dates = { begin_date => '2023-08-15', end_date => '2023-10-02' };

    # Unauthorized attempt
    $t->post_ok(
        "//$unauth_userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => $dates )->status_is(403);

    # Both dates are required
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => { begin_date => '2023-08-15' } )->status_is(400);

    # Begin date must be before end date
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => { begin_date => '2023-10-02', end_date => '2023-08-15' } )
        ->status_is(400)
        ->json_is( '/error' => 'Begin date must not be after end date' );

    # Equal dates give one job per report type
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => { begin_date => '2023-08-15', end_date => '2023-08-15' } )->status_is(200);
    is( scalar @{ $t->tx->res->json->{jobs} }, 2, 'Equal dates give one job per report type' );

    # A begin date in the future is rejected
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => { begin_date => '2999-01-01', end_date => '2999-01-31' } )
        ->status_is(400)
        ->json_is( '/error' => 'begin_date must not be in the future' );

    # Unknown usage data provider
    my $non_existent_id = $usage_data_provider_id;
    $usage_data_provider->delete;
    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$non_existent_id/process_SUSHI_response" => json =>
            $dates )->status_is(404)->json_is( '/error' => 'Usage data provider not found' );

    # One job per report type and per month
    $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => { report_types => 'TR_J1;PR' }
        }
    );
    $usage_data_provider_id = $usage_data_provider->erm_usage_data_provider_id;

    $t->post_ok(
        "//$userid:$password@/api/v1/erm/usage_data_providers/$usage_data_provider_id/process_SUSHI_response" =>
            json => $dates )->status_is(200)->json_has('/jobs');

    my $jobs = $t->tx->res->json->{jobs};
    is( scalar @{$jobs},           6,            '2 report types x 3 months = 6 jobs' );
    is( $jobs->[0]->{report_type}, 'TR_J1',      'First job is for the first report type' );
    is( $jobs->[0]->{begin_date},  '2023-08-15', 'First job starts on the requested begin date' );
    is( $jobs->[0]->{end_date},    '2023-08-31', 'First job ends at the end of the first month' );
    is( $jobs->[2]->{begin_date},  '2023-10-01', 'Last month starts on the first day' );
    is( $jobs->[2]->{end_date},    '2023-10-02', 'Last month ends on the requested end date' );
    is( $jobs->[3]->{report_type}, 'PR',         'Fourth job is for the second report type' );
    ok( $jobs->[0]->{job_id}, 'Each job has a job_id' );

    $schema->storage->txn_rollback;
};
