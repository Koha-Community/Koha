package Koha::REST::V1::Acquisitions::Vendors;

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

use Koha::Acquisition::Booksellers;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Acquisitions::Vendors

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Acquisition::Bookseller objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $vendors_rs = Koha::Acquisition::Booksellers->new;
        my $vendors    = $c->objects->search( $vendors_rs );
        return $c->render(
            status  => 200,
            openapi => $vendors
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Bookseller

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Booksellers->find( $c->param('vendor_id') );
    unless ($vendor) {
        return $c->render(
            status  => 404,
            openapi => { error => "Vendor not found" }
        );
    }

    return try {
        return $c->render(
            status  => 200,
            openapi => $vendor->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Bookseller object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Bookseller->new_from_api( $c->req->json );

    return try {
        $vendor->store;
        $c->res->headers->location($c->req->url->to_string . '/' . $vendor->id );
        return $c->render(
            status  => 201,
            openapi => $vendor->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Bookseller object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $vendor;

    return try {
        $vendor = Koha::Acquisition::Booksellers->find( $c->param('vendor_id') );
        $vendor->set_from_api( $c->req->json );
        $vendor->store();
        return $c->render(
            status  => 200,
            openapi => $vendor->to_api
        );
    }
    catch {
        if ( not defined $vendor ) {
            return $c->render(
                status  => 404,
                openapi => { error => "Object not found" }
            );
        }

        $c->unhandled_exception($_);
    };

}

=head3 delete

Controller function that handles deleting a Koha::Acquisition::Bookseller object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $vendor = Koha::Acquisition::Booksellers->find( $c->param('vendor_id') );

        unless ( $vendor ) {
            return $c->render(
                status  => 404,
                openapi => { error => "Object not found" }
            );
        }

        $vendor->delete;

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
