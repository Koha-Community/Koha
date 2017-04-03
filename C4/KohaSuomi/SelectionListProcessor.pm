package C4::KohaSuomi::SelectionListProcessor;

# Copyright 2015 Vaara-kirjastot
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use MARC::Batch;

use Scalar::Util qw( blessed );
use Try::Tiny;

use File::Basename;

#@Throws
use Koha::Exception::File;

use C4::KohaSuomi::SelectionList;
use C4::ImportBatch;

sub new {
    my ($class, $self) = @_;

    $self = {} unless $self;

    bless $self, $class;
    return $self;
}

=head splitToSubSelectionLists

@PARAMS-HASH
  ->{encoding}    = 'utf-8' or some other encoding.
  ->{file}        = String, absolute path to the selectionListsBatch to split to selection lists.
  ->{writeToFile} = boolean, Write selection lists as new files next to the source file. REQUIRES 'file' to be given!
  ->{singleList}  = String, if you don't want to split the selection lists, but instead gather them all under this listName
@RETURNS Arrayref of C4::KohaSuomi::SelectionList-objects
=cut

sub splitToSubSelectionLists {
    my ($self, $records, $params) = @_;
    my $marc_encoding = $params->{encoding} || $self->{encoding};

    #Sort the Records based on the selection list name.
    my %recordsGroupedBySelectionList;
    foreach my $record (@$records) {
        my $newname = ($params->{singleList}) ? $params->{singleList} : C4::KohaSuomi::SelectionList::GetSelectionListIdentifier($record);
        $recordsGroupedBySelectionList{$newname} = C4::KohaSuomi::SelectionList->new($record, $params->{singleList}) unless $recordsGroupedBySelectionList{$newname};
        $recordsGroupedBySelectionList{$newname}->addRecord( $record );
    }

    while (my ($newname, $selectionList) = each(%recordsGroupedBySelectionList)) {

        sanitateRecords($selectionList->getMarcRecords(), $marc_encoding);

        if ($params->{writeToFile}) {
            $self->writeSelectionListToFile($newname, $selectionList, $params);
        }
    }
    return \%recordsGroupedBySelectionList;
}

=head splitToSubSelectionListsFromFile

@PARAMS-HASH
See splitToSubSelectionLists
Also exclusive here
  ->{format}  = String, either MARCXML or ISO2709

@Throws Koha::Exception::File
=cut

sub splitToSubSelectionListsFromFile {
    my ($self, $params) = @_;

    my $records = $self->_loadFile($params);
    $self->splitToSubSelectionLists($records, $params);
}

=head _loadFile
@Throws Koha::Exception::File
=cut

sub _loadFile {
    my ($self, $params) = @_;
    my $marc_encoding = $params->{encoding} || $self->{encoding};
    my ($errors, $records);
    if ($params->{format} =~ /ISO2709/i) {
        ($errors, $records) = C4::ImportBatch::RecordsFromISO2709File($params->{file}, 'biblio', $marc_encoding);
    }
    elsif ($params->{format} =~ /MARCXML/i) {
        ($errors, $records) = C4::ImportBatch::RecordsFromMARCXMLFile($params->{file}, $marc_encoding);
    }
    print "Errors when reading selection list:\n".join("\n", @$errors) if scalar(@$errors);
    Koha::Exception::File->throw(error => "Couldn't extract MARC::Records from file '".$params->{file}."'") unless $records;
    return $records;
}

=head writeSelectionListToFile
It is important to set the leaders utf8-character properly to 'a' before trying to export
utf-8 encoded MARCXML, or they will get double-encoded.
=cut

sub writeSelectionListToFile {
    my ($self, $newname, $selectionList, $params) = @_;

    my($filename, $dirs, $suffix) = File::Basename::fileparse( $params->{file} );

    $selectionList->setFilePath($dirs.$newname);
    my $file = MARC::File::XML->out( $dirs.$newname, 'utf-8' );
    foreach my $record (@{$selectionList->getMarcRecords()}) {
        $file->write($record);
    }
    $file->close();
}

=head sanitateRecords
One can conveniently sanitate Records coming from KV here.
=cut

sub sanitateRecords {
    my ($records, $marc_encoding) = @_;
    if ($marc_encoding =~ /utf-?8/i) { #Remove this if-clause if we get more checks
        foreach my $record (@$records) {
            _enforceLeaderUtf8Flag($record) if ($marc_encoding =~ /utf-?8/i);
        }
    }
}

=head _enforceLeaderUtf8Flag
This should be done only for Records we know should be utf8, otherwise this will cause encoding issues.
Also if this leader is not set, the MARC::File::XML will doubly encode these records.
=cut

sub _enforceLeaderUtf8Flag {
    my $record = shift;
    my $ldr = $record->leader;
    substr($ldr,9,1,'a');
    $record->leader( $ldr );
}

1; #Happy compiler happy!
