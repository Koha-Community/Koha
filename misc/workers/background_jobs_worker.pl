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

=head1 NAME

background_jobs_worker.pl - Worker script that will process background jobs

=head1 SYNOPSIS

./background_jobs_worker.pl [--queue QUEUE] [-m|--max-processes MAX_PROCESSES]

=head1 DESCRIPTION

This script will connect to the Stomp server (RabbitMQ) and subscribe to the queues passed in parameter (or the 'default' queue),
or if a Stomp server is not active it will poll the database every 10s for new jobs in the passed queue.

You can specify some queues only (using --queue, which is repeatable) if you want to run several workers that will handle their own jobs.

--m --max-processes specifies how many jobs to process simultaneously

Max processes will be set from the command line option, the environment variable MAX_PROCESSES, or the koha-conf file, in that order of precedence.
By default the script will only run one job at a time.

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
use Parallel::ForkManager;
use Time::HiRes;

use C4::Context;
use Koha::Logger;
use Koha::BackgroundJobs;
use C4::Context;

$SIG{'PIPE'} = 'IGNORE';    # See BZ 35111; added to ignore PIPE error when connection lost on Ubuntu.

my ( $help, @queues );

my $max_processes = $ENV{MAX_PROCESSES};
$max_processes ||= C4::Context->config('background_jobs_worker')->{max_processes}
    if C4::Context->config('background_jobs_worker');
$max_processes ||= 1;
my $mq_timeout = $ENV{MQ_TIMEOUT} // 10;

my $not_found_retries = {};
my $max_retries       = $ENV{MAX_RETRIES} || 10;

GetOptions(
    'm|max-processes=i' => \$max_processes,
    'h|help'            => \$help,
    'queue=s'           => \@queues,
) || pod2usage(1);

pod2usage(0) if $help;

unless (@queues) {
    push @queues, 'default';
}

my $notification_method = C4::Context->preference('JobsNotificationMethod') // 'STOMP';

my ( $conn, $error );
if ( $notification_method eq 'STOMP' ) {
    try {
        $conn = Koha::BackgroundJob->connect;
    } catch {
        $error = sprintf "Cannot connect to the message broker, the jobs will be processed anyway (%s)", $_;
    };
    $error ||= "Cannot connect to the message broker, the jobs will be processed anyway" unless $conn;
    warn $error if $error;
}

my $pm = Parallel::ForkManager->new($max_processes);

if ($conn) {

    # FIXME cf note in Koha::BackgroundJob about $namespace
    my $namespace = C4::Context->config('memcached_namespace');
    for my $queue (@queues) {
        $conn->subscribe(
            {
                destination      => sprintf( "/queue/%s-%s", $namespace, $queue ),
                ack              => 'client',
                'prefetch-count' => 1,
            }
        );
    }
}
while (1) {
    if ($conn) {
        my $frame = $conn->receive_frame( { timeout => $mq_timeout } );
        if ( !defined $frame ) {

            # timeout or connection issue?
            $pm->reap_finished_children;
            next;    # will reconnect automatically
        }

        my $args = try {
            my $command      = $frame->command;
            my $body         = $frame->body;
            my $content_type = $frame->content_type;
            if ( $command && $command eq 'MESSAGE' ) {
                if ( $content_type && $content_type eq 'application/json' ) {
                    decode_json($body);    # TODO Should this be from_json? Check utf8 flag.
                } else {

                    #TODO: This is a fallback for older enqueued messages which are missing the content-type header
                    #TODO: Please replace this decode with a die in the future once content-type is well established
                    decode_json($body);    # TODO Should this be from_json? Check utf8 flag.
                }
            } elsif ( $command && $command eq 'ERROR' ) {

                #Known errors:
                #You must log in using CONNECT first
                #"NACK" must include a valid "message-id" header
                Koha::Logger->get( { interface => 'worker' } )
                    ->warn( sprintf "Shutting down after receiving ERROR frame:\n%s\n", $frame->as_string );
                exit 1;
            }
        } catch {
            Koha::Logger->get( { interface => 'worker' } )->warn( sprintf "Frame not processed - %s", $_ );
            return;
        };

        unless ($args) {
            Koha::Logger->get( { interface => 'worker' } )
                ->warn( sprintf "Frame does not have correct args, ignoring it" );
            $conn->nack( { frame => $frame, requeue => 'false' } );
            next;
        }

        my $job = Koha::BackgroundJobs->find( $args->{job_id} );

        if ( $job && $job->status ne 'new' ) {
            Koha::Logger->get( { interface => 'worker' } )
                ->warn( sprintf "Job %s has wrong status %s", $args->{job_id}, $job->status );

            # nack without requeue, we do not want to process this frame again
            $conn->nack( { frame => $frame, requeue => 'false' } );
            next;
        }

        unless ($job) {
            $not_found_retries->{ $args->{job_id} } //= 0;
            if ( ++$not_found_retries->{ $args->{job_id} } >= $max_retries ) {
                Koha::Logger->get( { interface => 'worker' } )
                    ->warn( sprintf "Job %s not found, no more retry", $args->{job_id} );

                # nack without requeue, we do not want to process this frame again
                $conn->nack( { frame => $frame, requeue => 'false' } );
                next;
            }

            Koha::Logger->get( { interface => 'worker' } )
                ->debug( sprintf "Job %s not found, will retry later", $args->{job_id} );

            # nack to force requeue
            $conn->nack( { frame => $frame, requeue => 'true' } );
            Time::HiRes::sleep(0.5);
            next;
        }
        $conn->ack( { frame => $frame } );

        $pm->start and next;
        srand();    # ensure each child process begins with a new seed
        process_job( $job, $args );
        $pm->finish;

    } else {
        my $jobs = Koha::BackgroundJobs->search( { status => 'new', queue => \@queues } );
        while ( my $job = $jobs->next ) {
            my $args = try {
                $job->json->decode( $job->data );
            } catch {
                Koha::Logger->get( { interface => 'worker' } )
                    ->warn( sprintf "Cannot decode data for job id=%s", $job->id );
                $job->status('failed')->store;
                return;
            };

            next unless $args;

            $pm->start and next;
            srand();    # ensure each child process begins with a new seed
            process_job( $job, { job_id => $job->id, %$args } );
            $pm->finish;

        }
        $pm->reap_finished_children;
        sleep 10;
    }
}
$conn->disconnect;
$pm->wait_all_children;

sub process_job {
    my ( $job, $args ) = @_;
    try {
        $job->process($args);
    } catch {
        Koha::Logger->get( { interface => 'worker' } )
            ->warn( sprintf "Uncaught exception processing job id=%s: %s", $job->id, $_ );
        $job->status('failed')->store;
    };
}
