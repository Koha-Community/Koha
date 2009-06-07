package C4::ImportBatch;

# Copyright (C) 2007 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use C4::Context;
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Charset;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
    GetZ3950BatchId
    GetImportRecordMarc
    AddImportBatch
    GetImportBatch
    AddBiblioToBatch
    ModBiblioInBatch

    BatchStageMarcRecords
    BatchFindBibDuplicates
    BatchCommitBibRecords
    BatchRevertBibRecords

    GetAllImportBatches
    GetImportBatchRangeDesc
    GetNumberOfNonZ3950ImportBatches
    GetImportBibliosRange
	GetItemNumbersFromImportBatch
    
    GetImportBatchStatus
    SetImportBatchStatus
    GetImportBatchOverlayAction
    SetImportBatchOverlayAction
    GetImportBatchNoMatchAction
    SetImportBatchNoMatchAction
    GetImportBatchItemAction
    SetImportBatchItemAction
    GetImportBatchMatcher
    SetImportBatchMatcher
    GetImportRecordOverlayStatus
    SetImportRecordOverlayStatus
    GetImportRecordStatus
    SetImportRecordStatus
    GetImportRecordMatches
    SetImportRecordMatches
	);
}

=head1 NAME

C4::ImportBatch - manage batches of imported MARC records

=head1 SYNOPSIS

=over 4

use C4::ImportBatch;

=back

=head1 FUNCTIONS

=head2 GetZ3950BatchId

=over 4

my $batchid = GetZ3950BatchId($z3950server);

=back

Retrieves the ID of the import batch for the Z39.50
reservoir for the given target.  If necessary,
creates the import batch.

=cut

sub GetZ3950BatchId {
    my ($z3950server) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_batch_id FROM import_batches
                             WHERE  batch_type = 'z3950'
                             AND    file_name = ?");
    $sth->execute($z3950server);
    my $rowref = $sth->fetchrow_arrayref();
    $sth->finish();
    if (defined $rowref) {
        return $rowref->[0];
    } else {
        my $batch_id = AddImportBatch('create_new', 'staged', 'z3950', $z3950server, '');
        return $batch_id;
    }
    
}

=head2 GetImportRecordMarc

=over 4

my ($marcblob, $encoding) = GetImportRecordMarc($import_record_id);

=back

=cut

sub GetImportRecordMarc {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT marc, encoding FROM import_records WHERE import_record_id = ?");
    $sth->execute($import_record_id);
    my ($marc, $encoding) = $sth->fetchrow();
    $sth->finish();
    return $marc;

}

=head2 AddImportBatch

=over 4

my $batch_id = AddImportBatch($overlay_action, $import_status, $type, $file_name, $comments);

=back

=cut

sub AddImportBatch {
    my ($overlay_action, $import_status, $type, $file_name, $comments) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO import_batches (overlay_action, import_status, batch_type,
                                                         file_name, comments)
                                    VALUES (?, ?, ?, ?, ?)");
    $sth->execute($overlay_action, $import_status, $type, $file_name, $comments);
    my $batch_id = $dbh->{'mysql_insertid'};
    $sth->finish();

    return $batch_id;

}

=head2 GetImportBatch 

=over 4

my $row = GetImportBatch($batch_id);

=back

Retrieve a hashref of an import_batches row.

=cut

sub GetImportBatch {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM import_batches WHERE import_batch_id = ?");
    $sth->bind_param(1, $batch_id);
    $sth->execute();
    my $result = $sth->fetchrow_hashref;
    $sth->finish();
    return $result;

}

=head2 AddBiblioToBatch 

=over 4

my $import_record_id = AddBiblioToBatch($batch_id, $record_sequence, $marc_record, $encoding, $z3950random, $update_counts);

=back

=cut

sub AddBiblioToBatch {
    my $batch_id = shift;
    my $record_sequence = shift;
    my $marc_record = shift;
    my $encoding = shift;
    my $z3950random = shift;
    my $update_counts = @_ ? shift : 1;

    my $import_record_id = _create_import_record($batch_id, $record_sequence, $marc_record, 'biblio', $encoding, $z3950random);
    _add_biblio_fields($import_record_id, $marc_record);
    _update_batch_record_counts($batch_id) if $update_counts;
    return $import_record_id;
}

=head2 ModBiblioInBatch

=over 4

ModBiblioInBatch($import_record_id, $marc_record);

=back

=cut

