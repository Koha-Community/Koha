package Koha::Exceptions;

use Modern::Perl;

use Exception::Class (

    # General exceptions
    'Koha::Exceptions::Exception' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::BadParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'A bad parameter was given',
        fields => ['parameter'],
    },
    'Koha::Exceptions::DuplicateObject' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Same object already exists',
    },
    'Koha::Exceptions::ObjectNotFound' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'The required object doesn\'t exist',
    },
    'Koha::Exceptions::CannotDeleteDefault' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'The default value cannot be deleted'
    },
    'Koha::Exceptions::MissingParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'A required parameter is missing'
    },
    'Koha::Exceptions::NoChanges' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'No changes were made',
    },
    'Koha::Exceptions::WrongParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'One or more parameters are wrong',
    },
    'Koha::Exceptions::NoPermission' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'You do not have permission for this action',
    },
    'Koha::Exceptions::CannotAddLibraryLimit' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'General problem adding a library limit'
    },
    'Koha::Exceptions::UnderMaintenance' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Koha is under maintenance.'
    },
    # Virtualshelves exceptions
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
