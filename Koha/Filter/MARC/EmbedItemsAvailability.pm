package Koha::Filter::MARC::EmbedItemsAvailability;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::Filter::MARC::EmbedItemsAvailability - calculates item availability and embeds
it in a fixed MARC subfield for indexing.

=head1 SYNOPSIS

my $processor = Koha::RecordProcessor->new({ filters => ('EmbedItemsAvailability') });

=head1 DESCRIPTION

Filter to embed items not on loan count information into MARC records.

=cut

use Modern::Perl;

use C4::Biblio qw( GetMarcFromKohaField );
use Koha::Items;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'EmbedItemsAvailability';

=head2 filter

    my $newrecord = $filter->filter($record);
    my $newrecords = $filter->filter(\@records);

Embed not on loan items count into the specified record(s) and return the result.

=cut

sub filter {
    my $self   = shift;
    my $record = shift;
    my $newrecord;

    return unless defined $record;

    if ( ref $record eq 'ARRAY' ) {
        my @recarray;
        foreach my $thisrec (@$record) {
            push @recarray, _processrecord($thisrec);
        }
        $newrecord = \@recarray;
    } elsif ( ref $record eq 'MARC::Record' ) {
        $newrecord = _processrecord($record);
    }

    return $newrecord;
}

sub _processrecord {

    my $record = shift;

    my ( $biblionumber_field, $biblionumber_subfield ) = GetMarcFromKohaField("biblio.biblionumber");
    my $biblionumber =
        ( $biblionumber_field > 9 )
        ? $record->field($biblionumber_field)->subfield($biblionumber_subfield)
        : $record->field($biblionumber_field)->data();

    my $not_onloan_items = Koha::Items->search(
        {
            biblionumber => $biblionumber,
            onloan       => undef,
        }
    )->count;

    # check for field 999
    my $destination_field = $record->field('999');
    if ( defined $destination_field ) {

        # we have a field, add what we need
        $destination_field->update( x => $not_onloan_items );
    } else {

        # no field, create one
        $destination_field = MARC::Field->new( '999', '', '', x => $not_onloan_items );
        $record->append_fields($destination_field);
    }

    return $record;
}

1;
