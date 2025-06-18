package Koha::Preservation::Train;

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

use Koha::Preservation::Processings;
use Koha::Preservation::Train::Items;

use Koha::Exceptions::Preservation;

=head1 NAME

Koha::Preservation::Train - Koha Train Object class

=head1 API

=head2 Class methods

=cut

=head3 default_processing

Return the default processing object for this train

=cut

sub default_processing {
    my ($self) = @_;
    my $rs = $self->_result->default_processing;
    return unless $rs;
    return Koha::Preservation::Processing->_new_from_dbic($rs);
}

=head3 add_item

Add item to this train

my $train_item = $train->add_item({item_id => $itemnumber, processing_id => $processing_id}, { skip_waiting_list_check => 0|1 });
my $train_item = $train->add_item({barcode => $barcode, processing_id => $processing_id, { skip_waiting_list_check => 0|1 });

skip_waitin_list_check can be set to true if the item can be added to the train even if the item is not in the waiting list.

=cut

sub add_item {
    my ( $self, $train_item, $params ) = @_;

    Koha::Exceptions::Preservation::CannotAddItemToClosedTrain->throw if $self->closed_on;

    my $skip_waiting_list_check = $params->{skip_waiting_list_check} || 0;

    my $not_for_loan = C4::Context->preference('PreservationNotForLoanWaitingListIn');

    my $key  = exists $train_item->{item_id} ? 'itemnumber' : 'barcode';
    my $item = Koha::Items->find( { $key => $train_item->{item_id} || $train_item->{barcode} } );
    Koha::Exceptions::Preservation::ItemNotFound->throw unless $item;

    Koha::Exceptions::Preservation::ItemNotInWaitingList->throw
        if !$skip_waiting_list_check && $item->notforloan != $not_for_loan;

    my $already_in_train = Koha::Preservation::Train::Items->search(
        { item_id => $train_item->{item_id}, 'train.received_on' => undef },
        { join    => 'train' }
    );
    if ( $already_in_train->count ) {
        my $train_id = $already_in_train->next->train_id;
        Koha::Exceptions::Preservation::ItemAlreadyInAnotherTrain->throw( train_id => $train_id );
    }

    # FIXME We need a LOCK here
    # Not important for now as we have add_items
    # Note that there are several other places in Koha with this max+1 problem
    my $max               = $self->items->search->_resultset->get_column("user_train_item_id")->max || 0;
    my $train_item_object = Koha::Preservation::Train::Item->new(
        {
            train_id           => $self->train_id,
            item_id            => $item->itemnumber,
            processing_id      => $train_item->{processing_id} || $self->default_processing_id,
            user_train_item_id => $max + 1,
            added_on           => \'NOW()',
        }
    )->store;
    $item->notforloan( $self->not_for_loan )->store;
    return $train_item_object->get_from_storage;
}

=head3 add_items

my $train_items = $train->add_items([$item_1, $item_2]);

Add items in batch.

=cut

sub add_items {
    my ( $self, $train_items ) = @_;
    my @added_items;
    for my $train_item (@$train_items) {
        try {
            my $added_item = $self->add_item($train_item);
            $added_item->attributes( $train_item->{attributes} );
            push @added_items, $added_item;
        } catch {

            # FIXME Do we rollback and raise an error or just skip it?
            # FIXME See status code 207 partial success
            warn "Item not added to train: " . $_;
        };
    }
    return Koha::Preservation::Train::Items->search( { train_item_id => [ map { $_->train_item_id } @added_items ] } );
}

=head3 items

my $items = $train->items;

Return the items in this train.

=cut

sub items {
    my ($self) = @_;
    my $items_rs = $self->_result->preservation_trains_items;
    return Koha::Preservation::Train::Items->_new_from_dbic($items_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'PreservationTrain';
}

1;
