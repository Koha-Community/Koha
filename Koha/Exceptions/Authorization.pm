package Koha::Exceptions::Authorization;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Authorization' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Authorization::Unauthorized' => {
        isa => 'Koha::Exceptions::Authorization',
        description => 'Unauthorized',
        fields => ['required_permissions']
    },

);

1;
