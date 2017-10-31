package Koha::Exceptions::Config;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Config' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Config::MissingEntry' => {
        isa => 'Koha::Exceptions::Config',
        description => 'The required entry is missing in the configuration file'
    }
);

1;
