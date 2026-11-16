#!/usr/bin/perl

# This file is part of Koha
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
use Test::More tests => 6;
use Test::Exception;
use Time::Fake;
use DateTime;

use Koha::BackgroundJobs;
use Koha::ERM::EUsage::UsageDataProvider;
use Koha::Database;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_build_url_query' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $service_url  = 'https://service_url.com';
    my $api_key      = 'APIKEY';
    my $requestor_id = 'REQID123';
    my $customer_id  = 'ID123';
    my $name         = 'TestProvider';

    my $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url => $service_url, api_key => $api_key, requestor_id     => $requestor_id,
                customer_id => $customer_id, name    => $name,    service_platform => undef, report_release => 5
            }
        }
    );

    $usage_data_provider->{report_type} = 'TR_J1';
    $usage_data_provider->{begin_date}  = '2023-08-01';
    $usage_data_provider->{end_date}    = '2023-09-30';

    is(
        $usage_data_provider->_build_url_query,
        $service_url
            . '/reports/'
            . lc( $usage_data_provider->{report_type} )
            . '?customer_id='
            . $customer_id
            . '&requestor_id='
            . $requestor_id
            . '&api_key='
            . $api_key
            . '&begin_date='
            . substr( $usage_data_provider->{begin_date}, 0, 7 )
            . '&end_date='
            . substr( $usage_data_provider->{end_date}, 0, 7 )
    );

    my $test_platform = 'www.whatever.com';

    my $usage_data_provider_with_platform = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url => $service_url, api_key => $api_key, requestor_id  => $requestor_id,
                customer_id => $customer_id, name    => $name, service_platform => $test_platform, report_release => 5
            }
        }
    );

    $usage_data_provider_with_platform->{report_type} = 'TR_J1';
    $usage_data_provider_with_platform->{begin_date}  = '2023-08-01';
    $usage_data_provider_with_platform->{end_date}    = '2023-09-30';

    is(
        $usage_data_provider_with_platform->_build_url_query,
        $service_url
            . '/reports/'
            . lc( $usage_data_provider->{report_type} )
            . '?customer_id='
            . $customer_id
            . '&requestor_id='
            . $requestor_id
            . '&api_key='
            . $api_key
            . '&begin_date='
            . substr( $usage_data_provider->{begin_date}, 0, 7 )
            . '&end_date='
            . substr( $usage_data_provider->{end_date}, 0, 7 )
            . '&platform='
            . $test_platform
    );

    my $usage_data_provider_51 = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url => $service_url, api_key => $api_key, requestor_id => $requestor_id,
                customer_id => $customer_id, name => $name, service_platform => $test_platform, report_release => '5.1'
            }
        }
    );

    $usage_data_provider_51->{report_type} = 'TR_J1';
    $usage_data_provider_51->{begin_date}  = '2023-08-01';
    $usage_data_provider_51->{end_date}    = '2023-09-30';

    is(
        $usage_data_provider_51->_build_url_query,
        $service_url
            . '/r51/reports/'
            . lc( $usage_data_provider->{report_type} )
            . '?customer_id='
            . $customer_id
            . '&requestor_id='
            . $requestor_id
            . '&api_key='
            . $api_key
            . '&begin_date='
            . substr( $usage_data_provider->{begin_date}, 0, 7 )
            . '&end_date='
            . substr( $usage_data_provider->{end_date}, 0, 7 )
            . '&platform='
            . $test_platform
    );

    $schema->storage->txn_rollback;

};

subtest '_build_url_query access_method' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url    => 'https://service_url.com', customer_id => 'ID123', service_platform => undef,
                report_release => 5
            }
        }
    );

    # Only the usage for the Regular access method is stored. A master report includes all access methods by
    # default, the standard views are preset to Regular
    foreach my $report_type (qw( PR DR TR IR )) {
        $usage_data_provider->{report_type} = $report_type;
        like( $usage_data_provider->_build_url_query, qr/&access_method=Regular$/, "$report_type asks for Regular" );
    }

    foreach my $report_type (qw( PR_P1 TR_J1 IR_A1 )) {
        $usage_data_provider->{report_type} = $report_type;
        unlike( $usage_data_provider->_build_url_query, qr/access_method/, "$report_type does not ask for it" );
    }

    $schema->storage->txn_rollback;
};

subtest 'test_connection() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $ua = Test::MockModule->new('LWP::UserAgent');
    $ua->mock(
        'simple_request',
        sub {
            my $response = Test::MockObject->new();

            $response->mock(
                'code',
                sub {
                    return 200;
                }
            );
            $response->mock(
                'is_error',
                sub {
                    return 0;
                }
            );
            $response->mock(
                'is_redirect',
                sub {
                    return 0;
                }
            );
            $response->mock(
                'decoded_content',
                sub {
                    return
                        '{"Description":"COUNTER Usage Reports for Test platform.","ServiceActive":true,"RegistryURL":"https://www.whatever.com"}';
                }
            );
            $response->{_rc} = 200;
            return $response;
        }
    );

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    is( $usage_data_provider->test_connection, 1 );

    $schema->storage->txn_rollback;
};

