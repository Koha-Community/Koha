package Koha::Exceptions::SysPref;

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
    'Koha::Exceptions::SysPref' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::SysPref::NotSet' => {
        isa         => 'Koha::Exceptions::SysPref',
        description => 'Required syspref is not set',
        fields      => ['syspref']
    }
);

=head1 NAME

Koha::Exceptions::SysPref - Base class for syspref-related exceptions

=head1 Exceptions

=head2 Koha::Exceptions::SysPref

Generic syspref-related exception

=head2 Koha::Exceptions::SysPref::NotSet

Exception to be used when a required syspref is not set.

=cut

1;
