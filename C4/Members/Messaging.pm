package C4::Members::Messaging;

# Copyright (C) 2008 LibLime
#
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

use strict;
use warnings;
use C4::Context;

=head1 NAME

C4::Members::Messaging - manage patron messaging preferences

=head1 SYNOPSIS

  use C4::Members::Messaging

=head1 DESCRIPTION

This module lets you modify a patron's messaging preferences.

=head1 FUNCTIONS

=head1 TABLES

=head2 message_queue

The actual messages which will be sent via a cron job running
F<misc/cronjobs/process_message_queue.pl>.

=head2 message_attributes

What kinds of messages can be sent?

=head2 message_transport_types

What transports can messages be sent vith?  (email, sms, etc.)

=head2 message_transports

How are message_attributes and message_transport_types correlated?

=head2 borrower_message_preferences

What messages do the borrowers want to receive?

=head2 borrower_message_transport_preferences

What transport should a message be sent with?

=head1 CONFIG

=head2 Adding a New Kind of Message to the System

=over 4

=item 1.

Add a new template to the `letter` table.

=item 2.

Insert a row into the `message_attributes` table.

=item 3.

Insert rows into `message_transports` for each message_transport_type.

=back

=head1 SEE ALSO

L<C4::Letters>

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Andrew Moore <andrew.moore@liblime.com>

=cut

1;
