package Koha::Exceptions::Ill;

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

    'Koha::Exceptions::Ill' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Ill::InvalidBackendId' => {
        isa         => 'Koha::Exceptions::Ill',
        description => "Invalid backend name required",
    },
    'Koha::Exceptions::Ill::NoTargetEmail' => {
        isa         => 'Koha::Exceptions::Ill',
        description => "ILL partner library has no email address configured",
    },
    'Koha::Exceptions::Ill::NoLibraryEmail' => {
        isa         => 'Koha::Exceptions::Ill',
        description => "Invalid backend name required",
    }
);

=head1 NAME

Koha::Exceptions::Ill - Base class for ILL exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Ill

Generic Ill exception

=head2 Koha::Exceptions::Ill::InvalidBackend

Exception to be used when the required ILL backend is invalid.

=head2 Koha::Exceptions::Ill::NoTargetEmail

Exception to be used when the ILL partner has no email address set.

=head2 Koha::Exceptions::Ill::NoLibraryEmail

Exception to be used when the current library has no email address set.

=cut

1;
