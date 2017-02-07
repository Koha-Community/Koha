package Koha::Exceptions::Library;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Library::Exception' => {
        description => 'Something went wrong!',
    },

    'Koha::Exceptions::Library::NotFound' => {
        isa => 'Koha::Exceptions::Library::Exception',
        description => 'Library not found',
    },
);

1;
