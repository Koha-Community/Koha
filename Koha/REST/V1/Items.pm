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

use C4::Circulation qw( barcodedecode );

use Koha::Items;

use List::MoreUtils qw( any );
use Try::Tiny qw( catch try );

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
        my $items_rs = Koha::Items->new;
        my $item = $c->objects->find($items_rs, $c->validation->param('item_id'));
        unless ( $item ) {
            return $c->render(
                status => 404,
                openapi => { error => 'Item not found'}
            );
        }
        return $c->render( status => 200, openapi => $item );
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

        my $pl_set = $item->pickup_locations( { patron => $patron } );

        my @response = ();
        if ( C4::Context->preference('AllowHoldPolicyOverride') ) {

            my $libraries_rs = Koha::Libraries->search( { pickup_location => 1 } );
            my $libraries    = $c->objects->search($libraries_rs);

            @response = map {
                my $library = $_;
                $library->{needs_override} = (
                    any { $_->branchcode eq $library->{library_id} }
                    @{ $pl_set->as_list }
                  )
                  ? Mojo::JSON->false
                  : Mojo::JSON->true;
                $library;
            } @{$libraries};
        }
        else {

            my $pickup_locations = $c->objects->search($pl_set);
            @response = map { $_->{needs_override} = Mojo::JSON->false; $_; } @{$pickup_locations};
        }

        return $c->render(
            status  => 200,
            openapi => \@response
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 bundled_items

Controller function that handles bundled_items Koha::Item objects

=cut

sub bundled_items {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item = Koha::Items->find( $item_id );

    unless ($item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Item not found" }
        );
    }

    return try {
        my $items_set = $item->bundle_items;
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

=head3 add_to_bundle

Controller function that handles adding items to this bundle

=cut

sub add_to_bundle {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item = Koha::Items->find( $item_id );

    unless ($item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Item not found" }
        );
    }

    my $bundle_item_id = $c->validation->param('body')->{'external_id'};
    $bundle_item_id = barcodedecode($bundle_item_id);
    my $bundle_item = Koha::Items->find( { barcode => $bundle_item_id } );

    unless ($bundle_item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Bundle item not found" }
        );
    }

    return try {
        my $force_checkin = $c->validation->param('body')->{'force_checkin'};
        my $link = $item->add_to_bundle($bundle_item, { force_checkin => $force_checkin });
        return $c->render(
            status  => 201,
            openapi => $bundle_item
        );
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::Object::DuplicateID' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Item is already bundled',
                    error_code => 'already_bundled',
                    key        => $_->duplicate_id
                }
            );
        }
        elsif ( ref($_) eq 'Koha::Exceptions::Item::Bundle::BundleIsCheckedOut' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Bundle is checked out',
                    error_code => 'bundle_checked_out'
                }
            );
        } elsif ( ref($_) eq 'Koha::Exceptions::Item::Bundle::ItemIsCheckedOut' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Item is checked out',
                    error_code => 'checked_out'
                }
            );
        }
        elsif ( ref($_) eq 'Koha::Exceptions::Checkin::FailedCheckin' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Item cannot be checked in',
                    error_code => 'failed_checkin'
                }
            );
        }
        elsif ( ref($_) eq 'Koha::Exceptions::Item::Bundle::IsBundle' ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => 'Bundles cannot be nested',
                    error_code => 'failed_nesting'
                }
            );
        }
        else {
            $c->unhandled_exception($_);
        }
    };
}

=head3 remove_from_bundle

Controller function that handles removing items from this bundle

=cut

sub remove_from_bundle {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item = Koha::Items->find( $item_id );

    unless ($item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Item not found" }
        );
    }

    my $bundle_item_id = $c->validation->param('bundled_item_id');
    $bundle_item_id = barcodedecode($bundle_item_id);
    my $bundle_item = Koha::Items->find( { itemnumber => $bundle_item_id } );

    unless ($bundle_item) {
        return $c->render(
            status  => 404,
            openapi => { error => "Bundle item not found" }
        );
    }

    return try {
        $bundle_item->remove_from_bundle;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::Item::Bundle::BundleIsCheckedOut' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Bundle is checked out',
                    error_code => 'bundle_checked_out'
                }
            );
        } else {
            $c->unhandled_exception($_);
        }
    };
}

1;
