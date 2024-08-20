package Koha::REST::V1::Preservation::Trains;

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

use Koha::Preservation::Trains;
use Koha::Preservation::Train::Items;

use Scalar::Util qw( blessed );
use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing the items from a train

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $trains_set = Koha::Preservation::Trains->new;
        my $trains     = $c->objects->search($trains_set);
        return $c->render( status => 200, openapi => $trains );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Preservation::Train object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $train_id = $c->param('train_id');
        my $train    = $c->objects->find( Koha::Preservation::Trains->search, $train_id );

        return $c->render_resource_not_found("Train")
            unless $train;

        return $c->render(
            status  => 200,
            openapi => $train
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Preservation::Train object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $train = Koha::Preservation::Train->new_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/' . $train->train_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($train),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::Preservation::Train->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Preservation::Train object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                $train->set_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/' . $train->train_id );
                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($train),
                );
            }
        );
    } catch {
        my $to_api_mapping = Koha::Preservation::Train->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Preservation::Train object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $train = Koha::Preservation::Trains->find( $c->param('train_id') );

    return $c->render_resource_not_found("Train")
        unless $train;

    return try {
        $train->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_item

Controller function that handles getting an item from a train

=cut

sub get_item {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $train_item_id = $c->param('train_item_id');

    my $train_item = $c->objects->find(
        Koha::Preservation::Train::Items->search,
        { train_item_id => $train_item_id, train_id => $train_id }
    );

    return $c->render_resource_not_found("Item")
        unless $train_item;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                return $c->render( status => 200, openapi => $train_item );
            }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_items

Controller function that handles adding items in batch to a train

=cut

sub add_items {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $body = $c->req->json;
    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $train_items = $train->add_items($body);
                return $c->render( status => 201, openapi => $train_items );
            }
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

=head3 add_item

Controller function that handles adding a new item to a train

=cut

sub add_item {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $body = $c->req->json;
    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $attributes = delete $body->{attributes} // [];
                my $train_item = $train->add_item($body);
                $train_item->attributes($attributes);
                return $c->render( status => 201, openapi => $train_item );
            }
        );
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Preservation::MissingSettings') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "MissingSettings", parameter => $_->parameter }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemNotFound') ) {
                return $c->render_resource_not_found("Item");
            } elsif ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemNotInWaitingList') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => 'Item not in waiting list' }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemAlreadyInAnotherTrain') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => 'Item already in a non-received train', train_id => $_->train_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::CannotAddItemToClosedTrain') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => 'Cannot add item to a closed train' }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 copy_item

Controller function that handles copying an item from a train to an other

=cut

sub copy_item {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $train_item_id = $c->param('train_item_id');

    my $train_item =
        Koha::Preservation::Train::Items->search( { train_item_id => $train_item_id, train_id => $train_id } )->single;

    return $c->render_resource_not_found("Item")
        unless $train_item;

    my $body = $c->req->json;
    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $new_train_id = delete $body->{train_id};
                my $new_train    = Koha::Preservation::Trains->find($new_train_id);

                return $c->render_resource_not_found("Train")
                    unless $new_train;

                my $new_train_item = $new_train->add_item(
                    {
                        item_id       => $train_item->item_id,
                        processing_id => $train_item->processing_id
                    },
                    {
                        skip_waiting_list_check => 1,
                    },
                );
                my $attributes = [
                    map {
                        {
                            processing_attribute_id => $_->processing_attribute_id,
                            train_item_id           => $new_train_item->train_item_id,
                            value                   => $_->value
                        }
                    } $train_item->attributes->as_list
                ];
                $new_train_item->attributes($attributes);
                return $c->render( status => 201, openapi => $train_item );
            }
        );
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Preservation::MissingSettings') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "MissingSettings", parameter => $_->parameter }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemNotFound') ) {
                return $c->render_resource_not_found("Item");
            } elsif ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemNotInWaitingList') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => 'Item not in waiting list' }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::ItemAlreadyInAnotherTrain') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => 'Item already in a non-received train', train_id => $_->train_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Preservation::CannotAddItemToClosedTrain') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => 'Cannot add item to a closed train' }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update_item

Controller function that handles updating an item from a train

=cut

sub update_item {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $train_item_id = $c->param('train_item_id');

    my $train_item =
        Koha::Preservation::Train::Items->search( { train_item_id => $train_item_id, train_id => $train_id } )->single;

    return $c->render_resource_not_found("Item")
        unless $train_item;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $body       = $c->req->json;
                my $attributes = delete $body->{attributes} // [];

                $train_item->set_from_api($body)->store;
                $train_item->attributes($attributes);
                return $c->render( status => 200, openapi => $train_item );
            }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 remove_item

Controller function that handles removing an item from a train

=cut

sub remove_item {
    my $c = shift->openapi->valid_input or return;

    my $train_id = $c->param('train_id');
    my $train    = Koha::Preservation::Trains->find($train_id);

    return $c->render_resource_not_found("Train")
        unless $train;

    my $train_item_id = $c->param('train_item_id');

    my $train_item = $train->items->find($train_item_id);

    return $c->render_resource_not_found("Train item")
        unless $train_item;

    return try {
        $train_item->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
