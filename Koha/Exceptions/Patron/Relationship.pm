package Koha::Exceptions::Patron::Relationship;

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

use Exception::Class (

    'Koha::Exceptions::Patron::Relationship' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Patron::Relationship::DuplicateRelationship' => {
        isa         => 'Koha::Exceptions::Patron::Relationship',
        description => 'There can only be one relationship between patrons in a direction',
        fields      => [ 'guarantor_id', 'guarantee_id' ]
    },
    'Koha::Exceptions::Patron::Relationship::InvalidRelationship' => {
        isa         => 'Koha::Exceptions::Patron::Relationship',
        description => 'The specified relationship is invalid',
        fields      =>  ['relationship','no_relationship']
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ( $msg) {
        if ( $self->isa('Koha::Exceptions::Patron::Relationship::InvalidRelationship') ) {
            if ( $self->no_relationship ) {
                $msg = sprintf( "No relationship passed." );
            }
            else {
                $msg = sprintf("Invalid relationship passed, '%s' is not defined.", $self->relationship );
            }
        }
        elsif ( $self->isa('Koha::Exceptions::Patron::Relationship::DuplicateRelationship') ) {
            $msg
                = sprintf(
                "There already exists a relationship for the same guarantor (%s) and guarantee (%s) combination",
                $self->guarantor_id, $self->guarantee_id );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Patron::Relationship - Base class for patron relatioship exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Patron::Relationship

Generic Patron exception

=head2 Koha::Exceptions::Patron::Relationship::DuplicateRelationship

Exception to be used when more than one relationship is requested for a
pair of patrons in the same direction.

=head2 Koha::Exceptions::Patron::Relationship::InvalidRelationship

Exception to be used when an invalid relationship is passed.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
