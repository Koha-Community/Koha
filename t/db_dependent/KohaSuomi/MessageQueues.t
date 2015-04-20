#!/usr/bin/perl

use Modern::Perl;

use Koha::Database;
use Koha::MessageQueue;
use Koha::DateUtils;
use C4::Letters;
use C4::Biblio;

use t::lib::TestBuilder;

use Test::More tests => 9;

use_ok('Koha::MessageQueue');
use_ok('Koha::MessageQueue::MessageQueueItem');

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_transport_types|);
$dbh->do(q|DELETE FROM message_queue_items|);

$dbh->do(q|
    INSERT INTO message_transport_types( message_transport_type ) VALUES ('email'), ('phone'), ('print'), ('sms')
|);

my $library = $builder->build({
    source => 'Branch',
});

my $borrower = $builder->build({
    source => 'Borrower',
    value  => { branchcode => $library->{branchcode}},
});

my $item = $builder->build({
    source => 'Item',
});

my $lastweek = DateTime->today(time_zone => C4::Context->tz())->add( days => -7 );
my $datedue = output_pref({ dt => dt_from_string( $lastweek ), dateformat => 'iso'});

my $issue = $builder->build({
    source => 'Issue',
    value  => { 
    	branchcode => $library->{branchcode}, 
    	borrowernumber => $borrower->{borrowernumber}, 
    	date_due => $datedue,
    	itemnumber => $item->{itemnumber},
    	issuedate => undef,
    	lastreneweddate => undef,
    	returndate => undef,
    	notedate => undef,
    	},
});
my $my_content = "<<borrowers.cardnumber>>\n<item>Barcode: <<items.barcode>>,</item> ";
$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES (?,'circulation','ODUE1','Overdue messages',1,'Overdue messages',?,'print')|, undef, $library->{branchcode}, $my_content);

my $messageTransportType = 'print';

my $tables = {
    borrowers => $borrower->{borrowernumber},
    branches => $library->{branchcode},
};
my $repeat = [
    {
        itemcallnumber => 'my callnumber1',
        barcode        => $item->{barcode},
        itemnumber	   => $item->{itemnumber},
    },
];

my $letter = C4::Letters::GetPreparedLetter (
                        module => 'circulation',
                        letter_code => 'ODUE1',
                        branchcode => $library->{branchcode},
                        message_transport_type => $messageTransportType,
                        tables => $tables,
                        #substitute => $substitute,
                        repeat => $repeat,
                        );

my $mqHash = {
            letter                 => $letter,
            borrowernumber         => $borrower->{borrowernumber},
            message_transport_type => $messageTransportType,
            from_address           => C4::Context->preference('KohaAdminEmailAddress'),
            to_address             => 'dontsend@example.com',
};
my $message_queue_id = C4::Letters::EnqueueLetter( $mqHash );
like($message_queue_id, qr/^\d+$/, "Message enqueued.");

my $messageQueues = $schema->resultset('MessageQueue')->search({})->count;
is($messageQueues, 1, 'Found message queue');

my $params = {  issue_id => $issue->{issue_id},
                    itemnumber => $item->{itemnumber}, branch => $library->{branchcode},
                    message_id => $message_queue_id,
                 };        

my $messageQueueItem = Koha::MessageQueue::MessageQueueItem->new($params);
$messageQueueItem->store();

my $allMessageQueueItemsCount = $schema->resultset('MessageQueueItem')->search({})->count();
is($allMessageQueueItemsCount, 1, 'Message queue has an item');

my $check_statement = $dbh->prepare(
    "SELECT 1 FROM message_queue_items mi ".
    "LEFT JOIN message_queue mq ON mi.message_id = mq.message_id ".
    "LEFT JOIN borrowers b ON mq.borrowernumber = b.borrowernumber ".
    "LEFT JOIN items i ON mi.itemnumber = i.itemnumber ".
    "LEFT JOIN issues iss ON iss.issue_id = mi.issue_id ".
    "WHERE b.cardnumber = ? AND i.barcode = ? AND mi.branch = ? AND mq.letter_code = ? ".
    "AND mq.message_transport_type = ? ".
"");

##Check that there is a matching MessageQueueItem for each given test.
my @params;
push @params, $borrower->{cardnumber};
push @params, $item->{barcode};
push @params, $library->{branchcode};
push @params, $letter->{code};
push @params, $messageTransportType;
$check_statement->execute( @params );
my $ok = $check_statement->fetchrow();
last unless ok(($ok && $ok == 1), "Check: For params @params");

$check_statement = $dbh->prepare(
    "SELECT 1 FROM message_queue mq ".
    "LEFT JOIN message_queue_items mqi ON mqi.message_id = mq.message_id ".
    "LEFT JOIN borrowers b ON mq.borrowernumber = b.borrowernumber ".
    "LEFT JOIN items i ON mqi.itemnumber = i.itemnumber ".
    "WHERE b.cardnumber = ? ".
    "AND i.barcode = ? ".
    "AND mq.letter_code = ? ".
    "AND mq.message_transport_type = ? ".
"");

##Check that there is a matching MessageQueue for each given test.
undef @params;
push @params, $borrower->{cardnumber};
push @params, $item->{barcode};
push @params, $letter->{code};
push @params, $messageTransportType;
$check_statement->execute( @params );
$ok = $check_statement->fetchrow();
last unless ok(($ok && $ok == 1), "Check: For params @params");

$check_statement = $dbh->prepare(
    "SELECT 1 FROM message_queue mq ".
    "LEFT JOIN borrowers b ON mq.borrowernumber = b.borrowernumber ".
    "WHERE b.cardnumber = ? ".
    "AND mq.letter_code = ? ".
    "AND mq.message_transport_type = ? ".
    "AND mq.content REGEXP ? ".
"");

    ##Check that there is a matching MessageQueue for each given test.
my $contentRegexp = 'Barcode: .*,';
undef @params;
push @params, $borrower->{cardnumber};
push @params, $letter->{code};
push @params, $messageTransportType;
push @params, $contentRegexp;
$check_statement->execute( @params );
$ok = $check_statement->fetchrow();
last unless ok(($ok && $ok == 1), "Check: For params @params");

$schema->resultset('MessageQueue')->search({})->delete_all();

$messageQueues = $schema->resultset('MessageQueue')->search({})->count;
is($messageQueues, 0, 'Message queues deleted');

$schema->storage->txn_rollback;