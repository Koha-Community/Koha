package Koha::Exceptions::Library;

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (

    'Koha::Exceptions::Library::Exception' => {
        isa => 'Koha::Exceptions::Exception',
    },

    'Koha::Exceptions::Library::NotFound' => {
        isa => 'Koha::Exceptions::Library::Exception',
        description => 'Library not found',
    },
);

1;
