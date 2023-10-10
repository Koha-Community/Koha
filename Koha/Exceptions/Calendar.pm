package Koha::Exceptions::Calendar;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Calendar' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Calendar::NoOpenDays' => {
        isa         => 'Koha::Exceptions::Calendar',
        description => 'Library has no open days',
    },
);

1;
