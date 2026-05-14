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
use Test::More tests => 4;

use JSON qw( decode_json );

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::RunReport;
use Koha::Report;
use Koha::Reports;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'job_type() tests' => sub {
    plan tests => 1;
    is( Koha::BackgroundJob::RunReport->job_type, 'run_report', 'job_type is run_report' );
};

subtest 'enqueue() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $report      = $builder->build_object( { class => 'Koha::Reports' } );
    my $sql_params  = [ 'a',  'b' ];
    my $param_names = [ 'p1', 'p2' ];

    my $job_id = Koha::BackgroundJob::RunReport->new->enqueue(
        {
            report_id   => $report->id,
            sql_params  => $sql_params,
            param_names => $param_names,
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status,    'new',        'Initial status is new' );
    is( $job->queue,     'long_tasks', 'BG report jobs use the long_tasks queue' );
    is( $job->size,      1,            'job size is 1' );
    is( $job->report_id, $report->id,  'report_id column populated for indexed lookups' );

    my $data = decode_json( $job->data );
    is_deeply( $data->{sql_params},  $sql_params,  'sql_params stored on job' );
    is_deeply( $data->{param_names}, $param_names, 'param_names stored on job' );

    $schema->storage->txn_rollback;
};

subtest 'process() with missing report' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    # Enqueue against a real report, then delete it. The FK SET NULL on
    # background_jobs.report_id nulls the column, but the JSON job_args
    # still carries the original id for the process() lookup.
    my $report    = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_id = $report->id;
    my $job_id    = Koha::BackgroundJob::RunReport->new->enqueue(
        { report_id => $report_id, sql_params => [], param_names => [] } );
    $report->delete;

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( { report_id => $report_id } );
    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->status, 'failed', 'job is marked failed when the report is missing' );
    my $data = $job->decoded_data;
    is( $data->{messages}[0]{code}, 'report_not_found', 'reports report_not_found' );
    is( $data->{report}{report_id}, $report_id,         'reports the requested report_id' );

    $schema->storage->txn_rollback;
};
