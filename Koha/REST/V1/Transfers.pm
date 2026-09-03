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

=head3 cancel

POST /transfers/{transfer_id}/cancellation

Controller function that handles cancelling an item transfer. The transfer is
cancelled with the reason passed in the request body (defaulting to C<Manual>),
and when recalls are in use any in-transit recall for the item has its transfer
reverted.

=cut

sub cancel {
    my $c = shift->openapi->valid_input or return;

    my $transfer = $c->objects->find_rs( Koha::Item::Transfers->new, $c->param('transfer_id') );

    return $c->render_resource_not_found("Transfer")
        unless $transfer;

    if ( $transfer->datearrived ) {
        return $c->render(
            status  => 409,
            openapi => {
                error      => "Transfer has already arrived",
                error_code => 'already_arrived',
            }
        );
    }

    if ( $transfer->datecancelled ) {
        return $c->render(
            status  => 409,
            openapi => {
                error      => "Transfer has already been cancelled",
                error_code => 'already_cancelled',
            }
        );
    }

    my $body   = $c->req->json                // {};
    my $reason = $body->{cancellation_reason} // 'Manual';

    return try {
        $transfer->cancel( { reason => $reason, force => 1 } );

        # If there's a recall in transit for this item, revert it.
        #
        # FIXME: This recall-revert-on-cancel trigger is duplicated with
        # Koha::Checkin->cancel_transfer. It really belongs one level down,
        # in Koha::Item::Transfer->cancel, so that *every* transfer
        # cancellation reverts an in-transit recall regardless of the caller.
        if ( C4::Context->preference('UseRecalls') ) {
            my $recall = Koha::Recalls->find( { item_id => $transfer->itemnumber, status => 'in_transit' } );
            $recall->revert_transfer if $recall;
        }

        $transfer->discard_changes;
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($transfer)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
