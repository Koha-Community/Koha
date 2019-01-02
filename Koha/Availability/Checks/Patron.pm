package Koha::Availability::Checks::Patron;

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

use Scalar::Util qw(looks_like_number);

use C4::Context;
use C4::Members;

use Koha::Exceptions::Hold;
use Koha::Exceptions::Patron;

sub new {
    my ($class, $patron) = @_;

    unless ($patron) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Patron related checks require a patron. Not given.'
        );
    }
    unless (ref($patron) eq 'Koha::Patron') {
        Koha::Exceptions::BadParameter->throw(
            error => 'Patron must be a Koha::Patron object.'
        );
    }

    my $self = {
        patron => $patron,
    };

    bless $self, $class;
}

=head3 debarred

Returns Koha::Exceptions::Patron::Debarred if patron is debarred.

Koha::Exceptions::Patron::Debarred additional fields:
  expiration     # expiration date of debarment
  comment        # comment for this debarment

=cut

sub debarred {
    my ($self) = @_;

    my $patron = $self->patron;
    if ($patron->is_debarred) {
        return Koha::Exceptions::Patron::Debarred->new(
            expiration => $patron->debarred,
            comment => $patron->debarredcomment,
        );
    }
    return;
}

=head3 debt_checkout

Returns Koha::Exceptions::Patron::Debt if patron has outstanding fines that
exceed the amount defined in "noissuescharge" system preference.

Koha::Exceptions::Patron::Debt additional fields:
  max_outstanding       # maximum allowed amount of outstanding fines
  current_outstanding   # current amount of outstanding fines

=cut

sub debt_checkout {
    my ($self) = @_;

    my ($amount) = C4::Members::GetMemberAccountRecords(
                        $self->patron->borrowernumber
    );
    my $maxoutstanding = C4::Context->preference("noissuescharge");
    if (C4::Context->preference('AllFinesNeedOverride') && $amount > 0) {
        # All fines need override, so return Koha::Exceptions::Patron::Debt.
        return Koha::Exceptions::Patron::Debt->new(
            max_outstanding => 0+sprintf("%.2f", $maxoutstanding),
            current_outstanding => 0+sprintf("%.2f", $amount),
        );
    } else {
        return $self->_debt($amount, $maxoutstanding);
    }
}

=head3 debt_checkout_guarantees

Returns Koha::Exceptions::Patron::DebtGuarantees if patron's guarantees are
exceeding the amount defined in "NoIssuesChargeGuarantees" system preference.

Koha::Exceptions::Patron::DebtGuarantees additional fields:
  max_outstanding       # maximum allowed amount of outstanding fines
  current_outstanding   # current amount of outstanding fines

=cut

sub debt_checkout_guarantees {
    my ($self) = @_;

    my $patron = $self->patron;
    my $max_charges = C4::Context->preference("NoIssuesChargeGuarantees");
    $max_charges = undef unless looks_like_number($max_charges);
    return unless $max_charges;
    my @guarantees = $patron->guarantees;
    return unless scalar(@guarantees);
    my $guarantees_non_issues_charges;
    foreach my $g (@guarantees) {
        my ($b, $n, $o) = C4::Members::GetMemberAccountBalance($g->id);
        $guarantees_non_issues_charges += $n;
    }
    if ($guarantees_non_issues_charges > $max_charges) {
        return Koha::Exceptions::Patron::DebtGuarantees->new(
            max_outstanding => 0+sprintf("%.2f", $max_charges),
            current_outstanding => 0+sprintf("%.2f", $guarantees_non_issues_charges),
        );
    }
    return;
}

=head3 debt_hold

Returns Koha::Exceptions::Patron::Debt if patron has outstanding fines that
exceed the amount defined in "maxoutstanding" system preference.

Koha::Exceptions::Patron::Debt additional fields:
  max_outstanding       # maximum allowed amount of outstanding fines
  current_outstanding   # current amount of outstanding fines

=cut

sub debt_hold {
    my ($self) = @_;

    my ($amount) = C4::Members::GetMemberAccountRecords(
                        $self->patron->borrowernumber
    );
    my $maxoutstanding = C4::Context->preference("maxoutstanding");
    return $self->_debt($amount, $maxoutstanding);
}

=head3 debt_checkout

Returns Koha::Exceptions::Patron::Debt if patron has outstanding fines that
exceed the amount defined in "OPACFineNoRenewals" system preference.

