package Koha::Exceptions::Auth;

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
    'Koha::Exceptions::Auth' => {
        isa    => 'Koha::Exception',
        fields => ['code']
    },
    'Koha::Exceptions::Auth::NoValidDomain' => {
        isa         => 'Koha::Exceptions::Auth',
        description => 'No valid domain found'
    },
    'Koha::Exceptions::Auth::Unauthorized' => {
        isa         => 'Koha::Exceptions::Auth',
        description => 'External auth user cannot access resource'
    },
    'Koha::Exceptions::Auth::CannotCreateSession' => {
        isa         => 'Koha::Exceptions::Auth',
        description => 'Cannot create session'
    },
);

1;
