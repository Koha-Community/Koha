package Koha::Util::StockRotation;

# Module contains subroutines used with Stock Rotation
#
# Copyright 2016 PTFS-Europe Ltd
#
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

use Koha::Items;
use Koha::StockRotationItems;
use Koha::Database;

our ( @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS );
BEGIN {
    require Exporter;
    @ISA = qw( Exporter );
    @EXPORT = qw( );
    @EXPORT_OK = qw(
        get_branches
        get_stages
        toggle_indemand
        remove_from_stage
        get_barcodes_status
        add_items_to_rota
        move_to_next_stage
    );
    %EXPORT_TAGS = ( ALL => [ @EXPORT_OK, @EXPORT ] );
}

=head1 NAME

Koha::Util::StockRotation - utility class with routines for Stock Rotation

=head1 FUNCTIONS

=head2 get_branches

    returns all branches ordered by branchname as an array, each element
    contains a hashref containing branch details

=cut

sub get_branches {

    return Koha::Libraries->search(
        {},
        { order_by => ['branchname'] }
    )->unblessed;

}

=head2 get_stages

    returns an arrayref of StockRotationStage objects representing
    all stages for a passed rota

=cut

sub get_stages {

    my $rota = shift;

    my @out = ();

    if ($rota->stockrotationstages->count > 0) {

        push @out, $rota->first_stage->unblessed;

        push @out, @{$rota->first_stage->siblings->unblessed};

    }

    return \@out;
}

=head2 toggle_indemand

    given an item's ID & stage ID toggle that item's in_demand
    status on that stage

=cut

sub toggle_indemand {

    my ($item_id, $stage_id) = @_;

    # Get the item object
    my $item = Koha::StockRotationItems->find(
        {
            itemnumber_id => $item_id,
            stage_id      => $stage_id
        }
    );

    # Toggle the item's indemand flag
    my $new_indemand = ($item->indemand == 1) ? 0 : 1;

    $item->indemand($new_indemand)->store;

}

=head2 move_to_next_stage

    given an item's ID and stage ID, move it
    to the next stage on the rota

=cut

sub move_to_next_stage {

    my ($item_id, $stage_id) = shift;

    # Get the item object
    my $item = Koha::StockRotationItems->find(
        {
            itemnumber_id => $item_id,
            stage_id      => $stage_id
        }
    );

    $item->advance;

}

=head2 remove_from_stage

    given an item's ID & stage ID, remove that item from that stage

=cut

sub remove_from_stage {

    my ($item_id, $stage_id) = @_;

    # Get the item object and delete it
    Koha::StockRotationItems->find(
        {
            itemnumber_id => $item_id,
            stage_id      => $stage_id
        }
    )->delete;

}

=head2 get_barcodes_status

    take an arrayref of barcodes and a status hashref and populate it

=cut

sub get_barcodes_status {

    my ($rota_id, $barcodes, $status) = @_;

    # Get the items associated with these barcodes
    my $items = Koha::Items->search(
        {
            barcode => { '-in' => $barcodes }
        },
        {
            prefetch => 'stockrotationitem'
        }
    );
    # Get an array of barcodes that were found
    # Assign each barcode's status
    my @found = ();
    while (my $item = $items->next) {

        push @found, $item->barcode if $item->barcode;

        # Check if it's on a rota
        my $on_rota = $item->stockrotationitem;

        # It is on a rota
        if ($on_rota) {

            # Check if it's on this rota
            if ($on_rota->stage->rota->rota_id == $rota_id) {

                # It's on this rota
                push @{$status->{on_this}}, $item;

            } else {

                # It's on another rota
                push @{$status->{on_other}}, $item;

            }

        } else {

            # Item is not on a rota
            push @{$status->{ok}}, $item;

        }

    }

    # Create an array of barcodes supplied in the file that
    # were not found in the catalogue
    my %found_in_cat = map{ $_ => 1 } @found;
    push @{$status->{not_found}}, grep(
        !defined $found_in_cat{$_}, @{$barcodes}
    );

}

=head2 add_items_to_rota

    take an arrayref of Koha::Item objects and add them to the passed rota

=cut

sub add_items_to_rota {

    my ($rota_id, $items) = @_;

    foreach my $item(@{$items}) {

        $item->add_to_rota($rota_id);

    }

}

1;

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut
