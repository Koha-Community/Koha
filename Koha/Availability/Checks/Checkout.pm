package Koha::Availability::Checks::Checkout;

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

use Koha::DateUtils;
use Koha::Items;

use Koha::Exceptions::Biblio;
use Koha::Exceptions::Checkout;

sub new {
    my ($class) = @_;

    my $self = {};

    bless $self, $class;
}

=head3 invalid_due_date

Returns Koha::Exceptions::Checkout::InvalidDueDate if given due date is invalid.

Returns Koha::Exceptions::Checkout::DueDateBeforeNow if given due date is in the
past.

=cut

sub invalid_due_date {
    my ($self, $item, $patron, $duedate) = @_;

    if ($duedate && ref $duedate ne 'DateTime') {
        eval { $duedate = dt_from_string($duedate); };
        if ($@) {
            return Koha::Exceptions::Checkout::InvalidDueDate->new(
                duedate => $duedate,
            );
        }
    }

    my $now = DateTime->now(time_zone => C4::Context->tz());
    unless ($duedate) {
        my $issuedate = $now->clone();

        my $branch = C4::Circulation::_GetCircControlBranch($item, $patron);
        $duedate = C4::Circulation::CalcDateDue
        (
            $issuedate, $item->effective_itemtype, $branch, $patron->unblessed
        );
    }
    if ($duedate) {
        my $today = $now->clone->truncate(to => 'minute');
        if (DateTime->compare($duedate,$today) == -1 ) {
            # duedate cannot be before now
            return Koha::Exceptions::Checkout::DueDateBeforeNow->new(
                duedate => $duedate->strftime('%F %T'),
                now => $now->strftime('%F %T'),
            );
        }
    } else {
        return Koha::Exceptions::Checkout::InvalidDueDate->new(
                duedate => $duedate,
        );
    }
    return;
}

=head3 no_more_renewals

Returns Koha::Exceptions::Checkout::NoMoreRenewals if no more renewals are
allowed for given checkout.

=cut

sub no_more_renewals {
    my ($self, $issue) = @_;

    return unless $issue;
    my ($status) = C4::Circulation::CanBookBeRenewed($issue->borrowernumber,
             $issue->itemnumber);
    if ($status == 0) {
        return Koha::Exceptions::Checkout::NoMoreRenewals->new;
    }
    return;
}

1;
