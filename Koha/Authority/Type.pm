package Koha::Authority::Type;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Authority::Type - Koha Authority Type Object class

=head1 API

=head2 Class Methods

=cut

=head2 auth_tag_structures

Missing POD for auth_tag_structures.

=cut

sub auth_tag_structures {
    my ($self) = @_;
    return $self->_result->auth_tag_structures;
}

=head3 type

=cut

sub _type {
    return 'AuthType';
}

1;
