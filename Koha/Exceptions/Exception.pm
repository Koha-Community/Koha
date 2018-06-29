package Koha::Exceptions::Exception;

use Modern::Perl;

# Looks like this class should be more Koha::Exception::Base;
use Exception::Class (
    'Koha::Exceptions::Exception' => {
        description => "Something went wrong!"
    },
);

1;
