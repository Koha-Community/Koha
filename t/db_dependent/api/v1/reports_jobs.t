#!/usr/bin/env perl

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
use Test::More tests => 4;
use Test::Mojo;

use JSON qw( encode_json );

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::BackgroundJobs;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $t       = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $password = 'thePassword123';

sub make_patron {
    my ($flags) = @_;
    my $p = $builder->build_object( { class => 'Koha::Patrons', value => { flags => $flags } } );
    $p->set_password( { password => $password, skip_validation => 1 } );
    return $p;
}

sub grant_reports_perm {
    my ( $patron, $code ) = @_;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->borrowernumber,
                module_bit     => 16,                        # reports
                code           => $code,
            },
        }
    );
}

sub enqueue_report_job {
    my ( $owner, $status, $report_id, $saved_id, $enqueued_on ) = @_;
    my $data = { report_id => $report_id };
    $data->{report} = {
        report_id       => $report_id,
        saved_report_id => $saved_id,
        row_count       => 0,
    } if $saved_id;
    my %value = (
        type           => 'run_report',
        status         => $status,
        borrowernumber => $owner->borrowernumber,
        report_id      => $report_id,
        data           => encode_json($data),
    );
    $value{enqueued_on} = $enqueued_on if $enqueued_on;
    return $builder->build_object(
        {
            class => 'Koha::BackgroundJobs',
            value => \%value,
        }
    );
}

subtest 'list endpoint, auth & time range' => sub {
    plan tests => 13;
    $schema->storage->txn_begin;

    Koha::BackgroundJobs->delete;

    my $super  = make_patron(1);
    my $runner = make_patron( 2**16 );      # reports flag, no sub-perm yet
    grant_reports_perm( $runner, 'execute_reports_foreground' );
    my $catalogue = make_patron( 2**2 );    # catalogue only, no reports

    my $report = $builder->build_object( { class => 'Koha::Reports' } );

    my $now = dt_from_string;
    my $old = $now->clone->subtract( days => 2 );

    my $queued   = enqueue_report_job( $runner, 'new',      $report->id );
    my $running  = enqueue_report_job( $runner, 'started',  $report->id );
    my $finished = enqueue_report_job( $super,  'finished', $report->id, 999, $old );

    # Patron without execute_reports_* is rejected outright.
    $t->get_ok("//${\$catalogue->userid}:$password@/api/v1/reports/jobs")->status_is(403);

    # Permissioned librarian sees all three jobs.
    $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs")
        ->status_is(200)
        ->json_has('/0/job_id')
        ->json_is( '/0/type', 'run_report' );

    # 'after' filter excludes the backdated finished job.
    my $after = $now->clone->subtract( hours => 1 )->iso8601;
    my $recent =
        $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs?after=$after")->status_is(200)->tx->res->json;
    my @statuses = sort map { $_->{status} } @{$recent};
    is_deeply( \@statuses, [ 'new', 'started' ], 'after= filter excludes the backdated job' );

    # 'before' filter keeps only the backdated finished job.
    my $before = $now->clone->subtract( days => 1 )->iso8601;
    my $stale =
        $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs?before=$before")
        ->status_is(200)
        ->tx->res->json;
    is( scalar @{$stale},      1,          'before= keeps only the old job' );
    is( $stale->[0]->{status}, 'finished', 'and the kept job is the finished one' );

    $schema->storage->txn_rollback;
};

subtest 'cancel as owner' => sub {
    plan tests => 5;
    $schema->storage->txn_begin;
    Koha::BackgroundJobs->delete;

    my $owner = make_patron( 2**16 );
    grant_reports_perm( $owner, 'execute_reports_background' );

    my $report = $builder->build_object( { class => 'Koha::Reports' } );
    my $job    = enqueue_report_job( $owner, 'new', $report->id );

    $t->post_ok("//${\$owner->userid}:$password@/api/v1/reports/jobs/${\$job->id}/cancel")->status_is(204);
    is( Koha::BackgroundJobs->find( $job->id )->status, 'cancelled', 'owner cancellation flips status' );

    # Cancelling an already-cancelled job returns 409.
    $t->post_ok("//${\$owner->userid}:$password@/api/v1/reports/jobs/${\$job->id}/cancel")->status_is(409);

    $schema->storage->txn_rollback;
};

subtest 'cancel as superlibrarian and non-owner' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;
    Koha::BackgroundJobs->delete;

    my $super = make_patron(1);
    my $owner = make_patron( 2**16 );
    grant_reports_perm( $owner, 'execute_reports_background' );
    my $other = make_patron( 2**16 );
    grant_reports_perm( $other, 'execute_reports_background' );

    my $report = $builder->build_object( { class => 'Koha::Reports' } );
    my $job1   = enqueue_report_job( $owner, 'new', $report->id );
    my $job2   = enqueue_report_job( $owner, 'new', $report->id );

    # Another librarian with reports perm but who doesn't own the job is rejected.
    $t->post_ok("//${\$other->userid}:$password@/api/v1/reports/jobs/${\$job1->id}/cancel")->status_is(403);
    is( Koha::BackgroundJobs->find( $job1->id )->status, 'new', 'non-owner cancel did not change status' );

    # Superlibrarian can cancel any job.
    $t->post_ok("//${\$super->userid}:$password@/api/v1/reports/jobs/${\$job2->id}/cancel")->status_is(204);
    is(
        Koha::BackgroundJobs->find( $job2->id )->status, 'cancelled',
        'super cancelled a job owned by another librarian'
    );

    $schema->storage->txn_rollback;
};
