package Koha::Exceptions::Patron::Attribute::Type;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Patron::Attribute::Type' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Patron::Attribute::Type::CannotChangeProperty' => {
        isa         => 'Koha::Exceptions::Patron::Attribute::Type',
        description => "Cannot change property",
        fields      => ['property'],
    },
);

sub full_message {
    my $self = shift;

    my $msg = $self->message;

    unless ($msg) {
        if ( $self->isa('Koha::Exceptions::Patron::Attribute::Type::CannotChangeProperty') ) {
            $msg = sprintf(
                "The property '%s' cannot be changed, some patron attributes are using it that way.",
                $self->property
            );
        }
    }

    return $msg;
}

1;
