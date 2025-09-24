package Koha::HoldGroups;

# Copyright Koha Development team 2020
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

use Koha::Database;

use Koha::HoldGroup;

use base qw(Koha::Objects);

=head1 NAME

Koha::HoldGroups - Koha Hold Group object set class

=head1 API

=head2 Class Methods

=cut

=head3 _type

=cut

sub _type {
    return 'HoldGroup';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::HoldGroup';
}

=head1 AUTHOR

Josef Moravec <josef.moravec@gmail.com>

=cut

1;
