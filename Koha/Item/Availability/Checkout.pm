package Koha::Item::Availability::Checkout;

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

use base qw(Koha::Item::Availability);

use Koha::Biblioitems;
use Koha::Checkouts;
use Koha::DateUtils;
use Koha::Items;

use Koha::Availability::Checks::Biblio;
use Koha::Availability::Checks::Biblioitem;
use Koha::Availability::Checks::Checkout;
use Koha::Availability::Checks::Item;
use Koha::Availability::Checks::IssuingRule;
use Koha::Availability::Checks::Patron;

use Koha::Exceptions::Hold;
use Koha::Exceptions::Checkout;
use Koha::Exceptions::Item;
use Koha::Exceptions::ItemType;
use Koha::Exceptions::Patron;

use DateTime;
use Scalar::Util qw( looks_like_number );

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    $self->{'duedate'} ||= undef;

    return $self;
}

sub in_intranet {
    my ($self, $params) = @_;
    my $reason;

    $self->reset;

    my $item = $self->item;
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $patron;
    unless ($patron = $self->patron) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Missing parameter patron. This level of availability query '
            .'requires Koha::Item::Availability::Checkout to have a patron '
            .'parameter.'
        );
    }

    my $branchcode = C4::Circulation::_GetCircControlBranch
    (
        $item->unblessed,$patron->unblessed
    );
    my $checkoutcalc = Koha::Availability::Checks::Checkout->new;
    my $duedate = $self->duedate;
    if ($duedate &&
       ($reason = $checkoutcalc->invalid_due_date($item, $patron, $duedate))) {
        if (ref($reason) eq 'Koha::Exceptions::Checkout::DueDateBeforeNow') {
            $self->confirm($reason);        # due date before now
        } else {
            $self->unavailable($reason);    # invalid due date
        }
    }

    my $bibitem = Koha::Biblioitems->find($item->biblioitemnumber);
    my $bibitemcalc = Koha::Availability::Checks::Biblioitem->new($bibitem);
    if ($reason = $bibitemcalc->age_restricted($patron)) {
        if (C4::Context->preference('AgeRestrictionOverride')) {
            $self->confirm($reason);        # age restricted override
        } else {
            $self->unavailable($reason);    # age restricted
        }
    }

    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $allowfineoverride = C4::Context->preference('AllowFineOverride');
    if ($reason = $patroncalc->debt_checkout) {
        if ($allowfineoverride) {
            $self->confirm($reason);        # patron fines override
        } else {
            $self->unavailable($reason);    # patron fines
        }
    }
    if ($reason = $patroncalc->debt_checkout_guarantees) {
        if ($allowfineoverride) {
            $self->confirm($reason);        # guarantees' fines override
        } else {
            $self->unavailable($reason);    # guarantees' fines
        }
    }
    $self->unavailable($reason) if $reason = $patroncalc->debarred;
    $self->confirm($reason) if $reason = $patroncalc->from_another_library;
    $self->unavailable($reason) if $reason = $patroncalc->gonenoaddress;
    $self->unavailable($reason) if $reason = $patroncalc->lost;
    $self->unavailable($reason) if $reason = $patroncalc->expired;
    if ($reason = $patroncalc->overdue_checkouts) {
        my $overduesblockcirc = C4::Context->preference("OverduesBlockCirc");
        if ($overduesblockcirc eq 'block') {
            $self->unavailable($reason);    # overdue checkouts
        }
        elsif ($overduesblockcirc eq 'confirmation'){
            $self->confirm($reason);        # overdue checkouts override
        }
    }

    my $checkoutrulecalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
        branchcode => $branchcode,
    });
    if ($reason = $checkoutrulecalc->zero_checkouts_allowed) {
        $self->confirm($reason);             # maxissueqty == 0
    }
    else {
        if ($reason = $checkoutrulecalc->maximum_checkouts_reached) {
            if (C4::Context->preference("AllowTooManyOverride")) {
                $self->confirm($reason);     # too many override
            } else {
                $self->unavailable($reason); # too many
            }
        }
    }

    my $itemcalc = Koha::Availability::Checks::Item->new($item);
    $self->unavailable($reason) if $reason = $itemcalc->damaged;
    if ($reason = $itemcalc->lost) {
        my $issuelostitem = C4::Context->preference("IssueLostItem");
        unless ($issuelostitem eq 'nothing') {
            if ($issuelostitem eq 'confirm') {
                $self->confirm($reason);     # lost item, require confirmation
            } elsif ($issuelostitem eq 'alert') {
                $self->note($reason);        # lost item, additional note
            }
        }
    }
    $self->unavailable($reason) if $reason = $itemcalc->from_another_library;
    $self->unavailable($reason) if $reason = $itemcalc->restricted;
    $self->unavailable($reason) if $reason = $itemcalc->unknown_barcode;
    $self->unavailable($reason) if $reason = $itemcalc->withdrawn;
    if ($reason = $itemcalc->notforloan) {
        if (C4::Context->preference("AllowNotForLoanOverride")) {
            $self->confirm($reason);        # notforloan override
        } else {
            $self->unavailable($reason);    # notforloan
        }
    }

    if (C4::Context->preference("RentalFeesCheckoutConfirmation")
        && ($reason = $itemcalc->checkout_fee)) {
        $self->confirm($reason);            # checkout fees
    }

    # is item already checked out?
    my $issue = Koha::Checkouts->find({ itemnumber => $item->itemnumber });
    if ($reason = $itemcalc->checked_out($issue)) {
        if ($reason->borrowernumber == $patron->borrowernumber) {
            if ($reason = $checkoutcalc->no_more_renewals($issue)) {
                if (C4::Context->preference('AllowRenewalLimitOverride')) {
                    $self->confirm($reason);     # no more renewals override
                } else {
                    $self->unavailable($reason); # no more renewals
                }
            } else {
                $self->confirm(Koha::Exceptions::Checkout::Renew->new);
            }
        } else {
            $self->confirm($reason);        # checked out (to someone else)
        }
    }

    unless ($params->{'ignore_holds'}) {
        if ($reason = $itemcalc->held) {
            if ($reason->borrowernumber != $patron->borrowernumber) {
                $self->confirm($reason);    # held (to someone else)
            }
        }
    }
    if ($reason = $itemcalc->high_hold($patron)) {
        if ($params->{'override_high_holds'}) {
            $self->note($reason);           # high holds, additional note
        } else {
            $self->confirm($reason);        # high holds, confirmation
        }
    }

    my $bibliocalc = Koha::Availability::Checks::Biblio->new($biblio);
    my $nomorerenewals = exists
       $self->unavailabilities->{'Koha::Exceptions::Checkout::NoMoreRenewals'}
       ? 1 : 0;
    my $renew = exists
       $self->confirmations->{'Koha::Exceptions::Checkout::Renew'}
       ? 1 : 0;
    if (!$nomorerenewals && !$renew &&
        ($reason = $bibliocalc->checked_out($patron))) {
        $self->confirm($reason);
    }

    return $self;
}

1;
