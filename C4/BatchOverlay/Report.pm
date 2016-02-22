package C4::BatchOverlay::Report;

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
use Data::Dumper;
use JSON::XS;
use Encode;
use DateTime::Format::MySQL;

use C4::Context;
use C4::Biblio;
use C4::BatchOverlay::Report::Header;
use C4::BatchOverlay::Report::Report;
use C4::BatchOverlay::Report::Error;
use C4::BatchOverlay::ReportManager;

use Koha::Exception::BadParameter;
use Koha::Exception::DB;
use Koha::Exception::Parse;
use Koha::Exception::UnknownProgramState;

=head new
@OVERLOADABLE

Call from subclasses to generate common elements, like Headers

=cut

sub new {
    my ($self) = @_;
    $self->{recordHeaders} = [];
    $self->_generateRecordHeaders();

    my $biblionumber;
    my ( $tagid_biblionumber, $subfieldid_biblionumber ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber" );
    $biblionumber = $self->{localRecord}->subfield( $tagid_biblionumber, $subfieldid_biblionumber ) if $self->{localRecord};
    $biblionumber = $self->{newRecord}->subfield( $tagid_biblionumber, $subfieldid_biblionumber ) if not($biblionumber) && $self->{newRecord};
    $biblionumber = $self->{mergedRecord}->subfield( $tagid_biblionumber, $subfieldid_biblionumber ) if not($biblionumber) && $self->{mergedRecord};
    if ($biblionumber) {
        $self->setBiblionumber($biblionumber);
    }

    return $self;
}

=head newFromDB

Figures out what kind of a Report this row is and creates a matching object.

=cut

sub newFromDB {
    my ($class, $row) = @_;
    _validateDBRow($row);

    #Figure out the proper class
    my $subclass = C4::BatchOverlay::Report->getSubclass($row);
    $row = $subclass->newFromDB($row);

    eval {
        $row->{timestamp} = DateTime::Format::MySQL->parse_datetime( $row->{timestamp} );
    };
    if ($@) {
        my @cc = caller(1);
        Koha::Exception::Parse->throw(error => $cc[3]." is trying to create a ".__PACKAGE__."-object from the DB row '$row', but the 'timestamp' parameter '".$row->{timestamp}."' is not a valid ISO8601 datetime\n$@\n");
    }
    $row->{diff} = $row->deserializeDiff($row->{diff});
    $row->{recordHeaders} = [];
    $row->_getHeadersFromDB();

    return $row;
}
sub getSubclass {
    my ($class, $row) = @_;

    if ($row->{operation} eq 'error') {
        return 'C4::BatchOverlay::Report::Error';
    }
    else {
        return 'C4::BatchOverlay::Report::Report';
    }
}
sub addHeader {
    my ($self, $header) = @_;

    push(@{$self->{recordHeaders}}, $header);
    return $self;
}
sub getHeaders {
    return shift->{recordHeaders};
}

sub _generateRecordHeaders {
    my ($self) = @_;
    my @records;
    push(@records, $self->{localRecord}) if $self->{localRecord};
    push(@records, $self->{newRecord}) if $self->{newRecord};
    push(@records, $self->{mergedRecord}) if $self->{mergedRecord};

    for(my $ri=0 ; $ri<scalar(@records) ; $ri++) {
        my $r = $records[$ri];
        my $rhead = C4::BatchOverlay::Report::Header->new($r);
        $self->addHeader($rhead);
    }
}

sub _getHeadersFromDB {
    my ($self) = @_;

    my $headerRows = C4::BatchOverlay::ReportManager->listHeaders($self->{id});
    foreach my $hr (@$headerRows) {
        $self->addHeader( C4::BatchOverlay::Report::Header->newFromDB($hr) );
    }
}

sub _validate {
    my ($report) = @_;
    try {
        unless ($report->{operation}) {
            die 'operation';
        }
        if ($report->{localRecord} && not(blessed($report->{localRecord}) && $report->{localRecord}->isa('MARC::Record'))) {
            die 'localRecord';
        }
        unless (blessed($report->{timestamp}) && $report->{timestamp}->isa('DateTime')) {
            die 'timestamp';
        }
        if ($report->{localRecord} && not(blessed($report->{overlayRule}) && $report->{overlayRule}->isa('C4::BatchOverlay::Rule'))) {
            die 'overlayRule';
        }
    } catch {
        $report->_throwValidationError($_);
    };
    return $report;
}
sub _throwValidationError {
    my ($report, $die) = @_;
    my $exampleReport = "{ localRecord => MARC::Record,\n".
                        "  newRecord => MARC::Record,\n".
                        "  margedRecord => MARC::Record,\n".
                        "  operation => 'record merging' || 'error',\n".
                        "  timestamp => DateTime\n".
                        "  overlayRule => C4::BatchOverlay::Rule\n".
                        "}";
    #Flatten properties or it will flood the error report
    $report->{timestamp} = $report->{timestamp}->iso8601() if blessed($report->{timestamp}) && $report->{timestamp}->isa('DateTime');
    foreach my $key (keys %$report) {
        $report->{$key} = ref($report->{$key}) if ref($report->{$key});
    }
    my @cc5 = caller(5);
    Koha::Exception::BadParameter->throw(
            error => $cc5[3]." is trying to add a report, but the report's property '$die' is undefined. Report should look something like this:\n".
            "$exampleReport\n".
            "But what I got is:\n".
            Data::Dumper::Dumper($report)
    );
}
sub _validateDBRow {
    my ($row) = @_;
    unless (ref($row) eq 'HASH') {
        my @cc2 = caller(2);
        Koha::Exception::BadParameter->throw(
                error => $cc2[3]." is trying to add a report from a DB row '$row', but the DB row is not a HASH"
        );
    }

    my @requiredProperties = qw(id batch_overlay_reports_id timestamp operation diff);
    foreach my $prop (@requiredProperties) {
        unless($row->{$prop}) {
            my @cc2 = caller(2);
            Koha::Exception::BadParameter->throw(
                    error => $cc2[3]." is trying to add a report from a DB row '$row', but the DB row is missing column '$prop'"
            );
        }
    }
}

sub serializeDiff {
    my ($self) = @_;
    my $text;
    eval {
        $text = JSON::XS->new->encode($self->{diff}); #Dont touch utf:ness here
    };
    if ($@) {
        my @cc = caller(1);
        Koha::Exception::Parse->throw(error => $cc[3]." is parsing 'diff' '".$self->{diff}."' as json but it cannot be parsed:\n$@\n");
    }
    return $text;
}
sub deserializeDiff {
    my ($self, $text) = @_;
    my $diff;
    eval {
        $diff = JSON::XS->new->decode( $text ); #Dont touch utf:ness here
    };
    if ($@) {
        my @cc = caller(1);
        Koha::Exception::Parse->throw(error => $cc[3]." is parsing 'diff' '$text' as HASH but it cannot be parsed:\n$@\n");
    }
    return $diff;
}

sub persist {
    my ($self, $reportContainerId) = @_;

    $self->setReportContainerId($reportContainerId);
    $self->setId(  C4::BatchOverlay::ReportManager->_insertDiffToDB($reportContainerId, $self->getBiblionumber(), $self->getOperation(), $self->{overlayRule}->{ruleName}, $self->serializeDiff())  );

    foreach my $header (@{$self->getHeaders()}) {
        $header->persist( $self->getId() );
    }
}

sub getId {
    return shift->{id};
}
sub setId {
    my ($self, $id) = @_;
    return $self->{id} = $id;
}
sub getReportContainerId {
    return shift->{batch_overlay_reports_id};
}
sub setReportContainerId {
    my ($self, $id) = @_;
    return $self->{batch_overlay_reports_id} = $id;
}
sub setBiblionumber {
    my ($self, $bn) = @_;
    return $self->{biblionumber} = $bn;
}
sub getBiblionumber {
    return shift->{biblionumber};
}
sub getTimestamp {
    return shift->{timestamp};
}
sub getOperation {
    return shift->{operation};
}
sub getRuleName {
    return shift->{ruleName};
}
sub getDiff {
    return shift->{diff};
}

1; #Satisfying the compiler, we aim to please!
