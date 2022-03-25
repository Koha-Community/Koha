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
use Test::Exception;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateItem;

use JSON qw( decode_json );

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_derived_class() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $job_object = Koha::BackgroundJob->new();
    my $mapping = $job_object->type_to_class_mapping;

    # pick the first
    my $type = ( keys %{$mapping} )[0];

    my $job = $builder->build_object(
        {   class => 'Koha::BackgroundJobs',
            value => { type => $type, data => 'Foo' }
        }
    );

    my $derived = $job->_derived_class;

    is( ref($derived), $mapping->{$type}, 'Job object class is correct' );
    ok( $derived->in_storage, 'The object is correctly marked as in storage' );

    $derived->data('Bar')->store->discard_changes;
    $job->discard_changes;

    is_deeply( $job->unblessed, $derived->unblessed, '_derived_class object refers to the same DB object and can be manipulated as expected' );

    $schema->storage->txn_rollback;
};

subtest 'enqueue() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # FIXME: This all feels we need to do it better...
    my $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2 ] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           2,     'Two steps' );
    is( $job->status,         'new', 'Initial status set correctly' );
    is( $job->borrowernumber, undef, 'No userenv, borrowernumber undef' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2, 3 ] } );
    $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           3,           'Three steps' );
    is( $job->status,         'new',       'Initial status set correctly' );
    is( $job->borrowernumber, $patron->id, 'No userenv, borrowernumber undef' );

    $schema->storage->txn_rollback;
};

subtest 'start(), step() and finish() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    # FIXME: This all feels we need to do it better...
    my $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2 ] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->started_on, undef, 'started_on not set yet' );
    is( $job->size, 2, 'Two steps' );

    $job->start;

    isnt( $job->started_on, undef, 'started_on set' );
    is( $job->status, 'started' );
    is( $job->progress, 0, 'No progress yet' );

    $job->step;
    is( $job->progress, 1, 'First step' );
    $job->step;
    is( $job->progress, 2, 'Second step' );
    throws_ok
        { $job->step; }
        'Koha::Exceptions::BackgroundJob::StepOutOfBounds',
        'Tried to make a forbidden extra step';

    is( $job->progress, 2, 'progress remains unchanged' );

    my $data = { some => 'data' };

    $job->status('cancelled')->store;
    $job->finish( $data );

    is( $job->status, 'cancelled', "'finish' leaves 'cancelled' untouched" );
    isnt( $job->ended_on, undef, 'ended_on set' );
    is_deeply( decode_json( $job->data ), $data );

    $job->status('started')->store;
    $job->finish( $data );

    is( $job->status, 'finished' );
    isnt( $job->ended_on, undef, 'ended_on set' );
    is_deeply( decode_json( $job->data ), $data );

    throws_ok
        { $job->start; }
        'Koha::Exceptions::BackgroundJob::InconsistentStatus',
        'Exception thrown trying to start a finished job';

    is( $@->expected_status, 'new' );

    throws_ok
        { $job->step; }
        'Koha::Exceptions::BackgroundJob::InconsistentStatus',
        'Exception thrown trying to start a finished job';

    is( $@->expected_status, 'started' );

    $schema->storage->txn_rollback;
};
