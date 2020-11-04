package Koha::Exceptions::Patron::Message::Preference;

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

    'Koha::Exceptions::Patron::Message::Preference' => {
        description => 'Something went wrong'
    },
    'Koha::Exceptions::Patron::Message::Preference::AttributeNotFound' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Message attribute not found",
        fields => ['message_attribute_id']
    },
    'Koha::Exceptions::Patron::Message::Preference::DaysInAdvanceOutOfRange' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Days in advance is out of range",
        fields => ['min','max', 'message_name']
    },
    'Koha::Exceptions::Patron::Message::Preference::DaysInAdvanceNotAvailable' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Days in advance cannot be selected for this preference",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::Message::Preference::DigestNotAvailable' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Digest is not available for this message type",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::Message::Preference::DigestRequired' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Digest must be selected for this message type",
        fields => ['message_name']
    },
    'Koha::Exceptions::Patron::Message::Preference::EmailAddressRequired' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Patron has no email address, cannot use email transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
    'Koha::Exceptions::Patron::Message::Preference::NoTransportType' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Transport type not available for this message.",
        fields => ['message_name', 'transport_type']
    },
    'Koha::Exceptions::Patron::Message::Preference::SMSNumberRequired' => {
        isa => 'Koha::Exceptions::Patron::Message::Preference',
        description => "Patron has no SMS number, cannot use sms transport type.",
        fields => ['message_name', 'borrowernumber' ]
    },
);

1;
