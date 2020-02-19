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

use Koha::BackgroundJob::BatchUpdateBiblio;
use Koha::BackgroundJob;

my $conn = Koha::BackgroundJob->connect;

my $channel = $conn->open_channel();

my $job_type = 'batch_biblio_record_modification';
$channel->declare_queue(
    queue => $job_type,
    durable => 1,
);

$channel->qos(prefetch_count => 1,);

$channel->consume(
    on_consume => sub {
        my $var = shift;
        my $body = $var->{body}->{payload};
        say " [x] Received $body";

        my $args = decode_json( $body );

        Koha::BackgroundJob::BatchUpdateBiblio->process($args, $channel);
        say " [x] Done";
    },
    no_ack => 0,
);

warn "waiting forever";
# Wait forever
AnyEvent->condvar->recv;
