package Koha::BackgroundJob::BatchUpdateAuthority;

use Modern::Perl;
use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );
use JSON qw( encode_json decode_json );

use base 'Koha::BackgroundJob';

our $channel;
sub process {
    my ( $self, $args, $channel ) = @_;

    my $job_type = $args->{job_type};

    return unless exists $args->{job_id};

    my $job = Koha::BackgroundJobs->find( $args->{job_id} );

    my $job_progress = 0;
    $job->started_on(dt_from_string)
        ->progress($job_progress)
        ->status('started')
        ->store;

    my $mmtid = $args->{mmtid};
    my $record_type = $args->{record_type};
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => 0,
        total_success => 0,
    };
    my @messages;
    my $dbh = C4::Context->dbh;
    $dbh->{RaiseError} = 1;
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {
        $report->{total_records}++;
        next unless $record_id;
        # Authorities
        my $authid = $record_id;
        my $error = eval {
            my $authority = Koha::MetadataRecord::Authority->get_from_authid( $authid );
            my $record = $authority->record;
            ModifyRecordWithTemplate( $mmtid, $record );
            ModAuthority( $authid, $record, $authority->authtypecode );
        };
        if ( $error and $error != $authid or $@ ) {
            push @messages, {
                type => 'error',
                code => 'authority_not_modified',
                authid => $authid,
                error => ($@ ? $@ : 0),
            };
        } else {
            push @messages, {
                type => 'success',
                code => 'authority_modified',
                authid => $authid,
            };
            $report->{total_success}++;
        }
        $job->progress( ++$job_progress )->store;
    }

    my $job_data = decode_json $job->data;
    $job_data->{messages} = \@messages;
    $job_data->{report} = $report;

    $job->ended_on(dt_from_string)
        ->status('finished')
        ->data(encode_json $job_data)
        ->store;

    $channel->ack(); # FIXME Is that ok even on failure?
}

sub enqueue {
    my ( $self, $args) = @_;

    # TODO Raise exception instead
    return unless exists $args->{mmtid};
    return unless exists $args->{record_type}; #FIXME RMME
    return unless exists $args->{record_ids};

    my $mmtid = $args->{mmtid};
    my $record_type = $args->{record_type};
    my @record_ids = @{ $args->{record_ids} };

    $self->SUPER::enqueue({
        job_type => 'batch_record_modification',
        job_size => scalar @record_ids,
        job_args => {mmtid => $mmtid, record_type => $record_type, record_ids => \@record_ids,}
    });
}

1;
