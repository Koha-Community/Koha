#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;

use Koha::BackgroundJob::BatchDeletePatron;
use Koha::BackgroundJobs;
use Koha::Database;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue(
        {
            record_ids => [ $patron_1->borrowernumber, $patron_2->borrowernumber ],
        }
    );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->status, 'new',                   'Initial status is new' );
    is( $job->queue,  'long_tasks',            'Uses the long_tasks queue' );
    is( $job->size,   2,                       'job_size equals the number of patrons passed' );
    is( $job->type,   'batch_patron_deletion', 'job_type is batch_patron_deletion' );

    is(
        Koha::BackgroundJob::BatchDeletePatron->new->enqueue( { record_ids => [] } ),
        undef, 'Nothing is enqueued when no patron is passed'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my @borrowernumbers = ( $patron_1->borrowernumber, $patron_2->borrowernumber );

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue( { record_ids => \@borrowernumbers } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'finished', 'Job finishes successfully' );

    my $report = $job->report;
    is( $report->{total_records},                       2, 'Two patrons were passed for deletion' );
    is( $report->{total_success},                       2, 'Two patrons were deleted' );
    is( scalar @{ $report->{deleted_borrowernumbers} }, 2, 'Both borrowernumbers reported as deleted' );

    is(
        Koha::Patrons->search( { borrowernumber => { '-in' => \@borrowernumbers } } )->count,
        0, 'Patrons no longer exist in the database'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() with move_to_deleted' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $borrowernumber = $patron->borrowernumber;

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue(
        {
            record_ids      => [$borrowernumber],
            move_to_deleted => 1,
        }
    );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->report->{total_success}, 1, 'The patron was deleted' );

    is(
        Koha::Patrons->search( { borrowernumber => $borrowernumber } )->count,
        0, 'Patron no longer exists in borrowers'
    );
    is(
        $schema->resultset('Deletedborrower')->search( { borrowernumber => $borrowernumber } )->count,
        1, 'Patron was copied to deletedborrowers'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() does not move a patron to deleted when delete fails' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron         = $builder->build_object( { class => 'Koha::Patrons', value => { protected => 1 } } );
    my $borrowernumber = $patron->borrowernumber;

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue(
        {
            record_ids      => [$borrowernumber],
            move_to_deleted => 1,
        }
    );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->report->{total_success}, 0, 'The protected patron was not deleted' );
    is_deeply(
        $job->report->{not_deleted_borrowernumbers}, [$borrowernumber],
        'The patron is reported as not deleted'
    );
    is( $job->messages->[0]->{reason}, 'patron_protected', 'The reason is patron_protected' );

    is(
        Koha::Patrons->search( { borrowernumber => $borrowernumber } )->count,
        1, 'Patron still exists in borrowers'
    );
    is(
        $schema->resultset('Deletedborrower')->search( { borrowernumber => $borrowernumber } )->count,
        0, 'Patron was not copied to deletedborrowers'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() skips patrons that no longer exist or already deleted' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted        = $builder->build_object( { class => 'Koha::Patrons' } );
    my $borrowernumber = $deleted->borrowernumber;
    $deleted->delete;

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue(
        {
            record_ids => [ $patron->borrowernumber, $borrowernumber ],
        }
    );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'finished', 'Job finishes when a patron has already been deleted' );

    my $report = $job->report;
    is( $report->{total_records}, 2, 'Two patrons were passed for deletion' );
    is( $report->{total_success}, 1, 'Only the existing patron was deleted' );
    is( $job->progress,           2, 'The missing patron counts towards the progress' );

    is_deeply(
        $job->messages,
        [ { type => 'warning', code => 'patron_not_found', borrowernumber => $borrowernumber } ],
        'A patron_not_found message is recorded for the missing patron'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() with cancelled job' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $borrowernumber = $patron->borrowernumber;

    my $job_id = Koha::BackgroundJob::BatchDeletePatron->new->enqueue( { record_ids => [$borrowernumber] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->status('cancelled')->store;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'cancelled', 'Cancelled job status unchanged after process()' );
    is(
        Koha::Patrons->search( { borrowernumber => $borrowernumber } )->count,
        1, 'No patron deleted for a cancelled job'
    );

    $schema->storage->txn_rollback;
};
