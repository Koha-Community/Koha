package C4::ImportBatch;

# Copyright (C) 2007 LibLime, 2012 C & P Bibliography Services
#
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

use strict;
use warnings;

use C4::Context;
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Charset;
use C4::AuthoritiesMarc;
use C4::MarcModificationTemplates;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
    GetZ3950BatchId
    GetWebserviceBatchId
    GetImportRecordMarc
    GetImportRecordMarcXML
    AddImportBatch
    GetImportBatch
    AddAuthToBatch
    AddBiblioToBatch
    AddItemsToImportBiblio
    ModAuthorityInBatch
    ModBiblioInBatch

    BatchStageMarcRecords
    BatchFindDuplicates
    BatchCommitRecords
    BatchRevertRecords
    CleanBatch

    GetAllImportBatches
    GetStagedWebserviceBatches
    GetImportBatchRangeDesc
    GetNumberOfNonZ3950ImportBatches
    GetImportBiblios
    GetImportRecordsRange
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

use C4::ImportBatch;

=head1 FUNCTIONS

=head2 GetZ3950BatchId

  my $batchid = GetZ3950BatchId($z3950server);

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
        my $batch_id = AddImportBatch( {
                overlay_action => 'create_new',
                import_status => 'staged',
                batch_type => 'z3950',
                file_name => $z3950server,
            } );
        return $batch_id;
    }
    
}

=head2 GetWebserviceBatchId

  my $batchid = GetWebserviceBatchId();

Retrieves the ID of the import batch for webservice.
If necessary, creates the import batch.

=cut

my $WEBSERVICE_BASE_QRY = <<EOQ;
SELECT import_batch_id FROM import_batches
WHERE  batch_type = 'webservice'
AND    import_status = 'staged'
EOQ
sub GetWebserviceBatchId {
    my ($params) = @_;

    my $dbh = C4::Context->dbh;
    my $sql = $WEBSERVICE_BASE_QRY;
    my @args;
    foreach my $field (qw(matcher_id overlay_action nomatch_action item_action)) {
        if (my $val = $params->{$field}) {
            $sql .= " AND $field = ?";
            push @args, $val;
        }
    }
    my $id = $dbh->selectrow_array($sql, undef, @args);
    return $id if $id;

    $params->{batch_type} = 'webservice';
    $params->{import_status} = 'staged';
    return AddImportBatch($params);
}

=head2 GetImportRecordMarc

  my ($marcblob, $encoding) = GetImportRecordMarc($import_record_id);

=cut

sub GetImportRecordMarc {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my ( $marc, $encoding ) = $dbh->selectrow_array(q|
        SELECT marc, encoding
        FROM import_records
        WHERE import_record_id = ?
    |, undef, $import_record_id );

    return $marc, $encoding;
}

sub GetRecordFromImportBiblio {
    my ( $import_record_id, $embed_items ) = @_;

    my ($marc) = GetImportRecordMarc($import_record_id);
    my $record = MARC::Record->new_from_usmarc($marc);

    EmbedItemsInImportBiblio( $record, $import_record_id ) if $embed_items;

    return $record;
}

sub EmbedItemsInImportBiblio {
    my ( $record, $import_record_id ) = @_;
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField("items.itemnumber", '');
    my $dbh = C4::Context->dbh;
    my $import_items = $dbh->selectall_arrayref(q|
        SELECT import_items.marcxml
        FROM import_items
        WHERE import_record_id = ?
    |, { Slice => {} }, $import_record_id );
    my @item_fields;
    for my $import_item ( @$import_items ) {
        my $item_marc = MARC::Record::new_from_xml($import_item->{marcxml});
        push @item_fields, $item_marc->field($itemtag);
    }
    $record->append_fields(@item_fields);
    return $record;
}

=head2 GetImportRecordMarcXML

  my $marcxml = GetImportRecordMarcXML($import_record_id);

=cut

sub GetImportRecordMarcXML {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT marcxml FROM import_records WHERE import_record_id = ?");
    $sth->execute($import_record_id);
    my ($marcxml) = $sth->fetchrow();
    $sth->finish();
    return $marcxml;

}

=head2 AddImportBatch

  my $batch_id = AddImportBatch($params_hash);

=cut

sub AddImportBatch {
    my ($params) = @_;

    my (@fields, @vals);
    foreach (qw( matcher_id template_id branchcode
                 overlay_action nomatch_action item_action
                 import_status batch_type file_name comments record_type )) {
        if (exists $params->{$_}) {
            push @fields, $_;
            push @vals, $params->{$_};
        }
    }
    my $dbh = C4::Context->dbh;
    $dbh->do("INSERT INTO import_batches (".join( ',', @fields).")
                                  VALUES (".join( ',', map '?', @fields).")",
             undef,
             @vals);
    return $dbh->{'mysql_insertid'};
}

