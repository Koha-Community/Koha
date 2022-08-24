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
use Test::More tests => 86;
use Test::MockModule;
use Test::Warn;
use Test::Exception;

use Email::Sender::Failure;

use MARC::Record;

use utf8;

my ( $email_object, $sendmail_params );

my $email_sender_module = Test::MockModule->new('Email::Stuffer');
$email_sender_module->mock(
    'send_or_die',
    sub {
        ( $email_object, $sendmail_params ) = @_;
        my $str = $email_object->email->as_string;
        unlike $str, qr/I =C3=A2=C2=99=C2=A5 Koha=/, "Content is not double encoded";
        warn "Fake send_or_die";
    }
);

use_ok('C4::Context');
use_ok('C4::Members');
use_ok('C4::Acquisition', qw( NewBasket ));
use_ok('C4::Biblio', qw( AddBiblio GetBiblioData ));
use_ok('C4::Letters', qw( GetMessageTransportTypes GetMessage EnqueueLetter GetQueuedMessages SendQueuedMessages ResendMessage GetLetters GetPreparedLetter SendAlerts ));
use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Bookseller::Contacts;
use Koha::Acquisition::Orders;
use Koha::Libraries;
use Koha::Notice::Templates;
use Koha::Patrons;
use Koha::Subscriptions;
my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);

my $library = $builder->build({
    source => 'Branch',
    value  => {
        branchemail      => 'branchemail@address.com',
        branchreplyto    => 'branchreplyto@address.com',
        branchreturnpath => 'branchreturnpath@address.com',
    }
});
my $patron_category = $builder->build({ source => 'Category' })->{categorycode};
my $date = dt_from_string;
my $borrowernumber = Koha::Patron->new({
    firstname    => 'Jane',
    surname      => 'Smith',
    categorycode => $patron_category,
    branchcode   => $library->{branchcode},
    dateofbirth  => $date,
    smsalertnumber => undef,
})->store->borrowernumber;

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
    content      => 'I ♥ Koha',
    title        => '啤酒 is great',
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
isnt( $messages->[0]->{time_queued}, undef, 'Time queued inserted by default in message_queue table' );
is( $messages->[0]->{updated_on}, $messages->[0]->{time_queued}, 'Time status changed equals time queued when created in message_queue table' );
is( $messages->[0]->{failure_code}, '', 'Failure code for successful message correctly empty');

# Setting time_queued to something else than now
my $yesterday = dt_from_string->subtract( days => 1 );
Koha::Notice::Messages->find($messages->[0]->{message_id})->time_queued($yesterday)->store;

# SendQueuedMessages
my $messages_processed = C4::Letters::SendQueuedMessages( { type => 'email' });
is($messages_processed, 0, 'No queued messages processed if type limit passed with unused type');
$messages_processed = C4::Letters::SendQueuedMessages( { type => 'sms' });
is($messages_processed, 1, 'All queued messages processed, found correct number of messages with type limit');
$messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is(
    $messages->[0]->{status},
    'failed',
    'message marked failed if tried to send SMS message for borrower with no smsalertnumber set (bug 11208)'
);
is(
    $messages->[0]->{failure_code},
    'MISSING_SMS',
    'Correct failure code set for borrower with no smsalertnumber set'
);
isnt($messages->[0]->{updated_on}, $messages->[0]->{time_queued}, 'Time status changed differs from time queued when status changes' );
is(dt_from_string($messages->[0]->{time_queued}), $yesterday, 'Time queued remaines inmutable' );

# ResendMessage
my $resent = C4::Letters::ResendMessage($messages->[0]->{message_id});
my $message = C4::Letters::GetMessage( $messages->[0]->{message_id});
is( $resent, 1, 'The message should have been resent' );
is($message->{status},'pending', 'ResendMessage sets status to pending correctly (bug 12426)');
$resent = C4::Letters::ResendMessage($messages->[0]->{message_id});
is( $resent, 0, 'The message should not have been resent again' );
$resent = C4::Letters::ResendMessage();
is( $resent, undef, 'ResendMessage should return undef if not message_id given' );

