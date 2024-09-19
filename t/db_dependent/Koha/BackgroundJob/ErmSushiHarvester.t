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

use Test::More tests => 3;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::ErmSushiHarvester;

use File::Basename qw( dirname );
use JSON qw( decode_json );
use File::Slurp;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockModule;
use Test::MockObject;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $sushi_response_errors = {
    'invalid_date_arguments' => '{"message":"Invalid Date Arguments","code":3020,"severity":"Error"}',
    'invalid_api_key'        => '{"Code": 2020, "Severity": "Error", "Message": "API Key Invalid"}',
};

subtest 'enqueue() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    my $job_id = Koha::BackgroundJob::ErmSushiHarvester->new->enqueue(
        {
            ud_provider_id   => $usage_data_provider->erm_usage_data_provider_id,
            report_type      => 'TR_J1',
            begin_date       => '2023-08-01',
            end_date         => '2023-09-30',
            ud_provider_name => $usage_data_provider->name,
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   1,            'Size is correct' );
    is( $job->status, 'new',        'Initial status set correctly' );
    is( $job->queue,  'long_tasks', 'ErmSushiHarvester should use the long_tasks queue' );

    $schema->storage->txn_rollback;
};

subtest 'invalid_date_arguments() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $ua = Test::MockModule->new('LWP::UserAgent');
    $ua->mock('simple_request', sub {
            return mock_sushi_response({'error'=>'invalid_date_arguments'});
    });

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    my $job_args = {
            ud_provider_id   => $usage_data_provider->erm_usage_data_provider_id,
            report_type      => 'TR_J1',
            begin_date       => '2023-08-01',
            end_date         => '2023-09-30',
            ud_provider_name => $usage_data_provider->name,
        };

    my $job_id = Koha::BackgroundJob::ErmSushiHarvester->new->enqueue($job_args);
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job_args );

    is( $job->{messages}[0]->{message}, decode_json($sushi_response_errors->{invalid_date_arguments})->{severity} . ' - ' . decode_json($sushi_response_errors->{invalid_date_arguments})->{message},'SUSHI error invalid_date_arguments is stored on job messages correctly' );
    is( $job->{messages}[0]->{type},'error','SUSHI error invalid_date_arguments is stored on job messages correctly' );
    is( $job->{messages}[0]->{code},decode_json($sushi_response_errors->{invalid_date_arguments})->{code},'SUSHI error invalid_date_arguments is stored on job messages correctly' );

    $schema->storage->txn_rollback;
};

subtest 'invalid_api_key() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $ua = Test::MockModule->new('LWP::UserAgent');
    $ua->mock('simple_request', sub {
            return mock_sushi_response({'error'=>'invalid_api_key', 'code'=>401});
    });

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    my $job_args = {
            ud_provider_id   => $usage_data_provider->erm_usage_data_provider_id,
            report_type      => 'TR_J1',
            begin_date       => '2023-08-01',
            end_date         => '2023-09-30',
            ud_provider_name => $usage_data_provider->name,
        };

    my $job_id = Koha::BackgroundJob::ErmSushiHarvester->new->enqueue($job_args);
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job_args );

    is( $job->{messages}[0]->{message}, decode_json($sushi_response_errors->{invalid_api_key})->{Severity} . ' - ' . decode_json($sushi_response_errors->{invalid_api_key})->{Message},'SUSHI error invalid_date_arguments is stored on job messages correctly' );
    is( $job->{messages}[0]->{type},'error','SUSHI error invalid_date_arguments is stored on job messages correctly' );
    is( $job->{messages}[0]->{code},decode_json($sushi_response_errors->{invalid_api_key})->{Code},'SUSHI error invalid_date_arguments is stored on job messages correctly' );

    $schema->storage->txn_rollback;
};

sub mock_sushi_response {
    my ($args) = @_;
    my $response = Test::MockObject->new();

    $response->mock('code', sub {
        return $args->{code} || 200;
    });
    $response->mock('is_error', sub {
        return 0;
    });
    $response->mock('is_redirect', sub {
        return 0;
    });
    $response->mock('decoded_content', sub {
        return $sushi_response_errors->{$args->{error}};
    });
}