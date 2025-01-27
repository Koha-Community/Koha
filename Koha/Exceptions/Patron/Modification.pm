package Koha::Exceptions::Patron::Modification;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Patron::Modification' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Patron::Modification::DuplicateVerificationToken' => {
        isa         => 'Koha::Exceptions::Patron::Modification',
        description => "The verification token given already exists"
    },
    'Koha::Exceptions::Patron::Modification::InvalidData' => {
        isa         => 'Koha::Exceptions::Patron::Modification',
        description => "Some passed data is invalid"
    }
);

1;
