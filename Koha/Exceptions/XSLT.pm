package Koha::Exceptions::XSLT;

# Copyright 2022 Rijksmuseum, Koha Development Team
#
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
    'Koha::Exceptions::XSLT' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::XSLT::MissingFilename' => {
        isa         => 'Koha::Exceptions::XSLT',
        description => 'File name required',
    },
    'Koha::Exceptions::XSLT::FetchFailed' => {
        isa         => 'Koha::Exceptions::XSLT',
        description => 'Fetching xslt file failed',
    },
);

=head1 NAME

Koha::Exceptions::XSLT - Base class for XSLT exceptions

=head1 DESCRIPTION

Defines a few exceptions for Koha::XSLT:: modules

=head1 Exceptions

=head2 Koha::Exceptions::XSLT

Generic XSLT exception.

=head2 Koha::Exceptions::XSLT::MissingFilename

Missing filename exception.

=head2 Koha::Exceptions::XSLT::FetchFailed

Failed to fetch the XSLT.

=cut

1;
