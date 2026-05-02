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
use Test::More tests => 3;
use Test::Exception;
use Test::MockModule;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio_ids = [ 1, 2 ];

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
    is(
        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => $biblio_ids } ),
        undef, 'No result when pref is off'
    );
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    throws_ok { Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue() }
    'Koha::Exceptions::MissingParameter',
        "Exception thrown if 'biblio_ids' param is missing";

    like( "$@", qr/Missing biblio_ids parameter is mandatory/, 'Expected exception message' );

    my $job_id = Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => $biblio_ids } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   scalar @{$biblio_ids}, 'Size is correct' );
    is( $job->status, 'new',                 'Initial status set correctly' );
    is( $job->queue,  'default',             'BatchUpdateItem should use the default queue' );

    $schema->storage->txn_rollback;
};

subtest 'process() respects RealTimeHoldsQueueUnallocated' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my @captured_args;
    my $mock_job = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock_job->mock(
        'update_queue_for_biblio',
        sub {
            push @captured_args, $_[0];
            return {};
        }
    );

    my $biblio = $builder->build_sample_biblio;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    # Default: full rebuild (unallocated off)
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueueUnallocated', 0 );
    @captured_args = ();

    my $job_id =
        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $biblio->biblionumber ] } );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->decoded_data );

    is( $captured_args[0]->{delete}, 1, 'delete => 1 when RealTimeHoldsQueueUnallocated is off' );
    ok( !$captured_args[0]->{unallocated}, 'unallocated not set when pref is off' );

    # Unallocated mode on
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueueUnallocated', 1 );
    @captured_args = ();

    $job_id =
        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $biblio->biblionumber ] } );
    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->decoded_data );

    is( $captured_args[0]->{delete},      0, 'delete => 0 when RealTimeHoldsQueueUnallocated is on' );
    is( $captured_args[0]->{unallocated}, 1, 'unallocated => 1 when pref is on' );

    $schema->storage->txn_rollback;
};