sub ModBiblioInBatch {
    my ($import_record_id, $marc_record) = @_;

    _update_import_record_marc($import_record_id, $marc_record);
    _update_biblio_fields($import_record_id, $marc_record);

}

=head2 BatchStageMarcRecords

=over 4

($batch_id, $num_records, $num_items, @invalid_records) = 
    BatchStageMarcRecords($marc_flavor, $marc_records, $file_name, 
                          $comments, $branch_code, $parse_items,
                          $leave_as_staging, 
                          $progress_interval, $progress_callback);

=back

=cut

sub  BatchStageMarcRecords {
    my $marc_flavor = shift;
    my $marc_records = shift;
    my $file_name = shift;
    my $comments = shift;
    my $branch_code = shift;
    my $parse_items = shift;
    my $leave_as_staging = shift;
   
    # optional callback to monitor status 
    # of job
    my $progress_interval = 0;
    my $progress_callback = undef;
    if ($#_ == 1) {
        $progress_interval = shift;
        $progress_callback = shift;
        $progress_interval = 0 unless $progress_interval =~ /^\d+$/ and $progress_interval > 0;
        $progress_interval = 0 unless 'CODE' eq ref $progress_callback;
    } 
    
    my $batch_id = AddImportBatch('create_new', 'staging', 'batch', $file_name, $comments);
    if ($parse_items) {
        SetImportBatchItemAction($batch_id, 'always_add');
    } else {
        SetImportBatchItemAction($batch_id, 'ignore');
    }

    my @invalid_records = ();
    my $num_valid = 0;
    my $num_items = 0;
    # FIXME - for now, we're dealing only with bibs
    my $rec_num = 0;
    foreach my $marc_blob (split(/\x1D/, $marc_records)) {
        $marc_blob =~ s/^\s+//g;
        $marc_blob =~ s/\s+$//g;
        next unless $marc_blob;
        $rec_num++;
        if ($progress_interval and (0 == ($rec_num % $progress_interval))) {
            &$progress_callback($rec_num);
        }
        my ($marc_record, $charset_guessed, $char_errors) =
            MarcToUTF8Record($marc_blob, C4::Context->preference("marcflavour"));
        my $import_record_id;
        if (scalar($marc_record->fields()) == 0) {
            push @invalid_records, $marc_blob;
        } else {
            $num_valid++;
            $import_record_id = AddBiblioToBatch($batch_id, $rec_num, $marc_record, $marc_flavor, int(rand(99999)), 0);
            if ($parse_items) {
                my @import_items_ids = AddItemsToImportBiblio($batch_id, $import_record_id, $marc_record, 0);
                $num_items += scalar(@import_items_ids);
            }
        }
    }
    unless ($leave_as_staging) {
        SetImportBatchStatus($batch_id, 'staged');
    }
    # FIXME branch_code, number of bibs, number of items
    _update_batch_record_counts($batch_id);
    return ($batch_id, $num_valid, $num_items, @invalid_records);
}

=head2 AddItemsToImportBiblio

=over 4

my @import_items_ids = AddItemsToImportBiblio($batch_id, $import_record_id, $marc_record, $update_counts);

=back

=cut

