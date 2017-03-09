package Koha::Exception::SelfService::Underage;

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SelfService::Underage' => {
        isa => 'Koha::Exception::SelfService',
        description => "The given borrower is too young to access the self-service resource",
        fields => ['minimumAge'],
    },
);

return 1;
