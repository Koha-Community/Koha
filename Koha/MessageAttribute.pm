package Koha::MessageAttribute;

# Copyright PTFS Europe 2020
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

use Modern::Perl;

use Carp;

use base qw(Koha::Object);

=head1 NAME

Koha::MessageAttribute - Koha MessageAttribute Object class

=head1 API

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'MessageAttribute';
}

1;
