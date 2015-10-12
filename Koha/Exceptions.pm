package Koha::Exceptions;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Exception' => {
        description => 'Something went wrong!',
    },

    'Koha::Exceptions::DuplicateObject' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Same object already exists',
    },

    'Koha::Exceptions::Virtualshelves::DuplicateObject' => {
        isa => 'Koha::Exceptions::DuplicateObject',
        description => "Duplicate shelf object",
    },
    'Koha::Exceptions::Virtualshelves::InvalidInviteKey' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Invalid key on accepting the share',
    },
    'Koha::Exceptions::Virtualshelves::InvalidKeyOnSharing' => {
        isa => 'Koha::Exceptions::Exception',
        description=> 'Invalid key on sharing a shelf',
    },
    'Koha::Exceptions::Virtualshelves::ShareHasExpired' => {
        isa => 'Koha::Exceptions::Exception',
        description=> 'Cannot share this shelf, the share has expired',
    },
    'Koha::Exceptions::Virtualshelves::UseDbAdminAccount' => {
        isa => 'Koha::Exceptions::Exception',
        description => "Invalid use of database administrator account",
    }
);

1;
