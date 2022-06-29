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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::Exceptions::XSLT;

=head1 SYNOPSIS

Koha::Exceptions::XSLT::MissingFilename->throw;

=head1 DESCRIPTION

Defines a few exceptions for Koha::XSLT:: modules

=cut

use Modern::Perl;
use Koha::Exception;
use Exception::Class (
    'Koha::Exceptions::XSLT' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::XSLT::MissingFilename' => {
        isa => 'Koha::Exceptions::XSLT',
        description => 'File name required',
    },
    'Koha::Exceptions::XSLT::FetchFailed' => {
        isa => 'Koha::Exceptions::XSLT',
        description => 'Fetching xslt file failed',
    },
);

1;