Koha::Exceptions::Patron::Debt additional fields:
  max_outstanding       # maximum allowed amount of outstanding fines
  current_outstanding   # current amount of outstanding fines

=cut

sub debt_renew_opac {
    my ($self) = @_;

    my ($amount) = C4::Members::GetMemberAccountRecords(
                        $self->patron->borrowernumber
    );
    my $maxoutstanding = C4::Context->preference("OPACFineNoRenewals");
    return $self->_debt($amount, $maxoutstanding);
}

=head3 exceeded_maxreserves

Returns Koha::Exceptions::Hold::MaximumHoldsReached if the total amount of
patron's holds exceeds the amount defined in "maxreserves" system preference.

Koha::Exceptions::Hold::MaximumHoldsReached additional fields:
  max_holds_allowed    # maximum amount of allowed holds (maxreserves preference)
  current_hold_count   # total amount of patron's current (non-found) holds

=cut

sub exceeded_maxreserves {
    my ($self) = @_;

    my $patron = $self->patron;
    my $max = C4::Context->preference('maxreserves');
    return unless $max;
    my $holds = Koha::Holds->search({
        borrowernumber => $patron->borrowernumber,
        found => undef,
    })->count();
    if ($holds && $max && $holds >= $max) {
        return Koha::Exceptions::Hold::MaximumHoldsReached->new(
            max_holds_allowed => 0+$max,
            current_hold_count => 0+$holds,
        );
    }
    return;
}

=head3 expired

Returns Koha::Exceptions::Patron::CardExpired if patron's card has been expired.

Koha::Exceptions::Patron::CardExpired additional fields:
  expiration_date

=cut

sub expired {
    my ($self) = @_;

    my $patron = $self->patron;
    if ($patron->is_expired) {
        return Koha::Exceptions::Patron::CardExpired->new(
            expiration_date => $patron->dateexpiry
        );
    }
    return;
}

=head3 from_another_library

Returns Koha::Exceptions::Patron::FromAnotherLibrary if patron is from another
library than currently logged-in user. System preference "IndependentBranches"
is considered for this method.

Koha::Exceptions::Patron::FromAnotherLibrary additional fields:
  patron_branch             # patron's library
  current_branch            # library of currently logged-in user

=cut

sub from_another_library {
    my ($self) = @_;

    my $patron = $self->patron;
    if (C4::Context->preference("IndependentBranches")) {
        my $userenv = C4::Context->userenv;
        unless (C4::Context->IsSuperLibrarian()) {
            if ($patron->branchcode ne $userenv->{branch}) {
                return Koha::Exceptions::Patron::FromAnotherLibrary->new(
                    patron_branch => $patron->branchcode,
                    current_branch => $userenv->{branch},
                );
            }
        }
    }
    return;
}

=head3 gonenoaddress

Returns Koha::Exceptions::Patron::GoneNoAddress if patron is gonenoaddress.

=cut

sub gonenoaddress {
    my ($self) = @_;

    if ($self->patron->gonenoaddress) {
        return Koha::Exceptions::Patron::GoneNoAddress->new;
    }
    return;
}

=head3 lost

Returns Koha::Exceptions::Patron::CardLost if patron's card is marked as lost.

=cut

sub lost {
    my ($self) = @_;

    if ($self->patron->lost) {
        return Koha::Exceptions::Patron::CardLost->new;
    }
    return;
}

=head3 overdue_checkouts

Returns Koha::Exceptions::Patron::DebarredOverdue if patron is debarred because
they have overdue checkouts.

Koha::Exceptions::Patron::DebarredOverdue additional fields:
  number_of_overdues

=cut

sub overdue_checkouts {
    my ($self) = @_;

    my $number;
    if ($number = $self->patron->has_overdues) {
        return Koha::Exceptions::Patron::DebarredOverdue->new(
            number_of_overdues => 0+$number,
        );
    }
    return;
}

sub _debt {
    my ($self, $amount, $maxoutstanding) = @_;
    return unless $maxoutstanding;
    if ($amount && $maxoutstanding && $amount > $maxoutstanding) {
        return Koha::Exceptions::Patron::Debt->new(
            max_outstanding => 0+sprintf("%.2f", $maxoutstanding),
            current_outstanding => 0+sprintf("%.2f", $amount),
        );
    }
    return;
}

1;
