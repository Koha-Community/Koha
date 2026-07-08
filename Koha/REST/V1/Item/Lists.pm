package Koha::REST::V1::Item::Lists;

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

use C4::Circulation qw( barcodedecode );
use Koha::Exceptions::Item::List;
use Koha::Item::Lists;
use Koha::Item::ListContents;
use Koha::Item::ListShares;
use Koha::Items;
use Koha::Patrons;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Item::Lists

=head2 Methods

=head3 config

Returns the configuration options needed for the item lists Vue app

=cut

sub config {
    my $c = shift->openapi->valid_input or return;

    my $patron = $c->stash('koha.user');

    return $c->render(
        status  => 200,
        openapi => {
            borrowernumber => $patron->borrowernumber,
            permissions    => {
                'create_item_lists'         => $patron->has_permission( { item_lists => 'create_item_lists' } ) ? 1 : 0,
                'edit_item_lists'           => $patron->has_permission( { item_lists => 'edit_item_lists' } )   ? 1 : 0,
                'delete_item_lists'         => $patron->has_permission( { item_lists => 'delete_item_lists' } ) ? 1 : 0,
                'manage_item_list_contents' => $patron->has_permission( { item_lists => 'manage_item_list_contents' } )
                ? 1
                : 0,
                'items_batchmod' => $patron->has_permission( { tools     => 'items_batchmod' } ) ? 1 : 0,
                'items_batchdel' => $patron->has_permission( { tools     => 'items_batchdel' } ) ? 1 : 0,
                'list_borrowers' => $patron->has_permission( { borrowers => 'list_borrowers' } ) ? 1 : 0,
            },
        },
    );
}

=head3 list

Returns an array of item lists that the current user has the permission to view.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    return try {
        my $patron   = $c->stash('koha.user');
        my $lists_rs = Koha::Item::Lists->get_readable_lists($patron);
        my $lists    = $c->objects->search($lists_rs);
        return $c->render(
            status  => 200,
            openapi => $lists
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 create

Creates a new item list.

=cut

sub create {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patron = $c->stash('koha.user');

        my $body = $c->req->json;
        my $list = Koha::Item::List->new($body)->store();
        $list->discard_changes();

        $c->res->headers->location( $c->req->url->to_string . '/' . $list->id );
        return $c->render( status => 201, openapi => $c->objects->to_api($list) );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Item::List::DuplicateObject') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'An item list already exists with this name',
                    error_code => 'duplicate_name'
                }
            );
        }
        $c->unhandled_exception($_);
    };
}

=head3 update

Modifies and existing item list.

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $body   = $c->req->json;
        my $list   = Koha::Item::Lists->find( $c->param('item_list_id') );

        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to edit this item list." }
        ) unless $list->can_be_updated_by($patron);

        $list->update($body);
        $list->discard_changes();

        return $c->render( status => 200, openapi => $c->objects->to_api($list) );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Item::List::DuplicateObject') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'An item list already exists with this name',
                    error_code => 'duplicate_name'
                }
            );
        }
        $c->unhandled_exception($_);
    };
}

=head3 get

Retrieves information about an item list from its ID.

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $list   = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to view this item list." }
        ) unless $list->can_be_read_by($patron);

        return $c->render( status => 200, openapi => $c->objects->to_api($list) );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Deletes an existing item list.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $list   = Koha::Item::Lists->find( $c->param('item_list_id') );

        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to delete this item list." }
        ) unless $list->can_be_deleted_by($patron);

        $list->delete();

        return $c->render_resource_deleted();
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_items

Returns an array of items in an item list, supporting embeds, sorts, and filters.

=cut

sub list_items {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $list   = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to view this item list." }
        ) unless $list->can_be_read_by($patron);

        my $items = $c->objects->search( $list->items );

        return $c->render( status => 200, openapi => $items );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_items

Adds a set of items to an item list. The items may be defined by a mixture of itemnumbers and barcodes.

=cut

