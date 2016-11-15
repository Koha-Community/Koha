package Koha::Exceptions::ItemType;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::ItemType' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::ItemType::NotForLoan' => {
        isa => 'Koha::Exceptions::ItemType',
        description => "This type of items are not for loan.",
        fields => ["itemtype", "status", "code"],
    },

);

1;
