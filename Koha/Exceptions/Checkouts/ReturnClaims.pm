package Koha::Exceptions::Checkouts::ReturnClaims;

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
    'Koha::Exceptions::Checkouts::ReturnClaims' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Checkouts::ReturnClaims::NoCreatedBy' => {
        isa         => 'Koha::Exceptions::Checkouts::ReturnClaims',
        description => 'created_by is mandatory'
    },
);

=head1 NAME

Koha::Exceptions::Checkouts - Base class for Checkouts exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Checkouts::ReturnClaims

Generic return claim exception

=head2 Koha::Exceptions::Checkouts::ReturnClaims::NoCreatedBy

Exception to be used when a return claim is requested to be store but
the 'created_by' param is not passed.

=cut

1;
