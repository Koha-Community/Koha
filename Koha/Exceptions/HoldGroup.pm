package Koha::Exceptions::HoldGroup;

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
    'Koha::Exceptions::HoldGroup' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::HoldGroup::HoldDoesNotExist' => {
        isa         => 'Koha::Exceptions::HoldGroup',
        description => "One or more holds do not exist",
        fields      => ['hold_ids'],
    },
    'Koha::Exceptions::HoldGroup::HoldDoesNotBelongToPatron' => {
        isa         => 'Koha::Exceptions::HoldGroup',
        description => "One or more holds do not belong to patron",
        fields      => ['hold_ids'],
    },
    'Koha::Exceptions::HoldGroup::HoldHasAlreadyBeenFound' => {
        isa         => 'Koha::Exceptions::HoldGroup',
        description => "One or more holds have already been found",
        fields      => ['barcodes'],
    },
    'Koha::Exceptions::HoldGroup::HoldAlreadyBelongsToHoldGroup' => {
        isa         => 'Koha::Exceptions::HoldGroup',
        description => "One or more holds already belong to a hold group",
        fields      => ['hold_ids'],
    },
);

=head1 NAME

Koha::Exceptions::HoldGroup - Base class for HoldGroup exceptions

=head1 Exceptions

=head2 Koha::Exceptions::HoldGroup

Generic HoldGroup exception

=head2 Koha::Exceptions::HoldGroup::HoldDoesNotExist

Exception to be used when one or more provided holds do not exist.

=cut

1;
