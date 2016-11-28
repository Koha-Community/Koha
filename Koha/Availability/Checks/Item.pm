package Koha::Availability::Checks::Item;

# Copyright Koha-Suomi Oy 2016
#
# This file is part of Koha
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

use base qw(Koha::Availability::Checks);

use C4::Circulation;
use C4::Context;
use C4::Reserves;

use Koha::AuthorisedValues;
use Koha::DateUtils;
use Koha::Holds;
use Koha::ItemTypes;
use Koha::Items;
use Koha::Item::Transfers;

use Koha::Exceptions::Item;
use Koha::Exceptions::ItemType;

sub new {
    my ($class, $item) = @_;

    unless ($item) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Class must be instantiated by providing a Koha::Item object.'
        );
    }
    unless (ref($item) eq 'Koha::Item') {
        Koha::Exceptions::BadParameter->throw(
            error => 'Item must be a Koha::Item object.'
        );
    }

    my $self = {
        item => $item,
    };

    bless $self, $class;
}

=head3 checked_out

Returns Koha::Exceptions::Item::CheckedOut if item is checked out.

=cut

sub checked_out {
    my ($self, $issue) = @_;

    $issue ||= C4::Circulation::GetItemIssue($self->item->itemnumber);
    if (ref($issue) eq 'Koha::Checkout') {
        $issue = $issue->unblessed;
        $issue->{date_due} = dt_from_string($issue->{date_due});
    }
    if ($issue) {
        return Koha::Exceptions::Item::CheckedOut->new(
            borrowernumber => 0+$issue->{borrowernumber},
            date_due => $issue->{date_due}->strftime('%F %T'),
        );
    }
    return;
}

=head3 checked_out

Returns Koha::Exceptions::Checkout::Fee if checking out an item will cause
a checkout fee.

Koha::Exceptions::Checkout::Fee additional fields:
  amount                # defines the amount of checkout fee

=cut

sub checkout_fee {
    my ($self, $patron) = @_;

    my ($rentalCharge) = C4::Circulation::GetIssuingCharges
    (
        $self->item->itemnumber,
        $patron ? $patron->borrowernumber : undef
    );
    if ($rentalCharge > 0){
        return Koha::Exceptions::Checkout::Fee->new(
            amount => sprintf("%.02f", $rentalCharge),
        );
    }
    return;
}

=head3 damaged

Returns Koha::Exceptions::Item::Damaged if item is damaged and holds are not
allowed on damaged items.

=cut

sub damaged {
    my ($self) = @_;

    if ($self->item->damaged
        && !C4::Context->preference('AllowHoldsOnDamagedItems')) {
        return Koha::Exceptions::Item::Damaged->new;
    }
    return;
}

=head3 from_another_library

Returns Koha::Exceptions::Item::FromAnotherLibrary if IndependentBranches is on,
and item is from another branch than the user currently logged in.

Koha::Exceptions::Item::FromAnotherLibrary additional fields:
  from_library              # item's library (according to HomeOrHoldingBranch)
  current_library           # the library of logged-in user

=cut

sub from_another_library {
    my ($self) = @_;

    my $item = $self->item;
    if (C4::Context->preference("IndependentBranches")) {
        return unless my $userenv = C4::Context->userenv;
        unless (C4::Context->IsSuperLibrarian()) {
            my $homeorholding = C4::Context->preference("HomeOrHoldingBranch");
            if ($userenv->{branch} && $item->$homeorholding ne $userenv->{branch}){
                return Koha::Exceptions::Item::FromAnotherLibrary->new(
                        from_library => $item->$homeorholding,
                        current_library => $userenv->{branch},
                );
            }
        }
    }
    return;
}

=head3 held

Returns Koha::Exceptions::Item::Held item is held.

Koha::Exceptions::Item::Held additional fields:
  borrowernumber              # item's library (according to HomeOrHoldingBranch)
  status                      # the library of logged-in user
  hold_queue_length           # hold queue length for the item

