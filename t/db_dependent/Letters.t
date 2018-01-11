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
use Test::More tests => 77;
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
use_ok('C4::Letters');
use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Bookseller::Contacts;
use Koha::Acquisition::Orders;
use Koha::Libraries;
use Koha::Notice::Templates;
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
my $patron_category = $builder->build({ source => 'Category' })->{categorycode};
my $date = dt_from_string;
my $borrowernumber = AddMember(
    firstname    => 'Jane',
    surname      => 'Smith',
    categorycode => $patron_category,
    branchcode   => $library->{branchcode},
    dateofbirth  => $date,
    smsalertnumber => undef,
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
    to_address             => undef,
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
my $messages_processed = C4::Letters::SendQueuedMessages( { type => 'email' });
is($messages_processed, 0, 'No queued messaged process if type limit passed with unused type');
$messages_processed = C4::Letters::SendQueuedMessages( { type => 'sms' });
is($messages_processed, 1, 'all queued messages processed, found correct number of messages with type limit');
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
is( $letters->[0]->{module}, 'my module', 'GetLetters gets the module correctly' );
is( $letters->[0]->{code}, 'my code', 'GetLetters gets the code correctly' );
is( $letters->[0]->{name}, 'my name', 'GetLetters gets the name correctly' );


# getletter
subtest 'getletter' => sub {
    plan tests => 16;
    t::lib::Mocks::mock_preference('IndependentBranches', 0);
    my $letter = C4::Letters::getletter('my module', 'my code', $library->{branchcode}, 'email');
    is( $letter->{branchcode}, $library->{branchcode}, 'GetLetters gets the branch code correctly' );
    is( $letter->{module}, 'my module', 'GetLetters gets the module correctly' );
    is( $letter->{code}, 'my code', 'GetLetters gets the code correctly' );
    is( $letter->{name}, 'my name', 'GetLetters gets the name correctly' );
    is( $letter->{is_html}, 1, 'GetLetters gets the boolean is_html correctly' );
    is( $letter->{title}, $title, 'GetLetters gets the title correctly' );
    is( $letter->{content}, $content, 'GetLetters gets the content correctly' );
    is( $letter->{message_transport_type}, 'email', 'GetLetters gets the message type correctly' );

    my $context = Test::MockModule->new('C4::Context');
    $context->mock( 'userenv', sub {
        return {
            flags  => 1,
            branch => "anotherlib" }
    });

    t::lib::Mocks::mock_preference('IndependentBranches', 1);
    $letter = C4::Letters::getletter('my module', 'my code', $library->{branchcode}, 'email');
    is( $letter->{branchcode}, $library->{branchcode}, 'GetLetters gets the branch code correctly' );
    is( $letter->{module}, 'my module', 'GetLetters gets the module correctly' );
    is( $letter->{code}, 'my code', 'GetLetters gets the code correctly' );
    is( $letter->{name}, 'my name', 'GetLetters gets the name correctly' );
    is( $letter->{is_html}, 1, 'GetLetters gets the boolean is_html correctly' );
    is( $letter->{title}, $title, 'GetLetters gets the title correctly' );
    is( $letter->{content}, $content, 'GetLetters gets the content correctly' );
    is( $letter->{message_transport_type}, 'email', 'GetLetters gets the message type correctly' );

    $context->unmock('userenv');
};



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
my $biblio_timestamp = dt_from_string( GetBiblioData($biblionumber)->{timestamp} );
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
Look at this wonderful biblio timestamp: | . output_pref({ dt => $biblio_timestamp })  . ".\n";

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

my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1,
        deliverytime => 5,
    }
)->store;
my $booksellerid = $bookseller->id;

Koha::Acquisition::Bookseller::Contact->new( { name => 'John Smith',  phone => '0123456x1', claimacquisition => 1, orderacquisition => 1, booksellerid => $booksellerid } )->store;
Koha::Acquisition::Bookseller::Contact->new( { name => 'Leo Tolstoy', phone => '0123456x2', claimissues      => 1, booksellerid => $booksellerid } )->store;
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
)->store;
my $ordernumber = $order->ordernumber;

C4::Acquisition::CloseBasket( $basketno );
my $err;
warning_like {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ], 'TESTACQCLAIM' ) }
    qr/^Bookseller .* without emails at/,
    "SendAlerts prints a warning";
is($err->{'error'}, 'no_email', "Trying to send an alert when there's no e-mail results in an error");

$bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
$bookseller->contacts->next->email('testemail@mydomain.com')->store;

# Ensure that the preference 'LetterLog' is set to logging
t::lib::Mocks::mock_preference( 'LetterLog', 'on' );

