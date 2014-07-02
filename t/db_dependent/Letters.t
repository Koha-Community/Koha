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

use Test::More tests => 45;

use C4::Context;
use C4::Letters;
use C4::Members;
use C4::Branch;
use t::lib::Mocks;

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);

my $borrowernumber = AddMember(
    firstname    => 'Jane',
    surname      => 'Smith',
    categorycode => 'PT',
    branchcode   => 'CPL',
);


# GetMessageTransportTypes
my $mtts = C4::Letters::GetMessageTransportTypes();
is( @$mtts, 0, 'GetMessageTransportTypes returns the correct number of message types' );

$dbh->do(q|
    INSERT INTO message_transport_types( message_transport_type ) VALUES ('email'), ('phone'), ('print'), ('sms')
|);
$mtts = C4::Letters::GetMessageTransportTypes();
is_deeply( $mtts, ['email', 'phone', 'print', 'sms'], 'GetMessageTransportTypes returns all values' );


# EnqueueLetter
is( C4::Letters::EnqueueLetter(), undef, 'EnqueueLetter without argument returns undef' );

my $my_message = {
    borrowernumber         => $borrowernumber,
    message_transport_type => 'sms',
    to_address             => 'to@example.com',
    from_address           => 'from@example.com',
};
my $message_id = C4::Letters::EnqueueLetter($my_message);
is( $message_id, undef, 'EnqueueLetter without the letter argument returns undef' );

delete $my_message->{message_transport_type};
$my_message->{letter} = {
    content      => 'a message',
    title        => 'message title',
    metadata     => 'metadata',
    code         => 'TEST_MESSAGE',
    content_type => 'text/plain',
};
$message_id = C4::Letters::EnqueueLetter($my_message);
is( $message_id, undef, 'EnqueueLetter without the message type argument argument returns undef' );

$my_message->{message_transport_type} = 'sms';
$message_id = C4::Letters::EnqueueLetter($my_message);
ok(defined $message_id && $message_id > 0, 'new message successfully queued');


# GetQueuedMessages
my $messages = C4::Letters::GetQueuedMessages();
is( @$messages, 1, 'GetQueuedMessages without argument returns all the entries' );

$messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is( @$messages, 1, 'one message stored for the borrower' );
is( $messages->[0]->{message_id}, $message_id, 'EnqueueLetter returns the message id correctly' );
is( $messages->[0]->{borrowernumber}, $borrowernumber, 'EnqueueLetter stores the borrower number correctly' );
is( $messages->[0]->{subject}, $my_message->{letter}->{title}, 'EnqueueLetter stores the subject correctly' );
is( $messages->[0]->{content}, $my_message->{letter}->{content}, 'EnqueueLetter stores the content correctly' );
is( $messages->[0]->{message_transport_type}, $my_message->{message_transport_type}, 'EnqueueLetter stores the message type correctly' );
is( $messages->[0]->{status}, 'pending', 'EnqueueLetter stores the status pending correctly' );


# SendQueuedMessages
my $messages_processed = C4::Letters::SendQueuedMessages();
is($messages_processed, 1, 'all queued messages processed');

$messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is(
    $messages->[0]->{status},
    'failed',
    'message marked failed if tried to send SMS message for borrower with no smsalertnumber set (bug 11208)'
);


# GetLetters
my $letters = C4::Letters::GetLetters();
is( @$letters, 0, 'GetLetters returns the correct number of letters' );

my $title = q|<<branches.branchname>> - <<status>>|;
my $content = q|Dear <<borrowers.firstname>> <<borrowers.surname>>,
According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

<<branches.branchname>>
<<branches.branchaddress1>>
URL: <<OPACBaseURL>>

The following item(s) is/are currently <<status>>:

<item> <<count>>. <<items.itemcallnumber>>, Barcode: <<items.barcode>> </item>

Thank-you for your prompt attention to this matter.|;

$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES ('CPL','my module','my code','my name',1,?,?,'email')|, undef, $title, $content );
$letters = C4::Letters::GetLetters();
is( @$letters, 1, 'GetLetters returns the correct number of letters' );
is( $letters->[0]->{branchcode}, 'CPL', 'GetLetters gets the branch code correctly' );
is( $letters->[0]->{module}, 'my module', 'GetLetters gets the module correctly' );
is( $letters->[0]->{code}, 'my code', 'GetLetters gets the code correctly' );
is( $letters->[0]->{name}, 'my name', 'GetLetters gets the name correctly' );