=cut

sub held {
    my ($self) = @_;

    my $item = $self->item;
    if (my ($s, $reserve) = C4::Reserves::CheckReserves($item->itemnumber)) {
        if ($reserve) {
            return Koha::Exceptions::Item::Held->new(
                borrowernumber => 0+$reserve->{'borrowernumber'},
                status => $s,
                hold_queue_length => 0+Koha::Holds->search({
                    itemnumber => $item->itemnumber })->count,
            );
        }
    }
    return;
}

=head3 held_by_patron

Returns Koha::Exceptions::Item::AlreadyHeldForThisPatron if item is already
held by given patron.

OPTIONAL PARAMETERS
holds       # list of Koha::Hold objects to inspect the item's held-status from.
            # If not given, a query is made for selecting the holds from database.
            # Useful in optimizing biblio-level availability by selecting all holds
            # of a biblio and then passing it for this function instead of querying
            # reserves table multiple times for each item.

=cut

sub held_by_patron {
    my ($self, $patron, $params) = @_;

    my $item = $self->item;
    my $holds;
    if (!exists $params->{'holds'}) {
        $holds = Koha::Holds->search({
            borrowernumber => 0+$patron->borrowernumber,
            itemnumber => 0+$item->itemnumber,
        })->count();
    } else {
        foreach my $hold (@{$params->{'holds'}}) {
            next unless $hold->itemnumber;
            if ($hold->itemnumber == $item->itemnumber) {
                $holds++;
            }
        }
    }
    if ($holds) {
        return Koha::Exceptions::Item::AlreadyHeldForThisPatron->new
    }
    return;
}

=head3 high_hold

Returns Koha::Exceptions::Item::HighHolds if item is a high-held item and
decreaseLoanHighHolds is enabled.

=cut

sub high_hold {
    my ($self, $patron) = @_;

    return unless C4::Context->preference('decreaseLoanHighHolds');

    my $item = $self->item;
    my $check = C4::Circulation::checkHighHolds(
        $item->unblessed,
        $patron->unblessed
    );

    if ($check->{exceeded}) {
        return Koha::Exceptions::Item::HighHolds->new(
            num_holds => 0+$check->{outstanding},
            duration => $check->{duration},
            returndate => $check->{due_date}->strftime('%F %T'),
        );
    }
    return;
}

=head3 lost

Returns Koha::Exceptions::Item::Lost if item is lost.

=cut

sub lost {
    my ($self) = @_;

    my $item = $self->item;
    if ($self->item->itemlost) {
        my $av = Koha::AuthorisedValues->search({
            category => 'LOST',
            authorised_value => $item->itemlost
        });
        my $code = $av->count ? $av->next->lib : '';
        return Koha::Exceptions::Item::Lost->new(
            status => 0+$item->itemlost,
            code => $code,
        );
    }
    return;
}

=head3 notforloan

Returns Koha::Exceptions::Item::NotForLoan if item is not for loan, and
additionally Koha::Exceptions::ItemType::NotForLoan if itemtype is not for loan.

=cut

sub notforloan {
    my ($self) = @_;

    my $item = $self->item;
    my $cache = Koha::Caches->get_instance('availability');
    my $cached = $cache->get_from_cache('itemtype-'.$item->effective_itemtype);
    my $itemtype;
    if ($cached) {
        $itemtype = Koha::ItemType->new->set($cached);
    } else {
        $itemtype = Koha::ItemTypes->find($item->effective_itemtype);
        $cache->set_in_cache('itemtype-'.$item->effective_itemtype,
                            $itemtype->unblessed, { expiry => 10 }) if $itemtype;
    }

    if ($item->notforloan != 0 || $itemtype && $itemtype->notforloan != 0) {
        my $av = Koha::AuthorisedValues->search({
            category => 'NOT_LOAN',
            authorised_value => $item->notforloan
        });
        my $code = $av->count ? $av->next->lib : '';
        if ($item->notforloan > 0) {
            return Koha::Exceptions::Item::NotForLoan->new(
                status => 0+$item->notforloan,
                code => $code,
            );
        } elsif ($itemtype && $itemtype->notforloan > 0) {
            return Koha::Exceptions::ItemType::NotForLoan->new(
                status => 0+$itemtype->notforloan,
                code => $code,
                itemtype => $itemtype->itemtype,
            );
        } elsif ($item->notforloan < 0) {
            return Koha::Exceptions::Item::NotForLoan->new(
                status => 0+$item->notforloan,
                code => $code,
            );
        }
    }
    return;
}

