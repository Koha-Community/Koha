package Koha::Exception::SelfService::PermissionRevoked;

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SelfService::PermissionRevoked' => {
        isa => 'Koha::Exception::SelfService',
        description => "The given borrower has got his self-service usage permission revoked",
        fields => ['expirationdate'],
    },
);

return 1;