sub add_items {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $body   = $c->req->json;

        my $list = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to manage this item list." }
        ) unless $list->can_be_managed_by($patron);

        my $item_ids = $body->{item_ids}     // [];
        my $barcodes = $body->{external_ids} // [];
        my @barcodes = map { barcodedecode($_) } @{$barcodes};

        # TODO: can we do this in one query?
        my $items = Koha::Items->search(
            {
                '-or' => [
                    { itemnumber => { '-in' => $item_ids } },
                    { barcode    => { '-in' => \@barcodes } },
                ]
            }
        );

        # Find which of the input item_ids and barcodes were not matched to
        # an item.
        my @items = $items->as_list;
        my %unused_item_ids;
        my %unused_barcodes;
        $unused_item_ids{$_}++ for ( @{$item_ids} );
        $unused_barcodes{$_}++ for (@barcodes);

        foreach my $item (@items) {
            delete $unused_item_ids{ $item->itemnumber };
            delete $unused_barcodes{ $item->barcode };
        }

        if ( keys %unused_item_ids || keys %unused_barcodes ) {
            my @unused_item_ids = sort keys %unused_item_ids;
            my @unused_barcodes = sort keys %unused_barcodes;
            my @errors;
            push(
                @errors,
                { message => 'Unrecognised itemnumbers: ' . join( ', ', @unused_item_ids ), path => '/item_ids' }
            ) if @unused_item_ids;
            push(
                @errors,
                { message => 'Unrecognised barcodes: ' . join( ', ', @unused_barcodes ), path => '/external_ids' }
            ) if @unused_barcodes;
            return $c->render(
                status  => 404,
                openapi => {
                    errors => \@errors,
                }
            );
        }

        foreach my $item (@items) {
            $list->add_item( $item->itemnumber );
        }

        # No Read API call for individual items in list, point to the item index
        $c->res->headers->location( $c->req->url->to_string );
        return $c->render( status => 201, openapi => $c->objects->to_api($items) );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 remove_items

Removes items from an item list, defined by their itemnumbers.

=cut

sub remove_items {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $body   = $c->req->json;

        my $list = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to manage this item list." }
        ) unless $list->can_be_managed_by($patron);

        my $itemnumbers = $body->{item_ids} // [];

        $list->remove_items($itemnumbers);

        return $c->render_resource_deleted();
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_shares

Returns an array of shares associated with an item list.

=cut

sub list_shares {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $list   = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to edit this item list." }
        ) unless $list->can_be_updated_by($patron);

        my $items = $c->objects->search( $list->item_list_shares );

        return $c->render( status => 200, openapi => $items );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_share

Adds or updates a share permission associated with an item list.

=cut

sub add_share {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');
        my $body   = $c->req->json;

        my $list = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to edit this item list." }
        ) unless $list->can_be_updated_by($patron);

        my $sharee = Koha::Patrons->find( $body->{patron_id} );
        return $c->render_resource_not_found("Patron")
            unless $sharee;

        return $c->render(
            status  => 409,
            openapi => {
                error      => 'Sharee is the list owner',
                error_code => 'sharee_owner'
            }
        ) if $sharee->borrowernumber eq $list->owner;

        $list->share(
            {
                borrowernumber => $sharee->borrowernumber,
                permission     => $body->{permission},
            }
        );

        return $c->render( status => 200, openapi => {} );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 remove_share

Removes a share from an item list.

=cut

sub remove_share {
    my $c = shift->openapi->valid_input or return;

    try {
        my $patron = $c->stash('koha.user');

        my $list = Koha::Item::Lists->find( $c->param('item_list_id') );
        return $c->render_resource_not_found("ItemList")
            unless $list;

        return $c->render(
            status  => 403,
            openapi => { error => "You do not have permission to edit this item list." }
        ) unless $list->can_be_updated_by($patron);

        my $sharee = Koha::Patrons->find( $c->param('patron_id') );
        return $c->render_resource_not_found("Patron")
            unless $sharee;

        $list->remove_share( $sharee->borrowernumber );

        return $c->render_resource_deleted();
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
