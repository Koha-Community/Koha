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

background_jobs_worker_es.pl - Worker script that will process background Elasticsearch jobs

=head1 SYNOPSIS

./background_jobs_worker_es.pl --batch_size=X

Options:

   --help                   brief help message
   -b --batch_size          how many jobs to commit

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

use C4::Context;
use Koha::Logger;
use Koha::BackgroundJobs;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;


my ( $help, $batch_size );
GetOptions(
    'h|help' => \$help,
    'b|batch_size=s' => \$batch_size
) || pod2usage(1);

pod2usage(0) if $help;

$batch_size //= 10;

die "Not using Elasticsearch" unless C4::Context->preference('SearchEngine') eq 'Elasticsearch';

my $logger = Koha::Logger->get({ interface =>  'worker' });

my $conn;
try {
    $conn = Koha::BackgroundJob->connect;
} catch {
    warn sprintf "Cannot connect to the message broker, the jobs will be processed anyway (%s)", $_;
};

if ( $conn ) {
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
my $biblio_indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
my $auth_indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
my @jobs = ();

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
            $logger->warn(sprintf "Frame not processed - %s", $_);
            return;
        } finally {
            $conn->ack( { frame => $frame } );
        };

        next unless $args;

        # FIXME This means we need to have create the DB entry before
        # It could work in a first step, but then we will want to handle job that will be created from the message received
        my $job = Koha::BackgroundJobs->find($args->{job_id});

        unless ( $job ) {
            $logger->warn(sprintf "No job found for id=%s", $args->{job_id});
            next;
        }

        push @jobs, $job;
        if ( @jobs >= $batch_size || !$conn->can_read( { timeout => '0.1' } ) ) {
            commit(@jobs);
            @jobs = ();
        }

    } else {
        @jobs = Koha::BackgroundJobs->search(
            { status => 'new', queue => 'elastic_index' } )->as_list;
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
        try {
            $auth_indexer->update_index( \@auth_records );
        } catch {
            $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
        };
    }
    if (@bib_records) {
        try {
            $biblio_indexer->update_index( \@bib_records );
        } catch {
            $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
        };
    }

    Koha::BackgroundJobs->search( { id => [ map { $_->id } @jobs ] } )->update( { status => 'finished', progress => 1 }, { no_triggers => 1 } );
}
