package Koha::Exceptions::ClubHold;

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (
    'Koha::Exceptions::ClubHold' => {
        isa => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::ClubHold::NoPatrons' => {
        isa => 'Koha::Exceptions::ClubHold',
        description => "Cannot place a hold on a club without patrons.",
    },
);

1;
