package Koha::REST::V1::Biblios::ItemGroups;

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

use Koha::Biblio::ItemGroups;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Biblios::ItemGroups - Koha REST API for handling item groups (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Controller function that handles listing Koha::Biblio::ItemGroup objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    my $biblio_id = $c->validation->param('biblio_id');

    my $biblio=Koha::Biblios->find( $biblio_id);

    return try {
#my $item_groups_set = Koha::Biblio::ItemGroups->new;
        my $item_groups_set = $biblio->item_groups;
        my $item_groups     = $c->objects->search( $item_groups_set );
        return $c->render(
            status  => 200,
            openapi => $item_groups
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Biblio::ItemGroup

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    try {
        my $item_group_id = $c->validation->param('item_group_id');
        my $biblio_id = $c->validation->param('biblio_id');

        my $item_group = $c->objects->find( Koha::Biblio::ItemGroups->new, $item_group_id );

        if ( $item_group && $item_group->{biblio_id} eq $biblio_id ) {
            return $c->render(
                status  => 200,
                openapi => $item_group
            );
        }
        else {
            return $c->render(
                status  => 404,
                openapi => {
                    error => 'Item group not found'
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function to handle adding a Koha::Biblio::ItemGroup object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $biblio = Koha::Biblios->find( $c->param('biblio_id') );
        return $c->render(
            status  => 404,
            openapi => { error => 'Object not found' }
        ) unless $biblio;

        my $item_group_data = $c->req->json;
        # biblio_id comes from the path
        $item_group_data->{biblio_id} = $biblio->id;

        my $item_group = Koha::Biblio::ItemGroup->new_from_api($item_group_data);
        $item_group->store->discard_changes();

        $c->res->headers->location( $c->req->url->to_string . '/' . $item_group->id );

        return $c->render(
            status  => 201,
            openapi => $item_group->to_api
        );
    }
    catch {
        if ( blessed($_) ) {
            my $to_api_mapping = Koha::Biblio::ItemGroup->new->to_api_mapping;

            if (    $_->isa('Koha::Exceptions::Object::FKConstraint')
                and $_->broken_fk eq 'biblio_id' )
            {
                return $c->render(
                    status  => 404,
                    openapi => { error => "Biblio not found" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function to handle updating a Koha::Biblio::ItemGroup object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $item_group_id = $c->validation->param('item_group_id');
        my $biblio_id     = $c->validation->param('biblio_id');

        my $item_group = Koha::Biblio::ItemGroups->find( $item_group_id );

        unless ( $item_group && $item_group->biblio_id eq $biblio_id ) {
            return $c->render(
                status  => 404,
                openapi => {
                    error => 'Item group not found'
                }
            );
        }

        my $item_group_data = $c->validation->param('body');
        $item_group->set_from_api( $item_group_data )->store->discard_changes();

        return $c->render(
            status  => 200,
            openapi => $item_group->to_api
        );
    }
    catch {
        if ( blessed($_) ) {
            my $to_api_mapping = Koha::Biblio::ItemGroup->new->to_api_mapping;

            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Biblio::ItemGroup object

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $item_group_id = $c->validation->param('item_group_id');
    my $biblio_id     = $c->validation->param('biblio_id');

    my $item_group = Koha::Biblio::ItemGroups->find(
        { item_group_id => $item_group_id, biblio_id => $biblio_id } );

    if ( not defined $item_group ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Item group not found" }
        );
    }

    return try {
        $item_group->delete;
        return $c->render( status => 204, openapi => '' );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
