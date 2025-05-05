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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::ErmSushiHarvester;

use JSON           qw( decode_json );
use File::Basename qw( dirname );
use File::Slurp;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockModule;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

my $sushi_response_file_TR_J1      = dirname(__FILE__) . "/../../data/erm/eusage/TR_J1.json";
my $sushi_counter_5_response_TR_J1 = read_file($sushi_response_file_TR_J1);
my $sushi_counter_report_TR_J1 =
    Koha::ERM::EUsage::SushiCounter->new( { response => decode_json($sushi_counter_5_response_TR_J1) } );

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
                return $sushi_counter_5_response_TR_J1;
            }
        );
        $response->{_rc} = 200;
        return $response;
    }
);

subtest 'enqueue_sushi_harvest_jobs' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $patron = Koha::Patrons->search()->last;
    t::lib::Mocks::mock_userenv( { number => $patron->borrowernumber } );    # Is superlibrarian

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    my $job = Koha::BackgroundJob::ErmSushiHarvester->new(
        {
            status => 'new',
            size   => 1,
            type   => 'erm_sushi_harvester'
        }
    )->store;

    $job = Koha::BackgroundJobs->find( $job->id );
    $job->process(
        {
            job_id           => $job->id,
            ud_provider_id   => $usage_data_provider->erm_usage_data_provider_id,
            report_type      => 'TR_J1',
            begin_date       => '2023-08-01',
            end_date         => '2023-09-30',
            ud_provider_name => $usage_data_provider->name,
        }
    );

    my $report = decode_json( $job->get_from_storage->data )->{report};

    is( $report->{ud_provider_id},                        $usage_data_provider->erm_usage_data_provider_id );
    is( $report->{report_type},                           'TR_J1' );
    is( $report->{ud_provider_name},                      $usage_data_provider->name );
    is( $report->{us_report_info}->{skipped_mus},         0 );
    is( $report->{us_report_info}->{skipped_yus},         0 );
    is( $report->{us_report_info}->{added_yus},           6 );
    is( $report->{us_report_info}->{added_mus},           22 );
    is( $report->{us_report_info}->{added_usage_objects}, 2 );

    # Subsequent job
    my $another_job = Koha::BackgroundJob::ErmSushiHarvester->new(
        {
            status => 'new',
            size   => 1,
            type   => 'erm_sushi_harvester'
        }
    )->store;

    $another_job = Koha::BackgroundJobs->find( $another_job->id );

    $another_job->process(
        {
            job_id           => $job->id,
            ud_provider_id   => $usage_data_provider->erm_usage_data_provider_id,
            report_type      => 'TR_J1',
            begin_date       => '2023-08-01',
            end_date         => '2023-09-30',
            ud_provider_name => $usage_data_provider->name,
        }
    );

    my $another_report = decode_json( $another_job->get_from_storage->data )->{report};

    is( $another_report->{ud_provider_id},                        $usage_data_provider->erm_usage_data_provider_id );
    is( $another_report->{report_type},                           'TR_J1' );
    is( $another_report->{ud_provider_name},                      $usage_data_provider->name );
    is( $another_report->{us_report_info}->{skipped_mus},         22 );
    is( $another_report->{us_report_info}->{skipped_yus},         6 );
    is( $another_report->{us_report_info}->{added_yus},           0 );
    is( $another_report->{us_report_info}->{added_mus},           0 );
    is( $another_report->{us_report_info}->{added_usage_objects}, 0 );

    #TODO: Test more report types

    $schema->storage->txn_rollback;

};

subtest 'enqueue_counter_file_processing_job' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    $usage_data_provider->{report_type} = 'TR_J1';

    my $job = Koha::BackgroundJob::ErmSushiHarvester->new(
        {
            status => 'new',
            size   => 1,
            type   => 'erm_sushi_harvester'
        }
    )->store;

    $job = Koha::BackgroundJobs->find( $job->id );

    $job->process(
        {
            job_id         => $job->id,
            ud_provider_id => $usage_data_provider->erm_usage_data_provider_id,
            file_content   => $sushi_counter_report_TR_J1->get_COUNTER_from_SUSHI,
        }
    );

    my $report = decode_json( $job->get_from_storage->data )->{report};

    is( $report->{ud_provider_id},                        $usage_data_provider->erm_usage_data_provider_id );
    is( $report->{report_type},                           'TR_J1' );
    is( $report->{ud_provider_name},                      $usage_data_provider->name );
    is( $report->{us_report_info}->{skipped_mus},         0 );
    is( $report->{us_report_info}->{skipped_yus},         0 );
    is( $report->{us_report_info}->{added_yus},           6 );
    is( $report->{us_report_info}->{added_mus},           22 );
    is( $report->{us_report_info}->{added_usage_objects}, 2 );

    # Subsequent job
    my $another_job = Koha::BackgroundJob::ErmSushiHarvester->new(
        {
            status => 'new',
            size   => 1,
            type   => 'erm_sushi_harvester'
        }
    )->store;

    $another_job = Koha::BackgroundJobs->find( $another_job->id );

    $another_job->process(
        {
            job_id         => $job->id,
            ud_provider_id => $usage_data_provider->erm_usage_data_provider_id,
            file_content   => $sushi_counter_report_TR_J1->get_COUNTER_from_SUSHI,
        }
    );

    my $another_report = decode_json( $another_job->get_from_storage->data )->{report};

    is( $another_report->{ud_provider_id},                        $usage_data_provider->erm_usage_data_provider_id );
    is( $another_report->{report_type},                           'TR_J1' );
    is( $another_report->{ud_provider_name},                      $usage_data_provider->name );
    is( $another_report->{us_report_info}->{skipped_mus},         22 );
    is( $another_report->{us_report_info}->{skipped_yus},         6 );
    is( $another_report->{us_report_info}->{added_yus},           0 );
    is( $another_report->{us_report_info}->{added_mus},           0 );
    is( $another_report->{us_report_info}->{added_usage_objects}, 0 );

    #TODO: Test a big file larger than max_allowed_packets
    #TODO: Test more report types

    $schema->storage->txn_rollback;

};

$ua->unmock_all;
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
                return '{
                "Code": 2010,
                "Message": "Requestor is Not Authorized to Access Usage for Institution"
            }';
            }
        );
        $response->{_rc} = 200;
        return $response;
    }
);

subtest 'enqueue_sushi_harvest_jobs_error_handling' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $usage_data_provider_error = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    my $job = Koha::BackgroundJob::ErmSushiHarvester->new(
        {
            status => 'new',
            size   => 1,
            type   => 'erm_sushi_harvester'
        }
    )->store;

    $job = Koha::BackgroundJobs->find( $job->id );

    $job->process(
        {
            job_id         => $job->id,
            ud_provider_id => $usage_data_provider_error->erm_usage_data_provider_id,
            report_type    => 'TR_J1',
        }
    );

    is( ref $job->messages,          'ARRAY', 'messages is an array' );
    is( $job->messages->[0]->{code}, 2010,    'first message has code 2010' );

    $schema->storage->txn_rollback;

};
