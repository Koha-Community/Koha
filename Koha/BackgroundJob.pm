package Koha::BackgroundJob;

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
use Carp qw( croak );
use Net::Stomp;
use Try::Tiny;

use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::BackgroundJob::BatchUpdateBiblio;
use Koha::BackgroundJob::BatchUpdateAuthority;

use base qw( Koha::Object );

=head1 NAME

Koha::BackgroundJob - Koha BackgroundJob Object class

This is a base class for BackgroundJob, some methods must be subclassed.

Example of usage:

Producer:
my $job_id = Koha::BackgroundJob->enqueue(
    {
        job_type => $job_type,
        job_size => $job_size,
        job_args => $job_args
    }
);

Consumer:
Koha::BackgrounJobs->find($job_id)->process;
See also C<misc/background_jobs_worker.pl> for a full example

=head1 API

=head2 Class methods

=head3 connect

Connect to the message broker using default guest/guest credential

=cut

sub connect {
    my ( $self );
    my $hostname = 'localhost';
    my $port = '61613';
    my $config = C4::Context->config('message_broker');
    my $credentials = {
        login => 'guest',
        passcode => 'guest',
    };
    if ($config){
        $hostname = $config->{hostname} if $config->{hostname};
        $port = $config->{port} if $config->{port};
        $credentials->{login} = $config->{username} if $config->{username};
        $credentials->{passcode} = $config->{password} if $config->{password};
        $credentials->{host} = $config->{vhost} if $config->{vhost};
    }
    my $stomp = Net::Stomp->new( { hostname => $hostname, port => $port } );
    my $frame = $stomp->connect( $credentials );
    unless ($frame && $frame->command eq 'CONNECTED'){
        if ($frame){
            warn $frame->as_string;
        }
        die "Cannot connect to message broker";
    }
    return $stomp;
}

=head3 enqueue

Enqueue a new job. It will insert a new row in the DB table and notify the broker that a new job has been enqueued.

C<job_size> is the size of the job
C<job_args> is the arguments of the job. It's a structure that will be JSON encoded.

Return the job_id of the newly created job.

=cut

sub enqueue {
    my ( $self, $params ) = @_;

    my $job_type = $self->job_type;
    my $job_size = $params->{job_size};
    my $job_args = $params->{job_args};

    my $borrowernumber = C4::Context->userenv->{number}; # FIXME Handle non GUI calls
    my $json_args = encode_json $job_args;
    my $job_id;
    $self->_result->result_source->schema->txn_do(
        sub {
            $self->set(
                {
                    status         => 'new',
                    type           => $job_type,
                    size           => $job_size,
                    data           => $json_args,
                    enqueued_on    => dt_from_string,
                    borrowernumber => $borrowernumber,
                }
            )->store;

            $job_id = $self->id;
            $job_args->{job_id} = $job_id;
            $json_args = encode_json $job_args;

            try {
                my $conn = $self->connect;
                # This namespace is wrong, it must be a vhost instead.
                # But to do so it needs to be created on the server => much more work when a new Koha instance is created.
                # Also, here we just want the Koha instance's name, but it's not in the config...
                # Picking a random id (memcached_namespace) from the config
                my $namespace = C4::Context->config('memcached_namespace');
                $conn->send_with_receipt( { destination => sprintf("/queue/%s-%s", $namespace, $job_type), body => $json_args } )
                  or Koha::Exceptions::Exception->throw('Job has not been enqueued');
            } catch {
                if ( ref($_) eq 'Koha::Exceptions::Exception' ) {
                    $_->rethrow;
                } else {
                    warn sprintf "The job has not been sent to the message broker: (%s)", $_;
                }
            };
        }
    );

    return $job_id;
}

=head3 process

Process the job!

=cut

sub process {
    my ( $self, $args ) = @_;

    my $job_type = $self->type;
    return $job_type eq 'batch_biblio_record_modification'
      ? Koha::BackgroundJob::BatchUpdateBiblio->process($args)
      : $job_type eq 'batch_authority_record_modification'
      ? Koha::BackgroundJob::BatchUpdateAuthority->process($args)
      : Koha::Exceptions::Exception->throw('->process called without valid job_type');
}

=head3 job_type

Return the job type of the job. Must be a string.

=cut

sub job_type { croak "This method must be subclassed" }

=head3 messages

Messages let during the processing of the job.

=cut

sub messages {
    my ( $self ) = @_;

    my @messages;
    my $data_dump = decode_json $self->data;
    if ( exists $data_dump->{messages} ) {
        @messages = @{ $data_dump->{messages} };
    }

    return \@messages;
}

=head3 report

Report of the job.

=cut

sub report {
    my ( $self ) = @_;

    my $data_dump = decode_json $self->data;
    return $data_dump->{report};
}

=head3 cancel

Cancel a job.

=cut

sub cancel {
    my ( $self ) = @_;
    $self->status('cancelled')->store;
}

sub _type {
    return 'BackgroundJob';
}

1;
