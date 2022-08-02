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
use JSON;
use Carp qw( croak );
use Net::Stomp;
use Try::Tiny qw( catch try );

use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Plugins;
use Koha::Exceptions::BackgroundJob;

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
Koha::BackgroundJobs->find($job_id)->process;
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
    $stomp->connect( $credentials );
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

    my $job_type    = $self->job_type;
    my $job_size    = $params->{job_size};
    my $job_args    = $params->{job_args};
    my $job_context = $params->{job_context} // C4::Context->userenv;
    my $job_queue   = $params->{job_queue}  // 'default';
    my $json = $self->json;

    my $borrowernumber = (C4::Context->userenv) ? C4::Context->userenv->{number} : undef;
    $job_context->{interface} = C4::Context->interface;
    my $json_context = $json->encode($job_context);
    my $json_args = $json->encode($job_args);

    $self->set(
        {
            status         => 'new',
            type           => $job_type,
            queue          => $job_queue,
            size           => $job_size,
            data           => $json_args,
            context        => $json_context,
            enqueued_on    => dt_from_string,
            borrowernumber => $borrowernumber,
        }
    )->store;

    $job_args->{job_id} = $self->id;

    my $conn;
    try {
        $conn = $self->connect;
    } catch {
        warn "Cannot connect to broker " . $_;
    };
    return unless $conn;

    $json_args = $json->encode($job_args);
    try {
        # This namespace is wrong, it must be a vhost instead.
        # But to do so it needs to be created on the server => much more work when a new Koha instance is created.
        # Also, here we just want the Koha instance's name, but it's not in the config...
        # Picking a random id (memcached_namespace) from the config
        my $namespace = C4::Context->config('memcached_namespace');
        $conn->send_with_receipt( { destination => sprintf("/queue/%s-%s", $namespace, $job_queue), body => $json_args } )
          or Koha::Exceptions::Exception->throw('Job has not been enqueued');
    } catch {
        $self->status('failed')->store;
        if ( ref($_) eq 'Koha::Exceptions::Exception' ) {
            $_->rethrow;
        } else {
            warn sprintf "The job has not been sent to the message broker: (%s)", $_;
        }
    };

    return $self->id;
}

=head3 process

Process the job!

=cut

sub process {
    my ( $self, $args ) = @_;

    return {} if ref($self) ne 'Koha::BackgroundJob';

    my $derived_class = $self->_derived_class;

    $args ||= {};

    if ( $self->context ) {
        my $context = $self->json->decode($self->context);
        C4::Context->_new_userenv(-1);
        C4::Context->interface( $context->{interface} );
        C4::Context->set_userenv(
            $context->{number},       $context->{id},
            $context->{cardnumber},   $context->{firstname},
            $context->{surname},      $context->{branch},
            $context->{branchname},   $context->{flags},
            $context->{emailaddress}, undef,
            $context->{desk_id},      $context->{desk_name},
            $context->{register_id},  $context->{register_name}
        );
    }
    else {
        Koha::Logger->get->warn("A background job didn't have context defined (" . $self->id . ")");
    }

    return $derived_class->process( $args );
}

=head3 start

    $self->start;

Marks the job as started.

=cut

sub start {
    my ($self) = @_;

    Koha::Exceptions::BackgroundJob::InconsistentStatus->throw(
        current_status  => $self->status,
        expected_status => 'new'
    ) unless $self->status eq 'new';

    return $self->set(
        {
            started_on => \'NOW()',
            progress   => 0,
            status     => 'started',
        }
    )->store;
}

=head3 step

    $self->step;

Makes the job record a step has taken place.

=cut

sub step {
    my ($self) = @_;

    Koha::Exceptions::BackgroundJob::InconsistentStatus->throw(
        current_status  => $self->status,
        expected_status => 'started'
    ) unless $self->status eq 'started';

    # reached the end of the tasks already
    Koha::Exceptions::BackgroundJob::StepOutOfBounds->throw()
        unless $self->progress < $self->size;

    return $self->progress( $self->progress + 1 )->store;
}

=head3 finish

    $self->finish;

Makes the job record as finished. If the job status is I<cancelled>, it is kept.

=cut

sub finish {
    my ( $self, $data ) = @_;

    $self->status('finished') unless $self->status eq 'cancelled' or $self->status eq 'failed';

    return $self->set(
        {
            ended_on => \'NOW()',
            data     => $self->json->encode($data),
        }
    )->store;
}

=head3 json

   my $JSON_object = $self->json;

Returns a JSON object with utf8 disabled. Encoding to UTF-8 should be
done later.

=cut

sub json {
    my ( $self ) = @_;
    $self->{_json} //= JSON->new->utf8(0); # TODO Should we allow_nonref ?
    return $self->{_json};
}

=head3 decoded_data

    my $job_data = $self->decoded_data;

Returns the decoded JSON contents from $self->data.

=cut

sub decoded_data {
    my ($self) = @_;

    return $self->data ? $self->json->decode( $self->data ) : undef;
}

=head3 set_encoded_data

    $self->set_encoded_data( $data );

