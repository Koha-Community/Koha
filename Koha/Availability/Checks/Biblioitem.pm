package Koha::Availability::Checks::Biblioitem;

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
use C4::Members;

use Koha::Biblioitems;

use Koha::Exceptions::Patron;

sub new {
    my ($class, $biblioitem) = @_;

    unless ($biblioitem) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Biblioitem related checks require a biblioitem. Not given.'
        );
    }
    unless (ref($biblioitem) eq 'Koha::Biblioitem') {
        Koha::Exceptions::BadParameter->throw(
            error => 'Biblioitem must be a Koha::Biblioitem object.'
        );
    }

    my $self = {
        biblioitem => $biblioitem,
    };

    bless $self, $class;
}

=head3 age_restricted

Returns Koha::Exceptions::Patron::AgeRestricted if biblioitem age restriction
applies for patron.

=cut

sub age_restricted {
    my ($self, $patron) = @_;

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

    my $biblioitem = $self->biblioitem;
    my $agerestriction  = $biblioitem->agerestriction;
    my ($restriction_age, $daysToAgeRestriction) =
        C4::Circulation::GetAgeRestriction($agerestriction, $patron->unblessed);
    my $restricted = $daysToAgeRestriction && $daysToAgeRestriction > 0 ? 1:0;
    if ($restricted) {
        return Koha::Exceptions::Patron::AgeRestricted->new(
            age_restriction => $agerestriction,
        );
    }
    return;
}

1;
