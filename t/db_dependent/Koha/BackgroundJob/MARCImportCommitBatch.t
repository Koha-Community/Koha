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

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 3;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::MARCImportCommitBatch;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $import_batch = $builder->build_object( { class => 'Koha::ImportBatches' } );

    # Add two records
    $builder->build_object( { class => 'Koha::Import::Records', value => { import_batch_id => $import_batch->id } } );
    $builder->build_object( { class => 'Koha::Import::Records', value => { import_batch_id => $import_batch->id } } );

    my $job_id = Koha::BackgroundJob::MARCImportCommitBatch->new->enqueue( { import_batch_id => $import_batch->id } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   2,            'Size is correct' );
    is( $job->status, 'new',        'Initial status set correctly' );
    is( $job->queue,  'long_tasks', 'BatchUpdateItem should use the long_tasks queue' );

    $schema->storage->txn_rollback;
};

subtest 'process() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $batch_return  = [];
    my $output_module = Test::MockModule->new('Koha::BackgroundJob::MARCImportCommitBatch');
    $output_module->mock(
        'BatchCommitRecords',
        sub {
            return @{$batch_return};
        }
    );
    my $import_batch = $builder->build_object( { class => 'Koha::ImportBatches' } );

    # Add two records
    $builder->build_object( { class => 'Koha::Import::Records', value => { import_batch_id => $import_batch->id } } );
    $builder->build_object( { class => 'Koha::Import::Records', value => { import_batch_id => $import_batch->id } } );

    my $job_id = Koha::BackgroundJob::MARCImportCommitBatch->new->enqueue( { import_batch_id => $import_batch->id } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    @{$batch_return} = ( 0, 0, 0, 0, 0, 2 );
    $job->process( { import_batch_id => $import_batch->id } );
    $job->discard_changes;
    is( $job->status, 'finished', 'A job where all records are ignored is a success' );

    $job->status('new')->store;
    @{$batch_return} = ( 1, 1, 0, 0, 0, 1 );
    $job->process( { import_batch_id => $import_batch->id } );
    $job->discard_changes;
    is( $job->status,   'failed', 'A job where the record counts do not match is failed' );
    is( $job->size,     '2',      'Size is based on number of records' );
    is( $job->progress, '3', 'Progress is the total number of records processed, including added/updated/ignored' );
    $schema->storage->txn_rollback;
};