# getletter
my $letter = C4::Letters::getletter('my module', 'my code', 'CPL', 'email');
is( $letter->{branchcode}, 'CPL', 'GetLetters gets the branch code correctly' );
is( $letter->{module}, 'my module', 'GetLetters gets the module correctly' );
is( $letter->{code}, 'my code', 'GetLetters gets the code correctly' );
is( $letter->{name}, 'my name', 'GetLetters gets the name correctly' );
is( $letter->{is_html}, 1, 'GetLetters gets the boolean is_html correctly' );
is( $letter->{title}, $title, 'GetLetters gets the title correctly' );
is( $letter->{content}, $content, 'GetLetters gets the content correctly' );
is( $letter->{message_transport_type}, 'email', 'GetLetters gets the message type correctly' );


# addalert
my $type = 'my type';
my $externalid = 'my external id';
my $alert_id = C4::Letters::addalert($borrowernumber, $type, $externalid);
isnt( $alert_id, undef, 'addalert does not return undef' );

my $alerts = C4::Letters::getalert($borrowernumber);
is( @$alerts, 1, 'addalert adds an alert' );
is( $alerts->[0]->{alertid}, $alert_id, 'addalert returns the alert id correctly' );
is( $alerts->[0]->{type}, $type, 'addalert stores the type correctly' );
is( $alerts->[0]->{externalid}, $externalid, 'addalert stores the externalid correctly' );


# getalert
$alerts = C4::Letters::getalert($borrowernumber, $type);
is( @$alerts, 1, 'getalert returns the correct number of alerts' );
$alerts = C4::Letters::getalert($borrowernumber, $type, $externalid);
is( @$alerts, 1, 'getalert returns the correct number of alerts' );
$alerts = C4::Letters::getalert($borrowernumber, 'another type');
is( @$alerts, 0, 'getalert returns the correct number of alerts' );
$alerts = C4::Letters::getalert($borrowernumber, $type, 'another external id');
is( @$alerts, 0, 'getalert returns the correct number of alerts' );


# delalert
eval {
    C4::Letters::delalert();
};
isnt( $@, undef, 'delalert without argument returns an error' );
$alerts = C4::Letters::getalert($borrowernumber);
is( @$alerts, 1, 'delalert without argument does not remove an alert' );

C4::Letters::delalert($alert_id);
$alerts = C4::Letters::getalert($borrowernumber);
is( @$alerts, 0, 'delalert removes an alert' );


# GetPreparedLetter
t::lib::Mocks::mock_preference('OPACBaseURL', 'http://thisisatest.com');

$content = 'This is a SMS for an <<status>>';
$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES ('CPL','my module','my code','my name',1,'my title',?,'sms')|, undef, $content );

my $tables = {
    borrowers => $borrowernumber,
    branches => 'CPL',
};
my $substitute = {
    status => 'overdue',
};
my $repeat = [
    {
        itemcallnumber => 'my callnumber1',
        barcode        => '1234',
    },
    {
        itemcallnumber => 'my callnumber2',
        barcode        => '5678',
    },
];
my $prepared_letter = GetPreparedLetter((
    module      => 'my module',
    branchcode  => 'CPL',
    letter_code => 'my code',
    tables      => $tables,
    substitute  => $substitute,
    repeat      => $repeat,
));
my $branch = GetBranchDetail('CPL');
my $my_title_letter = qq|$branch->{branchname} - $substitute->{status}|;
my $my_content_letter = qq|Dear Jane Smith,
According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

$branch->{branchname}
$branch->{branchaddress1}
URL: http://thisisatest.com

The following item(s) is/are currently $substitute->{status}:

<item> 1. $repeat->[0]->{itemcallnumber}, Barcode: $repeat->[0]->{barcode} </item>
<item> 2. $repeat->[1]->{itemcallnumber}, Barcode: $repeat->[1]->{barcode} </item>

Thank-you for your prompt attention to this matter.|;
is( $prepared_letter->{title}, $my_title_letter, 'GetPreparedLetter returns the title correctly' );
is( $prepared_letter->{content}, $my_content_letter, 'GetPreparedLetter returns the content correctly' );

$prepared_letter = GetPreparedLetter((
    module                 => 'my module',
    branchcode             => 'CPL',
    letter_code            => 'my code',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
    message_transport_type => 'sms',
));
$my_content_letter = qq|This is a SMS for an $substitute->{status}|;
is( $prepared_letter->{content}, $my_content_letter, 'GetPreparedLetter returns the content correctly' );

$dbh->rollback;
