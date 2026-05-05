package Koha::Policy::Circulation;

# Copyright 2026 Koha Development Team
#
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

use C4::Context;

=head1 NAME

Koha::Policy::Circulation - module to deal with circulation policy

=head1 API

=head2 Class methods

=head3 circ_control_library

    my $branchcode = Koha::Policy::Circulation->circ_control_library( $item, $patron );

    # With explicit pickup library (avoids userenv dependency)
    my $branchcode = Koha::Policy::Circulation->circ_control_library(
        $item, $patron, { pickup_library_id => $library_id }
    );

Given L<Koha::Item> and L<Koha::Patron> objects, returns the branchcode of
the library that controls circulation rules. Relies on the B<CircControl>
and B<HomeOrHoldingBranch> system preferences.

When C<CircControl> is C<PickupLibrary>, the method uses the
C<pickup_library_id> parameter if provided, otherwise falls back to
C<C4::Context-E<gt>userenv-E<gt>{branch}>.

=cut

sub circ_control_library {
    my ( $class, $item, $patron, $params ) = @_;

    my $circcontrol = C4::Context->preference('CircControl');

    if ( $circcontrol eq 'PickupLibrary' ) {
        return $params->{pickup_library_id}
            if $params->{pickup_library_id};
        my $userenv = C4::Context->userenv;
        return $userenv->{branch} if $userenv && $userenv->{branch};
    }

    if ( $circcontrol eq 'PatronLibrary' ) {
        return $patron->branchcode;
    }

    # ItemHomeLibrary (default)
    my $branchfield = C4::Context->preference('HomeOrHoldingBranch') || 'homebranch';
    my $branch      = $item->$branchfield;

    # Fall back to homebranch if holdingbranch is not set
    if ( !defined($branch) && $branchfield eq 'holdingbranch' ) {
        $branch = $item->homebranch;
    }

    return $branch;
}

1;
