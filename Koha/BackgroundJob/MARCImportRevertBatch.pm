package Koha::BackgroundJob::MARCImportRevertBatch;

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

use C4::ImportBatch qw(
    BatchRevertRecords
);
use Koha::Database;
use Koha::Import::Records;

=head1 NAME

Koha::BackgroundJob::MARCImportRevertBatch - Revert a batch

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: marc_import_revert_batch

=cut

sub job_type {
    return 'marc_import_revert_batch';
}

=head3 process

Revert a batch

=cut

sub process {
    my ( $self, $args ) = @_;

    $self->start;

    my $import_batch_id = $args->{import_batch_id};

    my @messages;
    my $job_progress = 0;
    my (
        $num_deleted,       $num_errors, $num_reverted,
        $num_items_deleted, $num_ignored
    );

    my $schema = Koha::Database->new->schema;
    try {
        $schema->storage->txn_begin;
        ( $num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored ) =
            BatchRevertRecords($import_batch_id);    # TODO BatchRevertRecords still needs a progress_callback
        $schema->storage->txn_commit;

        my $count = $num_deleted + $num_reverted;
        if ($count) {
            $self->set( { progress => $count, size => $count } );
        } else {                                     # TODO Nothing happened? Refine later
            $self->set( { progress => 0, status => 'failed' } );
        }
    } catch {
        warn $_;
        $schema->storage->txn_rollback;
        $self->set( { progress => 0, status => 'failed' } );
    };

    my $report = {
        num_deleted       => $num_deleted,
        num_items_deleted => $num_items_deleted,
        num_errors        => $num_errors,
        num_reverted      => $num_reverted,
        num_ignored       => $num_ignored,
        import_batch_id   => $import_batch_id,
    };

    my $data = $self->decoded_data;
    $data->{messages} = \@messages;
    $data->{report}   = $report;

    $self->finish($data);
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    $self->SUPER::enqueue(
        {
            job_size  => Koha::Import::Records->search( { import_batch_id => $args->{import_batch_id} } )->count,
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

1;