# Delivery notes
is( $messages->[0]->{failure_code}, 'MISSING_SMS', 'Failure code set correctly for no smsalertnumber correctly set' );

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

# GetPreparedLetter
t::lib::Mocks::mock_preference('OPACBaseURL', 'http://thisisatest.com');
t::lib::Mocks::mock_preference( 'SendAllEmailsTo', '' );

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

warning_is {
    $prepared_letter = GetPreparedLetter((
        module                 => 'my module',
        branchcode             => $library->{branchcode},
        letter_code            => 'my code',
        tables                 => $tables,
        substitute             => { status => undef },
        repeat                 => $repeat,
        message_transport_type => 'sms',
    ));
}
undef, "No warning if GetPreparedLetter called with substitute containing undefined value";
is( $prepared_letter->{content}, q|This is a SMS for an |, 'GetPreparedLetter returns the content correctly when substitute contains undefined value' );

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
$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('orderacquisition','TESTACQORDER','Acquisition Order','Order','<<aqbooksellers.name>>|<<aqcontacts.name>>|<order>Ordernumber <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> ordered)</order> Basket name: [% basket.basketname %]');});

# Test that _parseletter doesn't modify its parameters bug 15429
{
    my $values = { dateexpiry => '2015-12-13', };
    C4::Letters::_parseletter($prepared_letter, 'borrowers', $values);
    is( $values->{dateexpiry}, '2015-12-13', "_parseletter doesn't modify its parameters" );
}

# Correctly format dateexpiry
{
    my $values = { dateexpiry => '2015-12-13', };

    t::lib::Mocks::mock_preference('dateformat', 'metric');
    t::lib::Mocks::mock_preference('timeformat', '24hr');
    my $letter = C4::Letters::_parseletter({ content => "expiry on <<borrowers.dateexpiry>>"}, 'borrowers', $values);
    is( $letter->{content}, 'expiry on 13/12/2015' );

    t::lib::Mocks::mock_preference('dateformat', 'metric');
    t::lib::Mocks::mock_preference('timeformat', '12hr');
    $letter = C4::Letters::_parseletter({ content => "expiry on <<borrowers.dateexpiry>>"}, 'borrowers', $values);
    is( $letter->{content}, 'expiry on 13/12/2015' );
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
my $basketno = NewBasket($booksellerid, 1, 'The basket name');

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

my $logged_in_user = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode => $library->{branchcode},
            email      => 'some@email.com'
        }
    }
);

t::lib::Mocks::mock_userenv({ patron => $logged_in_user });

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

Koha::Acquisition::Baskets->find( $basketno )->close;
my $err;
warning_like {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ], 'TESTACQCLAIM' ) }
    qr/^Bookseller .* without emails at/,
    "SendAlerts prints a warning";
is($err->{'error'}, 'no_email', "Trying to send an alert when there's no e-mail results in an error");

$bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
$bookseller->contacts->next->email('testemail@mydomain.com')->store;

# Ensure that the preference 'ClaimsLog' is set to logging
t::lib::Mocks::mock_preference( 'ClaimsLog', 'on' );

# SendAlerts needs branchemail or KohaAdminEmailAddress as sender
t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'library@domain.com' );

{
warning_like {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ) }
    qr|Fake send_or_die|,
    "SendAlerts is using the mocked send_or_die routine (orderacquisition)";
is($err, 1, "Successfully sent order.");
is($email_object->email->header('To'), 'testemail@mydomain.com', "mailto correct in sent order");
is($email_object->email->body, 'my vendor|John Smith|Ordernumber ' . $ordernumber . ' (Silence in the library) (1 ordered) Basket name: The basket name', 'Order notice text constructed successfully');

my $mocked_koha_email = Test::MockModule->new('Koha::Email');
$mocked_koha_email->mock( 'send_or_die', sub {
    Email::Sender::Failure->throw('something went wrong');
});

