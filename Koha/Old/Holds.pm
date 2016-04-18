package Koha::Old::Holds;

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

use Koha::Old::Hold;

use base qw(Koha::Holds);

=head1 NAME

Koha::Old::Holds - Koha Old Hold object set class

This object represents a set of holds that have been filled or canceled

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'OldReserve';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Old::Hold';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
