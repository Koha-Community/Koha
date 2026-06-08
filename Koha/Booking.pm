package Koha::Booking;

# Copyright PTFS Europe 2021
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

use Koha::Exceptions::Booking;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Patrons;
use Koha::Libraries;

use C4::Letters;

use List::Util qw(any);

use base qw(Koha::Object);

=head1 NAME

Koha::Booking - Koha Booking object class

=head1 API

=head2 Class methods

=head3 set_itemtype_filter

    $booking->set_itemtype_filter($itemtype_id);

Sets a transient itemtype filter for item selection. This is used when
creating "any item" bookings to filter items by type before optimal selection.
This value is not persisted to the database.

=cut

sub set_itemtype_filter {
    my ( $self, $itemtype_id ) = @_;
    $self->{_itemtype_filter} = $itemtype_id;
    return $self;
}

=head3 biblio

Returns the related Koha::Biblio object for this booking

=cut

sub biblio {
    my ($self) = @_;

    my $biblio_rs = $self->_result->biblio;
    return Koha::Biblio->_new_from_dbic($biblio_rs);
}

=head3 patron

Returns the related Koha::Patron object for this booking

=cut

sub patron {
    my ($self) = @_;

    my $patron_rs = $self->_result->patron;
    return Koha::Patron->_new_from_dbic($patron_rs);
}

=head3 pickup_library

Returns the related Koha::Library object for this booking

=cut

sub pickup_library {
    my ($self) = @_;

    my $pickup_library_rs = $self->_result->pickup_library;
    return Koha::Library->_new_from_dbic($pickup_library_rs);
}

=head3 item

Returns the related Koha::Item object for this Booking

=cut

sub item {
    my ($self) = @_;

    my $item_rs = $self->_result->item;
    return unless $item_rs;
    return Koha::Item->_new_from_dbic($item_rs);
}

=head3 checkout

Returns the related Koha::Checkout object for this booking, if any

=cut

sub checkout {
    my ($self) = @_;

    my $checkout_rs = $self->_result->issues->first;
    return unless $checkout_rs;
    return Koha::Checkout->_new_from_dbic($checkout_rs);
}

=head3 old_checkout

Returns the related Koha::Old::Checkout object for this booking, if any

=cut

sub old_checkout {
    my ($self) = @_;

    my $old_checkout_rs = $self->_result->old_issues->first;
    return unless $old_checkout_rs;
    return Koha::Old::Checkout->_new_from_dbic($old_checkout_rs);
}

=head3 store

Booking specific store method to catch booking clashes and ensure we have an item assigned

We assume that if an item is passed, it's bookability has already been checked. This is to allow
overrides in the future.

=cut

