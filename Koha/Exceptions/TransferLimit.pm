package Koha::Exceptions::TransferLimit;

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

    'Koha::Exceptions::TransferLimit::Exception' => {
        isa => 'Koha::Exception',
    },

    'Koha::Exceptions::TransferLimit::Duplicate' => {
        isa         => 'Koha::Exceptions::TransferLimit::Exception',
        description => 'A transfer limit with the given parameters already exists!',
    },
);

=head1 NAME

Koha::Exceptions::TransferLimit - Base class for transfer limits exceptions

=head1 Exceptions

=head2 Koha::Exceptions::TransferLimit

Generic transfer limit exception

=head2 Koha::Exceptions::TransferLimit::Duplicate

Exception to be used when trying to store an already existing transfer limit.

=cut

1;
