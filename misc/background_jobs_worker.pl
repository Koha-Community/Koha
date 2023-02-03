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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

background_jobs_worker.pl - Worker script that will process background jobs

=head1 SYNOPSIS

./background_jobs_worker.pl [--queue QUEUE]

=head1 DESCRIPTION

This script will connect to the Stomp server (RabbitMQ) and subscribe to the queues passed in parameter (or the 'default' queue),
or if a Stomp server is not active it will poll the database every 10s for new jobs in the passed queue.

You can specify some queues only (using --queue, which is repeatable) if you want to run several workers that will handle their own jobs.

=head1 OPTIONS

=over

=item B<--queue>

Repeatable. Give the job queues this worker will process.

The different values available are:

    default
    long_tasks

=back

=cut

use Modern::Perl;
use JSON qw( decode_json );
use Try::Tiny;
use Pod::Usage;
use Getopt::Long;

use Koha::Logger;
use Koha::BackgroundJobs;

my ( $help, @queues );
GetOptions(
    'h|help' => \$help,
    'queue=s' => \@queues,
) || pod2usage(1);

pod2usage(0) if $help;

unless (@queues) {
    push @queues, 'default';
}

my $conn;
try {
    $conn = Koha::BackgroundJob->connect;
} catch {
    warn sprintf "Cannot connect to the message broker, the jobs will be processed anyway (%s)", $_;
};

if ( $conn ) {
    # FIXME cf note in Koha::BackgroundJob about $namespace
    my $namespace = C4::Context->config('memcached_namespace');
    for my $queue (@queues) {
        $conn->subscribe({
            destination => sprintf("/queue/%s-%s", $namespace, $queue),
            ack => 'client',
            'prefetch-count' => 1,
        });
    }
}
while (1) {
    if ( $conn ) {
        my $frame = $conn->receive_frame;
        if ( !defined $frame ) {
            # maybe log connection problems
            next;    # will reconnect automatically
        }

        my $args = try {
            my $body = $frame->body;
            decode_json($body); # TODO Should this be from_json? Check utf8 flag.
        } catch {
            Koha::Logger->get({ interface => 'worker' })->warn(sprintf "Frame not processed - %s", $_);
            return;
        } finally {
            $conn->ack( { frame => $frame } );
        };

        next unless $args;

        # FIXME This means we need to have create the DB entry before
        # It could work in a first step, but then we will want to handle job that will be created from the message received
        my $job = Koha::BackgroundJobs->find($args->{job_id});

        unless ( $job ) {
            Koha::Logger->get({ interface => 'worker' })->warn(sprintf "No job found for id=%s", $args->{job_id});
            next;
        }

        process_job( $job, $args );

    } else {
        my $jobs = Koha::BackgroundJobs->search({ status => 'new', queue => \@queues });
        while ( my $job = $jobs->next ) {
            my $args = try {
                $job->json->decode($job->data);
            } catch {
                Koha::Logger->get({ interface => 'worker' })->warn(sprintf "Cannot decode data for job id=%s", $job->id);
                $job->status('failed')->store;
                return;
            };

            next unless $args;

            process_job( $job, { job_id => $job->id, %$args } );

        }
        sleep 10;
    }
}
$conn->disconnect;

sub process_job {
    my ( $job, $args ) = @_;

    my $pid;
    if ( $pid = fork ) {
        wait;
        return;
    }

    die "fork failed!" unless defined $pid;

    try {
        $job->process( $args );
    } catch {
        $job->status('failed')->store;
    };

    exit;
}