sub AddItemsToImportBiblio {
    my $batch_id = shift;
    my $import_record_id = shift;
    my $marc_record = shift;
    my $update_counts = @_ ? shift : 0;

    my @import_items_ids = ();
   
    my $dbh = C4::Context->dbh; 
    my ($item_tag,$item_subfield) = &GetMarcFromKohaField("items.itemnumber",'');
    foreach my $item_field ($marc_record->field($item_tag)) {
        my $item_marc = MARC::Record->new();
        $item_marc->leader("00000    a              "); # must set Leader/09 to 'a'
        $item_marc->append_fields($item_field);
        $marc_record->delete_field($item_field);
        my $sth = $dbh->prepare_cached("INSERT INTO import_items (import_record_id, status, marcxml)
                                        VALUES (?, ?, ?)");
        $sth->bind_param(1, $import_record_id);
        $sth->bind_param(2, 'staged');
        $sth->bind_param(3, $item_marc->as_xml());
        $sth->execute();
        push @import_items_ids, $dbh->{'mysql_insertid'};
        $sth->finish();
    }

    if ($#import_items_ids > -1) {
        _update_batch_record_counts($batch_id) if $update_counts;
        _update_import_record_marc($import_record_id, $marc_record);
    }
    return @import_items_ids;
}

=head2 BatchFindBibDuplicates

=over 4

my $num_with_matches = BatchFindBibDuplicates($batch_id, $matcher, $max_matches, $progress_interval, $progress_callback);

=back

Goes through the records loaded in the batch and attempts to 
find duplicates for each one.  Sets the matching status 
of each record to "no_match" or "auto_match" as appropriate.

The $max_matches parameter is optional; if it is not supplied,
it defaults to 10.

The $progress_interval and $progress_callback parameters are 
optional; if both are supplied, the sub referred to by
$progress_callback will be invoked every $progress_interval
records using the number of records processed as the 
singular argument.

=cut

sub BatchFindBibDuplicates {
    my $batch_id = shift;
    my $matcher = shift;
    my $max_matches = @_ ? shift : 10;

    # optional callback to monitor status 
    # of job
    my $progress_interval = 0;
    my $progress_callback = undef;
    if ($#_ == 1) {
        $progress_interval = shift;
        $progress_callback = shift;
        $progress_interval = 0 unless $progress_interval =~ /^\d+$/ and $progress_interval > 0;
        $progress_interval = 0 unless 'CODE' eq ref $progress_callback;
    }

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare("SELECT import_record_id, marc
                             FROM import_records
                             JOIN import_biblios USING (import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my $num_with_matches = 0;
    my $rec_num = 0;
    while (my $rowref = $sth->fetchrow_hashref) {
        $rec_num++;
        if ($progress_interval and (0 == ($rec_num % $progress_interval))) {
            &$progress_callback($rec_num);
        }
        my $marc_record = MARC::Record->new_from_usmarc($rowref->{'marc'});
        my @matches = ();
        if (defined $matcher) {
            @matches = $matcher->get_matches($marc_record, $max_matches);
        }
        if (scalar(@matches) > 0) {
            $num_with_matches++;
            SetImportRecordMatches($rowref->{'import_record_id'}, @matches);
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'auto_match');
        } else {
            SetImportRecordMatches($rowref->{'import_record_id'}, ());
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'no_match');
        }
    }
    $sth->finish();
    return $num_with_matches;
}

=head2 BatchCommitBibRecords

=over 4

my ($num_added, $num_updated, $num_items_added, $num_items_errored, $num_ignored) = 
    BatchCommitBibRecords($batch_id, $progress_interval, $progress_callback);

=back

=cut

sub BatchCommitBibRecords {
    my $batch_id = shift;

    # optional callback to monitor status 
    # of job
    my $progress_interval = 0;
    my $progress_callback = undef;
    if ($#_ == 1) {
        $progress_interval = shift;
        $progress_callback = shift;
        $progress_interval = 0 unless $progress_interval =~ /^\d+$/ and $progress_interval > 0;
        $progress_interval = 0 unless 'CODE' eq ref $progress_callback;
    }

    my $num_added = 0;
    my $num_updated = 0;
    my $num_items_added = 0;
    my $num_items_errored = 0;
    my $num_ignored = 0;
    # commit (i.e., save, all records in the batch)
    # FIXME biblio only at the moment
    SetImportBatchStatus('importing');
    my $overlay_action = GetImportBatchOverlayAction($batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($batch_id);
    my $item_action = GetImportBatchItemAction($batch_id);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_record_id, status, overlay_status, marc, encoding
                             FROM import_records
                             JOIN import_biblios USING (import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my $rec_num = 0;
    while (my $rowref = $sth->fetchrow_hashref) {
        $rec_num++;
        if ($progress_interval and (0 == ($rec_num % $progress_interval))) {
            &$progress_callback($rec_num);
        }
        if ($rowref->{'status'} eq 'error' or $rowref->{'status'} eq 'imported') {
            $num_ignored++;
            next;
        }

        my $marc_record = MARC::Record->new_from_usmarc($rowref->{'marc'});

        # remove any item tags - rely on BatchCommitItems
        my ($item_tag,$item_subfield) = &GetMarcFromKohaField("items.itemnumber",'');
        foreach my $item_field ($marc_record->field($item_tag)) {
            $marc_record->delete_field($item_field);
        }

        # decide what what to do with the bib and item records
        my ($bib_result, $item_result, $bib_match) = 
            _get_commit_action($overlay_action, $nomatch_action, $item_action, 
                               $rowref->{'overlay_status'}, $rowref->{'import_record_id'});

        if ($bib_result eq 'create_new') {
            $num_added++;
            my ($biblionumber, $biblioitemnumber) = AddBiblio($marc_record, '');
            my $sth = $dbh->prepare_cached("UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?");
            $sth->execute($biblionumber, $rowref->{'import_record_id'});
            $sth->finish();
            if ($item_result eq 'create_new') {
                my ($bib_items_added, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $biblionumber);
                $num_items_added += $bib_items_added;
                $num_items_errored += $bib_items_errored;
            }
            SetImportRecordStatus($rowref->{'import_record_id'}, 'imported');
        } elsif ($bib_result eq 'replace') {
            $num_updated++;
            my $biblionumber = $bib_match;
            my ($count, $oldbiblio) = GetBiblio($biblionumber);
            my $oldxml = GetXmlBiblio($biblionumber);

            # remove item fields so that they don't get
            # added again if record is reverted
            my $old_marc = MARC::Record->new_from_xml(StripNonXmlChars($oldxml), 'UTF-8', $rowref->{'encoding'});
            foreach my $item_field ($old_marc->field($item_tag)) {
                $old_marc->delete_field($item_field);
            }

            ModBiblio($marc_record, $biblionumber, $oldbiblio->{'frameworkcode'});
            my $sth = $dbh->prepare_cached("UPDATE import_records SET marcxml_old = ? WHERE import_record_id = ?");
            $sth->execute($old_marc->as_xml(), $rowref->{'import_record_id'});
            $sth->finish();
            my $sth2 = $dbh->prepare_cached("UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?");
            $sth2->execute($biblionumber, $rowref->{'import_record_id'});
            $sth2->finish();
            if ($item_result eq 'create_new') {
                my ($bib_items_added, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $biblionumber);
                $num_items_added += $bib_items_added;
                $num_items_errored += $bib_items_errored;
            }
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'match_applied');
            SetImportRecordStatus($rowref->{'import_record_id'}, 'imported');
        } elsif ($bib_result eq 'ignore') {
            $num_ignored++;
            my $biblionumber = $bib_match;
            if (defined $biblionumber and $item_result eq 'create_new') {
                my ($bib_items_added, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $biblionumber);
                $num_items_added += $bib_items_added;
                $num_items_errored += $bib_items_errored;
                # still need to record the matched biblionumber so that the
                # items can be reverted
                my $sth2 = $dbh->prepare_cached("UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?");
                $sth2->execute($biblionumber, $rowref->{'import_record_id'});
                SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'match_applied');
            }
            SetImportRecordStatus($rowref->{'import_record_id'}, 'ignored');
        }
    }
    $sth->finish();
    SetImportBatchStatus($batch_id, 'imported');
    return ($num_added, $num_updated, $num_items_added, $num_items_errored, $num_ignored);
}

=head2 BatchCommitItems

=over 4

($num_items_added, $num_items_errored) = BatchCommitItems($import_record_id, $biblionumber);

=back

=cut

sub BatchCommitItems {
    my ($import_record_id, $biblionumber) = @_;

    my $dbh = C4::Context->dbh;

    my $num_items_added = 0;
    my $num_items_errored = 0;
    my $sth = $dbh->prepare("SELECT import_items_id, import_items.marcxml, encoding
                             FROM import_items
                             JOIN import_records USING (import_record_id)
                             WHERE import_record_id = ?
                             ORDER BY import_items_id");
    $sth->bind_param(1, $import_record_id);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        my $item_marc = MARC::Record->new_from_xml(StripNonXmlChars($row->{'marcxml'}), 'UTF-8', $row->{'encoding'});
        # FIXME - duplicate barcode check needs to become part of AddItemFromMarc()
        my $item = TransformMarcToKoha($dbh, $item_marc);
        my $duplicate_barcode = exists($item->{'barcode'}) && GetItemnumberFromBarcode($item->{'barcode'});
        if ($duplicate_barcode) {
            my $updsth = $dbh->prepare("UPDATE import_items SET status = ?, import_error = ? WHERE import_items_id = ?");
            $updsth->bind_param(1, 'error');
            $updsth->bind_param(2, 'duplicate item barcode');
            $updsth->bind_param(3, $row->{'import_items_id'});
            $updsth->execute();
            $num_items_errored++;
        } else {
            my ($item_biblionumber, $biblioitemnumber, $itemnumber) = AddItemFromMarc($item_marc, $biblionumber);
            my $updsth = $dbh->prepare("UPDATE import_items SET status = ?, itemnumber = ? WHERE import_items_id = ?");
            $updsth->bind_param(1, 'imported');
            $updsth->bind_param(2, $itemnumber);
            $updsth->bind_param(3, $row->{'import_items_id'});
            $updsth->execute();
            $updsth->finish();
            $num_items_added++;
        }
    }
    $sth->finish();
    return ($num_items_added, $num_items_errored);
}

=head2 BatchRevertBibRecords

=over 4

my ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored) = BatchRevertBibRecords($batch_id);

