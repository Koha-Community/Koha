package Koha::REST::V1::Acquisitions::Orders;

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

use Koha::Acquisition::Orders;

use Clone qw( clone );
use JSON;
use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

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

        my $only_active = $c->param('only_active');
        my $order_id    = $c->param('order_id');

        $c->req->params->remove('only_active')->remove('order_id');

        my $orders_rs;

        if ( $only_active ) {
            $orders_rs = Koha::Acquisition::Orders->filter_by_active;
        }
        else {
            $orders_rs = Koha::Acquisition::Orders->new;
        }

        $orders_rs = $orders_rs->filter_by_id_including_transfers({ ordernumber => $order_id })
            if $order_id;

        my @query_fixers;

        # Look for embeds
        my $embed = $c->stash('koha.embed');
        if ( exists $embed->{biblio} ) { # asked to embed biblio
            my $fixed_embed = clone($embed);
            # Add biblioitems to prefetch
            # FIXME remove if we merge biblio + biblioitems
            $fixed_embed->{biblio}->{children}->{biblioitem} = {};
            $c->stash('koha.embed', $fixed_embed);
            push @query_fixers, (sub{ Koha::Biblios->new->api_query_fixer( $_[0], 'biblio', $_[1] ) });
        }

        return $c->render(
            status  => 200,
            openapi => $c->objects->search( $orders_rs, \@query_fixers ),
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Order object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    return try {
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api( $order ),
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Order object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $order = Koha::Acquisition::Order->new_from_api( $c->req->json );
        $order->store->discard_changes;

        $c->res->headers->location(
            $c->req->url->to_string . '/' . $order->ordernumber
        );

        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api( $order ),
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Order object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    return try {
        $order->set_from_api( $c->req->json );
        $order->store()->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api( $order ),
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->param('order_id') );

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
        $c->unhandled_exception($_);
    };
}

1;
