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
use JSON qw( encode_json decode_json );

use Koha::BackgroundJobs;

my $conn = Koha::BackgroundJob->connect;

my @job_types = qw( batch_biblio_record_modification batch_authority_record_modification );

for my $job_type ( @job_types ) {
    $conn->subscribe({ destination => $job_type, ack => 'client' });
}
while (1) {
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
    my $success = $job->process( $args );

    $conn->ack( { frame => $frame } ); # FIXME depending on $success?
}
$conn->disconnect;
