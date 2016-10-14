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
use Test::More tests => 78;
use Test::MockModule;
use Test::Warn;

use MARC::Record;

my %mail;
my $module = new Test::MockModule('Mail::Sendmail');
$module->mock(
    'sendmail',
    sub {
        warn "Fake sendmail";
        %mail = @_;
    }
);

use_ok('C4::Context');
use_ok('C4::Members');
use_ok('C4::Acquisition');
use_ok('C4::Biblio');
use_ok('C4::Bookseller');
use_ok('C4::Letters');
use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Order;
use Koha::Acquisition::Bookseller;
use Koha::Libraries;
my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);

my $library = $builder->build({
    source => 'Branch',
});
my $date = dt_from_string;
my $borrowernumber = AddMember(
    firstname    => 'Jane',
    surname      => 'Smith',
    categorycode => 'PT',
    branchcode   => $library->{branchcode},
    dateofbirth  => $date,
);

my $marc_record = MARC::Record->new;
my( $biblionumber, $biblioitemnumber ) = AddBiblio( $marc_record, '' );

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

# ResendMessage
my $resent = C4::Letters::ResendMessage($messages->[0]->{message_id});
my $message = C4::Letters::GetMessage( $messages->[0]->{message_id});
is( $resent, 1, 'The message should have been resent' );
is($message->{status},'pending', 'ResendMessage sets status to pending correctly (bug 12426)');
$resent = C4::Letters::ResendMessage($messages->[0]->{message_id});
is( $resent, 0, 'The message should not have been resent again' );
$resent = C4::Letters::ResendMessage();
is( $resent, undef, 'ResendMessage should return undef if not message_id given' );

# GetLetters
my $letters = C4::Letters::GetLetters();
is( @$letters, 0, 'GetLetters returns the correct number of letters' );

my $title = q|<<branches.branchname>> - <<status>>|;
my $content = q{Dear <<borrowers.firstname>> <<borrowers.surname>>,
According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

<<branches.branchname>>
<<branches.branchaddress1>>
URL: <<OPACBaseURL>>

The following item(s) is/are currently <<status>>:

<item> <<count>>. <<items.itemcallnumber>>, Barcode: <<items.barcode>> </item>

Thank-you for your prompt attention to this matter.
Don't forget your date of birth: <<borrowers.dateofbirth>>.
Look at this wonderful biblio timestamp: <<biblio.timestamp>>.
};

$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES (?,'my module','my code','my name',1,?,?,'email')|, undef, $library->{branchcode}, $title, $content );
$letters = C4::Letters::GetLetters();
is( @$letters, 1, 'GetLetters returns the correct number of letters' );
is( $letters->[0]->{branchcode}, $library->{branchcode}, 'GetLetters gets the branch code correctly' );
is( $letters->[0]->{module}, 'my module', 'GetLetters gets the module correctly' );
is( $letters->[0]->{code}, 'my code', 'GetLetters gets the code correctly' );
is( $letters->[0]->{name}, 'my name', 'GetLetters gets the name correctly' );


# getletter
my $letter = C4::Letters::getletter('my module', 'my code', $library->{branchcode}, 'email');
is( $letter->{branchcode}, $library->{branchcode}, 'GetLetters gets the branch code correctly' );
is( $letter->{module}, 'my module', 'GetLetters gets the module correctly' );
is( $letter->{code}, 'my code', 'GetLetters gets the code correctly' );
is( $letter->{name}, 'my name', 'GetLetters gets the name correctly' );
is( $letter->{is_html}, 1, 'GetLetters gets the boolean is_html correctly' );
is( $letter->{title}, $title, 'GetLetters gets the title correctly' );
is( $letter->{content}, $content, 'GetLetters gets the content correctly' );
is( $letter->{message_transport_type}, 'email', 'GetLetters gets the message type correctly' );

# Regression test for Bug 14206
$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES ('FFL','my module','my code','my name',1,?,?,'print')|, undef, $title, $content );
my $letter14206_a = C4::Letters::getletter('my module', 'my code', 'FFL' );
is( $letter14206_a->{message_transport_type}, 'print', 'Bug 14206 - message_transport_type not passed, correct mtt detected' );
my $letter14206_b = C4::Letters::getletter('my module', 'my code', 'FFL', 'print');
is( $letter14206_b->{message_transport_type}, 'print', 'Bug 14206 - message_transport_type passed, correct mtt detected'  );

# test for overdue_notices.pl
my $overdue_rules = {
    letter1         => 'my code',
};
my $i = 1;
my $branchcode = 'FFL';
my $letter14206_c = C4::Letters::getletter('my module', $overdue_rules->{"letter$i"}, $branchcode);
is( $letter14206_c->{message_transport_type}, 'print', 'Bug 14206 - correct mtt detected for call from overdue_notices.pl' );

