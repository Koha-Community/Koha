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
            branch => $branch,
        }
    );

    # Or via instance method
    my $availability = $item->checkin_availability( { branch => $branch } );

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
            branch => $branch,
        }
    );

Validates check-in availability for an item.

Parameters:
    $item   - Koha::Item object (required)
    $params - hashref with:
        branch => $branchcode (required)

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

    my $branch = $params->{branch};

    my $result = Koha::Availability::Result->new();

    # Check if item is withdrawn and blocked
    if ( $item->withdrawn && C4::Context->preference("BlockReturnOfWithdrawnItems") ) {
        $result->add_blocker( BlockedWithdrawn => 1 );
        return $result;
    }

    # Check if item is lost and blocked
    if ( $item->itemlost && C4::Context->preference("BlockReturnOfLostItems") ) {
        $result->add_blocker( BlockedLost => 1 );
        return $result;
    }

    # Check branch check-in policy
    my ( $returnallowed, $message ) = _can_book_be_returned( $item, $branch );
    unless ($returnallowed) {
        $result->add_blocker(
            Wrongbranch => {
                Wrongbranch => $branch,
                Rightbranch => $message
            }
        );
        return $result;
    }

    # Check if item is currently checked out
    my $checkout = $item->checkout;
    if ($checkout) {
        $result->set_context( checkout => $checkout );
        $result->set_context( patron   => $checkout->patron );
    } else {

        # Item not checked out
        $result->add_confirmation( NotIssued => $item->barcode );
    }

    # Add warnings for withdrawn (when not blocked)
    if ( $item->withdrawn ) {
        $result->add_warning( withdrawn => 1 );
    }

    return $result;
}

=head2 Internal methods

=head3 _can_book_be_returned

    my ($allowed, $message) = _can_book_be_returned($item, $branch);

Internal method to check if an item can be checked in to a specific branch
based on the AllowReturnToBranch system preference.

This is extracted from C4::Circulation::CanBookBeReturned.

=cut

sub _can_book_be_returned {
    my ( $item, $branch ) = @_;
    my $allowreturntobranch = C4::Context->preference("AllowReturnToBranch") || 'anywhere';

    my $allowed = 1;
    my $message;

    if ( $allowreturntobranch eq 'homebranch' && $branch ne $item->homebranch ) {
        $allowed = 0;
        $message = $item->homebranch;
    } elsif ( $allowreturntobranch eq 'holdingbranch' && $branch ne $item->holdingbranch ) {
        $allowed = 0;
        $message = $item->holdingbranch;
    } elsif ( $allowreturntobranch eq 'homeorholdingbranch'
        && $branch ne $item->homebranch
        && $branch ne $item->holdingbranch )
    {
        $allowed = 0;
        $message = $item->homebranch;
    }

    return ( $allowed, $message );
}

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut

1;
