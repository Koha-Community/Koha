package Koha::UI::Table::Builder::Items;

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

use Modern::Perl;
use List::MoreUtils qw( uniq );
use C4::Biblio qw( GetMarcStructure GetMarcFromKohaField IsMarcStructureInternal );
use Koha::Items;

=head1 NAME

Koha::UI::Table::Builder::Items

Helper to build a table with a list of items with all their information.

Items' attributes that are mapped and not mapped will be listed in the table.

Only attributes that have been defined only once will be displayed (empty string is considered as not defined).

=head1 API

=head2 Class methods

=cut

=head3 new

    my $table = Koha::UI::Table::Builder::Items->new( { itemnumbers => \@itemnumbers } );

Constructor.

=cut

sub new {
    my ( $class, $params ) = @_;

    my $self;
    $self->{itemnumbers} = $params->{itemnumbers} || [];

    bless $self, $class;
    return $self;
}

=head3 build_table

    my $items_table = Koha::UI::Table::Builder::Items->new( { itemnumbers => \@itemnumbers } )
                                                     ->build_table;

    my $items   = $items_table->{items};
    my $headers = $items_table->{headers};

Build the headers and rows for the table.

Use it with:
    [% PROCESS items_table_batchmod headers => headers, items => items %]

=cut

sub build_table {
    my ( $self, $params ) = @_;

    my $patron = $params->{patron};

    my %itemnumbers_to_idx = map { $self->{itemnumbers}->[$_] => $_ } 0..$#{$self->{itemnumbers}};

    my $items = Koha::Items->search( { itemnumber => $self->{itemnumbers} } );

    my @items;
    while ( my $item = $items->next ) {
        my $item_info = $item->columns_to_str;
        $item_info = {
            %$item_info,
            index          => $itemnumbers_to_idx{$item->itemnumber},
            biblio         => $item->biblio,
            safe_to_delete => $item->safe_to_delete,
            holds          => $item->biblio->holds->count,
            item_holds     => $item->holds->count,
            is_checked_out => $item->checkout ? 1 : 0,
            nomod          => $patron ? !$patron->can_edit_items_from($item->homebranch) : 0,
        };
        push @items, $item_info;
    }

    $self->{headers} = $self->_build_headers( \@items );
    $self->{items}   = \@items;
    return $self;
}

=head2 Internal methods

=cut

=head3 _build_headers

Build the headers given the items' info.

=cut

sub _build_headers {
    my ( $self, $items ) = @_;

    my @witness_attributes = uniq map {
        my $item = $_;
        map {
            defined $item->{$_}
              && !ref( $item->{$_} ) # biblio and safe_to_delete are objects
              && $item->{$_} ne ""
              ? $_
              : ()
          } keys %$item
    } @$items;

    my ( $itemtag, $itemsubfield ) =
      C4::Biblio::GetMarcFromKohaField("items.itemnumber");
    my $tagslib = C4::Biblio::GetMarcStructure(1);
    my $subfieldcode_attribute_mappings;
    for my $subfield_code ( keys %{ $tagslib->{$itemtag} } ) {

        my $subfield = $tagslib->{$itemtag}->{$subfield_code};

        next if IsMarcStructureInternal($subfield);
        next unless $subfield->{tab} eq 10;    # Is this really needed?

        my $attribute;
        if ( $subfield->{kohafield} ) {
            ( $attribute = $subfield->{kohafield} ) =~ s|^items\.||;
        }
        else {
            $attribute = $subfield_code;       # It's in more_subfields_xml
        }
        next unless grep { $attribute eq $_ } @witness_attributes;
        $subfieldcode_attribute_mappings->{$subfield_code} = $attribute;
    }

    return [
        map {
            {
                header_value  => $tagslib->{$itemtag}->{$_}->{lib},
                attribute     => $subfieldcode_attribute_mappings->{$_},
                subfield_code => $_,
            }
        } sort keys %$subfieldcode_attribute_mappings
    ];
}

1
