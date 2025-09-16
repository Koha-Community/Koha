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

es_indexer_daemon.pl - Worker script that will process background Elasticsearch jobs

=head1 SYNOPSIS

./es_indexer_daemon.pl --batch_size=X

Options:

   -b --batch_size          how many jobs to commit (default: 10)
   --help                   brief help message

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--batch_size>

How many jobs to commit per batch. Defaults to 10, will commit after .1 seconds if no more jobs incoming.

=back

=head1 DESCRIPTION

This script will connect to the Stomp server (RabbitMQ) and subscribe to the Elasticsearch queue, processing batches every second.
If a Stomp server is not active it will poll the database every 10s for new jobs in the Elasticsearch queue
and process them in batches every second.

=cut

use Modern::Perl;
use JSON qw( decode_json );
use Try::Tiny;
use Pod::Usage;
use Getopt::Long;
use List::MoreUtils qw( natatime );
use Time::HiRes;

use C4::Context;
use Koha::Logger;
use Koha::BackgroundJobs;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

my $help;
my $batch_size = 10;

my $not_found_retries = {};
my $max_retries       = $ENV{MAX_RETRIES} || 10;

GetOptions(
    'h|help'         => \$help,
    'b|batch_size=s' => \$batch_size
) || pod2usage(1);

pod2usage(0) if $help;

warn "Not using Elasticsearch" unless C4::Context->preference('SearchEngine') eq 'Elasticsearch';

my $logger = Koha::Logger->get( { interface => 'worker' } );

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

if ($conn) {

    # FIXME cf note in Koha::BackgroundJob about $namespace
    my $namespace = C4::Context->config('memcached_namespace');
    $conn->subscribe(
        {
            destination      => sprintf( "/queue/%s-%s", $namespace, 'elastic_index' ),
            ack              => 'client',
            'prefetch-count' => 1,
        }
    );
}
my $biblio_indexer = Koha::SearchEngine::Indexer->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
my $auth_indexer   = Koha::SearchEngine::Indexer->new( { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
my $config         = $biblio_indexer->get_elasticsearch_params;
my $at_a_time      = $config->{chunk_size} // 5000;

my @jobs = ();

while (1) {

    if ($conn) {
        my $frame = $conn->receive_frame;
        if ( !defined $frame ) {

            # maybe log connection problems
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

        push @jobs, $job;
        if ( @jobs >= $batch_size || !$conn->can_read( { timeout => '0.1' } ) ) {
            commit(@jobs);
            @jobs = ();
        }

    } else {
        @jobs = Koha::BackgroundJobs->search(
            { status => 'new', queue => 'elastic_index' },
            { rows   => $batch_size }
        )->as_list;
        commit(@jobs);
        @jobs = ();
        sleep 10;
    }

}
$conn->disconnect;

sub commit {
    my (@jobs) = @_;

    my @bib_records;
    my @auth_records;

    my $jobs = Koha::BackgroundJobs->search( { id => [ map { $_->id } @jobs ] } );

    # Start
    $jobs->update(
        {
            progress   => 0,
            status     => 'started',
            started_on => \'NOW()',
        }
    );

    for my $job (@jobs) {
        my $args = try {
            $job->json->decode( $job->data );
        } catch {
            $logger->warn( sprintf "Cannot decode data for job id=%s", $job->id );
            $job->status('failed')->store;
            return;
        };
        next unless $args;
        if ( $args->{record_server} eq 'biblioserver' ) {
            push @bib_records, @{ $args->{record_ids} };
        } else {
            push @auth_records, @{ $args->{record_ids} };
        }
    }

    if (@auth_records) {
        my $auth_chunks = natatime $at_a_time, @auth_records;
        while ( ( my @auth_chunk = $auth_chunks->() ) ) {
            try {
                $auth_indexer->update_index( \@auth_chunk );
            } catch {
                $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
            };
        }
    }
    if (@bib_records) {
        my $biblio_chunks = natatime $at_a_time, @bib_records;
        while ( ( my @bib_chunk = $biblio_chunks->() ) ) {
            try {
                $biblio_indexer->update_index( \@bib_chunk );
            } catch {
                $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
            };
        }
    }

    # Finish
    $jobs->update(
        {
            progress => 1,
            status   => 'finished',
            ended_on => \'NOW()',
        }
    );
}
