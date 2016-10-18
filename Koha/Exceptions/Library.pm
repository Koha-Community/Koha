package Koha::Exceptions::Library;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Library' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Library::BranchcodeNotFound' => {
        isa => 'Koha::Exceptions::Library',
        description => "Library does not exist",
        fields => ["branchcode"],
    },
);

1;
