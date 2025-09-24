package Koha::Template::Plugin::Item;

# Copyright Open Fifth 2025

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

use Template::Plugin;
use base qw( Template::Plugin );

use Koha::Items;

=head1 METHODS

=head2 HasSerialItem

Checks whether a particular item has an associated serial item

=cut

sub HasSerialItem {
    my ( $self, $itemnumber ) = @_;

    my $serial_item = Koha::Items->find($itemnumber)->serial_item;

    return $serial_item ? 1 : 0;
}

1;