# SendAlerts needs branchemail or KohaAdminEmailAddress as sender
C4::Context->_new_userenv('DUMMY');
C4::Context->set_userenv( 0, 0, 0, 'firstname', 'surname', $library->{branchcode}, 'My Library', 0, '', '');
t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'library@domain.com' );

{
warning_is {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ) }
    "Fake sendmail",
    "SendAlerts is using the mocked sendmail routine (orderacquisition)";
is($err, 1, "Successfully sent order.");
is($mail{'To'}, 'testemail@mydomain.com', "mailto correct in sent order");
is($mail{'Message'}, 'my vendor|John Smith|Ordernumber ' . $ordernumber . ' (Silence in the library) (1 ordered)', 'Order notice text constructed successfully');

$dbh->do(q{DELETE FROM letter WHERE code = 'TESTACQORDER';});
warning_like {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ) }
    qr/No orderacquisition TESTACQORDER letter transported by email/,
    "GetPreparedLetter warns about missing notice template";
is($err->{'error'}, 'no_letter', "No TESTACQORDER letter was defined.");
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
    categorycode => $patron_category,
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

subtest 'GetPreparedLetter' => sub {
    plan tests => 4;

    Koha::Notice::Template->new(
        {
            module                 => 'test',
            code                   => 'test',
            branchcode             => '',
            message_transport_type => 'email'
        }
    )->store;
    my $letter;
    warning_like {
        $letter = C4::Letters::GetPreparedLetter(
            module      => 'test',
            letter_code => 'test',
        );
    }
    qr{^ERROR: nothing to substitute},
'GetPreparedLetter should warn if tables, substiture and repeat are not set';
    is( $letter, undef,
'No letter should be returned by GetPreparedLetter if something went wrong'
    );

    warning_like {
        $letter = C4::Letters::GetPreparedLetter(
            module      => 'test',
            letter_code => 'test',
            substitute  => {}
        );
    }
    qr{^ERROR: nothing to substitute},
'GetPreparedLetter should warn if tables, substiture and repeat are not set, even if the key is passed';
    is( $letter, undef,
'No letter should be returned by GetPreparedLetter if something went wrong'
    );

};



subtest 'TranslateNotices' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'TranslateNotices', '1' );

    $dbh->do(
        q|
        INSERT INTO letter (module, code, branchcode, name, title, content, message_transport_type, lang) VALUES
        ('test', 'code', '', 'test', 'a test', 'just a test', 'email', 'default'),
        ('test', 'code', '', 'test', 'una prueba', 'solo una prueba', 'email', 'es-ES');
    | );
    my $substitute = {};
    my $letter = C4::Letters::GetPreparedLetter(
            module                 => 'test',
            tables                 => $tables,
            letter_code            => 'code',
            message_transport_type => 'email',
            substitute             => $substitute,
    );
    is(
        $letter->{title},
        'a test',
        'GetPreparedLetter should return the default one if the lang parameter is not provided'
    );

    $letter = C4::Letters::GetPreparedLetter(
            module                 => 'test',
            tables                 => $tables,
            letter_code            => 'code',
            message_transport_type => 'email',
            substitute             => $substitute,
            lang                   => 'es-ES',
    );
    is( $letter->{title}, 'una prueba',
        'GetPreparedLetter should return the required notice if it exists' );

    $letter = C4::Letters::GetPreparedLetter(
            module                 => 'test',
            tables                 => $tables,
            letter_code            => 'code',
            message_transport_type => 'email',
            substitute             => $substitute,
            lang                   => 'fr-FR',
    );
    is(
        $letter->{title},
        'a test',
        'GetPreparedLetter should return the default notice if the one required does not exist'
    );

    t::lib::Mocks::mock_preference( 'TranslateNotices', '' );

    $letter = C4::Letters::GetPreparedLetter(
            module                 => 'test',
            tables                 => $tables,
            letter_code            => 'code',
            message_transport_type => 'email',
            substitute             => $substitute,
            lang                   => 'es-ES',
    );
    is( $letter->{title}, 'a test',
        'GetPreparedLetter should return the default notice if pref disabled but additional language exists' );

};

