package Koha::Bookings;

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

use Koha::Database;
use Koha::Booking;

use base qw(Koha::Objects);

=head1 NAME

Koha::Bookings - Koha Booking object set class

=head1 API

=head2 Class Methods

=head3 filter_by_active

    $bookings->filter_by_active;

Will return the bookings that have not ended, were cancelled or are completed.

=cut

sub filter_by_active {
    my ($self) = @_;
    return $self->search(
        {
            end_date => { '>='      => \'NOW()' },
            status   => { '-not_in' => [ 'cancelled', 'completed' ] }
        }
    );
}

=head2 Internal Methods

=head3 _type

=cut

sub _type {
    return 'Booking';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Booking';
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
