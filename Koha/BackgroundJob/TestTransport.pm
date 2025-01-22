package Koha::BackgroundJob::TestTransport;

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

use JSON qw( decode_json encode_json );
use Try::Tiny;
use Koha::File::Transports;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::TestTransport - Background job derived class to test File::Transports

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: file_transport_test

=cut

sub job_type {
    return 'file_transport_test';
}

=head3 process

Process the transport test.

=cut

sub process {
    my ( $self, $args ) = @_;
    $self->start;

    my $transport = Koha::File::Transports->find( $args->{transport_id} );
    $transport->test_connection;
    my $status   = { status => 'ok' };
    my $messages = $transport->object_messages;
    for my $message (@$messages) {
        $status->{status} = 'errors' if $message->{type} eq 'error';
        push @{ $status->{operations} },
            { code => $message->{message}, status => $message->{type}, detail => $message->{payload} };
    }
    $transport->set( { status => encode_json($status) } )->store();

    my $data = $status;
    $self->finish($data);
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    my $transport = $args->{transport_id};
    Koha::Exceptions::MissingParameter->throw("Missing transport_id parameter is mandatory")
        unless $transport;

    $self->SUPER::enqueue(
        {
            job_size  => 1,
            job_args  => {%$args},
            job_queue => 'default',
        }
    );
}

1;
