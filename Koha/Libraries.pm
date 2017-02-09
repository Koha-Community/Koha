package Koha::Libraries;

# Copyright 2015 Koha Development team
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

use Carp;

use C4::Context;

use Koha::Biblios;
use Koha::Database;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Library;

use base qw(Koha::Objects);

=head1 NAME

Koha::Libraries - Koha Library Object set class

=head1 API

=head2 Class Methods

=cut

=head3 pickup_locations

Returns available pickup locations for
    A. a specific item
    B. a biblio
    C. none of the above, simply all libraries with pickup_location => 1

This method determines the pickup location by two factors:
    1. is the library configured as pickup location
    2. can a specific item / at least one of the items of a biblio be transferred
       into the library

OPTIONAL PARAMETERS:
    item   # Koha::Item object / itemnumber, find pickup locations for item
    biblio # Koha::Biblio object / biblionumber, find pickup locations for biblio

If no parameters are given, all libraries with pickup_location => 1 are returned.

=cut

sub pickup_locations {
    my ($self, $params) = @_;

    my $item = $params->{'item'};
    my $biblio = $params->{'biblio'};
    if ($biblio && $item) {
        Koha::Exceptions::BadParameter->throw(
            error => "Koha::Libraries->pickup_locations takes either 'biblio' or "
            ." 'item' as parameter, but not both."
        );
    }

    # Select libraries that are configured as pickup locations
    my $libraries = $self->search({
        pickup_location => 1
    }, {
        order_by => ['branchname']
    });

    return $libraries->unblessed unless $item or $biblio;
    return $libraries->unblessed
        unless C4::Context->preference('UseBranchTransferLimits');
    my $limittype = C4::Context->preference('BranchTransferLimitsType');

    my $items;
    if ($item) {
        unless (ref($item) eq 'Koha::Item') {
            $item = Koha::Items->find($item);
            return $libraries->unblessed unless $item;
        }
    } else {
        unless (ref($biblio) eq 'Koha::Biblio') {
            $biblio = Koha::Biblios->find($biblio);
            return $libraries->unblessed unless $biblio;
        }
    }

    my @pickup_locations;
    foreach my $library ($libraries->as_list) {
        if ($item && $item->can_be_transferred({ to => $library })) {
            push @pickup_locations, $library->unblessed;
        } elsif ($biblio && $biblio->can_be_transferred({ to => $library })) {
            push @pickup_locations, $library->unblessed;
        }
    }

    return wantarray ? @pickup_locations : \@pickup_locations;
}

=head3 search_filtered

=cut

sub search_filtered {
    my ( $self, $params, $attributes ) = @_;

    my @branchcodes;
    my $userenv = C4::Context->userenv;
    if ( $userenv and $userenv->{number} ) {
        my $only_from_group = $params->{only_from_group};
        if ( $only_from_group ) {
            my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
            my @branchcodes = $logged_in_user->libraries_where_can_see_patrons;
            $params->{branchcode} = { -in => \@branchcodes } if @branchcodes;
        } else {
            if ( C4::Context::only_my_library ) {
                $params->{branchcode} = C4::Context->userenv->{branch};
            }
        }
    }
    delete $params->{only_from_group};
    return $self->SUPER::search( $params, $attributes );
}

=head3 type

=cut

sub _type {
    return 'Branch';
}

sub object_class {
    return 'Koha::Library';
}

1;
