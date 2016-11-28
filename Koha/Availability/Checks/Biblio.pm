package Koha::Availability::Checks::Biblio;

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

use C4::Context;
use C4::Circulation;
use C4::Serials;

use Koha::Biblios;
use Koha::Checkouts;
use Koha::Patrons;

use Koha::Exceptions::Biblio;

sub new {
    my ($class, $biblio) = @_;

    unless ($biblio) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Class must be instantiated by providing a Koha::Biblio object.'
        );
    }
    unless (ref($biblio) eq 'Koha::Biblio') {
        Koha::Exceptions::BadParameter->throw(
            error => 'Biblio must be a Koha::Biblio object.'
        );
    }

    my $self = {
        biblio => $biblio,
    };

    bless $self, $class;
}

=head3 checked_out

Returns Koha::Exceptions::Biblio::CheckedOut if biblio is checked out.

=cut

sub checked_out {
    my ($self, $patron) = @_;

    my $biblio = $self->biblio;
    my $issues = Koha::Checkouts->search({
        borrowernumber => 0+$patron->borrowernumber,
        biblionumber   => 0+$biblio->biblionumber,
    },
    {
        join => 'item',
    });
    if ($issues->count > 0) {
        return Koha::Exceptions::Biblio::CheckedOut->new(
            biblionumber => 0+$biblio->biblionumber,
        );
    }
    return;
}

=head3 forbid_holds_on_patrons_possessions

Returns Koha::Exceptions::Biblio::AnotherItemCheckedOut if system preference
AllowHoldsOnPatronsPossessions is disabled and another item from the same biblio
is checked out.

=cut

sub forbid_holds_on_patrons_possessions {
    my ($self, $patron) = @_;

    if (!C4::Context->preference('AllowHoldsOnPatronsPossessions')) {
        return $self->checked_out($patron);
    }
    return;
}

=head3 forbid_multiple_issues

Returns Koha::Exceptions::Biblio::CheckedOut if system preference
AllowMultipleIssuesOnABiblio is disabled and an item from biblio is checked out.

=cut

sub forbid_multiple_issues {
    my ($self, $patron) = @_;

    if (!C4::Context->preference('AllowMultipleIssuesOnABiblio')) {
        my $biblionumber = $self->biblio->biblionumber;
        unless (C4::Serials::CountSubscriptionFromBiblionumber($biblionumber)) {
            return $self->checked_out($patron);
        }
    }
    return;
}

1;
