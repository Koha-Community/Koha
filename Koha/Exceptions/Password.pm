package Koha::Exceptions::Password;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Password' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Password::Invalid' => {
        isa => 'Koha::Exceptions::Password',
        description => 'Invalid password',
    },
    'Koha::Exceptions::Password::TooShort' => {
        isa => 'Koha::Exceptions::Password',
        description => 'Password is too short',
    },
    'Koha::Exceptions::Password::TrailingWhitespaces' => {
        isa => 'Koha::Exceptions::Password',
        description => 'Password contains trailing whitespace(s)',
    }
);

1;