# addalert
my $type = 'my type';
my $externalid = 'my external id';
my $alert_id = C4::Letters::addalert($borrowernumber, $type, $externalid);
isnt( $alert_id, undef, 'addalert does not return undef' );


# getalert
my $alerts = C4::Letters::getalert();
is( @$alerts, 1, 'getalert should not fail without parameter' );
$alerts = C4::Letters::getalert($borrowernumber);
is( @$alerts, 1, 'addalert adds an alert' );
is( $alerts->[0]->{alertid}, $alert_id, 'addalert returns the alert id correctly' );
is( $alerts->[0]->{type}, $type, 'addalert stores the type correctly' );
is( $alerts->[0]->{externalid}, $externalid, 'addalert stores the externalid correctly' );

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

my $sms_content = 'This is a SMS for an <<status>>';
$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES (?,'my module','my code','my name',1,'my title',?,'sms')|, undef, $library->{branchcode}, $sms_content );

my $tables = {
    borrowers => $borrowernumber,
    branches => $library->{branchcode},
    biblio => $biblionumber,
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
    branchcode  => $library->{branchcode},
    letter_code => 'my code',
    tables      => $tables,
    substitute  => $substitute,
    repeat      => $repeat,
));
my $retrieved_library = Koha::Libraries->find($library->{branchcode});
my $my_title_letter = $retrieved_library->branchname . qq| - $substitute->{status}|;
my $my_content_letter = qq|Dear Jane Smith,
According to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.

|.$retrieved_library->branchname.qq|
|.$retrieved_library->branchaddress1.qq|
URL: http://thisisatest.com

The following item(s) is/are currently $substitute->{status}:

<item> 1. $repeat->[0]->{itemcallnumber}, Barcode: $repeat->[0]->{barcode} </item>
<item> 2. $repeat->[1]->{itemcallnumber}, Barcode: $repeat->[1]->{barcode} </item>

Thank-you for your prompt attention to this matter.
Don't forget your date of birth: | . output_pref({ dt => $date, dateonly => 1 }) . q|.
Look at this wonderful biblio timestamp: | . output_pref({ dt => $date }) . ".\n";

is( $prepared_letter->{title}, $my_title_letter, 'GetPreparedLetter returns the title correctly' );
is( $prepared_letter->{content}, $my_content_letter, 'GetPreparedLetter returns the content correctly' );

$prepared_letter = GetPreparedLetter((
    module                 => 'my module',
    branchcode             => $library->{branchcode},
    letter_code            => 'my code',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
    message_transport_type => 'sms',
));
$my_content_letter = qq|This is a SMS for an $substitute->{status}|;
is( $prepared_letter->{content}, $my_content_letter, 'GetPreparedLetter returns the content correctly' );

$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('test_date','TEST_DATE','Test dates','A title with a timestamp: <<biblio.timestamp>>','This one only contains the date: <<biblio.timestamp | dateonly>>.');});
$prepared_letter = GetPreparedLetter((
    module                 => 'test_date',
    branchcode             => '',
    letter_code            => 'test_date',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
));
is( $prepared_letter->{content}, q|This one only contains the date: | . output_pref({ dt => $date, dateonly => 1 }) . q|.|, 'dateonly test 1' );

$dbh->do(q{UPDATE letter SET content = 'And also this one:<<timestamp | dateonly>>.' WHERE code = 'test_date';});
$prepared_letter = GetPreparedLetter((
    module                 => 'test_date',
    branchcode             => '',
    letter_code            => 'test_date',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
));
is( $prepared_letter->{content}, q|And also this one:| . output_pref({ dt => $date, dateonly => 1 }) . q|.|, 'dateonly test 2' );

$dbh->do(q{UPDATE letter SET content = 'And also this one:<<timestamp|dateonly >>.' WHERE code = 'test_date';});
$prepared_letter = GetPreparedLetter((
    module                 => 'test_date',
    branchcode             => '',
    letter_code            => 'test_date',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
));
is( $prepared_letter->{content}, q|And also this one:| . output_pref({ dt => $date, dateonly => 1 }) . q|.|, 'dateonly test 3' );

t::lib::Mocks::mock_preference( 'TimeFormat', '12hr' );
my $yesterday_night = $date->clone->add( days => -1 )->set_hour(22);
$dbh->do(q|UPDATE biblio SET timestamp = ? WHERE biblionumber = ?|, undef, $yesterday_night, $biblionumber );
$dbh->do(q{UPDATE letter SET content = 'And also this one:<<timestamp>>.' WHERE code = 'test_date';});
$prepared_letter = GetPreparedLetter((
    module                 => 'test_date',
    branchcode             => '',
    letter_code            => 'test_date',
    tables                 => $tables,
    substitute             => $substitute,
    repeat                 => $repeat,
));
is( $prepared_letter->{content}, q|And also this one:| . output_pref({ dt => $yesterday_night }) . q|.|, 'dateonly test 3' );

