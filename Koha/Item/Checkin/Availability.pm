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
use Koha::Libraries;

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
            library    => $branchcode,
            to_library => $destination_branchcode,
        }
    );

Validates check-in availability for an item.

Parameters:
    $item   - Koha::Item object (required)
    $params - hashref with:
        library    => branchcode where the return takes place (required)
        to_library => branchcode where the item should be sent after return
                      (optional, for transfer limit validation)

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

    my $library    = $params->{library};
    my $to_library = $params->{to_library};

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

    # Check AllowReturnToBranch policy
    my ( $returnallowed, $message ) = _check_return_policy( $item, $library );
    unless ($returnallowed) {
        $result->add_blocker(
            Wrongbranch => {
                Wrongbranch => $library,
                Rightbranch => $message
            }
        );
        return $result;
    }

    # Check branch transfer limits (bug 7376)
    if ( defined $to_library ) {
        my $from = Koha::Libraries->find($library);
        my $to   = Koha::Libraries->find($to_library);
        if ( !$item->can_be_transferred( { from => $from, to => $to } ) ) {
            $result->add_blocker(
                Wrongbranch => {
                    Wrongbranch => $library,
                    Rightbranch => $to_library
                }
            );
            return $result;
        }
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

=head3 _check_return_policy

    my ($allowed, $message) = _check_return_policy($item, $library);

Check if an item can be checked in at the given library based on the
AllowReturnToBranch system preference.

=cut

sub _check_return_policy {
    my ( $item, $library ) = @_;
    my $allowreturntobranch = C4::Context->preference("AllowReturnToBranch") || 'anywhere';

    my $allowed = 1;
    my $message;

    if ( $allowreturntobranch eq 'homebranch' && $library ne $item->homebranch ) {
        $allowed = 0;
        $message = $item->homebranch;
    } elsif ( $allowreturntobranch eq 'holdingbranch' && $library ne $item->holdingbranch ) {
        $allowed = 0;
        $message = $item->holdingbranch;
    } elsif ( $allowreturntobranch eq 'homeorholdingbranch'
        && $library ne $item->homebranch
        && $library ne $item->holdingbranch )
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
