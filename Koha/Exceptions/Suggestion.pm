package Koha::Exceptions::Suggestion;

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
    'Koha::Exceptions::Suggestion' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Suggestion::StatusForbidden' => {
        isa         => 'Koha::Exceptions::Suggestion',
        description => 'This status is forbidden, check authorised values "SUGGEST"',
        fields      => ['STATUS']
    }
);

=head1 NAME

Koha::Exceptions::Suggestion - Base class for Suggestion exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Suggestion

Generic Suggestion exception

=head2 Koha::Exceptions::Suggestion::StatusIsUnknown

Exception to be used when a purchase suggestion tries to be saved and the status doesn't belong to the list of authorised_values.

=cut

1;
