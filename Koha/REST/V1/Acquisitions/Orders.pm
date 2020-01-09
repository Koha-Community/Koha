package Koha::REST::V1::Acquisitions::Orders;

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

use Koha::Acquisition::Orders;
use Koha::DateUtils;

use Scalar::Util qw( blessed );
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Acquisitions::Orders

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Acquisition::Order objects

=cut

sub list {

    my $c = shift->openapi->valid_input or return;

    return try {
        my $orders = $c->objects->search( Koha::Acquisition::Orders->new );

        return $c->render(
            status  => 200,
            openapi => $orders
        );
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Unhandled exception ($_)" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs. ($_)" }
            );
        }
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Order object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    my $embed = $c->stash('koha.embed');

    return $c->render(
        status  => 200,
        openapi => $order->to_api({ embed => $embed })
    );
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Order object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $order = Koha::Acquisition::Order->new_from_api( $c->validation->param('body') );
        $order->store->discard_changes;

        $c->res->headers->location(
            $c->req->url->to_string . '/' . $order->ordernumber
        );

        return $c->render(
            status  => 201,
            openapi => $order->to_api
        );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error =>
                      "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "$_" }
            );
        }
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Order object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    return try {
        $order->set_from_api( $c->validation->param('body') );
        $order->store()->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $order->to_api
        );
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Unhandled exception ($_)" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => 'Order not found' }
        );
    }

    return try {

        $order->delete;

        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Unhandled exception ($_)" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

1;
