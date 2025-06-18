package Koha::Library::Hour;

# Copyright 2021 Aleisha Amohia <aleisha@catalyst.net.nz>
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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Library::Hour - Koha Library Hour Object class

=head1 SYNOPSIS

use Koha::Library::Hour;

=head1 DESCRIPTION

Describes the open time and close time for a library on a given day of the week.

=head1 FUNCTIONS

=head2 Class Methods

=head3 _type

Return type of Object relating to Schema Resultset

=cut

sub _type {
    return 'LibraryHour';
}

1;
