package Koha::Exceptions::Item::Transfer;

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

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Item::Transfer' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Item::Transfer::InQueue' => {
        isa         => 'Koha::Exceptions::Item::Transfer',
        description => "Active item transfer already exists",
        fields      => ['transfer']
    },
    'Koha::Exceptions::Item::Transfer::Limit' => {
        isa         => 'Koha::Exceptions::Item::Transfer',
        description => "Transfer not allowed"
    },
    'Koha::Exceptions::Item::Transfer::OnLoan' => {
        isa         => 'Koha::Exceptions::Item::Transfer',
        description => "Transfer item is currently checked out"
    },
    'Koha::Exceptions::Item::Transfer::InTransit' => {
        isa         => 'Koha::Exceptions::Item::Transfer',
        description => "Transfer item is currently in transit"
    }
);

=head1 NAME

Koha::Exceptions::Item::Transfer - Base class for Transfer exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Item::Transfer

Generic Item::Transfer exception

=head2 Koha::Exceptions::Item::Transfer::InQueue

Exception to be used when an active item transfer prevents a transfer action.

=head2 Koha::Exceptions::Item::Transfer::Limit

Exception to be used when transfer limits prevent a transfer action.

=head2 Koha::Exceptions::Item::Transfer::OnLoan

Exception to be used when an active checkout prevents a transfer action.

=head2 Koha::Exceptions::Item::Transfer::InTransit

Exception to be used when an in transit transfer prevents a transfer action.

=cut

1;
