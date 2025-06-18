package Koha::BackgroundJob::StageMARCForImport;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Try::Tiny;

use base 'Koha::BackgroundJob';

use Koha::Database;
use Koha::ImportBatches;
use C4::Matcher;
use C4::ImportBatch qw(
    RecordsFromMARCXMLFile
    RecordsFromISO2709File
    RecordsFromMarcPlugin
    BatchStageMarcRecords
    BatchFindDuplicates
    SetImportBatchMatcher
    SetImportBatchOverlayAction
    SetImportBatchNoMatchAction
    SetImportBatchItemAction
);

=head1 NAME

Koha::BackgroundJob::StageMARCForImport - Stage MARC records for import

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: stage_marc_for_import

=cut

sub job_type {
    return 'stage_marc_for_import';
}

=head3 process

Stage the MARC records for import.

=cut

sub process {
    my ( $self, $args ) = @_;

    $self->start;

    my $import_args = { %$args, job => $self };
    my $result      = Koha::ImportBatch->new_from_file($import_args);

    my $data = $self->decoded_data;
    $data->{messages} = $result->{messages};
    $data->{report}   = $result->{report};

    $self->finish($data);
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    # FIXME: no $args validation
    $self->SUPER::enqueue(
        {
            job_size  => 0,              # TODO Unknown for now?
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

1;
