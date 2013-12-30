#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Equinox Software, Inc.
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

use Test::More tests => 4;

use C4::Context;
use C4::Letters;
use C4::Members;

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do('DELETE FROM message_queue');

my $borrowernumber = AddMember(
    firstname    => 'Jane',
    surname      => 'Smith',
    categorycode => 'PT',
    branchcode   => 'CPL',
);

my $message_id = C4::Letters::EnqueueLetter({
    borrowernumber         => $borrowernumber,
    message_transport_type => 'sms',
    to_address             => 'to@example.com',
    from_address           => 'from@example.com',
    letter => {
        content      => 'a message',
        title        => 'message title',
        metadata     => 'metadata',
        code         => 'TEST_MESSAGE',
        content_type => 'text/plain',
    },
});

ok(defined $message_id && $message_id > 0, 'new message successfully queued');

my $messages_processed = C4::Letters::SendQueuedMessages();
is($messages_processed, 1, 'all queued messages processed');

my $messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is(scalar(@$messages), 1, 'one message stored for the borrower');

is(
    $messages->[0]->{status},
    'failed',
    'message marked failed if tried to send SMS message for borrower with no smsalertnumber set (bug 11208)'
);

$dbh->rollback;