warning_like {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ); }
    qr{something went wrong},
    'Warning is printed';

is($err->{error}, 'something went wrong', "Send exception, error message returned");

$dbh->do(q{DELETE FROM letter WHERE code = 'TESTACQORDER';});
warning_like {
    $err = SendAlerts( 'orderacquisition', $basketno , 'TESTACQORDER' ) }
    qr/No orderacquisition TESTACQORDER letter transported by email/,
    "GetPreparedLetter warns about missing notice template";
is($err->{'error'}, 'no_letter', "No TESTACQORDER letter was defined.");
}

{
warning_like {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ], 'TESTACQCLAIM' ) }
    qr|Fake send_or_die|,
    "SendAlerts is using the mocked send_or_die routine";

is($err, 1, "Successfully sent claim");
is($email_object->email->header('To'), 'testemail@mydomain.com', "mailto correct in sent claim");
is($email_object->email->body, 'my vendor|John Smith|Ordernumber ' . $ordernumber . ' (Silence in the library) (1 ordered)', 'Claim notice text constructed successfully');

my $mocked_koha_email = Test::MockModule->new('Koha::Email');
$mocked_koha_email->mock( 'send_or_die', sub {
    Email::Sender::Failure->throw('something went wrong');
});

warning_like {
    $err = SendAlerts( 'claimacquisition', [ $ordernumber ] , 'TESTACQCLAIM' ); }
    qr{something went wrong},
    'Warning is printed';

is($err->{error}, 'something went wrong', "Send exception, error message returned");
}

{
use C4::Serials qw( NewSubscription GetSerials findSerialsByStatus ModSerialStatus );

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

my $patron = Koha::Patron->new({
    firstname    => 'John',
    surname      => 'Smith',
    categorycode => $patron_category,
    branchcode   => $library->{branchcode},
    dateofbirth  => $date,
    email        => 'john.smith@test.de',
})->store;
my $borrowernumber = $patron->borrowernumber;
my $subscription = Koha::Subscriptions->find( $subscriptionid );
$subscription->add_subscriber( $patron );

t::lib::Mocks::mock_userenv({ branch => $library->{branchcode} });
my $err2;
warning_like {
$err2 = SendAlerts( 'issue', $serial->{serialid}, 'RLIST' ) }
    qr|Fake send_or_die|,
    "SendAlerts is using the mocked send_or_die routine";

is($err2, 1, "Successfully sent serial notification");
is($email_object->email->header('To'), 'john.smith@test.de', "mailto correct in sent serial notification");
is($email_object->email->body, 'Silence in the library,'.$subscriptionid.',No. 0', 'Serial notification text constructed successfully');

t::lib::Mocks::mock_preference( 'SendAllEmailsTo', 'robert.tables@mail.com' );

my $err3;
warning_like {
$err3 = SendAlerts( 'issue', $serial->{serialid}, 'RLIST' ) }
    qr|Fake send_or_die|,
    "SendAlerts is using the mocked send_or_die routine";
is($email_object->email->header('To'), 'robert.tables@mail.com', "mailto address overwritten by SendAllMailsTo preference");

my $mocked_koha_email = Test::MockModule->new('Koha::Email');
$mocked_koha_email->mock( 'send_or_die', sub {
    Email::Sender::Failure->throw('something went wrong');
});

warning_like {
    $err = SendAlerts( 'issue', $serial->{serialid} , 'RLIST' ); }
    qr{something went wrong},
    'Warning is printed';

is($err->{error}, 'something went wrong', "Send exception, error message returned");

}
t::lib::Mocks::mock_preference( 'SendAllEmailsTo', '' );

