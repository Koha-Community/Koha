package Koha::Exceptions::Notice;

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

    'Koha::Exceptions::Notice' => {
        isa => 'Koha::Exception',
    },

    'Koha::Exceptions::Notice::CannotConvertToPrint' => {
        isa         => 'Koha::Exceptions::Notice',
        description => 'The notice cannot be converted to a print notice',
    },

    'Koha::Exceptions::Notice::NoConversionTemplate' => {
        isa         => 'Koha::Exceptions::Notice',
        description => 'There is no notice to convert a notice to a print notice (CONVERTED_TO_PRINT)',
    },

    'Koha::Exceptions::Notice::ConversionTemplateError' => {
        isa         => 'Koha::Exceptions::Notice',
        description => 'The notice to convert a notice to a print notice (CONVERTED_TO_PRINT) has an error',
    },
);

=head1 NAME

Koha::Exceptions::Notice - Base class for notice exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Notice

Generic notice exception

=head2 Koha::Exceptions::Notice::CannotConvertToPrint

Exception to be used when a notice cannot be converted to a print notice

=head2 Koha::Exceptions::Notice::NoConversionTemplate

Exception to be used when the notice used to convert a notice to a print notice does not exist

=head2 Koha::Exceptions::Notice::ConversionTemplateError

Exception to be used when the notice used to convert a notice to a print notice cannot be processed,
for example because of an error in its template. The error is in I<error>.

=cut

1;