sub store {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            if ( $self->item_id ) {
                Koha::Exceptions::Object::FKConstraint->throw(
                    broken_fk => 'item_id',
                    value     => $self->item_id,
                ) unless ( $self->item );

                $self->biblio_id( $self->item->biblionumber )
                    unless $self->biblio_id;

                Koha::Exceptions::Object::FKConstraint->throw(
                    broken_fk => 'item/biblio_id',
                    value     => "item biblionumber: "
                        . $self->item->biblionumber
                        . " booking biblio_id: "
                        . $self->biblio_id
                ) unless ( $self->biblio_id == $self->item->biblionumber );
            }

            Koha::Exceptions::Object::FKConstraint->throw(
                broken_fk => 'biblio_id',
                value     => $self->biblio_id,
            ) unless ( $self->biblio );

            # Skip clash detection when transitioning to a final/terminal
            # status (cancelled or completed); the checks are irrelevant
            # at those points and can produce false positives.
            unless ( $self->_is_final_status_transition ) {

                # Throw exception for item level booking clash
                Koha::Exceptions::Booking::Clash->throw()
                    if $self->item_id && !$self->item->check_booking(
                    {
                        start_date => $self->start_date,
                        end_date   => $self->end_date,
                        booking_id => $self->in_storage ? $self->booking_id : undef
                    }
                    );

                # Throw exception for biblio level booking clash
                Koha::Exceptions::Booking::Clash->throw()
                    if !$self->biblio->check_booking(
                    {
                        start_date => $self->start_date,
                        end_date   => $self->end_date,
                        booking_id => $self->in_storage ? $self->booking_id : undef
                    }
                    );
            }

            # FIXME: We should be able to combine the above two functions into one

            # Assign item at booking time
            if ( !$self->item_id ) {
                $self->_assign_item_for_booking;
            }

            if ( !$self->in_storage ) {
                $self->SUPER::store;
                $self->discard_changes;
                $self->_send_notice( { notice => 'BOOKING_CONFIRMATION' } );
            } else {
                my %updated_columns = $self->_result->get_dirty_columns;
                return $self->SUPER::store unless %updated_columns;

                my $old_booking = $self->get_from_storage;
                $self->SUPER::store;

                if ( exists( $updated_columns{status} ) && $updated_columns{status} eq 'cancelled' ) {
                    $self->_send_notice(
                        { notice => 'BOOKING_CANCELLATION', objects => { old_booking => $old_booking } } );
                } elsif ( exists( $updated_columns{pickup_library_id} )
                    or exists( $updated_columns{start_date} )
                    or exists( $updated_columns{end_date} ) )
                {
                    $self->_send_notice(
                        { notice => 'BOOKING_MODIFICATION', objects => { old_booking => $old_booking } } );
                }
            }
        }
    );

    return $self;
}

=head3 _assign_item_for_booking

  $self->_assign_item_for_booking;

Used internally in Koha::Booking->store to ensure we have an item assigned for the booking.

=cut

sub _assign_item_for_booking {
    my ($self) = @_;

    my $biblio = $self->biblio;

    my $start_date = dt_from_string( $self->start_date );
    my $end_date   = dt_from_string( $self->end_date );

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    my $existing_bookings = $biblio->bookings(
        {
            '-and' => [
                {
                    '-or' => [
                        start_date => {
                            '-between' => [
                                $dtf->format_datetime($start_date),
                                $dtf->format_datetime($end_date)
                            ]
                        },
                        end_date => {
                            '-between' => [
                                $dtf->format_datetime($start_date),
                                $dtf->format_datetime($end_date)
                            ]
                        },
                        {
                            start_date => { '<' => $dtf->format_datetime($start_date) },
                            end_date   => { '>' => $dtf->format_datetime($end_date) }
                        }
                    ]
                },
                { status => { '-not_in' => [ 'cancelled', 'completed' ] } }
            ]
        }
    );

    my $checkouts =
        $biblio->current_checkouts->search( { date_due => { '>=' => $dtf->format_datetime($start_date) } } );

    # Build search conditions for bookable items
    my $item_search_conditions = {
        itemnumber => [
            '-and' => { '-not_in' => $existing_bookings->_resultset->get_column('item_id')->as_query },
            { '-not_in' => $checkouts->_resultset->get_column('itemnumber')->as_query }
        ]
    };

    # Filter by itemtype if specified (for "any item" bookings)
    if ( $self->{_itemtype_filter} ) {
        $item_search_conditions->{itype} = $self->{_itemtype_filter};
    }

    my $bookable_items = $biblio->bookable_items->search($item_search_conditions);

    # Use optimal selection instead of random selection
    my $optimal_item = $self->_select_optimal_item($bookable_items);

    Koha::Exceptions::Booking::Clash->throw("No available items found for booking")
        unless $optimal_item;

    my $itemnumber = $optimal_item->itemnumber;
    return $self->item_id($itemnumber);
}

=head3 get_items_that_can_fill

    my $items = $bookings->get_items_that_can_fill();

Return the list of items that can fulfill this booking.

Items that are not:

  in transit
  lost
  withdrawn
  not for loan
  not already booked

=cut