subtest 'SendAlerts - claimissue' => sub {
    plan tests => 13;

    use C4::Serials;

    $dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('claimissues','TESTSERIALCLAIM','Serial claim test','Serial claim test','<<serial.serialid>>|<<subscription.startdate>>|<<biblio.title>>|<<biblioitems.issn>>');});

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

    Koha::Acquisition::Bookseller::Contact->new( { name => 'Leo Tolstoy', phone => '0123456x2', claimissues => 1, booksellerid => $booksellerid } )->store;

    my $bib = MARC::Record->new();
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $bib->append_fields(
            MARC::Field->new('011', ' ', ' ', a => 'xxxx-yyyy'),
            MARC::Field->new('200', ' ', ' ', a => 'Silence in the library'),
        );
    } else {
        $bib->append_fields(
            MARC::Field->new('022', ' ', ' ', a => 'xxxx-yyyy'),
            MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
        );
    }
    my ($biblionumber) = AddBiblio($bib, '');

    $dbh->do(q|UPDATE subscription_numberpatterns SET numberingmethod='No. {X}' WHERE id=1|);
    my $subscriptionid = NewSubscription(
         undef, "", $booksellerid, undef, undef, $biblionumber,
        '2013-01-01', 1, undef, undef,  undef,
        undef,  undef,  undef, undef, undef, undef,
        1, 'public',undef, '2013-01-01', undef, 1,
        undef, undef,  0, 'internal',  0,
        undef, undef, 0,  undef, '2013-12-31', 0
    );

    my ($serials_count, @serials) = GetSerials($subscriptionid);
    my  @serialids = ($serials[0]->{serialid});

    my $err;
    warning_like {
        $err = SendAlerts( 'claimissues', \@serialids, 'TESTSERIALCLAIM' ) }
        qr/^Bookseller .* without emails at/,
        "Warn on vendor without email address";

    $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
    $bookseller->contacts->next->email('testemail@mydomain.com')->store;

    # Ensure that the preference 'ClaimsLog' is set to logging
    t::lib::Mocks::mock_preference( 'ClaimsLog', 'on' );

    # SendAlerts needs branchemail or KohaAdminEmailAddress as sender
    t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

    t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'library@domain.com' );

    {
    warning_like {
        $err = SendAlerts( 'claimissues', \@serialids , 'TESTSERIALCLAIM' ) }
        qr|Fake send_or_die|,
        "SendAlerts is using the mocked send_or_die routine (claimissues)";
    is( $err, 1, "Successfully sent claim" );
    is( $email_object->email->header('To'),
        'testemail@mydomain.com', "mailto correct in sent claim" );
    is(
        $email_object->email->body,
        "$serialids[0]|2013-01-01|Silence in the library|xxxx-yyyy",
        'Serial claim letter for 1 issue constructed successfully'
    );

    my $mocked_koha_email = Test::MockModule->new('Koha::Email');
    $mocked_koha_email->mock( 'send_or_die', sub {
            Email::Sender::Failure->throw('something went wrong');
    });

    warning_like {
        $err = SendAlerts( 'claimissues', \@serialids , 'TESTSERIALCLAIM' ); }
        qr{something went wrong},
        'Warning is printed';

    is($err->{error}, 'something went wrong', "Send exception, error message returned");
    }

    {
    my $publisheddate = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
    my $serialexpected = ( C4::Serials::findSerialsByStatus( 1, $subscriptionid ) )[0];
    ModSerialStatus( $serials[0]->{serialid}, "No. 1", $publisheddate, $publisheddate, $publisheddate, '3', 'a note' );
    ($serials_count, @serials) = GetSerials($subscriptionid);
    push @serialids, ($serials[1]->{serialid});

    warning_like { $err = SendAlerts( 'claimissues', \@serialids, 'TESTSERIALCLAIM' ); }
        qr|Fake send_or_die|,
        "SendAlerts is using the mocked send_or_die routine (claimissues)";

    is(
        $email_object->email->body,
        "$serialids[0]|2013-01-01|Silence in the library|xxxx-yyyy"
          . $email_object->email->crlf
          . "$serialids[1]|2013-01-01|Silence in the library|xxxx-yyyy",
        "Serial claim letter for 2 issues constructed successfully"
    );

    $dbh->do(q{DELETE FROM letter WHERE code = 'TESTSERIALCLAIM';});
    warning_like {
        $err = SendAlerts( 'orderacquisition', $basketno , 'TESTSERIALCLAIM' ) }
        qr/No orderacquisition TESTSERIALCLAIM letter transported by email/,
        "GetPreparedLetter warns about missing notice template";
    is($err->{'error'}, 'no_letter', "No TESTSERIALCLAIM letter was defined");
    }

};

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

