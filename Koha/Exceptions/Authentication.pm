package Koha::Exceptions::Authentication;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Authentication' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Authentication::Required' => {
        isa => 'Koha::Exceptions::Authentication',
        description => 'Authentication required'
    },
    'Koha::Exceptions::Authentication::SessionExpired' => {
        isa => 'Koha::Exceptions::Authentication',
        description => 'Session has been expired',
    },

);

1;