$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('claimacquisition','TESTACQCLAIM','Acquisition Claim','Item Not Received','<<aqbooksellers.name>>|<<aqcontacts.name>>|<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordered)</order>');});
$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('orderacquisition','TESTACQORDER','Acquisition Order','Order','<<aqbooksellers.name>>|<<aqcontacts.name>>|<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordered)</order>');});

# Test that _parseletter doesn't modify its parameters bug 15429
{
    my $values = { dateexpiry => '2015-12-13', };
    C4::Letters::_parseletter($prepared_letter, 'borrowers', $values);
    is( $values->{dateexpiry}, '2015-12-13', "_parseletter doesn't modify its parameters" );
}

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1,
        deliverytime => 5,
    },
    [
        { name => 'John Smith', acqprimary => 1, phone => '0123456x1', claimacquisition => 1, orderacquisition => 1 },
        { name => 'Leo Tolstoy', phone => '0123456x2', claimissues => 1 },
    ]
);
my $basketno = NewBasket($booksellerid, 1);

my $budgetid = C4::Budgets::AddBudget({
    budget_code => "budget_code_test_letters",
    budget_name => "budget_name_test_letters",
});

my $bib = MARC::Record->new();
if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
    $bib->append_fields(
        MARC::Field->new('200', ' ', ' ', a => 'Silence in the library'),
    );
} else {
    $bib->append_fields(
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
}

($biblionumber, $biblioitemnumber) = AddBiblio($bib, '');
my $order = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 1,
        biblionumber => $biblionumber,
        budget_id => $budgetid,
    }
)->insert;
my $ordernumber = $order->{ordernumber};

C4::Acquisition::CloseBasket( $basketno );
my $err;
warning_like {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ], 'TESTACQCLAIM' ) }
    qr/^Bookseller .* without emails at/,
    "SendAlerts prints a warning";
is($err->{'error'}, 'no_email', "Trying to send an alert when there's no e-mail results in an error");

my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
$bookseller->contacts->[0]->email('testemail@mydomain.com');
C4::Bookseller::ModBookseller($bookseller);
$bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });

# Ensure that the preference 'LetterLog' is set to logging
t::lib::Mocks::mock_preference( 'LetterLog', 'on' );

{
warning_is {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ) }
    "Fake sendmail",
    "SendAlerts is using the mocked sendmail routine (orderacquisition)";
is($err, 1, "Successfully sent order.");
is($mail{'To'}, 'testemail@mydomain.com', "mailto correct in sent order");
is($mail{'Message'}, 'my vendor|John Smith|Ordernumber ' . $ordernumber . ' (Silence in the library) (1 ordered)', 'Order notice text constructed successfully');
}


{
warning_is {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ], 'TESTACQCLAIM' ) }
    "Fake sendmail",
    "SendAlerts is using the mocked sendmail routine";

is($err, 1, "Successfully sent claim");
is($mail{'To'}, 'testemail@mydomain.com', "mailto correct in sent claim");
is($mail{'Message'}, 'my vendor|John Smith|Ordernumber ' . $ordernumber . ' (Silence in the library) (1 ordered)', 'Claim notice text constructed successfully');
}

{
use C4::Serials;

my $notes = 'notes';
my $internalnotes = 'intnotes';
$dbh->do(q|UPDATE subscription_numberpatterns SET numberingmethod='No. {X}' WHERE id=1|);
my $subscriptionid = NewSubscription(
     undef,      "",     undef, undef, undef, $biblionumber,
    '2013-01-01', 1, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          $notes,undef, '2013-01-01', undef, 1,
    undef,       undef,  0,    $internalnotes,  0,
    undef, undef, 0,          undef,         '2013-12-31', 0
);
$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('serial','RLIST','Serial issue notification','Serial issue notification','<<biblio.title>>,<<subscription.subscriptionid>>,<<serial.serialseq>>');});
my ($serials_count, @serials) = GetSerials($subscriptionid);
my $serial = $serials[0];

my $borrowernumber = AddMember(
    firstname    => 'John',
    surname      => 'Smith',
    categorycode => 'PT',
    branchcode   => $library->{branchcode},
    dateofbirth  => $date,
    email        => 'john.smith@test.de',
);
my $alert_id = C4::Letters::addalert($borrowernumber, 'issue', $subscriptionid);


my $err2;
warning_is {
$err2 = SendAlerts( 'issue', $serial->{serialid}, 'RLIST' ) }
    "Fake sendmail",
    "SendAlerts is using the mocked sendmail routine";
is($err2, 1, "Successfully sent serial notification");
is($mail{'To'}, 'john.smith@test.de', "mailto correct in sent serial notification");
is($mail{'Message'}, 'Silence in the library,'.$subscriptionid.',No. 0', 'Serial notification text constructed successfully');
}
