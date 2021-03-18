package Koha::Exceptions::Patron::MessagePreference;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron::MessagePreference' => {
        description => 'Something went wrong'
    },
    'Koha::Exceptions::Patron::MessagePreference::AttributeNotFound' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Message attribute not found",
        fields => ['message_attribute_id']
    },
    'Koha::Exceptions::Patron::MessagePreference::DaysInAdvanceOutOfRange' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Days in advance is out of range",
        fields => ['min','max', 'message_name']
    },
    'Koha::Exceptions::Patron::MessagePreference::DaysInAdvanceNotAvailable' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Days in advance cannot be selected for this preference",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::MessagePreference::DigestNotAvailable' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Digest is not available for this message type",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::MessagePreference::DigestRequired' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Digest must be selected for this message type",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::MessagePreference::EmailAddressRequired' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Patron has no email address, cannot use email transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
    'Koha::Exceptions::Patron::MessagePreference::NoTransportType' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Transport type not available for this message.",
        fields => ['message_name', 'transport_type']
    },
    'Koha::Exceptions::Patron::MessagePreference::PhoneNumberRequired' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Patron has no phone number, cannot use phone transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
    'Koha::Exceptions::Patron::MessagePreference::SMSNumberRequired' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "Patron has no SMS number, cannot use sms transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
    'Koha::Exceptions::Patron::MessagePreference::TalkingTechItivaPhoneNotificationRequired' => {
        isa => 'Koha::Exceptions::Patron::MessagePreference',
        description => "System preference TalkingTechItivaPhoneNotification is disabled, cannot use itiva transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
);

1;
