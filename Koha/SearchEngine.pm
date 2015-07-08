package Koha::SearchEngine;
# This handles generic search-engine related functions

# Copyright 2015 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Readonly;

=head1 NAME

Koha::SearchEngine - non-engine-specific data and functions

=head1 VARIABLES / CONSTANTS

=head2 BIBLIOS_INDEX

Use this constant when creating a new L<Koha::SearchEngine::Search> instance
to indicate that you want to be working with the biblio index.

=head2 AUTHORITIES_INDEX

Use this constant when creating a new L<Koha::SearchEngine::Search> instance to
indicate that you want to be working with the authorities index.

=cut

# Search engine implementations should compare against these to determine
# what bit of storage is being requested. They will be sensible strings so
# may be used for, e.g., directory names.
Readonly our $BIBLIOS_INDEX     => 'biblios';
Readonly our $AUTHORITIES_INDEX => 'authorities';
