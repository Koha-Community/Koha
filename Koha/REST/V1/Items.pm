package Koha::REST::V1::Items;

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

use Koha::Items;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Items - Koha REST API for handling items (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Controller function that handles listing Koha::Item objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $items_set = Koha::Items->new;
        my $items     = $c->objects->search( $items_set );
        return $c->render(
            status  => 200,
            openapi => $items
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
        return $c->render(
            status  => 500,
            openapi => { error => "$_" }
        );
    };
}


=head3 get

Controller function that handles retrieving a single Koha::Item

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $item;
    try {
        $item = Koha::Items->find($c->validation->param('item_id'));
        return $c->render( status => 200, openapi => $item->to_api );
    }
    catch {
        unless ( defined $item ) {
            return $c->render( status => 404,
                               openapi => { error => 'Item not found'} );
        }
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

1;
