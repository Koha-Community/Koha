package Koha::ImportBatch;

# This file is part of Koha.
#
# Copyright 2020 Koha Development Team
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <https://www.gnu.org/licenses>

use Modern::Perl;
use Try::Tiny;

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

use base qw(Koha::Object);

=head1 NAME

Koha::ImportBatch - Koha ImportBatch Object class

=head1 API

=head2 Class Methods

=head3 new_from_file

Koha::ImportBatch->new_from_file($args);

This method is used to create a new Koha::ImportBatch object from a file.
If being called from a background job, $args->{job} must be set.

=cut

sub new_from_file {
    my ( $self, $args ) = @_;

    my $job                        = $args->{job};
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
            ( $errors, $marcrecords ) = C4::ImportBatch::RecordsFromMARCXMLFile( $filepath, $encoding );
        } elsif ( $format eq 'ISO2709' ) {
            ( $errors, $marcrecords ) = C4::ImportBatch::RecordsFromISO2709File(
                $filepath, $record_type,
                $encoding
            );
        } else {    # plugin based
            $errors      = [];
            $marcrecords = C4::ImportBatch::RecordsFromMarcPlugin(
                $filepath, $format,
                $encoding
            );
        }

        $job->size( scalar @$marcrecords )->store if $job;

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
                $job->progress( int($job_progress) )->store if $job;
            }
        );
        if ( $num_valid && $job ) {
            $job->set( { progress => $num_valid, size => $num_valid } );
        } else {    # We must assume that something went wrong here
            $job->set( { progress => 0, status => 'failed' } ) if $job;
        }

        if ($profile_id) {
            my $ibatch = Koha::ImportBatches->find($batch_id);
            $ibatch->set( { profile_id => $profile_id } )->store;
        }

        if ($matcher_id) {
            my $matcher = C4::Matcher->fetch($matcher_id);
            if ( defined $matcher ) {
                $checked_matches  = 1;
                $matcher_code     = $matcher->code();
                $num_with_matches = BatchFindDuplicates(
                    $batch_id, $matcher, 10, 50,
                    sub { my $job_progress = shift; $job->progress($job_progress)->store if $job }
                );
                SetImportBatchMatcher( $batch_id, $matcher_id );
                SetImportBatchOverlayAction( $batch_id, $overlay_action );
                SetImportBatchNoMatchAction( $batch_id, $nomatch_action );
                SetImportBatchItemAction( $batch_id, $item_action );
                $schema->storage->txn_commit;
            } else {
                $matcher_failed = 1;
                $schema->storage->txn_rollback;
            }
        } else {
            $schema->storage->txn_commit;
        }
    } catch {
        warn $_;
        $schema->storage->txn_rollback;
        die "Something terrible has happened!"
            if ( $_ =~ /Rollback failed/ );    # TODO Check test: Rollback failed
        $job->set( { progress => 0, status => 'failed' } ) if $job;
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

    return { report => $report, messages => \@messages };
}

=head3 _type

=cut

sub _type {
    return 'ImportBatch';
}

1;