=back

=cut

sub BatchRevertBibRecords {
    my $batch_id = shift;

    my $num_deleted = 0;
    my $num_errors = 0;
    my $num_reverted = 0;
    my $num_items_deleted = 0;
    my $num_ignored = 0;
    # commit (i.e., save, all records in the batch)
    # FIXME biblio only at the moment
    SetImportBatchStatus('reverting');
    my $overlay_action = GetImportBatchOverlayAction($batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($batch_id);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_record_id, status, overlay_status, marcxml_old, encoding, matched_biblionumber
                             FROM import_records
                             JOIN import_biblios USING (import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    while (my $rowref = $sth->fetchrow_hashref) {
        if ($rowref->{'status'} eq 'error' or $rowref->{'status'} eq 'reverted') {
            $num_ignored++;
            next;
        }

        my $bib_result = _get_revert_action($overlay_action, $rowref->{'overlay_status'}, $rowref->{'status'});

        if ($bib_result eq 'delete') {
            $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
            my $error = DelBiblio($rowref->{'matched_biblionumber'});
            if (defined $error) {
                $num_errors++;
            } else {
                $num_deleted++;
                SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
            }
        } elsif ($bib_result eq 'restore') {
            $num_reverted++;
            my $old_record = MARC::Record->new_from_xml(StripNonXmlChars($rowref->{'marcxml_old'}), 'UTF-8', $rowref->{'encoding'});
            my $biblionumber = $rowref->{'matched_biblionumber'};
            my ($count, $oldbiblio) = GetBiblio($biblionumber);
            $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
            ModBiblio($old_record, $biblionumber, $oldbiblio->{'frameworkcode'});
            SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
        } elsif ($bib_result eq 'ignore') {
            $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
            SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
        }
        my $sth2 = $dbh->prepare_cached("UPDATE import_biblios SET matched_biblionumber = NULL WHERE import_record_id = ?");
        $sth2->execute($rowref->{'import_record_id'});
    }

    $sth->finish();
    SetImportBatchStatus($batch_id, 'reverted');
    return ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored);
}

=head2 BatchRevertItems

=over 4

my $num_items_deleted = BatchRevertItems($import_record_id, $biblionumber);

=back

=cut

sub BatchRevertItems {
    my ($import_record_id, $biblionumber) = @_;

    my $dbh = C4::Context->dbh;
    my $num_items_deleted = 0;

    my $sth = $dbh->prepare_cached("SELECT import_items_id, itemnumber
                                   FROM import_items
                                   JOIN items USING (itemnumber)
                                   WHERE import_record_id = ?");
    $sth->bind_param(1, $import_record_id);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        DelItem($dbh, $biblionumber, $row->{'itemnumber'});
        my $updsth = $dbh->prepare("UPDATE import_items SET status = ? WHERE import_items_id = ?");
        $updsth->bind_param(1, 'reverted');
        $updsth->bind_param(2, $row->{'import_items_id'});
        $updsth->execute();
        $updsth->finish();
        $num_items_deleted++;
    }
    $sth->finish();
    return $num_items_deleted;
}

=head2 GetAllImportBatches

=over 4

my $results = GetAllImportBatches();

=back

Returns a references to an array of hash references corresponding
to all import_batches rows (of batch_type 'batch'), sorted in 
ascending order by import_batch_id.

=cut

sub  GetAllImportBatches {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM import_batches
                                    WHERE batch_type = 'batch'
                                    ORDER BY import_batch_id ASC");

    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @$results, $row;
    }
    $sth->finish();
    return $results;
}

