package Koha::Policy::Holds;

# Copyright 2023 Koha Development team
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;

=head1 NAME

Koha::Policy::Holds - module to deal with holds policy

=head1 API

=head2 Class Methods

=head3 new

=cut

sub new {
    return bless {}, shift;
}

=head3 holds_control_library

    my $control_library = Koha::Policy::Holds->holds_control_library( $item, $patron );

Given I<Koha::Item> and I<Koha::Patron> objects, this method returns a library id, for
the library that is to be used for calculating circulation rules. It relies
on the B<ReservesControlBranch> system preference.

=cut

sub holds_control_library {
    my ( $class, $item, $patron ) = @_;

    return ( C4::Context->preference('ReservesControlBranch') eq 'ItemHomeLibrary' )
        ? $item->homebranch
        : $patron->branchcode;
}

1;
