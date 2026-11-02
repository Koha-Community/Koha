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

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 8;
use Test::Mojo;

use JSON qw( encode_json );

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::BackgroundJobs;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Library::Group;

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

subtest 'list endpoint, job whose report was deleted' => sub {
    plan tests => 5;
    $schema->storage->txn_begin;

    Koha::BackgroundJobs->delete;

    my $runner = make_patron( 2**16 );
    grant_reports_perm( $runner, 'execute_reports_foreground' );

    my $report = $builder->build_object( { class => 'Koha::Reports' } );
    my $job    = enqueue_report_job( $runner, 'finished', $report->id, 999 );

    # The foreign key sets background_jobs.report_id to NULL
    $report->delete;
    is( $job->get_from_storage->report_id, undef, 'report_id is NULL once the report is deleted' );

    my $jobs = $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs")->status_is(200)->tx->res->json;
    is( scalar @{$jobs},         1,     'job for a deleted report is still listed' );
    is( $jobs->[0]->{report_id}, undef, 'and has no report_id' );

    $schema->storage->txn_rollback;
};

subtest 'list endpoint, LimitReportsBy' => sub {
    plan tests => 16;
    $schema->storage->txn_begin;

    Koha::BackgroundJobs->delete;
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );

    my $my_library    = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $runner = make_patron(0);    # execute_reports_foreground only, cannot manage limits
    $runner->branchcode( $my_library->branchcode )->store;
    grant_reports_perm( $runner, 'execute_reports_foreground' );
    my $super = make_patron(1);

    my $open_report    = $builder->build_object( { class => 'Koha::Reports' } );
    my $my_report      = $builder->build_object( { class => 'Koha::Reports' } );
    my $limited_report = $builder->build_object( { class => 'Koha::Reports' } );
    $my_report->replace_library_limits( [ $my_library->branchcode ] );
    $limited_report->replace_library_limits( [ $other_library->branchcode ] );

    my $open_job    = enqueue_report_job( $runner, 'finished', $open_report->id );
    my $my_job      = enqueue_report_job( $runner, 'finished', $my_report->id );
    my $limited_job = enqueue_report_job( $runner, 'finished', $limited_report->id );

    my $deleted_report = $builder->build_object( { class => 'Koha::Reports' } );
    my $deleted_job    = enqueue_report_job( $runner, 'finished', $deleted_report->id );
    $deleted_report->delete;

    my $url = "//${\$runner->userid}:$password@/api/v1/reports/jobs?_order_by=job_id&_per_page=2";

    # The hidden job is filtered before paging, so the total and pages only count visible jobs
    my $page1 = $t->get_ok("$url&_page=1")->status_is(200)->header_is( 'X-Total-Count', 3 )->tx->res->json;
    is( scalar @{$page1}, 2, 'first page is full' );
    my $page2 = $t->get_ok("$url&_page=2")->status_is(200)->header_is( 'X-Total-Count', 3 )->tx->res->json;
    is( scalar @{$page2}, 1, 'second page has the remaining job' );

    is_deeply(
        [ sort { $a <=> $b } map { $_->{job_id} } @{$page1}, @{$page2} ],
        [ sort { $a <=> $b } $open_job->id, $my_job->id, $deleted_job->id ],
        'jobs for unrestricted reports, reports limited to my library and deleted reports are listed'
    );

    # Users who can manage report limits see every job
    $t->get_ok("//${\$super->userid}:$password@/api/v1/reports/jobs")
        ->status_is(200)
        ->header_is( 'X-Total-Count', 4, 'superlibrarian sees all jobs' );

    # With the preference off, nothing is hidden
    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    my $all =
        $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs")
        ->status_is(200)
        ->header_is( 'X-Total-Count', 4 )
        ->tx->res->json;
    ok( ( grep { $_->{job_id} == $limited_job->id } @{$all} ), 'limited job is listed when the preference is off' );

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

