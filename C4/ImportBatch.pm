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
use C4::Context;
use C4::Koha;
use C4::Biblio;
use C4::Matcher;
require Exporter;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::ImportBatch - manage batches of imported MARC records

=head1 SYNOPSIS

=over 4

use C4::ImportBatch;

=back

=head1 FUNCTIONS

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
    GetZ3950BatchId
    GetImportRecordMarc
    AddImportBatch
    AddBiblioToBatch
    ModBiblioInBatch

    BatchStageMarcRecords
    BatchFindBibDuplicates
    BatchCommitBibRecords
    
    GetImportBatchStatus
    SetImportBatchStatus
    GetImportBatchOverlayAction
    SetImportBatchOverlayAction
    GetImportRecordOverlayStatus
    SetImportRecordOverlayStatus
    SetImportRecordMatches
);

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

=over4

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

=head2 AddBiblioToBatch 

=over 4

my $import_record_id = AddBiblioToBatch($batch_id, $record_sequence, $marc_record, $encoding, $z3950random);

=back

=cut

sub AddBiblioToBatch {
    my ($batch_id, $record_sequence, $marc_record, $encoding, $z3950random) = @_;

    my $import_record_id = _create_import_record($batch_id, $record_sequence, $marc_record, 'biblio', $encoding, $z3950random);
    _add_biblio_fields($import_record_id, $marc_record);
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

($batch_id, $num_records, @invalid_records) = BatchStageMarcRecords($marc_flavor, $marc_records, $file_name, 
                                                                    $comments, $branch_code, $leave_as_staging);

=back

=cut

sub  BatchStageMarcRecords {
    my ($marc_flavor, $marc_records, $file_name, $comments, $branch_code, $leave_as_staging) = @_;

    my $batch_id = AddImportBatch('create_new', 'staging', 'batch', $file_name, $comments);
    my @invalid_records = ();
    my $num_valid = 0;
    # FIXME - for now, we're dealing only with bibs
    my $rec_num = 0;
    foreach my $marc_blob (split(/\x1D/, $marc_records)) {
        $rec_num++;
        my $marc_record = FixEncoding($marc_blob, "\x1D");
        my $import_record_id;
        if (scalar($marc_record->fields()) == 0) {
            push @invalid_records, $marc_blob;
        } else {
            $num_valid++;
            $import_record_id = AddBiblioToBatch($batch_id, $rec_num, $marc_record, $marc_flavor, int(rand(99999)));
        }
    }
    unless ($leave_as_staging) {
        SetImportBatchStatus($batch_id, 'staged');
    }
    # FIXME batch_code, number of bibs, number of items
    return ($batch_id, $num_valid, @invalid_records);
}

=head2 BatchFindBibDuplicates

=over4

my $num_with_matches = BatchFindBibDuplicates($batch_id, $matcher, $max_matches);

=back

Goes through the records loaded in the batch and attempts to 
find duplicates for each one.  Sets the overlay action to
'replace' if it was 'create_new', and sets the overlay status
of each record to 'no_match' or 'auto_match' as appropriate.

The $max_matches parameter is optional; if it is not supplied,
it defaults to 10.

=cut

sub BatchFindBibDuplicates {
    my $batch_id = shift;
    my $matcher = shift;
    my $max_matches = @_ ? shift : 10;

    my $dbh = C4::Context->dbh;
    my $old_overlay_action = GetImportBatchOverlayAction($batch_id);
    if ($old_overlay_action eq "create_new") {
        SetImportBatchOverlayAction($batch_id, 'replace');
    }

    my $sth = $dbh->prepare("SELECT import_record_id, marc
                             FROM import_records
                             JOIN import_biblios USING (import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    my $num_with_matches = 0;
    while (my $rowref = $sth->fetchrow_hashref) {
        my $marc_record = MARC::Record->new_from_usmarc($rowref->{'marc'});
        my @matches = $matcher->get_matches($marc_record, $max_matches);
        if (scalar(@matches) > 0) {
            $num_with_matches++;
            SetImportRecordMatches($rowref->{'import_record_id'}, @matches);
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'auto_match');
        } else {
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'no_match');
        }
    }
    $sth->finish();
    return $num_with_matches;
}

=head2 BatchCommitBibRecords

=over 4

my ($num_added, $num_updated, $num_ignored) = BatchCommitBibRecords($batch_id);

=back

=cut

sub BatchCommitBibRecords {
    my $batch_id = shift;

    my $num_added = 0;
    my $num_updated = 0;
    my $num_ignored = 0;
    # commit (i.e., save, all records in the batch)
    # FIXME biblio only at the moment
    SetImportBatchStatus('importing');
    my $overlay_action = GetImportBatchOverlayAction($batch_id);
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT import_record_id, status, overlay_status, marc
                             FROM import_records
                             JOIN import_biblios USING (import_record_id)
                             WHERE import_batch_id = ?");
    $sth->execute($batch_id);
    while (my $rowref = $sth->fetchrow_hashref) {
        if ($rowref->{'status'} eq 'error' or $rowref->{'status'} eq 'imported') {
            $num_ignored++;
        }
        my $marc_record = MARC::Record->new_from_usmarc($rowref->{'marc'});
        if ($overlay_action eq 'create_new' or
            ($overlay_action eq 'replace' and $rowref->{'overlay_status'} eq 'no_match')) {
            $num_added++;
            my ($biblionumber, $biblioitemnumber) = AddBiblio($marc_record, '');
        } else {
            $num_updated++;
            my $biblionumber = GetBestRecordMatch($rowref->{'import_record_id'});
            my ($count, $oldbiblio) = GetBiblio($biblionumber);
            my $oldxml = GetXmlBiblio($biblionumber);
            ModBiblio($marc_record, $biblionumber, $oldbiblio->{'frameworkcode'});
            my $dbh = C4::Context->dbh;
            my $sth = $dbh->prepare("UPDATE import_records SET marcxml_old = ? WHERE import_record_id = ?");
            $sth->execute($oldxml, $rowref->{'import_record_id'});
            $sth->finish();
            SetImportRecordOverlayStatus($rowref->{'import_record_id'}, 'match_applied');
        }
    }
    $sth->finish();
    SetImportBatchStatus('imported');
    return ($num_added, $num_updated, $num_ignored);
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
    my $sth = $dbh->prepare("SELECT import_status FROM import_batches WHERE batch_id = ?");
    $sth->execute($batch_id);
    my ($status) = $sth->fetchrow_array();
    $sth->finish();
    return;

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
    # FIXME 2 - should regularize normalization of ISBN wherever it is done
    $isbn =~ s/\(.*$//;
    $isbn =~ tr/ -_//;  
    $isbn = uc $isbn;
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

1;

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
