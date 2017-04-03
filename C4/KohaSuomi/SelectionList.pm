package C4::KohaSuomi::SelectionList;

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

use Koha::DateUtils;

=head new

    my $sl = C4::KohaSuomi::SelectionList->new({
                        vendor => 'Vendor code', #MARC21 971$a
                        identifier => 'E342345E', #Some code from the vendor MARC21 971$b
                        lastOrderDate => '20150505' #MARC21 971$c
                        listName => 'nice name', #MARC21 971$d

                        description => 'this is a selection list from vendor and it has nice stuff in it.', #Meant for the import_batches.comment
                        filePath => '/tmp/marc_transport_file.xml|dat', #For import_batches.filename
                        marcRecords => \@marcRecords, #Arrayref of MARC::Record-objects
    });
    my $sl = C4::KohaSuomi::SelectionList->new($marcRecord); #Create the SelectionList out of a MARC::Record object.
    my $sl = C4::KohaSuomi::SelectionList->new($marcRecord, $selectionListBatch); #

Creates a new SelectionList-object

@PARAMS1, MARC::Record or a HASH of properties.
@PARAMS2, String, A selectionListBatch name.
                  Is this a selection list batch representation, so the description
                  describes the batch, not an individual selection lists?
=cut

sub new {
    my ($class, $self, $batchList) = @_;
    unless ($self) {
        $self = {};
        bless $self, $class;
    }

    ##Create a new SelectionList out of a MARC::Records vendor specific fields.
    if (blessed($self) && $self->isa('MARC::Record')) {
        my $record = $self;
        $self = {};
        bless $self, $class;

        $self->{vendor} = $record->subfield('971','a');
        $self->{identifier} = GetSelectionListIdentifier($record);
        $self->{lastOrderDate} = $record->subfield('971','c');
        $self->{listName} = $record->subfield('971','d');
        $self->{code} = $record->subfield('971','m');
        $self->{productGroup} = $record->subfield('971','t');

        print "SelectionList->new():> No vendor code from 971\$a" unless $self->{vendor};
        print "SelectionList->new():> No identifier from 971\$b" unless $self->{identifier};
        print "SelectionList->new():> No lastOrderDate from 971\$c" unless $self->{lastOrderDate};
        print "SelectionList->new():> No listName from 971\$d" unless $self->{listName};
        #print "SelectionList->new():> No code from 971\$m" unless $self->{code}; #Code is not so important, and BTJ doesn't have it.
        print "SelectionList->new():> No productGroup from 971\$t" unless $self->{productGroup};
    }

    if ($batchList) {
        $self->{identifier} = $batchList;
        $self->{batchList} = $batchList;
    }

    $self->{marcRecords} = [] unless $self->{marcRecords} && ref $self->{marcRecords} eq 'ARRAY';
    $self->setDescription();

    return $self;
}

sub addRecord {
    my ($self, $record) = @_;
    if (blessed $record && $record->isa('MARC::Record')) {
        push @{$self->{marcRecords}}, $record;
    }
    else {
        warn "SelectionList->addRecord($record):> Param1 is not a MARC::Record!";
    }
}

sub getMarcRecords {
    my $self = shift;
    return $self->{marcRecords};
}

=head GetSelectionListIdentifier
STATIC FUNCTION
    my $identifier = C4::KohaSuomi::SelectionList::GetSelectionListIdentifier($marcRecord);
=cut

sub GetSelectionListIdentifier {
    my ($record) = @_;
    return $record->subfield('971','b');
}


sub getIdentifier {
    my $self = shift;
    return $self->{identifier};
}
sub setDescription {
    my ($self, $description) = @_;
    if ($description) {
        $self->{description} = $description;
    }
    else {
        if ($self->{vendor} && $self->{identifier}) {
            #Turn the last order date to Koha date preference.
            my $lastOrderDate;
            if ($self->{lastOrderDate} =~ /(\d\d\d\d)(\d\d)(\d\d)/){
                $self->{lastOrderDate} = Koha::DateUtils::format_sqldatetime("$1-$2-$3", undef, undef, 1); #DateOnly
            }
            $lastOrderDate = ($self->{lastOrderDate}) ? '<BR/>Viim. '.$self->{lastOrderDate} : '';

            my $code = ($self->{code}) ? ' '.$self->{code} : '';
            my $productGroup = ($self->{productGroup}) ? ' - Tuoteryh. '.$self->{productGroup} : '';
            my $listName = ($self->{listName}) ? '<br/>'.$self->{listName} : '';

            if ($self->{batchList}) {
                $self->{description} = '<i>'.$self->{vendor}.'</i>'.$lastOrderDate;
            }
            else {
                $self->{description} = '<i>'.$self->{vendor}.$code.$productGroup.'</i>'.$listName.$lastOrderDate;
            }
        }
        else {
            $self->{description} = "Invalid MARC-data from 971\$* to generate a description.";
        }
    }
}
sub getDescription {
    my $self = shift;
    return $self->{description};
}
sub setFilePath {
    my ($self, $filePath) = @_;
    $self->{filePath} = $filePath;
}
sub getFilePath {
    my $self = shift;
    return $self->{filePath};
}

1; #Happy compiler happy!