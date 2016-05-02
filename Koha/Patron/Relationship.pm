package Koha::Patron::Relationship;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Relationship - A class to represent relationships between patrons

Patrons in Koha may be guarantors or guarantees. This class models that relationship
and provides a way to access those relationships.

=head1 API

=head2 Class Methods

=cut

=head3 guarantor

Returns the Koha::Patron object for the guarantor, if there is one

=cut

sub guarantor {
    my ( $self ) = @_;

    return unless $self->guarantor_id;

    return scalar Koha::Patrons->find( $self->guarantor_id );
}

=head3 guarantee

Returns the Koha::Patron object for the guarantee

=cut

sub guarantee {
    my ( $self ) = @_;

    return scalar Koha::Patrons->find( $self->guarantee_id );
}

=head3 type

=cut

sub _type {
    return 'BorrowerRelationship';
}

1;
