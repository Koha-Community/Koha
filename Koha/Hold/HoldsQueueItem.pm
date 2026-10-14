package Koha::Hold::HoldsQueueItem;

# Copyright 2023 Koha development team
#
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

use Koha::Database;

use Koha::Items;
use Koha::ItemTypes;
use Koha::Biblios;
use Koha::Libraries;
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::Hold::HoldsQueueItem - Koha holds queue items object class

=head1 API

=head2 Class methods

=head3 patron

    my $patron = $queue_item->patron;

Returns the related L<Koha::Patron> object for the hold requester,
or C<undef> if not found.

=cut

sub patron {
    my ($self) = @_;
    my $rs = $self->_result->patron;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 biblio

    my $biblio = $queue_item->biblio;

Returns the related L<Koha::Biblio> object, or C<undef> if not found.

=cut

sub biblio {
    my ($self) = @_;
    my $rs = $self->_result->biblio;
    return unless $rs;
    return Koha::Biblio->_new_from_dbic($rs);
}

=head3 item

    my $item = $queue_item->item;

Returns the related L<Koha::Item> object, or C<undef> if not found.

=cut

sub item {
    my ($self) = @_;
    my $rs = $self->_result->item;
    return unless $rs;
    return Koha::Item->_new_from_dbic($rs);
}

=head3 pickup_library

    my $pickup_library = $queue_item->pickup_library;

Returns the related L<Koha::Library> object, or C<undef> if not found.

=cut

sub pickup_library {
    my ($self) = @_;
    my $rs = $self->_result->pickup_library;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 strings_map

    my $strings = $queue_item->strings_map($params);

Returns a map of coded values to their descriptions, following the C<+strings>
API embed convention. Currently exposes the item type (C<item_type_id>)
translated description for the current language, mirroring
C<Koha::Item/strings_map>.

The item type is resolved via C<< Koha::ItemTypes->find->translated_description >>.
The expensive part (loading a language's translations) is already cached by the
C<localization> cache, so each row only costs a primary-key lookup.

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $strings = {};

    if ( my $item_type_id = $self->_result->get_column('item_type_id') ) {

        # TODO: explore cleaner/batched approaches once available, e.g. the
        # cached Koha::ItemTypes->description_for() class method from Bug 43269.
        my $itemtype = Koha::ItemTypes->find($item_type_id);
        $strings->{item_type_id} = {
            str  => $itemtype ? $itemtype->translated_description : $item_type_id,
            type => 'item_type',
        };
    }

    return $strings;
}

=head3 _type

=cut

sub _type {
    return 'TmpHoldsqueue';
}

=head3 to_api_mapping

=cut

sub to_api_mapping {
    return {
        biblionumber       => 'biblio_id',
        itemnumber         => 'item_id',
        borrowernumber     => 'patron_id',
        reservedate        => 'hold_date',
        holdingbranch      => 'holding_library_id',
        pickbranch         => 'pickup_library_id',
        itemcallnumber     => 'callnumber',
        item_level_request => 'item_level',
        surname            => undef,
        firstname          => undef,
        phone              => undef,
        cardnumber         => undef,
        title              => undef,
        timestamp          => undef,
    };
}

=head1 AUTHORS

Kyle Hall <kyle@bywatersolutions.com>

=cut

1;
