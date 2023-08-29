package Koha::Exceptions::ERM::EUsage::CounterFile;

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

    'Koha::Exceptions::ERM::EUsage::CounterFile' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::ERM::EUsage::CounterFile::UnsupportedRelease' => {
        isa         => 'Koha::Exceptions::ERM::EUsage::CounterFile',
        description => 'This COUNTER release is not supported'
    }
);

=head1 NAME

Koha::Exceptions::ERM::EUsage::CounterFile - Base class for CounterFile exceptions

=head1 Exceptions


=head2 Koha::Exceptions::ERM::EUsage::CounterFile

Generic CounterFile exception

=head2 Koha::Exceptions::ERM::EUsage::CounterFile::UnsupportedRelease

Exception to be used when a report is submit with an unsupported COUNTER release

=cut

1;
