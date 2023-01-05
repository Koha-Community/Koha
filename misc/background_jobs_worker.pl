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

use Modern::Perl;
use JSON qw( decode_json );
use Try::Tiny qw( catch try );

use Koha::BackgroundJobs;

my $conn;
try {
    $conn = Koha::BackgroundJob->connect;
} catch {
    warn sprintf "Cannot connect to the message broker, the jobs will be processed anyway (%s)", $_;
};

my @job_types = qw(
    batch_biblio_record_modification
    batch_authority_record_modification
    batch_item_record_modification
    batch_biblio_record_deletion
    batch_authority_record_deletion
    batch_item_record_deletion
    batch_hold_cancel
);

if ( $conn ) {
    # FIXME cf note in Koha::BackgroundJob about $namespace
    my $namespace = C4::Context->config('memcached_namespace');
    for my $job_type ( @job_types ) {
        $conn->subscribe({
            destination => sprintf("/queue/%s-%s", $namespace, $job_type),
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

        my $body = $frame->body;
        my $args = decode_json($body);

        # FIXME This means we need to have create the DB entry before
        # It could work in a first step, but then we will want to handle job that will be created from the message received
        my $job = Koha::BackgroundJobs->find($args->{job_id});

        $conn->ack( { frame => $frame } ); # Acknowledge the message was received
        process_job( $job, $args );

    } else {
        my $jobs = Koha::BackgroundJobs->search({ status => 'new' });
        while ( my $job = $jobs->next ) {
            my $args = decode_json($job->data);
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

    $job->process( $args );
    exit;
}
