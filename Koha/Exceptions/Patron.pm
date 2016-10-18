package Koha::Exceptions::Patron;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Patron::DuplicateObject' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron cardnumber and userid must be unique",
        fields => ["conflict"],
    },
);

1;