=head2 GetImportBatch 

  my $row = GetImportBatch($batch_id);

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

  my $import_record_id = AddBiblioToBatch($batch_id, $record_sequence, 
                $marc_record, $encoding, $z3950random, $update_counts);

=cut

sub AddBiblioToBatch {
    my $batch_id = shift;
    my $record_sequence = shift;
    my $marc_record = shift;
    my $encoding = shift;
    my $z3950random = shift;
    my $update_counts = @_ ? shift : 1;

    my $import_record_id = _create_import_record($batch_id, $record_sequence, $marc_record, 'biblio', $encoding, $z3950random, C4::Context->preference('marcflavour'));
    _add_biblio_fields($import_record_id, $marc_record);
    _update_batch_record_counts($batch_id) if $update_counts;
    return $import_record_id;
}

=head2 ModBiblioInBatch

  ModBiblioInBatch($import_record_id, $marc_record);

=cut

sub ModBiblioInBatch {
    my ($import_record_id, $marc_record) = @_;

    _update_import_record_marc($import_record_id, $marc_record, C4::Context->preference('marcflavour'));
    _update_biblio_fields($import_record_id, $marc_record);

}

=head2 AddAuthToBatch

  my $import_record_id = AddAuthToBatch($batch_id, $record_sequence,
                $marc_record, $encoding, $z3950random, $update_counts, [$marc_type]);

=cut

sub AddAuthToBatch {
    my $batch_id = shift;
    my $record_sequence = shift;
    my $marc_record = shift;
    my $encoding = shift;
    my $z3950random = shift;
    my $update_counts = @_ ? shift : 1;
    my $marc_type = shift || C4::Context->preference('marcflavour');

    $marc_type = 'UNIMARCAUTH' if $marc_type eq 'UNIMARC';

    my $import_record_id = _create_import_record($batch_id, $record_sequence, $marc_record, 'auth', $encoding, $z3950random, $marc_type);
    _add_auth_fields($import_record_id, $marc_record);
    _update_batch_record_counts($batch_id) if $update_counts;
    return $import_record_id;
}

=head2 ModAuthInBatch

  ModAuthInBatch($import_record_id, $marc_record);

=cut

sub ModAuthInBatch {
    my ($import_record_id, $marc_record) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');
    _update_import_record_marc($import_record_id, $marc_record, $marcflavour eq 'UNIMARC' ? 'UNIMARCAUTH' : 'USMARC');

}

=head2 BatchStageMarcRecords

  ($batch_id, $num_records, $num_items, @invalid_records) = 
    BatchStageMarcRecords($encoding, $marc_records, $file_name, $marc_modification_template,
                          $comments, $branch_code, $parse_items,
                          $leave_as_staging, 
                          $progress_interval, $progress_callback);

=cut

