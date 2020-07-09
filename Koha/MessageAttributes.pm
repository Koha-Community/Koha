package Koha::MessageAttributes;

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

use Carp;

use base qw(Koha::Objects);

=head1 NAME

Koha::MessageAttributes - Koha MessageAttributes Object set class

=head1 API

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'MessageAttribute';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::MessageAttribute';
}

1;