=head3 onloan

Returns Koha::Exceptions::Item::CheckedOut if item is onloan.

This does not query issues table, but simply checks item's onloan-column.

=cut

sub onloan {
    my ($self) = @_;

    # This simply checks item's onloan-column to determine item's checked out
    # -status. Use C<checked_out> to perform an actual query for checkouts.
    if ($self->item->onloan) {
        return Koha::Exceptions::Item::CheckedOut->new;
    }
}

=head3 restricted

Returns Koha::Exceptions::Item::Restricted if item is restricted.

=cut

sub restricted {
    my ($self) = @_;

    if ($self->item->restricted) {
        return Koha::Exceptions::Item::Restricted->new;
    }
    return;
}

=head3 transfer

Returns Koha::Exceptions::Item::Transfer if item is in transfer.

Koha::Exceptions::Item::Transfer additional fields:
  from_library
  to_library
  datesent

=cut

sub transfer {
    my ($self) = @_;

    my $transfer = Koha::Item::Transfers->search({
        itemnumber => $self->item->itemnumber,
        datesent => { '!=', undef },
        datearrived => undef,
    })->next;
    if ($transfer) {
        return Koha::Exceptions::Item::Transfer->new(
            from_library => $transfer->frombranch,
            to_library => $transfer->tobranch,
            datesent => $transfer->datesent,
        );
    }
    return;
}

=head3 transfer_limit

Returns Koha::Exceptions::Item::CannotBeTransferred a transfer limit applies
for item.

Koha::Exceptions::Item::CannotBeTransferred additional parameters:
  from_library
  to_library

=cut

sub transfer_limit {
    my ($self, $to_branch) = @_;

    return unless C4::Context->preference('UseBranchTransferLimits');
    my $item = $self->item;
    my $limit_type = C4::Context->preference('BranchTransferLimitsType');
    my $code;
    if ($limit_type eq 'itemtype') {
        $code = $item->effective_itemtype;
    } elsif ($limit_type eq 'ccode') {
        $code = $item->ccode;
    } else {
        Koha::Exceptions::BadParameter->throw(
            error => 'System preference BranchTransferLimitsType has an'
            .' unrecognized value.'
        );
    }

    my $allowed = C4::Circulation::IsBranchTransferAllowed(
        $to_branch,
        $item->holdingbranch,
        $code
    );
    if (!$allowed) {
        return Koha::Exceptions::Item::CannotBeTransferred->new(
            from_library => $item->holdingbranch,
            to_library   => $to_branch,
        );
    }
    return;
}

=head3 unknown_barcode

Returns Koha::Exceptions::Item::UnknownBarcode if item has no barcode.

=cut

sub unknown_barcode {
    my ($self) = @_;

    my $item = $self->item;
    unless ($item->barcode) {
        return Koha::Exceptions::Item::UnknownBarcode->new;
    }
    return;
}

=head3 withdrawn

Returns Koha::Exceptions::Item::Withdrawn if item is withdrawn.

=cut

sub withdrawn {
    my ($self) = @_;

    if ($self->item->withdrawn) {
        return Koha::Exceptions::Item::Withdrawn->new;
    }
    return;
}

1;
