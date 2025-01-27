package Koha::Exceptions::Virtualshelf;

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

    'Koha::Exceptions::Virtualshelf' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Virtualshelf::DuplicateObject' => {
        isa         => 'Koha::Exceptions::Virtualshelf',
        description => "Duplicate shelf object",
    },
    'Koha::Exceptions::Virtualshelf::InvalidInviteKey' => {
        isa         => 'Koha::Exceptions::Virtualshelf',
        description => 'Invalid key on accepting the share',
    },
    'Koha::Exceptions::Virtualshelf::InvalidKeyOnSharing' => {
        isa         => 'Koha::Exceptions::Virtualshelf',
        description => 'Invalid key on sharing a shelf',
    },
    'Koha::Exceptions::Virtualshelf::ShareHasExpired' => {
        isa         => 'Koha::Exceptions::Virtualshelf',
        description => 'Cannot share this shelf, the share has expired',
    },
    'Koha::Exceptions::Virtualshelf::UseDbAdminAccount' => {
        isa         => 'Koha::Exceptions::Virtualshelf',
        description => "Invalid use of database administrator account",
    }
);

=head1 NAME

Koha::Exceptions::Virtualshelf - Base class for virtualshelf exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Virtualshelf

Generic Virtualshelf exception

=head2 Koha::Exceptions::Virtualshelf::DuplicateObject

Exception to be used when a similar virtual shelf already exists.

=head2 Koha::Exceptions::Virtualshelf::InvalidInviteKey

Exception to be used when an invite key is invalid.

=head2 Koha::Exceptions::Virtualshelf::InvalidKeyOnSharing

Exception to be used when the supplied key is invalid on sharing.

=head2 Koha::Exceptions::Virtualshelf::ShareHasExpired

Exception to be used when a share has expired.

=head2 Koha::Exceptions::Virtualshelf::UseDbAdminAccount

Exception to be used when the owner is not set.

=cut

1;
