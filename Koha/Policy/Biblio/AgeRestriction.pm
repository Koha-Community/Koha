package Koha::Policy::Biblio::AgeRestriction;

# Copyright 2026 Theke Solutions
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

use Koha::Result::Boolean;

=head1 NAME

Koha::Policy::Biblio::AgeRestriction - age restriction policy checks

=head1 API

=head2 Class methods

=head3 check

    my $result = Koha::Policy::Biblio::AgeRestriction->check( $biblio, $patron );

Checks whether a patron meets the age restriction for a biblio.

Returns undef if there is no restriction or it cannot be evaluated
(e.g. patron has no date of birth). Otherwise returns a L<Koha::Result::Boolean>:
true if the patron meets the restriction, false (with message) if not.

=cut

sub check {
    my ( $class, $biblio, $patron ) = @_;

    my $restriction_age = $biblio->age_restriction;
    return Koha::Result::Boolean->new(1) unless $restriction_age;
    return Koha::Result::Boolean->new(1) unless $patron->dateofbirth;

    return $restriction_age > $patron->get_age
        ? Koha::Result::Boolean->new(0)
        ->add_message( { message => 'age_restricted', payload => { restriction_age => $restriction_age } } )
        : Koha::Result::Boolean->new(1);
}

1;
