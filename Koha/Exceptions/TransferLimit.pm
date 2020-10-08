package Koha::Exceptions::TransferLimit;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::TransferLimit::Exception' => {
        description => 'Something went wrong!',
    },

    'Koha::Exceptions::TransferLimit::Duplicate' => {
        isa => 'Koha::Exceptions::TransferLimit::Exception',
        description => 'A transfer limit with the given parameters already exists!',
    },
);

1;