subtest 'Test SMS handling in SendQueuedMessages' => sub {

    plan tests => 14;

    t::lib::Mocks::mock_preference( 'SMSSendDriver', 'Email' );
    t::lib::Mocks::mock_preference('EmailSMSSendDriverFromAddress', '');

    my $patron = Koha::Patrons->find($borrowernumber);
    $dbh->do(q|
        INSERT INTO message_queue(borrowernumber, subject, content, message_transport_type, status, letter_code)
        VALUES (?, 'subject', 'content', 'sms', 'pending', 'just_a_code')
        |, undef, $borrowernumber
    );
    eval { C4::Letters::SendQueuedMessages(); };
    is( $@, '', 'SendQueuedMessages should not explode if the patron does not have a sms provider set' );

    my $sms_pro = $builder->build_object({ class => 'Koha::SMS::Providers', value => { domain => 'kidclamp.rocks' } });
    $patron->set( { smsalertnumber => '5555555555', sms_provider_id => $sms_pro->id() } )->store;
    $message_id = C4::Letters::EnqueueLetter($my_message); #using datas set around line 95 and forward

    warning_like { C4::Letters::SendQueuedMessages(); }
        qr|Fake send_or_die|,
        "SendAlerts is using the mocked send_or_die routine (claimissues)";

    my $message = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next();

    is( $message->letter_id, $messages->[0]->{id}, "Message letter_id is set correctly" );
    is( $message->to_address(), '5555555555@kidclamp.rocks', 'SendQueuedMessages populates the to address correctly for SMS by email when to_address not set' );
    is(
        $message->from_address(),
        'from@example.com',
        'SendQueuedMessages uses message queue item \"from address\" for SMS by email when EmailSMSSendDriverFromAddress system preference is not set'
    );

    $schema->resultset('MessageQueue')->search({borrowernumber => $borrowernumber, status => 'sent'})->delete(); #clear borrower queue

    t::lib::Mocks::mock_preference('EmailSMSSendDriverFromAddress', 'override@example.com');

    $message_id = C4::Letters::EnqueueLetter($my_message);
    warning_like { C4::Letters::SendQueuedMessages(); }
        qr|Fake send_or_die|,
        "SendAlerts is using the mocked send_or_die routine (claimissues)";

    $message = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next();

    is(
        $message->from_address(),
        'override@example.com',
        'SendQueuedMessages uses EmailSMSSendDriverFromAddress value for SMS by email when EmailSMSSendDriverFromAddress is set'
    );

    $schema->resultset('MessageQueue')->search({borrowernumber => $borrowernumber,status => 'sent'})->delete(); #clear borrower queue
    $my_message->{to_address} = 'fixme@kidclamp.iswrong';
    $message_id = C4::Letters::EnqueueLetter($my_message);

    my $number_attempted = C4::Letters::SendQueuedMessages({
        borrowernumber => -1, # -1 still triggers the borrowernumber condition
        letter_code    => 'PASSWORD_RESET',
    });
    is ( $number_attempted, 0, 'There were no password reset messages for SendQueuedMessages to attempt.' );

    warning_like { C4::Letters::SendQueuedMessages(); }
        qr|Fake send_or_die|,
        "SendAlerts is using the mocked send_or_die routine (claimissues)";

    my $sms_message_address = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next()->to_address();
    is( $sms_message_address, '5555555555@kidclamp.rocks', 'SendQueuedMessages populates the to address correctly for SMS by email when to_address is set incorrectly' );

    # Test using SMS::Send::Test driver that's bundled with SMS::Send
    t::lib::Mocks::mock_preference('SMSSendDriver', "AU::Test");

    $schema->resultset('MessageQueue')->search({borrowernumber => $borrowernumber, status => 'sent'})->delete(); #clear borrower queue
    C4::Letters::EnqueueLetter($my_message);
    C4::Letters::SendQueuedMessages();

    $sms_message_address = $schema->resultset('MessageQueue')->search({
        borrowernumber => $borrowernumber,
        status => 'sent'
    })->next()->to_address();
    is( $sms_message_address, '5555555555', 'SendQueuedMessages populates the to address correctly for SMS by SMS::Send driver to smsalertnumber when to_address is set incorrectly' );

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

subtest 'Test where parameter for SendQueuedMessages' => sub {
    plan tests => 1;

    my $dbh = C4::Context->dbh;

    my $borrowernumber = Koha::Patron->new({
        firstname    => 'Jane',
        surname      => 'Smith',
        categorycode => $patron_category,
        branchcode   => $library->{branchcode},
        dateofbirth  => $date,
        smsalertnumber => undef,
    })->store->borrowernumber;

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
    my $my_message2 = {
        'letter' => {
            'content'      => 'another message',
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
    my $my_message3 = {
        'letter' => {
            'content'      => 'a skipped message',
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
    C4::Letters::EnqueueLetter($my_message2);
    C4::Letters::EnqueueLetter($my_message3);
    my $messages_processed = C4::Letters::SendQueuedMessages( { where => q{content NOT LIKE '%skipped%'} } );
    is( $messages_processed, 2, "Correctly skipped processing one message containing the work 'skipped' in contents" );
};

subtest 'Test limit parameter for SendQueuedMessages' => sub {
    plan tests => 3;

    my $dbh = C4::Context->dbh;

    my $borrowernumber = Koha::Patron->new({
        firstname    => 'Jane',
        surname      => 'Smith',
        categorycode => $patron_category,
        branchcode   => $library->{branchcode},
        dateofbirth  => $date,
        smsalertnumber => undef,
    })->store->borrowernumber;

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

subtest 'Test message_id parameter for SendQueuedMessages' => sub {

    plan tests => 7;

    my $dbh = C4::Context->dbh;

    my $borrowernumber = Koha::Patron->new({
        firstname    => 'Jane',
        surname      => 'Smith',
        categorycode => $patron_category,
        branchcode   => $library->{branchcode},
        dateofbirth  => $date,
        smsalertnumber => undef,
    })->store->borrowernumber;

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
        'to_address'             => 'to@example.org',
        'message_transport_type' => 'email',
        'from_address'           => '@example.com' # invalid from_address
    };
    my $message_id = C4::Letters::EnqueueLetter($my_message);
    my $processed = C4::Letters::SendQueuedMessages( { message_id => $message_id } );
    is( $processed, 1, 'Processed 1 message when one message_id passed' );
    my $message_1 = C4::Letters::GetMessage($message_id);
    is( $message_1->{status}, 'failed', 'Invalid from_address => status failed' );
    is( $message_1->{failure_code}, 'INVALID_EMAIL:from', 'Failure code set correctly for invalid email parameter');

    $my_message->{from_address} = 'root@example.org'; # valid from_address
    $message_id = C4::Letters::EnqueueLetter($my_message);
    warning_like { C4::Letters::SendQueuedMessages( { message_id => $message_id } ); }
        qr|Fake send_or_die|,
        "SendQueuedMessages is using the mocked send_or_die routine";
    $message_1 = C4::Letters::GetMessage($message_1->{message_id});
    my $message_2 = C4::Letters::GetMessage($message_id);
    is( $message_1->{status}, 'failed', 'Message 1 status is unchanged' );
    is( $message_2->{status}, 'sent', 'Valid from_address => status sent' );
};
