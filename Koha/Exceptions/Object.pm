package Koha::Exceptions::Object;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Object' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Object::MethodNotFound' => {
        isa => 'Koha::Exceptions::Object',
        description => "Invalid method",
    },
    'Koha::Exceptions::Object::PropertyNotFound' => {
        isa => 'Koha::Exceptions::Object',
        description => "Invalid property",
    }
);

1;
