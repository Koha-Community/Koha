package Koha::Library::Hours;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::Library::Hour;

use base qw(Koha::Objects);

=head1 NAME

Koha::Library::Hours - Koha Library Hours Object set class

=head1 API

=head2 Class Methods

=cut

=head3 _type

Return type of object, relating to Schema Resultset

=cut

sub _type {
    return 'LibraryHour';
}

=head3 object_class

Return object class

=cut

sub object_class {
    return 'Koha::Library::Hour';
}

1;
