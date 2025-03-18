package Koha::SearchField;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::SearchField - Koha SearchField Object class

=head1 API

=head2 Class Methods

=cut

=head2 add_to_search_marc_maps

Missing POD for add_to_search_marc_maps.

=cut

sub add_to_search_marc_maps {
    my ( $self, $search_field, $params ) = @_;
    return $self->_result()->add_to_search_marc_maps( $search_field->_result, $params );
}

=head3 search_marc_maps

my $search_marc_maps = $search_field->search_marc_maps;

=cut

sub search_marc_maps {
    my ($self) = @_;

    my $marc_type = lc C4::Context->preference('marcflavour');

    my $schema          = Koha::Database->new->schema;
    my $marc_map_fields = $schema->resultset('SearchMarcToField')->search(
        {
            'me.search_field_id'        => $self->id,
            'search_marc_map.marc_type' => $marc_type
        },
        {
            select => [
                'search_marc_map.index_name',
                'search_marc_map.marc_type',
                'search_marc_map.marc_field'
            ],
            as   => [ 'index_name', 'marc_type', 'marc_field' ],
            join => 'search_marc_map'
        }
    );

    return $marc_map_fields;
}

=head3 is_mapped

my $is_mapped = $search_field->is_mapped

=cut

sub is_mapped {
    my ($self) = @_;

    return $self->search_marc_maps()->count ? 1 : 0;
}

=head3 is_mapped_biblios

my $is_mapped_biblios = $search_field->is_mapped_biblios

=cut

sub is_mapped_biblios {
    my ($self) = @_;

    return $self->search_marc_maps->search( { index_name => 'biblios' } )->count ? 1 : 0;
}

=head3 type

=cut

sub _type {
    return 'SearchField';
}

1;