subtest 'running endpoint' => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    my $runner = make_patron( 2**16 );
    grant_reports_perm( $runner, 'execute_reports_foreground' );
    my $other = make_patron( 2**16 );
    grant_reports_perm( $other, 'execute_reports_background' );

    my $report   = $builder->build_object( { class => 'Koha::Reports' } );
    my $rid      = $report->id;
    my $bnum     = $runner->borrowernumber;
    my $other_id = $other->borrowernumber;

    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        '_processlist_rows',
        sub {
            return [
                {
                    id   => 101,
                    time => 12,
                    info => "SELECT 1 /* { saved_sql.id: $rid } { user_id: $bnum } { run_type: foreground } */"
                },
                {
                    id   => 102,
                    time => 30,
                    info => "SELECT 1 /* { saved_sql.id: $rid } { user_id: $other_id } { run_type: background } */"
                },
            ];
        }
    );

    my $body =
        $t->get_ok("//${\$runner->userid}:$password@/api/v1/reports/jobs/running")->status_is(200)->tx->res->json;

    is( scalar @{$body}, 2, 'foreground and background threads both returned' );
    my @by_pid = sort { $a->{process_id} <=> $b->{process_id} } @{$body};
    is( $by_pid[0]{run_type}, 'foreground', 'first row is foreground' );
    is( $by_pid[0]{seconds},  12,           'seconds surfaced from processlist' );
    is( $by_pid[1]{run_type}, 'background', 'second row is background' );
    is( $by_pid[1]{seconds},  30,           'seconds for the BG worker thread' );

    $schema->storage->txn_rollback;
};

subtest 'running endpoint, LimitReportsBy' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my $runner = make_patron(0);
    grant_reports_perm( $runner, 'execute_reports_foreground' );
    my $super = make_patron(1);
    my $other = make_patron(0);

    # The runner's library and a sibling library are in the same reports group
    my $library_sibling = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_outside = $builder->build_object( { class => 'Koha::Libraries' } );

    my $root  = Koha::Library::Group->new( { title     => 'reports root', ft_reports => 1 } )->store;
    my $group = Koha::Library::Group->new( { parent_id => $root->id, title => 'reports group' } )->store;
    Koha::Library::Group->new( { parent_id => $group->id, branchcode => $runner->branchcode } )->store;
    Koha::Library::Group->new( { parent_id => $group->id, branchcode => $library_sibling->branchcode } )->store;

    my $report_open    = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_sibling = $builder->build_object( { class => 'Koha::Reports' } );
    my $report_outside = $builder->build_object( { class => 'Koha::Reports' } );
    $report_sibling->replace_library_limits( [ $library_sibling->branchcode ] );
    $report_outside->replace_library_limits( [ $library_outside->branchcode ] );

    my $reports_mock = Test::MockModule->new('Koha::Reports');
    $reports_mock->mock(
        '_active_report_runs',
        sub {
            return (
                {
                    report_id  => $report_open->id, user_id => $other->borrowernumber, run_type => 'foreground',
                    process_id => 1, seconds => 5
                },
                {
                    report_id  => $report_sibling->id, user_id => $other->borrowernumber, run_type => 'foreground',
                    process_id => 2, seconds => 5
                },
                {
                    report_id  => $report_outside->id, user_id => $other->borrowernumber, run_type => 'foreground',
                    process_id => 3, seconds => 5
                },
            );
        }
    );

    my $runner_url = "//${\$runner->userid}:$password@/api/v1/reports/jobs/running";
    my $super_url  = "//${\$super->userid}:$password@/api/v1/reports/jobs/running";
    my $rows;

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library' );
    $rows = $t->get_ok($runner_url)->status_is(200)->tx->res->json;
    is( scalar @$rows,           1,                'library: only one report is shown' );
    is( $rows->[0]->{report_id}, $report_open->id, 'library: it is the unlimited report' );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'library_group' );
    $rows = $t->get_ok($runner_url)->status_is(200)->tx->res->json;
    is( scalar @$rows,           2,                   'library_group: two reports are shown' );
    is( $rows->[0]->{report_id}, $report_open->id,    'library_group: the unlimited report is shown' );
    is( $rows->[1]->{report_id}, $report_sibling->id, 'library_group: the report limited to the same group is shown' );

    $rows = $t->get_ok($super_url)->status_is(200)->tx->res->json;
    is( scalar @$rows, 3, 'superlibrarian: all reports are shown' );

    t::lib::Mocks::mock_preference( 'LimitReportsBy', 'none' );
    $rows = $t->get_ok($runner_url)->status_is(200)->tx->res->json;
    is( scalar @$rows, 3, 'none: all reports are shown' );

    $schema->storage->txn_rollback;
};
