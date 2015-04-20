#!/usr/bin/perl

use Modern::Perl;

use Koha::Database;
use Koha::Overdues::Calendar;
use Koha::DateUtils;

use t::lib::TestBuilder;

use Test::More tests => 5;

use_ok('Koha::Overdues::Controller');

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM overduerules|);
$dbh->do(q|DELETE FROM overduerules_transport_types|);
$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM message_queue|);
$dbh->do(q|DELETE FROM message_queue_items|);
$dbh->do(q|DELETE FROM overdue_calendar_weekdays|);

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my @letterNumbers = 1;
my @borrowerCategories = 'STAFF';
my $verbose = 0;
my $sortByColumn = 0;
my $sortByColumnAlt = 0;
my $lookback = 120;
my $notNotForLoan = 6;
my $mergeNotificationBranches = 1;
my %repeatPageChange;

my $library = $builder->build({
    source => 'Branch',
});

my $calendar = Koha::Overdues::Calendar->new();

$calendar->upsertWeekdays($library->{branchcode},'1,2,3,4,5,6,7');

my $borrower = $builder->build({
    source => 'Borrower',
    value  => { branchcode => $library->{branchcode}, categorycode => 'STAFF'},
});

my $item = $builder->build({
    source => 'Item',
});

my $lastweek = DateTime->today(time_zone => C4::Context->tz())->add( days => -30 );
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
$dbh->do( q|INSERT INTO letter(branchcode,module,code,name,is_html,title,content,message_transport_type) VALUES (?,'circulation','ODUE1','Overdue messages',1,'Overdue messages',?,'print')|, undef, '', $my_content);

my $orm = Koha::Overdues::OverdueRulesMap->new();

my $rules = {  	branchCode => $library->{branchcode},
                borrowerCategory => 'STAFF',
                letterNumber => 1,
                delay => 2,
                letterCode => 'ODUE1',
                debarred => 1,
                fine => 2.5,
                messageTransportTypes => { print => 1,
                },
             };     

my ($overdueRule, $error) = $orm->upsertOverdueRule( $rules );

$orm->store();

my $controller = Koha::Overdues::Controller->new({verbose => $verbose,
                                                  sortBy => $sortByColumn,
                                                  sortByAlt => $sortByColumnAlt,
                                                  lookback => $lookback,
                                                  notNotForLoan => $notNotForLoan,
                                                  mergeBranches => $mergeNotificationBranches,
                                                  _repeatPageChange => ((scalar(%repeatPageChange)) ? \%repeatPageChange : undef),
                                                });


my ($overdueLetters, $errors) = $controller->gatherOverdueNotifications( (@letterNumbers)      ? \@letterNumbers      : undef,
                                                        (@borrowerCategories) ? \@borrowerCategories : undef,
                                                      );
#my ($overdueLetters, $errors) = $controller->gatherOverdueNotifications(undef, undef);
is(ref($overdueLetters), "ARRAY", "Overdue letters were returned");

my $overdueNotifications = Koha::MessageQueue::Notification::Overdues->search({})->count;

is($overdueNotifications, 1, "Found one overdue notification");

C4::Context->set_preference("PrintProviderImplementation",'PrintProviderLimbo');
my ($sentMessageQueues, $finedMessageQueues) = $controller->sendOverdueNotifications(1);

my $check_statement = $dbh->prepare(
    "SELECT 1 FROM message_queue ".
    "WHERE borrowernumber = ? AND letter_code = ? ".
    "AND message_transport_type = ? AND status = 'sent'".
"");

##Check that there is a matching MessageQueueItem for each given test.
my @params;
push @params, $borrower->{borrowernumber};
push @params, 'ODUE1';
push @params, 'print';
$check_statement->execute( @params );
my $ok = $check_statement->fetchrow();
last unless ok(($ok && $ok == 1), "Check: For params @params");

my @overdueNotifications = Koha::MessageQueue::Notification::Overdues->search({});
$_->delete() for @overdueNotifications;

$overdueNotifications = Koha::MessageQueue::Notification::Overdues->search({})->count;
is($overdueNotifications, 0, "Overdue notification has been deleted");

$schema->storage->txn_rollback;
