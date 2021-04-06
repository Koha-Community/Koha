package Koha::Filter::MARC::EmbedItems;

# Copyright 2019  Theke Solutions

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

=head1 NAME

Koha::Filter::MARC::EmbedItems - Appends item information on MARC::Record objects.

=head1 SYNOPSIS

my $biblio = Koha::Biblios->find(
    $biblio_id,
    { prefetch => [ items, metadata ] }
);

my $rules = C4::Context->yaml_preference('OpacHiddenItems');

my @items  = grep { !$_->hidden_in_opac({ rules => $rules }) @{$biblio->items};
my $record = $biblio->metadata->record;

my $processor = Koha::RecordProcessor->new(
    {
        filters => ('EmbedItems'),
        options => {
            items        => \@items
        }
    }
);

$processor->process( $record );

=head1 DESCRIPTION

Filter to embed items information into MARC::Record objects.

=cut

use Modern::Perl;

use C4::Biblio;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'EmbedItems';

=head2 filter

Embed items into the MARC::Record object.

=cut

sub filter {
    my $self   = shift;
    my $record = shift;

    return unless defined $record and ref($record) eq 'MARC::Record';

    my $items = $self->{params}->{options}->{items};
    my $mss   = $self->{params}->{options}->{mss}
      // C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 1 } );

    my @item_fields;

    foreach my $item ( @{$items} ) {
        push @item_fields, $item->as_marc_field( { mss => $mss } );
    }

    $record->append_fields(@item_fields);

    return $record;
}

1;