sub BatchStageMarcRecords {
    my $record_type = shift;
    my $encoding = shift;
    my $marc_records = shift;
    my $file_name = shift;
    my $marc_modification_template = shift;
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
    
    my $batch_id = AddImportBatch( {
            overlay_action => 'create_new',
            import_status => 'staging',
            batch_type => 'batch',
            file_name => $file_name,
            comments => $comments,
            record_type => $record_type,
        } );
    if ($parse_items) {
        SetImportBatchItemAction($batch_id, 'always_add');
    } else {
        SetImportBatchItemAction($batch_id, 'ignore');
    }

    my $marc_type = C4::Context->preference('marcflavour');
    $marc_type .= 'AUTH' if ($marc_type eq 'UNIMARC' && $record_type eq 'auth');
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
            MarcToUTF8Record($marc_blob, $marc_type, $encoding);

        $encoding = $charset_guessed unless $encoding;

        ModifyRecordWithTemplate( $marc_modification_template, $marc_record ) if ( $marc_modification_template );

        my $import_record_id;
        if (scalar($marc_record->fields()) == 0) {
            push @invalid_records, $marc_blob;
        } else {

            # Normalize the record so it doesn't have separated diacritics
            SetUTF8Flag($marc_record);

            $num_valid++;
            if ($record_type eq 'biblio') {
                $import_record_id = AddBiblioToBatch($batch_id, $rec_num, $marc_record, $encoding, int(rand(99999)), 0);
                if ($parse_items) {
                    my @import_items_ids = AddItemsToImportBiblio($batch_id, $import_record_id, $marc_record, 0);
                    $num_items += scalar(@import_items_ids);
                }
            } elsif ($record_type eq 'auth') {
                $import_record_id = AddAuthToBatch($batch_id, $rec_num, $marc_record, $encoding, int(rand(99999)), 0, $marc_type);
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

  my @import_items_ids = AddItemsToImportBiblio($batch_id, 
                $import_record_id, $marc_record, $update_counts);

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
        _update_import_record_marc($import_record_id, $marc_record, C4::Context->preference('marcflavour'));
    }
    return @import_items_ids;
}

=head2 BatchFindDuplicates

  my $num_with_matches = BatchFindDuplicates($batch_id, $matcher,
             $max_matches, $progress_interval, $progress_callback);

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

sub BatchFindDuplicates {
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

    my $sth = $dbh->prepare("SELECT import_record_id, record_type, marc
                             FROM import_records
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

=head2 BatchCommitRecords

  my ($num_added, $num_updated, $num_items_added, $num_items_replaced, $num_items_errored, $num_ignored) =
        BatchCommitRecords($batch_id, $framework,
        $progress_interval, $progress_callback);

=cut

sub BatchCommitRecords {
    my $batch_id = shift;
    my $framework = shift;

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

    my $record_type;
    my $num_added = 0;
    my $num_updated = 0;
    my $num_items_added = 0;
    my $num_items_replaced = 0;
    my $num_items_errored = 0;
    my $num_ignored = 0;
    # commit (i.e., save, all records in the batch)
    SetImportBatchStatus('importing');
    my $overlay_action = GetImportBatchOverlayAction($batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($batch_id);
    my $item_action = GetImportBatchItemAction($batch_id);
    my $item_tag;
    my $item_subfield;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_records.import_record_id, record_type, status, overlay_status, marc, encoding
                             FROM import_records
                             LEFT JOIN import_auths ON (import_records.import_record_id=import_auths.import_record_id)
                             LEFT JOIN import_biblios ON (import_records.import_record_id=import_biblios.import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my $marcflavour = C4::Context->preference('marcflavour');
    my $rec_num = 0;
    while (my $rowref = $sth->fetchrow_hashref) {
        $record_type = $rowref->{'record_type'};
        $rec_num++;
        if ($progress_interval and (0 == ($rec_num % $progress_interval))) {
            &$progress_callback($rec_num);
        }
        if ($rowref->{'status'} eq 'error' or $rowref->{'status'} eq 'imported') {
            $num_ignored++;
            next;
        }

        my $marc_type;
        if ($marcflavour eq 'UNIMARC' && $record_type eq 'auth') {
            $marc_type = 'UNIMARCAUTH';
        } elsif ($marcflavour eq 'UNIMARC') {
            $marc_type = 'UNIMARC';
        } else {
            $marc_type = 'USMARC';
        }
        my $marc_record = MARC::Record->new_from_usmarc($rowref->{'marc'});

        if ($record_type eq 'biblio') {
            # remove any item tags - rely on BatchCommitItems
            ($item_tag,$item_subfield) = &GetMarcFromKohaField("items.itemnumber",'');
            foreach my $item_field ($marc_record->field($item_tag)) {
                $marc_record->delete_field($item_field);
            }
        }

        my ($record_result, $item_result, $record_match) =
            _get_commit_action($overlay_action, $nomatch_action, $item_action, 
                               $rowref->{'overlay_status'}, $rowref->{'import_record_id'}, $record_type);

        my $recordid;
        my $query;
        if ($record_result eq 'create_new') {
            $num_added++;
            if ($record_type eq 'biblio') {
                my $biblioitemnumber;
                ($recordid, $biblioitemnumber) = AddBiblio($marc_record, $framework);
                $query = "UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?";
                if ($item_result eq 'create_new' || $item_result eq 'replace') {
                    my ($bib_items_added, $bib_items_replaced, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $recordid, $item_result);
                    $num_items_added += $bib_items_added;
                    $num_items_replaced += $bib_items_replaced;
                    $num_items_errored += $bib_items_errored;
                }
            } else {
                $recordid = AddAuthority($marc_record, undef, GuessAuthTypeCode($marc_record));
                $query = "UPDATE import_auths SET matched_authid = ? WHERE import_record_id = ?";
            }
            my $sth = $dbh->prepare_cached($query);
            $sth->execute($recordid, $rowref->{'import_record_id'});
            $sth->finish();
            SetImportRecordStatus($rowref->{'import_record_id'}, 'imported');
        } elsif ($record_result eq 'replace') {
            $num_updated++;
            $recordid = $record_match;
            my $oldxml;
            if ($record_type eq 'biblio') {
                my $oldbiblio = GetBiblio($recordid);
                $oldxml = GetXmlBiblio($recordid);

                # remove item fields so that they don't get
                # added again if record is reverted
                # FIXME: GetXmlBiblio output should not contain item info any more! So the next foreach should not be needed. Does not hurt either; may remove old 952s that should not have been there anymore.
                my $old_marc = MARC::Record->new_from_xml(StripNonXmlChars($oldxml), 'UTF-8', $rowref->{'encoding'}, $marc_type);
                foreach my $item_field ($old_marc->field($item_tag)) {
                    $old_marc->delete_field($item_field);
                }
                $oldxml = $old_marc->as_xml($marc_type);

                ModBiblio($marc_record, $recordid, $oldbiblio->{'frameworkcode'});
                $query = "UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?";

                if ($item_result eq 'create_new' || $item_result eq 'replace') {
                    my ($bib_items_added, $bib_items_replaced, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $recordid, $item_result);
                    $num_items_added += $bib_items_added;
                    $num_items_replaced += $bib_items_replaced;
                    $num_items_errored += $bib_items_errored;
                }
            } else {
                $oldxml = GetAuthorityXML($recordid);

                ModAuthority($recordid, $marc_record, GuessAuthTypeCode($marc_record));
                $query = "UPDATE import_auths SET matched_authid = ? WHERE import_record_id = ?";
            }
            my $sth = $dbh->prepare_cached("UPDATE import_records SET marcxml_old = ? WHERE import_record_id = ?");
            $sth->execute($oldxml, $rowref->{'import_record_id'});
            $sth->finish();
            my $sth2 = $dbh->prepare_cached($query);
            $sth2->execute($recordid, $rowref->{'import_record_id'});
            $sth2->finish();
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'match_applied');
            SetImportRecordStatus($rowref->{'import_record_id'}, 'imported');
        } elsif ($record_result eq 'ignore') {
            $recordid = $record_match;
            $num_ignored++;
            $recordid = $record_match;
            if ($record_type eq 'biblio' and defined $recordid and ( $item_result eq 'create_new' || $item_result eq 'replace' ) ) {
                my ($bib_items_added, $bib_items_replaced, $bib_items_errored) = BatchCommitItems($rowref->{'import_record_id'}, $recordid, $item_result);
                $num_items_added += $bib_items_added;
         $num_items_replaced += $bib_items_replaced;
                $num_items_errored += $bib_items_errored;
                # still need to record the matched biblionumber so that the
                # items can be reverted
                my $sth2 = $dbh->prepare_cached("UPDATE import_biblios SET matched_biblionumber = ? WHERE import_record_id = ?");
                $sth2->execute($recordid, $rowref->{'import_record_id'});
                SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'match_applied');
            }
            SetImportRecordStatus($rowref->{'import_record_id'}, 'ignored');
        }
    }
    $sth->finish();
    SetImportBatchStatus($batch_id, 'imported');
    return ($num_added, $num_updated, $num_items_added, $num_items_replaced, $num_items_errored, $num_ignored);
}

=head2 BatchCommitItems

  ($num_items_added, $num_items_errored) = 
         BatchCommitItems($import_record_id, $biblionumber);

=cut

sub BatchCommitItems {
    my ( $import_record_id, $biblionumber, $action ) = @_;

    my $dbh = C4::Context->dbh;

    my $num_items_added = 0;
    my $num_items_errored = 0;
    my $num_items_replaced = 0;

    my $sth = $dbh->prepare( "
        SELECT import_items_id, import_items.marcxml, encoding
        FROM import_items
        JOIN import_records USING (import_record_id)
        WHERE import_record_id = ?
        ORDER BY import_items_id
    " );
    $sth->bind_param( 1, $import_record_id );
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref() ) {
        my $item_marc = MARC::Record->new_from_xml( StripNonXmlChars( $row->{'marcxml'} ), 'UTF-8', $row->{'encoding'} );

        # Delete date_due subfield as to not accidentally delete item checkout due dates
        my ( $MARCfield, $MARCsubfield ) = GetMarcFromKohaField( 'items.onloan', GetFrameworkCode($biblionumber) );
        $item_marc->field($MARCfield)->delete_subfield( code => $MARCsubfield );

        my $item = TransformMarcToKoha( $dbh, $item_marc );

        my $duplicate_barcode = exists( $item->{'barcode'} ) && GetItemnumberFromBarcode( $item->{'barcode'} );
        my $duplicate_itemnumber = exists( $item->{'itemnumber'} );

        my $updsth = $dbh->prepare("UPDATE import_items SET status = ?, itemnumber = ? WHERE import_items_id = ?");
        if ( $action eq "replace" && $duplicate_itemnumber ) {
            # Duplicate itemnumbers have precedence, that way we can update barcodes by overlaying
            ModItemFromMarc( $item_marc, $biblionumber, $item->{itemnumber} );
            $updsth->bind_param( 1, 'imported' );
            $updsth->bind_param( 2, $item->{itemnumber} );
            $updsth->bind_param( 3, $row->{'import_items_id'} );
            $updsth->execute();
            $updsth->finish();
            $num_items_replaced++;
        } elsif ( $action eq "replace" && $duplicate_barcode ) {
            my $itemnumber = GetItemnumberFromBarcode( $item->{'barcode'} );
            ModItemFromMarc( $item_marc, $biblionumber, $itemnumber );
            $updsth->bind_param( 1, 'imported' );
            $updsth->bind_param( 2, $item->{itemnumber} );
            $updsth->bind_param( 3, $row->{'import_items_id'} );
            $updsth->execute();
            $updsth->finish();
            $num_items_replaced++;
        } elsif ($duplicate_barcode) {
            $updsth->bind_param( 1, 'error' );
            $updsth->bind_param( 2, 'duplicate item barcode' );
            $updsth->bind_param( 3, $row->{'import_items_id'} );
            $updsth->execute();
            $num_items_errored++;
        } else {
            my ( $item_biblionumber, $biblioitemnumber, $itemnumber ) = AddItemFromMarc( $item_marc, $biblionumber );
            $updsth->bind_param( 1, 'imported' );
            $updsth->bind_param( 2, $itemnumber );
            $updsth->bind_param( 3, $row->{'import_items_id'} );
            $updsth->execute();
            $updsth->finish();
            $num_items_added++;
        }
    }

    return ( $num_items_added, $num_items_replaced, $num_items_errored );
}

=head2 BatchRevertRecords

  my ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, 
      $num_ignored) = BatchRevertRecords($batch_id);

=cut

sub BatchRevertRecords {
    my $batch_id = shift;

    my $record_type;
    my $num_deleted = 0;
    my $num_errors = 0;
    my $num_reverted = 0;
    my $num_ignored = 0;
    my $num_items_deleted = 0;
    # commit (i.e., save, all records in the batch)
    SetImportBatchStatus('reverting');
    my $overlay_action = GetImportBatchOverlayAction($batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($batch_id);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_records.import_record_id, record_type, status, overlay_status, marcxml_old, encoding, matched_biblionumber, matched_authid
                             FROM import_records
                             LEFT JOIN import_auths ON (import_records.import_record_id=import_auths.import_record_id)
                             LEFT JOIN import_biblios ON (import_records.import_record_id=import_biblios.import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my $marc_type;
    my $marcflavour = C4::Context->preference('marcflavour');
    while (my $rowref = $sth->fetchrow_hashref) {
        $record_type = $rowref->{'record_type'};
        if ($rowref->{'status'} eq 'error' or $rowref->{'status'} eq 'reverted') {
            $num_ignored++;
            next;
        }
        if ($marcflavour eq 'UNIMARC' && $record_type eq 'auth') {
            $marc_type = 'UNIMARCAUTH';
        } elsif ($marcflavour eq 'UNIMARC') {
            $marc_type = 'UNIMARC';
        } else {
            $marc_type = 'USMARC';
        }

        my $record_result = _get_revert_action($overlay_action, $rowref->{'overlay_status'}, $rowref->{'status'});

        if ($record_result eq 'delete') {
            my $error = undef;
            if  ($record_type eq 'biblio') {
                $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
                $error = DelBiblio($rowref->{'matched_biblionumber'});
            } else {
                my $deletedauthid = DelAuthority($rowref->{'matched_authid'});
            }
            if (defined $error) {
                $num_errors++;
            } else {
                $num_deleted++;
                SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
            }
        } elsif ($record_result eq 'restore') {
            $num_reverted++;
            my $old_record = MARC::Record->new_from_xml(StripNonXmlChars($rowref->{'marcxml_old'}), 'UTF-8', $rowref->{'encoding'}, $marc_type);
            if ($record_type eq 'biblio') {
                my $biblionumber = $rowref->{'matched_biblionumber'};
                my $oldbiblio = GetBiblio($biblionumber);
                $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
                ModBiblio($old_record, $biblionumber, $oldbiblio->{'frameworkcode'});
            } else {
                my $authid = $rowref->{'matched_authid'};
                ModAuthority($authid, $old_record, GuessAuthTypeCode($old_record));
            }
            SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
        } elsif ($record_result eq 'ignore') {
            if ($record_type eq 'biblio') {
                $num_items_deleted += BatchRevertItems($rowref->{'import_record_id'}, $rowref->{'matched_biblionumber'});
            }
            SetImportRecordStatus($rowref->{'import_record_id'}, 'reverted');
        }
        my $query;
        if ($record_type eq 'biblio') {
            # remove matched_biblionumber only if there is no 'imported' item left
            $query = "UPDATE import_biblios SET matched_biblionumber = NULL WHERE import_record_id = ?";
            $query = "UPDATE import_biblios SET matched_biblionumber = NULL WHERE import_record_id = ?  AND NOT EXISTS (SELECT * FROM import_items WHERE import_items.import_record_id=import_biblios.import_record_id and status='imported')";
        } else {
            $query = "UPDATE import_auths SET matched_authid = NULL WHERE import_record_id = ?";
        }
        my $sth2 = $dbh->prepare_cached($query);
        $sth2->execute($rowref->{'import_record_id'});
    }

    $sth->finish();
    SetImportBatchStatus($batch_id, 'reverted');
    return ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored);
}

=head2 BatchRevertItems

  my $num_items_deleted = BatchRevertItems($import_record_id, $biblionumber);

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
        my $error = DelItemCheck($dbh, $biblionumber, $row->{'itemnumber'});
        if ($error == 1){
            my $updsth = $dbh->prepare("UPDATE import_items SET status = ? WHERE import_items_id = ?");
            $updsth->bind_param(1, 'reverted');
            $updsth->bind_param(2, $row->{'import_items_id'});
            $updsth->execute();
            $updsth->finish();
            $num_items_deleted++;
        }
        else {
            next;
        }
    }
    $sth->finish();
    return $num_items_deleted;
}

=head2 CleanBatch

  CleanBatch($batch_id)

Deletes all staged records from the import batch
and sets the status of the batch to 'cleaned'.  Note
that deleting a stage record does *not* affect
any record that has been committed to the database.

=cut

sub CleanBatch {
    my $batch_id = shift;
    return unless defined $batch_id;

    C4::Context->dbh->do('DELETE FROM import_records WHERE import_batch_id = ?', {}, $batch_id);
    SetImportBatchStatus($batch_id, 'cleaned');
}

=head2 GetAllImportBatches

  my $results = GetAllImportBatches();

Returns a references to an array of hash references corresponding
to all import_batches rows (of batch_type 'batch'), sorted in 
ascending order by import_batch_id.

=cut

sub  GetAllImportBatches {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare_cached("SELECT * FROM import_batches
                                    WHERE batch_type IN ('batch', 'webservice')
                                    ORDER BY import_batch_id ASC");

    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        push @$results, $row;
    }
    $sth->finish();
    return $results;
}

=head2 GetStagedWebserviceBatches

  my $batch_ids = GetStagedWebserviceBatches();

Returns a references to an array of batch id's
of batch_type 'webservice' that are not imported

=cut

my $PENDING_WEBSERVICE_BATCHES_QRY = <<EOQ;
SELECT import_batch_id FROM import_batches
WHERE batch_type = 'webservice'
AND import_status = 'staged'
EOQ
sub  GetStagedWebserviceBatches {
    my $dbh = C4::Context->dbh;
    return $dbh->selectcol_arrayref($PENDING_WEBSERVICE_BATCHES_QRY);
}

=head2 GetImportBatchRangeDesc

  my $results = GetImportBatchRangeDesc($offset, $results_per_group);

Returns a reference to an array of hash references corresponding to
import_batches rows (sorted in descending order by import_batch_id)
start at the given offset.

=cut

sub GetImportBatchRangeDesc {
    my ($offset, $results_per_group) = @_;

    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM import_batches
                                    WHERE batch_type IN ('batch', 'webservice')
                                    ORDER BY import_batch_id DESC";
    my @params;
    if ($results_per_group){
        $query .= " LIMIT ?";
        push(@params, $results_per_group);
    }
    if ($offset){
        $query .= " OFFSET ?";
        push(@params, $offset);
    }
    my $sth = $dbh->prepare_cached($query);
    $sth->execute(@params);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish();
    return $results;
}

=head2 GetItemNumbersFromImportBatch

  my @itemsnos = GetItemNumbersFromImportBatch($batch_id);

=cut

sub GetItemNumbersFromImportBatch {
	my ($batch_id) = @_;
 	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT itemnumber FROM import_batches,import_records,import_items WHERE import_batches.import_batch_id=import_records.import_batch_id AND import_records.import_record_id=import_items.import_record_id AND import_batches.import_batch_id=?");
	$sth->execute($batch_id);
	my @items ;
	while ( my ($itm) = $sth->fetchrow_array ) {
		push @items, $itm;
	}
	return @items;
}

=head2 GetNumberOfImportBatches 

  my $count = GetNumberOfImportBatches();

=cut

sub GetNumberOfNonZ3950ImportBatches {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT COUNT(*) FROM import_batches WHERE batch_type != 'z3950'");
    $sth->execute();
    my ($count) = $sth->fetchrow_array();
    $sth->finish();
    return $count;
}

=head2 GetImportBiblios

  my $results = GetImportBiblios($importid);

=cut

sub GetImportBiblios {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM import_biblios WHERE import_record_id = ?";
    return $dbh->selectall_arrayref(
        $query,
        { Slice => {} },
        $import_record_id
    );

}

=head2 GetImportRecordsRange

  my $results = GetImportRecordsRange($batch_id, $offset, $results_per_group);

Returns a reference to an array of hash references corresponding to
import_biblios/import_auths/import_records rows for a given batch
starting at the given offset.

=cut

sub GetImportRecordsRange {
    my ( $batch_id, $offset, $results_per_group, $status, $parameters ) = @_;

    my $dbh = C4::Context->dbh;

    my $order_by = $parameters->{order_by} || 'import_record_id';
    ( $order_by ) = grep( /^$order_by$/, qw( import_record_id title status overlay_status ) ) ? $order_by : 'import_record_id';

    my $order_by_direction =
      uc( $parameters->{order_by_direction} ) eq 'DESC' ? 'DESC' : 'ASC';

    $order_by .= " $order_by_direction, authorized_heading" if $order_by eq 'title';

    my $query = "SELECT title, author, isbn, issn, authorized_heading, import_records.import_record_id,
                                           record_sequence, status, overlay_status,
                                           matched_biblionumber, matched_authid, record_type
                                    FROM   import_records
                                    LEFT JOIN import_auths ON (import_records.import_record_id=import_auths.import_record_id)
                                    LEFT JOIN import_biblios ON (import_records.import_record_id=import_biblios.import_record_id)
                                    WHERE  import_batch_id = ?";
    my @params;
    push(@params, $batch_id);
    if ($status) {
        $query .= " AND status=?";
        push(@params,$status);
    }

    $query.=" ORDER BY $order_by $order_by_direction";

    if($results_per_group){
        $query .= " LIMIT ?";
        push(@params, $results_per_group);
    }
    if($offset){
        $query .= " OFFSET ?";
        push(@params, $offset);
    }
    my $sth = $dbh->prepare_cached($query);
    $sth->execute(@params);
    my $results = $sth->fetchall_arrayref({});
    $sth->finish();
    return $results;

}

=head2 GetBestRecordMatch

  my $record_id = GetBestRecordMatch($import_record_id);

=cut

sub GetBestRecordMatch {
    my ($import_record_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT candidate_match_id
                             FROM   import_record_matches
                             JOIN   import_records ON ( import_record_matches.import_record_id = import_records.import_record_id )
                             LEFT JOIN biblio ON ( candidate_match_id = biblio.biblionumber )
                             LEFT JOIN auth_header ON ( candidate_match_id = auth_header.authid )
                             WHERE  import_record_matches.import_record_id = ? AND
                             (  (import_records.record_type = 'biblio' AND biblio.biblionumber IS NOT NULL) OR
                                (import_records.record_type = 'auth' AND auth_header.authid IS NOT NULL) )
                             ORDER BY score DESC, candidate_match_id DESC");
    $sth->execute($import_record_id);
    my ($record_id) = $sth->fetchrow_array();
    $sth->finish();
    return $record_id;
}

=head2 GetImportBatchStatus

  my $status = GetImportBatchStatus($batch_id);

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

  SetImportBatchStatus($batch_id, $new_status);

=cut

sub SetImportBatchStatus {
    my ($batch_id, $new_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET import_status = ? WHERE import_batch_id = ?");
    $sth->execute($new_status, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchOverlayAction

  my $overlay_action = GetImportBatchOverlayAction($batch_id);

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

  SetImportBatchOverlayAction($batch_id, $new_overlay_action);

=cut

sub SetImportBatchOverlayAction {
    my ($batch_id, $new_overlay_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET overlay_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_overlay_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchNoMatchAction

  my $nomatch_action = GetImportBatchNoMatchAction($batch_id);

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

  SetImportBatchNoMatchAction($batch_id, $new_nomatch_action);

=cut

sub SetImportBatchNoMatchAction {
    my ($batch_id, $new_nomatch_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET nomatch_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_nomatch_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchItemAction

  my $item_action = GetImportBatchItemAction($batch_id);

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

  SetImportBatchItemAction($batch_id, $new_item_action);

=cut

sub SetImportBatchItemAction {
    my ($batch_id, $new_item_action) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET item_action = ? WHERE import_batch_id = ?");
    $sth->execute($new_item_action, $batch_id);
    $sth->finish();

}

=head2 GetImportBatchMatcher

  my $matcher_id = GetImportBatchMatcher($batch_id);

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

  SetImportBatchMatcher($batch_id, $new_matcher_id);

=cut

sub SetImportBatchMatcher {
    my ($batch_id, $new_matcher_id) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_batches SET matcher_id = ? WHERE import_batch_id = ?");
    $sth->execute($new_matcher_id, $batch_id);
    $sth->finish();

}

=head2 GetImportRecordOverlayStatus

  my $overlay_status = GetImportRecordOverlayStatus($import_record_id);

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

  SetImportRecordOverlayStatus($import_record_id, $new_overlay_status);

=cut

sub SetImportRecordOverlayStatus {
    my ($import_record_id, $new_overlay_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET overlay_status = ? WHERE import_record_id = ?");
    $sth->execute($new_overlay_status, $import_record_id);
    $sth->finish();

}

=head2 GetImportRecordStatus

  my $overlay_status = GetImportRecordStatus($import_record_id);

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

  SetImportRecordStatus($import_record_id, $new_overlay_status);

=cut

sub SetImportRecordStatus {
    my ($import_record_id, $new_overlay_status) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET status = ? WHERE import_record_id = ?");
    $sth->execute($new_overlay_status, $import_record_id);
    $sth->finish();

}

=head2 GetImportRecordMatches

  my $results = GetImportRecordMatches($import_record_id, $best_only);

=cut

sub GetImportRecordMatches {
    my $import_record_id = shift;
    my $best_only = @_ ? shift : 0;

    my $dbh = C4::Context->dbh;
    # FIXME currently biblio only
    my $sth = $dbh->prepare_cached("SELECT title, author, biblionumber,
                                    candidate_match_id, score, record_type
                                    FROM import_records
                                    JOIN import_record_matches USING (import_record_id)
                                    LEFT JOIN biblio ON (biblionumber = candidate_match_id)
                                    WHERE import_record_id = ?
                                    ORDER BY score DESC, biblionumber DESC");
    $sth->bind_param(1, $import_record_id);
    my $results = [];
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        if ($row->{'record_type'} eq 'auth') {
            $row->{'authorized_heading'} = C4::AuthoritiesMarc::GetAuthorizedHeading( { authid => $row->{'candidate_match_id'} } );
        }
        next if ($row->{'record_type'} eq 'biblio' && not $row->{'biblionumber'});
        push @$results, $row;
        last if $best_only;
    }
    $sth->finish();

    return $results;
    
}


=head2 SetImportRecordMatches

  SetImportRecordMatches($import_record_id, @matches);

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
    my ($batch_id, $record_sequence, $marc_record, $record_type, $encoding, $z3950random, $marc_type) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO import_records (import_batch_id, record_sequence, marc, marcxml, 
                                                         record_type, encoding, z3950random)
                                    VALUES (?, ?, ?, ?, ?, ?, ?)");
    $sth->execute($batch_id, $record_sequence, $marc_record->as_usmarc(), $marc_record->as_xml($marc_type),
                  $record_type, $encoding, $z3950random);
    my $import_record_id = $dbh->{'mysql_insertid'};
    $sth->finish();
    return $import_record_id;
}

sub _update_import_record_marc {
    my ($import_record_id, $marc_record, $marc_type) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE import_records SET marc = ?, marcxml = ?
                             WHERE  import_record_id = ?");
    $sth->execute($marc_record->as_usmarc(), $marc_record->as_xml($marc_type), $import_record_id);
    $sth->finish();
}

sub _add_auth_fields {
    my ($import_record_id, $marc_record) = @_;

    my $controlnumber;
    if ($marc_record->field('001')) {
        $controlnumber = $marc_record->field('001')->data();
    }
    my $authorized_heading = C4::AuthoritiesMarc::GetAuthorizedHeading({ record => $marc_record });
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO import_auths (import_record_id, control_number, authorized_heading) VALUES (?, ?, ?)");
    $sth->execute($import_record_id, $controlnumber, $authorized_heading);
    $sth->finish();
}

sub _add_biblio_fields {
    my ($import_record_id, $marc_record) = @_;

    my ($title, $author, $isbn, $issn) = _parse_biblio_fields($marc_record);
    my $dbh = C4::Context->dbh;
    # FIXME no controlnumber, originalsource
    $isbn = C4::Koha::GetNormalizedISBN($isbn);
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
    my $sth = $dbh->prepare_cached("UPDATE import_batches SET
                                        num_records = (
                                            SELECT COUNT(*)
                                            FROM import_records
                                            WHERE import_batch_id = import_batches.import_batch_id),
                                        num_items = (
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
    my ($overlay_action, $nomatch_action, $item_action, $overlay_status, $import_record_id, $record_type) = @_;
    
    if ($record_type eq 'biblio') {
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
         if($item_action eq 'always_add' or $item_action eq 'add_only_for_matches'){
                $item_result = 'create_new';
       }
      elsif($item_action eq 'replace'){
          $item_result = 'replace';
          }
      else {
             $item_result = 'ignore';
           }
        } else {
            $bib_result = $nomatch_action;
            $item_result = ($item_action eq 'always_add' or $item_action eq 'add_only_for_new')     ? 'create_new' : 'ignore';
        }
        return ($bib_result, $item_result, $bib_match);
    } else { # must be auths
        my ($auth_result, $auth_match);

        if ($overlay_status ne 'no_match') {
            $auth_match = GetBestRecordMatch($import_record_id);
            if ($overlay_action eq 'replace') {
                $auth_result  = defined($auth_match) ? 'replace' : 'create_new';
            } elsif ($overlay_action eq 'create_new') {
                $auth_result  = 'create_new';
            } elsif ($overlay_action eq 'ignore') {
                $auth_result  = 'ignore';
            }
        } else {
            $auth_result = $nomatch_action;
        }

        return ($auth_result, undef, $auth_match);

    }
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

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut
