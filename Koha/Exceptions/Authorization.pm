package Koha::Exceptions::Authorization;

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (

    'Koha::Exceptions::Authorization' => {
        isa => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::Authorization::Unauthorized' => {
        isa => 'Koha::Exceptions::Authorization',
        description => 'Unauthorized',
        fields => ['required_permissions']
    },

);

1;
