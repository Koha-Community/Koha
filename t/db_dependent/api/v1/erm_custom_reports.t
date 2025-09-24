#!/usr/bin/env perl

# Copyright PTFS Europe 2023

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
use Test::More tests => 9;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::ERM::EUsage::SushiCounter;
use Koha::ERM::EUsage::MonthlyUsages;
use Koha::ERM::EUsage::YearlyUsages;

use JSON           qw( decode_json );
use File::Basename qw( dirname );
use File::Slurp;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $sushi_response_file_TR_J1      = dirname(__FILE__) . "/../../data/erm/eusage/COUNTER_5/TR_J1.json";
my $sushi_counter_5_response_TR_J1 = decode_json( read_file($sushi_response_file_TR_J1) );
my $report_items                   = $sushi_counter_5_response_TR_J1->{Report_Items};
my $sushi_counter_TR_J1 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_J1 } );

subtest "monthly_report" => sub {
    plan tests => 17;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/monthly_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_muses.year":2023,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 2;    # One title, with one row for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[6,7,8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        },
        {
            "erm_usage_muses.year":2021,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[8,9,10],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results2 = 4;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 4 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 3 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "yearly_report" => sub {
    plan tests => 17;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/yearly_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=
        {
            "erm_usage_yuses.year":[2023],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=
        {
            "erm_usage_yuses.year":[2021],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';
    my $expected_results1 = 2;    # One title, with one row for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=
        {
            "erm_usage_yuses.year":[2021,2022],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';
    my $expected_results2 = 4;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 4 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 3 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "metric_types_report" => sub {
    plan tests => 14;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/metric_types_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_muses.year":2023,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 1;    # One title

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[6,7,8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        },
        {
            "erm_usage_muses.year":2021,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[8,9,10],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results2 = 2;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "provider_rollup_report" => sub {
    plan tests => 9;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_titles.erm_usage_muses.year":2023,
            "erm_usage_titles.erm_usage_muses.report_type":"TR_J1",
            "erm_usage_titles.erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_titles.erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_titles.erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_titles.erm_usage_muses.year":2022,
            "erm_usage_titles.erm_usage_muses.report_type":"TR_J1",
            "erm_usage_titles.erm_usage_muses.month":[8],
            "erm_usage_titles.erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 2;    # One provider repeated once for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_titles.erm_usage_muses' } )->status_is(200)
        ->json_is( '/' . ( $expected_results1 - 2 ) . '/provider_rollup_total' => 2, 'Total is correct' )
        ->json_is( '/' . ( $expected_results1 - 1 ) . '/provider_rollup_total' => 1, 'Total is correct' );

    $schema->storage->txn_rollback;
};

my $sushi_response_file_51_TR_J1    = dirname(__FILE__) . "/../../data/erm/eusage/COUNTER_5.1/TR_J1.json";
my $sushi_counter_51_response_TR_J1 = decode_json( read_file($sushi_response_file_51_TR_J1) );
my $sushi_counter_51_TR_J1 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_51_response_TR_J1 } );

subtest "5.1 monthly_report" => sub {
    plan tests => 17;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_51_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/monthly_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_muses.year":2023,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[6],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 2;    # One title, with one row for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,6,7,8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        },
        {
            "erm_usage_muses.year":2021,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results2 = 4;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/monthly_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 4 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 3 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "5.1 yearly_report" => sub {
    plan tests => 17;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_51_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/yearly_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=
        {
            "erm_usage_yuses.year":[2023],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=
        {
            "erm_usage_yuses.year":[2022],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';
    my $expected_results1 = 4;    # Two titles, with one row for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=
        {
            "erm_usage_yuses.year":[2021,2022],
            "erm_usage_yuses.report_type":"TR_J1",
            "erm_usage_yuses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ';
    my $expected_results2 = 4;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/yearly_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_yuses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 4 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 3 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "5.1 metric_types_report" => sub {
    plan tests => 14;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_51_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/metric_types_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_muses.year":2023,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[6],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 1;    # One title

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results1 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results1) . '/title_id' );

    my $query_string_with_multiple_years = 'q=[
        {
            "erm_usage_muses.year":2022,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3,6,7,8],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        },
        {
            "erm_usage_muses.year":2021,
            "erm_usage_muses.report_type":"TR_J1",
            "erm_usage_muses.month":[1,2,3],
            "erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results2 = 2;    # Two titles this time

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/metric_types_report/title?$query_string_with_multiple_years" =>
            { 'x-koha-embed' => 'erm_usage_muses' } )->status_is(200)
        ->json_has( '/' . ( $expected_results2 - 2 ) . '/title_id' )
        ->json_has( '/' . ( $expected_results2 - 1 ) . '/title_id' )
        ->json_hasnt( '/' . ($expected_results2) . '/title_id' );

    $schema->storage->txn_rollback;
};

subtest "5.1 provider_rollup_report" => sub {
    plan tests => 9;

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
    t::lib::Mocks::mock_userenv( { number => $userid } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Run a harvest to populate the database with data
    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );
    my $counter_file        = $sushi_counter_51_TR_J1->get_COUNTER_from_SUSHI;

    $usage_data_provider->counter_files(
        [
            {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $counter_file,
                filename               => "Test_TR_J1",
            }
        ]
    );

    # Unauthorized access
    $t->get_ok("//$unauth_userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title")->status_is(403);

    # Authorised access
    my $query_string_with_no_results = 'q=[
        {
            "erm_usage_titles.erm_usage_muses.year":2023,
            "erm_usage_titles.erm_usage_muses.report_type":"TR_J1",
            "erm_usage_titles.erm_usage_muses.month":[1,2,3,4,5,6,7,8,9,10,11,12],
            "erm_usage_titles.erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title?$query_string_with_no_results" =>
            { 'x-koha-embed' => 'erm_usage_titles.erm_usage_muses' } )->status_is(200)->json_is( [] );

    my $query_string = 'q=[
        {
            "erm_usage_titles.erm_usage_muses.year":2022,
            "erm_usage_titles.erm_usage_muses.report_type":"TR_J1",
            "erm_usage_titles.erm_usage_muses.month":[1,6],
            "erm_usage_titles.erm_usage_muses.metric_type":["Total_Item_Requests","Unique_Item_Requests"]
        }
    ]';
    my $expected_results1 = 2;    # One provider repeated once for each metric type

    $t->get_ok( "//$userid:$password@/api/v1/erm/eUsage/provider_rollup_report/title?$query_string" =>
            { 'x-koha-embed' => 'erm_usage_titles.erm_usage_muses' } )->status_is(200)
        ->json_is( '/' . ( $expected_results1 - 2 ) . '/provider_rollup_total' => 528, 'Total is correct' )
        ->json_is( '/' . ( $expected_results1 - 1 ) . '/provider_rollup_total' => 228, 'Total is correct' );

    $schema->storage->txn_rollback;
};
