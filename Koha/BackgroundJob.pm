package Koha::BackgroundJob;

use Modern::Perl;
use JSON qw( encode_json decode_json );
use Carp qw( croak );
use Net::Stomp;

use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use Koha::BackgroundJobs;

use base qw( Koha::Object );

sub connect {
    my ( $self );
    my $stomp = Net::Stomp->new( { hostname => 'localhost', port => '61613' } );
    $stomp->connect( { login => 'guest', passcode => 'guest' } );
    return $stomp;
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
    $conn->send({destination => $job_type, body => $json_args});

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
