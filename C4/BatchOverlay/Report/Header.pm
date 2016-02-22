package C4::BatchOverlay::Report::Header;

# Copyright (C) 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Context;
use C4::Biblio;
use C4::BatchOverlay;
use C4::BatchOverlay::ReportManager;

use Koha::Exception::BadParameter;
use Koha::Exception::DB;

sub new {
    my ($class, $record) = @_;

    unless(blessed($record) && $record->isa('MARC::Record')) {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]." is trying to create a ".__PACKAGE__."-object, but the parameter \$record '$record' is not a MARC::Record");
    }

    my ( $tagid_biblionumber, $subfieldid_biblionumber ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber" );
    my $biblionumber = $record->subfield( $tagid_biblionumber, $subfieldid_biblionumber );
    my $self = {
        title => C4::Biblio::GetMarcTitle($record) || '',
        stdid => scalar(C4::Biblio::GetMarcStdids($record) || ''),
        biblionumber => $biblionumber,
        breedingid => $record->{breedingid}, #Breedingid might be injected here
    };
    bless $self, $class;
    return $self;
}
sub newFromDB {
    my ($class, $row) = @_;

    my $error;
    if(not($row->{id})) {
        $error = "'id'";
    }
    if(not(defined($row->{title}))) {
        $error = "'title'";
    }
    elsif(not(exists($row->{stdid}))) {
        $error = "'stdid'";
    }
    elsif(not(exists($row->{biblionumber}))) {
        $error = "'biblionumber'";
    }
    elsif(not(exists($row->{breedingid}))) {
        $error = "'breedingid'";
    }
    if ($error) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]." is trying to create a '".__PACKAGE__."-object from a DB row '$row', but is has an error with column '$error'");
    }
    bless $row, $class;
    return $row;
}

sub persist {
    my ($self, $batchOverlayReportId) = @_;

    $self->setBatchOverlayReportId($batchOverlayReportId);
    $self->setId( C4::BatchOverlay::ReportManager->_insertHeaderToDB($batchOverlayReportId, $self->{biblionumber}, $self->{breedingid}, $self->{title}, $self->{stdid}) );
}

sub getId {
    return shift->{id};
}
sub setId {
    my ($self, $id) = @_;
    return $self->{id} = $id;
}
sub getBatchOverlayReportId {
    return shift->{batch_overlay_diff_id};
}
sub setBatchOverlayReportId {
    my ($self, $id) = @_;
    return $self->{batch_overlay_diff_id} = $id;
}
sub getTitle {
    return shift->{title};
}
sub getStdid {
    return shift->{stdid};
}
sub getBiblionumber {
    return shift->{biblionumber};
}
sub getBreedingid {
    return shift->{breedingid};
}
1; #Satisfying the compiler, we aim to please!
