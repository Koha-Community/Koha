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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Exceptions::Booking;
use Koha::DateUtils qw( dt_from_string );

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

Booking specific store method to catch booking clashes

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

                Koha::Exceptions::Object::FKConstraint->throw()
                  unless ( $self->biblio_id == $self->item->biblionumber );
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

            $self = $self->SUPER::store;
        }
    );

    return $self;
}

=head3 intersects

  my $intersects = $booking1->intersects($booking2);

Returns a boolean denoting whether booking1 interfers/overlaps/clashes with booking2.

=cut

sub intersects {
    my ( $self, $comp ) = @_;

    # Start date of comparison booking is after end date of this booking.
    return 0
      if (
        DateTime->compare(
            dt_from_string( $comp->start_date ),
            dt_from_string( $self->end_date )
        ) >= 0
      );

    # End date of comparison booking is before start date of this booking.
    return 0
      if (
        DateTime->compare(
            dt_from_string( $comp->end_date ),
            dt_from_string( $self->start_date )
        ) <= 0
      );

    # Bookings must overlap
    return 1;
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

=head3 _type

=cut

sub _type {
    return 'Booking';
}

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
