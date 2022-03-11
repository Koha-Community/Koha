package Koha::Exceptions::Checkouts::Renewals;

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
    'Koha::Exceptions::Checkouts::Renewals' => {
        isa         => 'Koha::Exception',
    },
    'Koha::Exceptions::Checkouts::Renewals::NoRenewerID' => {
        isa         => 'Koha::Exceptions::Checkouts::Renewals',
        description => 'renewer_id is mandatory'
    },
);

=head1 NAME

Koha::Exceptions::Checkouts - Base class for Checkouts exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Checkouts::Renewals

Generic return claim exception

=head2 Koha::Exceptions::Checkouts::Renewals::NoRenewerID

Exception to be used when a renewal is requested to be store but
the 'renewer_id' param is not passed.

=cut

1;
