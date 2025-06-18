package Koha::Exceptions::Object;

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

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Object' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Object::DuplicateID' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Duplicate ID passed",
        fields      => ['duplicate_id']
    },
    'Koha::Exceptions::Object::FKConstraint' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Foreign key constraint broken",
        fields      => [ 'broken_fk', 'value' ],
    },
    'Koha::Exceptions::Object::FKConstraintDeletion' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Foreign key constraint broken on deleting resource",
        fields      => [ 'column', 'fk', 'table', 'constraint' ],
    },
    'Koha::Exceptions::Object::MethodNotFound' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Invalid method",
    },
    'Koha::Exceptions::Object::PropertyNotFound' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Invalid property",
    },
    'Koha::Exceptions::Object::ReadOnlyProperty' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Change of readonly property attempted",
        fields      => ['property'],
    },
    'Koha::Exceptions::Object::MethodNotCoveredByTests' => {
        isa         => 'Koha::Exceptions::Object',
        description => "Method not covered by tests",
    },
    'Koha::Exceptions::Object::BadValue' => {
        isa         => 'Koha::Exceptions::Object',
        description => 'Invalid data passed',
        fields      => [ 'type', 'property', 'value' ],
    },
    'Koha::Exceptions::Object::NotInstantiated' => {
        isa         => 'Koha::Exceptions::Object',
        description => 'Tried to access a method on an uninstantiated object',
        fields      => [ 'class', 'method' ]
    },
    'Koha::Exceptions::Object::NotInStorage' => {
        isa         => 'Koha::Exceptions::Object',
        description => 'The object is not in storage yet',
    },
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Object::FKConstraint') ) {
            $msg = sprintf( "Invalid parameter passed, %s=%s does not exist", $self->broken_fk, $self->value );
        } elsif ( $self->isa('Koha::Exceptions::Object::BadValue') ) {
            $msg = sprintf(
                "Invalid value passed, %s=%s expected type is %s", $self->property, $self->value,
                $self->type
            );
        } elsif ( $self->isa('Koha::Exceptions::Object::ReadOnlyProperty') ) {
            $msg = sprintf( "Invalid attempt to change readonly property: %s", $self->property );
        } elsif ( $self->isa('Koha::Exceptions::Object::NotInstantiated') ) {
            $msg =
                sprintf( "Tried to access the '%s' method, but %s is not instantiated", $self->method, $self->class );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Object - Base class for Object exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Object

Generic Object exception

=head2 Koha::Exceptions::Object::DuplicateID

Exception to be used when a duplicate ID is passed.

=head2 Koha::Exceptions::Object::FKConstraint

Exception to be used when a foreign key constraint is broken.

=head2 Koha::Exceptions::Object::MethodNotFound

Exception to be used when an invalid class method has been invoked.

=head2 Koha::Exceptions::Object::PropertyNotFound

Exception to be used when an invalid object property has been requested.

=head2 Koha::Exceptions::Object::MethodNotCoveredByTests

Exception to be used when the invoked method is not covered by tests.

=head2 Koha::Exceptions::Object::BadValue

Exception to be used when a bad value has been passed for a property.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
