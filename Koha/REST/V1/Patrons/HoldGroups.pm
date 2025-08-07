package Koha::REST::V1::Patrons::HoldGroups;

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

use Koha::HoldGroup;
use Koha::Patrons;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons::HoldGroups

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::HoldGroup objects for the requested patron

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    return $c->render_resource_not_found("Patron")
        unless $patron;

    return try {
        my $hold_groups_set = $patron->hold_groups;

        my $hold_groups = $c->objects->search($hold_groups_set);
        return $c->render( status => 200, openapi => $hold_groups );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding Koha::HoldGroup objects for the requested patron

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    return $c->render_resource_not_found("Patron")
        unless $patron;

    my $body          = $c->req->json;
    my $hold_ids      = $body->{hold_ids};
    my $force_grouped = $body->{force_grouped} || 0;

    return try {
        my $hold_group = $patron->create_hold_group( $hold_ids, $force_grouped );
        $c->res->headers->location( $c->req->url->to_string . '/' . $hold_group->hold_group_id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($hold_group),
        );
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::HoldGroup::HoldDoesNotExist') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => $_->description . ": " . join( ', ', @{ $_->hold_ids } ),
                        error_code => 'HoldDoesNotExist',
                        hold_ids   => $_->hold_ids
                    }
                );
            } elsif ( $_->isa('Koha::Exceptions::HoldGroup::HoldDoesNotBelongToPatron') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => $_->description . ": " . join( ', ', @{ $_->hold_ids } ),
                        error_code => 'HoldDoesNotBelongToPatron',
                        hold_ids   => $_->hold_ids
                    }
                );
            } elsif ( $_->isa('Koha::Exceptions::HoldGroup::HoldHasAlreadyBeenFound') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => $_->description . ": " . join( ', ', @{ $_->barcodes } ),
                        error_code => 'HoldHasAlreadyBeenFound',
                        barcodes   => $_->barcodes
                    }
                );
            } elsif ( $_->isa('Koha::Exceptions::HoldGroup::HoldAlreadyBelongsToHoldGroup') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => $_->description . ": " . join( ', ', @{ $_->hold_ids } ),
                        error_code => 'HoldAlreadyBelongsToHoldGroup',
                        hold_ids   => $_->hold_ids
                    }
                );

            }
        }
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller method that handles removing a hold group.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    return $c->render_resource_not_found("Patron")
        unless $patron;

    return try {

        my $hold_group = $patron->hold_groups->find( $c->param('hold_group_id') );

        return $c->render_resource_not_found("Hold group")
            unless $hold_group;

        $hold_group->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
