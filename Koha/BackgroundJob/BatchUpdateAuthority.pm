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

use C4::MarcModificationTemplates qw( ModifyRecordWithTemplate );
use C4::AuthoritiesMarc qw( ModAuthority );
use Koha::BackgroundJobs;
use Koha::MetadataRecord::Authority;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

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

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    $self->start;

    my $mmtid = $args->{mmtid};
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {
        next unless $record_id;
        # Authorities
        my $authid = $record_id;
        my $error = eval {
            my $authority = Koha::MetadataRecord::Authority->get_from_authid( $authid );
            my $record = $authority->record;
            ModifyRecordWithTemplate( $mmtid, $record );
            ModAuthority( $authid, $record, $authority->authtypecode, { skip_record_index => 1 } );
        };
        if ( $error and $error != $authid or $@ ) {
            push @messages, {
                type => 'error',
                code => 'authority_not_modified',
                authid => $authid,
                error => ($@ ? "$@" : 0),
            };
        } else {
            push @messages, {
                type => 'success',
                code => 'authority_modified',
                authid => $authid,
            };
            $report->{total_success}++;
        }
        $self->step;
    }

    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
    $indexer->index_records( \@record_ids, "specialUpdate", "authorityserver" );

    my $data = $self->decoded_data;
    $data->{messages} = \@messages;
    $data->{report}   = $report;

    $self->finish( $data );

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
        job_size  => scalar @record_ids,
        job_args  => {mmtid => $mmtid, record_ids => \@record_ids,},
        job_queue => 'long_tasks',
    });
}

1;
