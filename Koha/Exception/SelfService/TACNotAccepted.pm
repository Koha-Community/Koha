package Koha::Exception::SelfService::TACNotAccepted;

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SelfService::TACNotAccepted' => {
        isa => 'Koha::Exception::SelfService',
        description => "Self-Service terms and conditions has not been accepted by the user in the OPAC",
    },
);

return 1;