Serializes I<$data> as a JSON string and sets the I<data> attribute with it.

=cut

sub set_encoded_data {
    my ( $self, $data ) = @_;

    return $self->data( $data ? $self->json->encode($data) : undef );
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
    my $data_dump = $self->json->decode($self->data);
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

    my $data_dump = $self->json->decode($self->data);
    return $data_dump->{report} || {};
}

=head3 additional_report

Build additional variables for the job detail view.

=cut

sub additional_report {
    my ( $self ) = @_;

    return {} if ref($self) ne 'Koha::BackgroundJob';

    my $derived_class = $self->_derived_class;

    return $derived_class->additional_report;
}

=head3 cancel

Cancel a job.

=cut

sub cancel {
    my ( $self ) = @_;
    $self->status('cancelled')->store;
}

=head2 Internal methods

=head3 _derived_class

=cut

sub _derived_class {
    my ( $self ) = @_;
    my $job_type = $self->type;

    my $class = $self->type_to_class_mapping->{$job_type};

    Koha::Exception->throw($job_type . ' is not a valid job_type')
        unless $class;

    eval "require $class";
    return $class->_new_from_dbic( $self->_result );
}

=head3 type_to_class_mapping

    my $mapping = Koha::BackgroundJob->new->type_to_class_mapping;

Returns the available types to class mappings.

=cut

sub type_to_class_mapping {
    my ($self) = @_;

    my $plugins_mapping = ( C4::Context->config("enable_plugins") ) ? $self->plugin_types_to_classes : {};

    return ($plugins_mapping)
      ? { %{ $self->core_types_to_classes }, %$plugins_mapping }
      : $self->core_types_to_classes;
}

=head3 core_types_to_classes

    my $mappings = Koha::BackgroundJob->new->core_types_to_classes

Returns the core background jobs types to class mappings.

=cut

sub core_types_to_classes {
    return {
        batch_authority_record_deletion     => 'Koha::BackgroundJob::BatchDeleteAuthority',
        batch_authority_record_modification => 'Koha::BackgroundJob::BatchUpdateAuthority',
        batch_biblio_record_deletion        => 'Koha::BackgroundJob::BatchDeleteBiblio',
        batch_biblio_record_modification    => 'Koha::BackgroundJob::BatchUpdateBiblio',
        batch_item_record_deletion          => 'Koha::BackgroundJob::BatchDeleteItem',
        batch_item_record_modification      => 'Koha::BackgroundJob::BatchUpdateItem',
        batch_hold_cancel                   => 'Koha::BackgroundJob::BatchCancelHold',
        create_eholdings_from_biblios       => 'Koha::BackgroundJob::CreateEHoldingsFromBiblios',
        update_elastic_index                => 'Koha::BackgroundJob::UpdateElasticIndex',
        update_holds_queue_for_biblios      => 'Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue',
        stage_marc_for_import               => 'Koha::BackgroundJob::StageMARCForImport',
        marc_import_commit_batch            => 'Koha::BackgroundJob::MARCImportCommitBatch',
        marc_import_revert_batch            => 'Koha::BackgroundJob::MARCImportRevertBatch',
    };
}

=head3 plugin_types_to_classes

    my $mappings = Koha::BackgroundJob->new->plugin_types_to_classes

Returns the plugin-defined background jobs types to class mappings.

=cut

sub plugin_types_to_classes {
    my ($self) = @_;

    unless ( exists $self->{_plugin_mapping} ) {
        my @plugins = Koha::Plugins->new()->GetPlugins( { method => 'background_tasks', } );

        foreach my $plugin (@plugins) {

            my $tasks    = $plugin->background_tasks;
            my $metadata = $plugin->get_metadata;

            unless ( $metadata->{namespace} ) {
                Koha::Logger->get->warn(
                        q{A plugin includes the 'background_tasks' method, }
                      . q{but doesn't provide the required 'namespace' }
                      . qq{method ($plugin->{class})} );
                next;
            }

            my $namespace = $metadata->{namespace};

            foreach my $type ( keys %{$tasks} ) {
                my $class = $tasks->{$type};

                # skip if conditions not met
                next unless $type and $class;

                my $key = "plugin_$namespace" . "_$type";

                $self->{_plugin_mapping}->{$key} = $tasks->{$type};
            }
        }
    }

    return $self->{_plugin_mapping};
}

=head3 to_api

    my $json = $job->to_api;

Overloaded method that returns a JSON representation of the Koha::BackgroundJob object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json = $self->SUPER::to_api( $params );

    $json->{context} = $self->json->decode($self->context)
      if defined $self->context;
    $json->{data} = $self->decoded_data;

    return $json;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::BackgroundJob object
on the API.

=cut

sub to_api_mapping {
    return {
        id             => 'job_id',
        borrowernumber => 'patron_id',
        ended_on       => 'ended_date',
        enqueued_on    => 'enqueued_date',
        started_on     => 'started_date',
    };
}

=head3 _type

=cut

sub _type {
    return 'BackgroundJob';
}

1;
