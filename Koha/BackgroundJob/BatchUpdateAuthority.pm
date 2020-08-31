package Koha::BackgroundJob::BatchUpdateAuthority;

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

use C4::MarcModificationTemplates;
use C4::AuthoritiesMarc;
use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );
use Koha::MetadataRecord::Authority;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchUpdateAuthority - Batch update authorities

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: batch_authority_record_modification

=cut

sub job_type {
    return 'batch_authority_record_modification';
}

=head3 process

Process the modification.

=cut

sub process {
    my ( $self, $args ) = @_;

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
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
    my $dbh = C4::Context->dbh;
    $dbh->{RaiseError} = 1;
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {
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
        ->data(encode_json $job_data);
    $job->status('finished') if $job->status ne 'cancelled';
    $job->store;

}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args) = @_;

    # TODO Raise exception instead
    return unless exists $args->{mmtid};
    return unless exists $args->{record_ids};

    my $mmtid = $args->{mmtid};
    my @record_ids = @{ $args->{record_ids} };

    $self->SUPER::enqueue({
        job_size => scalar @record_ids,
        job_args => {mmtid => $mmtid, record_ids => \@record_ids,}
    });
}

1;
