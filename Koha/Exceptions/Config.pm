package Koha::Exceptions::Config;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Config' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Config::MissingEntry' => {
        isa         => 'Koha::Exceptions::Config',
        description => 'The required entry is missing in the configuration file'
    }
);

1;
