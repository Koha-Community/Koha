package Koha::CurbsidePickupPolicy;

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
use Koha::Library;
use Koha::CurbsidePickupOpeningSlots;

use Koha::Result::Boolean;
use Koha::Exceptions::CurbsidePickup;

use base qw(Koha::Object);

=head1 NAME

Koha::CurbsidePickupPolicy - Koha Curbside Pickup Policy Object class

=head1 API

=head2 Class methods

=head3 library

Return the branch associated with this policy

=cut

sub library {
    my ( $self ) = @_;
    my $rs = $self->_result->branchcode;
    return unless $rs;
    return Koha::Library->_new_from_dbic( $rs );
}

=head3 opening_slots

$policy->opening_slots

Return the list of opening slots (Koha::CurbsidePickupOpeningSlots object)

=cut

sub opening_slots {
    my ( $self ) = @_;
    my $rs = $self->_result->curbside_pickup_opening_slots;
    return unless $rs;
    return Koha::CurbsidePickupOpeningSlots->_new_from_dbic( $rs );
}

=head3 add_opening_slot

$policy->add("$d-12:00-15:00");

Add a new opening slot for this library. It must be formatted "day:start:end" with 'start' and 'end' in 24-hour format.

=cut

sub add_opening_slot {
    my ( $self, $slot ) = @_;

    my ( $day, $start, $end ) = split '-', $slot;
    my ( $start_hour, $start_minute ) = split ':', $start;
    my ( $end_hour,   $end_minute )   = split ':', $end;

    return Koha::CurbsidePickupOpeningSlot->new(
        {
            curbside_pickup_policy_id => $self->id,
            day                       => $day,
            start_hour                => $start_hour,
            start_minute              => $start_minute,
            end_hour                  => $end_hour,
            end_minute                => $end_minute,
        }
    )->store;
}

=head3 is_valid_pickup_datetime

=cut

sub is_valid_pickup_datetime {
    my ( $self, $datetime ) = @_;

    my $opening_slots =
      $self->opening_slots->search( { day => $datetime->dow % 7 } );
    my $matching_slot;
    while ( my $opening_slot = $opening_slots->next ) {
        my $start = $datetime->clone->set_hour( $opening_slot->start_hour )
          ->set_minute( $opening_slot->start_minute );
        my $end = $datetime->clone->set_hour( $opening_slot->end_hour )
          ->set_minute( $opening_slot->end_minute );
        my $keep_going = 1;
        my $slot_start = $start->clone;
        my $slot_end = $slot_start->clone->add(minutes => $self->pickup_interval);
        while ($slot_end <= $end) {
            if ( $slot_start == $datetime ) {
                $matching_slot = $slot_start;
                last;
            }
            $slot_start->add( minutes => $self->pickup_interval);
            $slot_end->add( minutes => $self->pickup_interval);
        }
    }

    return Koha::Result::Boolean->new(0)
      ->add_message( { message => 'no_matching_slots' } )
      unless $matching_slot;

    my $dtf  = Koha::Database->new->schema->storage->datetime_parser;
    # Check too many users for this slot
    my $existing_pickups = Koha::CurbsidePickups->search(
        {
            branchcode                => $self->branchcode,
            scheduled_pickup_datetime => $dtf->format_datetime($matching_slot),
        }
    );

    return Koha::Result::Boolean->new(0)
      ->add_message( { message => 'no_more_available' } )
      if $existing_pickups->count >= $self->patrons_per_interval;

    return 1;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CurbsidePickupPolicy';
}

1;
