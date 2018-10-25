package Koha::Exceptions::Patron;

use Modern::Perl;

use Exception::Class (
    'Koha::Exceptions::Patron' => {
        description => "Something went wrong!"
    },
    'Koha::Exceptions::Patron::FailedDelete' => {
        description => "Deleting patron failed"
    },
);

1;
