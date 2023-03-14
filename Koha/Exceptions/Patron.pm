package Koha::Exceptions::Patron;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Patron' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Patron::MissingEmailAddress' => {
        description => "Patron has no email address",
    },
    'Koha::Exceptions::Patron::FailedDelete' => {
        isa         => 'Koha::Exceptions::Patron',
        description => "Deleting patron failed"
    },
    'Koha::Exceptions::Patron::FailedAnonymizing' => {
        isa         => 'Koha::Exceptions::Patron',
        description => "Anonymizing patron reading history failed"
    },
    'Koha::Exceptions::Patron::FailedDeleteAnonymousPatron' => {
        isa         => 'Koha::Exceptions::Patron',
        description => "Deleting patron failed, AnonymousPatron is not deleteable"
    },
    'Koha::Exceptions::Patron::InvalidUserid' => {
        isa         => 'Koha::Exceptions::Patron',
        description => 'Field userid is not valid (probably not unique)',
        fields      => [ 'userid' ],
    },
    'Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute' => {
        isa         => 'Koha::Exceptions::Patron',
        description => "Mandatory extended attribute missing",
        fields      => ['type']
    }
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ( $msg) {
        if ( $self->isa('Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute') ) {
            $msg = sprintf("Missing mandatory extended attribute (type=%s)", $self->type );
        }
    }

    return $msg;
}

=head1 NAME

Koha::Exceptions::Patron - Base class for patron exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Patron

Generic patron exception.

=head2 Koha::Exceptions::Patron::FailedDelete

Deleting patron failed.

=head2 Koha::Exceptions::Patron::FailedDeleteAnonymousPatron

Tried to delete the anonymous patron.

=head2 Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute

A required mandatory extended attribute is missing.

=head1 Class methods

=head2 full_message

Overloaded method for exception stringifying.

=cut

1;
