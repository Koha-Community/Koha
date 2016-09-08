package Koha::Holds;

# Copyright ByWater Solutions 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;

use Koha::Hold;

use base qw(Koha::Objects);

=head1 NAME

Koha::Holds - Koha Hold object set class

=head1 API

=head2 Class Methods

=cut

=head3 waiting

Returns a set of holds that are waiting from an existing set

=cut

sub waiting {
    my ( $self ) = @_;

    return $self->search( { found => 'W' } );
}

=head3 forced_hold_level

If a patron has multiple holds for a single record,
those holds must be either all record level holds,
or they must all be item level holds.

This method should be used with Hold sets where all
Hold objects share the same patron and record.

This method will return 'item' if the patron has
at least one item level hold. It will return 'record'
if the patron has holds but none are item level,
Finally, if the patron has no holds, it will return
undef which indicateds the patron may select either
record or item level holds, barring any other rules
that would prevent one or the other.

=cut

sub forced_hold_level {
    my ($self) = @_;

    return $self->search( { itemnumber => { '!=' => undef } } )->count()
      ? 'item'
      : 'record';
}

=head3 type

=cut

sub _type {
    return 'Reserve';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Hold';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
