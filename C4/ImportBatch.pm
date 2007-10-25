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

=cut

sub AddBiblioToBatch {
    my ($batch_id, $record_sequence, $marc_record, $encoding, $z3950random) = @_;

    my $import_record_id = _create_import_record($batch_id, $record_sequence, $marc_record, 'bib', $encoding, $z3950random);
    _add_biblio_fields($import_record_id, $marc_record);
    return $import_record_id;
}

=head2 ModBiblioInBatch

=over 4

ModBiblioInBatch($import_record_id, $marc_record);

=cut

sub ModBiblioInBatch {
    my ($import_record_id, $marc_record) = @_;

    _update_import_record_marc($import_record_id, $marc_record);
    _update_biblio_fields($import_record_id, $marc_record);

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
