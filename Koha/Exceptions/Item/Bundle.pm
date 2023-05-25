package Koha::Exceptions::Item::Bundle;

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

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Item::Bundle' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Item::Bundle::IsBundle' => {
        isa         => 'Koha::Exceptions::Item::Bundle',
        description => "A bundle cannot be added to a bundle",
    },
    'Koha::Exceptions::Item::Bundle::BundleIsCheckedOut' => {
        isa         => 'Koha::Exceptions::Item::Bundle',
        description => 'Someone tried to add an item to a checked out bundle',
    },
    'Koha::Exceptions::Item::Bundle::ItemIsCheckedOut' => {
        isa         => 'Koha::Exceptions::Item::Bundle',
        description => 'Someone tried to add a checked out item to a bundle',
    },
);

=head1 NAME

Koha::Exceptions::Item::Bundle - Base class for Bundle exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Item::Bundle

Generic Item::Bundle exception

=head2 Koha::Exceptions::Item::Bundle::IsBundle

Exception to be used when attempting to add one bundle into another.

=head2 Koha::Exceptions::Item::Bundle::ItemIsCheckedOut

Exception to be used when attempting to add a checked out item to a bundle.

=cut

1;
