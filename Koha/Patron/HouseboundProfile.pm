package Koha::Patron::HouseboundProfile;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::Patron::HouseboundVisits;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::HouseboundProfile - Koha Patron HouseboundProfile Object class

=head1 SYNOPSIS

HouseboundProfile class used primarily by members/housebound.pl.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 housebound_visits

    my $visits = Koha::Patron::HouseboundProfile->housebound_visits;

Returns a I<Koha::Patron::HouseboundVisits> iterator for all the visits
associated this houseboundProfile.

=cut

sub housebound_visits {
    my ($self) = @_;
    return Koha::Patron::HouseboundVisits->special_search( { borrowernumber => $self->borrowernumber } );
}

=head3 _type

=cut

sub _type {
    return 'HouseboundProfile';
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