sub get_items_that_can_fill {
    my ($self) = @_;
    return;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Booking object
on the API.

=cut

sub to_api_mapping {
    return {};
}

=head2 Internal methods

=head3 _is_final_status_transition

    my $bool = $self->_is_final_status_transition;

Returns true when the booking is being transitioned to a terminal status where
clash detection is no longer meaningful: C<cancelled> or C<completed>.

=cut

sub _is_final_status_transition {
    my ($self) = @_;

    return 0 unless $self->in_storage;

    my $updated_columns = { $self->_result->get_dirty_columns };
    my $new_status      = $updated_columns->{status};

    return 0 unless $new_status;
    return 1 if any { $_ eq $new_status } qw( cancelled completed );
    return 0;
}

=head3 _select_optimal_item

    my $item_id = $self->_select_optimal_item($available_items);

Selects the optimal item from a set of available items by choosing the item
with the longest future availability after the booking ends.

This maximizes future booking opportunities by preserving items with shorter
future availability for bookings that specifically need them.

=cut

sub _select_optimal_item {
    my ( $self, $available_items ) = @_;

    return unless $available_items && $available_items->count > 0;

    # If only one item available, return it immediately
    return $available_items->next if $available_items->count == 1;

    my $check_date = dt_from_string( $self->end_date )->add( days => 1 );
    my $dtf        = Koha::Database->new->schema->storage->datetime_parser;

    # Get item IDs from the available items
    my @item_ids = map { $_->itemnumber } $available_items->as_list;

    # Find the item with the latest (furthest in future) next booking start date
    # Items with no future bookings will have NULL and sort first (most desirable)
    my $search_conditions = {
        item_id    => { '-in'     => \@item_ids },
        start_date => { '>='      => $dtf->format_datetime($check_date) },
        status     => { '-not_in' => [ 'cancelled', 'completed' ] }
    };

    # Exclude current booking if we're editing
    if ( $self->in_storage ) {
        $search_conditions->{booking_id} = { '!=' => $self->booking_id };
    }

    # Query to find the earliest future booking for each item
    my $rs = Koha::Bookings->search(
        $search_conditions,
        {
            select   => [ 'item_id', { min => 'start_date', -as => 'next_booking_start' } ],
            as       => [ 'item_id', 'next_booking_start' ],
            group_by => ['item_id'],
        }
    );

    # Get items that have future bookings, sorted by next booking date (desc = later is better)
    my %next_booking_by_item;
    while ( my $row = $rs->next ) {
        $next_booking_by_item{ $row->get_column('item_id') } = $row->get_column('next_booking_start');
    }

    # Find the best item: items without future bookings first, then by latest next booking
    my $best_item_id;
    my $latest_next_booking;

    foreach my $item_id (@item_ids) {
        my $next_booking = $next_booking_by_item{$item_id};

        # Items with no future bookings are best (infinite availability)
        if ( !defined $next_booking ) {
            $best_item_id = $item_id;
            last;
        }

        # Otherwise, prefer items with later (further in future) next bookings
        if ( !defined $latest_next_booking || $next_booking gt $latest_next_booking ) {
            $latest_next_booking = $next_booking;
            $best_item_id        = $item_id;
        }
    }

    # Return the optimal item
    return Koha::Items->find($best_item_id) if $best_item_id;

    # Fallback: shouldn't reach here, but return first available item
    $available_items->reset;
    return $available_items->next;
}

=head3 _send_notice

    $self->_send_notice();

Sends appropriate notice to patron.

=cut

sub _send_notice {
    my ( $self, $params ) = @_;

    my $notice  = $params->{notice};
    my $objects = $params->{objects} // {};
    $objects->{booking} = $self;

    my $branch = C4::Context->userenv->{'branch'};
    my $patron = $self->patron;

    my $letter = C4::Letters::GetPreparedLetter(
        module                 => 'bookings',
        letter_code            => $notice,
        message_transport_type => 'email',
        branchcode             => $branch,
        lang                   => $patron->lang,
        objects                => $objects
    );

    if ($letter) {
        C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $patron->borrowernumber,
                message_transport_type => 'email',
            }
        );
    }
}

=head3 _type

=cut

sub _type {
    return 'Booking';
}

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