subtest 'harvest_periods() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageDataProviders' } );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2023-08-05', end_date => '2023-08-20' } ),
        [ { begin_date => '2023-08-05', end_date => '2023-08-20' } ],
        'A range inside one month gives one period with the exact dates'
    );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2023-11-15', end_date => '2024-02-02' } ),
        [
            { begin_date => '2023-11-15', end_date => '2023-11-30' },
            { begin_date => '2023-12-01', end_date => '2023-12-31' },
            { begin_date => '2024-01-01', end_date => '2024-01-31' },
            { begin_date => '2024-02-01', end_date => '2024-02-02' },
        ],
        'A range across a year boundary is split into months, keeping the exact first and last dates'
    );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2024-01-01', end_date => '2024-03-31' } ),
        [
            { begin_date => '2024-01-01', end_date => '2024-01-31' },
            { begin_date => '2024-02-01', end_date => '2024-02-29' },
            { begin_date => '2024-03-01', end_date => '2024-03-31' },
        ],
        'Month-aligned dates and a leap year are handled'
    );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2023-08-15', end_date => '2023-08-15' } ),
        [ { begin_date => '2023-08-15', end_date => '2023-08-15' } ],
        'Equal begin and end dates give one period'
    );

    throws_ok {
        $usage_data_provider->harvest_periods( { begin_date => '2023-08-01' } );
    }
    'Koha::Exceptions::MissingParameter', 'A missing end_date throws MissingParameter';

    throws_ok {
        $usage_data_provider->harvest_periods( { begin_date => '2023-09-01', end_date => '2023-08-31' } );
    }
    'Koha::Exceptions::BadParameter', 'A begin_date after the end_date throws BadParameter';

    # Today is 2024-06-15 for the next cases
    Time::Fake->offset( DateTime->new( year => 2024, month => 6, day => 15, hour => 12 )->epoch );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2024-05-20', end_date => '2024-08-01' } ),
        [
            { begin_date => '2024-05-20', end_date => '2024-05-31' },
            { begin_date => '2024-06-01', end_date => '2024-06-15' },
        ],
        'An end date in the future is reduced to today'
    );

    is_deeply(
        $usage_data_provider->harvest_periods( { begin_date => '2024-06-01', end_date => '2024-06-15' } ),
        [ { begin_date => '2024-06-01', end_date => '2024-06-15' } ],
        'An end date of today is kept'
    );

    throws_ok {
        $usage_data_provider->harvest_periods( { begin_date => '2024-07-01', end_date => '2024-08-01' } );
    }
    'Koha::Exceptions::BadParameter', 'A begin_date in the future throws BadParameter';

    Time::Fake->reset;

    $schema->storage->txn_rollback;
};

subtest 'enqueue_sushi_harvest_jobs() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => { name => 'TestProvider', report_types => 'TR_J1;PR' }
        }
    );

    my $jobs_before = Koha::BackgroundJobs->search( { type => 'erm_sushi_harvester' } )->count;

    my $jobs = $usage_data_provider->enqueue_sushi_harvest_jobs(
        {
            begin_date => '2023-08-15',
            end_date   => '2023-10-02',
        }
    );

    is( scalar @{$jobs}, 6, 'One job per report type and per month is enqueued' );
    is(
        Koha::BackgroundJobs->search( { type => 'erm_sushi_harvester' } )->count, $jobs_before + 6,
        '6 background jobs were created'
    );

    is_deeply(
        [ map { $_->{report_type} } @{$jobs} ],
        [ 'TR_J1', 'TR_J1', 'TR_J1', 'PR', 'PR', 'PR' ],
        'Jobs are ordered by report type'
    );
    is_deeply(
        [ map { [ $_->{begin_date}, $_->{end_date} ] } @{$jobs} ],
        [
            [ '2023-08-15', '2023-08-31' ],
            [ '2023-09-01', '2023-09-30' ],
            [ '2023-10-01', '2023-10-02' ],
            [ '2023-08-15', '2023-08-31' ],
            [ '2023-09-01', '2023-09-30' ],
            [ '2023-10-01', '2023-10-02' ],
        ],
        'Each job covers one month and the first and last keep the exact dates'
    );

    my @job_ids = map { $_->{job_id} } @{$jobs};
    is( scalar( keys %{ { map { $_ => 1 } @job_ids } } ), 6, 'Every job has its own job_id' );

    my $second_job = Koha::BackgroundJobs->find( $jobs->[1]->{job_id} );
    my $job_args   = $second_job->decoded_data;
    is(
        $job_args->{ud_provider_id}, $usage_data_provider->erm_usage_data_provider_id,
        'Job args hold the provider id'
    );
    is( $job_args->{ud_provider_name}, 'TestProvider', 'Job args hold the provider name' );
    is( $job_args->{report_type},      'TR_J1',        'Job args hold the report type' );
    is( $job_args->{begin_date},       '2023-09-01',   'Job args hold the monthly begin date' );
    is( $job_args->{end_date},         '2023-09-30',   'Job args hold the monthly end date' );

    throws_ok {
        $usage_data_provider->enqueue_sushi_harvest_jobs( { begin_date => '2023-08-01' } );
    }
    'Koha::Exceptions::MissingParameter', 'A missing date is rejected before any job is enqueued';

    $schema->storage->txn_rollback;
};
