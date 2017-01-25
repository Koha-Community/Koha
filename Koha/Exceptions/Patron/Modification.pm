package Koha::Exceptions::Patron::Modification;

use Modern::Perl;

use Exception::Class (
    'Koha::Exceptions::Koha::Patron::Modification::DuplicateVerificationToken' => {
        isa => 'Koha::Exceptions::Object',
        description => "The verification token given already exists",
    },
);

1;
