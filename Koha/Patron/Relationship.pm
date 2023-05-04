package Koha::Patron::Relationship;

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

use List::MoreUtils qw( any );
use Try::Tiny qw( catch try );

use Koha::Database;
use Koha::Exceptions::Patron::Relationship;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Relationship - A class to represent relationships between patrons

Patrons in Koha may be guarantors or guarantees. This class models that relationship
and provides a way to access those relationships.

=head1 API

=head2 Class methods

=cut

=head3 store

Overloaded method that makes some checks before storing on the DB

=cut

sub store {
    my ( $self ) = @_;

    my @valid_relationships = split /\|/, C4::Context->preference('borrowerRelationship'), -1;
    @valid_relationships = ('') unless @valid_relationships;

    Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw(
        no_relationship => 1 )
        unless defined $self->relationship;

    Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw(
        relationship => $self->relationship )
        unless any { $_ eq $self->relationship } @valid_relationships;

    return try {
        $self->SUPER::store;
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::Object::DuplicateID' ) {
            Koha::Exceptions::Patron::Relationship::DuplicateRelationship->throw(
                guarantee_id => $self->guarantee_id,
                guarantor_id => $self->guarantor_id
            );
        }
    };
}

=head3 guarantor

Returns the Koha::Patron object for the guarantor

=cut

sub guarantor {
    my ( $self ) = @_;
    return Koha::Patrons->find( $self->guarantor_id );
}

=head3 guarantee

Returns the Koha::Patron object for the guarantee

=cut

sub guarantee {
    my ( $self ) = @_;
    return Koha::Patrons->find( $self->guarantee_id );
}

=head3 type

=cut

sub _type {
    return 'BorrowerRelationship';
}

1;
