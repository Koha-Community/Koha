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

    my $bookable_items = $biblio->bookable_items->search(
        {
            itemnumber => [
                '-and' => { '-not_in' => $existing_bookings->_resultset->get_column('item_id')->as_query },
                { '-not_in' => $checkouts->_resultset->get_column('itemnumber')->as_query }
            ]
        },
        { order_by => \'RAND()', rows => 1 }
    );

    my $itemnumber = $bookable_items->single->itemnumber;
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
