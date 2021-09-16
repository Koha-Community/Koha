package Koha::REST::V1::Bookings;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Bookings;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Controller function that handles retrieving a list of bookings

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $bookings_set = Koha::Bookings->new;
        my $bookings     = $c->objects->search($bookings_set);
        return $c->render( status => 200, openapi => $bookings );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single booking

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $booking =
          Koha::Bookings->find( $c->validation->param('booking_id') );
        unless ($booking) {
            return $c->render(
                status  => 404,
                openapi => { error => "Booking not found" }
            );
        }

        return $c->render( status => 200, openapi => $booking->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller function that handles adding a new booking

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $booking =
          Koha::Booking->new_from_api( $c->validation->param('body') );
        $booking->store;
        $c->res->headers->location(
            $c->req->url->to_string . '/' . $booking->booking_id );
        return $c->render(
            status  => 201,
            openapi => $booking->to_api
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Booking::Clash') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Booking would conflict" }
            );
        }

        return $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating an existing booking

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $booking = Koha::Bookings->find( $c->validation->param('booking_id') );

    if ( not defined $booking ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        $booking->set_from_api( $c->validation->param('body') );
        $booking->store();
        return $c->render( status => 200, openapi => $booking->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles removing an existing booking

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $booking = Koha::Bookings->find( $c->validation->param('booking_id') );
    if ( not defined $booking ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        $booking->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
