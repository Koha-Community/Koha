package Koha::Exceptions::Exception;

use Modern::Perl;

# Looks like this class should be more Koha::Exception::Base;
use Exception::Class (
    'Koha::Exceptions::Exception' => {
        description => "Something went wrong!"
    },
);

# We want to overload it to have a stringification method for our exceptions
sub full_message {
    my $self = shift;

    my $msg = $self->message;

    if ( $self->isa('Koha::Exceptions::Object::FKConstraint') ) {
        $msg = sprintf("Invalid parameter passed, %s=%s does not exist", $self->broken_fk, $self->value );
    }

    return $msg;
}

1;