=head2 GetImportBatchRangeDesc

=over 4

my $results = GetImportBatchRangeDesc($offset, $results_per_group);

=back

Returns a reference to an array of hash references corresponding to
import_batches rows (sorted in descending order by import_batch_id)
start at the given offset.

=cut

sub GetImportBatchRangeDesc {
    my ($offset, $results_per_group) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM import_batches
                                    WHERE batch_type = 'batch'
                                    ORDER BY import_batch_id DESC
                                    LIMIT ? OFFSET ?");
    $sth->bind_param(1, $results_per_group);
    $sth->bind_param(2, $offset);

    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @$results, $row;
    }
    $sth->finish();
    return $results;
}

=head2 GetItemNumbersFromImportBatch

=cut

sub GetItemNumbersFromImportBatch {
	my ($batch_id) = @_;
 	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select itemnumber from import_batches,import_records,import_items where import_batches.import_batch_id=import_records.import_batch_id and import_records.import_record_id=import_items.import_record_id and import_batches.import_batch_id=?");
	$sth->execute($batch_id);
	my @items ;
	while ( my ($itm) = $sth->fetchrow_array ) {
		push @items, $itm;
	}
	return @items;
}

=head2 GetNumberOfImportBatches 

=over 4

my $count = GetNumberOfImportBatches();

