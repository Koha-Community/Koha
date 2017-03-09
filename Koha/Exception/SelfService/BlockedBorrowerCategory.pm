package Koha::Exception::SelfService::BlockedBorrowerCategory;

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SelfService::BlockedBorrowerCategory' => {
        isa => 'Koha::Exception::SelfService',
        description => "The given borrower has an unauthorized borrower category",
    },
);

return 1;
