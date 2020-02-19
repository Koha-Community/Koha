package Koha::BackgroundJob::BatchUpdateBiblio;

use Modern::Perl;
use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );
use JSON qw( encode_json decode_json );

use base 'Koha::BackgroundJob';

sub process {
    my ( $self, $args ) = @_;

    my $job_type = $args->{job_type};

    my $job = Koha::BackgroundJobs->find( $args->{job_id} );

    if ( !exists $args->{job_id} || !$job || $job->status eq 'cancelled' ) {
        return;
    }

    my $job_progress = 0;
    $job->started_on(dt_from_string)
        ->progress($job_progress)
        ->status('started')
        ->store;

    my $mmtid = $args->{mmtid};
    my $record_type = $args->{record_type};
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
    my $dbh = C4::Context->dbh;
    $dbh->{RaiseError} = 1;
    RECORD_IDS: for my $biblionumber ( sort { $a <=> $b } @record_ids ) {

        last if $job->get_from_storage->status eq 'cancelled';

        next unless $biblionumber;

        # Modify the biblio
        my $error = eval {
            my $record = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
            C4::MarcModificationTemplates::ModifyRecordWithTemplate( $mmtid, $record );
            my $frameworkcode = C4::Biblio::GetFrameworkCode( $biblionumber );
            C4::Biblio::ModBiblio( $record, $biblionumber, $frameworkcode );
        };
        if ( $error and $error != 1 or $@ ) { # ModBiblio returns 1 if everything as gone well
            push @messages, {
                type => 'error',
                code => 'biblio_not_modified',
                biblionumber => $biblionumber,
                error => ($@ ? $@ : $error),
            };
        } else {
            push @messages, {
                type => 'success',
                code => 'biblio_modified',
                biblionumber => $biblionumber,
            };
            $report->{total_success}++;
        }
        $job->progress( ++$job_progress )->store;
    }

    my $job_data = decode_json $job->data;
    $job_data->{messages} = \@messages;
    $job_data->{report} = $report;

    $job->ended_on(dt_from_string)
        ->data(encode_json $job_data);
    $job->status('finished') if $job->status ne 'cancelled';
    $job->store;
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
        job_type => 'batch_biblio_record_modification', # FIXME Must be a global const
        job_size => scalar @record_ids,
        job_args => {mmtid => $mmtid, record_type => $record_type, record_ids => \@record_ids,}
    });
}

1;
