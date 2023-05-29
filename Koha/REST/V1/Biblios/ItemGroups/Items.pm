package Koha::REST::V1::Biblios::ItemGroups::Items;

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

use Koha::Biblio::ItemGroup::Items;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Biblios::ItemGroups::Items - Koha REST API for handling item group items (V1)

=head1 API

=head2 Methods

=head3 add

Controller function to handle linking an item to a Koha::Biblio::ItemGroup object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $item_group = Koha::Biblio::ItemGroups->find( $c->param('item_group_id') );

        unless ( $item_group ) {
            return $c->render(
                status  => 404,
                openapi => {
                    error => 'Item group not found'
                }
            );
        }

        unless ( $item_group->biblio_id eq $c->param('biblio_id') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error => 'Item group does not belong to passed biblio_id'
                }
            );
        }

        # All good, add the item
        my $body    = $c->req->json;
        my $item_id = $body->{item_id};

        $item_group->add_item({ item_id => $item_id });

        $c->res->headers->location( $c->req->url->to_string . '/' . $item_id );

        my $embed = $c->stash('koha.embed');

        return $c->render(
            status  => 201,
            openapi => $item_group->to_api({ embed => $embed })
        );
    }
    catch {
        if ( blessed($_) ) {

            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                if ( $_->broken_fk eq 'itemnumber' ) {
                    return $c->render(
                        status  => 409,
                        openapi => {
                            error => "Given item_id does not exist"
                        }
                    );
                }
                elsif ( $_->broken_fk eq 'biblio_id' ) {
                    return $c->render(
                        status  => 409,
                        openapi => {
                            error => "Given item_id does not belong to the item group's biblio"
                        }
                    );
                }
            }
            elsif ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {

                return $c->render(
                    status  => 409,
                    openapi => {
                        error => "The given item_id is already linked to the item group"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles unlinking an item from a Koha::Biblio::ItemGroup object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $item_group_id = $c->param('item_group_id');
    my $item_id       = $c->param('item_id');

    my $item_link = Koha::Biblio::ItemGroup::Items->find(
        {
            item_id       => $item_id,
            item_group_id => $item_group_id
        }
    );

    unless ( $item_link ) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'No such item group <-> item relationship'
            }
        );
    }

    return try {
        $item_link->delete;
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
