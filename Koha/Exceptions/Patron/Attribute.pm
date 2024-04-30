package Koha::Exceptions::Patron::Attribute;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Patron::Attribute' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Patron::Attribute::InvalidType' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "the passed type is invalid",
        fields      => ["type"]
    },
    'Koha::Exceptions::Patron::Attribute::NonRepeatable' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "repeatable not set for attribute type and tried to add a new attribute for the same code",
        fields      => ["attribute"]
    },
    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "unique_id set for attribute type and tried to add a new with the same code and value",
        fields      => ["attribute"]
    },
    'Koha::Exceptions::Patron::Attribute::InvalidAttributeValue' => {
        isa         => 'Koha::Exceptions::Patron::Attribute',
        description => "the passed value is invalid for attribute type",
        fields      => ["attribute"]
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') ) {
            $msg = sprintf(
                "Tried to add more than one non-repeatable attributes. type=%s value=%s",
                $self->attribute->code,
                $self->attribute->attribute
            );
        } elsif ( $self->isa('Koha::Exceptions::Patron::Attribute::UniqueIDConstraint') ) {
            $msg = sprintf(
                "Your action breaks a unique constraint on the attribute. type=%s value=%s",
                $self->attribute->code,
                $self->attribute->attribute
            );
        } elsif ( $self->isa('Koha::Exceptions::Patron::Attribute::InvalidType') ) {
            $msg = sprintf(
                "Tried to use an invalid attribute type. type=%s",
                $self->type
            );
        } elsif ( $self->isa('Koha::Exceptions::Patron::Attribute::InvalidAttributeValue') ) {
            $msg = sprintf(
                "Tried to use an invalid value for attribute type. type=%s value=%s",
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
