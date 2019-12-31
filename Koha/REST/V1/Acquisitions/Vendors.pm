package Koha::REST::V1::Acquisitions::Vendors;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Acquisition::Booksellers;

use Try::Tiny;

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
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Bookseller

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
    unless ($vendor) {
        return $c->render( status  => 404,
                           openapi => { error => "Vendor not found" } );
    }

    return $c->render(
        status  => 200,
        openapi => $vendor->to_api
    );
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Bookseller object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Bookseller->new_from_api( $c->validation->param('body') );

    return try {
        $vendor->store;
        $c->res->headers->location($c->req->url->to_string . '/' . $vendor->id );
        return $c->render(
            status  => 201,
            openapi => $vendor->to_api
        );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->msg } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Bookseller object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $vendor;

    return try {
        $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
        $vendor->set_from_api( $c->validation->param('body') );
        $vendor->store();
        return $c->render(
            status  => 200,
            openapi => $vendor->to_api
        );
    }
    catch {
        if ( not defined $vendor ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('Koha::Exceptions::Object') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->message } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };

}

=head3 delete

Controller function that handles deleting a Koha::Acquisition::Bookseller object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $vendor;

    return try {
        $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
        $vendor->delete;
        return $c->render( status => 200,
                           openapi => q{} );
    }
    catch {
        if ( not defined $vendor ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->msg } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };

}

1;
