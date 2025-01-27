package Koha::Exceptions::Library;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Library::Exception' => {
        isa => 'Koha::Exception',
    },

    'Koha::Exceptions::Library::NotFound' => {
        isa         => 'Koha::Exceptions::Library::Exception',
        description => 'Library not found',
    },
);

1;
