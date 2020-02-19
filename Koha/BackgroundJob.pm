package Koha::BackgroundJob;

use Modern::Perl;
use JSON qw( encode_json decode_json );
use Carp qw( croak );
use Net::RabbitFoot;

use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use Koha::BackgroundJobs;

use base qw( Koha::Object );

sub connect {
    my ( $self );
    my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
        host => 'localhost', # TODO Move this to KOHA_CONF
        port => 5672,
        user => 'guest',
        pass => 'guest',
        vhost => '/',
    );

    return $conn;
}

sub enqueue {
    my ( $self, $params ) = @_;

    my $job_type = $params->{job_type};
    my $job_size = $params->{job_size};
    my $job_args = $params->{job_args};

    my $borrowernumber = C4::Context->userenv->{number}; # FIXME Handle non GUI calls
    my $json_args = encode_json $job_args;
    $self->set({
        status => 'new',
        type => $job_type,
        size => $job_size,
        data => $json_args,
        enqueued_on => dt_from_string,
        borrowernumber => $borrowernumber,
    })->store;

    my $job_id = $self->id;
    $job_args->{job_id} = $job_id;
    $json_args = encode_json $job_args,

    my $conn = $self->connect;
    my $channel = $conn->open_channel();

    $channel->declare_queue(
        queue => $job_type,
        durable => 1,
    );

    $channel->publish(
        exchange => '',
        routing_key => $job_type, # TODO Must be different?
        body => $json_args,
    );
    $conn->close;
    return $job_id;
}

sub process { croak "This method must be subclassed" }

sub messages {
    my ( $self ) = @_;

    my @messages;
    my $data_dump = decode_json $self->data;
    if ( exists $data_dump->{messages} ) {
        @messages = @{ $data_dump->{messages} };
    }

    return @messages;
}

sub report {
    my ( $self ) = @_;

    my $data_dump = decode_json $self->data;
    return $data_dump->{report};
}

sub cancel {
    my ( $self ) = @_;
    $self->status('cancelled')->store;
}

sub _type {
    return 'BackgroundJob';
}

1;
