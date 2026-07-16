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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::NoWarnings;
use Test::MockModule;
use JSON       qw( decode_json );
use File::Temp qw( tempdir );
use File::Spec;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::TestTransport;
use Koha::File::Transports;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'process() records the full trace (successes and the failure), not only the last error' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $tempdir      = tempdir( CLEANUP => 1 );
    my $download_dir = File::Spec->catdir( $tempdir, 'download' );
    my $upload_dir   = File::Spec->catdir( $tempdir, 'upload' );
    mkdir $download_dir or die "Cannot create download_dir: $!";
    mkdir $upload_dir   or die "Cannot create upload_dir: $!";

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport          => 'local',
                download_directory => $download_dir,
                upload_directory   => $upload_dir,
            }
        }
    );

    # test_connection() calls list_files() once per configured direction
    # (download, then upload). Simulate a real "some steps pass, one fails"
    # run: the first call (download) succeeds, the second (upload) fails.
    my $call_count = 0;
    my $mock_local = Test::MockModule->new('Koha::File::Transport::Local');
    $mock_local->mock(
        '_list_files',
        sub {
            my ($self) = @_;
            $call_count++;
            if ( $call_count == 1 ) {
                $self->add_message(
                    { message => 'list', type => 'success', payload => { path => $download_dir, count => 0 } } );
                return [];
            } else {
                $self->add_message(
                    {
                        message => 'list', type => 'error',
                        payload => { error => 'Simulated failure', path => $upload_dir }
                    }
                );
                return;
            }
        }
    );

    my $job_id = Koha::BackgroundJob::TestTransport->new->enqueue( { transport_id => $transport->id } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    $job->process( { transport_id => $transport->id } );

    is( $job->status, 'finished', 'job finished' );

    my $data = $job->decoded_data;
    is( $data->{status}, 'errors', 'overall job status is "errors" because one operation failed' );

    my @codes = map { $_->{code} } @{ $data->{operations} };
    ok(
        scalar(@codes) > 1,
        'more than one operation was recorded - the trace is not collapsed to just the final error'
    );

    my @statuses = map { $_->{status} } @{ $data->{operations} };
    ok( ( grep { $_ eq 'success' } @statuses ), 'at least one recorded operation is a success' );
    ok( ( grep { $_ eq 'error' } @statuses ),   'at least one recorded operation is an error' );

    # Order matters for display: successes should appear before the failure
    # they preceded, not just the failure on its own.
    my ($first_error_index) = grep { $statuses[$_] eq 'error' } 0 .. $#statuses;
    ok(
        ( grep { $_ eq 'success' } @statuses[ 0 .. $first_error_index - 1 ] ),
        'a success is recorded before the failing operation, preserving the full sequence'
    );

    # The transport's own status column (read by the admin UI) should match
    # what was persisted by TestTransport::process(), not something narrower.
    my $reloaded         = Koha::File::Transports->find( $transport->id );
    my $persisted_status = decode_json( $reloaded->status );
    is( $persisted_status->{status}, 'errors', q{the transport's own status column matches the job's} );
    is(
        scalar @{ $persisted_status->{operations} }, scalar @codes,
        q{the transport's own status column carries the same full trace, not a single collapsed entry}
    );

    $schema->storage->txn_rollback;
};

1;
