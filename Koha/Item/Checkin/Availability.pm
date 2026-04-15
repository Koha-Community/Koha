package Koha::Item::Checkin::Availability;

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
use Koha::Availability::Result;

=head1 NAME

Koha::Item::Checkin::Availability - Check-in availability validation for items

=head1 SYNOPSIS

    my $availability = Koha::Item::Checkin::Availability->check( $item,
        {
            library    => $branchcode,
            to_library => $destination_branchcode,
        }
    );

    # Or via instance method
    my $availability = $item->checkin_availability(
        {
            library    => $branchcode,
            to_library => $destination_branchcode,
        }
    );

    # Collect all blockers (e.g. for API responses)
    my $availability = $item->checkin_availability(
        {
            library          => $branchcode,
            to_library       => $destination_branchcode,
            no_short_circuit => 1,
        }
    );

=head1 DESCRIPTION

This class provides validation logic for item check-in operations, extracting
and centralizing checks from C4::Circulation::AddReturn.

The result categorizes conditions as:
- blockers: Prevent check-in (e.g., BlockReturnOfWithdrawnItems enabled)
- confirmations: Noteworthy conditions (e.g., item not checked out)
- warnings: Informational (e.g., item is withdrawn but check-in allowed)

=head1 API

=head2 Class methods

=head3 check

    my $availability = Koha::Item::Checkin::Availability->check( $item,
        {
            library          => $branchcode,
            to_library       => $destination_branchcode,
            no_short_circuit => 1,
        }
    );

Validates check-in availability for an item.

Parameters:
    $item   - Koha::Item object (required)
    $params - hashref with:
        library          => branchcode where the return takes place (required)
        to_library       => branchcode where the item should be sent after return
                            (optional, for transfer limit validation)
        no_short_circuit => boolean, if true all checks are performed and all
                            blockers collected. Default: false (short-circuit
                            on first blocker). This follows the same pattern
                            as Koha::Patron->can_place_holds.

Returns a Koha::Availability::Result object with:
    blockers      => {}       # Conditions that prevent check-in
    confirmations => {}       # Conditions requiring confirmation
    warnings      => {}       # Informational messages
    context       => {
        checkout => $checkout # Koha::Checkout object if checked out
        patron   => $patron   # Koha::Patron object if item is checked out
    }

=cut

sub check {
    my ( $class, $item, $params ) = @_;

    my $library          = $params->{library};
    my $to_library       = $params->{to_library};
    my $no_short_circuit = $params->{no_short_circuit} // 0;

    my $result = Koha::Availability::Result->new();

    # Always check checkout status first so context is available to callers
    # even when blockers prevent the check-in
    my $checkout = $item->checkout;
    if ($checkout) {
        $result->set_context( checkout => $checkout );
        $result->set_context( patron   => $checkout->patron );
    } else {

        # Item not checked out
        $result->add_confirmation( NotIssued => $item->barcode );
    }

    # Check if item is withdrawn
    if ( $item->withdrawn ) {
        if ( C4::Context->preference("BlockReturnOfWithdrawnItems") ) {
            $result->add_blocker( BlockedWithdrawn => 1 );
            return $result unless $no_short_circuit;
        } else {
            $result->add_warning( withdrawn => 1 );
        }
    }

    # Check AllowReturnToBranch policy and branch transfer limits
    my ( $returnallowed, $message ) =
        $item->can_be_returned_at( { library => $library, to_library => $to_library } );
    unless ($returnallowed) {
        $result->add_blocker(
            Wrongbranch => {
                Wrongbranch => $library,
                Rightbranch => $message
            }
        );
        return $result unless $no_short_circuit;
    }

    # Check if item is lost and blocked
    if ( $item->itemlost && C4::Context->preference("BlockReturnOfLostItems") ) {
        $result->add_blocker( BlockedLost => 1 );
    }

    return $result;
}

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut

1;
