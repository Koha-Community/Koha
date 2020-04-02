package Koha::Exceptions::ClubHold;

use Modern::Perl;

use Exception::Class (
    'Koha::Exceptions::ClubHold' => {
        description => "Something went wrong!",
    },
    'Koha::Exceptions::ClubHold::NoPatrons' => {
        isa => 'Koha::Exceptions::ClubHold',
        description => "Cannot place a hold on a club without patrons.",
    },
);

1;
