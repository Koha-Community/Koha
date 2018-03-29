package Koha::SearchField;

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

use Carp;

use Koha::Database;
use Koha::SearchMarcMaps;

use base qw(Koha::Object);

=head1 NAME

Koha::SearchField - Koha SearchField Object class

=head1 API

=head2 Class Methods

=cut

sub add_to_search_marc_maps {
    my ( $self, $search_field, $params ) = @_;
    return $self->_result()->add_to_search_marc_maps($search_field->_result, $params);
}

=head3 search_marc_maps

my $search_marc_maps = $search_field->search_marc_maps;

=cut

sub search_marc_maps {
    my ( $self ) = @_;

    my $marc_type = lc C4::Context->preference('marcflavour');
    my @marc_maps = ();

    my $schema = Koha::Database->new->schema;
    my @marc_map_fields = $schema->resultset('SearchMarcToField')->search({
        search_field_id => $self->id
    });

    return @marc_maps unless @marc_map_fields;

    foreach my $marc_field ( @marc_map_fields ) {
        my $marc_map = Koha::SearchMarcMaps->find( $marc_field->search_marc_map_id );
        push @marc_maps, $marc_map if $marc_map->marc_type eq $marc_type;
    }

    return @marc_maps;

}

=head3 is_mapped_biblios

my $is_mapped_biblios = $search_field->is_mapped_biblios

=cut

sub is_mapped_biblios {
    my ( $self ) = @_;

    foreach my $marc_map ( $self->search_marc_maps ) {
        return 1 if $marc_map->index_name eq 'biblios';
    }

    return 0;
}

=head3 type

=cut

sub _type {
    return 'SearchField';
}

1;
