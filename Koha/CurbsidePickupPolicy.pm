package Koha::CurbsidePickupPolicy;

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
use Koha::Library;
use Koha::CurbsidePickupOpeningSlots;

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

sub opening_slots {
    my ( $self ) = @_;
    my $rs = $self->_result->curbside_pickup_opening_slots;
    return unless $rs;
    return Koha::CurbsidePickupOpeningSlots->_new_from_dbic( $rs );
}

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

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CurbsidePickupPolicy';
}

1;
