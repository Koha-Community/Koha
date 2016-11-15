package Koha::Exceptions::Biblio;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Biblio' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Biblio::AnotherItemCheckedOut' => {
        isa => 'Koha::Exceptions::Biblio',
        description => "Another item from same biblio already checked out.",
        fields => ["itemnumbers"],
    },
    'Koha::Exceptions::Biblio::CheckedOut' => {
        isa => 'Koha::Exceptions::Biblio',
        description => "Biblio is already checked out for patron.",
        fields => ['biblionumber'],
    },
    'Koha::Exceptions::Biblio::NoAvailableItems' => {
        isa => 'Koha::Exceptions::Biblio',
        description => "Biblio does not have any available items.",
    },
    'Koha::Exceptions::Biblio::NotFound' => {
        isa => 'Koha::Exceptions::Biblio',
        description => "Biblio not found.",
        fields => ['biblionumber'],
    },

);

1;
