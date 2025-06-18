package Koha::Preservation::Train::Item;

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

use Modern::Perl;

use JSON qw( to_json );
use Try::Tiny;

use Koha::Database;

use base qw(Koha::Object);

use Koha::Items;
use Koha::Preservation::Processings;
use Koha::Preservation::Train::Item::Attributes;

=head1 NAME

Koha::Preservation::Train::Item - Koha Train::Item Object class

=head1 API

=head2 Class methods

=cut

=head3 processing

Return the processing object for this item

=cut

sub processing {
    my ($self) = @_;
    my $rs = $self->_result->processing;    # FIXME Should we return train's default processing if there is no specific?
    return Koha::Preservation::Processing->_new_from_dbic($rs);
}

=head3 catalogue_item

Return the catalogue item object for this train item

=cut

sub catalogue_item {
    my ($self) = @_;
    my $item_rs = $self->_result->item;
    return Koha::Item->_new_from_dbic($item_rs);
}

=head3 train

Return the train object for this item

=cut

sub train {
    my ($self) = @_;
    my $rs = $self->_result->train;
    return Koha::Preservation::Train->_new_from_dbic($rs);
}

=head3 attributes

Getter and setter for the attributes

=cut

sub attributes {
    my ( $self, $attributes ) = @_;

    if ($attributes) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->attributes->delete;

                for my $attribute (@$attributes) {
                    $self->_result->add_to_preservation_processing_attributes_items($attribute);
                }
            }
        );

    }
    my $attributes_rs = $self->_result->preservation_processing_attributes_items;
    return Koha::Preservation::Train::Item::Attributes->_new_from_dbic($attributes_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'PreservationTrainsItem';
}

1;
