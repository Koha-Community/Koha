package Koha::Exceptions::Patron::Attribute;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron::Attribute' => {
        description => 'Something went wrong'
    },
    'Koha::Exceptions::Patron::Attribute::NonRepeatable' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "repeatable not set for attribute type and tried to add a new attribute for the same code",
        fields      => [ "attribute" ]
    },
    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "unique_id set for attribute type and tried to add a new with the same code and value",
        fields      => [ "attribute" ]
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ( $msg) {
        if ( $self->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') ) {
            $msg = sprintf(
                "Tried to add more than one non-repeatable attributes. code=%s attribute=%s",
                $self->attribute->code,
                $self->attribute->attribute
            );
        }
        elsif ( $self->isa('Koha::Exceptions::Patron::Attribute::UniqueIDConstraint') ) {
            $msg = sprintf(
                "Your action breaks a unique constraint on the attribute. code=%s attribute=%s",
                $self->attribute->code,
                $self->attribute->attribute
            );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Patron::Attribute - Base class for patron attribute exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Patron::Attribute

Generic patron attribute exception

=head2 Koha::Exceptions::Patron::Attribute::NonRepeatable

Exception to be used trying to add more than one non-repeatable attribute.

=head2 Koha::Exceptions::Patron::Attribute::UniqueIDConstraint

Exception to be used when trying to add an attribute that breaks its type unique constraint.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
