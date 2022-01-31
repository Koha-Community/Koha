package Koha::Exceptions::Acquisition::Basket;

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

    'Koha::Exceptions::Acquisition::Basket' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Acquisition::Basket::AlreadyClosed' => {
        isa         => 'Koha::Exceptions::Acquisition::Basket',
        description => 'Basket is already closed'
    }
);

=head1 NAME

Koha::Exceptions::Acquisition::Basket - Base class for Basket exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Acquisition::Basket

Generic Nasket exception

=head2 Koha::Exceptions::Acquisition::Basket::AlreadyClosed

Exception to be used when an already closed basket is asked to be closed.

=cut

1;
