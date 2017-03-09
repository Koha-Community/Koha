package Koha::Exception::SubroutineCall;

# Copyright 2016 Koha-Suomi Oy
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SubroutineCall' => {
        isa => 'Koha::Exception',
        description => 'Subroutine is called wrongly',
    },
);

return 1;
