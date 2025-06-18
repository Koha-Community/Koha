package Koha::REST::V1::Preservation::WaitingList;

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

use Koha::Preservation::Train::Items;
use Koha::Items;
use Koha::Exceptions::Preservation;

use Scalar::Util qw( blessed );
use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing the items from the waiting list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $not_for_loan = C4::Context->preference('PreservationNotForLoanWaitingListIn');
        Koha::Exceptions::Preservation::MissingSettings->throw( parameter => 'PreservationNotForLoanWaitingListIn' )
            unless $not_for_loan;

        my $items_set = Koha::Items->new->search( { notforloan => $not_for_loan } );
        my $items     = $c->objects->search($items_set);
        return $c->render(
            status  => 200,
            openapi => $items
        );
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Preservation::MissingSettings') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "MissingSettings", parameter => $_->parameter }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 add_items

Controller function that handles adding items to the waiting list

=cut

sub add_items {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body             = $c->req->json;
        my $new_not_for_loan = C4::Context->preference('PreservationNotForLoanWaitingListIn');

        Koha::Exceptions::Preservation::MissingSettings->throw( parameter => 'PreservationNotForLoanWaitingListIn' )
            unless $new_not_for_loan;

        my @items;
        for my $item_id (@$body) {
            try {
                while ( my ( $k, $v ) = each %$item_id ) {

                    my $key  = $k eq 'item_id' ? 'itemnumber' : 'barcode';
                    my $item = Koha::Items->find( { $key => $v } );
                    next unless $item;    # FIXME Must return a multi-status response 207
                    if ( $item->notforloan != $new_not_for_loan ) {
                        my $already_in_train = Koha::Preservation::Train::Items->search(
                            {
                                item_id             => $item->itemnumber,
                                'train.received_on' => undef,
                            },
                            {
                                join => 'train',
                            }
                        )->count;
                        if ($already_in_train) {
                            Koha::Exceptions::Preservation::ItemAlreadyInTrain->throw;
                        }

                        $item->notforloan($new_not_for_loan)->store;
                        push @items, { item_id => $item->itemnumber };
                    }
                }
            } catch {
                warn $_;
            };
        }
        return $c->render( status => 201, openapi => \@items );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 remove_item

Controller function that handles removing an item from the waiting list

=cut

sub remove_item {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $item_id = $c->param('item_id');

        my $item = Koha::Items->find($item_id);

        return $c->render_resource_not_found("Item")
            unless $item;

        my $not_for_loan_waiting_list_in = C4::Context->preference('PreservationNotForLoanWaitingListIn');
        if ( $item->notforloan ne $not_for_loan_waiting_list_in ) {
            unless ($item) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Item not in waiting list found" }
                );
            }
        }

        $item->notforloan(0)->store;

        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