subtest 'SendQueuedMessages' => sub {

    plan tests => 4;
    t::lib::Mocks::mock_preference( 'SMSSendDriver', 'Email' );
    my $patron = Koha::Patrons->find($borrowernumber);
    $dbh->do(q|
        INSERT INTO message_queue(borrowernumber, subject, content, message_transport_type, status, letter_code)
        VALUES (?, 'subject', 'content', 'sms', 'pending', 'just_a_code')
        |, undef, $borrowernumber
    );
    eval { C4::Letters::SendQueuedMessages(); };
    is( $@, '', 'SendQueuedMessages should not explode if the patron does not have a sms provider set' );

    my $sms_pro = $builder->build_object({ class => 'Koha::SMS::Providers', value => { domain => 'kidclamp.rocks' } });
    ModMember( borrowernumber => $borrowernumber, smsalertnumber => '5555555555', sms_provider_id => $sms_pro->id() );
    $message_id = C4::Letters::EnqueueLetter($my_message); #using datas set around line 95 and forward
    C4::Letters::SendQueuedMessages();
    my $sms_message_address = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next()->to_address();
    is( $sms_message_address, '5555555555@kidclamp.rocks', 'SendQueuedMessages populates the to address correctly for SMS by email when to_address not set' );
    $schema->resultset('MessageQueue')->search({borrowernumber => $borrowernumber,status => 'sent'})->delete(); #clear borrower queue
    $my_message->{to_address} = 'fixme@kidclamp.iswrong';
    $message_id = C4::Letters::EnqueueLetter($my_message);

    my $number_attempted = C4::Letters::SendQueuedMessages({
        borrowernumber => -1, # -1 still triggers the borrowernumber condition
        letter_code    => 'PASSWORD_RESET',
    });
    is ( $number_attempted, 0, 'There were no password reset messages for SendQueuedMessages to attempt.' );

    C4::Letters::SendQueuedMessages();
    $sms_message_address = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next()->to_address();
    is( $sms_message_address, '5555555555@kidclamp.rocks', 'SendQueuedMessages populates the to address correctly for SMS by email when to_address is set incorrectly' );

};

subtest 'get_item_content' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference('dateformat', 'metric');
    t::lib::Mocks::mock_preference('timeformat', '24hr');
    my @items = (
        {date_due => '2041-01-01 12:34', title => 'a first title', barcode => 'a_first_barcode', author => 'a_first_author', itemnumber => 1 },
        {date_due => '2042-01-02 23:45', title => 'a second title', barcode => 'a_second_barcode', author => 'a_second_author', itemnumber => 2 },
    );
    my @item_content_fields = qw( date_due title barcode author itemnumber );

    my $items_content;
    for my $item ( @items ) {
        $items_content .= C4::Letters::get_item_content( { item => $item, item_content_fields => \@item_content_fields } );
    }

    my $expected_items_content = <<EOF;
01/01/2041 12:34\ta first title\ta_first_barcode\ta_first_author\t1
02/01/2042 23:45\ta second title\ta_second_barcode\ta_second_author\t2
EOF
    is( $items_content, $expected_items_content, 'get_item_content should return correct items info with time (default)' );


    $items_content = q||;
    for my $item ( @items ) {
        $items_content .= C4::Letters::get_item_content( { item => $item, item_content_fields => \@item_content_fields, dateonly => 1, } );
    }

    $expected_items_content = <<EOF;
01/01/2041\ta first title\ta_first_barcode\ta_first_author\t1
02/01/2042\ta second title\ta_second_barcode\ta_second_author\t2
EOF
    is( $items_content, $expected_items_content, 'get_item_content should return correct items info without time (if dateonly => 1)' );
};

subtest 'Test limit parameter for SendQueuedMessages' => sub {
    plan tests => 3;

    my $dbh = C4::Context->dbh;

    my $borrowernumber = AddMember(
        firstname    => 'Jane',
        surname      => 'Smith',
        categorycode => $patron_category,
        branchcode   => $library->{branchcode},
        dateofbirth  => $date,
        smsalertnumber => undef,
    );

    $dbh->do(q|DELETE FROM message_queue|);
    $my_message = {
        'letter' => {
            'content'      => 'a message',
            'metadata'     => 'metadata',
            'code'         => 'TEST_MESSAGE',
            'content_type' => 'text/plain',
            'title'        => 'message title'
        },
        'borrowernumber'         => $borrowernumber,
        'to_address'             => undef,
        'message_transport_type' => 'sms',
        'from_address'           => 'from@example.com'
    };
    C4::Letters::EnqueueLetter($my_message);
    C4::Letters::EnqueueLetter($my_message);
    C4::Letters::EnqueueLetter($my_message);
    C4::Letters::EnqueueLetter($my_message);
    C4::Letters::EnqueueLetter($my_message);
    my $messages_processed = C4::Letters::SendQueuedMessages( { limit => 1 } );
    is( $messages_processed, 1,
        'Processed 1 message with limit of 1 and 5 unprocessed messages' );
    $messages_processed = C4::Letters::SendQueuedMessages( { limit => 2 } );
    is( $messages_processed, 2,
        'Processed 2 message with limit of 2 and 4 unprocessed messages' );
    $messages_processed = C4::Letters::SendQueuedMessages( { limit => 3 } );
    is( $messages_processed, 2,
        'Processed 2 message with limit of 3 and 2 unprocessed messages' );
};
