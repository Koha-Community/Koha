package Koha::Exception::SelfService::OpeningHours;

# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use Modern::Perl;

use Exception::Class (
    'Koha::Exception::SelfService::OpeningHours' => {
        isa => 'Koha::Exception::SelfService',
        description => "Self-service resource closed at this time. Possibly outside opening hours or otherwise library has set this resource unavailable at this specific time. Try again alter. Attached time fields in ISO8601.",
        fields => ['startTime', 'endTime'],
    },
);

return 1;
