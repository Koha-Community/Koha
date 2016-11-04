package Koha::Exceptions::Patron::Modification;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron::Modification' => {
        description => 'Something went wrong'
    },
    'Koha::Exceptions::Patron::Modification::DuplicateVerificationToken' => {
        isa => 'Koha::Exceptions::Patron::Modification',
        description => "The verification token given already exists"
    }
);

1;
