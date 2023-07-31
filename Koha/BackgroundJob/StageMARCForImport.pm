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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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

    my $record_type                = $args->{record_type};
    my $encoding                   = $args->{encoding};
    my $format                     = $args->{format};
    my $filepath                   = $args->{filepath};
    my $filename                   = $args->{filename};
    my $marc_modification_template = $args->{marc_modification_template};
    my $comments                   = $args->{comments};
    my $parse_items                = $args->{parse_items};
    my $matcher_id                 = $args->{matcher_id};
    my $overlay_action             = $args->{overlay_action};
    my $nomatch_action             = $args->{nomatch_action};
    my $item_action                = $args->{item_action};
    my $vendor_id                  = $args->{vendor_id};
    my $basket_id                  = $args->{basket_id};
    my $profile_id                 = $args->{profile_id};

    my @messages;
    my ( $batch_id, $num_valid, $num_items, @import_errors );
    my $num_with_matches = 0;
    my $checked_matches  = 0;
    my $matcher_failed   = 0;
    my $matcher_code     = "";

    my $schema = Koha::Database->new->schema;
    try {
        $schema->storage->txn_begin;

        my ( $errors, $marcrecords );
        if ( $format eq 'MARCXML' ) {
            ( $errors, $marcrecords ) =
              C4::ImportBatch::RecordsFromMARCXMLFile( $filepath, $encoding );
        }
        elsif ( $format eq 'ISO2709' ) {
            ( $errors, $marcrecords ) =
              C4::ImportBatch::RecordsFromISO2709File( $filepath, $record_type,
                $encoding );
        }
        else {    # plugin based
            $errors = [];
            $marcrecords =
              C4::ImportBatch::RecordsFromMarcPlugin( $filepath, $format,
                $encoding );
        }

        $self->size(scalar @$marcrecords)->store;

        ( $batch_id, $num_valid, $num_items, @import_errors ) = BatchStageMarcRecords(
            $record_type,                $encoding,
            $marcrecords,                $filename,
            $marc_modification_template, $comments,
            '',                          $parse_items,
            0,                           50,
            sub {
                my $job_progress = shift;
                if ($matcher_id) {
                    $job_progress /= 2;
                }
                $self->progress( int($job_progress) )->store;
            }
        );
        if( $num_valid ) {
            $self->set({ progress => $num_valid, size => $num_valid });
        } else { # We must assume that something went wrong here
            $self->set({ progress => 0, status => 'failed' });
        }

        if ($profile_id) {
            my $ibatch = Koha::ImportBatches->find($batch_id);
            $ibatch->set( { profile_id => $profile_id } )->store;
        }

        if ($matcher_id) {
            my $matcher = C4::Matcher->fetch($matcher_id);
            if ( defined $matcher ) {
                $checked_matches = 1;
                $matcher_code    = $matcher->code();
                $num_with_matches =
                  BatchFindDuplicates( $batch_id, $matcher, 10, 50,
                    sub { my $job_progress = shift; $self->progress( $self->progress + $job_progress )->store } );
                SetImportBatchMatcher( $batch_id, $matcher_id );
                SetImportBatchOverlayAction( $batch_id, $overlay_action );
                SetImportBatchNoMatchAction( $batch_id, $nomatch_action );
                SetImportBatchItemAction( $batch_id, $item_action );
                $schema->storage->txn_commit;
            }
            else {
                $matcher_failed = 1;
                $schema->storage->txn_rollback;
            }
        } else {
            $schema->storage->txn_commit;
        }
    }
    catch {
        warn $_;
        $schema->storage->txn_rollback;
        die "Something terrible has happened!"
          if ( $_ =~ /Rollback failed/ );    # TODO Check test: Rollback failed
        $self->set({ progress => 0, status => 'failed' });
    };

    my $report = {
        staged          => $num_valid,
        matched         => $num_with_matches,
        num_items       => $num_items,
        import_errors   => scalar(@import_errors),
        total           => $num_valid + scalar(@import_errors),
        checked_matches => $checked_matches,
        matcher_failed  => $matcher_failed,
        matcher_code    => $matcher_code,
        import_batch_id => $batch_id,
        vendor_id       => $vendor_id,
        basket_id       => $basket_id,
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
    my ( $self, $args) = @_;

    # FIXME: no $args validation
    $self->SUPER::enqueue({
        job_size  => 0, # TODO Unknown for now?
        job_args  => $args,
        job_queue => 'long_tasks',
    });
}

1;