=back

=cut

sub GetNumberOfNonZ3950ImportBatches {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT COUNT(*) FROM import_batches WHERE batch_type='batch'");
    $sth->execute();
    my ($count) = $sth->fetchrow_array();
    $sth->finish();
    return $count;
}

=head2 GetImportBibliosRange

=over 4

my $results = GetImportBibliosRange($batch_id, $offset, $results_per_group);

=back

Returns a reference to an array of hash references corresponding to
import_biblios/import_records rows for a given batch
starting at the given offset.

=cut

sub GetImportBibliosRange {
    my ($batch_id, $offset, $results_per_group) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT title, author, isbn, issn, import_record_id, record_sequence,
                                           matched_biblionumber, status, overlay_status
                                    FROM   import_records
                                    JOIN   import_biblios USING (import_record_id)
                                    WHERE  import_batch_id = ?
                                    ORDER BY import_record_id LIMIT ? OFFSET ?");
    $sth->bind_param(1, $batch_id);
    $sth->bind_param(2, $results_per_group);
    $sth->bind_param(3, $offset);
    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @$results, $row;
    }
    $sth->finish();
    return $results;

}

=head2 GetBestRecordMatch

=over 4

my $record_id = GetBestRecordMatch($import_record_id);

=back

=cut

sub GetBestRecordMatch {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT candidate_match_id
                             FROM   import_record_matches
                             WHERE  import_record_id = ?
                             ORDER BY score DESC, candidate_match_id DESC");
    $sth->execute($import_record_id);
    my ($record_id) = $sth->fetchrow_array();
    $sth->finish();
    return $record_id;
}

=head2 GetImportBatchStatus

=over 4

my $status = GetImportBatchStatus($batch_id);

=back

=cut

sub GetImportBatchStatus {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_status FROM import_batches WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my ($status) = $sth->fetchrow_array();
    $sth->finish();
    return $status;

}

=head2 SetImportBatchStatus

=over 4

SetImportBatchStatus($batch_id, $new_status);

=back

=cut

