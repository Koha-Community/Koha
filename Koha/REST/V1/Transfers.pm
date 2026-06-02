package Koha::REST::V1::Transfers;

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

use Mojo::Base 'Mojolicious::Controller';

use C4::Context;
use Koha::Item::Transfers;
use Koha::Recalls;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Controller function that handles retrieving a list of item transfers

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $transfers = $c->objects->search( Koha::Item::Transfers->new );
        return $c->render( status => 200, openapi => $transfers );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles cancelling an item transfer

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $transfer = Koha::Item::Transfers->find( $c->param('transfer_id') );

    return $c->render_resource_not_found("Transfer")
        unless $transfer;

    return try {
        my $body = $c->req->json;

        $transfer->cancel( { reason => $body->{cancellation_reason}, force => 1 } );

        # Revert an in transit recall tied to this item, as returns.pl does
        if ( C4::Context->preference('UseRecalls') ) {
            my $recall = Koha::Recalls->find( { item_id => $transfer->itemnumber, status => 'in_transit' } );
            $recall->revert_transfer if $recall;
        }

        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
