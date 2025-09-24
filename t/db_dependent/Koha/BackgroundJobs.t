#!/usr/bin/perl

# Copyright 2020 Koha Development team
#
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
use Test::More tests => 15;
use Test::MockModule;

use List::MoreUtils qw(any);

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;
use t::lib::Koha::BackgroundJob::BatchTest;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

t::lib::Mocks::mock_userenv;

my $net_stomp = Test::MockModule->new('Net::Stomp');
$net_stomp->mock( 'send_with_receipt', sub { return 1 } );

my $background_job_module = Test::MockModule->new('Koha::BackgroundJob');
$background_job_module->mock(
    'type_to_class_mapping',
    sub {
        return { batch_test => 't::lib::Koha::BackgroundJob::BatchTest' };
    }
);

my $data     = { a => 'aaa', b => 'bbb' };
my $job_size = 10;
my $job_id   = t::lib::Koha::BackgroundJob::BatchTest->new->enqueue(
    {
        size => $job_size,
        %$data
    }
);

# Enqueuing a new job
my $new_job = Koha::BackgroundJobs->find($job_id);
ok( $new_job, 'New job correctly enqueued' );
is_deeply(
    $new_job->json->decode( $new_job->data ),
    $data, 'data retrieved and json encoded correctly'
);
is(
    t::lib::Dates::compare( $new_job->enqueued_on, dt_from_string ),
    0, 'enqueued_on correctly filled with now()'
);
is( $new_job->size,   $job_size,    'job size retrieved correctly' );
is( $new_job->status, "new",        'job has not started yet, status is new' );
is( $new_job->type,   "batch_test", 'job type retrieved from ->job_type' );

# FIXME: This behavior doesn't seem correct. It shouldn't be the background job's
#        responsibility to return 'undef'. Some higher-level check should raise a
#        proper exception.
# Test cancelled job
$new_job->status('cancelled')->store;
my $processed_job = $new_job->process;
is( $processed_job, undef );
$new_job->discard_changes;
is( $new_job->status, "cancelled", "A cancelled job has not been processed" );

# Test new job to process
$new_job->status('new')->store;
$new_job = $new_job->process;
is( $new_job->status,                  "finished", 'job is new finished!' );
is( scalar( @{ $new_job->messages } ), 10,         '10 messages generated' );
is_deeply(
    $new_job->report,
    { total_records => 10, total_success => 10 },
    'Correct number of records processed'
);

is_deeply( $new_job->additional_report(), {} );

$schema->storage->txn_rollback;

subtest 'filter_by_current() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $job_new = $builder->build_object( { class => 'Koha::BackgroundJobs', value => { status => 'new' } } );
    my $job_cancelled =
        $builder->build_object( { class => 'Koha::BackgroundJobs', value => { status => 'cancelled' } } );
    my $job_failed   = $builder->build_object( { class => 'Koha::BackgroundJobs', value => { status => 'failed' } } );
    my $job_finished = $builder->build_object( { class => 'Koha::BackgroundJobs', value => { status => 'finished' } } );

    my $rs = Koha::BackgroundJobs->search(
        { id => [ $job_new->id, $job_cancelled->id, $job_failed->id, $job_finished->id ] } );

    is( $rs->count, 4, '4 jobs in resultset' );
    ok( any { $_->status eq 'new' } @{ $rs->as_list }, "There is a 'new' job" );

    $rs = $rs->filter_by_current;

    is( $rs->count,        1,     'Only 1 job in filtered resultset' );
    is( $rs->next->status, 'new', "The only job in resultset is 'new'" );

    $schema->storage->txn_rollback;
};

subtest 'search_limited' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    my $patron1 = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $job1 =
        $builder->build_object( { class => 'Koha::BackgroundJobs', value => { borrowernumber => $patron1->id } } );

    my $cnt = Koha::BackgroundJobs->search( { borrowernumber => undef } )
        ->count;    # expected to be zero, but theoretically possible

    C4::Context->set_userenv( undef, q{} );
    is( Koha::BackgroundJobs->search_limited->count, $cnt, 'No jobs found without userenv' );
    C4::Context->set_userenv( $patron1->id, $patron1->userid );
    is( Koha::BackgroundJobs->search_limited->count, 1, 'My job found' );
    C4::Context->set_userenv( $patron2->id, $patron2->userid );
    is( Koha::BackgroundJobs->search_limited->count, 0, 'No jobs for me' );

    $schema->storage->txn_rollback;
};