sub SetImportBatchStatus {
    my ($batch_id, $new_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET import_status = ? WHERE import_batch_id = ?");
    $sth->execute($new_status, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchOverlayAction

=over 4

my $overlay_action = GetImportBatchOverlayAction($batch_id);

=back

=cut

sub GetImportBatchOverlayAction {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT overlay_action FROM import_batches WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my ($overlay_action) = $sth->fetchrow_array();
    $sth->finish();
    return $overlay_action;

}


=head2 SetImportBatchOverlayAction

=over 4

SetImportBatchOverlayAction($batch_id, $new_overlay_action);

=back

=cut

sub SetImportBatchOverlayAction {
    my ($batch_id, $new_overlay_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET overlay_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_overlay_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchNoMatchAction

=over 4

my $nomatch_action = GetImportBatchNoMatchAction($batch_id);

=back

=cut

sub GetImportBatchNoMatchAction {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT nomatch_action FROM import_batches WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my ($nomatch_action) = $sth->fetchrow_array();
    $sth->finish();
    return $nomatch_action;

}


=head2 SetImportBatchNoMatchAction

=over 4

SetImportBatchNoMatchAction($batch_id, $new_nomatch_action);

=back

=cut

sub SetImportBatchNoMatchAction {
    my ($batch_id, $new_nomatch_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET nomatch_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_nomatch_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchItemAction

=over 4

my $item_action = GetImportBatchItemAction($batch_id);

=back

=cut

sub GetImportBatchItemAction {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT item_action FROM import_batches WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my ($item_action) = $sth->fetchrow_array();
    $sth->finish();
    return $item_action;

}


=head2 SetImportBatchItemAction

=over 4

SetImportBatchItemAction($batch_id, $new_item_action);

=back

=cut

sub SetImportBatchItemAction {
    my ($batch_id, $new_item_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET item_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_item_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchMatcher

=over 4

my $matcher_id = GetImportBatchMatcher($batch_id);

=back

=cut

sub GetImportBatchMatcher {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT matcher_id FROM import_batches WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my ($matcher_id) = $sth->fetchrow_array();
    $sth->finish();
    return $matcher_id;

}


=head2 SetImportBatchMatcher

=over 4

SetImportBatchMatcher($batch_id, $new_matcher_id);

=back

=cut

sub SetImportBatchMatcher {
    my ($batch_id, $new_matcher_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET matcher_id = ? WHERE import_batch_id = ?");
    $sth->execute($new_matcher_id, $batch_id);
    $sth->finish();

}

=head2 GetImportRecordOverlayStatus

=over 4

my $overlay_status = GetImportRecordOverlayStatus($import_record_id);

=back

=cut

sub GetImportRecordOverlayStatus {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT overlay_status FROM import_records WHERE import_record_id = ?");
    $sth->execute($import_record_id);
    my ($overlay_status) = $sth->fetchrow_array();
    $sth->finish();
    return $overlay_status;

}


=head2 SetImportRecordOverlayStatus

=over 4

SetImportRecordOverlayStatus($import_record_id, $new_overlay_status);

=back

=cut

sub SetImportRecordOverlayStatus {
    my ($import_record_id, $new_overlay_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET overlay_status = ? WHERE import_record_id = ?");
    $sth->execute($new_overlay_status, $import_record_id);
    $sth->finish();

}

=head2 GetImportRecordStatus

=over 4

my $overlay_status = GetImportRecordStatus($import_record_id);

=back

=cut

sub GetImportRecordStatus {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT status FROM import_records WHERE import_record_id = ?");
    $sth->execute($import_record_id);
    my ($overlay_status) = $sth->fetchrow_array();
    $sth->finish();
    return $overlay_status;

}


=head2 SetImportRecordStatus

=over 4

SetImportRecordStatus($import_record_id, $new_overlay_status);

=back

=cut

sub SetImportRecordStatus {
    my ($import_record_id, $new_overlay_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET status = ? WHERE import_record_id = ?");
    $sth->execute($new_overlay_status, $import_record_id);
    $sth->finish();

}

=head2 GetImportRecordMatches

=over 4

my $results = GetImportRecordMatches($import_record_id, $best_only);

=back

=cut

sub GetImportRecordMatches {
    my $import_record_id = shift;
    my $best_only = @_ ? shift : 0;

    my $dbh = C4::Context->dbh;
    # FIXME currently biblio only
    my $sth = $dbh->prepare_cached("SELECT title, author, biblionumber, score
                                    FROM import_records
                                    JOIN import_record_matches USING (import_record_id)
                                    JOIN biblio ON (biblionumber = candidate_match_id)
                                    WHERE import_record_id = ?
                                    ORDER BY score DESC, biblionumber DESC");
    $sth->bind_param(1, $import_record_id);
    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @$results, $row;
        last if $best_only;
    }
    $sth->finish();

    return $results;
    
}


=head2 SetImportRecordMatches

=over 4

SetImportRecordMatches($import_record_id, @matches);

=back

=cut

sub SetImportRecordMatches {
    my $import_record_id = shift;
    my @matches = @_;

    my $dbh = C4::Context->dbh;
    my $delsth = $dbh->prepare("DELETE FROM import_record_matches WHERE import_record_id = ?");
    $delsth->execute($import_record_id);
    $delsth->finish();

    my $sth = $dbh->prepare("INSERT INTO import_record_matches (import_record_id, candidate_match_id, score)
                                    VALUES (?, ?, ?)");
    foreach my $match (@matches) {
        $sth->execute($import_record_id, $match->{'record_id'}, $match->{'score'});
    }
}


# internal functions

sub _create_import_record {
    my ($batch_id, $record_sequence, $marc_record, $record_type, $encoding, $z3950random) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO import_records (import_batch_id, record_sequence, marc, marcxml, 
                                                         record_type, encoding, z3950random)
                                    VALUES (?, ?, ?, ?, ?, ?, ?)");
    $sth->execute($batch_id, $record_sequence, $marc_record->as_usmarc(), $marc_record->as_xml(),
                  $record_type, $encoding, $z3950random);
    my $import_record_id = $dbh->{'mysql_insertid'};
    $sth->finish();
    return $import_record_id;
}

sub _update_import_record_marc {
    my ($import_record_id, $marc_record) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET marc = ?, marcxml = ?
                             WHERE  import_record_id = ?");
    $sth->execute($marc_record->as_usmarc(), $marc_record->as_xml(), $import_record_id);
    $sth->finish();
}

sub _add_biblio_fields {
    my ($import_record_id, $marc_record) = @_;

    my ($title, $author, $isbn, $issn) = _parse_biblio_fields($marc_record);
    my $dbh = C4::Context->dbh;
    # FIXME no controlnumber, originalsource
    $isbn = C4::Koha::_isbn_cleanup($isbn); # FIXME C4::Koha::_isbn_cleanup should be made public
    my $sth = $dbh->prepare("INSERT INTO import_biblios (import_record_id, title, author, isbn, issn) VALUES (?, ?, ?, ?, ?)");
    $sth->execute($import_record_id, $title, $author, $isbn, $issn);
    $sth->finish();
                
}

sub _update_biblio_fields {
    my ($import_record_id, $marc_record) = @_;

    my ($title, $author, $isbn, $issn) = _parse_biblio_fields($marc_record);
    my $dbh = C4::Context->dbh;
    # FIXME no controlnumber, originalsource
    # FIXME 2 - should regularize normalization of ISBN wherever it is done
    $isbn =~ s/\(.*$//;
    $isbn =~ tr/ -_//;
    $isbn = uc $isbn;
    my $sth = $dbh->prepare("UPDATE import_biblios SET title = ?, author = ?, isbn = ?, issn = ?
                             WHERE  import_record_id = ?");
    $sth->execute($title, $author, $isbn, $issn, $import_record_id);
    $sth->finish();
}

sub _parse_biblio_fields {
    my ($marc_record) = @_;

    my $dbh = C4::Context->dbh;
    my $bibliofields = TransformMarcToKoha($dbh, $marc_record, '');
    return ($bibliofields->{'title'}, $bibliofields->{'author'}, $bibliofields->{'isbn'}, $bibliofields->{'issn'});

}

sub _update_batch_record_counts {
    my ($batch_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("UPDATE import_batches SET num_biblios = (
                                    SELECT COUNT(*)
                                    FROM import_records
                                    WHERE import_batch_id = import_batches.import_batch_id
                                    AND record_type = 'biblio')
                                    WHERE import_batch_id = ?");
    $sth->bind_param(1, $batch_id);
    $sth->execute();
    $sth->finish();
    $sth = $dbh->prepare_cached("UPDATE import_batches SET num_items = (
                                    SELECT COUNT(*)
                                    FROM import_records
                                    JOIN import_items USING (import_record_id)
                                    WHERE import_batch_id = import_batches.import_batch_id
                                    AND record_type = 'biblio')
                                    WHERE import_batch_id = ?");
    $sth->bind_param(1, $batch_id);
    $sth->execute();
    $sth->finish();

}

sub _get_commit_action {
    my ($overlay_action, $nomatch_action, $item_action, $overlay_status, $import_record_id) = @_;
    
    my ($bib_result, $bib_match, $item_result);

    if ($overlay_status ne 'no_match') {
        $bib_match = GetBestRecordMatch($import_record_id);
        if ($overlay_action eq 'replace') {
            $bib_result  = defined($bib_match) ? 'replace' : 'create_new';
        } elsif ($overlay_action eq 'create_new') {
            $bib_result  = 'create_new';
        } elsif ($overlay_action eq 'ignore') {
            $bib_result  = 'ignore';
        } 
        $item_result = ($item_action eq 'always_add' or $item_action eq 'add_only_for_matches') ? 'create_new' : 'ignore';
    } else {
        $bib_result = $nomatch_action;
        $item_result = ($item_action eq 'always_add' or $item_action eq 'add_only_for_new')     ? 'create_new' : 'ignore';
    }

    return ($bib_result, $item_result, $bib_match);
}

sub _get_revert_action {
    my ($overlay_action, $overlay_status, $status) = @_;

    my $bib_result;

    if ($status eq 'ignored') {
        $bib_result = 'ignore';
    } else {
        if ($overlay_action eq 'create_new') {
            $bib_result = 'delete';
        } else {
            $bib_result = ($overlay_status eq 'match_applied') ? 'restore' : 'delete';
        }
    }
    return $bib_result;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
