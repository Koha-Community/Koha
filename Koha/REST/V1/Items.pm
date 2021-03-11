package Koha::REST::V1::Items;

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

use Koha::Items;

use List::MoreUtils qw(any);
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
        $c->unhandled_exception($_);
    };
}


=head3 get

Controller function that handles retrieving a single Koha::Item

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    try {
        my $item = Koha::Items->find($c->validation->param('item_id'));
        unless ( $item ) {
            return $c->render(
                status => 404,
                openapi => { error => 'Item not found'}
            );
        }
        return $c->render( status => 200, openapi => $item->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 pickup_locations

Method that returns the possible pickup_locations for a given item
used for building the dropdown selector

=cut

sub pickup_locations {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item = Koha::Items->find( $item_id );

    unless ($item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Item not found" }
        );
    }

    my $patron_id = delete $c->validation->output->{patron_id};
    my $patron    = Koha::Patrons->find( $patron_id );

    unless ($patron) {
        return $c->render(
            status  => 400,
            openapi => { error => "Patron not found" }
        );
    }

    return try {

        my $ps_set = $item->pickup_locations( { patron => $patron } );

        my $pickup_locations = $c->objects->search( $ps_set );
        my @response = ();

        if ( C4::Context->preference('AllowHoldPolicyOverride') ) {

            my $libraries_rs = Koha::Libraries->search( { pickup_location => 1 } );
            my $libraries    = $c->objects->search($libraries_rs);

            @response = map {
                my $library = $_;
                $library->{needs_override} = (
                    any { $_->{library_id} eq $library->{library_id} }
                    @{$pickup_locations}
                  )
                  ? Mojo::JSON->false
                  : Mojo::JSON->true;
                $library;
            } @{$libraries};

            return $c->render(
                status  => 200,
                openapi => \@response
            );
        }

        @response = map { $_->{needs_override} = Mojo::JSON->false; $_; } @{$pickup_locations};

        return $c->render(
            status  => 200,
            openapi => \@response
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
