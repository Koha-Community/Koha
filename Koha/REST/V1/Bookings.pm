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
        my $bookings = $c->objects->search( Koha::Bookings->filter_by_active );
        return $c->render( status => 200, openapi => $bookings );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single booking

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $booking = $c->objects->find( Koha::Bookings->new, $c->param('booking_id') );

        return $c->render_resource_not_found("Booking")
            unless $booking;

        return $c->render( status => 200, openapi => $booking );
    } catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller function that handles adding a new booking

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $booking = Koha::Booking->new_from_api( $c->req->json );
        $booking->store;
        $booking->discard_changes;
        $c->res->headers->location( $c->req->url->to_string . '/' . $booking->booking_id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($booking),
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Booking::Clash') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Booking would conflict" }
            );
        } elsif ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error => "Duplicate booking_id",
                }
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

    my $booking = $c->objects->find_rs( Koha::Bookings->new, $c->param('booking_id') );

    return $c->render_resource_not_found("Booking")
        unless $booking;

    return try {
        $booking->set_from_api( $c->req->json );
        $booking->store();
        $booking->discard_changes;
        return $c->render( status => 200, openapi => $c->objects->to_api($booking) );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles removing an existing booking

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $booking = Koha::Bookings->find( $c->param('booking_id') );

    return $c->render_resource_not_found("Booking")
        unless $booking;

    return try {
        $booking->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
